#!/usr/bin/env bash
set -euo pipefail

repo="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
test_dir="$(mktemp -d)"
trap 'rm -rf -- "$test_dir"' EXIT
export GIT_CONFIG_GLOBAL="$test_dir/gitconfig"
export GIT_CONFIG_NOSYSTEM=1
cd "$test_dir"

# Never use a developer's real GitHub session during regression tests.
gh() { return "${TEST_GH_STATUS:-0}"; }
export -f gh

# Unrelated host checks may fail; assert the Git checks and failure exit directly.
git config --global user.name 'Fixture User'
git config --global user.email 'fixture@example.invalid'
git config --global init.defaultBranch main
bash "$repo/scripts/wsl/verify.sh" > "$test_dir/result" 2>&1 || true
for key in user.name user.email init.defaultBranch; do
  grep -Fq "[PASS] Git global $key" "$test_dir/result"
done
grep -Fq '[PASS] GitHub CLI は認証済みです。' "$test_dir/result"
if grep -Fq 'fixture@example.invalid' "$test_dir/result"; then
  echo 'Git identity leaked into output' >&2
  exit 1
fi
for key in user.name user.email init.defaultBranch; do
  git config --global --unset "$key"
  if bash "$repo/scripts/wsl/verify.sh" > "$test_dir/result" 2>&1; then
    echo "missing $key passed" >&2
    exit 1
  fi
  if grep -Fq "[PASS] Git global $key" "$test_dir/result"; then
    echo "missing $key reported PASS" >&2
    exit 1
  fi
  if [[ "$key" == init.defaultBranch ]]; then
    grep -Fq '[FAIL] git config --global init.defaultBranch main' "$test_dir/result"
  else
    grep -Fq "[FAIL] Git global $key" "$test_dir/result"
  fi
done
git config --global user.name '   '
git config --global user.email ''
git config --global init.defaultBranch master
bash "$repo/scripts/wsl/verify.sh" > "$test_dir/result" 2>&1 || true
if grep -Fq '[PASS] Git global' "$test_dir/result"; then
  echo 'invalid Git config reported PASS' >&2
  exit 1
fi
TEST_GH_STATUS=1 bash "$repo/scripts/wsl/verify.sh" > "$test_dir/result" 2>&1 || true
grep -Fq '[FAIL] GitHub CLI は未認証です。' "$test_dir/result"
echo 'WSL Git verification tests PASS'
