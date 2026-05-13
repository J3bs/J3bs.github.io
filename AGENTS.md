# Project Rules

## Auto Publish Requirement

For any change made in this repository, publish the updated site artifacts to the GitHub Pages repository immediately after changes are complete.

Use this command from the repo root:

```powershell
.\publish-to-github-pages.ps1 -SourcePath "C:\git\j3-branding" -DestinationPath "C:\git\J3bs.github.io"
```

Required behavior:

1. Run the helper script after edits are finalized.
2. If push is rejected because remote is ahead, run:

```powershell
git -C C:\git\J3bs.github.io pull --rebase origin main
git -C C:\git\J3bs.github.io push origin main
```

3. Report the publish commit SHA from `C:\git\J3bs.github.io` in the final update.
