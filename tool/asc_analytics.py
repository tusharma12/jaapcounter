"""Pulls JaapMitra's App Store analytics through the App Store Connect API.

Answers the ASO question "is the problem being seen, or being chosen?":
impressions, product page views and downloads per day, by how people found
the app (search, browse, web) and by country.

Apple builds these reports only after an "ongoing" report request exists. The
first run creates it (needs an Admin key); Apple then takes a day or two to
produce the first files, and keeps producing them daily from then on.

Uses the same key as fastlane, with no extra packages (openssl signs the token):
  ASC_KEY_ID=... ASC_ISSUER_ID=... ASC_KEY_PATH=... python3 tool/asc_analytics.py [days]

Raw reports land in build/asc_analytics/ (not committed).
"""
import base64
import csv
import gzip
import io
import json
import os
import subprocess
import sys
import time
import urllib.error
import urllib.request
from collections import defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = f'{ROOT}/build/asc_analytics'
API = 'https://api.appstoreconnect.apple.com/v1'
APP_ID = '6816732989'
# The reports that say how the listing performs; Apple has many more.
REPORTS = [
    'App Store Discovery and Engagement Standard',
    'App Downloads Standard',
]


def _b64(data):
    return base64.urlsafe_b64encode(data).rstrip(b'=').decode()


def _der_to_raw(der):
    """openssl signs ECDSA as DER; a JWT wants the bare 32-byte r and s."""
    def read_int(at):
        assert der[at] == 0x02
        size = der[at + 1]
        value = der[at + 2:at + 2 + size]
        return value[-32:].rjust(32, b'\0'), at + 2 + size
    at = 3 if der[1] & 0x80 else 2  # skip the sequence header
    r, at = read_int(at)
    s, _ = read_int(at)
    return r + s


def token():
    key_id = os.environ['ASC_KEY_ID']
    header = {'alg': 'ES256', 'kid': key_id, 'typ': 'JWT'}
    now = int(time.time())
    claims = {
        'iss': os.environ['ASC_ISSUER_ID'],
        'iat': now,
        'exp': now + 15 * 60,
        'aud': 'appstoreconnect-v1',
    }
    signing_input = (
        f'{_b64(json.dumps(header).encode())}.'
        f'{_b64(json.dumps(claims).encode())}'
    )
    der = subprocess.run(
        ['openssl', 'dgst', '-sha256', '-sign',
         os.path.expanduser(os.environ['ASC_KEY_PATH'])],
        input=signing_input.encode(), capture_output=True, check=True,
    ).stdout
    return f'{signing_input}.{_b64(_der_to_raw(der))}'


_TOKEN = None


def call(path_or_url, body=None):
    global _TOKEN
    _TOKEN = _TOKEN or token()
    url = path_or_url if path_or_url.startswith('http') else API + path_or_url
    request = urllib.request.Request(
        url,
        data=json.dumps(body).encode() if body else None,
        headers={'Authorization': f'Bearer {_TOKEN}',
                 'Content-Type': 'application/json'},
        method='POST' if body else 'GET',
    )
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            return json.load(response)
    except urllib.error.HTTPError as error:
        detail = error.read().decode(errors='replace')
        sys.exit(f'{error.code} on {url}\n{detail}')


def all_pages(path):
    page = call(path)
    yield from page['data']
    while page.get('links', {}).get('next'):
        page = call(page['links']['next'])
        yield from page['data']


def ongoing_request():
    requests = list(all_pages(f'/apps/{APP_ID}/analyticsReportRequests'))
    for r in requests:
        if (r['attributes']['accessType'] == 'ONGOING'
                and not r['attributes'].get('stoppedDueToInactivity')):
            return r['id'], False
    created = call('/analyticsReportRequests', {
        'data': {
            'type': 'analyticsReportRequests',
            'attributes': {'accessType': 'ONGOING'},
            'relationships': {
                'app': {'data': {'type': 'apps', 'id': APP_ID}},
            },
        },
    })
    return created['data']['id'], True


def download(report_id, name, days):
    """Fetches the newest daily files of one report; returns their rows."""
    instances = list(all_pages(
        f'/analyticsReports/{report_id}/instances?filter[granularity]=DAILY'))
    instances.sort(key=lambda i: i['attributes']['processingDate'])
    rows = []
    folder = f'{OUT}/{name}'
    os.makedirs(folder, exist_ok=True)
    for instance in instances[-days:]:
        date = instance['attributes']['processingDate']
        for segment in all_pages(f'/analyticsReportInstances/{instance["id"]}/segments'):
            raw = urllib.request.urlopen(segment['attributes']['url'], timeout=120).read()
            text = gzip.decompress(raw).decode()
            with open(f'{folder}/{date}-{segment["id"]}.tsv', 'w') as f:
                f.write(text)
            rows += list(csv.DictReader(io.StringIO(text), delimiter='\t'))
    return rows


def summarise(name, rows, by):
    """Totals Counts per date and per value of one or two columns."""
    if not rows:
        print(f'\n{name}: no rows yet')
        return
    columns = list(rows[0])
    print(f'\n{name}  ({len(rows)} rows; columns: {", ".join(columns)})')
    for column in by:
        if column not in columns:
            continue
        totals = defaultdict(int)
        for row in rows:
            totals[row[column]] += int(float(row.get('Counts') or 0))
        print(f'  by {column}:')
        for value, count in sorted(totals.items(), key=lambda kv: -kv[1])[:12]:
            print(f'    {count:>8}  {value}')


def main():
    days = int(sys.argv[1]) if len(sys.argv) > 1 else 28
    request_id, created = ongoing_request()
    if created:
        print('Created an ongoing analytics report request. Apple needs a day '
              'or two to produce the first reports; run this again then.')
        return
    reports = {
        r['attributes']['name']: r['id']
        for r in all_pages(f'/analyticsReportRequests/{request_id}/reports')
    }
    for name in REPORTS:
        if name not in reports:
            print(f'\n{name}: not available yet')
            continue
        rows = download(reports[name], name, days)
        summarise(name, rows, ['Date', 'Event', 'Source Type', 'Territory',
                               'Download Type', 'Page Type'])


if __name__ == '__main__':
    main()
