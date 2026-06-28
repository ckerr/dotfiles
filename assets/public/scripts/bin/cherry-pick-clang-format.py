#!/usr/bin/env python3
"""Cherry-pick a commit across a clang-format style change.

The commit's diff is re-expressed against a base reformatted with *this*
branch's clang-format config, so it applies cleanly even when whitespace/brace
rules differ between branches. Original author and message are preserved.

Usage: cherry-pick-clang-format <commit>
"""

import argparse
import os
import shutil
import subprocess
import sys
import tempfile

# clang-format-22 is preferred; the repo targets version 22 (see code_style.sh).
CLANG_FORMAT_EXES = ("clang-format-22", "clang-format")
FORMATTABLE = (".c", ".cc", ".cpp", ".cxx", ".h", ".hh", ".hpp", ".m", ".mm")


def git(*args, cwd, check=True, capture=True):
    p = subprocess.run(
        ["git", *args],
        cwd=cwd,
        text=True,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.PIPE if capture else None,
    )
    if check and p.returncode != 0:
        sys.exit(f"git {' '.join(args)} failed:\n{p.stderr or ''}")
    return p


def find_clang_format():
    for name in CLANG_FORMAT_EXES:
        path = shutil.which(name)
        if path:
            return path
    sys.exit("error: clang-format not found")


def formattable_files(root, commit):
    out = git("diff-tree", "--no-commit-id", "--name-only", "-r", commit, cwd=root).stdout
    return [f for f in out.splitlines() if f.endswith(FORMATTABLE)]


def reformat(worktree, ref, files, clang_format, config):
    """Check out ref in worktree, force the new config, clang-format, commit."""
    git("checkout", "--detach", "--force", ref, cwd=worktree)
    shutil.copyfile(config, os.path.join(worktree, ".clang-format"))
    present = [f for f in files if os.path.exists(os.path.join(worktree, f))]
    if present:
        subprocess.run([clang_format, "-i", *present], cwd=worktree, check=True)
    git("add", "-A", cwd=worktree)
    git("-c", "user.name=cpcf", "-c", "user.email=cpcf@local", "-c", "commit.gpgsign=false",
        "commit", "--no-verify", "--allow-empty", "-m", "tmp", cwd=worktree)
    return git("rev-parse", "HEAD", cwd=worktree).stdout.strip()


def main():
    ap = argparse.ArgumentParser(description="Cherry-pick across a clang-format style change.")
    ap.add_argument("commit", help="commit to cherry-pick")
    args = ap.parse_args()

    root = git("rev-parse", "--show-toplevel", cwd=".").stdout.strip()
    commit = git("rev-parse", "--verify", f"{args.commit}^{{commit}}", cwd=root).stdout.strip()
    files = formattable_files(root, commit)
    if not files:
        sys.exit("error: commit touches no clang-format-able files; use a plain cherry-pick")

    clang_format = find_clang_format()
    cfg = tempfile.NamedTemporaryFile(prefix="clang-format-", delete=False)
    cfg.close()
    git("show", "HEAD:.clang-format", cwd=root, capture=True).stdout  # ensure it exists
    with open(cfg.name, "w") as fh:
        fh.write(git("show", "HEAD:.clang-format", cwd=root).stdout)

    work = tempfile.mkdtemp(prefix="cpcf-")
    wt = os.path.join(work, "wt")
    git("worktree", "add", "--detach", "--force", wt, f"{commit}^", cwd=root)
    try:
        base = reformat(wt, f"{commit}^", files, clang_format, cfg.name)
        pick = reformat(wt, commit, files, clang_format, cfg.name)
        patch = git("diff", base, pick, cwd=root).stdout
        if not patch.strip():
            sys.exit("error: empty patch after normalization; nothing to apply")
        apply = subprocess.run(
            ["git", "apply", "--3way", "--index"], cwd=root,
            input=patch, text=True,
        )
        if apply.returncode != 0:
            sys.exit("conflicts remain; resolve, then: git commit -C " + commit)
        git("commit", "-C", commit, cwd=root, capture=False)
        print("done.")
    finally:
        git("worktree", "remove", "--force", wt, cwd=root, check=False)
        git("worktree", "prune", cwd=root, check=False)
        shutil.rmtree(work, ignore_errors=True)
        os.unlink(cfg.name)


if __name__ == "__main__":
    main()
