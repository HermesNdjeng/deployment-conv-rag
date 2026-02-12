# Deployment Conv-RAG

Production-ready deployment setup for conversational LLM and OCR solutions using vLLM.

## Overview

This repository contains:
- **LLM Service**: Conversational AI with Qwen 2.5-3B model
- **OCR Solutions**: Multiple OCR services (DOTS, DeepSeek) for document processing
- **CI/CD Pipelines**: Automated building, testing, and deployment to AWS EC2
- **Infrastructure Documentation**: Setup guides and deployment instructions

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    GitHub Actions CI/CD                 │
├─────────────────────────────────────────────────────────┤
│  • Pre-commit checks (Ruff, Pyright, hadolint)         │
│  • Docker image build & push to Docker Hub             │
│  • Automated deployment to EC2 instances               │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│                    Docker Hub Registry                  │
├─────────────────────────────────────────────────────────┤
│  • your_dockerhub_username/rag-llm:latest                            │
│  • your_dockerhub_username/dots-ocr:latest                           │
│  • your_dockerhub_username/deepseek-ocr:latest                       │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│                    AWS EC2 GPU Instance                │
├─────────────────────────────────────────────────────────┤
│  • LLM Service (Port 8000)                         │
│  • OCR Services (Port 8001+)                           │
│  • Exposed via API Gateway / Load Balancer             │
└─────────────────────────────────────────────────────────┘
```

## Quick Start

### Prerequisites

- Docker & Docker Buildx
- Any VM instance with GPU (NVIDIA CUDA 12.1+) with docker installed
- Hugging Face API token
- vLLM API key for authentication

### Local Development

**1. Build  LLM image:**
```bash
docker buildx build \
  --platform=linux/amd64 \
  -f docker/Dockerfile.rag-llm \
  -t your_dockerhub_username/rag-llm:latest .
```

**2. Run  service locally:**
```bash
docker run -d --gpus all \
  -p 8000:8000 \
  --ipc=host \
  -e HUGGING_FACE_HUB_TOKEN="hf_..." \
  --name rag-llm \
  your_dockerhub_username/rag-llm:latest \
  --api-key "your-api-key"
```

**3. Test the API:**
```bash
curl -H "Authorization: Bearer your-api-key" \
  http://localhost:8000/v1/models
```

### Deployment to EC2

The CI/CD pipelines automatically build and deploy when you push to `main`. Manual deployment:

**1. SSH into EC2:**
```bash
ssh -i ~/.ssh/ec2_key ubuntu@your-ec2-host
```

**2. Pull and run  service:**
```bash
docker pull your_dockerhub_username/rag-llm:latest
docker run -d --gpus all \
  -p 8000:8000 \
  --ipc=host \
  -e HUGGING_FACE_HUB_TOKEN="hf_..." \
  --name rag-llm \
  your_dockerhub_username/rag-llm:latest \
  --api-key "your-api-key"
```

**3. Pull and run OCR service:**
```bash
docker pull your_dockerhub_username/dots-ocr:latest
docker run -d --gpus all \
  -p 8001:8000 \
  --ipc=host \
  -e HUGGING_FACE_HUB_TOKEN="hf_..." \
  --name dots-ocr \
  your_dockerhub_username/dots-ocr:latest \
  --api-key "your-api-key"
```



## Services

###  LLM Service
- **Model**: Qwen/Qwen2.5-3B-Instruct
- **Port**: 8000
- **Max sequence length**: 8192
- **GPU memory utilization**: 90%
- **Max concurrent requests**: 64

### OCR Services

#### DOTS OCR
- **Model**: rednote-hilab/dots.ocr
- **Port**: 8001
- **Use case**: Document and table OCR

#### DeepSeek OCR
- **Model**: DeepSeek vision model
- **Port**: 8002
- **Use case**: Advanced visual document understanding

## CI/CD Pipelines

### Pre-commit Checks (`pre-commit.yml`)
Runs on every push to `main` and pull requests:
- Python linting (Ruff)
- Type checking (Pyright)
- Dockerfile linting (hadolint)
- YAML/JSON validation

**Trigger**: Any commit to `main`

###  LLM Deployment (`deploy-llm.yml`)
Builds and deploys  service **only when  Dockerfile changes**:
- Builds Docker image
- Pushes to Docker Hub with `latest` and commit SHA tags
- Deploys to VM instance

**Trigger**: Changes to `docker/Dockerfile.rag-llm` on `main` branch

### OCR Deployment (`deploy-ocr.yml`)
Builds and deploys OCR service **only when OCR Dockerfile changes**:
- Builds Docker image
- Pushes to Docker Hub
- Deploys to VM instance

**Trigger**: Changes to `docker/Dockerfile.deepseek-ocr-vllm` on `main` branch

**Note**: Each service deploys independently. Push changes to `Dockerfile.rag-llm` to trigger  deployment, or `Dockerfile.deepseek-ocr-vllm` to trigger OCR deployment.


## GitHub Secrets Required

Add these in Settings → Secrets and variables → Actions:

```
DOCKERHUB_USERNAME          # Docker Hub username
DOCKERHUB_TOKEN             # Docker Hub access token
EC2_HOST                    # EC2 instance public/private IP
EC2_USER                    # EC2 SSH user (ubuntu)
EC2_SSH_KEY                 # EC2 private SSH key
HUGGING_FACE_HUB_TOKEN     # HuggingFace API token
VLLM_API_KEY               # vLLM API authentication key
```

## Project Structure

```
deployment-conv-rag/
├── docker/
│   ├── Dockerfile.rag-llm              #  LLM service
│   ├── Dockerfile.deepseek-ocr-vllm   # DeepSeek OCR service
│   ├── Dockerfile.dots-ocr-vllm       # DOTS OCR service (if exists)
│   └── entrypoint.deepseek-ocr.sh     # OCR entrypoint script
├── .github/workflows/
│   ├── pre-commit.yml                 # Code quality checks
│   ├── deploy-llm.yml                 #  LLM deployment
│   └── deploy-ocr.yml                 # OCR deployment
├── infra_documentation/
│   └── ec2_setup.md                   # EC2 setup guide
├── .pre-commit-config.yaml            # Pre-commit configuration
├── README.md                          # This file
└── .gitignore
```


## Troubleshooting

### Docker is not installed in the VM
Ensure docker is installed in the VM. To download:
```bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable --now docker
```


### GPU not detected
```bash
# Check GPU on VM
nvidia-smi

# Ensure Docker GPU support
docker run --gpus all nvidia/cuda:12.1.0-base nvidia-smi
```

### Out of disk space
```bash
# Clean up Docker
docker system prune -a -f --volumes

# Check disk usage
df -h
```

### Model download issues
```bash
# Verify HuggingFace token
echo $HUGGING_FACE_HUB_TOKEN

# Pre-download model
docker run -e HUGGING_FACE_HUB_TOKEN="hf_..." \
  -v ~/.cache/huggingface:/root/.cache/huggingface \
  your_dockerhub_username/rag-llm:latest \
  --trust-remote-code
```

### Container won't start
```bash
# View detailed logs
docker logs dots-ocr

# Check container status
docker ps -a
docker inspect dots-ocr
```

## Documentation

- [EC2 Setup Guide](infra_documentation/ec2_setup.md) - Infrastructure setup instructions
- [vLLM Documentation](https://docs.vllm.ai/) - vLLM server configuration
- [Qwen Model Card](https://huggingface.co/Qwen/Qwen2.5-3B-Instruct) - Model details

## Performance Tuning

### Optimize GPU memory
Adjust in Dockerfile or at runtime:
```bash
--gpu-memory-utilization 0.95  # Increase from 0.90
--max-num-seqs 128             # Increase from 64
```

### Reduce latency
```bash
--tensor-parallel-size 1       # For multi-GPU setups
--dtype auto                   # Auto-detect optimal precision
```

## Contributing

1. Create a feature branch
2. Make changes
3. Run pre-commit checks: `pre-commit run --all-files`
4. Push to GitHub (CI/CD runs automatically)
5. Create a pull request

## License

Internal use only

## Support

For issues or questions:
- Check [EC2 Setup Guide](infra_documentation/ec2_setup.md)
- Review workflow logs in GitHub Actions
- Check Docker logs on EC2
