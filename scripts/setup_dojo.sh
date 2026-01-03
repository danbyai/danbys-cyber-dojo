#!/usr/bin/env bash
set -Eeuo pipefail

OUT="$HOME/.dojo_config.sh"

read -rp "Target host (e.g. 10.0.0.X): " HOST
read -rp "Target user (e.g. ubuntu): " USER
read -rp "Dojo home folder (default: \$HOME/cyber_dojo): " HOMEFOLDER
HOMEFOLDER="${HOMEFOLDER:-$HOME/cyber_dojo}"

read -rp "SSH key path for admin (default: \$HOME/.ssh/dojo_admin): " KEY_ADMIN
KEY_ADMIN="${KEY_ADMIN:-$HOME/.ssh/dojo_admin}"

cat > "$OUT" <<EOF
#!/usr/bin/env bash
export DOJO_TARGET_HOST="${HOST}"
export DOJO_TARGET_USER="${USER}"
export DOJO_TARGET_PORT_SSH="22"

export DOJO_SSH_ALIAS=""

export DOJO_KEY_ADMIN="${KEY_ADMIN}"
export DOJO_KEY_LOGSYNC="\$HOME/.ssh/dojo_logsync"
export DOJO_KEY_WATCH="\$HOME/.ssh/dojo_watch"

export DOJO_HOME="${HOMEFOLDER}"
export DOJO_SCRIPTS="\$DOJO_HOME/scripts"
export DOJO_BASELINES="\$DOJO_HOME/baselines"
export DOJO_CAPTURES="\$DOJO_HOME/captures"
export DOJO_LOGS="\$DOJO_HOME/logs"
export DOJO_DIFFS="\$DOJO_HOME/daily_diff"
export DOJO_SESSIONS="\$DOJO_HOME/sessions"

export DOJO_LOGS_NGINX_ACCESS="/var/log/nginx/access.log"
export DOJO_LOGS_NGINX_ERROR="/var/log/nginx/error.log"
export DOJO_LOGS_AUTH="/var/log/auth.log"
export DOJO_LOGS_GUARDIAN=""

dojo_target() {
  if [[ -n "\${DOJO_SSH_ALIAS}" ]]; then
    echo "\${DOJO_SSH_ALIAS}"
  else
    echo "\${DOJO_TARGET_USER}@\${DOJO_TARGET_HOST}"
  fi
}

dojo_ssh_base() {
  local key="\${1:-\$DOJO_KEY_ADMIN}"
  if [[ -n "\${DOJO_SSH_ALIAS}" ]]; then
    echo "ssh \${DOJO_SSH_ALIAS}"
    return 0
  fi
  if [[ -f "\${key}" ]]; then
    echo "ssh -i \"\${key}\" -p \"\${DOJO_TARGET_PORT_SSH}\" -o IdentitiesOnly=yes \"\$(dojo_target)\""
  else
    echo "ssh -p \"\${DOJO_TARGET_PORT_SSH}\" \"\$(dojo_target)\""
  fi
}
EOF

chmod 600 "$OUT"
mkdir -p "$HOMEFOLDER"/{scripts,baselines,captures,logs,daily_diff,sessions}

echo
echo "✅ Wrote: $OUT"
echo "✅ Created folders under: $HOMEFOLDER"
echo
echo "Next:"
echo "  source ~/.dojo_config.sh"
echo "  ./baseline_capture_public.sh test_run"
