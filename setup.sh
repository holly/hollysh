#!/bin/bash

REPOSITORY_URL=https://github.com/holly/hollysh.git
INSTALL_DIR=$HOME/hollysh
ADD_LINE1="## add holly.sh load settings to your .bashrc or .zshrc"
ADD_LINE2="export HOLLYSH=\$HOME/hollysh"
ADD_LINE3="source \$HOLLYSH/holly.sh"
DEPENDENCY_COMMANDS=(bc curl make strace git jq nc)
DEPENDENCY_COMMANDS=(batcat rg)

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

echo "# install hollysh"
if [[ -d $INSTALL_DIR ]]; then
    echo "WARN: $INSTALL_DIR directory is already exists. update holly.sh."
    pushd $INSTALL_DIR
    git pull origin main
    pushd
    echo 
    echo "update success. exit."
    exit
else
    push $HOME
    git clone $REPOSITORY_URL
    popd
fi
echo

echo "# add load settings to your .bashrc or .zshrc"
if [[ -f $HOME/.bashrc ]]; then
    grep -q "$ADD_LINE1" $HOME/.bashrc
    if [[ $? -ne 0 ]]; then
        cat <<EOL | tee -a $HOME/.bashrc

$ADD_LINE1
$ADD_LINE2
$ADD_LINE3
EOL
    fi
fi
if [[ -f $HOME/.zshrc ]]; then
    grep -q "$ADD_LINE1" $HOME/.zshrc

    if [[ $? -ne 0 ]]; then
        cat <<EOL | tee -a $HOME/.zshrc

$ADD_LINE1
$ADD_LINE2
$ADD_LINE3
EOL
    fi
fi
echo 
echo "install success. exit."



