#!/usr/bin/env bash
# GCE startup script: runs as root on every boot, idempotent.
# Bootstraps the OS Login user's environment from this dotfiles repo.
#
# Attach:
#   gcloud compute instances add-metadata <vm> --zone=<zone> \
#     --metadata=dotfiles-user=<os-login-user> \
#     --metadata-from-file=startup-script=vm/gcp-startup.sh
# Optional metadata: dotfiles-repo (default: github.com/michaelschleiss/dotfiles),
#                    dotfiles-modules (default: "vm zsh zsh-profile")
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

META="http://metadata.google.internal/computeMetadata/v1/instance/attributes"
meta() { curl -sf -H "Metadata-Flavor: Google" "$META/$1" || true; }
log() { echo "[startup] $*"; }

USER_NAME="$(meta dotfiles-user)"
REPO="$(meta dotfiles-repo)"; REPO="${REPO:-https://github.com/michaelschleiss/dotfiles.git}"
MODULES="$(meta dotfiles-modules)"; MODULES="${MODULES:-vm zsh zsh-profile}"

if [[ -z "$USER_NAME" ]]; then
  log "metadata dotfiles-user not set; nothing to do"
  exit 0
fi
HOME_DIR="/home/$USER_NAME"
if ! id "$USER_NAME" >/dev/null 2>&1 || [[ ! -d "$HOME_DIR" ]]; then
  log "user $USER_NAME has no home yet; log in once via SSH, then re-run"
  exit 0
fi

# rsync is needed by dev-env before runs/vm gets a chance to install it.
apt-get install -qq -y git curl sudo rsync zsh >/dev/null

# OS Login accounts are not in /etc/passwd and have no password, so neither usermod nor
# runs/zsh's chsh can change the login shell. Export SHELL so runs/zsh skips chsh;
# runs/vm makes bash exec into zsh for interactive logins instead.
as_user() { runuser -u "$USER_NAME" -- env HOME="$HOME_DIR" SHELL=/usr/bin/zsh "$@"; }

DOTFILES="$HOME_DIR/personal/dotfiles"
if [[ -d "$DOTFILES/.git" ]]; then
  log "updating dotfiles"
  as_user git -C "$DOTFILES" pull -q --ff-only || log "pull failed, using existing checkout"
else
  log "cloning $REPO"
  as_user mkdir -p "$HOME_DIR/personal"
  as_user git clone -q "$REPO" "$DOTFILES"
fi
as_user git -C "$DOTFILES" submodule update --init --quiet || true

cd "$DOTFILES"
log "deploying configs (dev-env)"
as_user ./dev-env >/dev/null
log "running modules: $MODULES"
# shellcheck disable=SC2086
as_user ./run $MODULES

loginctl enable-linger "$USER_NAME" 2>/dev/null || true
log "done"
