#!/usr/bin/env bash

EXPECTED_UBUNTU_VERSION="26.04"
EXPECTED_WSL_DISTRIBUTION="Ubuntu-26.04"

APT_PACKAGES=(
  build-essential
  ca-certificates
  curl
  git
  gnupg
  python3
  unzip
)

FNM_INSTALL_URL="https://fnm.vercel.app/install"
UV_INSTALL_URL="https://astral.sh/uv/install.sh"
CODEX_INSTALL_URL="https://chatgpt.com/codex/install.sh"
CLAUDE_INSTALL_URL="https://claude.ai/install.sh"

MANAGED_ENV_RELATIVE_PATH=".config/windows-setup/env.sh"
MANAGED_SOURCE_LINE='[ -f "$HOME/.config/windows-setup/env.sh" ] && . "$HOME/.config/windows-setup/env.sh"'
