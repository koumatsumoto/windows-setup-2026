# Managed by windows-setup-2026. Keep personal shell settings outside this file.
export PATH="$HOME/.local/bin:$HOME/.local/share/fnm:$PATH"

if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --shell bash)"
fi

if [[ -r "${BASH_SOURCE[0]%/*}/git-helpers.sh" ]]; then
  # shellcheck source=../shell/git-helpers.sh
  source "${BASH_SOURCE[0]%/*}/git-helpers.sh"
fi
