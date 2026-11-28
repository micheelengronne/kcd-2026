#!/bin/bash

# WARNING: It is for a demo. There is a lot of yolo in terms of security

# Needs:
# openshift-cli
# kubectl
# helm
# virtctl
# step from smallstep.com (not the one in repos)

helm upgrade --install --create-namespace -n spire spire-crds spire-crds --repo https://spiffe.github.io/helm-charts-hardened/

helm upgrade --install -f spire-values.yml -n spire spire spire --repo https://spiffe.github.io/helm-charts-hardened/

# Prepare step-ssh service
oc new-project spiffe-step-ssh || true
helm pull spiffe-step-ssh --repo https://spiffe.github.io/helm-charts-hardened/ --untar

# Create the step CA
if [ ! -f ./spiffe-step-ssh-password.txt ]; then
  PASSWORD=$(openssl rand -base64 48); echo "$PASSWORD" > spiffe-step-ssh-password.txt
  step ca init --helm --deployment-type=Standalone --name='My CA' \
    --dns spiffe-step-ssh-fetchca.spiffe-step-ssh.svc.cluster.local --dns spiffe-step-ssh-fetchca \
    --ssh --address :8443 --provisioner default \
    --password-file spiffe-step-ssh-password.txt > spiffe-step-ssh-values.yaml
fi

helm upgrade --install spiffe-step-ssh ./spiffe-step-ssh -n spiffe-step-ssh \
  --set caPassword="$(cat spiffe-step-ssh-password.txt)" \
  -f spiffe-step-ssh-values.yaml \
  --set trustDomain=example.test \
  --set step.image.repository="docker.io/smallstep/step-ca"

oc adm policy add-scc-to-user anyuid -z default -n spiffe-step-ssh
oc adm policy add-scc-to-user anyuid -z spiffe-step-ssh-config -n spiffe-step-ssh
oc adm policy add-scc-to-user anyuid -z spiffe-step-ssh-fetchca -n spiffe-step-ssh
oc adm policy add-scc-to-user anyuid -z spiffe-step-ssh-config -n spiffe-step-ssh

# Deploy Kubevirt
kubectl apply -f kubevirt-operator.yaml

oc annotate hyperconverged kubevirt-hyperconverged -n openshift-cnv --overwrite \
  kubevirt.kubevirt.io/jsonpatch='[{"op":"add","path":"/spec/configuration/developerConfiguration","value":{"useEmulation":true,"featureGates":["MultiArchitecture"]}}]'

kubectl -n spire-server exec spire-server-0 -- \
  /opt/spire/bin/spire-server token generate \
  -spiffeID spiffe://example.test/vm/spire-vm -ttl 600 | awk '/Token:/{print $2}' > join_token

kubectl -n spire-server exec spire-server-0 -- \
  /opt/spire/bin/spire-server bundle show > bundle.pem

ssh-keygen -t ed25519 -N '' -f ./id_ed25519

kubectl apply -k .
