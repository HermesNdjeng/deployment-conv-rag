# VM Instance from Hyperstack – radiant-bohr

## Overview

- **Name**: `radiant-bohr`
- **Purpose**: GPU worker for OCR (VLM) and RAG LLM inference

## Compute

- **Os Image**: Ubuntu Server 22.04 LTS R535 CUDA 12.2
- **Instance type**: 1 L40 28 CPUs 58GB RAM 100GB Disk (root)

## Networking & Security

- **Security group rules**:
  - Inbound:
    - SSH (TCP 22) – admin access from my IP
    - HTTP (TCP 80) – web / API access
    - HTTPS (TCP 443) – secure web / API access
  - Outbound: allowed to the internet (default)
