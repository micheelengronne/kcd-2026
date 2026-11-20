#!/bin/bash

helm upgrade --install --create-namespace -n spire spire-crds spire-crds --repo https://spiffe.github.io/helm-charts-hardened/

helm upgrade --install -f spire-values.yml -n spire spire spire --repo https://spiffe.github.io/helm-charts-hardened/
