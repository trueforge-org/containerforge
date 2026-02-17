#!/usr/bin/env bash


FULL_ARGS=( "$@" )

exec /usr/local/bin/ffmpeg "${FULL_ARGS[@]}"

# look for input file value
for i in "$@"
do
  if [ ${KILL+x} ]; then
    INPUT_FILE=$i
    break
  fi
  if [ "$i" == "-i" ]; then
    KILL=1
  fi
done

## TODO: wont run?
run_ffmpeg

