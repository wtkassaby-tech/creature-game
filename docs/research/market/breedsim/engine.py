"""Time-based player model: sessions, pens, cooldowns, hatch timers, coins,
wild catches, storage caps, release and sinks. Used by sims 1, 3 and 5."""
from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from common import (COMMON, UNCOMMON, GEM1, RUBY, DIAMOND, N_SPECIES, ROSTER, Creature,
                    breed, breed_cost, can_breed, is_kin, total, wild, SLOTS)

DAY = 1440
CHECK = 5  # minutes between player checks while online

# Activity profiles: (share of players, sessions [(start minute, length)], breed budget share)
PROFILES = {
    "casual":   dict(sessions=[(18 * 60, 20)], share=0.5),
    "regular":  dict(sessions=[(7 * 60 + 30, 30), (19 * 60, 30)], share=0.5),
    "hardcore": dict(sessions=[(8 * 60, 60), (13 * 60, 60), (20 * 60, 60)], share=0.6),
}

# Assumptions about the world (stated in the report)
WORLD = dict(
    income_per_min=100,           # coins per minute of play, x biome tier
    biome_hours=(0.0, 3.0, 6.9),  # play hours to reach biome 1, 2, 3 (x1.3 per biome)
    breed_unlock_h=1.0,           # breeder unlocked in Greenwood's town after ~1 h
    catches_per_h=3.0,            # lasso catches per hour of play
    gem_rate_per_h=(0.0, 0.0, 0.05, 0.0, 0.0),  # wild gem catches per hour of play, by tier (1 in 60 catches)
    gem_min_biome=(9, 9, 2, 6, 10),
    storage=60,
    pens_free=2,                  # 1 free + 1 from a quest
    pens_spender=4,
    spender_share=0.15,
)


def biome_species(b):
    return [i for i, r in enumerate(ROSTER) if r[1] <= b]


class Player:
    def __init__(self, pid, profile, rules, rng, ids, world=WORLD, spender=False,
                 join_day=0, quit_day=10**9, policy="supply"):
        self.pid = pid
        self.profile = profile
        self.prof = PROFILES[profile]
        self.rules = rules
        self.rng = rng
        self.ids = ids
        self.world = world
        self.pens = world["pens_spender"] if spender else world["pens_free"]
        self.storage = world["storage"] * (2 if spender else 1)
        self.join_day = join_day
        self.quit_day = quit_day
        self.policy = policy
        self.coins = 0.0
        self.play_min = 0.0
        self.pool: list[Creature] = []
        self.eggs: list[tuple[float, Creature]] = []
        self.log = dict(breeds=0, gem_breeds=0, coins_spent=0.0, wild=0, wild_gem=[0] * 5,
                        bred_gem=[0] * 5, released=0, released_gem=[0] * 5, sunk_gem=[0] * 5,
                        first_breed_day=None, first_gem_day=None)
        self.best_wild_total = 0.0
        self.history = []  # (day, best_total, best_mean_q, n_gem, breeds)

    # -- helpers -----------------------------------------------------------
    def biome(self):
        h = self.play_min / 60
        b = 1
        for i, need in enumerate(self.world["biome_hours"]):
            if h >= need:
                b = i + 1
        return b

    def score(self, c):
        if c._score is None:
            c._score = total(c, self.rules)
        return c._score

    def active(self, day):
        return self.join_day <= day < self.quit_day

    def add(self, c):
        c.owner = self.pid
        self.pool.append(c)

    def catch_wild(self, now, rarity=COMMON):
        b = self.biome()
        sp = self.rng.choice(biome_species(b))
        c = wild(self.ids(), sp, self.rules, self.rng, rarity=rarity, owner=self.pid)
        self.add(c)
        self.log["wild"] += 1
        if rarity >= GEM1:
            self.log["wild_gem"][rarity] += 1
            if self.log["first_gem_day"] is None:
                self.log["first_gem_day"] = now / DAY
        if rarity == COMMON:
            self.best_wild_total = max(self.best_wild_total, self.score(c))

    # -- breeding choice ---------------------------------------------------
    def pick_pair(self, now):
        avail = [c for c in self.pool if can_breed(c, self.rules, now)]
        if len(avail) < 2:
            return None
        # 1. gem-tier pure pairs, highest tier first
        for tier in (DIAMOND, RUBY, GEM1):
            g = [c for c in avail if c.rarity == tier]
            g.sort(key=self.score, reverse=True)
            for i in range(len(g)):
                for j in range(i + 1, len(g)):
                    if not (self.rules["kin_rule"] and is_kin(g[i], g[j])):
                        return g[i], g[j]
        # 2. a lone gem creature with the best common partner
        gems = [c for c in avail if c.rarity >= GEM1]
        commons = sorted([c for c in avail if c.rarity < GEM1], key=self.score, reverse=True)
        if gems and self.policy in ("supply",):
            gem = max(gems, key=lambda c: (c.rarity, self.score(c)))
            # only if no other gem of any tier exists that it could pair with later today
            for c in commons[:12]:
                if not (self.rules["kin_rule"] and is_kin(gem, c)):
                    return gem, c
        # 3. best common pair
        top = commons[:12]
        best, bs = None, -1.0
        for i in range(len(top)):
            for j in range(i + 1, len(top)):
                a, b = top[i], top[j]
                if self.rules["kin_rule"] and is_kin(a, b):
                    continue
                s = self.score(a) + self.score(b)
                if s > bs:
                    best, bs = (a, b), s
        return best

    def try_breed(self, now):
        if self.play_min / 60 < self.world["breed_unlock_h"]:
            return
        while len(self.eggs) < self.pens:
            pair = self.pick_pair(now)
            if pair is None:
                return
            a, b = pair
            cost = breed_cost(a, b, self.rules, self.biome())
            if cost > self.coins:
                return
            self.coins -= cost
            self.log["coins_spent"] += cost
            ch = breed(a, b, self.rules, self.rng, self.ids(), now)
            hatch = self.rules["hatch"][ch.rarity]
            self.eggs.append((now + hatch, ch))
            self.log["breeds"] += 1
            if max(a.rarity, b.rarity) >= GEM1:
                self.log["gem_breeds"] += 1
            if self.log["first_breed_day"] is None:
                self.log["first_breed_day"] = now / DAY

    def collect(self, now):
        keep = []
        for t, ch in self.eggs:
            if t <= now:
                self.add(ch)
                if ch.rarity >= GEM1:
                    self.log["bred_gem"][ch.rarity] += 1
                    if self.log["first_gem_day"] is None:
                        self.log["first_gem_day"] = now / DAY
            else:
                keep.append((t, ch))
        self.eggs = keep

    def enforce_storage(self):
        if len(self.pool) <= self.storage:
            return
        # release the least valuable: commons with no breeds left first, then lowest score
        def val(c):
            fertile = c.used < self.rules["breed_limit"][c.rarity]
            return (c.rarity >= GEM1, fertile, c.rarity, self.score(c))
        self.pool.sort(key=val)
        n = len(self.pool) - self.storage
        for c in self.pool[:n]:
            self.log["released"] += 1
            if c.rarity >= GEM1:
                self.log["released_gem"][c.rarity] += 1
        self.pool = self.pool[n:]

    def daily_sink(self, rate):
        """Spent gem creatures outside the top-3 team are fused/imprinted/released at `rate`/day."""
        if rate <= 0:
            return
        team = set(id(c) for c in sorted(self.pool, key=self.score, reverse=True)[:3])
        keep = []
        for c in self.pool:
            if (c.rarity >= GEM1 and id(c) not in team
                    and c.used >= self.rules["breed_limit"][c.rarity]
                    and self.rng.random() < rate):
                self.log["sunk_gem"][c.rarity] += 1
                continue
            keep.append(c)
        self.pool = keep

    # -- one day -----------------------------------------------------------
    def run_day(self, day):
        if not self.active(day):
            return
        if day == self.join_day:
            for _ in range(2):  # starter + first catch
                self.catch_wild(day * DAY)
            self.coins += 500
        w = self.world
        for start, length in self.prof["sessions"]:
            t = day * DAY + start
            end = t + length
            while t < end:
                self.play_min += CHECK
                tier = self.biome()
                self.coins += w["income_per_min"] * tier * CHECK * self.prof["share"]
                if self.rng.random() < w["catches_per_h"] * CHECK / 60:
                    self.catch_wild(t)
                for r in (GEM1, RUBY, DIAMOND):
                    if tier >= w["gem_min_biome"][r] and self.rng.random() < w["gem_rate_per_h"][r] * CHECK / 60:
                        self.catch_wild(t, rarity=r)
                self.collect(t)
                self.try_breed(t)
                t += CHECK
            self.enforce_storage()
        # eggs that hatch overnight are collected at the next session

    def snapshot(self, day):
        if not self.pool:
            return
        best = max(self.pool, key=self.score)
        mq = sum(q for _, q in best.parts) / len(best.parts)
        ngem = [sum(1 for c in self.pool if c.rarity == r) for r in range(5)]
        self.history.append((day, self.score(best), mq, ngem, self.log["breeds"],
                             len({sp for sp, _ in best.parts})))
