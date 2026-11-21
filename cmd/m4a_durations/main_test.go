package main

import "testing"

func TestDurationMillis(t *testing.T) {
	out := []byte("[FORMAT]\nfilename=a.m4a\nduration=183.456789\nsize=123\n[/FORMAT]\n")
	got, err := durationMillis(out)
	if err != nil {
		t.Fatal(err)
	}
	if got != 183456 {
		t.Errorf("durationMillis() = %d, want 183456", got)
	}

	if _, err := durationMillis([]byte("[FORMAT]\n[/FORMAT]\n")); err == nil {
		t.Error("durationMillis should fail when duration is missing")
	}
}
