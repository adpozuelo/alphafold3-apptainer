# AlphaFold 3 Deployment with Apptainer on AlmaLinux 10 / RHEL 10

A streamlined, production-ready guide to deploy and run **AlphaFold 3** on High-Performance Computing (HPC) environments, workstations, and servers running **AlmaLinux 10** (or RHEL 10) using immutable **Apptainer** containers with NVIDIA GPU acceleration (**NVIDIA Blackwell / Ada Lovelace / Hopper / Ampere**).

---

## 📋 Prerequisites

1. **Operating System**: AlmaLinux 10.x / RHEL 10.x (x86_64).
2. **GPU & Drivers**: NVIDIA GPU with Driver 560+ / 610+ (CUDA UMD >= 12.6, fully compatible with Blackwell architectures).
3. **Storage Requirements**:
   - ~5 GB for the Apptainer container image (`.sif`).
   - ~250 GB (compressed) / ~600 GB (uncompressed) on fast NVMe storage for biological databases.
4. **Model Parameters / Weights (`af3.bin`)**:
   - Google DeepMind provides direct public download of the AlphaFold 3 model parameters:
     - **Standard Parameters**: [https://storage.googleapis.com/alphafold3/af3.bin.zst](https://storage.googleapis.com/alphafold3/af3.bin.zst)
     - **SynthID Watermarked Parameters**: [https://storage.googleapis.com/alphafold3/af3_synthid.bin.zst](https://storage.googleapis.com/alphafold3/af3_synthid.bin.zst)
   - To download and prepare the weights in the default location:
```bash
sudo mkdir -p /opt/alphafold3/models
sudo wget -O /opt/alphafold3/models/af3.bin.zst https://storage.googleapis.com/alphafold3/af3.bin.zst
sudo unzstd /opt/alphafold3/models/af3.bin.zst
```
   - *Note: Use is subject to DeepMind's [Terms of Use](https://github.com/google-deepmind/alphafold3/blob/main/WEIGHTS_TERMS_OF_USE.md).*

---

## 🚀 Quick Start Deployment

Clone this repository on your server:
```bash
git clone https://github.com/adpozuelo/alphafold3-apptainer.git
cd alphafold3-apptainer
```

### Step 1: Install Apptainer and System Dependencies
Installs Apptainer along with unprivileged user-space mounting tools (`squashfuse`, `fuse`, `gocryptfs`):
```bash
sudo bash scripts/01_install_dependencies.sh
```

### Step 2: Download Model Weights
Download and uncompress the official model parameters into `/opt/alphafold3/models/af3.bin`:
```bash
sudo mkdir -p /opt/alphafold3/models
sudo wget -O /opt/alphafold3/models/af3.bin.zst https://storage.googleapis.com/alphafold3/af3.bin.zst
sudo unzstd /opt/alphafold3/models/af3.bin.zst
```

### Step 3: Download Biological Reference Databases
*(Requires high-speed internet connectivity and ~600 GB of free NVMe space)*:
```bash
sudo bash scripts/02_download_databases.sh /opt/alphafold3/public_databases
```

### Step 4: Build the Immutable Apptainer Container
Compiles the `.sif` image using the optimized definition file `AF3.def` (native AVX-512 compilation for HMMER 3.4, DeepMind `jackhmmer_seq_limit` memory safety patch, and pre-indexed chemical components using `uv`):
```bash
sudo bash scripts/03_build_container.sh /opt/alphafold3
```

### Step 5: Install the System Wrapper
Exposes the `alphafold3` command globally so users do not need to memorize Apptainer mount flags or paths:
```bash
sudo bash scripts/04_install_wrapper.sh
```

### Step 6: Fast GPU Inference Validation (< 30 seconds)
Runs a validation inference on the GPU using a precalculated test dataset (ubiquitin) to verify JAX, Triton Flash Attention, and model weights without waiting for database searches:
```bash
bash scripts/05_run_test.sh
```

---

## 💡 Usage Workflows

### 1. End-to-End Execution (CPU Search + GPU Inference)
Best for standalone workstations with direct access to reference databases:
```bash
alphafold3 --json_path=/path/to/protein.json --output_dir=./results
```

### 2. Decoupled HPC Workflow (Slurm / PBS Clusters)
In multi-node HPC clusters with distinct CPU compute nodes and GPU partitions, decouple the stages to optimize resource allocation:

* **Stage 1 (CPU Nodes)**: Genetic database searches (HMMER):
```bash
alphafold3 --json_path=input.json --output_dir=./output --run_inference=false
```
  *(Produces precalculated alignment features: `output/<job_name>/<job_name>_data.json`)*

* **Stage 2 (GPU Partitions)**: Diffusion model structure inference:
```bash
alphafold3 --json_path=./output/<job_name>/<job_name>_data.json --output_dir=./output --run_data_pipeline=false
```

### 3. GPU Device Selection (Multi-GPU Systems)
To target a specific GPU (e.g. GPU 0 or GPU 1):
```bash
alphafold3 --json_path=input.json --gpu_device=1
```

---

## 📁 Repository Structure

```text
.
├── README.md                         # Project documentation and deployment guide
├── container/
│   └── AF3.def                       # Apptainer definition file (Ubuntu 24.04 + Python 3.12)
├── bin/
│   └── alphafold3                    # Universal wrapper abstracting container mounts
├── scripts/
│   ├── 01_install_dependencies.sh    # Installs Apptainer, FUSE, and build utilities
│   ├── 02_download_databases.sh     # Downloads public reference databases
│   ├── 03_build_container.sh         # Builds alphafold3.sif using NVMe cache
│   ├── 04_install_wrapper.sh         # Symlinks wrapper into /usr/local/bin
│   └── 05_run_test.sh                # 25-second GPU validation test
└── examples/
    ├── ubiquitin_monomer.json        # Raw FASTA sequence JSON for full pipeline
    └── ubiquitin_test_data.json      # Precomputed data for immediate GPU testing
```

---

## 📄 License

- Deployment automation scripts in this repository are licensed under the Apache-2.0 License.
- AlphaFold 3 source code is licensed by **Google DeepMind Technologies Limited** under Apache-2.0.
- Model parameters are governed by the [DeepMind Model Parameters Terms of Use](https://github.com/google-deepmind/alphafold3/blob/main/WEIGHTS_TERMS_OF_USE.md).
