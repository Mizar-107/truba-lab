#!/usr/bin/env python3
"""005 — What can a 2016 Tesla P100 still do? matmul TFLOPS, memory bandwidth, and a training loop."""
import time
import torch

def sync():
    torch.cuda.synchronize()

def main():
    assert torch.cuda.is_available(), "no CUDA device visible"
    dev = torch.device("cuda")
    p = torch.cuda.get_device_properties(0)
    print(f"device: {p.name}")
    print(f"capability: sm_{p.major}{p.minor}")
    print(f"memory: {p.total_memory / 2**30:.1f} GiB")
    print(f"torch: {torch.__version__} (cuda {torch.version.cuda})")

    print("\n=== matmul TFLOPS (20 reps) ===")
    for dtype, label in ((torch.float32, "fp32"), (torch.float16, "fp16")):
        for n in (2048, 4096, 8192):
            try:
                a = torch.randn(n, n, device=dev, dtype=dtype)
                b = torch.randn(n, n, device=dev, dtype=dtype)
                for _ in range(3):
                    a @ b
                sync(); t0 = time.perf_counter()
                for _ in range(20):
                    a @ b
                sync(); t = time.perf_counter() - t0
                print(f"{label} {n}x{n}: {2 * n**3 * 20 / t / 1e12:.2f} TFLOPS")
                del a, b
            except RuntimeError as e:
                print(f"{label} {n}x{n}: FAILED ({e})")
        torch.cuda.empty_cache()

    print("\n=== memory bandwidth ===")
    x = torch.empty(2**28, device=dev)                     # 1 GiB fp32
    y = torch.empty_like(x)
    y.copy_(x); sync(); t0 = time.perf_counter()
    for _ in range(20):
        y.copy_(x)
    sync(); t = time.perf_counter() - t0
    print(f"device copy (read+write): {2 * x.numel() * 4 * 20 / t / 1e9:.1f} GB/s")
    h = torch.empty(2**28, pin_memory=True)
    sync(); t0 = time.perf_counter()
    for _ in range(10):
        x.copy_(h, non_blocking=True)
    sync(); t = time.perf_counter() - t0
    print(f"H2D over PCIe (pinned): {h.numel() * 4 * 10 / t / 1e9:.1f} GB/s")
    del x, y, h
    torch.cuda.empty_cache()

    print("\n=== training loop (MLP, synthetic data) ===")
    torch.manual_seed(0)
    model = torch.nn.Sequential(
        torch.nn.Linear(1024, 2048), torch.nn.ReLU(),
        torch.nn.Linear(2048, 2048), torch.nn.ReLU(),
        torch.nn.Linear(2048, 10),
    ).to(dev)
    X = torch.randn(51200, 1024, device=dev)
    Y = torch.randint(0, 10, (51200,), device=dev)
    opt = torch.optim.Adam(model.parameters(), lr=1e-3)
    loss_fn = torch.nn.CrossEntropyLoss()
    steps, bs = 300, 512
    sync(); t0 = time.perf_counter()
    for s in range(steps):
        i = (s * bs) % (51200 - bs)
        loss = loss_fn(model(X[i:i + bs]), Y[i:i + bs])
        opt.zero_grad(); loss.backward(); opt.step()
        if s % 100 == 0 or s == steps - 1:
            print(f"step {s}: loss {loss.item():.4f}")
    sync(); t = time.perf_counter() - t0
    print(f"training: {steps / t:.1f} steps/s, {steps * bs / t:.0f} samples/s")

if __name__ == "__main__":
    main()
