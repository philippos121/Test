"""
MiniLLM configuration and path management.
All paths are relative to ~/.minillm/ for clean ISH storage.
"""

import os
import json

BASE_DIR = os.path.expanduser("~/.minillm")
MODELS_DIR = os.path.join(BASE_DIR, "models")
DATASETS_DIR = os.path.join(BASE_DIR, "datasets")
ADAPTERS_DIR = os.path.join(BASE_DIR, "adapters")
HISTORY_DIR = os.path.join(BASE_DIR, "history")
CONFIG_FILE = os.path.join(BASE_DIR, "config.json")

DEFAULT_CONFIG = {
    "default_model": None,
    "server_port": 8080,
    "server_host": "0.0.0.0",
    "context_size": 2048,
    "threads": 4,
    "temperature": 0.7,
    "top_p": 0.9,
    "max_tokens": 512,
    "repeat_penalty": 1.1,
    "gpu_layers": 0,  # ISH has no GPU acceleration
    "system_prompt": "You are a helpful AI assistant running locally on an iPhone.",
}


def init_dirs():
    for d in [BASE_DIR, MODELS_DIR, DATASETS_DIR, ADAPTERS_DIR, HISTORY_DIR]:
        os.makedirs(d, exist_ok=True)


def load_config():
    init_dirs()
    if os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE, "r") as f:
            saved = json.load(f)
        cfg = {**DEFAULT_CONFIG, **saved}
    else:
        cfg = dict(DEFAULT_CONFIG)
    return cfg


def save_config(cfg):
    init_dirs()
    with open(CONFIG_FILE, "w") as f:
        json.dump(cfg, f, indent=2)


def get_model_path(filename):
    return os.path.join(MODELS_DIR, filename)


def get_dataset_path(name):
    return os.path.join(DATASETS_DIR, f"{name}.jsonl")


def get_adapter_path(name):
    return os.path.join(ADAPTERS_DIR, name)


def get_history_path(name):
    return os.path.join(HISTORY_DIR, f"{name}.json")


def human_size(nbytes):
    for unit in ["B", "KB", "MB", "GB"]:
        if nbytes < 1024:
            return f"{nbytes:.1f} {unit}"
        nbytes /= 1024
    return f"{nbytes:.1f} TB"
