#!/bin/bash

function fingerprints() {
  local file="${1:-$HOME/.ssh/authorized_keys}"
  while read l; do
    [[ -n $l && ${l###} = $l ]] && ssh-keygen -l -f /dev/stdin <<<$l
  done < "${file}"
}

fingerprints $HOME/.ssh/authorized_keys
