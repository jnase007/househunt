#!/usr/bin/env python3
"""
FSBO Lead Scorer — scores listings based on investment criteria
Usage: python3 score-leads.py results/fsbo-2026-05-30.json
"""

import json, sys

def score_lead(listing):
    score = 0
    reasons = []
    
    # Parse price
    price_str = listing.get("price", "$0").replace("$", "").replace(",", "")
    try:
        price = float(price_str)
    except:
        price = 0
    
    # Under $800K?
    if 0 < price < 800000:
        score += 2
        reasons.append("Under $800K")
    
    # Under $500K? (wholesale territory)
    if 0 < price < 500000:
        score += 2
        reasons.append("Under $500K — wholesale potential")
    
    # Under $300K? (strong wholesale)
    if 0 < price < 300000:
        score += 1
        reasons.append("Under $300K — high wholesale potential")
    
    # Good size? (3+ beds)
    beds = listing.get("beds", 0)
    if beds >= 3:
        score += 1
        reasons.append(f"{beds} bedrooms")
    
    # In target area?
    address = listing.get("address", "").lower()
    target_cities = ["costa mesa", "santa ana", "anaheim", "garden grove", 
                     "stanton", "fountain valley", "huntington beach", "irvine",
                     "long beach", "placentia", "orange"]
    for city in target_cities:
        if city in address:
            score += 2
            reasons.append(f"Target area: {city.title()}")
            break
    
    # Price per sqft value?
    sqft = listing.get("sqft", 0)
    if sqft > 0 and price > 0:
        ppsf = price / sqft
        if ppsf < 400:
            score += 1
            reasons.append(f"${ppsf:.0f}/sqft — below area avg")
    
    # Notes / motivated signals
    notes = listing.get("notes", "").lower()
    motivated_words = ["must sell", "motivated", "price reduced", "below market", 
                       "fixer", "as-is", "estate", "relocating", "divorce"]
    for word in motivated_words:
        if word in notes or word in address:
            score += 1
            reasons.append(f"Motivated signal: {word}")
    
    return {
        **listing,
        "score": score,
        "rating": "🔥 HOT" if score >= 7 else "🟡 WARM" if score >= 4 else "⚪ COLD",
        "reasons": reasons,
    }

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 score-leads.py <results-file.json>")
        sys.exit(1)
    
    with open(sys.argv[1]) as f:
        data = json.load(f)
    
    scored = [score_lead(l) for l in data["listings"]]
    scored.sort(key=lambda x: -x["score"])
    
    print(f"\n🏠 FSBO LEAD SCORES — {data['date']}")
    print(f"{'='*70}")
    
    for l in scored:
        print(f"\n{l['rating']} Score: {l['score']}/10")
        print(f"   {l['price']} | {l.get('beds',0)}bd/{l.get('baths',0)}ba | {l.get('sqft',0)}sf")
        print(f"   {l['address']}")
        if l['reasons']:
            print(f"   Reasons: {', '.join(l['reasons'])}")
    
    # Save scored results
    output = {**data, "listings": scored}
    outpath = sys.argv[1].replace(".json", "-scored.json")
    with open(outpath, "w") as f:
        json.dump(output, f, indent=2)
    print(f"\n✅ Scored results saved to {outpath}")
