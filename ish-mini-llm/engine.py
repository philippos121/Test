"""
LLM inference engine.
Wraps llama-cpp-python for on-device inference in ISH.
Falls back to a stub mode if llama-cpp-python is not installed.
"""

import os
import sys
import time
import json
import config
import models as model_catalog

# Try to import llama-cpp-python
_LLAMA_AVAILABLE = False
try:
    from llama_cpp import Llama
    _LLAMA_AVAILABLE = True
except ImportError:
    pass


class InferenceEngine:
    """On-device LLM inference using llama.cpp via llama-cpp-python."""

    def __init__(self):
        self.model = None
        self.model_info = None
        self.model_path = None
        self.cfg = config.load_config()

    def is_available(self):
        return _LLAMA_AVAILABLE

    def is_loaded(self):
        return self.model is not None

    def get_model_info(self):
        return self.model_info

    def load(self, model_id):
        """Load a GGUF model into memory."""
        if not _LLAMA_AVAILABLE:
            raise RuntimeError(
                "llama-cpp-python is not installed.\n"
                "Install it with: pip3 install llama-cpp-python\n"
                "Or run: sh install.sh"
            )

        meta = model_catalog.find_model(model_id)
        if not meta:
            raise ValueError(f"Unknown model: {model_id}")

        path = config.get_model_path(meta["filename"])
        if not os.path.exists(path):
            raise FileNotFoundError(
                f"Model file not found: {path}\n"
                f"Download it first with: python3 app.py download {model_id}"
            )

        # Unload previous model
        self.unload()

        print(f"Loading {meta['name']}...")
        start = time.time()

        self.model = Llama(
            model_path=path,
            n_ctx=min(self.cfg["context_size"], meta["ctx"]),
            n_threads=self.cfg["threads"],
            n_gpu_layers=self.cfg["gpu_layers"],
            verbose=False,
        )

        elapsed = time.time() - start
        self.model_info = meta
        self.model_path = path
        print(f"Model loaded in {elapsed:.1f}s")

        # Save as default
        self.cfg["default_model"] = model_id
        config.save_config(self.cfg)

        return True

    def unload(self):
        """Unload current model and free memory."""
        if self.model is not None:
            del self.model
            self.model = None
            self.model_info = None
            self.model_path = None

    def generate(self, prompt, system_prompt=None, max_tokens=None,
                 temperature=None, top_p=None, stop=None, stream=False):
        """Generate text from prompt. Returns string or generator if stream=True."""
        if not self.is_loaded():
            raise RuntimeError("No model loaded. Load one first.")

        cfg = self.cfg
        max_tokens = max_tokens or cfg["max_tokens"]
        temperature = temperature if temperature is not None else cfg["temperature"]
        top_p = top_p or cfg["top_p"]
        system_prompt = system_prompt or cfg["system_prompt"]

        # Format with model template
        formatted = self._apply_template(prompt, system_prompt)

        if stream:
            return self._generate_stream(formatted, max_tokens, temperature, top_p, stop)
        else:
            return self._generate_full(formatted, max_tokens, temperature, top_p, stop)

    def _generate_full(self, prompt, max_tokens, temperature, top_p, stop):
        result = self.model(
            prompt,
            max_tokens=max_tokens,
            temperature=temperature,
            top_p=top_p,
            stop=stop or [],
            repeat_penalty=self.cfg["repeat_penalty"],
            echo=False,
        )
        text = result["choices"][0]["text"]
        usage = result.get("usage", {})
        return {
            "text": text.strip(),
            "prompt_tokens": usage.get("prompt_tokens", 0),
            "completion_tokens": usage.get("completion_tokens", 0),
            "total_tokens": usage.get("total_tokens", 0),
        }

    def _generate_stream(self, prompt, max_tokens, temperature, top_p, stop):
        stream = self.model(
            prompt,
            max_tokens=max_tokens,
            temperature=temperature,
            top_p=top_p,
            stop=stop or [],
            repeat_penalty=self.cfg["repeat_penalty"],
            echo=False,
            stream=True,
        )
        for output in stream:
            token = output["choices"][0]["text"]
            if token:
                yield token

    def _apply_template(self, prompt, system_prompt):
        """Apply the model's chat template."""
        if not self.model_info:
            return prompt

        template = self.model_info.get("template", "{prompt}")
        formatted = template.replace("{prompt}", prompt)
        formatted = formatted.replace("{system}", system_prompt)
        return formatted

    def chat(self, messages, max_tokens=None, temperature=None,
             top_p=None, stream=False):
        """OpenAI-style chat completion with message list."""
        if not self.is_loaded():
            raise RuntimeError("No model loaded.")

        system = self.cfg["system_prompt"]
        conversation = ""

        for msg in messages:
            role = msg.get("role", "user")
            content = msg.get("content", "")
            if role == "system":
                system = content
            elif role == "user":
                conversation += f"User: {content}\n"
            elif role == "assistant":
                conversation += f"Assistant: {content}\n"

        # Use the last user message as the prompt
        last_user = ""
        for msg in reversed(messages):
            if msg.get("role") == "user":
                last_user = msg["content"]
                break

        return self.generate(
            prompt=last_user if not conversation else conversation.strip(),
            system_prompt=system,
            max_tokens=max_tokens,
            temperature=temperature,
            top_p=top_p,
            stream=stream,
        )

    def count_tokens(self, text):
        """Count tokens in text using the loaded model's tokenizer."""
        if not self.is_loaded():
            # Rough estimate: ~4 chars per token
            return len(text) // 4
        tokens = self.model.tokenize(text.encode("utf-8"))
        return len(tokens)


# Singleton
_engine = None


def get_engine():
    global _engine
    if _engine is None:
        _engine = InferenceEngine()
    return _engine
