# Gotchas — what the docs don't tell you

Everything here was hit for real. Snapshot dates noted; cluster policy can change.

## Errors are Turkish, and on stderr only

The submit filter (`job_submit.lua`) explains rejections in Turkish on **stderr**, then Slurm prints a *misleading* generic English error (usually `Job violates accounting/QOS policy`). If you're automating, capture stderr (`2>&1`) or you'll only ever see the generic line. Known messages:

| Message | Meaning / fix |
|---|---|
| `Lutfen islerinizi /arf/scratch/ dizini altinda calistiriniz!` | Submit from `/arf/scratch/$USER`, never from home |
| `Orfoz kuyruguna gonderilen islerde node basina 56/112 cekirdek talep ediniz.` | `orfoz` accepts only 56- or 112-core-per-node jobs |
| `barbun-cuda kuyruguna gonderilen islerin cekirdek sayisi 20 ve katlari olmalidir` | Cores in multiples of 20 on `barbun-cuda` (20 per GPU) |

## Partition map (sinfo snapshot, 2026-08-10)

| Partition | Limit | Notes |
|---|---|---|
| `debug` | 4 h | **the test queue** — takes 1-core jobs; mixed akya/barbun/hamsi/orfoz nodes |
| `orfoz`* (default) | 3 d | main CPU fleet; 56/112-core rule above — a bare `sbatch` of a small job **fails by default** |
| `barbun` | 3 d | 2× Xeon Gold 6148 per node (40 cores) |
| `hamsi` | 3 d | general CPU |
| `smp` | 3 d | `orkinos1`, single fat-memory node |
| `akya-cuda` | 3 d | GPU, V100-class (not yet verified in this repo) |
| `barbun-cuda` | 3 d | 2× Tesla P100-PCIE-16GB per node, driver 565.57.01, CUDA 12.7 |

## Connection facts (verified 2026-08-10)

- SSH UIs: `arf-ui1`–`arf-ui5` = **172.16.6.11–.15** (older third-party guides list other IPs; this table is from the [official page](https://docs.truba.gov.tr/1-kaynaklar/arf/arf_baglanti.html)).
- Web, VPN-only: OpenOndemand (file manager / job composer / web shell) at `https://openondemand.yonetim` (172.16.6.20); Grafana cluster dashboards at `http://grafana.yonetim:3000` (172.16.6.25). If `.yonetim` names don't resolve, use the IPs.
- ARF-ACC (newer GPU cluster) is separate — it does **not** appear in `sinfo` on arf-ui.

## Windows client pitfalls

- **`ssh.exe` dies silently without a console.** Run from automation (no attached console) it exits 255 with zero output — not even `-vvv` to a redirected file. Fix: use a real terminal, or route through WSL (`wsl -d <distro> -- ssh …`). WSL note: copy the key out of `/mnt/c/...` (`cp … /tmp/k && chmod 600 /tmp/k`) or ssh refuses the 0777 drvfs permissions.
- **Don't pipe into ssh for key installation** — `type key.pub | ssh … "cat >> authorized_keys"` hangs: with stdin redirected, the password prompt never renders. Use the two-step `scp` + `ssh` from [setup.md](setup.md).
- **Turkish characters in paths** (`Masaüstü`) mangle across encoding boundaries in automation. From WSL, glob past them: `/mnt/c/Users/<you>/OneDrive/Masa*/...`.

## Storage

- Home and scratch are high-performance filesystems, **not backup** — TRUBA states data safety is your problem. Assume scratch can be purged; pull anything you care about off the cluster.

## General

- Never run compute on the UI node — the onboarding mail warns this can get the account suspended. Editing, transfers, `sbatch` are fine.
- Debug-size jobs schedule fast: both 001 jobs went from submit to finished within ~15 s polling windows.
