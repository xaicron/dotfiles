// Package punzip はファイル名の文字コードを変換しながら ZIP を展開する。
package punzip

import (
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"

	"github.com/yeka/zip"
	"golang.org/x/text/encoding"
	"golang.org/x/text/encoding/htmlindex"
	"golang.org/x/text/encoding/ianaindex"
	"golang.org/x/text/encoding/unicode"
)

// aliases は Perl の Encode などで使われる名前を WHATWG のラベルに対応付ける。
var aliases = map[string]string{
	"utf8":      "utf-8",
	"cp932":     "windows-31j",
	"shiftjis":  "shift_jis",
	"sjis":      "shift_jis",
	"eucjp":     "euc-jp",
	"iso2022jp": "iso-2022-jp",
}

// LookupEncoding は名前から文字コードを探す。
func LookupEncoding(name string) (encoding.Encoding, error) {
	key := strings.ToLower(name)
	if alias, ok := aliases[strings.ReplaceAll(key, "-", "")]; ok {
		key = alias
	}
	if e, err := htmlindex.Get(key); err == nil {
		return e, nil
	}
	if e, err := ianaindex.IANA.Encoding(key); err == nil && e != nil {
		return e, nil
	}
	return nil, fmt.Errorf("unknown encoding: %s", name)
}

// ConvertName はファイル名を from から to の文字コードに変換する。
func ConvertName(name string, from, to encoding.Encoding) (string, error) {
	if from != unicode.UTF8 {
		s, err := from.NewDecoder().String(name)
		if err != nil {
			return "", err
		}
		name = s
	}
	if to != unicode.UTF8 {
		s, err := to.NewEncoder().String(name)
		if err != nil {
			return "", err
		}
		name = s
	}
	return name, nil
}

// SafePath は dest 配下に収まる展開先パスを返す。dest の外を指す名前はエラーにする。
func SafePath(dest, name string) (string, error) {
	name = strings.ReplaceAll(name, `\`, "/")
	if filepath.IsAbs(name) || !filepath.IsLocal(filepath.FromSlash(name)) {
		return "", fmt.Errorf("unsafe path in archive: %q", name)
	}
	return filepath.Join(dest, filepath.FromSlash(name)), nil
}

// Extractor は ZIP を展開する。
type Extractor struct {
	Dest     string                 // 展開先ディレクトリ
	From, To encoding.Encoding      // ファイル名の変換元・変換先の文字コード
	Password func() (string, error) // 暗号化されたエントリがあったときに一度だけ呼ばれる
	Out      io.Writer

	password *string
}

// Extract は r のすべてのエントリを展開する。既に存在するファイルはスキップする。
func (e *Extractor) Extract(r *zip.Reader) error {
	for _, f := range r.File {
		if err := e.extract(f); err != nil {
			return err
		}
	}
	return nil
}

func (e *Extractor) extract(f *zip.File) error {
	name, err := ConvertName(f.Name, e.From, e.To)
	if err != nil {
		return fmt.Errorf("%q: %w", f.Name, err)
	}
	path, err := SafePath(e.Dest, name)
	if err != nil {
		return err
	}

	if f.FileInfo().IsDir() {
		return os.MkdirAll(path, 0o755)
	}
	if _, err := os.Lstat(path); err == nil {
		fmt.Fprintf(e.Out, "exists %s\n", name)
		return nil
	}

	if f.IsEncrypted() {
		if e.password == nil {
			if e.Password == nil {
				return errors.New("archive is encrypted")
			}
			p, err := e.Password()
			if err != nil {
				return err
			}
			e.password = &p
		}
		f.SetPassword(*e.password)
	}

	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}
	if err := writeFile(f, path); err != nil {
		return fmt.Errorf("%s: %w", name, err)
	}
	return nil
}

func writeFile(f *zip.File, path string) (err error) {
	rc, err := f.Open()
	if err != nil {
		return err
	}
	defer rc.Close()

	mode := f.Mode().Perm()
	if mode == 0 {
		mode = 0o644
	}
	out, err := os.OpenFile(path, os.O_WRONLY|os.O_CREATE|os.O_EXCL, mode)
	if err != nil {
		return err
	}
	defer func() {
		if cerr := out.Close(); err == nil {
			err = cerr
		}
		if err != nil {
			os.Remove(path) // 書きかけのファイルを残さない
		}
	}()
	_, err = io.Copy(out, rc)
	return err
}
