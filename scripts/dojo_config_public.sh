#!/usr/bin/env bash
# ~/.dojo_config.sh
# Cyber Dojo - Universal Config (PUBLIC TEMPLATE)
# Copy this file to:  ~/.dojo_config.sh
# Then edit values OR run ./setup_dojo.sh to generate it.

# =========================
# TARGET (REQUIRED)
# =========================
export DOJO_TARGET_HOST="${DOJO_TARGET_HOST:-CHANGE_ME}"   # e.g. 10.0.10.20
export DOJO_TARGET_USER="${DOJO_TARGET_USER:-CHANGE_ME}"   # e.g. ubuntu / danby / admin
export DOJO_TARGET_PORT_SSH="${DOJO_TARGET_PORT_SSH:-22}"

# Optional: if you use ~/.ssh/config aliases (recommended)
# Example: Host dojo-admin -> HostName, User, IdentityFile, etc.
export DOJO_SSH_ALIAS="${DOJO_SSH_ALIAS:-}"               # e.g. dojo-admin (leave blank if not used)

# =========================
# SSH KEYS (OPTIONAL BUT RECOMMENDED)
# =========================
# If using DOJO_SSH_ALIAS, keys can live in ~/.ssh/config and you can ignore these.
export DOJO_KEY_ADMIN="${DOJO_KEY_ADMIN:-$HOME/.ssh/dojo_admin}"
export DOJO_KEY_LOGSYNC="${DOJO_KEY_LOGSYNC:-$HOME/.ssh/dojo_logsync}"
export DOJO_KEY_WATCH="${DOJO_KEY_WATCH:-$HOME/.ssh/dojo_watch}"

# =========================
# LOCAL DOJO HOME (REQUIRED)
# =========================
# This is where baselines/captures/sessions/diffs are written locally.
export DOJO_HOME="${DOJO_HOME:-$HOME/cyber_dojo}"

export DOJO_SCRIPTS="${DOJO_SCRIPTS:-$DOJO_HOME/scripts}"
export DOJO_BASELINES="${DOJO_BASELINES:-$DOJO_HOME/baselines}"
export DOJO_CAPTURES="${DOJO_CAPTURES:-$DOJO_HOME/captures}"
export DOJO_LOGS="${DOJO_LOGS:-$DOJO_HOME/logs}"
export DOJO_DIFFS="${DOJO_DIFFS:-$DOJO_HOME/daily_diff}"
export DOJO_SESSIONS="${DOJO_SESSIONS:-$DOJO_HOME/sessions}"

# =========================
# REMOTE LOG PATHS (OPTIONAL)
# =========================
export DOJO_LOGS_NGINX_ACCESS="${DOJO_LOGS_NGINX_ACCESS:-/var/log/nginx/access.log}"
export DOJO_LOGS_NGINX_ERROR="${DOJO_LOGS_NGINX_ERROR:-/var/log/nginx/error.log}"
export DOJO_LOGS_AUTH="${DOJO_LOGS_AUTH:-/var/log/auth.log}"

# Optional (only if you actually use it)
export DOJO_LOGS_GUARDIAN="${DOJO_LOGS_GUARDIAN:-}"

# =========================
# HELPERS
# =========================
dojo_target() {
  if [[ -n "${DOJO_SSH_ALIAS}" ]]; then
    echo "${DOJO_SSH_ALIAS}"
  else
    echo "${DOJO_TARGET_USER}@${DOJO_TARGET_HOST}"
  fi
}

dojo_ssh_base() {
  # Builds SSH command (does not execute)
  local key="${1:-$DOJO_KEY_ADMIN}"

  if [[ -n "${DOJO_SSH_ALIAS}" ]]; then
    echo "ssh ${DOJO_SSH_ALIAS}"
    return 0
  fi

  # Key only if it exists; avoids forcing a non-existent IdentityFile.
  if [[ -f "${key}" ]]; then
    echo "ssh -i \"${key}\" -p \"${DOJO_TARGET_PORT_SSH}\" -o IdentitiesOnly=yes \"$(dojo_target)\""
  else
    echo "ssh -p \"${DOJO_TARGET_PORT_SSH}\" \"$(dojo_target)\""
  fi
}
