"""Shared model for the breeding stress test.

Everything here is pure and seeded so it can be ported to Lune tests.
Units: time in minutes, coins in abstract units (income 100 coins per minute of
play in biome 1, scaling with biome tier). See 09_BREEDING_STRESS_TEST.md for the
assumptions behind every number.
"""
from __future__ import annotations

import math
import random

SLOTS = ("head", "torso", "front", "legs", "tail")
STATS = ("HP", "Atk", "Def", "Spd")
COMMON, UNCOMMON, GEM1, RUBY, DIAMOND = 0, 1, 2, 3, 4
RARITY_NAMES = ("Common", "Uncommon", "Gem1", "Ruby", "Diamond")
RARITY_BOOST = (1.0, 1.0, 1.05, 1.10, 1.15)

# A plausible launch roster on one body plan (four-legged), 8 species.
# (name, biome, weight, HP, Atk, Def, Spd). Every species has the same 300 budget.
ROSTER = [
    ("Mossbun", 1, 8, 60, 60, 50, 130),      # light sprinter
    ("Stumpback", 1, 220, 110, 50, 110, 30), # heavy tank
    ("Thornfox", 1, 25, 75, 80, 65, 80),     # balanced
    ("Burrowbear", 1, 180, 100, 100, 70, 30),# heavy bruiser
    ("Dunestrider", 2, 140, 80, 60, 50, 110),# heavy but fast legs
    ("Scuttlejaw", 2, 40, 55, 115, 55, 75),  # glass cannon
    ("Shellback", 3, 300, 95, 60, 115, 30),  # heaviest tank
    ("Reefdart", 3, 15, 60, 75, 55, 110),    # light and quick
]
N_SPECIES = len(ROSTER)
TAIL_BONUS_SHARE = 0.10  # tail adds 10% of the species budget to its best stat


def species_part_stats(sp: int, slot: str) -> dict:
    """Base stats a species' part carries (before quality, fit, level, rarity)."""
    _, _, _, hp, atk, df, spd = ROSTER[sp]
    if slot == "head":
        return {"Atk": atk * 0.5}
    if slot == "front":
        return {"Atk": atk * 0.5}
    if slot == "torso":
        return {"HP": hp, "Def": df}
    if slot == "legs":
        return {"Spd": spd}
    # tail: small bonus to the species' best stat
    best = max(("HP", hp), ("Atk", atk), ("Def", df), ("Spd", spd), key=lambda t: t[1])[0]
    return {best: 300 * TAIL_BONUS_SHARE}


def weight(sp: int) -> float:
    return ROSTER[sp][2]


def biome(sp: int) -> int:
    return ROSTER[sp][1]


# ---------------------------------------------------------------------------
# Rule sets
# ---------------------------------------------------------------------------

def proposal_rules(**over) -> dict:
    """The 04_BREEDING_DESIGN.md proposal, as written."""
    r = dict(
        name="proposal",
        q_min=0, q_max=10, q_mid=5, pip=0.01,
        wild_q=(3, 7),
        mut_rate=0.20,          # chance to move one pip, pulled to the middle
        rare_mut=0.02,          # two-pip jump
        fit_clamp=(0.85, 1.15),
        fit_exp=0.5,
        size_range=(1.0, 1.0),  # size gene range; proposal does not define it
        size_affects_torso=False,
        kin_rule=True,
        steer=0.5,              # Bond Charm would make this 0.8 for one slot
        breed_limit=(5, 5, 3, 2, 2),
        p_pure=(0.0, 0.0, 0.50, 0.60, 0.60),
        p_single=(0.0, 0.0, 0.12, 0.15, 0.15),
        fail_to=UNCOMMON,
        cooldowns=((30, 60, 120, 240, 480), (30, 60, 120, 240, 480),
                   (720, 1440, 2880), (1440, 2880), (1440, 2880)),
        hatch=(10, 30, 240, 480, 720),
        rarity_mult=(1, 1.5, 4, 10, 25),
        count_mult=(1, 1.5, 2.5, 4, 6.5),
        base_cost=1000,
        level_share=0.40,
        fertility_inherit=False,
    )
    r.update(over)
    return r


def clamp(x, lo, hi):
    return lo if x < lo else hi if x > hi else x


class Creature:
    __slots__ = ("id", "parts", "size", "rarity", "used", "cool_until", "level",
                 "parents", "gen", "colour", "owner", "fert", "radiant", "_score")

    def __init__(self, cid, parts, rarity=COMMON, level=5, parents=None, gen=0,
                 size=1.0, colour=("n", "n"), owner=None, fert=None):
        self.id = cid
        self.parts = parts          # list of [species, quality] per slot (proposal)
        self.size = size
        self.rarity = rarity
        self.used = 0
        self.cool_until = 0
        self.level = level
        self.parents = parents
        self.gen = gen
        self.colour = colour
        self.owner = owner
        self.fert = fert
        self.radiant = False
        self._score = None


class IdGen:
    def __init__(self):
        self.n = 0

    def __call__(self):
        self.n += 1
        return self.n


def fit_factor(rules, legs_sp, torso_sp, size):
    body = weight(torso_sp) * size
    f = (weight(legs_sp) / body) ** rules["fit_exp"]
    lo, hi = rules["fit_clamp"]
    return clamp(f, lo, hi)


def stats(c: Creature, rules, level_scale=1.0, rarity=True) -> dict:
    out = {s: 0.0 for s in STATS}
    base_sum = 0.0
    torso_sp = c.parts[1][0]
    for i, slot in enumerate(SLOTS):
        sp, q = c.parts[i]
        qm = 1 + (q - rules["q_mid"]) * rules["pip"]
        f = 1.0
        if slot == "legs":
            f = fit_factor(rules, sp, torso_sp, c.size)
        sm = c.size if (slot == "torso" and rules["size_affects_torso"]) else 1.0
        for k, v in species_part_stats(sp, slot).items():
            out[k] += v * qm * f * sm
            base_sum += v * f * sm
    cap = rules.get("budget_cap")
    if cap and base_sum > cap:
        # assembled bodies share one stat budget: scale down so hybrids cannot
        # simply take the best part of every species
        k = cap / base_sum
        out = {s: v * k for s, v in out.items()}
    m = level_scale * (RARITY_BOOST[c.rarity] if rarity else 1.0)
    return {k: v * m for k, v in out.items()}


def total(c, rules, rarity=False):
    return sum(stats(c, rules, rarity=rarity).values())


def score(c, rules):
    """Cached rarity-free stat total (a creature's parts never change)."""
    if c._score is None:
        c._score = total(c, rules)
    return c._score


def mutate_q(q, rules, rng):
    lo, hi, span = rules["q_min"], rules["q_max"], rules["q_max"] - rules["q_min"]
    x = rng.random()
    if rules.get("pull", True):
        up = rules["mut_rate"] * (hi - q) / span
        down = rules["mut_rate"] * (q - lo) / span
    else:
        up = rules["mut_rate"] / 2 if q < hi else 0.0
        down = rules["mut_rate"] / 2 if q > lo else 0.0
    if x < up:
        q += 1
    elif x < up + down:
        q -= 1
    if rng.random() < rules["rare_mut"]:
        # two-pip jump with the same pull toward the middle
        q += 2 if rng.random() < (hi - q) / span else -2
    return int(clamp(q, lo, hi))


def wild(cid, sp, rules, rng, rarity=COMMON, level=5, owner=None, mixed=False):
    lo, hi = rules["wild_q"]
    parts = [[sp, rng.randint(lo, hi)] for _ in SLOTS]
    s0, s1 = rules["size_range"]
    size = rng.uniform(s0, s1)
    return Creature(cid, parts, rarity=rarity, level=level, size=size, owner=owner)


def is_kin(a: Creature, b: Creature) -> bool:
    if a.id == b.id:
        return True
    if a.parents and b.id in a.parents:
        return True
    if b.parents and a.id in b.parents:
        return True
    if a.parents and b.parents and set(a.parents) == set(b.parents):
        return True
    return False


def child_rarity(a, b, rules, rng):
    """Roll the higher tier first, then each lower gem tier. Both parents at or
    above a tier use the pure odds, one parent the single odds. All fail -> fail_to."""
    hi = max(a.rarity, b.rarity)
    if hi <= UNCOMMON:
        return UNCOMMON if (a.rarity == UNCOMMON and b.rarity == UNCOMMON and rng.random() < 0.5) else COMMON
    for tier in range(hi, GEM1 - 1, -1):
        both = a.rarity >= tier and b.rarity >= tier
        one = a.rarity >= tier or b.rarity >= tier
        if not one:
            continue
        p = rules["p_pure"][tier] if both else rules["p_single"][tier]
        if rng.random() < p:
            return tier
    return rules["fail_to"]


def breed_limit(c, rules):
    if rules.get("fertility_inherit") and c.fert is not None:
        return c.fert
    return rules["breed_limit"][c.rarity]


def can_breed(c, rules, now=0):
    return c.used < breed_limit(c, rules) and c.cool_until <= now


def breed(a, b, rules, rng, cid, now=0, steer_slot=None):
    parts = []
    for i in range(len(SLOTS)):
        pa = rules["steer"] if i != steer_slot else 0.8
        src = a if rng.random() < pa else b
        sp, q = src.parts[i]
        parts.append([sp, mutate_q(q, rules, rng)])
    # size gene: average of parents with a little noise, clamped to range
    s0, s1 = rules["size_range"]
    size = clamp((a.size + b.size) / 2 + rng.uniform(-0.05, 0.05), s0, s1) if s1 > s0 else 1.0
    rar = child_rarity(a, b, rules, rng)
    lvl = max(1, int(rules["level_share"] * (a.level + b.level) / 2))
    col = (rng.choice(a.colour), rng.choice(b.colour))
    ch = Creature(cid, parts, rarity=rar, level=lvl, parents=(a.id, b.id),
                  gen=max(a.gen, b.gen) + 1, size=size, colour=col, owner=a.owner)
    if rules.get("fertility_inherit"):
        ra = breed_limit(a, rules) - a.used - 1
        rb = breed_limit(b, rules) - b.used - 1
        ch.fert = min(rules["breed_limit"][rar], max(0, min(ra, rb)))
    for p in (a, b):
        p.used += 1
        cds = rules["cooldowns"][p.rarity]
        p.cool_until = now + cds[min(p.used, len(cds)) - 1]
    return ch


def breed_cost(a, b, rules, biome_tier=1):
    cm = rules["count_mult"]
    ca = cm[min(a.used, len(cm) - 1)]
    cb = cm[min(b.used, len(cm) - 1)]
    rm = rules["rarity_mult"][max(a.rarity, b.rarity)]
    return rules["base_cost"] * biome_tier * rm * (ca + cb) / 2


def pct(xs, q):
    xs = sorted(xs)
    if not xs:
        return float("nan")
    k = (len(xs) - 1) * q
    f = math.floor(k)
    c = min(f + 1, len(xs) - 1)
    return xs[f] + (xs[c] - xs[f]) * (k - f)
