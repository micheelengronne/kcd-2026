#!/bin/bash

oc exec -n spiffe-step-ssh spiffe-step-ssh-0 -- sh -c 'cat /home/step/certs/ssh_host_ca_key.pub' | awk 'NF > 0 { print }' > ./artifacts/ssh-ca.pub
echo "@cert-authority spire-vm.example.test,*.example.test $(<./artifacts/ssh-ca.pub)" > ./artifacts/known_hosts_spiffe

virtctl ssh cloud@vm/spire-vm -n default -i ./artifacts/id_ed25519 \
  --local-ssh-opts="-o UserKnownHostsFile=./artifacts/known_hosts_spiffe" \
  --local-ssh-opts="-o GlobalKnownHostsFile=/dev/null" \
  --local-ssh-opts="-o HostKeyAlias=spire-vm.example.test" \
  --local-ssh-opts="-o StrictHostKeyChecking=yes"
