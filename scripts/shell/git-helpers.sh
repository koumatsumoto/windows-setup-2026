#!/usr/bin/env bash

# Update main by fast-forward, then delete merged local branches that are not
# checked out in any worktree.
grb() {
  local main_wt branch
  local rc=0

  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "grb: not inside a Git worktree" >&2
    return 1
  }

  git show-ref --verify --quiet refs/heads/main || {
    echo "grb: local branch 'main' does not exist" >&2
    return 1
  }

  git fetch origin main || return 1

  git show-ref --verify --quiet refs/remotes/origin/main || {
    echo "grb: remote-tracking branch 'origin/main' does not exist" >&2
    return 1
  }

  if ! git merge-base --is-ancestor main origin/main; then
    echo "grb: local main cannot be fast-forwarded to origin/main" >&2
    return 1
  fi

  main_wt="$(git for-each-ref \
    --format='%(worktreepath)' \
    refs/heads/main
  )"

  if [[ -n "$main_wt" ]]; then
    git -C "$main_wt" merge --ff-only origin/main || return 1
  else
    git branch -f main origin/main || return 1
  fi

  while IFS= read -r branch; do
    [[ -z "$branch" || "$branch" == main ]] && continue

    if ! git branch -D -- "$branch"; then
      rc=1
    fi
  done < <(
    git for-each-ref \
      --merged=main \
      --format='%(if)%(worktreepath)%(then)%(else)%(refname:short)%(end)' \
      refs/heads/
  )

  return "$rc"
}

# Keep the primary main worktree and remove every linked worktree. Local branch
# refs remain available for a later grb cleanup.
grw() {
  local field wt branch primary_wt primary_branch
  local first_record=1 rc=0
  local -a worktrees=()

  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "grw: not inside a Git worktree" >&2
    return 1
  }

  wt=
  branch=

  while IFS= read -r -d '' field; do
    if [[ -z "$field" ]]; then
      if [[ -n "$wt" ]]; then
        if (( first_record )); then
          primary_wt="$wt"
          primary_branch="$branch"
          first_record=0
        else
          worktrees+=("$wt")
        fi
      fi

      wt=
      branch=
      continue
    fi

    case "$field" in
      'worktree '*) wt="${field#worktree }" ;;
      'branch '*) branch="${field#branch }" ;;
    esac
  done < <(git worktree list --porcelain -z)

  if [[ -z "$primary_wt" ]]; then
    echo "grw: could not determine the primary worktree" >&2
    return 1
  fi

  if [[ "$primary_branch" != refs/heads/main ]]; then
    echo "grw: primary worktree is not on 'main'; refusing cleanup" >&2
    echo "grw: primary worktree: $primary_wt" >&2
    return 1
  fi

  if (( ${#worktrees[@]} == 0 )); then
    echo "grw: no non-main worktrees"
    return 0
  fi

  cd -- "$primary_wt" || return 1

  for wt in "${worktrees[@]}"; do
    printf 'Removing worktree: %s\n' "$wt"

    if ! git worktree remove --force -- "$wt"; then
      rc=1
    fi
  done

  return "$rc"
}
