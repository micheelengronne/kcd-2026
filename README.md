# Spiffe/Spire

Install spire, kubevirt and a VM with a spire-agent and workloadattestators.
You may need to rerun it twice or thrice to handle CRDs.

```
bash install.sh
```

Create a spiffe entry for workloads inside the VM.

```
bash spire-create-entry.sh
```

Ssh to the VM.

```
bash vm-ssh.sh
```
