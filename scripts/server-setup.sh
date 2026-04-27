#!/usr/bin/env bash
# server-setup.sh — installs tmux and deploys configs on a headless Unix server
# Designed to run on Raspberry Pi OS, Ubuntu/Debian, Fedora/RHEL, Arch, Alpine
# Usage: bash server-setup.sh [--tmux-conf <path>] [--no-sshd-harden]

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

TMUX_CONF_SRC=""
HARDEN_SSHD=true

while [[ $# -gt 0 ]]; do
    case "$1" in
        --tmux-conf)    TMUX_CONF_SRC="$2"; shift 2 ;;
        --no-sshd-harden) HARDEN_SSHD=false; shift ;;
        -h|--help)
            echo "Usage: $0 [--tmux-conf <path>] [--no-sshd-harden]"
            exit 0
            ;;
        *) log_err "Unknown argument: $1"; exit 1 ;;
    esac
done

###################################################################################################
#                                       PACKAGE MANAGER DETECTION                                 #
###################################################################################################

detect_pkg_manager() {
    if   command -v apt-get &>/dev/null; then echo "apt"
    elif command -v dnf     &>/dev/null; then echo "dnf"
    elif command -v yum     &>/dev/null; then echo "yum"
    elif command -v pacman  &>/dev/null; then echo "pacman"
    elif command -v apk     &>/dev/null; then echo "apk"
    else
        log_err "No supported package manager found (apt/dnf/yum/pacman/apk)"
        exit 1
    fi
}

PKG_MGR=$(detect_pkg_manager)
log "Detected package manager: $BOLD$PKG_MGR$DEFAULT"

pkg_update() {
    case "$PKG_MGR" in
        apt)    sudo apt-get update -qq ;;
        dnf)    sudo dnf check-update -q || true ;;
        yum)    sudo yum check-update -q || true ;;
        pacman) sudo pacman -Sy --noconfirm ;;
        apk)    sudo apk update -q ;;
    esac
}

pkg_install() {
    local pkg="$1"
    case "$PKG_MGR" in
        apt)    sudo apt-get install -y -qq "$pkg" ;;
        dnf)    sudo dnf install -y -q "$pkg" ;;
        yum)    sudo yum install -y -q "$pkg" ;;
        pacman) sudo pacman -S --noconfirm --needed "$pkg" ;;
        apk)    sudo apk add -q "$pkg" ;;
    esac
}

###################################################################################################
#                                           TMUX INSTALL                                          #
###################################################################################################

log "Checking tmux..."
if command -v tmux &>/dev/null; then
    log_ok "tmux already installed: $(tmux -V)"
else
    log "Installing tmux..."
    pkg_update
    pkg_install tmux
    log_ok "tmux installed: $(tmux -V)"
fi

###################################################################################################
#                                         TMUX CONFIG DEPLOY                                      #
###################################################################################################

TMUX_CONF_DEST="$HOME/.tmux.conf"

if [[ -n "$TMUX_CONF_SRC" && -f "$TMUX_CONF_SRC" ]]; then
    if [[ -f "$TMUX_CONF_DEST" ]]; then
        BACKUP="$TMUX_CONF_DEST.backup.$(date +%Y%m%d_%H%M%S)"
        log_warn "Existing .tmux.conf backed up to $BACKUP"
        cp "$TMUX_CONF_DEST" "$BACKUP"
    fi
    cp "$TMUX_CONF_SRC" "$TMUX_CONF_DEST"
    log_ok ".tmux.conf deployed to $TMUX_CONF_DEST"
elif [[ -f "$(dirname "$0")/../config/.tmux.conf" ]]; then
    # Try relative path from script location (when run in-repo)
    RESOLVED="$(cd "$(dirname "$0")/.." && pwd)/config/.tmux.conf"
    if [[ -f "$TMUX_CONF_DEST" ]]; then
        BACKUP="$TMUX_CONF_DEST.backup.$(date +%Y%m%d_%H%M%S)"
        log_warn "Existing .tmux.conf backed up to $BACKUP"
        cp "$TMUX_CONF_DEST" "$BACKUP"
    fi
    cp "$RESOLVED" "$TMUX_CONF_DEST"
    log_ok ".tmux.conf deployed from repo config"
else
    log_warn "No .tmux.conf source found — skipping (pass --tmux-conf <path> to deploy one)"
fi

###################################################################################################
#                                          SSH DAEMON CHECK                                       #
###################################################################################################

log "Checking SSH daemon..."

SSHD_SVC=""
for svc in ssh sshd; do
    if systemctl list-units --type=service --all 2>/dev/null | grep -q "$svc.service"; then
        SSHD_SVC="$svc"
        break
    fi
done

if [[ -n "$SSHD_SVC" ]]; then
    if systemctl is-active --quiet "$SSHD_SVC"; then
        log_ok "SSH daemon ($SSHD_SVC) is running"
    else
        log_warn "SSH daemon ($SSHD_SVC) not running — attempting to start..."
        sudo systemctl enable "$SSHD_SVC"
        sudo systemctl start "$SSHD_SVC"
        log_ok "SSH daemon started and enabled"
    fi
elif command -v rc-service &>/dev/null; then
    # OpenRC (Alpine)
    if rc-service sshd status &>/dev/null; then
        log_ok "SSH daemon (sshd/OpenRC) is running"
    else
        sudo rc-update add sshd default
        sudo rc-service sshd start
        log_ok "SSH daemon started (OpenRC)"
    fi
else
    log_warn "Could not determine SSH daemon status — skipping (non-systemd/non-OpenRC system)"
fi

###################################################################################################
#                                        SSHD HARDENING                                          #
###################################################################################################

if $HARDEN_SSHD; then
    SSHD_CONFIG="/etc/ssh/sshd_config"

    if [[ ! -f "$SSHD_CONFIG" ]]; then
        log_warn "$SSHD_CONFIG not found — skipping hardening"
    elif [[ ! -f "$HOME/.ssh/authorized_keys" || ! -s "$HOME/.ssh/authorized_keys" ]]; then
        log_warn "No authorized_keys found — skipping hardening (would lock you out)"
    else
        log "Applying sshd hardening..."

        apply_sshd_setting() {
            local key="$1" val="$2"
            if grep -qE "^#?[[:space:]]*${key}[[:space:]]" "$SSHD_CONFIG"; then
                sudo sed -i -E "s|^#?[[:space:]]*${key}[[:space:]].*|${key} ${val}|" "$SSHD_CONFIG"
            else
                echo "${key} ${val}" | sudo tee -a "$SSHD_CONFIG" >/dev/null
            fi
        }

        apply_sshd_setting "PasswordAuthentication" "no"
        apply_sshd_setting "PermitRootLogin"        "no"
        apply_sshd_setting "PubkeyAuthentication"   "yes"
        apply_sshd_setting "AuthorizedKeysFile"     ".ssh/authorized_keys"
        apply_sshd_setting "X11Forwarding"          "no"
        apply_sshd_setting "PrintLastLog"           "yes"

        if [[ -n "$SSHD_SVC" ]]; then
            sudo systemctl reload "$SSHD_SVC" 2>/dev/null || sudo systemctl restart "$SSHD_SVC"
        elif command -v rc-service &>/dev/null; then
            sudo rc-service sshd reload 2>/dev/null || sudo rc-service sshd restart
        fi

        log_ok "sshd hardened (PasswordAuthentication=no, PermitRootLogin=no)"
    fi
else
    log_warn "sshd hardening skipped (--no-sshd-harden)"
fi

###################################################################################################
#                                               FIN                                               #
###################################################################################################

echo ""
echo -e "${GREEN}${BOLD}Server setup complete!${DEFAULT}"
echo -e "  Host:    $(hostname)"
echo -e "  tmux:    $(tmux -V)"
echo -e "  Config:  $TMUX_CONF_DEST"
echo ""
echo -e "${YELLOW}Tip:${DEFAULT} Start a session with ${BOLD}tmux new -s main${DEFAULT}"
echo -e "     Reattach with      ${BOLD}tmux attach -t main${DEFAULT}"
