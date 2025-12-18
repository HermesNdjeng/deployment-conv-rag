#!/usr/bin/env bash
set -e

exec vllm serve "${MODEL_NAME}" \
  --host 0.0.0.0 \
  --port "${PORT}" \
  --trust-remote-code \
  --gpu-memory-utilization "${GPU_MEMORY_UTILIZATION}" \
  --max-num-seqs "${MAX_NUM_SEQS}" \
  --max-model-len "${MAX_MODEL_LEN}" \
  --logits-processors vllm.model_executor.models.deepseek_ocr:NGramPerReqLogitsProcessor \
  --no-enable-prefix-caching \
  --mm-processor-cache-gb 0
