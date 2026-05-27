# Startup Benchmark Validation Report

This report presents the physical device cold boot startup benchmarks for the Grow~ Release Candidate 5 (RC5) build, measured in profile mode.

---

## 1. Methodology & Environment

- **Device Model**: Vivo 1726 (Android 8.1.0, SDK 27, Arm64 architecture, 3 GB RAM)
- **Compilation Mode**: Profile Mode (AOT compiled, identical performance characteristics to Release mode, with VM service logging enabled).
- **Compilation Command**:
  ```powershell
  flutter run --profile -d 69WGKNCYLRLJSOMB --dart-define-from-file=.env
  ```
- **Measurement Method**: A high-resolution stopwatch is initialized at the top-level of `main()` and evaluated after the first shell layout frame finishes rendering.
- **Benchmark Run Protocol**: The application was completely terminated, cache stabilized, and launched from a cold boot state 5 consecutive times to establish statistics.

---

## 2. Benchmark Log & Results

| Run Sequence | Startup Time (ms) | Log Source |
| :---: | :---: | :--- |
| Run 1 | 498 ms | `[Grow~][PERF] Startup: 498ms` |
| Run 2 | 365 ms | `[Grow~][PERF] Startup: 365ms` |
| Run 3 | 353 ms | `[Grow~][PERF] Startup: 353ms` |
| Run 4 | 349 ms | `[Grow~][PERF] Startup: 349ms` |
| Run 5 | 389 ms | `[Grow~][PERF] Startup: 389ms` |

---

## 3. Summary Statistics

- **Minimum Startup Time**: **349 ms**
- **Maximum Startup Time**: **498 ms**
- **Average Startup Time**: **390.8 ms**

All benchmarks indicate that cold startup takes significantly less than the target threshold of **800ms**. The background initialization system (which defers non-critical Firebase/Supabase queries to a post-frame callback) successfully prevents thread blocking during the critical boot sequence.
