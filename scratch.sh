#!/bin/sh

scratch() {

  # define local functions to be used in the script (unset at the end)
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

  __scratch_create_remote_addresses() {
    # the following styles will all result in the two remote addresses
    # http://github.com/supercrabtree/kerpow.git
    # git@github.com:supercrabtree/kerpow.git
    #
    # scratch install kerpow
    # scratch install supercrabtree/kerpow
    # scratch install http://github.com/supercrabtree/kerpow
    # scratch install git@github.com:supercrabtree/kerpow.git
    # scratch install https://github.com/supercrabtree/kerpow.git
    # scratch install http://github.com/supercrabtree/kerpow.git
    local ssh_address http_address

    # scratch install supercrabtree/kerpow
    local github_repo=$(printf %s $1 | awk '/^[0-9a-z]*\/[0-9a-z]*$/')
    if [ -n "$github_repo" ];then
      ssh_address="git@github.com:$github_repo.git"
      http_address="https://github.com/$github_repo.git"
      printf '%s %s' $ssh_address $http_address
      return 0
    fi
  }

  # define varibles to be used in the script
  local name folder

  # set scratch folder, and ensure we can write to it
  folder=${SCRATCHES_FOLDER:-"$HOME/scratches"}

  # if its a dir, and writable by this process
  if [ -d "${folder}" ]; then
    if [ ! -w "${folder}" ]; then
      printf "\n\033[1;32mYour scratches folder\033[0m %s\033[1;32m is not writable.\033[0m\n" $folder
      printf "  chmod +x %s\n" $folder
      return 1
    fi
  else
    printf "\n\033[1;32mYour scratches folder\033[0m %s\033[1;32m defined by environment varible SCRATCHES_FOLDER is not a directory\033[0m\n" $folder
  fi

  # if no parameters supplied
  if [ "$#" -eq 0 ]; then
    name=scratch-$(__scratch_rand_word)
    cd $folder
    mkdir -p $name
    cd $name
  fi

  # if `scratch install`
  if [ "$1" = "install" ]; then
    # Check to make sure the next parameter has also been supplied
    if [ "$#" -eq 1 ];then
      printf '%s\n' "Erm, what do you want to install? (You need another parameter)"
      return 1
    fi

    # try to find remote addresses
    local to_install=$2
    printf '%s %s\n' $(__scratch_create_remote_addresses $to_install)

  fi

  unset -f __scratch_rand_char
  unset -f __scratch_rand_word
  unset -f __scratch_rand_number
}

