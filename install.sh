#!/bin/bash

# Needs:
# openshift-cli
# kubectl
# helm
# virtctl

helm upgrade --install --create-namespace -n spire spire-crds spire-crds --repo https://spiffe.github.io/helm-charts-hardened/

helm upgrade --install -f spire-values.yml -n spire spire spire --repo https://spiffe.github.io/helm-charts-hardened/

kubectl apply -f kubevirt-operator.yaml

kubectl -n spire-server exec spire-server-0 -- \
  /opt/spire/bin/spire-server token generate \
  -spiffeID spiffe://example.test/vm/spire-vm -ttl 600 > join_token

kubectl -n spire-server exec spire-server-0 -- \
  /opt/spire/bin/spire-server bundle show > bundle.pem

ssh-keygen -t ed25519 -N '' -f ./id_ed25519

kubectl apply -k .

kubectl -n spire-server exec spire-server-0 -- \
  /opt/spire/bin/spire-server entry create \
  -parentID spiffe://example.test/vm/spire-vm \
  -spiffeID spiffe://example.test/vm/spire-vm/kcdbinary \
  -selector unix:uid:1000

#virtctl ssh cloud@vm/spire-vm -n default -i ./id_ed25519

# Check if demo without vault
#helm upgrade --install -f vault-values.yml --create-namespace -n vault vault vault --repo https://helm.releases.hashicorp.com
