# Measures live-event cadence and reward tables in Project Pokemon's EventsGallery.
# Usage: python3 -I eventsgallery_cadence.py "<EventsGallery clone>/Released/Gen 9/SV"
# Needs only the Encounters.txt files (a sparse checkout is enough). See SCAFFOLD_STRUCTURE.md section 3.
import sys, os, re, statistics, collections, datetime as dt
root = sys.argv[1]
def load(kind, label):
    out = []
    d = os.path.join(root, kind)
    for name in sorted(os.listdir(d)):
        p = os.path.join(d, name, "Encounters.txt")
        if not os.path.isfile(p):
            continue
        txt = open(p, encoding="utf-8", errors="replace").read()
        m = re.search(label + r" Identifier:\s*(\d+)", txt)
        ident = int(m.group(1)) if m else 0
        date = None
        if ident > 20000000:
            s = str(ident)
            try: date = dt.date(int(s[:4]), int(s[4:6]), int(s[6:8]))
            except ValueError: pass
        out.append((name, date, txt))
    return out

def cadence(rows, title):
    dates = sorted({d for _, d, _ in rows if d})
    gaps = [(b - a).days for a, b in zip(dates, dates[1:])]
    print(f"\n## {title}: {len(rows)} folders, {len(dates)} distinct dated starts, {dates[0]} to {dates[-1]}")
    span = (dates[-1] - dates[0]).days
    print(f"span {span} days = {span/365.25:.1f} years; starts per month {len(dates)/(span/30.44):.2f}")
    print(f"gap days: median {statistics.median(gaps)}, mean {statistics.mean(gaps):.1f}, p10 {sorted(gaps)[len(gaps)//10]}, p90 {sorted(gaps)[len(gaps)*9//10]}, max {max(gaps)}")
    by_year = collections.Counter(d.year for d in dates)
    print("starts by year:", dict(sorted(by_year.items())))
    return dates

raids = load("Raid Events", "Event Raid")
cadence(raids, "Raid events")
kinds = collections.Counter()
for name, _, _ in raids:
    n = name.lower()
    if "unrivaled" in n or "mightiest" in n: k = "7-star 'Unrivaled' boss (catch once)"
    elif "spotlight" in n: k = "Spotlight (species rotation)"
    elif any(w in n for w in ["valentine","delibird","halloween","new year","festive","anniversary","day","holiday","summer","spring"]): k = "Seasonal/holiday"
    elif "shiny" in n: k = "Shiny"
    else: k = "Other"
    kinds[k] += 1
reruns = sum(1 for n,_,_ in raids if "round 2" in n.lower() or "rerun" in n.lower() or "round 3" in n.lower())
print("raid kinds:", dict(kinds.most_common()), "| reruns (Round 2/3):", reruns)
stars = collections.Counter(); once = 0; bosses = 0; shiny = collections.Counter(); sums = []
for _, _, t in raids:
    for m in re.finditer(r"^(\d)-Star ", t, re.M): stars[int(m.group(1))] += 1
    once += len(re.findall(r"Catchable: Only Once", t))
    bosses += len(re.findall(r"^\d-Star ", t, re.M))
    for m in re.finditer(r"Shiny: (.+)", t): shiny[m.group(1).strip()] += 1
    for block in re.split(r"\n(?=\d-Star )", t):
        b = block.split("Bonus Drops:")
        if len(b) > 1:
            ps = [int(x) for x in re.findall(r"^\s+(\d+)%", b[1], re.M)]
            if ps: sums.append(sum(ps))
print("boss entries by star:", dict(sorted(stars.items())), "| catch-once entries:", once, "of", bosses)
print("shiny settings:", dict(shiny.most_common(5)))
print("bonus-drop % totals: n", len(sums), "| ==100:", sum(1 for s in sums if s == 100), "| min", min(sums), "max", max(sums))

outs = load("Outbreak Events", "Event Outbreak")
# nested version folders for 000
cadence(outs, "Outbreak events")
oshiny = collections.Counter()
for _, _, t in outs:
    for m in re.finditer(r"Shiny: (.+)", t): oshiny[m.group(1).strip()] += 1
print("outbreak shiny settings:", dict(oshiny.most_common(6)))
themes = collections.Counter()
for n,_,_ in outs:
    l = n.lower()
    if "type" in l: themes["Element-themed"] += 1
    elif "family" in l or " and " in l: themes["One evolution family"] += 1
    elif any(w in l for w in ["festive","new year","day","halloween","moon","valentine","delibird","holiday"]): themes["Seasonal/holiday"] += 1
    else: themes["Other (rare/baby/golden/etc)"] += 1
print("outbreak themes:", dict(themes.most_common()))
