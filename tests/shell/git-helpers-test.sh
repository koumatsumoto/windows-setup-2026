#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=../../scripts/shell/git-helpers.sh
source "$repo_root/scripts/shell/git-helpers.sh"

tmp_root="$(mktemp -d)"
trap 'rm -rf -- "$tmp_root"' EXIT

fail() {
  printf '[FAIL] %s\n' "$1" >&2
  exit 1
}

assert_ref() {
  git -C "$1" show-ref --verify --quiet "$2" || fail "missing ref: $2"
}

assert_no_ref() {
  if git -C "$1" show-ref --verify --quiet "$2"; then
    fail "unexpected ref: $2"
  fi
}

new_repo() {
  local name="$1"
  local remote="$tmp_root/$name-remote.git"
  local repo="$tmp_root/$name"

  git init --quiet --bare "$remote"
  git init --quiet --initial-branch=main "$repo"
  git -C "$repo" config user.name Test
  git -C "$repo" config user.email test@example.com
  printf 'initial\n' >"$repo/file.txt"
  git -C "$repo" add file.txt
  git -C "$repo" commit --quiet -m initial
  git -C "$repo" remote add origin "$remote"
  git -C "$repo" push --quiet --set-upstream origin main
  printf '%s\n' "$repo"
}

push_remote_update() {
  local repo="$1"
  local name="$2"
  local updater="$tmp_root/$name-updater"

  git clone --quiet "$(git -C "$repo" remote get-url origin)" "$updater"
  git -C "$updater" config user.name Test
  git -C "$updater" config user.email test@example.com
  printf '%s\n' "$name" >>"$updater/file.txt"
  git -C "$updater" commit --quiet -am "$name"
  git -C "$updater" push --quiet origin main
}

test_grb_from_linked_worktree() {
  local repo invoke_wt used_wt before_branch
  repo="$(new_repo grb-linked)"
  invoke_wt="$tmp_root/grb invoke"
  used_wt="$tmp_root/grb used"

  git -C "$repo" branch merged-delete
  git -C "$repo" branch merged-used
  git -C "$repo" push --quiet origin merged-delete
  git -C "$repo" worktree add --quiet "$used_wt" merged-used
  git -C "$repo" worktree add --quiet -b feature-invoke "$invoke_wt"
  printf 'feature\n' >"$invoke_wt/feature.txt"
  git -C "$invoke_wt" add feature.txt
  git -C "$invoke_wt" commit --quiet -m feature
  git -C "$repo" branch unmerged-unused "$(git -C "$invoke_wt" rev-parse HEAD)"
  push_remote_update "$repo" grb-linked

  cd -- "$invoke_wt"
  before_branch="$(git branch --show-current)"
  grb

  [[ "$(git branch --show-current)" == "$before_branch" ]] || fail 'grb switched the invoking worktree'
  [[ "$(git -C "$repo" rev-parse main)" == "$(git -C "$repo" rev-parse origin/main)" ]] || fail 'grb did not update checked-out main'
  assert_no_ref "$repo" refs/heads/merged-delete
  assert_ref "$repo" refs/heads/merged-used
  assert_ref "$repo" refs/heads/feature-invoke
  assert_ref "$repo" refs/heads/unmerged-unused
  assert_ref "$repo" refs/remotes/origin/merged-delete
}

test_grb_updates_main_linked_worktree() {
  local repo main_wt before_branch
  repo="$(new_repo grb-main-linked)"
  git -C "$repo" switch --quiet -c primary-feature
  main_wt="$tmp_root/grb main linked"
  git -C "$repo" worktree add --quiet "$main_wt" main
  before_branch="$(git -C "$repo" branch --show-current)"
  push_remote_update "$repo" grb-main-linked

  cd -- "$repo"
  grb

  [[ "$(git branch --show-current)" == "$before_branch" ]] || fail 'grb switched the primary feature worktree'
  [[ "$(git -C "$main_wt" rev-parse HEAD)" == "$(git rev-parse origin/main)" ]] || fail 'grb did not update main in a linked worktree'
}

test_grb_without_main_worktree() {
  local repo before_branch
  repo="$(new_repo grb-no-main)"
  git -C "$repo" switch --quiet -c feature
  before_branch="$(git -C "$repo" branch --show-current)"
  push_remote_update "$repo" grb-no-main

  cd -- "$repo"
  grb

  [[ "$(git branch --show-current)" == "$before_branch" ]] || fail 'grb switched a feature primary worktree'
  [[ "$(git rev-parse main)" == "$(git rev-parse origin/main)" ]] || fail 'grb did not update an unchecked main ref'
}

test_grb_refuses_ahead_main() {
  local repo rc
  repo="$(new_repo grb-ahead)"
  git -C "$repo" branch merged-keep
  printf 'ahead\n' >>"$repo/file.txt"
  git -C "$repo" commit --quiet -am ahead

  cd -- "$repo"
  set +e
  grb >/dev/null 2>&1
  rc=$?
  set -e

  [[ $rc -ne 0 ]] || fail 'grb accepted an ahead main'
  assert_ref "$repo" refs/heads/merged-keep
}

test_grb_refuses_diverged_main() {
  local repo rc
  repo="$(new_repo grb-diverged)"
  git -C "$repo" branch merged-keep
  printf 'local\n' >>"$repo/file.txt"
  git -C "$repo" commit --quiet -am local
  push_remote_update "$repo" grb-diverged

  cd -- "$repo"
  set +e
  grb >/dev/null 2>&1
  rc=$?
  set -e

  [[ $rc -ne 0 ]] || fail 'grb accepted a diverged main'
  assert_ref "$repo" refs/heads/merged-keep
}

test_grb_continues_after_delete_failure() {
  local repo rc
  repo="$(new_repo grb-delete-failure)"
  git -C "$repo" branch fail-one
  git -C "$repo" branch z-delete-after

  cd -- "$repo"
  git() {
    if [[ "$*" == 'branch -D -- fail-one' ]]; then
      return 1
    fi
    command git "$@"
  }

  set +e
  grb >/dev/null 2>&1
  rc=$?
  set -e
  unset -f git

  [[ $rc -ne 0 ]] || fail 'grb ignored a branch deletion failure'
  assert_ref "$repo" refs/heads/fail-one
  assert_no_ref "$repo" refs/heads/z-delete-after
}

test_grw_removes_linked_worktrees() {
  local repo caller_wt detached_wt dirty_wt locked_wt rc
  repo="$(new_repo grw-remove)"
  caller_wt="$tmp_root/grw caller"
  detached_wt="$tmp_root/grw detached"
  dirty_wt="$tmp_root/grw dirty path"
  locked_wt="$tmp_root/grw locked"

  git -C "$repo" worktree add --quiet -b caller "$caller_wt"
  git -C "$repo" worktree add --quiet --detach "$detached_wt"
  git -C "$repo" worktree add --quiet -b dirty "$dirty_wt"
  printf 'dirty\n' >"$dirty_wt/untracked.txt"
  git -C "$repo" worktree add --quiet -b locked "$locked_wt"
  git -C "$repo" worktree lock --reason test "$locked_wt"

  cd -- "$caller_wt"
  set +e
  grw >/dev/null 2>&1
  rc=$?
  set -e

  [[ $rc -ne 0 ]] || fail 'grw ignored a locked worktree'
  [[ "$PWD" == "$repo" ]] || fail 'grw did not move to the primary worktree'
  [[ ! -e "$caller_wt" && ! -e "$detached_wt" && ! -e "$dirty_wt" ]] || fail 'grw left a removable linked worktree'
  [[ -d "$locked_wt" ]] || fail 'grw removed a locked worktree'
  assert_ref "$repo" refs/heads/caller
  assert_ref "$repo" refs/heads/dirty
  assert_ref "$repo" refs/heads/locked

  git -C "$repo" worktree unlock "$locked_wt"
  git -C "$repo" worktree remove --force "$locked_wt"
}

test_grw_refuses_non_main_primary() {
  local repo main_wt other_wt before rc
  repo="$(new_repo grw-refuse)"
  git -C "$repo" switch --quiet -c primary-feature
  main_wt="$tmp_root/grw refusal main"
  other_wt="$tmp_root/grw refusal other"
  git -C "$repo" worktree add --quiet "$main_wt" main
  git -C "$repo" worktree add --quiet -b other "$other_wt"
  before="$(git -C "$repo" worktree list --porcelain)"

  cd -- "$repo"
  set +e
  grw >/dev/null 2>&1
  rc=$?
  set -e

  [[ $rc -ne 0 ]] || fail 'grw accepted a non-main primary worktree'
  [[ "$(git worktree list --porcelain)" == "$before" ]] || fail 'grw changed worktrees before refusing cleanup'
}

test_grw_noop() {
  local repo output
  repo="$(new_repo grw-noop)"
  cd -- "$repo"
  output="$(grw)"
  [[ "$output" == 'grw: no non-main worktrees' ]] || fail 'grw no-op output changed'
}

test_managed_env_sources_helpers() {
  local config_dir="$tmp_root/managed config"
  mkdir -p "$config_dir"
  cp "$repo_root/scripts/wsl/env.sh" "$config_dir/env.sh"
  cp "$repo_root/scripts/shell/git-helpers.sh" "$config_dir/git-helpers.sh"

  HOME="$tmp_root/home" PATH=/usr/bin:/bin bash --noprofile --norc -c '
    source "$1/env.sh"
    declare -F grb >/dev/null
    declare -F grw >/dev/null
  ' _ "$config_dir" || fail 'managed env did not source Git helpers'
}

test_grb_from_linked_worktree
test_grb_updates_main_linked_worktree
test_grb_without_main_worktree
test_grb_refuses_ahead_main
test_grb_refuses_diverged_main
test_grb_continues_after_delete_failure
test_grw_removes_linked_worktrees
test_grw_refuses_non_main_primary
test_grw_noop
test_managed_env_sources_helpers

printf '[PASS] git helper integration tests\n'
