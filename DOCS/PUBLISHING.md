# Publishing NBJWLINK to GitHub

## Create repository

Create an **empty public repository** named `NBJWLINK` in the desired GitHub account. Do not initialise it with a GitHub-generated README, `.gitignore` or alternate licence: this package already contains all three.

## Upload source

Extract the GitHub source ZIP so the resulting `NBJWLINK` directory directly contains `README.md`, `MAKE.CMD`, `SOURCE/` and `BIN/`.

With **Git** installed on your own PC, open a terminal in that `NBJWLINK` folder and run:

```cmd
git --version
git init
git branch -M main
git add .
git status --short
git commit -m "NBJWLINK 0.0.9 initial release"
git remote add origin https://github.com/techdistractions/NBJWLINK.git
git push -u origin main
```

You may need GitHub authentication when pushing. If Git reports that it does not know your name/email, configure `git config --global user.name` and `git config --global user.email` and rerun the commit. Change the remote URL if publishing from a different account. `BUILD/`, `OUTPUT/` and `LOGS/` are ignored; `BIN/NBJWLINK.EXE` and `BOOTSTRAP/JWlink.exe` are intentionally tracked. Verify `git status --short` before committing. Do not upload the original `JLINK.zip` or any `TOOLS/OW_PORTABLE` directory.

**Validation update:** Maintainer confirmed the external Open Watcom build, 5/5 audit, and Windows 1.01 GUI smoke test on 17 November 2026. The repository binary is still the **archived** 0.0.9 distribution build unless the locally rebuilt `BUILD/NBJWLINK.EXE` has been explicitly compared and promoted to `BIN/`. When promoting a new binary, update the release-notes SHA-256 and `DOCS/MANIFEST.sha256` before publication.

## Release binary

On GitHub, select **Releases > Draft a new release**; tag **`v0.0.9`** and attach the separate `NBJWLINK_0.0.9_WIN32_20261117.zip` distribution asset. Paste the contents of `RELEASE_NOTES.md` in the description and publish. No compiler binaries are required.

To regenerate a binary asset from `BIN/NBJWLINK.EXE` after future changes, run the repository's `PACKAGE_RELEASE.ps1` on Windows.
