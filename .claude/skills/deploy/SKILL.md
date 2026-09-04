---
name: deploy
description: Commit any pending changes, sync projekttabelle.html from its md sources, publish the site (index.html, projekttabelle/) to the public amarow/bosa-vision repo via deploy.sh, and push the working branch to origin — all in one step. Use when the user asks to "deploy", "veröffentlichen", "commit und deploy", "commit and publish", or similar for this project.
---

# Commit + Deploy (bosa-vision)

Combines two steps the user used to do separately into one: commit whatever is
pending in this private working repo, then run `deploy.sh` to publish the public
pages to the public `amarow/bosa-vision` GitHub repo (GitHub Pages).

**This pushes to a public, externally visible repository** (that's what `deploy.sh`
does at its last step). That is the whole point of this skill — the user asked for
commit+deploy in one step specifically so they don't have to confirm it every time.
Still, always summarize afterward exactly what was committed and pushed, including
the new version number, so it's transparent after the fact.

## Steps

1. Check whether `projekttabelle/*.md` (the German source files, format described
   in `projekttabelle/README.md`) are in sync with the `rows` array in
   `projekttabelle/projekttabelle.html`. If any entry was added, changed, or
   removed in the `.md` files but not yet reflected in `projekttabelle.html`,
   translate those changes into `projekttabelle.html` now (EN/IT, same as the
   existing rows) before continuing — this always runs as part of deploy, not
   just on explicit request. If genuinely ambiguous how to translate a German
   phrase, ask; otherwise just do it.
2. `git status` in the repo root. If there are uncommitted changes relevant to the
   site (not stray scratch files) — including the `projekttabelle.html` sync from
   step 1 — stage them with `git add` and commit with a concise, descriptive
   message following this repo's existing style (check `git log` for
   tone/format) — end it with the standard Co-Authored-By / Claude-Session
   footer from the current session's attribution instructions. Skip this step if
   the working tree is already clean.
3. Version bump level: use what the user specified this turn; if they didn't say,
   default to a plain patch bump (i.e. run `./deploy.sh` with no version flags) —
   don't stop to ask unless they've indicated they care.
4. Run `./deploy.sh [flags]` from the repo root (`--minor` / `--major` / an explicit
   `X.Y.Z` / `--no-bump`, only if requested). This will, on its own:
   - bump + commit the version tag in `index.html` and
     `projekttabelle/projekttabelle.html` (its own separate commit, in this
     private repo),
   - clone the public `amarow/bosa-vision` repo into a temp dir,
   - copy `index.html` and `projekttabelle/` into it,
   - commit and push that to the public repo's default branch.
5. Push the current working branch to `origin` (`git push`, or `git push -u origin
   <branch>` if it has no upstream yet) so the private working-repo commits from
   steps 1–2 (plus any earlier ones already sitting locally) land on GitHub too.
6. Report back: what got committed locally in steps 1–2 (if anything), the new
   version number from step 4, confirmation the public push (step 4) succeeded
   (or the exact error if it didn't), and confirmation of the branch push (step 5).

## Notes

- Two separate pushes happen here: `deploy.sh` pushes the **public site content**
  (`index.html`, `projekttabelle/`) straight to `main` of the public
  `amarow/bosa-vision` repo (bypassing this branch); step 5 separately pushes
  the **working branch itself** (with full history/other files) to `origin` on
  that same GitHub repo. Both now happen on every deploy, per the user's
  standing preference — no need to ask each time.
- If `deploy.sh` prints "Keine Änderungen feststellbar." that's a normal no-op
  (the public repo already matched), not an error.
- `deploy.sh` requires a clean-enough working tree feel for its own commit step
  (it runs `git add` + `git commit` on the version files) — the local commit in
  step 1 should already have taken care of everything else, so this is normally
  a non-issue.
