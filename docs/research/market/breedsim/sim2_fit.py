"""Sim 2: can species weight choices give a dominant build?

Enumerates every part combination (8 species ^ 5 slots = 32,768) on one body
plan, under the proposal's fit factor (legs only, clamp 0.85-1.15) and variants,
then runs a simple duel model (turn order by Speed, damage from Attack against
Defense, a damage roll) to see whether one build beats the field.
"""
from __future__ import annotations

import itertools
import os
import random
import statistics as st
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import ROSTER, SLOTS, Creature, proposal_rules, stats

SEED = 20261115
DUEL_MODE = "flat"  # "flat": Atk x 100/(100+Def); "ratio": Atk x Atk/Def
NAMES = [r[0] for r in ROSTER]


def build_stats(combo, rules, size=1.0, q=5):
    c = Creature(0, [[sp, q] for sp in combo], size=size)
    return stats(c, rules, rarity=False)


def enumerate_builds(rules, size=1.0):
    out = []
    for combo in itertools.product(range(8), repeat=5):
        s = build_stats(combo, rules, size)
        out.append((combo, s, sum(s.values())))
    return out


def label(combo):
    return "/".join(NAMES[sp][:5] for sp in combo)  # head/torso/front/legs/tail


def duel(a, b, rng):
    """One fight. Returns True if a wins. Stats dicts at equal level."""
    ha, hb = a["HP"] * 2.0, b["HP"] * 2.0

    def hit(att, dfn):
        dodge = max(0.0, 0.25 * (dfn["Spd"] - att["Spd"]) / (dfn["Spd"] + att["Spd"]))
        if rng.random() < dodge:
            return 0.0
        if DUEL_MODE == "ratio":
            return 0.4 * att["Atk"] * (att["Atk"] / dfn["Def"]) ** 0.5 * 80 / dfn["Def"] ** 0.5 * rng.uniform(0.85, 1.0) / 8.9
        return 0.5 * att["Atk"] * 100 / (100 + dfn["Def"]) * rng.uniform(0.85, 1.0)

    a_first = a["Spd"] > b["Spd"] or (a["Spd"] == b["Spd"] and rng.random() < 0.5)
    for _ in range(200):
        if a_first:
            hb -= hit(a, b)
            if hb <= 0:
                return True
            ha -= hit(b, a)
            if ha <= 0:
                return False
        else:
            ha -= hit(b, a)
            if ha <= 0:
                return False
            hb -= hit(a, b)
            if hb <= 0:
                return True
    return rng.random() < 0.5


def winrate(a, b, rng, n):
    return sum(duel(a, b, rng) for _ in range(n)) / n


def analyse(rules, tag, rng, size=1.0, do_duels=True):
    builds = enumerate_builds(rules, size)
    builds.sort(key=lambda t: t[2], reverse=True)
    pure = [b for b in builds if len(set(b[0])) == 1]
    best_pure = max(pure, key=lambda t: t[2])
    best, worst = builds[0], builds[-1]
    print(f"\n== {tag} ==")
    print(f"  best total  {best[2]:.1f}  {label(best[0])}  {fmt(best[1])}")
    print(f"  worst total {worst[2]:.1f}  {label(worst[0])}")
    print(f"  best pure   {best_pure[2]:.1f}  {NAMES[best_pure[0][0]]}; pure range "
          f"{min(p[2] for p in pure):.1f}-{best_pure[2]:.1f}")
    over = sum(1 for b in builds if b[2] > best_pure[2] * 1.12)
    print(f"  hybrids above best pure by >12%: {over} of {len(builds)}; best hybrid is "
          f"+{(best[2] / best_pure[2] - 1) * 100:.1f}% over best pure")
    for s in ("HP", "Atk", "Def", "Spd"):
        b = max(builds, key=lambda t: t[1][s])
        bp = max(pure, key=lambda t: t[1][s])
        print(f"  max {s}: {b[1][s]:.1f} ({label(b[0])}) vs best pure {bp[1][s]:.1f}")
    # legs fit spread
    fits = [b[1]["Spd"] for b in builds]
    res = dict(best=best, worst=worst, best_pure=best_pure, builds=builds)
    if not do_duels:
        return res
    # duel field: top 40 by total, 8 pure, top 10 per stat, 30 random
    field = {b[0]: b for b in builds[:40]}
    for p in pure:
        field[p[0]] = p
    for s in ("HP", "Atk", "Def", "Spd"):
        for b in sorted(builds, key=lambda t: t[1][s], reverse=True)[:10]:
            field[b[0]] = b
    for b in rng.sample(builds, 30):
        field[b[0]] = b
    F = list(field.values())
    n = 40
    wr = {}
    for i, a in enumerate(F):
        w = []
        for j, b in enumerate(F):
            if i != j:
                w.append(winrate(a[1], b[1], rng, n))
        wr[a[0]] = (st.mean(w), min(w))
    ranked = sorted(F, key=lambda b: wr[b[0]][0], reverse=True)
    print(f"  duel field of {len(F)} builds, {n} fights per pairing:")
    for b in ranked[:5]:
        print(f"    {label(b[0]):<34} mean win {wr[b[0]][0]*100:.0f}%, worst matchup {wr[b[0]][1]*100:.0f}%  {fmt(b[1])}")
    top_pure = max(pure, key=lambda b: wr[b[0]][0])
    print(f"    best pure in duels: {NAMES[top_pure[0][0]]} mean win {wr[top_pure[0]][0]*100:.0f}%")
    unbeaten = [b for b in F if wr[b[0]][1] >= 0.5]
    print(f"    builds with no losing matchup: {len(unbeaten)}")
    res.update(ranked=ranked, wr=wr)
    return res


def fmt(s):
    return " ".join(f"{k}{v:.0f}" for k, v in s.items())


def quality_matters(rng):
    """Win rate of a creature whose stats are all x(1+e) against an identical one."""
    print("\n== How much does an all-stat edge matter in a duel? (Thornfox mirror, 4,000 fights) ==")
    rules = proposal_rules()
    base = build_stats((2,) * 5, rules)
    for e in (0.01, 0.025, 0.05, 0.075, 0.10, 0.15):
        a = {k: v * (1 + e) for k, v in base.items()}
        # Speed tie-break removed: compare with Speed equal so only HP/Atk/Def count
        a2 = dict(a)
        a2["Spd"] = base["Spd"]
        print(f"  +{e*100:>4.1f}% all stats: win {winrate(a, base, rng, 4000)*100:.0f}%;"
              f" without the Speed edge: {winrate(a2, base, rng, 4000)*100:.0f}%")


if __name__ == "__main__":
    rng = random.Random(SEED)
    analyse(proposal_rules(), "Proposal: fit on legs only, clamp 0.85-1.15, size 1.0", rng)
    analyse(proposal_rules(fit_clamp=(1.0, 1.0)), "No fit factor at all", rng, do_duels=False)
    analyse(proposal_rules(fit_clamp=(0.7, 1.3)), "Brief clamp 0.7-1.3 (derived, not stored)", rng)
    # size gene exploit: proposal multiplies body weight by a size gene with no other effect
    r = proposal_rules()
    big = analyse(r, "Size gene 1.2 (proposal, size only feeds the fit)", rng, size=1.2, do_duels=False)
    small = analyse(r, "Size gene 0.8 (proposal, size only feeds the fit)", rng, size=0.8, do_duels=False)
    print(f"\n  size 0.8 vs 1.2, same parts: best total {small['best'][2]:.1f} vs {big['best'][2]:.1f}")
    # recommended: fit is symmetric (heavy torso on light legs is slow; light body on heavy legs gains)
    # and size also scales torso HP/Def so a small body is not free
    analyse(proposal_rules(size_affects_torso=True), "Recommended: size also scales torso HP/Def, size 0.8", rng,
            size=0.8, do_duels=False)
    for capm in (1.05, 1.10, 1.15):
        analyse(proposal_rules(budget_cap=330 * capm, fit_clamp=(0.6, 1.15), size_affects_torso=True),
                f"Recommended: budget cap {capm:.2f} x species budget, fit clamp 0.6-1.15, size scales torso", rng)
    DUEL_MODE = "ratio"
    print("\n######## Same tests with a ratio damage formula (damage ~ Atk x Atk/Def) ########")
    analyse(proposal_rules(), "Proposal (ratio damage)", rng)
    analyse(proposal_rules(budget_cap=330 * 1.10, fit_clamp=(0.6, 1.15), size_affects_torso=True),
            "Recommended cap 1.10 (ratio damage)", rng)
    DUEL_MODE = "flat"
    quality_matters(rng)
