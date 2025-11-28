# EC2 Instance – conv-rag-machine

## Overview

- **Name**: `conv-rag-machine`
- **Purpose**: GPU worker for OCR (VLM) and RAG LLM inference

## Compute

- **AMI**: Deep Learning AMI Neuron (Ubuntu 22.04)
- **Instance type**: `g4dn.xlarge` (1× NVIDIA T4, 4 vCPUs, 16 GiB RAM)[web:33][web:67][web:246]

## Networking & Security

- **Security group rules**:
  - Inbound:
    - SSH (TCP 22) – admin access from my IP
    - HTTP (TCP 80) – web / API access
    - HTTPS (TCP 443) – secure web / API access
  - Outbound: allowed to the internet (default)

## Storage

- **Root EBS volume**:
  - Type: gp3
  - Size: **200 GiB**
  - Usage: OS, Docker images, model weights/cache, logs
