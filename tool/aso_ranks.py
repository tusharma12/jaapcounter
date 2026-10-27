"""Tracks where JaapMitra ranks in App Store search, week by week.

For every search below it records our position (top 200, blank when absent),
the #1 app, and the median rating count of the top 5 (how hard the search is
to win). Rows are appended to marketing/aso/ranks.csv so a change of keywords,
screenshots or ratings can be judged by what moved, not by feel.

Only Apple's public search API; no key needed.
  python3 tool/aso_ranks.py            # India and the US
  python3 tool/aso_ranks.py in         # one country
"""
import csv
import datetime
import json
import os
import statistics
import sys
import time
import urllib.parse
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CSV = f'{ROOT}/marketing/aso/ranks.csv'
APP_ID = 6816732989
# Real searches, taken from the App Store's own suggestions for India.
TERMS = [
    'naam jaap counter', 'naam jaap counter free', 'naam jaap', 'naam japa',
    'naamjap counter', 'naam counter', 'jaap counter', 'jaap count',
    'mala jaap counter', 'mala counter', 'mala counting', 'japa counter',
    'japa counter free', 'japa mala counter', 'mantra counter',
    'mantra jaap counter', 'mantra jaap', 'mantra count', 'mantra chanting',
    'counter for mantra', 'chanting counter', 'chanting count', '108 counter',
    '108 jaap', '108 mala', '108 chanting', 'digital japa counter',
    'digital mala', 'radha naam jaap counter', 'radha naam jaap',
    'radha radha counter', 'radha counter', 'radha name counter',
    'radhe radhe counter', 'radhe counter', 'ram naam jaap', 'ram naam counter',
    'ram ram jaap', 'om namah shivaya counter', 'hare krishna mantra counter',
    'hare krishna counter', 'simran counter', 'waheguru simran',
    'bhajan counter', 'sumiran', 'bead counter', 'radha jaap counter',
    'radha naam counter', 'chant counter', 'mantra tracker', 'prayer counter',
    'japa mala', 'japa 108', 'hare krishna japa', 'satnam waheguru',
    'sadhana app',
]
FIELDS = ['date', 'country', 'term', 'rank', 'top1', 'top5_median_ratings']


def search(term, country):
    query = urllib.parse.urlencode({
        'term': term, 'country': country, 'entity': 'software', 'limit': 200,
    })
    for attempt in range(3):
        try:
            with urllib.request.urlopen(
                    f'https://itunes.apple.com/search?{query}', timeout=30) as r:
                return json.load(r)['results']
        except Exception:  # Apple rate-limits now and then; wait and retry.
            time.sleep(5 * (attempt + 1))
    return None


def last_ranks():
    if not os.path.exists(CSV):
        return {}
    with open(CSV) as f:
        rows = list(csv.DictReader(f))
    latest = {}
    for row in rows:
        latest[(row['country'], row['term'])] = row['rank']
    return latest


def main():
    countries = sys.argv[1:] or ['in', 'us']
    today = datetime.date.today().isoformat()
    before = last_ranks()
    rows = []
    for country in countries:
        print(f'\n{country.upper()}  {"rank":>5} {"was":>5}  search')
        for term in TERMS:
            results = search(term, country)
            if results is None:
                print(f'  could not search "{term}"')
                continue
            rank = next((i + 1 for i, a in enumerate(results)
                         if a['trackId'] == APP_ID), '')
            top5 = [a.get('userRatingCount', 0) for a in results[:5]]
            rows.append({
                'date': today,
                'country': country,
                'term': term,
                'rank': rank,
                'top1': results[0]['trackName'] if results else '',
                'top5_median_ratings': int(statistics.median(top5)) if top5 else '',
            })
            was = before.get((country, term), '')
            print(f'  {str(rank or "-"):>5} {was or "-":>5}  {term}')
            time.sleep(0.5)
    os.makedirs(os.path.dirname(CSV), exist_ok=True)
    new_file = not os.path.exists(CSV)
    with open(CSV, 'a', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=FIELDS)
        if new_file:
            writer.writeheader()
        writer.writerows(rows)
    ranked = sum(1 for r in rows if r['rank'] and r['rank'] <= 10)
    print(f'\nTop 10 for {ranked} of {len(rows)} searches. Saved to {CSV}')


if __name__ == '__main__':
    main()
