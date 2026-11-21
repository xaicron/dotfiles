// m4a_durations はディレクトリ内の .m4a ファイルの再生時間をミリ秒で表示する。ffprobe が必要。
//
//	m4a_durations <dir>
package main

import (
	"bufio"
	"bytes"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
)

func main() {
	if len(os.Args) != 2 {
		fmt.Fprintln(os.Stderr, "Usage: m4a_durations <dir>")
		os.Exit(2)
	}
	if err := run(os.Args[1]); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func run(dir string) error {
	entries, err := os.ReadDir(dir)
	if err != nil {
		return err
	}
	for _, e := range entries {
		if e.IsDir() || !strings.HasSuffix(e.Name(), "m4a") {
			continue
		}
		out, err := exec.Command("ffprobe", "-i", filepath.Join(dir, e.Name()), "-show_format", "-v", "quiet").Output()
		if err != nil {
			return fmt.Errorf("ffprobe %s: %w", e.Name(), err)
		}
		ms, err := durationMillis(out)
		if err != nil {
			return fmt.Errorf("%s: %w", e.Name(), err)
		}
		fmt.Printf("%s\t%d\n", e.Name(), ms)
	}
	return nil
}

// durationMillis は ffprobe -show_format の出力から duration= を読み取りミリ秒に変換する。
func durationMillis(out []byte) (int64, error) {
	sc := bufio.NewScanner(bytes.NewReader(out))
	for sc.Scan() {
		if v, ok := strings.CutPrefix(sc.Text(), "duration="); ok {
			sec, err := strconv.ParseFloat(v, 64)
			if err != nil {
				return 0, err
			}
			return int64(sec * 1000), nil
		}
	}
	return 0, errors.New("duration not found")
}
