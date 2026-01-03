#!/usr/bin/env bash
set -Eeuo pipefail

# baseline_capture_public.sh
# Cyber Dojo Baseline Capture (HTTP + HTTPS/TLS)
# Requires: ~/.dojo_config.sh

if [[ ! -f "$HOME/.dojo_config.sh" ]]; then
  echo "ERROR: Missing config: $HOME/.dojo_config.sh"
  echo "Fix: copy dojo_config_public.sh to ~/.dojo_config.sh OR run ./setup_dojo.sh"
  exit 1
fi

# shellcheck disable=SC1090
source "$HOME/.dojo_config.sh"

PREFIX="${1:-baseline}"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

# Basic validation (public safe)
if [[ "${DOJO_TARGET_HOST}" == "CHANGE_ME" || "${DOJO_TARGET_USER}" == "CHANGE_ME" ]]; then
  echo "ERROR: Set DOJO_TARGET_HOST and DOJO_TARGET_USER in ~/.dojo_config.sh"
  exit 1
fi

# Create output dirs
mkdir -p "$DOJO_BASELINES/nginx"
mkdir -p "$DOJO_CAPTURES/curl" "$DOJO_CAPTURES/nmap" "$DOJO_CAPTURES/tls"
mkdir -p "$DOJO_SESSIONS"

# Auto-create a session folder (so users don’t need your workflow)
SESSION_DIR="$DOJO_SESSIONS/session_${TIMESTAMP}_${PREFIX}"
mkdir -p "$SESSION_DIR"
cd "$SESSION_DIR"

# Colors (minimal + safe)
GREEN="\033[0;32m"; BLUE="\033[0;34m"; YELLOW="\033[1;33m"; NC="\033[0m"

echo -e "${GREEN}=== Cyber Dojo Baseline Capture ===${NC}"
echo -e "${BLUE}Target:${NC} ${DOJO_TARGET_HOST}"
echo -e "${BLUE}Session:${NC} $SESSION_DIR"
echo

save_copy() {
  local src="$1"
  local dest="$2"
  cp "$src" "$dest"
}

# ------------------------
# 1) HTTP headers
# ------------------------
echo -e "${GREEN}[1] HTTP headers (port 80)${NC}"
curl -sS -I "http://${DOJO_TARGET_HOST}/" > "${PREFIX}_http_headers.txt" || true
save_copy "${PREFIX}_http_headers.txt" "$DOJO_BASELINES/nginx/${PREFIX}_http_headers_${TIMESTAMP}.txt"
echo -e "${BLUE}  ✓ saved${NC}"

# ------------------------
# 2) HTTPS headers
# ------------------------
echo -e "${GREEN}[2] HTTPS headers (port 443)${NC}"
curl -sS -Ik "https://${DOJO_TARGET_HOST}/" > "${PREFIX}_https_headers.txt" || true
save_copy "${PREFIX}_https_headers.txt" "$DOJO_BASELINES/nginx/${PREFIX}_https_headers_${TIMESTAMP}.txt"
echo -e "${BLUE}  ✓ saved${NC}"

# ------------------------
# 3) HTTP -> HTTPS redirect check
# ------------------------
echo -e "${GREEN}[3] HTTP redirect check (expect 301 to https)${NC}"
curl -sS -I "http://${DOJO_TARGET_HOST}/" > "${PREFIX}_http_redirect_check.txt" || true
save_copy "${PREFIX}_http_redirect_check.txt" "$DOJO_CAPTURES/curl/${PREFIX}_http_redirect_${TIMESTAMP}.txt"
echo -e "${BLUE}  ✓ saved${NC}"

# ------------------------
# 4) Error page test
# ------------------------
echo -e "${GREEN}[4] 404 error page${NC}"
curl -sS "http://${DOJO_TARGET_HOST}/doesnotexist" > "${PREFIX}_error_page.txt" || true
save_copy "${PREFIX}_error_page.txt" "$DOJO_BASELINES/nginx/${PREFIX}_error_page_${TIMESTAMP}.txt"
echo -e "${BLUE}  ✓ saved${NC}"

# ------------------------
# 5) HTTP methods test
# ------------------------
echo -e "${GREEN}[5] HTTP methods (OPTIONS)${NC}"
curl -sS -X OPTIONS -v "http://${DOJO_TARGET_HOST}/" > "${PREFIX}_methods_test.txt" 2>&1 || true
save_copy "${PREFIX}_methods_test.txt" "$DOJO_CAPTURES/curl/${PREFIX}_methods_${TIMESTAMP}.txt"
echo -e "${BLUE}  ✓ saved${NC}"

# ------------------------
# 6) Nmap port detection
# ------------------------
echo -e "${GREEN}[6] Nmap ports 80/443${NC}"
nmap -Pn -p 80,443 "${DOJO_TARGET_HOST}" -oN "${PREFIX}_nmap_ports.txt" >/dev/null 2>&1 || true
save_copy "${PREFIX}_nmap_ports.txt" "$DOJO_CAPTURES/nmap/${PREFIX}_nmap_ports_${TIMESTAMP}.txt"
echo -e "${BLUE}  ✓ saved${NC}"

# ------------------------
# 7) TLS cipher enum
# ------------------------
echo -e "${GREEN}[7] TLS cipher enumeration (ssl-enum-ciphers)${NC}"
nmap -Pn -p 443 --script ssl-enum-ciphers "${DOJO_TARGET_HOST}" -oN "${PREFIX}_tls_ciphers.txt" >/dev/null 2>&1 || true
save_copy "${PREFIX}_tls_ciphers.txt" "$DOJO_CAPTURES/tls/${PREFIX}_tls_ciphers_${TIMESTAMP}.txt"
echo -e "${BLUE}  ✓ saved${NC}"

# ------------------------
# 8) OpenSSL cert capture
# ------------------------
echo -e "${GREEN}[8] OpenSSL certificate details${NC}"
( echo | openssl s_client -connect "${DOJO_TARGET_HOST}:443" -servername "${DOJO_TARGET_HOST}" 2>/dev/null \
  | openssl x509 -noout -text ) > "${PREFIX}_cert_details.txt" || true
save_copy "${PREFIX}_cert_details.txt" "$DOJO_CAPTURES/tls/${PREFIX}_cert_details_${TIMESTAMP}.txt"
echo -e "${BLUE}  ✓ saved${NC}"

echo
echo -e "${GREEN}DONE.${NC} Output written to:"
echo "  Session:   $SESSION_DIR"
echo "  Baselines: $DOJO_BASELINES"
echo "  Captures:  $DOJO_CAPTURES"
