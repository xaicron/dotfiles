// git-url-from-file はファイルの GitHub URL を表示する。
//
//	git url-from-file [-o|--open] <file> [line-start [line-end]]
package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/xaicron/dotfiles/internal/gitutil"
)

func main() {
	var open bool
	flag.BoolVar(&open, "open", false, "URL を open コマンドで開く (macOS)")
	flag.BoolVar(&open, "o", false, "--open の短縮形")
	flag.Usage = func() {
		fmt.Fprintln(flag.CommandLine.Output(), "Usage: git url-from-file [-o|--open] <file> [line-start [line-end]]")
		flag.PrintDefaults()
	}
	flag.Parse()
	if flag.NArg() < 1 {
		flag.Usage()
		os.Exit(2)
	}

	if err := run(flag.Arg(0), flag.Arg(1), flag.Arg(2), open); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func run(file, lineStart, lineEnd string, open bool) error {
	path, err := realpath(file)
	if err != nil {
		return err
	}
	remote, err := gitutil.RemoteURL()
	if err != nil {
		return err
	}
	ref, err := gitutil.Git("symbolic-ref", "HEAD")
	if err != nil {
		return err
	}
	branch := strings.TrimPrefix(ref, "refs/heads/")

	top, err := gitutil.Git("rev-parse", "--show-toplevel")
	if err != nil {
		return err
	}
	if top, err = realpath(top); err != nil {
		return err
	}
	rel, err := filepath.Rel(top, path)
	if err != nil {
		return err
	}

	url := gitutil.FileURL(remote, branch, rel, lineStart, lineEnd)
	if open {
		return gitutil.Open(url)
	}
	fmt.Println(url)
	return nil
}

func realpath(path string) (string, error) {
	abs, err := filepath.Abs(path)
	if err != nil {
		return "", err
	}
	return filepath.EvalSymlinks(abs)
}
