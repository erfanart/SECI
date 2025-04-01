#!/bin/bash

# Output file
IRAN_IPS_FILE="iranian_ips.txt"

# User-Agent header to mimic a browser
USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.3.1 Safari/605.1.15"

# Official sources
SOURCES=(
    "https://ftp.apnic.net/stats/apnic/delegated-apnic-latest"
    "https://ftp.ripe.net/ripe/stats/delegated-ripencc-latest"
    "https://ftp.arin.net/pub/stats/arin/delegated-arin-extended-latest"
    "https://ftp.lacnic.net/pub/stats/lacnic/delegated-lacnic-latest"
    "https://ftp.afrinic.net/pub/stats/afrinic/delegated-afrinic-latest"
    "https://www.cidr-report.org/as2.0/country/IR.html"
    "https://bgp.he.net/country/IR"
    "https://stat.ripe.net/data/country-resource-list/data.json?resource=IR"
)

# Temporary files
TMP_FILE=$(mktemp)
ASN_LIST=$(mktemp)

echo "[+] Fetching ALL Iranian IP ranges with proper User-Agent headers..."

# ========================
# 1. Download from all sources with User-Agent
# ========================
for url in "${SOURCES[@]}"; do
    echo "  -> Downloading from ${url}..."
    if curl -sSf -A "$USER_AGENT" "$url" >> "$TMP_FILE"; then
        echo "     ✓ Success"
    else
        echo "     ✗ Failed (skipping)" >&2
    fi
done

# ========================
# 2. Extract Iranian ASNs
# ========================
echo "[+] Identifying Iranian ASNs..."
grep -E '\|IR\|asn\|' "$TMP_FILE" | awk -F'|' '{print $4}' | sort -u > "$ASN_LIST"

# ========================
# 3. Get IP ranges for each ASN with User-Agent
# ========================
echo "[+] Fetching IP ranges for Iranian ASNs with browser headers..."
while read -r asn; do
    echo "  -> Processing AS${asn}..."
    
    # BGP.he.net with User-Agent
    curl -sSf -A "$USER_AGENT" "https://bgp.he.net/AS${asn}#_prefixes" | \
        grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}' >> "$TMP_FILE"
    
    # RIPE Stat API (keeps User-Agent for consistency)
    curl -sSf -A "$USER_AGENT" \
        "https://stat.ripe.net/data/announced-prefixes/data.json?resource=AS${asn}" | \
        jq -r '.data.prefixes[].prefix' >> "$TMP_FILE"
done < "$ASN_LIST"

# ========================
# 4. Process all data
# ========================
echo "[+] Processing all Iranian IP blocks..."

# Extract from RIR data
grep -E '\|IR\|ipv4\|' "$TMP_FILE" | awk -F'|' '{
    ip=$4;
    count=$5;
    prefix=32;
    while (count > 1) { prefix--; count/=2; }
    print ip "/" prefix;
}' > "$IRAN_IPS_FILE"

# Add CIDR blocks from other sources
grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}' "$TMP_FILE" >> "$IRAN_IPS_FILE"

# ========================
# 5. Final processing
# ========================
# Remove private IPs
echo "[+] Filtering out private IPs..."
grep -Ev '^(10\.|172\.(1[6-9]|2[0-9]|3[0-1])\.|192\.168\.)' "$IRAN_IPS_FILE" > "${IRAN_IPS_FILE}.tmp"

# Remove duplicates and sort
echo "[+] Deduplicating and sorting..."
sort -u "${IRAN_IPS_FILE}.tmp" -o "$IRAN_IPS_FILE"
rm -f "${IRAN_IPS_FILE}.tmp"

# ========================
# 6. Validation
# ========================
if [ ! -s "$IRAN_IPS_FILE" ]; then
    echo "[-] Error: No Iranian IPs found!" >&2
    exit 1
fi

# Count total IPs covered
echo "[+] Calculating total IP coverage..."
TOTAL_IPS=$(awk -F/ '{print $2}' "$IRAN_IPS_FILE" | \
    awk '{sum += 2^(32-$1)} END {print sum}')

echo "========================================"
echo "[+] FINAL RESULTS:"
echo "    - Output file: $IRAN_IPS_FILE"
echo "    - Total subnets: $(wc -l < "$IRAN_IPS_FILE")"
echo "    - Approx. total IPs: $(printf "%'d" "$TOTAL_IPS")"
echo "========================================"

# Cleanup
rm -f "$TMP_FILE" "$ASN_LIST"