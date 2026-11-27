#!/bin/bash

kubectl -n spire-server exec spire-server-0 -- \
  /opt/spire/bin/spire-server entry create \
  -parentID spiffe://example.test/vm/spire-vm \
  -spiffeID spiffe://example.test/vm/spire-vm/kcdbinary \
  -selector unix:uid:1000
