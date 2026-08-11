# 003 — Mandelbrot as a job array

**Date:** 2026-08-11 · **Cluster:** ARF · **Jobs:** 6224492 (array `0-49%10`) → 6224543 (stitcher, `afterok`)

## Goal

First multi-job workflow: a Slurm **job array** fans 50 independent tasks out, a **dependency job** assembles the result. Deliverable: one pretty picture, made of strips.

## Method

- [`mandel.c`](mandel.c) renders rows `[row0, row1)` of a 2800×2000 view (x ∈ [−2.55, 0.95], y ∈ [−1.25, 1.25], 2000 iterations, smooth-ν cosine palette) as raw RGB bytes — no image library needed anywhere on the cluster.
- [`job.slurm`](job.slurm): `--array=0-49%10`, each task compiles to node-local `/tmp` and writes one 40-row strip (`tile_%03d.ppmraw` — zero-padding *is* the ordering).
- [`stitch.slurm`](stitch.slurm), submitted with `--dependency=afterok:6224492`: prints a P6 header and `cat`s the strips. 16,800,017 bytes = 2800×2000×3 + 17-byte header, exactly.
- PPM pulled off the cluster and converted/verified locally.

## Results

![mandelbrot](results/mandelbrot.png)

- The `%10` throttle packed all 50 tasks onto **2 nodes** (barbun2 ×30, barbun124 ×20); slowest strip took 2 s; the stitcher ran in under a second. Total compute: ~50 core-seconds for the whole image.
- Seam check across strip boundaries (rows 39/40, 999/1000): pixel-identical gradients — no stitching artifacts.

## Lessons

- `--array` + `%N` throttle + `--dependency=afterok:<id>` is the entire orchestration vocabulary needed for fan-out/fan-in — no workflow engine required at this scale.
- Raw fixed-size chunks with zero-padded names make assembly a `cat` — worth remembering for any strip-parallel output, not just images.
- An array this small schedules as fast as a single job; the queue overhead story only starts mattering with thousands of tasks.
