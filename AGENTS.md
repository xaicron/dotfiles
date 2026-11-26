# AGENTS.md

Guidelines for AI coding agents working in this repository.

## Overview

- A dotfiles repository. Files at the root that start with `.` and `bin/` are symlinked into `$HOME`.
- The installer and the CLI tools are written in Go (the old Perl versions have been removed). Do not add new Perl scripts.
- mise manages the toolchain (`mise.toml`). Run commands through Task (`Taskfile.yml`).

## Layout

```
cmd/<name>/        main package for each command (keep it thin)
  symlink/         installer that symlinks the dotfiles into $HOME (not built into bin/)
  git-gh-url/ ...  tools built into bin/
internal/<pkg>/    logic and tests (link, gitutil, uriescape, punzip)
claude/CLAUDE.md   global Claude Code instructions (linked to ~/.claude/CLAUDE.md)
bin/               shell scripts + Go binaries built by task build (binaries are gitignored)
.zsh*, .vim*, ...  dotfiles themselves
```

## Commands

```sh
mise install   # install Go / task
task build     # build into bin/
task test      # go test ./...
task lint      # gofmt -l + go vet
task fmt       # gofmt -w
```

After making a change, make sure `task lint` and `task test` both pass.

## Rules

- When you add a tool:
  1. Create `cmd/<name>/main.go` (put logic you want to test in `internal/`).
  2. Add `<name>` to `TOOLS` in `Taskfile.yml`.
  3. Add `/bin/<name>` to `.gitignore`.
  4. Add it to the tool list in `README.md`.
- Use only the standard library `flag` for option parsing. Define a long form (`--open`) and a short form (`-o`) as separate flags bound to the same variable.
- Keep dependencies to a minimum (currently `github.com/yeka/zip`, `golang.org/x/text`, and `golang.org/x/term` only).
- Files that `task install` must not link into `$HOME` (project files such as `go.mod`, `cmd/`, `README.md`) are excluded because their names do not start with `.`. If you add a new dot-prefixed project file (for example a CI config), add it to `excluded` in `internal/link/link.go`.
- To link a single file inside a directory under `$HOME` (such as `~/.claude/CLAUDE.md`) without linking the directory itself, add it to `nested` in `internal/link/link.go`.
- To bump the Go / task version, update `mise.toml` (the `go` directive in `go.mod` should also match).
- Do not run `task install` against the real `$HOME` in tests or verification. Point `HOME` at a temporary directory instead (`HOME=$(mktemp -d) go run ./cmd/symlink --dir . -f`).
