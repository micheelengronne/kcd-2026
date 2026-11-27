#!/bin/bash

# Needs:
# openshift-cli
# kubectl
# helm
# virtctl

helm upgrade --install --create-namespace -n spire spire-crds spire-crds --repo https://spiffe.github.io/helm-charts-hardened/

helm upgrade --install -f spire-values.yml -n spire spire spire --repo https://spiffe.github.io/helm-charts-hardened/

kubectl apply -f kubevirt-operator.yaml

oc annotate hyperconverged kubevirt-hyperconverged -n openshift-cnv --overwrite \
  kubevirt.kubevirt.io/jsonpatch='[{"op":"add","path":"/spec/configuration/developerConfiguration","value":{"useEmulation":true,"featureGates":["MultiArchitecture"]}}]'

kubectl -n spire-server exec spire-server-0 -- \
  /opt/spire/bin/spire-server token generate \
  -spiffeID spiffe://example.test/vm/spire-vm -ttl 600 > join_token

kubectl -n spire-server exec spire-server-0 -- \
  /opt/spire/bin/spire-server bundle show > bundle.pem

ssh-keygen -t ed25519 -N '' -f ./id_ed25519

kubectl apply -k .
