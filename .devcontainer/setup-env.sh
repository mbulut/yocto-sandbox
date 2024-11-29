#!/bin/bash

HOST_HOME=$1
rm -rf ${HOME}/.ssh
cp -r ${HOST_HOME}/.ssh ${HOME}

pushd ${HOME}/.ssh
for i in $(ls .); do
    if [[ "$i" == "config" ]]; then
        chmod 664 $i
    elif [[ "$i" =~ .*\.pub$ ]]; then
        chmod 644 $i
    else
        chmod 600 $i
    fi
done
popd

if [[ -z "$SSH_AUTH_SOCK" ]]; then
    eval $(ssh-agent -s)
    echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" >>${HOME}/.bashrc
    echo "export SSH_AGENT_PID=$SSH_AGENT_PID" >>${HOME}/.bashrc
fi

. ${HOME}/.bashrc

ssh-add || true
