# dotfiles

xaicron's dotfiles: shell, editor, and git settings, plus small CLI tools written in Go.

## Requirements

- [mise](https://mise.jdx.dev/) (manages Go and [Task](https://taskfile.dev/))

## Setup

```sh
git clone git@github.com:xaicron/dotfiles.git
cd dotfiles
mise install      # installs the Go and task versions pinned in mise.toml
task install      # builds the tools into bin/ and symlinks the dotfiles into $HOME
```

If a file with the same name already exists in `$HOME`, you are asked whether to show a diff and whether to overwrite it.
To overwrite without asking:

```sh
task install -- --force
```

Existing symlinks are left as they are.

## What gets linked

- Every entry at the repository root whose name starts with `.` (except `.git`, `.gitignore`, `.gitmodules`, and a few others)
- `bin/` (`$HOME/bin` is added to `PATH` in `.zshrc`)
- `claude/CLAUDE.md` → `~/.claude/CLAUDE.md` (global instructions for Claude Code; `~/.claude` itself stays a real directory)

See `internal/link/link.go` for the exact rules.

## Tasks

| Command | Description |
| --- | --- |
| `task` | List tasks |
| `task setup` | Install the tools with mise |
| `task install` | Build + create symlinks |
| `task link` | Create symlinks only |
| `task build` | Build the Go tools into `bin/` |
| `task test` | Run the tests |
| `task lint` | `gofmt` / `go vet` checks |
| `task fmt` | Format with `gofmt` |
| `task tidy` | `go mod tidy` |
| `task clean` | Remove the binaries built into `bin/` |

## Tools in bin/

### Written in Go (`cmd/`, built with `task build`)

| Command | Description |
| --- | --- |
| `git gh-url` | Convert `remote.origin.url` to a GitHub https URL |
| `git url-from-file [-o] <file> [start [end]]` | Show a file's GitHub URL (with `-o`, open it in the browser) |
| `git url-from-hash [-o] <commit>` | Show a commit's GitHub URL |
| `uri_escape [-u] [-c] [-d] <url>` | URI escape (`-u` unescape, `-c` canonicalize, `-d` dump the query as JSON) |
| `punzip [-f <enc>] [-t <enc>] <file>` | Extract a zip while converting file-name encodings (e.g. `-f cp932`); supports password-protected zips |
| `m4a_durations <dir>` | List the duration of each `.m4a` file in milliseconds (requires ffprobe) |

### Shell scripts

| Command | Description |
| --- | --- |
| `format_failed_tests` | Extract failed test file names from `prove` output |
| `git rename-tag <old> <new>` | Rename a tag (and push it to the remote) |
| `osx_dns_refresh` | Flush the macOS DNS cache |
