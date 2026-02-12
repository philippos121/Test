"""
Model catalog and download manager.
Downloads GGUF models from HuggingFace with progress tracking.
Uses only Python stdlib (urllib) -- zero extra dependencies for downloading.
"""

import os
import json
import urllib.request
import urllib.error
import sys
import time
import config

# ---------------------------------------------------------------------------
# Model catalog -- small GGUF models suitable for iPhone / ISH
# ---------------------------------------------------------------------------

CATALOG = [
    {
        "id": "tinyllama-1.1b",
        "name": "TinyLlama 1.1B",
        "params": "1.1B",
        "quant": "Q4_K_M",
        "size_mb": 669,
        "ctx": 2048,
        "filename": "tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf",
        "url": "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf",
        "description": "Fastest model. Great for testing and quick responses.",
        "template": "<|system|>\n{system}</s>\n<|user|>\n{prompt}</s>\n<|assistant|>\n",
    },
    {
        "id": "phi-2",
        "name": "Phi-2 2.7B",
        "params": "2.7B",
        "quant": "Q4_K_M",
        "size_mb": 1600,
        "ctx": 2048,
        "filename": "phi-2.Q4_K_M.gguf",
        "url": "https://huggingface.co/TheBloke/phi-2-GGUF/resolve/main/phi-2.Q4_K_M.gguf",
        "description": "Microsoft's strong small model. Good reasoning ability.",
        "template": "Instruct: {prompt}\nOutput:",
    },
    {
        "id": "qwen2-0.5b",
        "name": "Qwen2 0.5B",
        "params": "0.5B",
        "quant": "Q4_K_M",
        "size_mb": 400,
        "ctx": 32768,
        "filename": "qwen2-0_5b-instruct-q4_k_m.gguf",
        "url": "https://huggingface.co/Qwen/Qwen2-0.5B-Instruct-GGUF/resolve/main/qwen2-0_5b-instruct-q4_k_m.gguf",
        "description": "Tiny but capable. Fastest inference, lowest memory.",
        "template": "<|im_start|>system\n{system}<|im_end|>\n<|im_start|>user\n{prompt}<|im_end|>\n<|im_start|>assistant\n",
    },
    {
        "id": "qwen2-1.5b",
        "name": "Qwen2 1.5B",
        "params": "1.5B",
        "quant": "Q4_K_M",
        "size_mb": 986,
        "ctx": 32768,
        "filename": "qwen2-1_5b-instruct-q4_k_m.gguf",
        "url": "https://huggingface.co/Qwen/Qwen2-1.5B-Instruct-GGUF/resolve/main/qwen2-1_5b-instruct-q4_k_m.gguf",
        "description": "Good balance of size and quality. Recommended for ISH.",
        "template": "<|im_start|>system\n{system}<|im_end|>\n<|im_start|>user\n{prompt}<|im_end|>\n<|im_start|>assistant\n",
    },
    {
        "id": "smollm-360m",
        "name": "SmolLM 360M",
        "params": "360M",
        "quant": "Q8_0",
        "size_mb": 387,
        "ctx": 2048,
        "filename": "smollm-360m-instruct-add-basics-q8_0.gguf",
        "url": "https://huggingface.co/mlx-community/SmolLM-360M-Instruct-GGUF/resolve/main/smollm-360m-instruct-add-basics-q8_0.gguf",
        "description": "Ultra-tiny model. Very fast on ISH. Good for basic tasks.",
        "template": "<|im_start|>system\n{system}<|im_end|>\n<|im_start|>user\n{prompt}<|im_end|>\n<|im_start|>assistant\n",
    },
    {
        "id": "gemma-2b",
        "name": "Gemma 2B",
        "params": "2B",
        "quant": "Q4_K_M",
        "size_mb": 1400,
        "ctx": 8192,
        "filename": "gemma-2b-it-Q4_K_M.gguf",
        "url": "https://huggingface.co/lmstudio-ai/gemma-2b-it-GGUF/resolve/main/gemma-2b-it-Q4_K_M.gguf",
        "description": "Google's compact model with solid instruction following.",
        "template": "<start_of_turn>user\n{prompt}<end_of_turn>\n<start_of_turn>model\n",
    },
    {
        "id": "llama-3.2-1b",
        "name": "Llama 3.2 1B",
        "params": "1B",
        "quant": "Q4_K_M",
        "size_mb": 800,
        "ctx": 131072,
        "filename": "Llama-3.2-1B-Instruct-Q4_K_M.gguf",
        "url": "https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf",
        "description": "Meta's latest small model. Great instruction following.",
        "template": "<|begin_of_text|><|start_header_id|>system<|end_header_id|>\n\n{system}<|eot_id|><|start_header_id|>user<|end_header_id|>\n\n{prompt}<|eot_id|><|start_header_id|>assistant<|end_header_id|>\n\n",
    },
]


def get_catalog():
    return CATALOG


def find_model(model_id):
    for m in CATALOG:
        if m["id"] == model_id:
            return m
    return None


def list_downloaded():
    downloaded = []
    for m in CATALOG:
        path = config.get_model_path(m["filename"])
        if os.path.exists(path):
            actual_size = os.path.getsize(path)
            downloaded.append({**m, "local_path": path, "actual_size": actual_size})
    return downloaded


def is_downloaded(model_id):
    m = find_model(model_id)
    if not m:
        return False
    return os.path.exists(config.get_model_path(m["filename"]))


def delete_model(model_id):
    m = find_model(model_id)
    if not m:
        return False
    path = config.get_model_path(m["filename"])
    if os.path.exists(path):
        os.remove(path)
        return True
    return False


def download_model(model_id, callback=None):
    """Download a model from HuggingFace. callback(bytes_done, total_bytes) for progress."""
    m = find_model(model_id)
    if not m:
        raise ValueError(f"Unknown model: {model_id}")

    config.init_dirs()
    dest = config.get_model_path(m["filename"])
    temp = dest + ".part"

    # Resume support
    start_byte = 0
    if os.path.exists(temp):
        start_byte = os.path.getsize(temp)

    url = m["url"]
    req = urllib.request.Request(url)
    req.add_header("User-Agent", "MiniLLM-ISH/1.0")
    if start_byte > 0:
        req.add_header("Range", f"bytes={start_byte}-")

    try:
        resp = urllib.request.urlopen(req, timeout=30)
    except urllib.error.URLError as e:
        raise ConnectionError(f"Download failed: {e}")

    if resp.status == 200:
        total = int(resp.headers.get("Content-Length", 0))
        start_byte = 0  # Server didn't support range, restart
        if os.path.exists(temp):
            os.remove(temp)
    elif resp.status == 206:
        range_header = resp.headers.get("Content-Range", "")
        total = int(range_header.split("/")[-1]) if "/" in range_header else 0
    else:
        total = int(resp.headers.get("Content-Length", 0)) + start_byte

    mode = "ab" if start_byte > 0 else "wb"
    done = start_byte
    chunk_size = 64 * 1024  # 64KB chunks (good for ISH)

    with open(temp, mode) as f:
        while True:
            chunk = resp.read(chunk_size)
            if not chunk:
                break
            f.write(chunk)
            done += len(chunk)
            if callback:
                callback(done, total)

    os.rename(temp, dest)
    return dest


def download_model_cli(model_id):
    """Download with terminal progress bar."""
    m = find_model(model_id)
    if not m:
        print(f"Error: Unknown model '{model_id}'")
        return None

    if is_downloaded(model_id):
        print(f"Model '{m['name']}' is already downloaded.")
        return config.get_model_path(m["filename"])

    print(f"Downloading {m['name']} ({config.human_size(m['size_mb'] * 1024 * 1024)})...")
    print(f"From: {m['url']}")
    print()

    start_time = time.time()
    last_print = [0]

    def progress(done, total):
        now = time.time()
        if now - last_print[0] < 0.5 and done < total:
            return
        last_print[0] = now

        elapsed = now - start_time
        speed = done / elapsed if elapsed > 0 else 0
        pct = (done / total * 100) if total > 0 else 0
        bar_len = 30
        filled = int(bar_len * done / total) if total > 0 else 0
        bar = "=" * filled + ">" + " " * (bar_len - filled - 1)

        sys.stdout.write(
            f"\r  [{bar}] {pct:5.1f}%  "
            f"{config.human_size(done)} / {config.human_size(total)}  "
            f"{config.human_size(speed)}/s   "
        )
        sys.stdout.flush()

    try:
        path = download_model(model_id, callback=progress)
        print(f"\n\nDownload complete: {path}")
        return path
    except Exception as e:
        print(f"\n\nDownload failed: {e}")
        return None
