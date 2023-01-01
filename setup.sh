#!/bin/bash

set -e
set -u
set -o pipefail

REPOSITORY_URL=https://github.com/holly/holly.sh.git
ADD_LINE1="export HOLLYSH=\$HOME/holly.sh"
ADD_LINE2="source \$HOLLYSH/.holly.sh"
DEPENDENCY_COMMANDS=(bc curl make strace git jq)

echo "# check dependency commands: ${DEPENDENCY_COMMANDS[@]}"
for cmd in ${DEPENDENCY_COMMANDS[@]}; do

    if which $cmd >/dev/null; then
        echo "$cmd is exists."
    else
        echo "$cmd is not exists. Your have to have $cmd installed."
        exit 1
    fi
done
echo

echo "# install holly.sh"
cd $HOME
if [[ -d holly.sh ]]; then
    echo "$HOME/holly.sh directory is already exists. If you want to install utility shell, remove holly.sh directory."
    exit 1
fi
git clone $REPOSITORY_URL
echo

echo "# add holly.sh load settings to your .bashrc or .zshrc"
pushd $HOME/holly.sh
if [[ -f $HOME/.bashrc ]]; then
    grep -q "$ADD_LINE1" $HOME/.bashrc

    if [[ $? -ne 0 ]]; then
        cat <<EOL | tee -a $HOME/.bashrc

# added loading .holly.sh by holly.sh/setup.sh
$ADD_LINE1
$ADD_LINE2
EOL
    fi
fi
if [[ -f $HOME/.zshrc ]]; then
    grep -q "$ADD_LINE1" $HOME/.zshrc

    if [[ $? -ne 0 ]]; then
        cat <<EOL | tee -a $HOME/.zshrc

# added loading .holly.sh by holly.sh/setup.sh
$ADD_LINE1
$ADD_LINE2
EOL
    fi
fi
