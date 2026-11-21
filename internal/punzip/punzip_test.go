package punzip

import (
	"bytes"
	"io"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/yeka/zip"
	"golang.org/x/text/encoding/japanese"
	"golang.org/x/text/encoding/unicode"
)

func TestLookupEncoding(t *testing.T) {
	for _, name := range []string{"utf8", "UTF-8", "cp932", "shiftjis", "Shift_JIS", "euc-jp", "eucJP"} {
		if _, err := LookupEncoding(name); err != nil {
			t.Errorf("LookupEncoding(%q): %v", name, err)
		}
	}
	if _, err := LookupEncoding("no-such-encoding"); err == nil {
		t.Error("LookupEncoding should fail for unknown encoding")
	}
}

func TestSafePath(t *testing.T) {
	dest := t.TempDir()
	for _, name := range []string{"a.txt", "dir/a.txt", `dir\a.txt`} {
		if _, err := SafePath(dest, name); err != nil {
			t.Errorf("SafePath(%q): %v", name, err)
		}
	}
	for _, name := range []string{"../a.txt", "dir/../../a.txt", "/etc/passwd", `..\a.txt`} {
		if _, err := SafePath(dest, name); err == nil {
			t.Errorf("SafePath(%q) should fail", name)
		}
	}
}

type entry struct {
	name, body string
}

func makeZip(t *testing.T, password string, entries []entry) *zip.Reader {
	t.Helper()
	var buf bytes.Buffer
	w := zip.NewWriter(&buf)
	for _, e := range entries {
		var (
			fw  io.Writer
			err error
		)
		if password != "" {
			fw, err = w.Encrypt(e.name, password, zip.StandardEncryption)
		} else {
			fw, err = w.Create(e.name)
		}
		if err != nil {
			t.Fatal(err)
		}
		if _, err := io.WriteString(fw, e.body); err != nil {
			t.Fatal(err)
		}
	}
	if err := w.Close(); err != nil {
		t.Fatal(err)
	}
	r, err := zip.NewReader(bytes.NewReader(buf.Bytes()), int64(buf.Len()))
	if err != nil {
		t.Fatal(err)
	}
	return r
}

func readFile(t *testing.T, path string) string {
	t.Helper()
	b, err := os.ReadFile(path)
	if err != nil {
		t.Fatal(err)
	}
	return string(b)
}

func TestExtractShiftJIS(t *testing.T) {
	sjisName, err := japanese.ShiftJIS.NewEncoder().String("日本語/ファイル.txt")
	if err != nil {
		t.Fatal(err)
	}
	r := makeZip(t, "", []entry{{sjisName, "hello"}})

	dest := t.TempDir()
	e := &Extractor{Dest: dest, From: japanese.ShiftJIS, To: unicode.UTF8, Out: io.Discard}
	if err := e.Extract(r); err != nil {
		t.Fatal(err)
	}
	if got := readFile(t, filepath.Join(dest, "日本語", "ファイル.txt")); got != "hello" {
		t.Errorf("content = %q", got)
	}
}

func TestExtractEncrypted(t *testing.T) {
	r := makeZip(t, "secret", []entry{{"a.txt", "aaa"}, {"b.txt", "bbb"}})

	dest := t.TempDir()
	calls := 0
	e := &Extractor{
		Dest: dest, From: unicode.UTF8, To: unicode.UTF8, Out: io.Discard,
		Password: func() (string, error) { calls++; return "secret", nil },
	}
	if err := e.Extract(r); err != nil {
		t.Fatal(err)
	}
	if calls != 1 {
		t.Errorf("password asked %d times, want 1", calls)
	}
	if got := readFile(t, filepath.Join(dest, "b.txt")); got != "bbb" {
		t.Errorf("content = %q", got)
	}
}

func TestExtractWrongPassword(t *testing.T) {
	r := makeZip(t, "secret", []entry{{"a.txt", "aaa"}})

	dest := t.TempDir()
	e := &Extractor{
		Dest: dest, From: unicode.UTF8, To: unicode.UTF8, Out: io.Discard,
		Password: func() (string, error) { return "wrong", nil },
	}
	if err := e.Extract(r); err == nil {
		t.Fatal("Extract should fail with wrong password")
	}
	if _, err := os.Stat(filepath.Join(dest, "a.txt")); !os.IsNotExist(err) {
		t.Error("partial file should be removed")
	}
}

func TestExtractSkipsExisting(t *testing.T) {
	r := makeZip(t, "", []entry{{"a.txt", "new"}})

	dest := t.TempDir()
	if err := os.WriteFile(filepath.Join(dest, "a.txt"), []byte("old"), 0o644); err != nil {
		t.Fatal(err)
	}
	var out strings.Builder
	e := &Extractor{Dest: dest, From: unicode.UTF8, To: unicode.UTF8, Out: &out}
	if err := e.Extract(r); err != nil {
		t.Fatal(err)
	}
	if got := readFile(t, filepath.Join(dest, "a.txt")); got != "old" {
		t.Errorf("existing file overwritten: %q", got)
	}
	if !strings.Contains(out.String(), "exists a.txt") {
		t.Errorf("output = %q", out.String())
	}
}

func TestExtractRejectsZipSlip(t *testing.T) {
	r := makeZip(t, "", []entry{{"../evil.txt", "x"}})
	e := &Extractor{Dest: t.TempDir(), From: unicode.UTF8, To: unicode.UTF8, Out: io.Discard}
	if err := e.Extract(r); err == nil {
		t.Fatal("Extract should reject path traversal")
	}
}
