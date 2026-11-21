package uriescape

import "testing"

func TestEscape(t *testing.T) {
	tests := map[string]string{
		"http://example.com/a b?x=1&y=あ": "http%3A%2F%2Fexample.com%2Fa%20b%3Fx%3D1%26y%3D%E3%81%82",
		"AZaz09-._~":                     "AZaz09-._~",
		"100%":                           "100%25",
	}
	for in, want := range tests {
		if got := Escape(in); got != want {
			t.Errorf("Escape(%q) = %q, want %q", in, got, want)
		}
	}
}

func TestUnescape(t *testing.T) {
	got, err := Unescape("http%3A%2F%2Fexample.com%2Fa%20b+c%2F%E3%81%82")
	if err != nil {
		t.Fatal(err)
	}
	if want := "http://example.com/a b+c/あ"; got != want {
		t.Errorf("Unescape() = %q, want %q", got, want)
	}
	if _, err := Unescape("%zz"); err == nil {
		t.Error("Unescape(%zz) should fail")
	}
}

func TestCanonical(t *testing.T) {
	tests := map[string]string{
		"HTTP://Example.COM:80/Path?Q=1": "http://example.com/Path?Q=1",
		"https://example.com:443/":       "https://example.com/",
		"https://example.com:8443/":      "https://example.com:8443/",
		"http://[::1]:80/":               "http://[::1]/",
		"http://user@Example.com/":       "http://user@example.com/",
	}
	for in, want := range tests {
		got, err := Canonical(in)
		if err != nil {
			t.Fatal(err)
		}
		if got != want {
			t.Errorf("Canonical(%q) = %q, want %q", in, got, want)
		}
	}
}

func TestDumpQuery(t *testing.T) {
	base, query, err := DumpQuery("https://example.com/a%20b?y=2&x=%E3%81%82&y=3&z=a+b")
	if err != nil {
		t.Fatal(err)
	}
	if want := "https://example.com/a%20b"; base != want {
		t.Errorf("base = %q, want %q", base, want)
	}
	want := `{
   "x": "あ",
   "y": [
      "2",
      "3"
   ],
   "z": "a b"
}`
	if query != want {
		t.Errorf("query =\n%s\nwant\n%s", query, want)
	}
}
