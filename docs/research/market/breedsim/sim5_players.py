"""Sim 5: what a casual player (20 min a day) has after the first week, and what
a hardcore player (3 h a day) has after a month, under the proposal and the
recommended rules. Uses the full player model from engine.py."""
from __future__ import annotations

import os
import random
import statistics as st
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import GEM1, IdGen, proposal_rules, pct, total
from engine import WORLD, Player
from recommended import recommended_rules, recommended_world

SEED = 20261115


def cohort(rules, world, prof, days, n=200, seed=SEED):
    rng = random.Random(seed)
    rows = []
    for i in range(n):
        ids = IdGen()
        p = Player(i, prof, rules, random.Random(rng.random()), ids, world=world,
                   spender=False)
        for d in range(days):
            p.run_day(d)
        best = max(p.pool, key=p.score)
        best_w = p.best_wild_total
        mq = sum(q for _, q in best.parts) / 5
        hyb = len({sp for sp, _ in best.parts})
        rows.append(dict(
            breeds=p.log["breeds"], first=p.log["first_breed_day"],
            gain=(p.score(best) / best_w - 1) * 100 if best_w else 0.0,
            mq=mq, hyb=hyb, gem=sum(1 for c in p.pool if c.rarity >= GEM1),
            hours=p.play_min / 60, biome=p.biome(), pool=len(p.pool),
            spent=p.log["coins_spent"]))
    return rows


def show(tag, rows):
    f = lambda k: st.median([r[k] for r in rows])
    firsts = [r["first"] for r in rows if r["first"] is not None]
    print(f"  {tag}: play {f('hours'):.1f} h, biome {f('biome'):.0f}; breeds median {f('breeds'):.0f} "
          f"(p10 {pct([r['breeds'] for r in rows], .1):.0f}, p90 {pct([r['breeds'] for r in rows], .9):.0f}); "
          f"first breed on day {st.median(firsts) + 1 if firsts else float('nan'):.1f}; "
          f"best creature +{f('gain'):.0f}% stat total over best wild catch "
          f"(p10 {pct([r['gain'] for r in rows], .1):.0f}%, p90 {pct([r['gain'] for r in rows], .9):.0f}%); "
          f"best mean pips {f('mq'):.1f}; species in best {f('hyb'):.0f}; "
          f"own a gem creature {100 * sum(1 for r in rows if r['gem']) / len(rows):.0f}%; gem creatures median {f('gem'):.0f}")


if __name__ == "__main__":
    w_low = recommended_world()
    for name, rules, world in (("proposal", proposal_rules(), WORLD),
                               ("recommended", recommended_rules(), w_low)):
        print(f"\n== {name} ==")
        show("casual, day 7", cohort(rules, world, "casual", 7))
        show("casual, day 30", cohort(rules, world, "casual", 30))
        show("regular, day 7", cohort(rules, world, "regular", 7))
        show("hardcore, day 7", cohort(rules, world, "hardcore", 7))
        show("hardcore, day 30", cohort(rules, world, "hardcore", 30))
