#!/usr/bin/bash
set -e

if [ $# != 2 ]; then
  echo "Usage path/to/test-threads.sh <termux-elf-cleaner> <source-dir>"
  exit 1
fi

elf_cleaner="$1"
source_dir="$2"

for i in {1..100}; do
  for arch in aarch64 arm i686 x86_64; do
    for api in 21 24; do
      cp "$source_dir/tests/curl-7.83.1-$arch-original" "$source_dir/tests/curl-8.83.1-$arch-api$api-threads-$i.test"
    done
  done
done

for api in 21 24; do
  "$elf_cleaner" --api-level "$api" --quiet --jobs 4 "$source_dir/tests/curl-8.83.1-"*"-api$api-threads"*".test"
done

for i in {1..100}; do
  for arch in aarch64 arm i686 x86_64; do
    for api in 21 24; do
      if not cmp -s "$source_dir/tests/curl-7.83.1-$arch-api$api-cleaned" "$source_dir/tests/curl-8.83.1-$arch-api$api-threads-$i.test"; then
        echo "Expected and actual files differ for $source_dir/tests/curl-8.83.1-$arch-threads-$i.test"
        exit 1
      fi
    done
  done
done
