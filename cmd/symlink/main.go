// symlink は dotfiles を $HOME にシンボリックリンクする。
//
//	symlink [--dir <dotfiles>] [--force] [--help]
package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/xaicron/dotfiles/internal/link"
)

func main() {
	var (
		dir   string
		force bool
	)
	flag.StringVar(&dir, "dir", ".", "dotfiles リポジトリのパス")
	flag.BoolVar(&force, "force", false, "確認せずに既存ファイルを上書きする")
	flag.BoolVar(&force, "f", false, "--force の短縮形")
	flag.Usage = func() {
		fmt.Fprintln(flag.CommandLine.Output(), "Usage: symlink [--dir <dotfiles>] [-f|--force]")
		flag.PrintDefaults()
	}
	flag.Parse()

	home := os.Getenv("HOME")
	if home == "" {
		fmt.Fprintln(os.Stderr, "$HOME not set")
		os.Exit(1)
	}

	l := &link.Linker{
		Src:   dir,
		Dst:   home,
		Force: force,
		In:    os.Stdin,
		Out:   os.Stdout,
		Err:   os.Stderr,
	}
	if err := l.Run(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
