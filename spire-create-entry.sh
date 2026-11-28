#!/bin/bash

#oc exec -n spire-server spire-server-0 -- /opt/spire/bin/spire-server entry create \
#  -parentID spiffe://example.test/vm/spire-vm \
#  -spiffeID spiffe://example.test/sshd/spire-vm.example.test \
#  -selector systemd:id:spiffe-step-ssh@main.service


oc exec -n spire-server spire-server-0 -- /opt/spire/bin/spire-server entry create \
  -parentID spiffe://example.test/spire/agent/http_challenge/spire-vm.example.test \
  -spiffeID spiffe://example.test/sshd/spire-vm.example.test \
  -selector systemd:id:spiffe-step-ssh@main.service


#kubectl -n spire-server exec spire-server-0 -- \
#  /opt/spire/bin/spire-server entry create \
#  -parentID spiffe://example.test/vm/spire-vm \
#  -spiffeID spiffe://example.test/vm/spire-vm/kcdbinary \
#  -selector unix:uid:1000
