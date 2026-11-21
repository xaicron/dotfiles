// punzip はファイル名の文字コードを変換しながら ZIP をカレントディレクトリに展開する。
//
//	punzip [-f|--from <encoding>] [-t|--to <encoding>] <file>
package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/xaicron/dotfiles/internal/punzip"
	"github.com/yeka/zip"
	"golang.org/x/term"
)

func main() {
	var from, to string
	flag.StringVar(&from, "from", "utf8", "ZIP 内のファイル名の文字コード (例 cp932)")
	flag.StringVar(&from, "f", "utf8", "--from の短縮形")
	flag.StringVar(&to, "to", "utf8", "展開後のファイル名の文字コード")
	flag.StringVar(&to, "t", "utf8", "--to の短縮形")
	flag.Usage = func() {
		fmt.Fprintln(flag.CommandLine.Output(), "Usage: punzip [-f|--from <encoding>] [-t|--to <encoding>] <file>")
		flag.PrintDefaults()
	}
	flag.Parse()
	if flag.NArg() != 1 {
		flag.Usage()
		os.Exit(2)
	}

	if err := run(flag.Arg(0), from, to); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func run(file, from, to string) error {
	fromEnc, err := punzip.LookupEncoding(from)
	if err != nil {
		return err
	}
	toEnc, err := punzip.LookupEncoding(to)
	if err != nil {
		return err
	}

	r, err := zip.OpenReader(file)
	if err != nil {
		return fmt.Errorf("%s read failed: %w", file, err)
	}
	defer r.Close()

	e := &punzip.Extractor{
		Dest:     ".",
		From:     fromEnc,
		To:       toEnc,
		Password: readPassword,
		Out:      os.Stdout,
	}
	return e.Extract(&r.Reader)
}

func readPassword() (string, error) {
	fmt.Fprint(os.Stderr, "password: ")
	defer fmt.Fprintln(os.Stderr)
	b, err := term.ReadPassword(int(os.Stdin.Fd()))
	return string(b), err
}
