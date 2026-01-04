#!/usr/bin/env bash
#
# baseline_capture.sh (PUBLIC VERSION)
# Full nginx reconnaissance with HTTP/HTTPS dual-protocol validation
# Phase 2.3 - Evidence-Based Purple Team Testing
#
# WORKFLOW:
# 1. curl scans (no sudo, no proxy) - HTTP + HTTPS
# 2. nikto scans - HTTP + HTTPS
# 3. nmap scans (sudo required) - Service detection + TLS

set -e

# =========================
# LOAD CONFIGURATION
# =========================
if [[ ! -f "$HOME/.dojo_config.sh" ]]; then
    echo "❌ ERROR: Configuration not found: ~/.dojo_config.sh"
    echo "   Run: ./setup_dojo.sh to generate configuration"
    exit 1
fi

source "$HOME/.dojo_config.sh"

# =========================
# COMMAND LINE ARGS
# =========================
PREFIX="${1:-baseline}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SESSION_DIR="$PWD"

HTTP_PORT="${DOJO_HTTP_PORT:-80}"
HTTPS_PORT="${DOJO_HTTPS_PORT:-443}"

# Evidence tracking
SCAN_COUNT=0
TOTAL_SCANS=16
EVIDENCE_FILES=0

# =========================
# HEADER
# =========================
echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   BASELINE CAPTURE – PHASE 2.3        ║${NC}"
echo -e "${BLUE}║   Evidence-Based Purple Team          ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Target:${NC}    ${DOJO_TARGET_USER}@${DOJO_TARGET_HOST}"
echo -e "${GREEN}Session:${NC}   ${SESSION_DIR}"
echo -e "${GREEN}Timestamp:${NC} ${TIMESTAMP}"
echo ""
echo -e "${YELLOW}[*] Initializing 16-scan reconnaissance...${NC}"
echo ""

# =========================
# DIRECTORY SETUP
# =========================
echo -e "${BLUE}[*] Creating evidence directories...${NC}"
mkdir -p "$DOJO_BASELINES/nginx"
mkdir -p "$DOJO_CAPTURES/curl"
mkdir -p "$DOJO_CAPTURES/tls"
mkdir -p "$DOJO_CAPTURES/nmap"
echo -e "${GREEN}  ✓ Baselines: $DOJO_BASELINES/nginx${NC}"
echo -e "${GREEN}  ✓ Captures:  $DOJO_CAPTURES/{curl,tls,nmap}${NC}"
echo ""

# =========================
# PART 1 — HTTP (PORT 80)
# =========================
echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   PART 1: HTTP EVIDENCE (PORT 80)     ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
echo ""

# 1. Banner grab
((SCAN_COUNT++))
echo -e "${YELLOW}[${SCAN_COUNT}/${TOTAL_SCANS}] HTTP banner grab${NC}"
echo -e "HEAD / HTTP/1.0\r\n\r\n" \
 | nc "$DOJO_TARGET_HOST" "$HTTP_PORT" \
 > "${PREFIX}_banner.txt" 2>&1 || true
cp "${PREFIX}_banner.txt" \
   "$DOJO_BASELINES/nginx/${PREFIX}_banner_${TIMESTAMP}.txt"
echo -e "${GREEN}  ✓ Working: ${PREFIX}_banner.txt${NC}"
echo -e "${GREEN}  ✓ Archived: $DOJO_BASELINES/nginx/${PREFIX}_banner_${TIMESTAMP}.txt${NC}"
((EVIDENCE_FILES+=2))
echo ""

# 2. HTTP headers
((SCAN_COUNT++))
echo -e "${YELLOW}[${SCAN_COUNT}/${TOTAL_SCANS}] HTTP headers (curl)${NC}"
curl $DOJO_CURL_OPTS -I \
 "http://${DOJO_TARGET_HOST}:${HTTP_PORT}" \
 > "${PREFIX}_headers.txt" 2>&1
cp "${PREFIX}_headers.txt" \
   "$DOJO_BASELINES/nginx/${PREFIX}_headers_${TIMESTAMP}.txt"
cp "${PREFIX}_headers.txt" \
   "$DOJO_CAPTURES/curl/${PREFIX}_http_headers_${TIMESTAMP}.txt"
echo -e "${GREEN}  ✓ Working: ${PREFIX}_headers.txt${NC}"
echo -e "${GREEN}  ✓ Archived: $DOJO_BASELINES/nginx/${PREFIX}_headers_${TIMESTAMP}.txt${NC}"
echo -e "${GREEN}  ✓ Captured: $DOJO_CAPTURES/curl/${PREFIX}_http_headers_${TIMESTAMP}.txt${NC}"
((EVIDENCE_FILES+=3))
echo ""

# 3. HTTP full response
((SCAN_COUNT++))
echo -e "${YELLOW}[${SCAN_COUNT}/${TOTAL_SCANS}] HTTP full response (with HTML)${NC}"
curl $DOJO_CURL_OPTS -v \
 "http://${DOJO_TARGET_HOST}:${HTTP_PORT}" \
 > "${PREFIX}_full_response.txt" 2>&1
cp "${PREFIX}_full_response.txt" \
   "$DOJO_BASELINES/nginx/${PREFIX}_full_response_${TIMESTAMP}.txt"
echo -e "${GREEN}  ✓ Working: ${PREFIX}_full_response.txt${NC}"
echo -e "${GREEN}  ✓ Archived: $DOJO_BASELINES/nginx/${PREFIX}_full_response_${TIMESTAMP}.txt${NC}"
((EVIDENCE_FILES+=2))
echo ""

# 4. 404 error page test
((SCAN_COUNT++))
echo -e "${YELLOW}[${SCAN_COUNT}/${TOTAL_SCANS}] HTTP 404 error page${NC}"
curl $DOJO_CURL_OPTS \
 "http://${DOJO_TARGET_HOST}:${HTTP_PORT}/doesnotexist" \
 > "${PREFIX}_error_page.txt" 2>&1
cp "${PREFIX}_error_page.txt" \
   "$DOJO_BASELINES/nginx/${PREFIX}_error_page_${TIMESTAMP}.txt"
echo -e "${GREEN}  ✓ Working: ${PREFIX}_error_page.txt${NC}"
echo -e "${GREEN}  ✓ Archived: $DOJO_BASELINES/nginx/${PREFIX}_error_page_${TIMESTAMP}.txt${NC}"
((EVIDENCE_FILES+=2))
echo ""

# 5. HTTP methods test
((SCAN_COUNT++))
echo -e "${YELLOW}[${SCAN_COUNT}/${TOTAL_SCANS}] HTTP methods test (OPTIONS)${NC}"
curl $DOJO_CURL_OPTS -X OPTIONS -v \
 "http://${DOJO_TARGET_HOST}:${HTTP_PORT}" \
 > "${PREFIX}_methods_test.txt" 2>&1
cp "${PREFIX}_methods_test.txt" \
   "$DOJO_BASELINES/nginx/${PREFIX}_methods_${TIMESTAMP}.txt"
echo -e "${GREEN}  ✓ Working: ${PREFIX}_methods_test.txt${NC}"
echo -e "${GREEN}  ✓ Archived: $DOJO_BASELINES/nginx/${PREFIX}_methods_${TIMESTAMP}.txt${NC}"
((EVIDENCE_FILES+=2))
echo ""

# =========================
# PART 2 — HTTPS / TLS
# =========================
echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   PART 2: HTTPS/TLS EVIDENCE (443)    ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
echo ""

# 6. HTTPS headers
((SCAN_COUNT++))
echo -e "${YELLOW}[${SCAN_COUNT}/${TOTAL_SCANS}] HTTPS headers (security validation)${NC}"
curl $DOJO_CURL_OPTS -I \
 "https://${DOJO_TARGET_HOST}:${HTTPS_PORT}" \
 > "${PREFIX}_https_headers.txt" 2>&1
cp "${PREFIX}_https_headers.txt" \
   "$DOJO_BASELINES/nginx/${PREFIX}_https_headers_${TIMESTAMP}.txt"
cp "${PREFIX}_https_headers.txt" \
   "$DOJO_CAPTURES/tls/${PREFIX}_https_headers_${TIMESTAMP}.txt"
echo -e "${GREEN}  ✓ Working: ${PREFIX}_https_headers.txt${NC}"
echo -e "${GREEN}  ✓ Archived: $DOJO_BASELINES/nginx/${PREFIX}_https_headers_${TIMESTAMP}.txt${NC}"
echo -e "${GREEN}  ✓ Captured: $DOJO_CAPTURES/tls/${PREFIX}_https_headers_${TIMESTAMP}.txt${NC}"
((EVIDENCE_FILES+=3))
echo ""

# 7. HTTPS HTML body (CSS detection)
((SCAN_COUNT++))
echo -e "${YELLOW}[${SCAN_COUNT}/${TOTAL_SCANS}] HTTPS HTML body (CSS detection)${NC}"
curl $DOJO_CURL_OPTS --http2 \
 "https://${DOJO_TARGET_HOST}:${HTTPS_PORT}/" \
 > "${PREFIX}_https_html.txt" 2>&1
cp "${PREFIX}_https_html.txt" \
   "$DOJO_BASELINES/nginx/${PREFIX}_https_html_${TIMESTAMP}.txt"
cp "${PREFIX}_https_html.txt" \
   "$DOJO_CAPTURES/tls/${PREFIX}_html_${TIMESTAMP}.txt"
echo -e "${GREEN}  ✓ Working: ${PREFIX}_https_html.txt${NC}"
echo -e "${GREEN}  ✓ Archived: $DOJO_BASELINES/nginx/${PREFIX}_https_html_${TIMESTAMP}.txt${NC}"
echo -e "${GREEN}  ✓ Captured: $DOJO_CAPTURES/tls/${PREFIX}_html_${TIMESTAMP}.txt${NC}"
((EVIDENCE_FILES+=3))
echo ""

# 8. HTTP → HTTPS redirect validation
((SCAN_COUNT++))
echo -e "${YELLOW}[${SCAN_COUNT}/${TOTAL_SCANS}] HTTP → HTTPS redirect validation${NC}"
curl $DOJO_CURL_OPTS -I \
 "http://${DOJO_TARGET_HOST}:${HTTP_PORT}" \
 > "${PREFIX}_https_redirect.txt" 2>&1
cp "${PREFIX}_https_redirect.txt" \
   "$DOJO_BASELINES/nginx/${PREFIX}_https_redirect_${TIMESTAMP}.txt"
echo -e "${GREEN}  ✓ Working: ${PREFIX}_https_redirect.txt${NC}"
echo -e "${GREEN}  ✓ Archived: $DOJO_BASELINES/nginx/${PREFIX}_https_redirect_${TIMESTAMP}.txt${NC}"
((EVIDENCE_FILES+=2))
echo ""

# 9. HSTS header check
((SCAN_COUNT++))
echo -e "${YELLOW}[${SCAN_COUNT}/${TOTAL_SCANS}] HSTS header check${NC}"
curl $DOJO_CURL_OPTS -I \
 "https://${DOJO_TARGET_HOST}:${HTTPS_PORT}" \
 | grep -i "Strict-Transport-Security" \
 > "${PREFIX}_hsts_header.txt" || echo "HSTS not found" > "${PREFIX}_hsts_header.txt"
cp "${PREFIX}_hsts_header.txt" \
   "$DOJO_BASELINES/nginx/${PREFIX}_hsts_${TIMESTAMP}.txt"
echo -e "${GREEN}  ✓ Working: ${PREFIX}_hsts_header.txt${NC}"
echo -e "${GREEN}  ✓ Archived: $DOJO_BASELINES/nginx/${PREFIX}_hsts_${TIMESTAMP}.txt${NC}"
((EVIDENCE_FILES+=2))
echo ""

# 10. HTTP/2 protocol validation
((SCAN_COUNT++))
echo -e "${YELLOW}[${SCAN_COUNT}/${TOTAL_SCANS}] HTTP/2 protocol validation${NC}"
curl $DOJO_CURL_OPTS --http2 -I \
 "https://${DOJO_TARGET_HOST}:${HTTPS_PORT}" \
 | grep -m1 "^HTTP/" \
 > "${PREFIX}_http2_check.txt" || true
cp "${PREFIX}_http2_check.txt" \
   "$DOJO_BASELINES/nginx/${PREFIX}_http2_${TIMESTAMP}.txt"
echo -e "${GREEN}  ✓ Working: ${PREFIX}_http2_check.txt${NC}"
echo -e "${GREEN}  ✓ Archived: $DOJO_BASELINES/nginx/${PREFIX}_http2_${TIMESTAMP}.txt${NC}"
((EVIDENCE_FILES+=2))
echo ""

# 11. SSL certificate details
((SCAN_COUNT++))
echo -e "${YELLOW}[${SCAN_COUNT}/${TOTAL_SCANS}] SSL certificate details${NC}"
echo | openssl s_client \
 -connect "${DOJO_TARGET_HOST}:${HTTPS_PORT}" \
 -servername "$DOJO_TARGET_HOST" 2>/dev/null \
 | openssl x509 -noout -text \
 > "${PREFIX}_ssl_cert_details.txt"
cp "${PREFIX}_ssl_cert_details.txt" \
   "$DOJO_BASELINES/nginx/${PREFIX}_ssl_cert_${TIMESTAMP}.txt"
echo -e "${GREEN}  ✓ Working: ${PREFIX}_ssl_cert_details.txt${NC}"
echo -e "${GREEN}  ✓ Archived: $DOJO_BASELINES/nginx/${PREFIX}_ssl_cert_${TIMESTAMP}.txt${NC}"
((EVIDENCE_FILES+=2))
echo ""

# =========================
# PART 3 — VULNERABILITY SCANS
# =========================
echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   PART 3: VULNERABILITY SCANS         ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
echo ""

# 12. Nikto HTTP scan
((SCAN_COUNT++))
echo -e "${YELLOW}[${SCAN_COUNT}/${TOTAL_SCANS}] Nikto HTTP scan (informational)${NC}"
nikto -h "http://${DOJO_TARGET_HOST}:${HTTP_PORT}" \
 | tee "${PREFIX}_nikto_http.txt" > /dev/null || true
cp "${PREFIX}_nikto_http.txt" \
   "$DOJO_BASELINES/nginx/${PREFIX}_nikto_http_${TIMESTAMP}.txt"
echo -e "${GREEN}  ✓ Working: ${PREFIX}_nikto_http.txt${NC}"
echo -e "${GREEN}  ✓ Archived: $DOJO_BASELINES/nginx/${PREFIX}_nikto_http_${TIMESTAMP}.txt${NC}"
((EVIDENCE_FILES+=2))
echo ""

# 13. Nikto HTTPS scan
((SCAN_COUNT++))
echo -e "${YELLOW}[${SCAN_COUNT}/${TOTAL_SCANS}] Nikto HTTPS scan (authoritative)${NC}"
nikto -h "https://${DOJO_TARGET_HOST}:${HTTPS_PORT}" -ssl \
 | tee "${PREFIX}_nikto_https.txt" > /dev/null || true
cp "${PREFIX}_nikto_https.txt" \
   "$DOJO_BASELINES/nginx/${PREFIX}_nikto_https_${TIMESTAMP}.txt"
echo -e "${GREEN}  ✓ Working: ${PREFIX}_nikto_https.txt${NC}"
echo -e "${GREEN}  ✓ Archived: $DOJO_BASELINES/nginx/${PREFIX}_nikto_https_${TIMESTAMP}.txt${NC}"
((EVIDENCE_FILES+=2))
echo ""

# =========================
# PART 4 — PRIVILEGED SCANS (NMAP)
# =========================
echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   PART 4: NMAP (PRIVILEGED SCANS)    ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}⚠️  Following scans require sudo privileges${NC}"
echo ""

# 14. Nmap HTTP service detection
((SCAN_COUNT++))
echo -e "${YELLOW}[${SCAN_COUNT}/${TOTAL_SCANS}] Nmap HTTP service detection ${RED}(sudo)${NC}"
sudo nmap -sV -p "$HTTP_PORT" "$DOJO_TARGET_HOST" \
 -oN "${PREFIX}_nmap_http.txt" || true
cp "${PREFIX}_nmap_http.txt" \
   "$DOJO_BASELINES/nginx/${PREFIX}_nmap_http_${TIMESTAMP}.txt"
cp "${PREFIX}_nmap_http.txt" \
   "$DOJO_CAPTURES/nmap/${PREFIX}_http_${TIMESTAMP}.txt"
echo -e "${GREEN}  ✓ Working: ${PREFIX}_nmap_http.txt${NC}"
echo -e "${GREEN}  ✓ Archived: $DOJO_BASELINES/nginx/${PREFIX}_nmap_http_${TIMESTAMP}.txt${NC}"
echo -e "${GREEN}  ✓ Captured: $DOJO_CAPTURES/nmap/${PREFIX}_http_${TIMESTAMP}.txt${NC}"
((EVIDENCE_FILES+=3))
echo ""

# 15. Nmap HTTPS service detection
((SCAN_COUNT++))
echo -e "${YELLOW}[${SCAN_COUNT}/${TOTAL_SCANS}] Nmap HTTPS service detection ${RED}(sudo)${NC}"
sudo nmap -sV -p "$HTTPS_PORT" "$DOJO_TARGET_HOST" \
 -oN "${PREFIX}_nmap_https.txt" || true
cp "${PREFIX}_nmap_https.txt" \
   "$DOJO_BASELINES/nginx/${PREFIX}_nmap_https_${TIMESTAMP}.txt"
cp "${PREFIX}_nmap_https.txt" \
   "$DOJO_CAPTURES/nmap/${PREFIX}_https_${TIMESTAMP}.txt"
echo -e "${GREEN}  ✓ Working: ${PREFIX}_nmap_https.txt${NC}"
echo -e "${GREEN}  ✓ Archived: $DOJO_BASELINES/nginx/${PREFIX}_nmap_https_${TIMESTAMP}.txt${NC}"
echo -e "${GREEN}  ✓ Captured: $DOJO_CAPTURES/nmap/${PREFIX}_https_${TIMESTAMP}.txt${NC}"
((EVIDENCE_FILES+=3))
echo ""

# 16. TLS cipher enumeration
((SCAN_COUNT++))
echo -e "${YELLOW}[${SCAN_COUNT}/${TOTAL_SCANS}] TLS cipher enumeration ${RED}(sudo)${NC}"
sudo nmap -p "$HTTPS_PORT" --script ssl-enum-ciphers "$DOJO_TARGET_HOST" \
 -oN "${PREFIX}_ssl_ciphers.txt" || true
cp "${PREFIX}_ssl_ciphers.txt" \
   "$DOJO_BASELINES/nginx/${PREFIX}_ssl_ciphers_${TIMESTAMP}.txt"
cp "${PREFIX}_ssl_ciphers.txt" \
   "$DOJO_CAPTURES/tls/${PREFIX}_ciphers_${TIMESTAMP}.txt"
echo -e "${GREEN}  ✓ Working: ${PREFIX}_ssl_ciphers.txt${NC}"
echo -e "${GREEN}  ✓ Archived: $DOJO_BASELINES/nginx/${PREFIX}_ssl_ciphers_${TIMESTAMP}.txt${NC}"
echo -e "${GREEN}  ✓ Captured: $DOJO_CAPTURES/tls/${PREFIX}_ciphers_${TIMESTAMP}.txt${NC}"
((EVIDENCE_FILES+=3))
echo ""

# =========================
# FINAL SUMMARY
# =========================
echo ""
echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   BASELINE CAPTURE COMPLETE           ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}📊 CAPTURE SUMMARY:${NC}"
echo -e "${GREEN}  ✓ Total scans executed: ${SCAN_COUNT}/${TOTAL_SCANS}${NC}"
echo -e "${GREEN}  ✓ Evidence files created: ${EVIDENCE_FILES}${NC}"
echo -e "${GREEN}  ✓ Working directory: ${SESSION_DIR}${NC}"
echo -e "${GREEN}  ✓ Timestamp: ${TIMESTAMP}${NC}"
echo ""
echo -e "${BLUE}📁 EVIDENCE LOCATIONS:${NC}"
echo -e "${BLUE}  → Baselines: $DOJO_BASELINES/nginx/${NC}"
echo -e "${BLUE}  → HTTP captures: $DOJO_CAPTURES/curl/${NC}"
echo -e "${BLUE}  → TLS captures: $DOJO_CAPTURES/tls/${NC}"
echo -e "${BLUE}  → Nmap captures: $DOJO_CAPTURES/nmap/${NC}"
echo ""
echo -e "${YELLOW}🎯 NEXT STEPS:${NC}"
echo -e "${YELLOW}  1. Review working files in: ${SESSION_DIR}${NC}"
echo -e "${YELLOW}  2. Run hardening on target (HTTPS, security headers, etc)${NC}"
echo -e "${YELLOW}  3. Run baseline_capture.sh again with 'after' prefix${NC}"
echo -e "${YELLOW}  4. Compare with: daily_diff.sh <before_session> <after_session>${NC}"
echo ""
echo -e "${GREEN}✓ Baseline capture complete - ready for Purple Team operations${NC}"
echo ""
