#!/usr/bin/env bash

out=/tmp/kcov
mkdir -p "$out"
mkdir -p "$out/coverage"
mkdir -p "$out/coverage1"

main(){
  # shellcheck disable=SC2054  # Use spaces
  opts=(
    --include-path=bashrc.sh
    --exclude-line=": ',  \",done"
  )
  kcov "$out/coverage1" "${opts[@]}" bashrc.sh
  kcov --merge "${opts[@]}" "$out/coverage" "$out/coverage1"
  rm -r "$out/coverage1"
}

if ! (return 0 2>/dev/null); then
  >&2 echo "--> $0 starting with $*."
  main "$@"; res=$?
  >&2 echo "<-- $0 returned with $res."
  exit "$res"
fi
