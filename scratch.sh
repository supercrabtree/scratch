#!/bin/sh

scratch() {
  local name folder

  __scratch_rand_char() {
    local rand_number=$(__scratch_rand_number)
    local rand_index=$(( $rand_number % $# + 1 ))
    eval "printf %s \${$rand_index}"
  }
  __scratch_rand_number() {
    printf %s $(od -An -tu -N2 /dev/urandom)
  }

  __scratch_rand_word() {
    local word
    word=$word$(__scratch_rand_char qu wh w r t y p ph d dr f g gr h j k kn l z c ch v b bl n m)
    word=$word$(__scratch_rand_char a ai e ee ei ie oo o u)
    word=$word$(__scratch_rand_char w r t y p s d ff g h k l c b n m)
    printf %s $word
  }


  # set scratch folder, and ensure we can write to it
  folder=${SCRATCHES_FOLDER:-"$HOME/scratches"}

    # if its a dir, and writable by the current process
    if [ -d "${folder}" ]; then
      if [ ! -w "${folder}" ]; then
        printf "\n\033[1;32mYour scratches folder\033[0m %s\033[1;32m is not writable.\033[0m\n" $folder
        printf "  chmod +x %s\n" $folder
        return 1
      fi
    fi

    name=scratch-$(__scratch_rand_word)

    cd $folder
    mkdir -p $name
    cd $name

  fi

  unset -f __scratch_rand_char
  unset -f __scratch_rand_word
  unset -f __scratch_rand_number
}
