# MiniLLM - On-Device AI for iPhone

Download, train, and host mini LLMs directly on your iPhone. Two ways to run:

1. **Native iOS App** (SwiftUI) -- full GUI with Metal acceleration
2. **iSH Terminal App** (Python) -- runs in iSH shell, no Xcode needed

## Quick Start with iSH (Easiest)

Install [iSH](https://apps.apple.com/app/ish-shell/id1436902243) from the App Store, then:

```sh
apk add git
git clone https://github.com/YOUR_USER/Test.git
sh Test/ish-mini-llm/install.sh
```

Then run:

```sh
minillm                         # Interactive mode
minillm download smollm-360m    # Download smallest model (387 MB)
minillm chat                    # Start chatting
minillm server                  # Start API server + Web UI
```

Open Safari and go to `http://localhost:8080` for the web interface.

## Features

- **Download** GGUF models from HuggingFace (7 models, 360M to 2.7B params)
- **Chat** in terminal or through a mobile-optimized web UI
- **Host** an OpenAI-compatible API server on your local network
- **Train** with LoRA fine-tuning and dataset management
- **Export** datasets in Alpaca, ShareGPT, or OpenAI format
- **100% on-device** -- no cloud, no tracking, fully private

## Available Models

| Model | Size | Parameters | Best For |
|-------|------|------------|----------|
| SmolLM 360M | 387 MB | 360M | Fastest, basic tasks |
| Qwen2 0.5B | 400 MB | 0.5B | Tiny but capable |
| TinyLlama 1.1B | 637 MB | 1.1B | Fast, general use |
| Llama 3.2 1B | 800 MB | 1B | Strong instruction following |
| Qwen2 1.5B | 986 MB | 1.5B | Best balance (recommended) |
| Gemma 2B | 1.4 GB | 2B | Google quality |
| Phi-2 | 1.6 GB | 2.7B | Best reasoning |

## Project Structure

```
ish-mini-llm/          # Python app for iSH
  install.sh           # One-command installer
  app.py               # CLI interface
  engine.py            # Inference engine (llama-cpp-python)
  models.py            # Model catalog & downloader
  server.py            # OpenAI-compatible API server
  trainer.py           # Training & dataset management
  web_ui.html          # Mobile web interface

MiniLLM-iOS/           # Native Swift/SwiftUI app
  MiniLLM-iOS/
    Models/            # Data models
    Views/             # SwiftUI views (Chat, Models, Training, Server, Settings)
    ViewModels/        # State management
    Services/          # Inference, download, training, server services
```

## API Usage

Once the server is running, use any OpenAI-compatible client:

```python
from openai import OpenAI

client = OpenAI(base_url="http://localhost:8080/v1", api_key="not-needed")
response = client.chat.completions.create(
    model="local",
    messages=[{"role": "user", "content": "Hello!"}]
)
print(response.choices[0].message.content)
```

Or with curl:

```sh
curl http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages": [{"role": "user", "content": "Hello!"}]}'
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/v1/chat/completions` | Chat completion (OpenAI compatible) |
| POST | `/v1/completions` | Text completion |
| GET | `/v1/models` | List downloaded models |
| GET | `/health` | Health check |
| GET | `/v1/status` | Full system status |

## iOS Native App

The SwiftUI app in `MiniLLM-iOS/` provides:
- Model browser with download/load/delete
- Chat interface with conversation export
- Training dataset creation and LoRA fine-tuning
- Local API server with OpenAI compatibility
- Performance settings (Metal, threads, battery)

See `MiniLLM-iOS/START_HERE.md` for setup instructions.

## Tennis Game (Bonus)

```sh
python3 tennis_game.py          # Terminal version
python3 serve_game.py           # Web version at http://localhost:8000
```

## License

MIT
