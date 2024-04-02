#!/usr/bin/bash
set -e
if [ $# != 2 ]; then
  echo "Usage path/to/test.sh <termux-elf-cleaner> <source-dir>"
  exit 1
fi

archs=('arm' 'aarch64' 'i686' 'x86_64')
apis=('21' '24')
progname="$(basename "$1")"

for arch in "${archs[@]}"; do
  for api in "${apis[@]}"; do
    basefile="$2/tests/curl-7.83.1-${arch}"
    if [ "${api}" = "21" ]; then
      expected_logs="${progname}: Removing version section from '${basefile}-api${api}.test'
${progname}: Removing version section from '${basefile}-api${api}.test'
${progname}: Removing the DT_RUNPATH dynamic section entry from '${basefile}-api${api}.test'
${progname}: Removing the DT_VERNEEDNUM dynamic section entry from '${basefile}-api${api}.test'
${progname}: Removing the DT_VERNEED dynamic section entry from '${basefile}-api${api}.test'
${progname}: Removing the DT_VERSYM dynamic section entry from '${basefile}-api${api}.test'
${progname}: Replacing unsupported DF_1_* flags 134217737 with 1 in '${basefile}-api${api}.test'
${progname}: Removing the DT_GNU_HASH dynamic section entry from '${basefile}-api${api}.test'"
    elif [ "${api}" = "24" ]; then
      expected_logs="${progname}: Replacing unsupported DF_1_* flags 134217737 with 9 in '${basefile}-api${api}.test'"
    else
      echo "Unknown API level ${api}"
      exit 1
    fi
    cp "${basefile}"{-original,"-api${api}".test}
    if [ "$("$1" --api-level "${api}" "${basefile}-api${api}.test")" != "${expected_logs}" ]; then
      echo "Failed to remove version section from ${basefile}-api${api}.test"
      exit 1
    fi
  done
done

for arch in "${archs[@]}"; do
  basefile="$2/tests/valgrind-3.19.0-${arch}"
  if [ "${arch}" = "aarch64" ] || [ "${arch}" = "x86_64" ]; then
    expected_logs="${progname}: Changing TLS alignment for '${basefile}.test' to 64, instead of 8"
  elif [ "${arch}" = "arm" ] || [ "${arch}" = "i686" ]; then
    expected_logs="${progname}: Changing TLS alignment for '${basefile}.test' to 32, instead of 8"
  else
    echo "Unknown architecture ${arch}"
    exit 1
  fi
  cp "${basefile}"{-original,.test}
  if [ "$("$1" "${basefile}.test")" != "${expected_logs}" ]; then
    echo "Failed to remove version section from ${basefile}.test"
    exit 1
  fi
  diff "${basefile}"{-tls-aligned,.test}
done
