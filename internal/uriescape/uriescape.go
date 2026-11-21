// Package uriescape は URI のエスケープ・アンエスケープ・正規化を行う。
package uriescape

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/url"
	"strings"
)

// Escape は RFC 3986 の unreserved 文字 (A-Z a-z 0-9 - . _ ~) 以外を
// UTF-8 のバイト列としてパーセントエンコードする。
func Escape(s string) string {
	var b strings.Builder
	for i := 0; i < len(s); i++ {
		c := s[i]
		if isUnreserved(c) {
			b.WriteByte(c)
		} else {
			fmt.Fprintf(&b, "%%%02X", c)
		}
	}
	return b.String()
}

func isUnreserved(c byte) bool {
	return 'A' <= c && c <= 'Z' || 'a' <= c && c <= 'z' || '0' <= c && c <= '9' ||
		c == '-' || c == '.' || c == '_' || c == '~'
}

// Unescape はパーセントエンコードを元に戻す。'+' は空白に変換しない。
func Unescape(s string) (string, error) {
	return url.PathUnescape(s)
}

var defaultPorts = map[string]string{
	"http":  "80",
	"https": "443",
	"ftp":   "21",
}

// Canonical は scheme と host を小文字にし、既定のポート番号を取り除く。
func Canonical(s string) (string, error) {
	u, err := url.Parse(s)
	if err != nil {
		return "", err
	}
	u.Scheme = strings.ToLower(u.Scheme)
	host := strings.ToLower(u.Hostname())
	if port := u.Port(); port != "" && port != defaultPorts[u.Scheme] {
		host += ":" + port
	} else if strings.Contains(host, ":") {
		host = "[" + host + "]" // IPv6
	}
	u.Host = host
	return u.String(), nil
}

// DumpQuery は URI のクエリ部分を除いた URL と、クエリパラメータの JSON を返す。
// 同じキーが複数あれば値は配列になる。
func DumpQuery(s string) (base, query string, err error) {
	u, err := url.Parse(s)
	if err != nil {
		return "", "", err
	}
	authority := u.Host
	if u.User != nil {
		authority = u.User.String() + "@" + authority
	}
	base = fmt.Sprintf("%s://%s%s", u.Scheme, authority, u.EscapedPath())

	values, err := url.ParseQuery(u.RawQuery)
	if err != nil {
		return "", "", err
	}
	params := make(map[string]any, len(values))
	for k, v := range values {
		if len(v) == 1 {
			params[k] = v[0]
		} else {
			params[k] = v
		}
	}

	var buf bytes.Buffer
	enc := json.NewEncoder(&buf)
	enc.SetEscapeHTML(false)
	enc.SetIndent("", "   ")
	if err := enc.Encode(params); err != nil {
		return "", "", err
	}
	return base, strings.TrimRight(buf.String(), "\n"), nil
}
