// git-url-from-hash はコミットの GitHub URL を表示する。
//
//	git url-from-hash [-o|--open] <commit>
package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/xaicron/dotfiles/internal/gitutil"
)

func main() {
	var open bool
	flag.BoolVar(&open, "open", false, "URL を open コマンドで開く (macOS)")
	flag.BoolVar(&open, "o", false, "--open の短縮形")
	flag.Usage = func() {
		fmt.Fprintln(flag.CommandLine.Output(), "Usage: git url-from-hash [-o|--open] <commit>")
		flag.PrintDefaults()
	}
	flag.Parse()
	if flag.NArg() < 1 {
		flag.Usage()
		os.Exit(2)
	}

	if err := run(flag.Arg(0), open); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func run(rev string, open bool) error {
	hash, err := gitutil.Git("rev-parse", rev)
	if err != nil {
		return err
	}
	remote, err := gitutil.RemoteURL()
	if err != nil {
		return err
	}
	url := gitutil.CommitURL(remote, hash)
	if open {
		return gitutil.Open(url)
	}
	fmt.Println(url)
	return nil
}
