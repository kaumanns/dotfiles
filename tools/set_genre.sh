#!/usr/bin/bash

# POSITIONAL=()
#
# while [[ $# -gt 0 ]]; do
#   key="$1"
#
#   case $key in
#     -g|--genre)
#       GENRE="$2"
#       shift # past argument
#       shift # past value
#       ;;
#     -t|--type)
#       if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
#         TYPE="$2"
#         shift # past argument
#         shift # past value
#       else
#         echo "Error: Argument for $1 is missing" >&2
#         exit 1
#       fi
#       ;;
#     -*|--*)
#       echo "Error: Unsupported flag ($1)" >&2
#       exit 1
#       ;;
#     *)    # unknown option
#       POSITIONAL+=("$1") # save it in an array for later
#       shift # past argument
#       ;;
#   esac
# done
#
# set -- "${POSITIONAL[@]}" # restore positional parameters
#
# if [ "$TYPE" == "mp3" ]; then
  # for d in .; do
  #   find "$d" \
  #     -iname '*.mp3' \
  #     -exec tageditor \
  #       set \
  #       --values genre="Chillout" \
  #       --files {} \
  #       \;
  # done
# elif [ "$TYPE" == "flac" ]; then
  for d in .; do
    find "$d" \
      -iname '*.flac' \
      -exec bash \
        -c ' \
          metaflac \
            --remove-tag="GENRE" "$1" \
          && metaflac \
            --set-tag="GENRE=Chillout" "$1" \
          ' \
        - {} \
        \;
  done
# fi
