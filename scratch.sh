#!/bin/sh

scratch() {


  # define varibles to be used in the script
  # ----------------------------------------------------------------------------
  local name folder to_install protocol git_minor_version


  # define local functions to be used in the script (unset at the end)
  # ----------------------------------------------------------------------------
  __rand_char() {
    local rand_number=$(__rand_number)
    local rand_index=$(( $rand_number % $# + 1 ))
    # this eval is okay because unsetting the functions at the end makes it safe
    eval "printf %s \${$rand_index}"
  }

  __rand_number() {
    printf %s $(od -An -tu -N2 /dev/urandom)
  }

  __rand_word() {
    local word
    word=$word$(__rand_char qu wh w r t y p ph d dr f g gr h j k kn l z c ch v b bl n m)
    word=$word$(__rand_char a ai e ee ei ie oo o u)
    word=$word$(__rand_char w r t y p s d ff g h k l c b n m)
    printf %s $word
  }

  __git_version_at_least() {
    local minor_git_version=$(git --version | sed 's/\(git version \)\([0-9]*\.[0-9]*\)\(.*\)/\2/')
    echo "$1 < ${minor_git_version}" | bc
  }

  __extract_repo_info() {
    local repo

    # will extract "username/repo#commit-ish" from the following:
    #
    # supercrabtree/kerpow
    # supercrabtree/kerpow#6c7efc4
    # git@github.com:supercrabtree/kerpow.git
    # https://github.com/supercrabtree/kerpow
    # https://github.com/supercrabtree/kerpow.git

    # did they pass in a username/repo
    # i.e. supercrabtree/beepboop
    repo=$(printf %s $1 | sed -n 's/\(^[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9]\/[a-zA-Z0-9\-]*$\)/\1/p')
    if [ ! -z $repo ];then
      printf '%s#' $repo
      return 0
    fi

    # did they pass in a username/repo#commit-ish
    # i.e. supercrabtree/beepboop#6c778ccd
    repo=$(printf %s $1 | sed -n 's/\(^[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9]\/[a-zA-Z0-9\-]*#.*$\)/\1/p')
    if [ ! -z $repo ];then
      printf '%s' $repo
      return 0
    fi

    # did they pass in an https git repo address
    # i.e. https://github.com/supercrabtree/beepboop.git                         = supercrabtree/beepboop
    # or   https://github.com/supercrabtree/beepboop                             = supercrabtree/beepboop
    # or   https://github.com/supercrabtree/beepboop/so/deep/nested/whatever     = supercrabtree/beepboop
    repo=$(printf %s $1 | sed -n 's/https\:\/\/github.com\/\([^\/]*\)\/\([^\.\/]*\)\(.*\)/\1\/\2/p')
    if [ ! -z $repo ];then
      printf '%s#' $repo
      return 0
    fi

    # did they pass in an ssh git repo address
    # i.e. git@github.com:supercrabtree/beepboop.git = supercrabtree/beepboop
    repo=$(printf %s $1 | sed -n 's/git@github.com:\([^\/]*\)\/\([^\/]*\)\.git/\1\/\2/p')
    if [ ! -z $repo ];then
      printf '%s#' $repo
      return 0
    fi


  }


  # run script
  # ----------------------------------------------------------------------------

  # set scratch folder
  folder=${SCRATCHES_FOLDER:-"$HOME/scratches"}

  # set protocol
  protocol=${SCRATCHES_PROTOCOL:-"https"}

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
    name=scratch-$(__rand_word)
    cd $folder
    mkdir -p $name
    cd $name
  fi


  # if `scratch install`
  if [ "$1" = "install" ]; then

    local to_install=$2

    # Check to make sure the next parameter has also been supplied
    if [ "$#" -eq 1 ];then
      printf '%s\n' "Erm, what do you want to install? (You need another parameter)"
      return 1
    fi

    # if to_install is a local path
    if [ -d $to_install ];then
      printf '%s\n' "Stop the press!! it's a folder. Sorry not supported yet."
      return 0
    fi

    local repo_info=$(__extract_repo_info $to_install)
    local repo_name=$(printf %s $repo_info | sed 's/#.*//')
    local repo_branch=$(printf %s $repo_info | sed 's/.*#//')

    url_format="https://git::@github.com/$repository_name.git"

    if [ $(__git_version_at_least 2.3) -eq 1 ]; then
      # Git 2.3.0 introduced $GIT_TERMINAL_PROMPT
      # which can be used to suppress user prompt
      export GIT_TERMINAL_PROMPT=0
      url_format="https://github.com/$repo_name.git"
    fi

    if [ $protocol = "https" ]; then
      url_format="https://git::@github.com/$repo_name.git"
    elif [ $protocol = "ssh" ]; then
      url_format="git@github.com:$repo_name.git"
    fi

    git clone --recursive $url_format "$HOME/.scratch/repos/$repo_name"

    if [ ! -z $repo_branch ]; then
      $(cd "$HOME/.scratch/repos/$repo_name"; git checkout --quiet $repo_branch)
    fi

  fi

  unset -f __rand_char
  unset -f __rand_word
  unset -f __rand_number
  unset -f __git_version_at_least
  unset -f __extract_repo_info
}

