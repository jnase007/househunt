#!/bin/bash
# =============================================================================
# FSBO HUNTER — Southern California
# Searches for For Sale By Owner properties in Orange County & LA County
# Runs daily, saves results, alerts on new finds
# =============================================================================

WORKSPACE="/Users/brandastic/.openclaw/workspace/fsbo-hunter"
RESULTS="$WORKSPACE/results"
DATE=$(date +%Y-%m-%d)
OUTPUT="$RESULTS/fsbo-$DATE.json"

mkdir -p "$RESULTS"

echo "🏠 FSBO Hunter — Southern California"
echo "Date: $DATE"
echo "==========================================="

python3 << 'PYEOF'
import json, urllib.request, re, os
from datetime import datetime

results = []

# Target areas in SoCal
areas = [
    {"name": "Costa Mesa", "state": "CA", "county": "Orange"},
    {"name": "Newport Beach", "state": "CA", "county": "Orange"},
    {"name": "Irvine", "state": "CA", "county": "Orange"},
    {"name": "Huntington Beach", "state": "CA", "county": "Orange"},
    {"name": "Santa Ana", "state": "CA", "county": "Orange"},
    {"name": "Anaheim", "state": "CA", "county": "Orange"},
    {"name": "Fountain Valley", "state": "CA", "county": "Orange"},
    {"name": "Garden Grove", "state": "CA", "county": "Orange"},
    {"name": "Long Beach", "state": "CA", "county": "Los Angeles"},
    {"name": "Lakewood", "state": "CA", "county": "Los Angeles"},
]

print(f"\nSearching {len(areas)} SoCal cities for FSBO listings...\n")

# Method 1: Zillow FSBO search
for area in areas:
    city = area["name"].replace(" ", "-").lower()
    state = area["state"].lower()
    try:
        url = f"https://www.zillow.com/homes/for_sale/fsbo/{city}-{state}/"
        req = urllib.request.Request(url, headers={
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
        })
        with urllib.request.urlopen(req, timeout=10) as resp:
            html = resp.read().decode('utf-8', errors='ignore')
            
            # Count FSBO listings mentioned
            fsbo_count = html.count('FSBO') + html.count('fsbo') + html.count('For Sale By Owner')
            price_matches = re.findall(r'\$[\d,]+', html)
            
            if fsbo_count > 0 or len(price_matches) > 0:
                results.append({
                    "city": area["name"],
                    "county": area["county"],
                    "source": "Zillow",
                    "fsbo_mentions": fsbo_count,
                    "prices_found": len(price_matches),
                    "sample_prices": price_matches[:5],
                    "url": url,
                    "checked": datetime.now().isoformat(),
                })
                print(f"  ✅ {area['name']}: {fsbo_count} FSBO mentions, {len(price_matches)} prices")
            else:
                print(f"  ⚪ {area['name']}: No FSBO listings found")
    except Exception as e:
        print(f"  ❌ {area['name']}: {str(e)[:50]}")

# Method 2: ForSaleByOwner.com
print("\n--- ForSaleByOwner.com ---")
for area in areas[:5]:  # Top 5 cities
    city = area["name"].replace(" ", "-").lower()
    try:
        url = f"https://www.forsalebyowner.com/search/ca/{city}"
        req = urllib.request.Request(url, headers={
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
        })
        with urllib.request.urlopen(req, timeout=10) as resp:
            html = resp.read().decode('utf-8', errors='ignore')
            listing_count = html.count('listing-card') + html.count('property-card')
            price_matches = re.findall(r'\$[\d,]+', html)
            
            if listing_count > 0 or len(price_matches) > 5:
                results.append({
                    "city": area["name"],
                    "county": area["county"],
                    "source": "ForSaleByOwner.com",
                    "listings_found": listing_count,
                    "prices_found": len(price_matches),
                    "sample_prices": price_matches[:5],
                    "url": url,
                    "checked": datetime.now().isoformat(),
                })
                print(f"  ✅ {area['name']}: {listing_count} listings, {len(price_matches)} prices")
            else:
                print(f"  ⚪ {area['name']}: No listings")
    except Exception as e:
        print(f"  ❌ {area['name']}: {str(e)[:50]}")

# Method 3: Craigslist FSBO
print("\n--- Craigslist ---")
try:
    url = "https://orangecounty.craigslist.org/search/rea?query=fsbo"
    req = urllib.request.Request(url, headers={
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
    })
    with urllib.request.urlopen(req, timeout=10) as resp:
        html = resp.read().decode('utf-8', errors='ignore')
        listing_count = html.count('result-row') + html.count('cl-search-result')
        price_matches = re.findall(r'\$[\d,]+', html)
        print(f"  ✅ OC Craigslist: {listing_count} results, {len(price_matches)} prices")
        results.append({
            "city": "Orange County",
            "county": "Orange",
            "source": "Craigslist",
            "listings_found": listing_count,
            "prices_found": len(price_matches),
            "sample_prices": price_matches[:10],
            "url": url,
            "checked": datetime.now().isoformat(),
        })
except Exception as e:
    print(f"  ❌ Craigslist: {str(e)[:50]}")

# Save results
output = {
    "date": datetime.now().strftime("%Y-%m-%d"),
    "areas_searched": len(areas),
    "total_results": len(results),
    "results": results,
}

output_path = os.environ.get('OUTPUT', '/Users/brandastic/.openclaw/workspace/fsbo-hunter/results/fsbo-latest.json')
with open(output_path, 'w') as f:
    json.dump(output, f, indent=2)

print(f"\n{'='*50}")
print(f"Total: {len(results)} sources with FSBO activity")
print(f"Results saved to {output_path}")

PYEOF
