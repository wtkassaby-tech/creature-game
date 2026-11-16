"""Sim 1: stat progression for a player who always breeds their best pair.

Part A: the brief's original formulas (stored stat values, +-5% multiplicative
mutation, stored weight factor), with and without a per-stat ceiling.
Part B: the proposal (bounded quality gene, derived fit), with and without the
kin rule and the Bond Charm, and with alternative pip sizes.
Part C: breeds, coins and days to reach 80%, 95% and 100% of the ceiling under
the proposed cooldowns, hatch times, pens and costs, by activity profile.
"""
from __future__ import annotations

import os
import random
import statistics as st
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import (SLOTS, ROSTER, Creature, IdGen, breed, can_breed, is_kin, pct,
                    proposal_rules, species_part_stats, total, score, weight, wild, clamp)
import engine
from engine import Player, DAY

SEED = 20261115

# ---------------------------------------------------------------------------
# Part A: brief formulas
# ---------------------------------------------------------------------------

class BC:
    __slots__ = ("id", "parts", "used", "parents", "gen", "w")

    def __init__(self, cid, parts, parents=None, gen=0):
        self.id = cid
        self.parts = parts  # list of (species, {stat: value})
        self.used = 0
        self.parents = parents
        self.gen = gen
        self.w = weight(parts[1][0])  # body weight from the torso species


def bc_total(c):
    return sum(sum(d.values()) for _, d in c.parts)


def bc_wild(cid, sp):
    return BC(cid, [(sp, dict(species_part_stats(sp, s))) for s in SLOTS])


def bc_breed(a, b, rng, cid, ceiling=None, mut=0.05, rare=0.02, rare_mut=0.15):
    parts = []
    donors = []
    for i in range(len(SLOTS)):
        src = a if rng.random() < 0.5 else b
        sp, d = src.parts[i]
        nd = {}
        for k, v in d.items():
            m = rng.uniform(1 - mut, 1 + mut)
            if rng.random() < rare:
                m = rng.uniform(1 - rare_mut, 1 + rare_mut)
            nd[k] = v * m
        parts.append((sp, nd))
        donors.append(src)
    child = BC(cid, parts, parents=(a.id, b.id), gen=max(a.gen, b.gen) + 1)
    # stored weight factor on the legs (brief formula, clamp 0.7-1.3)
    f = clamp((donors[3].w / child.w) ** 0.5, 0.7, 1.3)
    parts[3][1]["Spd"] *= f
    if ceiling:
        for sp, d in parts:
            for k in d:
                d[k] = min(d[k], ceiling[k])
    a.used += 1
    b.used += 1
    return child


def greedy_brief(rng, species, n_breeds, limit=5, ceiling=None, pool_cap=30):
    ids = IdGen()
    pool = [bc_wild(ids(), rng.choice(species)) for _ in range(6)]
    start = max(bc_total(c) for c in pool)
    rec = []
    for n in range(1, n_breeds + 1):
        av = sorted([c for c in pool if c.used < limit], key=bc_total, reverse=True)[:12]
        best, bs = None, -1
        for i in range(len(av)):
            for j in range(i + 1, len(av)):
                s = bc_total(av[i]) + bc_total(av[j])
                if s > bs:
                    best, bs = (av[i], av[j]), s
        if best is None:
            break
        ch = bc_breed(best[0], best[1], rng, ids(), ceiling)
        pool.append(ch)
        if len(pool) > pool_cap:
            pool.sort(key=bc_total)
            pool.pop(0)
        top = max(pool, key=bc_total)
        rec.append((n, top.gen, bc_total(top) / start, max(d.get("Spd", 0) for _, d in [top.parts[3]])))
    return rec


# ---------------------------------------------------------------------------
# Part B: proposal (count-based, no clock)
# ---------------------------------------------------------------------------

def best_pair(pool, rules, steer=False):
    av = sorted([c for c in pool if c.used < rules["breed_limit"][c.rarity]],
                key=lambda c: score(c, rules), reverse=True)[:12]
    best, bs = None, -1
    for i in range(len(av)):
        for j in range(i + 1, len(av)):
            if rules["kin_rule"] and is_kin(av[i], av[j]):
                continue
            s = score(av[i], rules) + score(av[j], rules)
            if s > bs:
                best, bs = (av[i], av[j]), s
    return best


def greedy_prop(rng, rules, species, n_breeds, steer=False, pool_cap=30, stop_at_perfect=False):
    ids = IdGen()
    pool = [wild(ids(), rng.choice(species), rules, rng) for _ in range(6)]
    rec = []
    for n in range(1, n_breeds + 1):
        pr = best_pair(pool, rules)
        if pr is None:
            pool.append(wild(ids(), rng.choice(species), rules, rng))
            continue
        a, b = pr
        slot = None
        if steer:
            # Bond Charm: steer the slot with the biggest quality gap toward the better parent
            gaps = [(a.parts[i][1] - b.parts[i][1], i) for i in range(5)]
            g, i = max(gaps, key=lambda t: abs(t[0]))
            if g < 0:
                a, b = b, a
            slot = i
        ch = breed(a, b, rules, rng, ids(), steer_slot=slot)
        pool.append(ch)
        if len(pool) > pool_cap:
            pool.sort(key=lambda c: score(c, rules))
            pool.pop(0)
        top = max(pool, key=lambda c: score(c, rules))
        mq = sum(q for _, q in top.parts) / 5
        rec.append((n, top.gen, mq, score(top, rules)))
        if stop_at_perfect and mq >= 10:
            break
    return rec


def first_reach(rec, thr, idx=2):
    for r in rec:
        if r[idx] >= thr - 1e-9:
            return r[0]
    return None


def part_a():
    print("== Part A: brief formulas, best-pair breeder, breed limit 5, no kin rule ==")
    rng = random.Random(SEED)
    single = [2]
    mixed = list(range(8))
    # ceiling: 1.25 x the best species part value for each stat
    ceil = {"HP": 110 * 1.25, "Atk": 115 * 0.5 * 1.25, "Def": 115 * 1.25, "Spd": 130 * 1.25}
    for label, sp, c in (("single species, no ceiling", single, None),
                         ("mixed roster, no ceiling", mixed, None),
                         ("mixed roster, ceiling 1.25x best part", mixed, ceil)):
        rows = {g: [] for g in (5, 10, 20, 50)}
        spd = {g: [] for g in (5, 10, 20, 50)}
        for t in range(200):
            rec = greedy_brief(rng, sp, 1500, ceiling=c)
            for g in rows:
                hit = next((r for r in rec if r[1] >= g), None)
                if hit:
                    rows[g].append(hit[2])
        print(f"  {label}: best total vs best wild founder, median (p10-p90)")
        for g in rows:
            v = rows[g]
            print(f"    gen {g:>2}: x{st.median(v):.2f} ({pct(v, .1):.2f}-{pct(v, .9):.2f})  n={len(v)}")
    # adversarial weight walk, stored factor
    print("  adversarial weight walk (stored factor): legs Speed 80 moved through ever lighter torsos")
    spd = 80.0
    w = 500.0
    for step in range(8):
        nw = w / 1.69
        spd *= clamp((w / nw) ** 0.5, 0.7, 1.3)
        w = nw
    spd_down = spd
    spd *= clamp((w / 500) ** 0.5, 0.7, 1.3)
    print(f"    after 8 steps down: {spd_down:.0f}; after one step back up: {spd:.0f}")


def part_b():
    print("\n== Part B: proposal, best-pair breeder (count only) ==")
    variants = [
        ("proposal, one species, kin rule", proposal_rules(), [2], False),
        ("proposal, one species, no kin rule", proposal_rules(kin_rule=False), [2], False),
        ("proposal + Bond Charm every breed", proposal_rules(), [2], True),
        ("pull 15% (recommended), one species", proposal_rules(mut_rate=0.15), [2], False),
        ("pull 15% + Bond Charm", proposal_rules(mut_rate=0.15), [2], True),
        ("no pull (flat 10% up/10% down)", proposal_rules(pull=False), [2], False),
    ]
    out = {}
    for vi, (label, rules, sp, steer) in enumerate(variants):
        rng = random.Random(SEED + vi)
        by_gen = {g: [] for g in (5, 10, 20, 50)}
        reach = {8: [], 9.5: [], 10: []}
        for t in range(200):
            rec = greedy_prop(rng, rules, sp, 2500, steer=steer, stop_at_perfect=True)
            for g in by_gen:
                hit = next((r for r in rec if r[1] >= g), None)
                by_gen[g].append(hit[2] if hit else 10.0)
            for thr in reach:
                n = first_reach(rec, thr)
                reach[thr].append(n if n is not None else 2500)
        out[label] = reach
        print(f"  {label}")
        print("    best creature mean pips by generation: " + ", ".join(
            f"g{g}={st.median(v):.1f}" for g, v in by_gen.items()))
        print("    breeds to reach mean 8 / 9.5 / 10 pips, median (p90): " + ", ".join(
            f"{thr}: {st.median(v):.0f} ({pct(v, .9):.0f})" for thr, v in reach.items()))
    # what the quality range means in stats
    r = proposal_rules()
    c = wild(1, 2, r, random.Random(1))
    for q in (5, 8, 10):
        c.parts = [[2, q] for _ in SLOTS]
        print(f"    stat total at all-{q} pips: {total(c, r):.1f}")
    return out


# ---------------------------------------------------------------------------
# Part C: with the clock
# ---------------------------------------------------------------------------

class Breeder(Player):
    """A player who only breeds one species line, best pair first."""
    def catch_wild(self, now, rarity=0):
        c = wild(self.ids(), 2, self.rules, self.rng, owner=self.pid)
        self.add(c)


def part_c(rules_label, rules, days=365, trials=60):
    print(f"\n== Part C: clock, coins and days ({rules_label}) ==")
    res = {}
    for prof, spender in (("casual", False), ("regular", False), ("hardcore", False), ("hardcore", True)):
        rng = random.Random(SEED + len(prof) + spender)
        rows = {8: [], 9.5: [], 10: []}
        for t in range(trials):
            ids = IdGen()
            p = Breeder(t, prof, rules, rng, ids, spender=spender, policy="progress")
            p.play_min = 60 * 7  # all three launch biomes reached; breeder unlocked
            for _ in range(6):
                p.catch_wild(0)
            hit = {}
            spent_at = {}
            for d in range(days):
                p.run_day(d)
                best = max(p.pool, key=p.score)
                mq = sum(q for _, q in best.parts) / 5
                for thr in rows:
                    if thr not in hit and mq >= thr - 1e-9:
                        hit[thr] = (d + 1, p.log["breeds"], p.log["coins_spent"])
                if 10 in hit:
                    break
            for thr in rows:
                rows[thr].append(hit.get(thr, (days + 1, p.log["breeds"], p.log["coins_spent"])))
        label = prof + (" with 4 pens" if spender else " (2 pens)")
        res[label] = rows
        print(f"  {label}:")
        for thr, v in rows.items():
            d = [x[0] for x in v]
            b = [x[1] for x in v]
            c = [x[2] for x in v]
            reached = sum(1 for x in d if x <= days)
            print(f"    mean {thr} pips: days median {st.median(d):.0f} (p90 {pct(d, .9):.0f}), "
                  f"breeds {st.median(b):.0f}, coins {st.median(c)/1000:.0f}k "
                  f"(= {st.median(c)/300:.0f} min of biome-3 income), reached in {days} d: {reached}/{len(v)}")
    return res


if __name__ == "__main__":
    which = sys.argv[1] if len(sys.argv) > 1 else "abc"
    if "a" in which:
        part_a()
    if "b" in which:
        part_b()
    if "c" in which:
        part_c("proposal", proposal_rules())
    if "d" in which:
        from recommended import recommended_rules
        part_c("recommended rules", recommended_rules())
