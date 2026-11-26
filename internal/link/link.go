// Package link は dotfiles リポジトリ内のファイルを $HOME へシンボリックリンクする。
package link

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"
)

// excluded はリンク対象外のドットファイル。
var excluded = map[string]bool{
	".git":        true,
	".gitignore":  true,
	".gitmodules": true,
	".task":       true,
	".claude":     true,
	".DS_Store":   true,
}

// extra はドットで始まらないがリンク対象にするエントリ。
var extra = map[string]bool{
	"bin": true,
}

// nested はリポジトリ内のパスと、$HOME 以下のリンク先パスの組。
// $HOME 側のディレクトリ (~/.claude など) 自体はリンクせず、その中の 1 ファイルだけをリンクする。
var nested = []struct{ from, to string }{
	{"claude/CLAUDE.md", ".claude/CLAUDE.md"},
}

// permissions はリンク後にパーミッションを変更するファイル。
var permissions = map[string]os.FileMode{
	".pause": 0o600,
}

// Linker は Src 内の dotfiles を Dst にリンクする。
type Linker struct {
	Src   string // dotfiles リポジトリのパス
	Dst   string // リンクの作成先 (通常は $HOME)
	Force bool   // 確認せずに上書きする

	In  io.Reader
	Out io.Writer
	Err io.Writer

	in *bufio.Reader
}

// Targets は Src のうちリンク対象となるエントリ名をソートして返す。
func Targets(src string) ([]string, error) {
	entries, err := os.ReadDir(src)
	if err != nil {
		return nil, err
	}
	var names []string
	for _, e := range entries {
		name := e.Name()
		if excluded[name] {
			continue
		}
		if strings.HasPrefix(name, ".") || extra[name] {
			names = append(names, name)
		}
	}
	sort.Strings(names)
	return names, nil
}

// Run はリンクを作成する。
func (l *Linker) Run() error {
	l.in = bufio.NewReader(l.In)

	src, err := filepath.Abs(l.Src)
	if err != nil {
		return err
	}
	if err := os.MkdirAll(filepath.Join(l.Dst, ".vim-backup"), 0o755); err != nil {
		return err
	}

	names, err := Targets(src)
	if err != nil {
		return err
	}
	for _, name := range names {
		if err := l.link(filepath.Join(src, name), filepath.Join(l.Dst, name)); err != nil {
			return fmt.Errorf("%s: %w", name, err)
		}
	}
	for _, n := range nested {
		from := filepath.Join(src, filepath.FromSlash(n.from))
		if _, err := os.Stat(from); os.IsNotExist(err) {
			continue
		}
		to := filepath.Join(l.Dst, filepath.FromSlash(n.to))
		if err := os.MkdirAll(filepath.Dir(to), 0o755); err != nil {
			return err
		}
		if err := l.link(from, to); err != nil {
			return fmt.Errorf("%s: %w", n.to, err)
		}
	}
	fmt.Fprintln(l.Out, "done.")
	return nil
}

func (l *Linker) link(from, to string) error {
	name := filepath.Base(to)

	fi, err := os.Lstat(to)
	switch {
	case err == nil && fi.Mode()&os.ModeSymlink != 0:
		// 既にシンボリックリンクなら何もしない
		return nil
	case err == nil:
		if !l.Force {
			if l.ask(yellow, fmt.Sprintf("want diff ? %s [y/n] : ", name)) {
				l.diff(to, from)
			}
			if !l.ask(red, fmt.Sprintf("override ? %s [y/n] : ", name)) {
				return nil
			}
		}
		if err := os.RemoveAll(to); err != nil {
			return err
		}
	case !os.IsNotExist(err):
		return err
	}

	if err := os.Symlink(from, to); err != nil {
		return err
	}
	if mode, ok := permissions[name]; ok {
		if err := os.Chmod(from, mode); err != nil {
			return err
		}
	}
	return nil
}

func (l *Linker) diff(a, b string) {
	cmd := exec.Command("diff", "-u", a, b)
	cmd.Stdout = l.Out
	cmd.Stderr = l.Err
	_ = cmd.Run() // 差分があると exit 1 になるため無視する
}

const (
	yellow = "\x1b[1;33m"
	red    = "\x1b[1;31m"
	reset  = "\x1b[0m"
)

func (l *Linker) ask(color, msg string) bool {
	fmt.Fprint(l.Out, color+msg+reset)
	line, _ := l.in.ReadString('\n')
	return strings.ContainsAny(line, "yY")
}
