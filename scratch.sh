#!/bin/sh

_scratch_rand_char() {
  local rand_index=$((${RANDOM} % $# + 1))
  eval "local char=\${$rand_index}"
  echo $char
}

_scratch_rand_word() {
  local word
  word=$word$(_scratch_rand_char qu wh w r t y p ph d dr f g gr h j k kn l z c ch v b bl n m)
  word=$word$(_scratch_rand_char a e ee i oo u)
  word=$word$(_scratch_rand_char w r t y p s d ff g h k l c b n m)
  echo $word
}

scratch() {
  local name folder

  if [ $# -eq 0 ]; then
    if [ -z "$SCRATCHES_FOLDER" ]; then
      folder="$HOME/scratches"
    else
      folder="$SCRATCHES_FOLDER"
    fi

    name=scratch-$(_scratch_rand_word)

    # if its a dir, and writable by the current process
    if [ -d "${folder}" ]; then
      if [ ! -w "${folder}" ]; then
        printf "\n\033[1;32mYour scratches folder\033[0m %s\033[1;32m is not writable.\033[0m\n" $folder
        printf "  chmod +x %s\n" $folder
        return 1
      fi
    fi

    cd $folder
    mkdir -p $name
    cd $name

  fi
}
