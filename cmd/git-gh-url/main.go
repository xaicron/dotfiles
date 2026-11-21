// git-gh-url は remote.origin.url を GitHub の https URL に変換して表示する。
//
//	git gh-url
package main

import (
	"fmt"
	"os"

	"github.com/xaicron/dotfiles/internal/gitutil"
)

func main() {
	url, err := gitutil.RemoteURL()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Println(url)
}
