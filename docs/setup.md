# Zero to first job

Condensed path for a fresh TRUBA account. Verified 2026-08-10 on ARF. Official docs: <https://docs.truba.gov.tr>.

## 1. VPN

TRUBA UI servers only exist inside the VPN. Grab the `.ovpn` profile from the [OpenVPN docs page](https://docs.truba.gov.tr/2-temel_bilgiler/openvpn_installation/openvpn_info.html), import into any OpenVPN client (OpenVPN Connect on Windows works), authenticate with your TRUBA username/password.

Tunnel check: `Test-NetConnection 172.16.6.11 -Port 22` (PowerShell) or `nc -zv 172.16.6.11 22`.

## 2. SSH

```
ssh <user>@172.16.6.11
```

ARF UI servers: `arf-ui1`–`arf-ui5` = 172.16.6.11–.15 (any of them). Change your initial password immediately: `passwd`.

## 3. Key auth (do this early)

Windows note: don't pipe into ssh (`type key.pub | ssh …` hangs — see [gotchas](gotchas.md)). Two steps that each prompt normally:

```
ssh-keygen -t ed25519
scp ~/.ssh/id_ed25519.pub <user>@172.16.6.11:~/mykey.pub
ssh <user>@172.16.6.11 "mkdir -p ~/.ssh; chmod 700 ~/.ssh; cat ~/mykey.pub >> ~/.ssh/authorized_keys; chmod 600 ~/.ssh/authorized_keys; rm ~/mykey.pub"
```

Test: `ssh <user>@172.16.6.11 hostname` → no password prompt.

## 4. First job

```bash
mkdir -p /arf/scratch/$USER && cd /arf/scratch/$USER   # jobs MUST live here, not home
sbatch -p debug <script>.slurm                          # debug = small/test queue, 4h max
squeue --me
cat *_<jobid>.out
```

See [experiments/001-hello](../experiments/001-hello/) for known-good scripts, and [gotchas.md](gotchas.md) before trying any other partition.

## 5. Orientation commands

```bash
sinfo -s          # partition map
lssrv             # TRUBA's own queue-load viewer
module avail      # software stacks
sacct -j <id> --format=JobID,State,Elapsed,MaxRSS,NodeList
```
