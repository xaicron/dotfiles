// Package gitutil は git コマンドと GitHub URL 変換のヘルパー。
package gitutil

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// Git は git コマンドを実行し、末尾の改行を除いた標準出力を返す。
func Git(args ...string) (string, error) {
	cmd := exec.Command("git", args...)
	cmd.Stderr = os.Stderr
	out, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("git %s: %w", strings.Join(args, " "), err)
	}
	return strings.TrimRight(string(out), "\n"), nil
}

// HTTPSURL は git の remote URL をブラウザで開ける https URL に変換する。
//
//	git@github.com:foo/bar.git      -> https://github.com/foo/bar
//	ssh://git@github.com/foo/bar.git -> https://github.com/foo/bar
//	git://github.com/foo/bar.git    -> https://github.com/foo/bar
//	https://github.com/foo/bar.git  -> https://github.com/foo/bar
func HTTPSURL(remote string) string {
	u := strings.TrimPrefix(remote, "ssh://")
	u = strings.TrimSuffix(u, ".git")
	if rest, ok := strings.CutPrefix(u, "git@"); ok {
		return "https://" + strings.Replace(rest, ":", "/", 1)
	}
	if rest, ok := strings.CutPrefix(u, "git://"); ok {
		return "https://" + rest
	}
	return u
}

// RemoteURL は remote.origin.url を https URL に変換して返す。
func RemoteURL() (string, error) {
	remote, err := Git("config", "remote.origin.url")
	if err != nil {
		return "", err
	}
	return HTTPSURL(remote), nil
}

// FileURL は GitHub 上のファイルの URL を組み立てる。
// path はリポジトリルートからの相対パス。lineStart / lineEnd が空なら行指定を付けない。
func FileURL(remote, branch, path, lineStart, lineEnd string) string {
	url := fmt.Sprintf("%s/tree/%s/%s", remote, branch, filepath.ToSlash(path))
	if lineStart != "" {
		url += "#L" + lineStart
		if lineEnd != "" {
			url += "..L" + lineEnd
		}
	}
	return url
}

// CommitURL は GitHub 上のコミットの URL を組み立てる。
func CommitURL(remote, hash string) string {
	return fmt.Sprintf("%s/commit/%s", remote, hash)
}

// Open は URL を macOS の open コマンドで開く。
func Open(url string) error {
	cmd := exec.Command("open", url)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}
