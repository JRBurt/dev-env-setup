#!/usr/bin/env bash
# push-server.sh — push SSH key + configs to a new server, then run server-setup.sh
# Runs on the LOCAL machine (macOS or Linux).
# Usage: ./scripts/push-server.sh <host> [user] [port] [--no-sshd-harden] [--add-ssh-config]
#
# Examples:
#   ./scripts/push-server.sh 192.168.10.42
#   ./scripts/push-server.sh pi.local pi 22 --add-ssh-config
#   ./scripts/push-server.sh server-50 john 22 --no-sshd-harden

set -euo pipefail

###################################################################################################
#                                         BEAUTIFICATION                                          #
###################################################################################################

BOLD=$(tput bold 2>/dev/null || echo "")
CYAN=$(tput setaf 6 2>/dev/null || echo "")
RED=$(tput setaf 1 2>/dev/null || echo "")
GREEN=$(tput setaf 2 2>/dev/null || echo "")
YELLOW=$(tput setaf 3 2>/dev/null || echo "")
DEFAULT=$(tput sgr0 2>/dev/null || echo "")

ARROW="$CYAN$BOLD==>$DEFAULT"
ARROW_GREEN="$GREEN$BOLD==>$DEFAULT"
ARROW_YELLOW="$YELLOW$BOLD==>$DEFAULT"
ARROW_RED="$RED$BOLD==>$DEFAULT"

log()         { echo -e "${ARROW} $*"; }
log_ok()      { echo -e "${ARROW_GREEN} $*"; }
log_warn()    { echo -e "${ARROW_YELLOW} $*"; }
log_err()     { echo -e "${ARROW_RED} $*" >&2; }

###################################################################################################
#                                         ARGUMENT PARSING                                        #
###################################################################################################

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <host> [user] [port] [--no-sshd-harden] [--add-ssh-config] [--alias <name>]"
    echo ""
    echo "  host            IP address or hostname (required)"
    echo "  user            Remote username (default: \$USER)"
    echo "  port            SSH port (default: 22)"
    echo "  --no-sshd-harden   Skip disabling password auth on the remote"
    echo "  --add-ssh-config   Append a Host block to ~/.ssh/config"
    echo "  --alias <name>  Friendly alias for the --add-ssh-config block"
    exit 1
fi

REMOTE_HOST="$1"; shift
REMOTE_USER="${USER}"
REMOTE_PORT=22
HARDEN_FLAG=""
ADD_SSH_CONFIG=false
SSH_ALIAS=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-sshd-harden)   HARDEN_FLAG="--no-sshd-harden"; shift ;;
        --add-ssh-config)   ADD_SSH_CONFIG=true; shift ;;
        --alias)            SSH_ALIAS="$2"; shift 2 ;;
        [0-9]*)             REMOTE_PORT="$1"; shift ;;
        -*)                 log_err "Unknown flag: $1"; exit 1 ;;
        *)                  REMOTE_USER="$1"; shift ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SSH_OPTS=(-p "$REMOTE_PORT" -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10)

###################################################################################################
#                                          LOCAL PREREQ CHECK                                     #
###################################################################################################

log "Target: ${BOLD}${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PORT}${DEFAULT}"
echo ""

# Locate a public key
SSH_KEY=""
for candidate in ~/.ssh/id_ed25519 ~/.ssh/id_rsa ~/.ssh/id_ecdsa; do
    if [[ -f "${candidate}.pub" ]]; then
        SSH_KEY="${candidate}.pub"
        break
    fi
done

if [[ -z "$SSH_KEY" ]]; then
    log_err "No SSH public key found. Generate one with: ssh-keygen -t ed25519"
    exit 1
fi

log_ok "Using public key: $SSH_KEY"

###################################################################################################
#                                       PUSH AUTHORIZED KEY                                       #
###################################################################################################

log "Copying public key to remote (you may be prompted for the remote password)..."
ssh-copy-id -i "$SSH_KEY" "${SSH_OPTS[@]}" "${REMOTE_USER}@${REMOTE_HOST}"
log_ok "Public key installed on ${REMOTE_HOST}"

###################################################################################################
#                                         SCP CONFIG FILES                                        #
###################################################################################################

REMOTE_TMP="/tmp/server-setup-$$"

log "Uploading setup files to $REMOTE_HOST:$REMOTE_TMP..."
ssh "${SSH_OPTS[@]}" "${REMOTE_USER}@${REMOTE_HOST}" "mkdir -p $REMOTE_TMP"

scp -P "$REMOTE_PORT" -q "$SCRIPT_DIR/server-setup.sh" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_TMP}/"

if [[ -f "$REPO_ROOT/config/.tmux.conf" ]]; then
    scp -P "$REMOTE_PORT" -q "$REPO_ROOT/config/.tmux.conf" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_TMP}/"
    TMUX_CONF_FLAG="--tmux-conf ${REMOTE_TMP}/.tmux.conf"
    log_ok ".tmux.conf uploaded"
else
    TMUX_CONF_FLAG=""
    log_warn "No config/.tmux.conf found — tmux will use defaults"
fi

###################################################################################################
#                                       REMOTE EXECUTION                                          #
###################################################################################################

log "Running server-setup.sh on ${REMOTE_HOST}..."
echo ""
ssh "${SSH_OPTS[@]}" "${REMOTE_USER}@${REMOTE_HOST}" \
    "bash ${REMOTE_TMP}/server-setup.sh ${TMUX_CONF_FLAG} ${HARDEN_FLAG}; rm -rf ${REMOTE_TMP}"

###################################################################################################
#                                    LOCAL SSH CONFIG UPDATE                                      #
###################################################################################################

if $ADD_SSH_CONFIG; then
    LOCAL_SSH_CONFIG="$HOME/.ssh/config"
    ALIAS="${SSH_ALIAS:-${REMOTE_HOST//./-}}"

    if grep -q "Host ${ALIAS}" "$LOCAL_SSH_CONFIG" 2>/dev/null; then
        log_warn "Host block '${ALIAS}' already exists in $LOCAL_SSH_CONFIG — skipping"
    else
        KEY_PATH="${SSH_KEY%.pub}"  # strip .pub to get the private key path

        log "Appending Host block to $LOCAL_SSH_CONFIG..."
        cat >> "$LOCAL_SSH_CONFIG" <<EOF

# Added by push-server.sh on $(date +%Y-%m-%d)
Host ${ALIAS}
    HostName ${REMOTE_HOST}
    User ${REMOTE_USER}
    IdentityFile ${KEY_PATH}
    Port ${REMOTE_PORT}
EOF
        log_ok "SSH config entry '${ALIAS}' added — connect with: ssh ${ALIAS}"
    fi
fi

###################################################################################################
#                                               FIN                                               #
###################################################################################################

echo ""
echo -e "${GREEN}${BOLD}Push complete!${DEFAULT}"
echo -e "  Connect: ${BOLD}ssh -p ${REMOTE_PORT} ${REMOTE_USER}@${REMOTE_HOST}${DEFAULT}"
if $ADD_SSH_CONFIG && [[ -n "${SSH_ALIAS:-}" || -n "$ALIAS" ]]; then
    echo -e "  Alias:   ${BOLD}ssh ${ALIAS:-$SSH_ALIAS}${DEFAULT}"
fi
echo -e "  tmux:    ${BOLD}tmux new -s main${DEFAULT}  /  ${BOLD}tmux attach -t main${DEFAULT}"
