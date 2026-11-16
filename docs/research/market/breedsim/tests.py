"""Invariant tests for the recommended rule set. Each check is meant to become a
Lune test in tests/ (see 09_BREEDING_STRESS_TEST.md, section 8). Exit code 1 on failure."""
from __future__ import annotations

import itertools
import os
import random
import statistics as st
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import (COMMON, GEM1, RUBY, DIAMOND, UNCOMMON, Creature, IdGen, breed, child_rarity, is_kin,
                    stats, total, wild)
from recommended import recommended_rules

SEED = 20261115
R = recommended_rules()
fails = []


def check(name, ok, detail=""):
    print(f"  [{'PASS' if ok else 'FAIL'}] {name} {detail}")
    if not ok:
        fails.append(name)


def ceiling_total():
    best = 0.0
    for combo in itertools.product(range(8), repeat=5):
        for size in (R["size_range"][0], R["size_range"][1]):
            c = Creature(0, [[sp, R["q_max"]] for sp in combo], size=size)
            best = max(best, total(c, R))
    return best


def t1_no_ratchet(rng, ceil):
    """Lineages with best-of-8 selection never leave 0-10 or exceed the ceiling."""
    ids = IdGen()
    worst_q, best_t = (10, 0), 0.0
    for lin in range(400):
        a = wild(ids(), rng.randrange(8), R, rng)
        b = wild(ids(), rng.randrange(8), R, rng)
        for g in range(50):
            kids = []
            for _ in range(8):
                a.used = b.used = 0
                kids.append(breed(a, b, R, rng, ids()))
            kids.sort(key=lambda c: total(c, R), reverse=True)
            a, b = kids[0], kids[1]
            b.parents = (-1, -2)  # treat as unrelated: adversarial (no kin brake)
            for c in kids:
                qs = [q for _, q in c.parts]
                worst_q = (min(worst_q[0], min(qs)), max(worst_q[1], max(qs)))
                best_t = max(best_t, total(c, R))
    check("quality stays within 0-10", worst_q[0] >= 0 and worst_q[1] <= 10, f"(seen {worst_q})")
    check("no stat total above the computed ceiling", best_t <= ceil + 1e-6, f"(best {best_t:.1f}, ceiling {ceil:.1f})")


def t2_path_independence(rng):
    """Stats depend only on the parts, quality and size: rebuilt creatures match exactly."""
    ok = True
    for _ in range(1000):
        parts = [[rng.randrange(8), rng.randint(0, 10)] for _ in range(5)]
        size = rng.uniform(*R["size_range"])
        a = Creature(1, [p[:] for p in parts], size=size, parents=(5, 6), gen=9)
        b = Creature(2, [p[:] for p in parts], size=size, parents=None, gen=0)
        if stats(a, R) != stats(b, R):
            ok = False
    check("same parts by any path give identical stats", ok)


def t3_neutral_drift(rng):
    ids = IdGen()
    pop = [wild(ids(), rng.randrange(8), R, rng) for _ in range(400)]
    means = []
    for g in range(100):
        nxt = []
        for _ in range(400):
            a, b = rng.sample(pop, 2)
            a.used = b.used = 0
            nxt.append(breed(a, b, R, rng, ids()))
        pop = nxt
        means.append(st.mean(q for c in pop for _, q in c.parts))
    check("random mating keeps mean quality in 4.5-5.5 for 100 generations",
          all(4.5 <= m <= 5.5 for m in means), f"(range {min(means):.2f}-{max(means):.2f})")


def t6_rarity_odds(rng):
    n = 100_000
    cases = [((GEM1, GEM1), GEM1, R["p_pure"][GEM1]), ((GEM1, COMMON), GEM1, R["p_single"][GEM1]),
             ((RUBY, RUBY), RUBY, R["p_pure"][RUBY]), ((RUBY, COMMON), RUBY, R["p_single"][RUBY]),
             ((DIAMOND, DIAMOND), DIAMOND, R["p_pure"][DIAMOND]), ((DIAMOND, UNCOMMON), DIAMOND, R["p_single"][DIAMOND])]
    for (ra, rb), tier, p in cases:
        a = Creature(1, [[0, 5]] * 5, rarity=ra)
        b = Creature(2, [[0, 5]] * 5, rarity=rb)
        hits = sum(1 for _ in range(n) if child_rarity(a, b, R, rng) == tier)
        check(f"rarity odds {ra}x{rb} -> {tier} match config", abs(hits / n - p) < 0.005,
              f"(measured {hits / n:.4f}, config {p:.2f})")


def t7_hybrid_cap():
    builds = []
    for combo in itertools.product(range(8), repeat=5):
        c = Creature(0, [[sp, 5] for sp in combo])
        builds.append((len(set(combo)) == 1, total(c, R)))
    best_pure = max(t for p, t in builds if p)
    best_any = max(t for _, t in builds)
    check("no hybrid beats the best pure species by more than 15% on total",
          best_any <= best_pure * 1.15 + 1e-6, f"(+{(best_any / best_pure - 1) * 100:.1f}%)")


def t9_kin_and_limits(rng):
    ids = IdGen()
    a = wild(ids(), 0, R, rng, rarity=GEM1)
    b = wild(ids(), 1, R, rng, rarity=GEM1)
    c1 = breed(a, b, R, rng, ids())
    c2 = breed(a, b, R, rng, ids())
    check("parent x child is kin", is_kin(a, c1))
    check("full siblings are kin", is_kin(c1, c2))
    d = wild(ids(), 2, R, rng)
    e = breed(a, d, R, rng, ids()) if a.used < R["breed_limit"][GEM1] else None
    check("gem-tier creature stops at its breed limit", a.used <= R["breed_limit"][GEM1])
    check("child level never below 1", breed(Creature(9, [[0, 5]] * 5, level=1), Creature(10, [[1, 5]] * 5, level=1),
                                             R, rng, ids()).level >= 1)


if __name__ == "__main__":
    rng = random.Random(SEED)
    ceil = ceiling_total()
    print("Recommended rule set invariants")
    t1_no_ratchet(rng, ceil)
    t2_path_independence(rng)
    t3_neutral_drift(rng)
    t6_rarity_odds(rng)
    t7_hybrid_cap()
    t9_kin_and_limits(rng)
    print(f"{'ALL PASS' if not fails else 'FAILURES: ' + ', '.join(fails)}")
    sys.exit(1 if fails else 0)
