#!/usr/bin/bash
set -e

if [ $# != 4 ]; then
  echo "Usage path/to/test-dynamic-section.sh <elf-cleaner> <source-dir> <binary-name> <arch>"
  exit 1
fi

elf_cleaner="$1"
source_dir="$2"
binary_name="$3"
arch="$4"

progname="$(basename "$elf_cleaner")"
basefile="$source_dir/tests/$binary_name-$arch"
origfile="$basefile-original"
testfile="$(basename $basefile).test"
expectedfile="$basefile-tls-aligned"
test_dir="$(dirname $1)/tests"

if [ "$arch" = "aarch64" ] || [ "$arch" = "x86_64" ]; then
  expected_logs="$progname: Changing TLS alignment for '$test_dir/$testfile' to 64, instead of 8"
elif [ "$arch" = "arm" ] || [ "$arch" = "i686" ]; then
  expected_logs="$progname: Changing TLS alignment for '$test_dir/$testfile' to 32, instead of 8"
else
  echo "Unknown architecture $arch"
  exit 1
fi

mkdir -p "$test_dir"
cp "$origfile" "$test_dir/$testfile"
# echo "$elf_cleaner" "$test_dir/$testfile"
if [ "$("$elf_cleaner" "$test_dir/$testfile")" != "$expected_logs" ]; then
  echo "Logs do not match for $testfile"
  exit 1
fi
if not cmp -s "$test_dir/$testfile" "$expectedfile"; then
  echo "Expected and actual files differ for $testfile"
  exit 1
fi
