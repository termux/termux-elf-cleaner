#!/usr/bin/bash
set -e

if [ $# != 2 ]; then
  echo "Usage path/to/test-exit-status.sh <elf-cleaner> <source-dir>"
  exit 1
fi

elf_cleaner="$1"
source_dir="$2"
test_dir="$(dirname $1)/tests"

original="$source_dir/tests/curl-7.83.1-aarch64-original"
expected="$source_dir/tests/curl-7.83.1-aarch64-api21-cleaned"
good="$test_dir/exit-status-good.test"
truncated="$test_dir/exit-status-truncated.test"
missing="$test_dir/exit-status-missing.test"

mkdir -p "$test_dir"
rm -f "$missing"

# A valid file is processed with exit status 0.
cp "$original" "$good"
if ! "$elf_cleaner" --api-level 21 --quiet "$good"; then
  echo "Non-zero exit status for a valid file"
  exit 1
fi

# A file that ends before its section header table is reported as an error.
head -c 4096 "$original" > "$truncated"
status=0
"$elf_cleaner" --api-level 21 --quiet "$truncated" 2>/dev/null || status=$?
if [ "$status" = 0 ]; then
  echo "Exit status 0 for a truncated file"
  exit 1
fi

# A file that cannot be opened is reported as an error, and the
# other files given on the same command line are still processed.
cp "$original" "$good"
status=0
"$elf_cleaner" --api-level 21 --quiet --jobs 2 "$missing" "$good" 2>/dev/null || status=$?
if [ "$status" = 0 ]; then
  echo "Exit status 0 when a file could not be opened"
  exit 1
fi
if ! cmp -s "$good" "$expected"; then
  echo "Valid file was not processed when another file failed"
  exit 1
fi
