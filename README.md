# Spiffe/Spire

Install spire, spiffe-ssh and its step-ca, kubevirt and a VM with a spire-agent and workloadattestators.
You may need to rerun it twice or thrice to handle CRDs.

```
bash install.sh
```

Create a spiffe entry for ssh hostkeys inside the VM.

```
bash spire-create-entry.sh
```

After 5 minutes (the VM is slow), add the SSH CA to the known hosts and ssh to the VM (with hostkeys automatically recognised).

```
bash vm-ssh.sh
```

Inside the VM, you can see the hostkeys set in `/etc/ssh/sshd_config.d/50-spiffe-step-ssh.conf`.
