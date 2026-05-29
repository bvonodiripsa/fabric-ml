# Notebook Testing Report — May 28, 2026

## Environment

| Item | Detail |
|------|--------|
| VM | Azure Linux 3, 64-core AMD EPYC 7V12 |
| GPU | 4x Tesla T4 (16 GB each) |
| Conda env | `PureComputePython313GPU` at `/opt/miniforge3/envs/PureComputePython313GPU` |
| Python | 3.13 |
| CUDA Driver | 580.126.16, CUDA 13.0 |
| cuDF | 26.04 |
| cuML | 26.04 |
| PyTorch | 2.9.1 |

## Problems Found & Fixed

| Problem | Fix Applied |
|---------|-------------|
| **iptables blocking port 8888** after VM reboot | Added inbound rule for user IP |
| **CuPy float16 compile failure** — NVRTC couldn't find `cuda_fp16.h` | Symlinked CUDA headers from `targets/x86_64-linux/include/` to `include/` |
| **`cudf_pandas_demo.ipynb`** — `do_shutdown(restart=True)` kills kernel | Moved `%load_ext cudf.pandas` to top, removed kernel restart |
| **`cudf_pandas_stocks_demo.ipynb`** — same kernel restart pattern | Same fix: `%load_ext cudf.pandas` at top, removed restart |
| **`cuml_sklearn_colab_demo.ipynb`** — two `do_shutdown(restart=True)` calls | Moved `%load_ext cuml.accel` to top, removed both restarts |
| **`cuml_sklearn_colab_demo.ipynb`** — HAR dataset not pre-downloaded | Downloaded and extracted to `/tmp/HAR_data/` |
| **`cvar_basic.ipynb`** — wrong kernel name `cufolio-dli` | Changed to `python3` kernel |

## Packages Installed

| Package | Reason |
|---------|--------|
| `plotnine` | Required by `cudf_pandas_stocks_demo.ipynb` |
| `hdbscan` | Required by `cuml_sklearn_colab_demo.ipynb` |
| `umap-learn` | Required by `cuml_sklearn_colab_demo.ipynb` |
| `scanpy` | Required by `01_scRNA_analysis_preprocessing.ipynb` |
| `rapids-singlecell` | Required by `01_scRNA_analysis_preprocessing.ipynb` |
| `cvxpy` | Required by `cvar_basic.ipynb` |

## Results

| Notebook | Status | Notes |
|----------|--------|-------|
| `cudf_pandas_demo.ipynb` | **PASS** | Fixed kernel restart; runs clean |
| `cudf_pandas_stocks_demo.ipynb` | **PASS** | Fixed kernel restart; runs ~8min |
| `cuml_sklearn_colab_demo.ipynb` | **PASS** | Fixed 2 kernel restarts + downloaded data |
| `gpu_vs_cpu_benchmark.ipynb` | **PASS** | Previously validated (PyTorch benchmarks) |
| `rapids_gpu_vs_cpu.ipynb` | **PASS** | Previously validated (cuDF/cuML benchmarks) |
| `embedding_knn_ray_rapids.ipynb` | **PASS** | Previously validated (Ray + RAPIDS + GPT) |
| `01_scRNA_analysis_preprocessing.ipynb` | **CANNOT RUN** | GPU OOM — needs >4 GB on single T4 after other allocations |
| `TopicModelingAtTheSpeedOfLight.ipynb` | **CANNOT RUN** | API mismatch: cuml.hdbscan passes 4 args to `hdbscan.plots.CondensedTree` which only accepts 3 (cuml 26.04 vs hdbscan 0.8.43) |
| `cvar_basic.ipynb` | **CANNOT RUN** | Requires `cufolio` — proprietary NVIDIA DLI course package, not publicly available |

## Recommendations

1. **`01_scRNA`**: Reduce dataset size or use multi-GPU RMM pool to avoid OOM
2. **`TopicModeling`**: Pin `hdbscan==0.8.40` or wait for cuml patch matching new hdbscan API
3. **`cvar_basic`**: Only runnable in NVIDIA DLI course environment where `cufolio` is pre-installed
