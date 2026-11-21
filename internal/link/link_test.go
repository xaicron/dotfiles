package link

import (
	"io"
	"os"
	"path/filepath"
	"reflect"
	"strings"
	"testing"
)

func setup(t *testing.T) (src, dst string) {
	t.Helper()
	src = t.TempDir()
	dst = t.TempDir()
	for _, name := range []string{".zshrc", ".pause", ".gitignore", "go.mod", "README.md"} {
		if err := os.WriteFile(filepath.Join(src, name), []byte(name+"\n"), 0o644); err != nil {
			t.Fatal(err)
		}
	}
	for _, dir := range []string{".git", ".vim", "bin", "cmd"} {
		if err := os.Mkdir(filepath.Join(src, dir), 0o755); err != nil {
			t.Fatal(err)
		}
	}
	return src, dst
}

func TestTargets(t *testing.T) {
	src, _ := setup(t)
	got, err := Targets(src)
	if err != nil {
		t.Fatal(err)
	}
	want := []string{".pause", ".vim", ".zshrc", "bin"}
	if !reflect.DeepEqual(got, want) {
		t.Errorf("Targets() = %v, want %v", got, want)
	}
}

func assertLink(t *testing.T, path, target string) {
	t.Helper()
	got, err := os.Readlink(path)
	if err != nil {
		t.Fatalf("%s is not a symlink: %v", path, err)
	}
	if got != target {
		t.Errorf("%s -> %s, want %s", path, got, target)
	}
}

func TestRunCreatesLinks(t *testing.T) {
	src, dst := setup(t)
	l := &Linker{Src: src, Dst: dst, In: strings.NewReader(""), Out: io.Discard, Err: io.Discard}
	if err := l.Run(); err != nil {
		t.Fatal(err)
	}
	for _, name := range []string{".pause", ".vim", ".zshrc", "bin"} {
		assertLink(t, filepath.Join(dst, name), filepath.Join(src, name))
	}
	if _, err := os.Lstat(filepath.Join(dst, "go.mod")); !os.IsNotExist(err) {
		t.Errorf("go.mod should not be linked")
	}
	if fi, err := os.Stat(filepath.Join(dst, ".vim-backup")); err != nil || !fi.IsDir() {
		t.Errorf(".vim-backup should be created")
	}
	if fi, _ := os.Stat(filepath.Join(src, ".pause")); fi.Mode().Perm() != 0o600 {
		t.Errorf(".pause mode = %v, want 0600", fi.Mode().Perm())
	}
}

func TestRunExistingFile(t *testing.T) {
	tests := []struct {
		name     string
		force    bool
		input    string
		wantLink bool
	}{
		{"force", true, "", true},
		{"answer yes", false, "n\ny\n", true},
		{"answer no", false, "n\nn\n", false},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			src, dst := setup(t)
			existing := filepath.Join(dst, ".zshrc")
			if err := os.WriteFile(existing, []byte("old\n"), 0o644); err != nil {
				t.Fatal(err)
			}
			// 既存ディレクトリも置き換えられること
			if err := os.MkdirAll(filepath.Join(dst, "bin", "sub"), 0o755); err != nil {
				t.Fatal(err)
			}
			input := tt.input + tt.input // .zshrc と bin の 2 回分
			l := &Linker{Src: src, Dst: dst, Force: tt.force, In: strings.NewReader(input), Out: io.Discard, Err: io.Discard}
			if err := l.Run(); err != nil {
				t.Fatal(err)
			}
			for _, name := range []string{".zshrc", "bin"} {
				_, err := os.Readlink(filepath.Join(dst, name))
				if isLink := err == nil; isLink != tt.wantLink {
					t.Errorf("%s isLink = %v, want %v", name, isLink, tt.wantLink)
				}
			}
		})
	}
}

func TestRunSkipsExistingSymlink(t *testing.T) {
	src, dst := setup(t)
	other := filepath.Join(t.TempDir(), "other")
	if err := os.Symlink(other, filepath.Join(dst, ".zshrc")); err != nil {
		t.Fatal(err)
	}
	l := &Linker{Src: src, Dst: dst, In: strings.NewReader(""), Out: io.Discard, Err: io.Discard}
	if err := l.Run(); err != nil {
		t.Fatal(err)
	}
	assertLink(t, filepath.Join(dst, ".zshrc"), other)
}
