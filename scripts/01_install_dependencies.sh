#!/bin/bash
set -e
echo "=== [1/5] Installing Apptainer and system dependencies on AlmaLinux / RHEL 10 ==="
dnf install -y epel-release || true
dnf install -y apptainer squashfuse fuse fuse-libs fuse-devel gocryptfs git wget curl zstd tar
echo "=== Apptainer and dependencies successfully installed ==="
apptainer --version
