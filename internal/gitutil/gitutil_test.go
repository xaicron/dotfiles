package gitutil

import "testing"

func TestHTTPSURL(t *testing.T) {
	tests := map[string]string{
		"git@github.com:foo/bar.git":       "https://github.com/foo/bar",
		"git@github.com:foo/bar":           "https://github.com/foo/bar",
		"ssh://git@github.com/foo/bar.git": "https://github.com/foo/bar",
		"git://github.com/foo/bar.git":     "https://github.com/foo/bar",
		"https://github.com/foo/bar.git":   "https://github.com/foo/bar",
		"https://github.com/foo/bar":       "https://github.com/foo/bar",
	}
	for in, want := range tests {
		if got := HTTPSURL(in); got != want {
			t.Errorf("HTTPSURL(%q) = %q, want %q", in, got, want)
		}
	}
}

func TestFileURL(t *testing.T) {
	const remote = "https://github.com/foo/bar"
	tests := []struct {
		start, end string
		want       string
	}{
		{"", "", remote + "/tree/master/a/b.go"},
		{"10", "", remote + "/tree/master/a/b.go#L10"},
		{"10", "20", remote + "/tree/master/a/b.go#L10..L20"},
	}
	for _, tt := range tests {
		if got := FileURL(remote, "master", "a/b.go", tt.start, tt.end); got != tt.want {
			t.Errorf("FileURL(%q, %q) = %q, want %q", tt.start, tt.end, got, tt.want)
		}
	}
}

func TestCommitURL(t *testing.T) {
	got := CommitURL("https://github.com/foo/bar", "abc123")
	if want := "https://github.com/foo/bar/commit/abc123"; got != want {
		t.Errorf("CommitURL() = %q, want %q", got, want)
	}
}
