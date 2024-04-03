#!/usr/bin/bash
set -e

if [ $# != 5 ]; then
  echo "Usage path/to/test-dynamic-section.sh <termux-elf-cleaner> <source-dir> <binary-name> <arch> <api>"
  exit 1
fi

elf_cleaner="$1"
source_dir="$2"
binary_name="$3"
arch="$4"
api="$5"

progname="$(basename "$elf_cleaner")"
basefile="$source_dir/tests/$binary_name-$arch"
origfile="$basefile-original"
testfile="$basefile-api$api.test"
expectedfile="$basefile-api$api-cleaned"

if [ "$api" = "21" ]; then
  expected_logs="$progname: Removing version section from '$testfile'
$progname: Removing version section from '$testfile'
$progname: Removing the DT_RUNPATH dynamic section entry from '$testfile'
$progname: Removing the DT_VERNEEDNUM dynamic section entry from '$testfile'
$progname: Removing the DT_VERNEED dynamic section entry from '$testfile'
$progname: Removing the DT_VERSYM dynamic section entry from '$testfile'
$progname: Replacing unsupported DF_1_* flags 134217737 with 1 in '$testfile'
$progname: Removing the DT_GNU_HASH dynamic section entry from '$testfile'"
elif [ "$api" = "24" ]; then
  expected_logs="$progname: Replacing unsupported DF_1_* flags 134217737 with 9 in '$testfile'"
else
  echo "Unknown API level $api"
  exit 1
fi

cp "$origfile" "$testfile"
if [ "$("$elf_cleaner" --api-level "$api" "$testfile")" != "$expected_logs" ]; then
  echo "Logs do not match for $testfile"
  exit 1
fi
if not cmp -s "$testfile" "$expectedfile"; then
  echo "Expected and actual files differ for $testfile"
  exit 1
fi
