"""The recommended rule set from 09_BREEDING_STRESS_TEST.md, as one config.
Every number here is in the report's final table."""
from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import proposal_rules

RECOMMENDED_WORLD_GEM_RATE = (0.0, 0.0, 0.025, 0.0125, 0.006)  # wild gem catches per hour of play


def recommended_world():
    from engine import WORLD
    return dict(WORLD, gem_rate_per_h=RECOMMENDED_WORLD_GEM_RATE, breed_unlock_h=0.33)


def recommended_rules(**over) -> dict:
    r = proposal_rules(
        name="recommended",
        pip=0.01, q_min=0, q_max=10, wild_q=(3, 7),
        mut_rate=0.15, rare_mut=0.02,
        fit_clamp=(0.6, 1.15),
        budget_cap=330 * 1.15,       # 1.15 x the body plan's species budget
        size_range=(0.9, 1.1), size_affects_torso=True,
        kin_rule=True,
        breed_limit=(5, 5, 2, 2, 2),
        p_pure=(0.0, 0.0, 0.40, 0.40, 0.30),
        p_single=(0.0, 0.0, 0.10, 0.08, 0.05),
        cooldowns=((30, 60, 120, 240, 480), (30, 60, 120, 240, 480),
                   (720, 1440), (1440, 2880), (2880, 4320)),
        hatch=(30, 45, 240, 480, 720),
        rarity_mult=(1, 1.5, 4, 10, 25),
        count_mult=(1, 1.25, 1.5, 2, 2.5),
        base_cost=400,
    )
    r.update(over)
    return r
