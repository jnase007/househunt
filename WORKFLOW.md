# FSBO Hunter — SoCal Workflow

## Daily Pipeline: Trigger → Collect → Decide → Act → Observe

### 1. TRIGGER (Daily 7:00 AM via Heartbeat)
- Check Zillow FSBO via Chrome scrape (OC + LA)
- Check Craigslist OC/LA for FSBO keywords
- Compare against previous day's listings for NEW entries

### 2. COLLECT (Data Enrichment)
- Address, price, beds/baths/sqft
- Days on market
- Seller contact info (when available)
- Price changes / drops

### 3. DECIDE (Lead Scoring)
Score each lead 1-10 based on:
- Under $800K? (+2)
- Price drop in last 30 days? (+2)
- 30+ days on market? (+2)
- In target area (Costa Mesa, Santa Ana, Irvine, HB, Anaheim)? (+2)
- Equity > 40% estimated? (+2)
- Motivated seller language? (+1)

Hot lead = 7+
Warm lead = 4-6
Cold lead = 0-3

### 4. ACT (Alerts)
- Hot leads: Immediate Telegram alert to Justin
- Warm leads: Daily summary
- Cold leads: Log only, review weekly

### 5. OBSERVE (Weekly Review)
- JSON logs of every run
- New vs removed listings
- Price drop tracking
- Lead conversion tracking

## Target Criteria
- **Geography:** Orange County primary, LA County secondary
- **Price:** Under $800K for investment, under $500K for wholesale potential
- **Property type:** SFR preferred, condos OK
- **Signals:** Price drops, 30+ DOM, motivated seller language, FSBO
- **Focus areas:** Costa Mesa, Santa Ana, Anaheim, Garden Grove, Stanton, Fountain Valley, Long Beach

## Current Data Sources
- ✅ Zillow FSBO (via Chrome scrape — works but manual)
- ✅ Craigslist OC/LA
- ⏳ PropStream ($99/mo — recommended for serious hunting)
- ⏳ BatchLeads ($79/mo — skip tracing + data)
- ⏳ ATTOM API (property data)

## Setup Notes
- Running on Mac Mini 24/7
- Results saved to fsbo-hunter/results/
- All data LOCAL only
