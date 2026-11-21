// uri_escape は URI をエスケープ・アンエスケープする。
//
//	uri_escape [-u|--unescape] [-c|--canonical] [-d|--dump-query] <url>
package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/xaicron/dotfiles/internal/uriescape"
)

func main() {
	var unescape, canonical, dumpQuery bool
	flag.BoolVar(&unescape, "unescape", false, "URI をアンエスケープする")
	flag.BoolVar(&unescape, "u", false, "--unescape の短縮形")
	flag.BoolVar(&canonical, "canonical", false, "URI を正規化する")
	flag.BoolVar(&canonical, "c", false, "--canonical の短縮形")
	flag.BoolVar(&dumpQuery, "dump-query", false, "クエリパラメータを JSON で表示する")
	flag.BoolVar(&dumpQuery, "d", false, "--dump-query の短縮形")
	flag.Usage = func() {
		fmt.Fprintln(flag.CommandLine.Output(), "Usage: uri_escape [-u|--unescape] [-c|--canonical] [-d|--dump-query] <url>")
		flag.PrintDefaults()
	}
	flag.Parse()
	if flag.NArg() < 1 {
		flag.Usage()
		os.Exit(2)
	}

	if err := run(flag.Arg(0), unescape, canonical, dumpQuery); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func run(url string, unescape, canonical, dumpQuery bool) error {
	var err error
	if unescape {
		if url, err = uriescape.Unescape(url); err != nil {
			return err
		}
	}
	if canonical {
		if url, err = uriescape.Canonical(url); err != nil {
			return err
		}
	}

	if dumpQuery {
		base, query, err := uriescape.DumpQuery(url)
		if err != nil {
			return err
		}
		fmt.Println(base)
		fmt.Println(query)
		return nil
	}

	if !unescape {
		url = uriescape.Escape(url)
	}
	fmt.Println(url)
	return nil
}
