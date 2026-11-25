# Contributing to CHIMERA

Fixes, measurements and test reports are welcome from anyone — you do not need to be added to the project.

## Send a fix (pull request)

1. Press **Fork** at the top of https://github.com/LukaManstein/CHIMERA (you get your own copy).
2. Clone **your** fork and branch off `next-nvidia` (the newest build):
   ```bat
   git clone https://github.com/<you>/CHIMERA.git
   cd CHIMERA
   git checkout -b my-fix origin/next-nvidia
   ```
3. Commit, then push to your fork: `git push origin my-fix`.
4. On GitHub, open a **pull request** into `LukaManstein/CHIMERA`, base branch **`next-nvidia`**.
   The form asks what you tested and on which card.

Pushing straight to `LukaManstein/CHIMERA` does not work for anyone but the maintainer: always go through your fork.

## No Git? Send a patch

Open an issue with **"Contribute a fix / patch"** and attach your `.patch` / `.diff` file
(`git format-patch -1`, or `git diff > my-fix.patch`). It will be applied with you as the author.

## What helps a fix get in quickly

- What it fixes, and how you checked it: a log line, a count (for example "shaders that do not translate: 208 → 197"),
  frame times, a screenshot or a short recording.
- Your card, driver, Windows version and the branch/commit you started from.
- Keep each change behind a `VICTORY_*` switch when it might hurt other cards.
- Credit where code comes from (another fork's commit, an upstream PR). Every commit keeps its author.

## Never

- Game files, keys, executables, saves of other people, or links to any of them — in code, issues, comments or recordings.
