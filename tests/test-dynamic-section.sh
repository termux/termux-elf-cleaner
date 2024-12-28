#!/usr/bin/bash
set -e

if [ $# != 5 ]; then
  echo "Usage path/to/test-dynamic-section.sh <elf-cleaner> <source-dir> <binary-name> <arch> <api>"
  exit 1
fi

elf_cleaner="$1"
source_dir="$2"
binary_name="$3"
arch="$4"
api="$5"
test_dir="$(dirname $1)/tests"

progname="$(basename "$elf_cleaner")"
basefile="$source_dir/tests/$binary_name-$arch"
origfile="$basefile-original"
expectedfile="$basefile-api$api-cleaned"
testfile="$(basename $origfile)"

if [ "$api" = "21" ]; then
  expected_logs="$progname: Removing VERSYM section from '$test_dir/$testfile'
$progname: Removing VERNEED section from '$test_dir/$testfile'
$progname: Removing the DT_RUNPATH dynamic section entry from '$test_dir/$testfile'
$progname: Removing the DT_VERNEEDNUM dynamic section entry from '$test_dir/$testfile'
$progname: Removing the DT_VERNEED dynamic section entry from '$test_dir/$testfile'
$progname: Removing the DT_VERSYM dynamic section entry from '$test_dir/$testfile'
$progname: Replacing unsupported DF_1_* flags 134217737 with 1 in '$test_dir/$testfile'
$progname: Removing the DT_GNU_HASH dynamic section entry from '$test_dir/$testfile'"
elif [ "$api" = "24" ]; then
  expected_logs="$progname: Replacing unsupported DF_1_* flags 134217737 with 9 in '$test_dir/$testfile'"
else
  echo "Unknown API level $api"
  exit 1
fi

mkdir -p "$test_dir"
cp "$origfile" "$test_dir/"
if [ "$("$elf_cleaner" --api-level "$api" "$test_dir/$testfile")" != "$expected_logs" ]; then
  echo "Logs do not match for $testfile"
  exit 1
fi
if not cmp -s "$test_dir/$testfile" "$expectedfile"; then
  echo "Expected and actual files differ for $testfile"
  exit 1
fi
