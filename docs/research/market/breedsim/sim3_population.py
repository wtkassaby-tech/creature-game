"""Sim 3: population and rarity supply, agent-based, 180 days.

Full model: a few hundred players (casual / regular / hardcore, some with Gem
pens), sessions, wild catches by biome, pens, cooldowns, hatch timers, costs,
storage caps with release, an optional creature sink, kin rule, and an optional
trading market that pairs up lone gem creatures across players.

Grid model: the same rules for gem-tier creatures only (commons ignored), fast
enough to sweep breed limits and inheritance odds.
"""
from __future__ import annotations

import os
import random
import statistics as st
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import (GEM1, RUBY, DIAMOND, COMMON, IdGen, can_breed, is_kin, pct, proposal_rules,
                    breed_limit)
from engine import DAY, PROFILES, WORLD, Player

SEED = 20261115
MIX = (("casual", 0.50), ("regular", 0.35), ("hardcore", 0.15))


def quit_day(rng):
    x = rng.random()
    if x < 0.40:
        return rng.randint(1, 7)
    if x < 0.65:
        return rng.randint(8, 30)
    if x < 0.80:
        return rng.randint(31, 90)
    return 10**9


def make_players(n, rules, rng, world, open_pop=False, horizon=180):
    ids = IdGen()
    ps = []
    for i in range(n):
        x = rng.random()
        acc = 0
        for prof, share in MIX:
            acc += share
            if x < acc:
                break
        spender = rng.random() < world["spender_share"]
        jd = rng.randint(0, horizon - 1) if open_pop else 0
        qd = jd + quit_day(rng) if open_pop else 10**9
        ps.append(Player(i, prof, rules, random.Random(rng.random()), ids, world=world,
                         spender=spender, join_day=jd, quit_day=qd))
    return ps


def market(players, day, rules, rng, eff):
    """Pair up players who hold a fertile gem creature with no valid partner."""
    if eff <= 0:
        return 0
    moved = 0
    for tier in (GEM1, RUBY, DIAMOND):
        seekers = []
        for p in players:
            if not p.active(day):
                continue
            g = [c for c in p.pool if c.rarity == tier and c.used < breed_limit(c, rules)]
            if not g:
                continue
            ok = any(not is_kin(g[i], g[j]) for i in range(len(g)) for j in range(i + 1, len(g)))
            if not ok:
                seekers.append((p, g[0]))
        rng.shuffle(seekers)
        for k in range(0, len(seekers) - 1, 2):
            if rng.random() < eff:
                (pa, ca), (pb, cb) = seekers[k], seekers[k + 1]
                if is_kin(ca, cb):
                    continue
                pb.pool.remove(cb)
                pa.add(cb)
                moved += 1
    return moved


def run_full(rules, n=300, days=180, seed=SEED, world=WORLD, sink=0.0, mkt=0.5, open_pop=False,
             report_days=(7, 30, 90, 180), verbose=True, tag=""):
    rng = random.Random(seed)
    ps = make_players(n, rules, rng, world, open_pop, days)
    out = {}
    for d in range(days):
        for p in ps:
            p.run_day(d)
            p.daily_sink(sink)
        market(ps, d, rules, rng, mkt)
        for p in ps:
            if p.active(d):
                p.snapshot(d + 1)
        if d + 1 in report_days:
            out[d + 1] = summarise(ps, d, rules)
    if verbose:
        print_summary(out, tag)
    return out, ps


def summarise(ps, d, rules):
    act = [p for p in ps if p.active(d)]
    held = [0] * 5
    total = 0
    for p in act:
        for c in p.pool:
            held[c.rarity] += 1
        total += len(p.pool)
    wild = [sum(p.log["wild_gem"][r] for p in ps) for r in range(5)]
    bred = [sum(p.log["bred_gem"][r] for p in ps) for r in range(5)]
    sunk = [sum(p.log["sunk_gem"][r] + p.log["released_gem"][r] for p in ps) for r in range(5)]
    own = {}
    for prof, _ in MIX:
        grp = [p for p in act if p.profile == prof]
        own[prof] = (sum(1 for p in grp if any(c.rarity >= GEM1 for c in p.pool)) / max(1, len(grp)), len(grp))
    breeds = {prof: st.mean([p.log["breeds"] for p in act if p.profile == prof] or [0]) for prof, _ in MIX}
    return dict(active=len(act), held=held, total=total, wild=wild, bred=bred, sunk=sunk, own=own, breeds=breeds)


def print_summary(out, tag):
    print(f"\n-- {tag}")
    for d, s in out.items():
        g = s["held"][GEM1]
        r_eff = 1 - s["wild"][GEM1] / max(1, s["wild"][GEM1] + s["bred"][GEM1])
        print(f"  day {d:>3}: active {s['active']}, gem1 held {g} ({g / max(1, s['active']):.2f}/player, "
              f"{100 * g / max(1, s['total']):.1f}% of creatures); made wild {s['wild'][GEM1]}, bred {s['bred'][GEM1]}, "
              f"removed {s['sunk'][GEM1]}; R_eff {r_eff:.2f}; own one: "
              + ", ".join(f"{k} {v[0]*100:.0f}%" for k, v in s["own"].items())
              + "; breeds/player: " + ", ".join(f"{k} {v:.0f}" for k, v in s["breeds"].items()))


# ---------------------------------------------------------------------------
# Grid model: gem creatures only
# ---------------------------------------------------------------------------

class G:
    __slots__ = ("id", "parents", "used", "cool", "owner")

    def __init__(self, cid, owner, parents=None):
        self.id = cid
        self.parents = parents
        self.used = 0
        self.cool = 0
        self.owner = owner


def kin(a, b):
    if a.parents and b.id in a.parents:
        return True
    if b.parents and a.id in b.parents:
        return True
    return bool(a.parents and b.parents and set(a.parents) == set(b.parents))


def run_grid(B, p_pure, p_single, seed=SEED, n=300, days=180, wild_rate=0.05, cooldown=(720, 1440, 2880),
             hatch=240, mkt=0.5, sink=0.0, single_ok=True, kin_rule=True, fert_inherit=False):
    """Returns per-day gem counts and ownership. Players breed gem x gem when they can,
    else a lone gem with a common at p_single. Each player has `pens` but gem eggs
    only need one; commons are assumed always available as partners."""
    rng = random.Random(seed)
    prof_hours = {"casual": 20 / 60, "regular": 1.0, "hardcore": 3.0}
    # time to reach Dust Canyon (3 h of play)
    players = []
    for i in range(n):
        x = rng.random()
        prof = "casual" if x < 0.5 else "regular" if x < 0.85 else "hardcore"
        players.append(dict(prof=prof, h=prof_hours[prof], pool=[], eggs=[], seen=False))
    ids = 0
    made_wild = made_bred = removed = 0
    hist = []
    for d in range(days):
        now = d * DAY + 18 * 60
        for p in players:
            hours_played = p["h"] * (d + 1)
            # wild gem catches once Dust Canyon is reached
            if hours_played >= 3.0:
                lam = wild_rate * p["h"]
                k = 0
                while rng.random() < lam / (1 + lam) and k < 5:  # geometric approx of Poisson
                    k += 1
                for _ in range(k):
                    ids += 1
                    p["pool"].append(G(ids, p, None))
                    made_wild += 1
            # hatch
            keep = []
            for t, ch in p["eggs"]:
                if t <= now:
                    p["pool"].append(ch)
                else:
                    keep.append((t, ch))
            p["eggs"] = keep
            # breed: sessions per day approximated by number of chances
            chances = 1 if p["prof"] == "casual" else 2 if p["prof"] == "regular" else 3
            for c_i in range(chances):
                t = now + c_i * 240
                fert = [g for g in p["pool"] if g.used < (g.fert if fert_inherit and hasattr(g, "fert") else B) and g.cool <= t]
                pair = None
                for i in range(len(fert)):
                    for j in range(i + 1, len(fert)):
                        if not (kin_rule and kin(fert[i], fert[j])):
                            pair = (fert[i], fert[j])
                            break
                    if pair:
                        break
                if pair:
                    a, b = pair
                    prob = p_pure
                    parents = [a, b]
                elif fert and single_ok:
                    a = fert[0]
                    parents = [a]
                    prob = p_single
                else:
                    continue
                for g in parents:
                    g.used += 1
                    g.cool = t + cooldown[min(g.used, len(cooldown)) - 1]
                if rng.random() < prob:
                    ids += 1
                    ch = G(ids, p, tuple(g.id for g in parents) if len(parents) == 2 else (parents[0].id, -ids))
                    p["eggs"].append((t + hatch, ch))
                    made_bred += 1
            # sink: spent creatures beyond the best 3 removed at rate `sink`
            if sink > 0:
                spent = [g for g in p["pool"] if g.used >= B]
                for g in spent[3:]:
                    if rng.random() < sink:
                        p["pool"].remove(g)
                        removed += 1
        # market: lone fertile gems paired across players
        if mkt > 0:
            lone = []
            for p in players:
                fert = [g for g in p["pool"] if g.used < B]
                if len(fert) == 1:
                    lone.append((p, fert[0]))
            rng.shuffle(lone)
            for k in range(0, len(lone) - 1, 2):
                if rng.random() < mkt:
                    (pa, ga), (pb, gb) = lone[k], lone[k + 1]
                    pb["pool"].remove(gb)
                    pa["pool"].append(gb)
        held = sum(len(p["pool"]) for p in players)
        hist.append(held)
    own = {}
    for prof in ("casual", "regular", "hardcore"):
        grp = [p for p in players if p["prof"] == prof]
        own[prof] = sum(1 for p in grp if p["pool"]) / len(grp)
    return dict(hist=hist, wild=made_wild, bred=made_bred, removed=removed, own=own,
                r_eff=1 - made_wild / max(1, made_wild + made_bred))


def grid():
    print("\n== Grid: gem tier 1 only, 300 players, 180 days, market 50%, no sink ==")
    print("   B  p_pure p_single | held d30  d90  d180 | per player d180 | bred:wild | R_eff | growth d90->d180 | own d180 cas/reg/hc")
    rows = []
    for B in (1, 2, 3, 4, 5):
        for pp in (0.3, 0.4, 0.5, 0.6):
            for ps_ in (0.08, 0.12, 0.15):
                rs = [run_grid(B, pp, ps_, seed=SEED + k) for k in range(3)]
                h = [st.mean(r["hist"][d - 1] for r in rs) for d in (30, 90, 180)]
                bw = st.mean(r["bred"] / max(1, r["wild"]) for r in rs)
                re_ = st.mean(r["r_eff"] for r in rs)
                own = [st.mean(r["own"][k] for r in rs) for k in ("casual", "regular", "hardcore")]
                g = (h[2] - h[1]) / max(1, h[1] - h[0])  # second-half growth relative to first (1 = linear)
                rows.append((B, pp, ps_, h, bw, re_, g, own))
                print(f"   {B}  {pp:.2f}   {ps_:.2f}    | {h[0]:6.0f} {h[1]:5.0f} {h[2]:5.0f} | {h[2]/300:6.2f}          |"
                      f" {bw:5.2f}     | {re_:.2f}  | {g:5.2f}            | "
                      f"{own[0]*100:.0f}/{own[1]*100:.0f}/{own[2]*100:.0f}%")
    return rows


def sensitivity(B, pp, ps_):
    print(f"\n== Sensitivity around B={B}, pure {pp:.0%}, single {ps_:.0%} (grid model, 3 seeds each) ==")
    cases = [
        ("baseline (wild 0.025/h)", {}),
        ("wild rate x0.5", dict(wild_rate=0.0125)),
        ("wild rate x2", dict(wild_rate=0.05)),
        ("no market", dict(mkt=0.0)),
        ("perfect market", dict(mkt=1.0)),
        ("no kin rule", dict(kin_rule=False)),
        ("cooldowns halved", dict(cooldown=(360, 720))),
        ("B=3 instead", dict()),
        ("hatch instant (Gem speed-ups)", dict(hatch=0)),
        ("sink 2%/day on spent", dict(sink=0.02)),
        ("no lone-gem breeding", dict(single_ok=False)),
        ("365 days", dict(days=365)),
        ("1,000 players", dict(n=1000)),
    ]
    for label, kw in cases:
        kw.setdefault("wild_rate", 0.025)
        kw.setdefault("cooldown", (720, 1440))
        b_ = 3 if label.startswith("B=3") else B
        rs = [run_grid(b_, pp, ps_, seed=SEED + 100 + k, **kw) for k in range(3)]
        n = kw.get("n", 300)
        days = kw.get("days", 180)
        h90 = st.mean(r["hist"][89] for r in rs)
        hend = st.mean(r["hist"][-1] for r in rs)
        bw = st.mean(r["bred"] / max(1, r["wild"]) for r in rs)
        own = [st.mean(r["own"][k] for r in rs) for k in ("casual", "regular", "hardcore")]
        print(f"  {label:<30} per player d90 {h90/n:5.2f}, end {hend/n:5.2f}; bred:wild {bw:4.2f}; "
              f"R_eff {st.mean(r['r_eff'] for r in rs):.2f}; own {own[0]*100:.0f}/{own[1]*100:.0f}/{own[2]*100:.0f}%")


def tier_runs():
    print("\n== Ruby and Diamond (grid model, 300 players, 180 days, from first play) ==")
    for name, rate, cds, hatch, B, pp, ps_ in (
            ("Gem1 proposal (wild 0.05/h)", 0.05, (720, 1440, 2880), 240, 3, 0.50, 0.12),
            ("Gem1 recommended (wild 0.025/h)", 0.025, (720, 1440), 240, 2, 0.40, 0.10),
            ("Ruby proposal (wild 0.0125/h)", 0.0125, (1440, 2880), 480, 2, 0.60, 0.15),
            ("Ruby recommended", 0.0125, (1440, 2880), 480, 2, 0.40, 0.08),
            ("Diamond proposal (wild 0.006/h)", 0.006, (1440, 2880), 720, 2, 0.60, 0.15),
            ("Diamond recommended", 0.006, (2880, 4320), 720, 2, 0.30, 0.05)):
        rs = []
        for k in range(5):
            r = run_grid(B, pp, ps_, seed=SEED + 200 + k, wild_rate=rate, cooldown=cds, hatch=hatch, mkt=1.0)
            rs.append(r)
        hend = st.mean(r["hist"][-1] for r in rs)
        bw = st.mean(r["bred"] / max(1, r["wild"]) for r in rs)
        own = [st.mean(r["own"][k] for r in rs) for k in ("casual", "regular", "hardcore")]
        print(f"  {name:<34} B={B} pure {pp:.0%} single {ps_:.0%}: per player d180 {hend/300:.2f}; bred:wild {bw:.2f};"
              f" R_eff {st.mean(r['r_eff'] for r in rs):.2f}; own d180 {own[0]*100:.0f}/{own[1]*100:.0f}/{own[2]*100:.0f}%"
              " (perfect market)")


if __name__ == "__main__":
    which = sys.argv[1] if len(sys.argv) > 1 else "full"
    if which == "full":
        run_full(proposal_rules(), tag="Proposal, closed cohort of 300, market 50%, no sink")
    elif which == "full_open":
        run_full(proposal_rules(), n=600, open_pop=True, tag="Proposal, open population (600 joins, churn), market 50%")
    elif which.startswith("abm"):
        # abm <label> : targeted ABM variants
        from recommended import recommended_rules, recommended_world
        w_low = recommended_world()
        lab = sys.argv[2]
        variants = {
            "prop_lowwild": (proposal_rules(), w_low, 0.0, False),
            "rec": (recommended_rules(), w_low, 0.01, False),
            "rec_open": (recommended_rules(), w_low, 0.01, True),
            "rec_highwild": (recommended_rules(), WORLD, 0.01, False),
            "rec_B3": (recommended_rules(breed_limit=(5, 5, 3, 2, 2)), w_low, 0.01, False),
            "rec_p50": (recommended_rules(p_pure=(0, 0, 0.5, 0.4, 0.35), p_single=(0, 0, 0.12, 0.08, 0.05)), w_low, 0.01, False),
            "rec_nosink": (recommended_rules(), w_low, 0.0, False),
            "rec_1000": (recommended_rules(), w_low, 0.01, False),
        }
        rules, world, sink, op = variants[lab]
        n = 1000 if lab == "rec_1000" else (600 if op else 300)
        run_full(rules, n=n, world=world, sink=sink, open_pop=op, tag=f"ABM {lab}: n={n}, sink {sink:.0%}/day, market 50%")
    elif which == "grid":
        grid()
    elif which == "sens":
        sensitivity(int(sys.argv[2]), float(sys.argv[3]), float(sys.argv[4]))
    elif which == "tiers":
        tier_runs()
