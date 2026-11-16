"""Sim 4: offspring level (40% of the parents' average) and the "biome reached"
rule. Looks for loopholes and dead ends, and tests that a rare colour can be
bred onto a stronger creature under the kin rule and breed limits."""
from __future__ import annotations

import itertools
import os
import random
import statistics as st
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import (ROSTER, SLOTS, Creature, IdGen, biome, breed, is_kin, proposal_rules, stats, total, wild,
                    pct)

SEED = 20261115


def level_scale(lv):
    return (lv + 10) / 60  # level 50 = 1.0 (assumption, see report)


def child_level(a, b, share=0.40, floor_=None):
    v = int(share * (a + b) / 2)
    return max(floor_, v) if floor_ is not None else v


def part_level():
    print("== Offspring level ==")
    print(f"  50 + 45 -> {child_level(50, 45)} (brief says about 20)")
    zero = [(a, b) for a in range(1, 101) for b in range(1, 101) if child_level(a, b) == 0]
    print(f"  parent pairs (levels 1-100) giving level 0 without a floor: {len(zero)}, e.g. {zero[:4]}")
    # max child level by parent level cap
    for cap in (20, 30, 50, 100):
        print(f"  parents at level {cap} -> child level {child_level(cap, cap)}")
    # repeated breeding never raises level; levels only come from play
    lv = (50, 50)
    chain = []
    a, b = lv
    for g in range(5):
        c = child_level(a, b)
        chain.append(c)
        a, b = c, c
    print(f"  breeding children of children with no levelling: {chain} (no runaway; floors at 0 without a minimum)")


def part_biome_rule():
    print("\n== Biome-reached rule: what counts as a creature's biome? ==")
    r = proposal_rules()

    def best(allowed_torso, allowed_parts):
        bestv, bestc = -1, None
        for combo in itertools.product(range(8), repeat=5):
            if combo[1] not in allowed_torso:
                continue
            if any(sp not in allowed_parts for sp in combo):
                continue
            c = Creature(0, [[sp, 5] for sp in combo])
            v = total(c, r)
            if v > bestv:
                bestv, bestc = v, combo
        return bestv, bestc

    b1 = [i for i in range(8) if biome(i) == 1]
    b12 = [i for i in range(8) if biome(i) <= 2]
    alls = list(range(8))
    v_native, c_native = best(b1, b1)
    v_torso, c_torso = best(b1, alls)
    print(f"  biome-1 player, all parts from biome 1: best total {v_native:.1f} "
          f"({'/'.join(ROSTER[s][0] for s in c_native)})")
    print(f"  if only the torso's biome is checked: {v_torso:.1f} "
          f"({'/'.join(ROSTER[s][0] for s in c_torso)}), +{(v_torso / v_native - 1) * 100:.0f}%")
    # cost loophole when cost uses the torso's biome tier
    base = 1000
    late = max(biome(s) for s in c_torso)
    print(f"  breed cost of that hybrid if tier comes from the torso: {base * 1} vs from its latest part: {base * late}"
          f" (x{late})")


def part_level_loophole():
    print("\n== Level loophole: traded high-level parents ==")
    # A new player in Greenwood (giant ~ level 12, wild 3-8) is given two level-60 Greenwood creatures.
    giant = 12
    for lv in (60, 24):
        print(f"  level {lv} creature vs Greenwood giant (level {giant}): stat multiple "
              f"x{level_scale(lv) / level_scale(giant):.2f}")
    print(f"  their bred child is level {child_level(60, 60)}; passes the biome rule because every part is from Greenwood")
    # with a per-player level cap from badges (creatures above it fight at the cap)
    cap_by_badges = {0: 15, 1: 25, 2: 35, 3: 45}
    print("  with a badge level cap (0 badges -> 15): both fight as level 15, x"
          f"{level_scale(15) / level_scale(giant):.2f} vs the giant")


def part_colour(trials=4000):
    print("\n== Rare colour onto a strong line (recessive gene, kin rule on) ==")
    rng = random.Random(SEED)
    r = proposal_rules()
    out = {}
    for label, limit in (("common/uncommon rare-colour parent, limit 5", 5), ("gem-tier parent, limit 3", 3),
                         ("Ruby parent, limit 2", 2), ("limit 1", 1)):
        succ, breeds_used = 0, []
        for t in range(trials):
            # A: rare colour rr, average parts; S1..S4: strong unrelated nn; carriers cannot be bought.
            n_breeds = 0
            a_left = limit
            carriers = []  # (id, parents)
            sid = 10
            found = False
            # step 1: A x strong partners until A is spent
            while a_left > 0:
                sid += 1
                n_breeds += 1
                a_left -= 1
                carriers.append(("c%d" % sid, ("A", "S%d" % sid)))  # every child carries r (A is rr)
            # step 2: carriers bred together (half-siblings allowed), else carrier x new strong partner
            # to make more carriers whose children can meet.
            budget = 12
            pool = [(c, p, 1.0) for c, p in carriers]  # (id, parents, prob carries r)
            while budget > 0 and not found:
                pair = None
                for i in range(len(pool)):
                    for j in range(i + 1, len(pool)):
                        pi, pj = pool[i][1], pool[j][1]
                        full_sib = set(pi) == set(pj)
                        parent_child = pool[i][0] in pj or pool[j][0] in pi
                        if not full_sib and not parent_child:
                            pair = (pool[i], pool[j])
                            break
                    if pair:
                        break
                budget -= 1
                n_breeds += 1
                if pair:
                    (ci, pi, qi), (cj, pj, qj) = pair
                    gi = rng.random() < qi
                    gj = rng.random() < qj
                    if gi and gj and rng.random() < 0.25:
                        found = True
                        break
                    sid += 1
                    # child carries with prob 0.5*qi + 0.5*qj (approx.)
                    pool.append(("c%d" % sid, (ci, cj), 0.5 * qi + 0.5 * qj))
                else:
                    c = pool[0]
                    sid += 1
                    pool.append(("c%d" % sid, (c[0], "S%d" % sid), 0.5 * c[2]))
            if found:
                succ += 1
                breeds_used.append(n_breeds)
        out[label] = (succ / trials, breeds_used)
        print(f"  {label}: rare colour shown on a strong-line child within {limit}+12 breeds in "
              f"{succ / trials * 100:.0f}% of runs; median breeds {st.median(breeds_used) if breeds_used else 'n/a'}")
    print("  without the kin rule a carrier could breed straight back to its rr parent: 50% per breed")
    return out


if __name__ == "__main__":
    part_level()
    part_biome_rule()
    part_level_loophole()
    part_colour()
