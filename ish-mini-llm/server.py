"""
OpenAI-compatible API server + Web UI server.
Uses only Python stdlib (http.server) -- zero extra dependencies.
Serves the web UI and provides API endpoints at the same time.
"""

import os
import json
import time
import threading
import uuid
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import engine
import config
import models as model_catalog

_server = None
_server_thread = None

# Track requests for stats
_request_log = []


class APIHandler(BaseHTTPRequestHandler):
    """Handles both API and Web UI requests."""

    def log_message(self, format, *args):
        # Suppress default logging
        pass

    def _send_json(self, data, status=200):
        body = json.dumps(data).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization")
        self.end_headers()
        self.wfile.write(body)

    def _send_html(self, html, status=200):
        body = html.encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _send_sse(self, generator):
        """Send Server-Sent Events for streaming."""
        self.send_response(200)
        self.send_header("Content-Type", "text/event-stream")
        self.send_header("Cache-Control", "no-cache")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()

        msg_id = f"chatcmpl-{uuid.uuid4().hex[:8]}"
        eng = engine.get_engine()
        model_name = eng.model_info["id"] if eng.model_info else "unknown"

        for token in generator:
            chunk = {
                "id": msg_id,
                "object": "chat.completion.chunk",
                "created": int(time.time()),
                "model": model_name,
                "choices": [{
                    "index": 0,
                    "delta": {"content": token},
                    "finish_reason": None,
                }],
            }
            self.wfile.write(f"data: {json.dumps(chunk)}\n\n".encode())
            self.wfile.flush()

        # Send final chunk
        final = {
            "id": msg_id,
            "object": "chat.completion.chunk",
            "created": int(time.time()),
            "model": model_name,
            "choices": [{
                "index": 0,
                "delta": {},
                "finish_reason": "stop",
            }],
        }
        self.wfile.write(f"data: {json.dumps(final)}\n\n".encode())
        self.wfile.write(b"data: [DONE]\n\n")
        self.wfile.flush()

    def _read_body(self):
        length = int(self.headers.get("Content-Length", 0))
        if length == 0:
            return {}
        raw = self.rfile.read(length)
        return json.loads(raw)

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization")
        self.end_headers()

    def do_GET(self):
        path = urlparse(self.path).path

        # Web UI
        if path == "/" or path == "/ui":
            return self._serve_web_ui()

        # API endpoints
        if path == "/v1/models":
            return self._handle_models()
        if path == "/health":
            return self._handle_health()
        if path == "/v1/status":
            return self._handle_status()

        self._send_json({"error": "Not found"}, 404)

    def do_POST(self):
        path = urlparse(self.path).path
        start = time.time()

        try:
            if path == "/v1/chat/completions":
                result = self._handle_chat_completions()
            elif path == "/v1/completions":
                result = self._handle_completions()
            elif path == "/v1/models/load":
                result = self._handle_load_model()
            elif path == "/v1/models/download":
                result = self._handle_download_model()
            else:
                return self._send_json({"error": "Not found"}, 404)

            elapsed = time.time() - start
            _request_log.append({
                "path": path,
                "time": elapsed,
                "timestamp": time.time(),
            })
            # Keep last 100 requests
            if len(_request_log) > 100:
                _request_log.pop(0)
            return result

        except Exception as e:
            return self._send_json({"error": str(e)}, 500)

    def _handle_chat_completions(self):
        body = self._read_body()
        messages = body.get("messages", [])
        max_tokens = body.get("max_tokens", 512)
        temperature = body.get("temperature", 0.7)
        top_p = body.get("top_p", 0.9)
        stream = body.get("stream", False)

        eng = engine.get_engine()
        if not eng.is_loaded():
            return self._send_json({"error": "No model loaded"}, 503)

        if stream:
            gen = eng.chat(messages, max_tokens=max_tokens,
                          temperature=temperature, top_p=top_p, stream=True)
            return self._send_sse(gen)

        result = eng.chat(messages, max_tokens=max_tokens,
                         temperature=temperature, top_p=top_p)

        response = {
            "id": f"chatcmpl-{uuid.uuid4().hex[:8]}",
            "object": "chat.completion",
            "created": int(time.time()),
            "model": eng.model_info["id"] if eng.model_info else "unknown",
            "choices": [{
                "index": 0,
                "message": {"role": "assistant", "content": result["text"]},
                "finish_reason": "stop",
            }],
            "usage": {
                "prompt_tokens": result.get("prompt_tokens", 0),
                "completion_tokens": result.get("completion_tokens", 0),
                "total_tokens": result.get("total_tokens", 0),
            },
        }
        self._send_json(response)

    def _handle_completions(self):
        body = self._read_body()
        prompt = body.get("prompt", "")
        max_tokens = body.get("max_tokens", 512)
        temperature = body.get("temperature", 0.7)

        eng = engine.get_engine()
        if not eng.is_loaded():
            return self._send_json({"error": "No model loaded"}, 503)

        result = eng.generate(prompt=prompt, max_tokens=max_tokens,
                             temperature=temperature)

        response = {
            "id": f"cmpl-{uuid.uuid4().hex[:8]}",
            "object": "text_completion",
            "created": int(time.time()),
            "model": eng.model_info["id"] if eng.model_info else "unknown",
            "choices": [{
                "text": result["text"],
                "index": 0,
                "finish_reason": "stop",
            }],
            "usage": {
                "prompt_tokens": result.get("prompt_tokens", 0),
                "completion_tokens": result.get("completion_tokens", 0),
                "total_tokens": result.get("total_tokens", 0),
            },
        }
        self._send_json(response)

    def _handle_models(self):
        eng = engine.get_engine()
        downloaded = model_catalog.list_downloaded()

        data = []
        for m in downloaded:
            data.append({
                "id": m["id"],
                "object": "model",
                "created": int(time.time()),
                "owned_by": "local",
                "loaded": eng.is_loaded() and eng.model_info and eng.model_info["id"] == m["id"],
            })

        self._send_json({"object": "list", "data": data})

    def _handle_health(self):
        eng = engine.get_engine()
        self._send_json({
            "status": "ok",
            "model_loaded": eng.is_loaded(),
            "model": eng.model_info["id"] if eng.model_info else None,
            "requests_served": len(_request_log),
        })

    def _handle_status(self):
        eng = engine.get_engine()
        downloaded = model_catalog.list_downloaded()
        self._send_json({
            "engine_available": eng.is_available(),
            "model_loaded": eng.is_loaded(),
            "current_model": eng.model_info if eng.model_info else None,
            "downloaded_models": [m["id"] for m in downloaded],
            "catalog": [{"id": m["id"], "name": m["name"], "size_mb": m["size_mb"],
                        "downloaded": model_catalog.is_downloaded(m["id"])}
                       for m in model_catalog.get_catalog()],
            "config": config.load_config(),
            "requests_served": len(_request_log),
        })

    def _handle_load_model(self):
        body = self._read_body()
        model_id = body.get("model_id", "")
        eng = engine.get_engine()
        try:
            eng.load(model_id)
            return self._send_json({"status": "ok", "model": model_id})
        except Exception as e:
            return self._send_json({"error": str(e)}, 400)

    def _handle_download_model(self):
        body = self._read_body()
        model_id = body.get("model_id", "")
        # Start download in background
        def do_download():
            try:
                model_catalog.download_model(model_id)
            except Exception:
                pass
        t = threading.Thread(target=do_download, daemon=True)
        t.start()
        return self._send_json({"status": "downloading", "model": model_id})

    def _serve_web_ui(self):
        # Serve the web UI HTML file
        html_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "web_ui.html")
        if os.path.exists(html_path):
            with open(html_path, "r") as f:
                html = f.read()
            self._send_html(html)
        else:
            self._send_html("<html><body><h1>MiniLLM</h1><p>web_ui.html not found</p></body></html>")


def get_local_ip():
    """Get local IP address for network access."""
    import socket
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return "127.0.0.1"


def start_server(host=None, port=None):
    """Start the API server."""
    global _server, _server_thread

    if _server is not None:
        print("Server is already running.")
        return

    cfg = config.load_config()
    host = host or cfg["server_host"]
    port = port or cfg["server_port"]

    _server = HTTPServer((host, port), APIHandler)
    _server_thread = threading.Thread(target=_server.serve_forever, daemon=True)
    _server_thread.start()

    local_ip = get_local_ip()
    print(f"MiniLLM API Server running!")
    print(f"  Local:   http://127.0.0.1:{port}")
    print(f"  Network: http://{local_ip}:{port}")
    print(f"  Web UI:  http://{local_ip}:{port}/ui")
    print()
    print("API Endpoints:")
    print(f"  POST /v1/chat/completions  - Chat (OpenAI compatible)")
    print(f"  POST /v1/completions       - Text completion")
    print(f"  GET  /v1/models            - List models")
    print(f"  GET  /health               - Health check")
    print()
    return _server


def stop_server():
    """Stop the API server."""
    global _server, _server_thread
    if _server:
        _server.shutdown()
        _server = None
        _server_thread = None
        print("Server stopped.")
    else:
        print("Server is not running.")


def is_running():
    return _server is not None
