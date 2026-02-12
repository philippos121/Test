#!/usr/bin/env python3
"""
MiniLLM - Download, train, and host mini LLMs on your iPhone.
Run via iSH (Alpine Linux shell for iOS).

Usage:
  python3 app.py                    # Interactive mode
  python3 app.py models             # List all available models
  python3 app.py download <model>   # Download a model
  python3 app.py chat               # Start chatting
  python3 app.py server             # Start API server
  python3 app.py train              # Training menu
  python3 app.py web                # Start web UI only
  python3 app.py help               # Show help
"""

import sys
import os
import json
import time
import signal
import readline  # enables line editing in input()

# Add script directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import config
import models
import engine
import server
import trainer


BANNER = r"""
  __  __ _       _ _     _     __  __
 |  \/  (_)_ __ (_) |   | |   |  \/  |
 | |\/| | | '_ \| | |   | |   | |\/| |
 | |  | | | | | | | |___| |___| |  | |
 |_|  |_|_|_| |_|_|_____|_____|_|  |_|

  On-device LLM for iPhone via iSH
  Type 'help' for commands
"""


def cmd_help():
    print("""
Commands:
  models          List available models (+ = downloaded, * = loaded)
  download <id>   Download a model
  delete <id>     Delete a downloaded model
  load <id>       Load a model for inference
  unload          Unload current model
  chat            Start interactive chat
  server          Start API server + Web UI
  server stop     Stop API server
  train           Training and datasets menu
  datasets        List training datasets
  export <name>   Export dataset (alpaca/sharegpt/openai format)
  config          Show current configuration
  set <k> <v>     Update config (e.g., set temperature 0.8)
  status          Show system status
  help            Show this help
  quit / exit     Exit MiniLLM
""")


def cmd_models():
    catalog = models.get_catalog()
    eng = engine.get_engine()
    loaded_id = eng.model_info["id"] if eng.is_loaded() and eng.model_info else None

    print("\nAvailable Models:")
    print("-" * 70)
    for m in catalog:
        dl = models.is_downloaded(m["id"])
        is_loaded = m["id"] == loaded_id
        marker = " * " if is_loaded else " + " if dl else "   "
        size = config.human_size(m["size_mb"] * 1024 * 1024)
        print(f"{marker}{m['id']:<20} {m['name']:<20} {m['params']:>5}  {size:>8}  {m['quant']}")
    print("-" * 70)
    print("  + = downloaded   * = loaded")
    print(f"\nDownloaded: {len(models.list_downloaded())}/{len(catalog)}")
    if loaded_id:
        print(f"Current model: {loaded_id}")
    print()


def cmd_download(model_id):
    if not model_id:
        print("Usage: download <model_id>")
        print("Run 'models' to see available models.")
        return
    models.download_model_cli(model_id)


def cmd_delete(model_id):
    if not model_id:
        print("Usage: delete <model_id>")
        return
    m = models.find_model(model_id)
    if not m:
        print(f"Unknown model: {model_id}")
        return
    if models.delete_model(model_id):
        print(f"Deleted {m['name']}")
    else:
        print(f"Model {model_id} is not downloaded.")


def cmd_load(model_id):
    if not model_id:
        # Try loading default model
        cfg = config.load_config()
        model_id = cfg.get("default_model")
        if not model_id:
            print("Usage: load <model_id>")
            print("Run 'models' to see available models.")
            return

    eng = engine.get_engine()
    try:
        eng.load(model_id)
    except Exception as e:
        print(f"Error: {e}")


def cmd_unload():
    eng = engine.get_engine()
    if eng.is_loaded():
        name = eng.model_info["name"] if eng.model_info else "model"
        eng.unload()
        print(f"Unloaded {name}")
    else:
        print("No model is loaded.")


def cmd_chat():
    eng = engine.get_engine()
    if not eng.is_loaded():
        print("No model loaded. Loading default or first available...")
        downloaded = models.list_downloaded()
        if not downloaded:
            print("No models downloaded. Run 'download <model_id>' first.")
            return
        cfg = config.load_config()
        model_id = cfg.get("default_model") or downloaded[0]["id"]
        try:
            eng.load(model_id)
        except Exception as e:
            print(f"Failed to load model: {e}")
            return

    model_name = eng.model_info["name"] if eng.model_info else "Unknown"
    print(f"\nChat with {model_name}")
    print("Type 'quit' to exit chat, 'clear' to reset history")
    print("-" * 50)

    messages = []
    cfg = config.load_config()
    system = cfg["system_prompt"]

    while True:
        try:
            user_input = input("\nYou: ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\n")
            break

        if not user_input:
            continue
        if user_input.lower() in ("quit", "exit", "q"):
            break
        if user_input.lower() == "clear":
            messages = []
            print("Chat history cleared.")
            continue
        if user_input.lower() == "save":
            _save_chat(messages)
            continue

        messages.append({"role": "user", "content": user_input})

        print("\nAssistant: ", end="", flush=True)
        start = time.time()

        try:
            # Try streaming first
            full_response = ""
            for token in eng.chat(messages, stream=True):
                print(token, end="", flush=True)
                full_response += token
            elapsed = time.time() - start
            print(f"\n  [{elapsed:.1f}s]")
            messages.append({"role": "assistant", "content": full_response.strip()})
        except Exception as e:
            # Fall back to non-streaming
            try:
                result = eng.chat(messages)
                elapsed = time.time() - start
                print(result["text"])
                print(f"  [{elapsed:.1f}s, {result.get('total_tokens', '?')} tokens]")
                messages.append({"role": "assistant", "content": result["text"]})
            except Exception as e2:
                print(f"\nError: {e2}")
                messages.pop()  # Remove failed user message


def _save_chat(messages):
    if not messages:
        print("No messages to save.")
        return
    name = f"chat_{int(time.time())}"
    path = config.get_history_path(name)
    with open(path, "w") as f:
        json.dump(messages, f, indent=2)
    print(f"Chat saved to {path}")


def cmd_server(args=""):
    if args == "stop":
        server.stop_server()
        return

    eng = engine.get_engine()
    if not eng.is_loaded():
        print("No model loaded. Load one first for inference.")
        print("The server will start but API calls will return errors until a model is loaded.")

    print("Starting MiniLLM server...")
    server.start_server()

    print("Press Ctrl+C to stop the server, or type 'server stop'.\n")


def cmd_web():
    """Start just the web UI server."""
    print("Starting web UI server...")
    server.start_server()
    ip = server.get_local_ip()
    cfg = config.load_config()
    port = cfg["server_port"]
    print(f"\nOpen Safari on your iPhone and go to:")
    print(f"  http://{ip}:{port}")
    print(f"\nPress Ctrl+C to stop.\n")

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        server.stop_server()


def cmd_train():
    print("\nTraining Menu:")
    print("  1. Create new dataset")
    print("  2. Add examples to dataset")
    print("  3. List datasets")
    print("  4. Train on dataset")
    print("  5. Export dataset")
    print("  6. List adapters")
    print("  7. Back")
    print()

    while True:
        try:
            choice = input("train> ").strip()
        except (EOFError, KeyboardInterrupt):
            print()
            break

        if choice in ("7", "back", "quit", "q", ""):
            break
        elif choice == "1":
            _train_create_dataset()
        elif choice == "2":
            _train_add_examples()
        elif choice == "3":
            _train_list_datasets()
        elif choice == "4":
            _train_run()
        elif choice == "5":
            _train_export()
        elif choice == "6":
            _train_list_adapters()
        else:
            print("Invalid choice. Enter 1-7.")


def _train_create_dataset():
    name = input("Dataset name: ").strip()
    if not name:
        return
    ds = trainer.create_dataset(name)
    print(f"Created dataset '{name}'")


def _train_add_examples():
    datasets = trainer.list_datasets()
    if not datasets:
        print("No datasets. Create one first.")
        return
    print("Datasets:", ", ".join(d["name"] for d in datasets))
    name = input("Dataset name: ").strip()
    ds = trainer.Dataset(name)
    print(f"Adding examples to '{name}' (empty instruction to stop)")

    while True:
        instruction = input("  Instruction: ").strip()
        if not instruction:
            break
        output = input("  Expected output: ").strip()
        if not output:
            break
        ds.add_example(instruction, "", output)
        print(f"  Added ({len(ds)} total)")

    print(f"Dataset '{name}' now has {len(ds)} examples.")


def _train_list_datasets():
    datasets = trainer.list_datasets()
    if not datasets:
        print("No datasets yet.")
        return
    print("\nDatasets:")
    for d in datasets:
        print(f"  {d['name']:<20} {d['count']:>4} examples")
    print()


def _train_run():
    datasets = trainer.list_datasets()
    if not datasets:
        print("No datasets. Create one first.")
        return

    eng = engine.get_engine()
    if not eng.is_loaded():
        print("Load a model first.")
        return

    print("Datasets:", ", ".join(d["name"] for d in datasets))
    name = input("Dataset name: ").strip()
    epochs = int(input("Epochs (default 3): ").strip() or "3")

    t = trainer.Trainer(eng)

    def on_progress(info):
        pct = info["progress"] * 100
        sys.stdout.write(
            f"\r  Epoch {info['epoch']}/{epochs}  "
            f"Step {info['step']}/{info['total_steps']}  "
            f"Loss: {info['loss']:.4f}  [{pct:.0f}%]"
        )
        sys.stdout.flush()

    print(f"\nTraining on '{name}' for {epochs} epochs...")
    try:
        adapter_path = t.train(name, epochs=epochs, callback=on_progress)
        print(f"\n\nTraining complete! Adapter saved to: {adapter_path}")
    except Exception as e:
        print(f"\nTraining error: {e}")


def _train_export():
    datasets = trainer.list_datasets()
    if not datasets:
        print("No datasets.")
        return
    print("Datasets:", ", ".join(d["name"] for d in datasets))
    name = input("Dataset name: ").strip()
    fmt = input("Format (alpaca/sharegpt/openai, default alpaca): ").strip() or "alpaca"

    t = trainer.Trainer()
    try:
        path = t.export_dataset(name, format=fmt)
        print(f"Exported to: {path}")
    except Exception as e:
        print(f"Export error: {e}")


def _train_list_adapters():
    t = trainer.Trainer()
    adapters = t.list_adapters()
    if not adapters:
        print("No adapters yet.")
        return
    print("\nAdapters:")
    for a in adapters:
        print(f"  {a['name']:<30} rank={a.get('rank', '?')}  base={a.get('base_model', '?')}")
    print()


def cmd_config():
    cfg = config.load_config()
    print("\nConfiguration:")
    for k, v in sorted(cfg.items()):
        print(f"  {k:<20} = {v}")
    print()


def cmd_set(key, value):
    if not key or value is None:
        print("Usage: set <key> <value>")
        return
    cfg = config.load_config()
    if key not in cfg:
        print(f"Unknown config key: {key}")
        print("Valid keys:", ", ".join(sorted(cfg.keys())))
        return

    # Type-cast to match existing type
    old_val = cfg[key]
    if isinstance(old_val, bool):
        value = value.lower() in ("true", "1", "yes")
    elif isinstance(old_val, int):
        value = int(value)
    elif isinstance(old_val, float):
        value = float(value)

    cfg[key] = value
    config.save_config(cfg)
    print(f"Set {key} = {value}")


def cmd_status():
    eng = engine.get_engine()
    downloaded = models.list_downloaded()
    cfg = config.load_config()

    print("\nMiniLLM Status")
    print("=" * 40)
    print(f"  llama-cpp-python:  {'installed' if eng.is_available() else 'NOT INSTALLED'}")
    print(f"  Model loaded:      {'Yes' if eng.is_loaded() else 'No'}")
    if eng.is_loaded() and eng.model_info:
        print(f"  Current model:     {eng.model_info['name']}")
    print(f"  Downloaded models: {len(downloaded)}")
    print(f"  Server running:    {'Yes' if server.is_running() else 'No'}")
    print(f"  Data directory:    {config.BASE_DIR}")

    # Storage used
    total_size = sum(m.get("actual_size", 0) for m in downloaded)
    print(f"  Storage used:      {config.human_size(total_size)}")
    print()


def interactive():
    """Main interactive loop."""
    print(BANNER)

    eng = engine.get_engine()
    if not eng.is_available():
        print("  WARNING: llama-cpp-python not installed!")
        print("  Run: pip3 install llama-cpp-python")
        print("  Or:  sh install.sh")
        print()

    cmd_status()

    while True:
        try:
            model_tag = ""
            eng = engine.get_engine()
            if eng.is_loaded() and eng.model_info:
                model_tag = f"[{eng.model_info['id']}] "

            line = input(f"minillm {model_tag}> ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nGoodbye!")
            break

        if not line:
            continue

        parts = line.split(None, 2)
        cmd = parts[0].lower()
        arg1 = parts[1] if len(parts) > 1 else ""
        arg2 = parts[2] if len(parts) > 2 else ""

        if cmd in ("quit", "exit"):
            print("Goodbye!")
            break
        elif cmd == "help":
            cmd_help()
        elif cmd == "models":
            cmd_models()
        elif cmd == "download":
            cmd_download(arg1)
        elif cmd == "delete":
            cmd_delete(arg1)
        elif cmd == "load":
            cmd_load(arg1)
        elif cmd == "unload":
            cmd_unload()
        elif cmd == "chat":
            cmd_chat()
        elif cmd == "server":
            cmd_server(arg1)
        elif cmd == "web":
            cmd_web()
        elif cmd == "train":
            cmd_train()
        elif cmd == "datasets":
            _train_list_datasets()
        elif cmd == "export":
            _train_export() if not arg1 else trainer.Trainer().export_dataset(arg1)
        elif cmd == "config":
            cmd_config()
        elif cmd == "set":
            cmd_set(arg1, arg2)
        elif cmd == "status":
            cmd_status()
        else:
            print(f"Unknown command: {cmd}. Type 'help' for commands.")


def main():
    config.init_dirs()

    if len(sys.argv) < 2:
        interactive()
        return

    cmd = sys.argv[1].lower()
    arg = sys.argv[2] if len(sys.argv) > 2 else ""

    if cmd == "help":
        cmd_help()
    elif cmd == "models":
        cmd_models()
    elif cmd == "download":
        cmd_download(arg)
    elif cmd == "delete":
        cmd_delete(arg)
    elif cmd == "load":
        cmd_load(arg)
    elif cmd == "chat":
        if arg:
            cmd_load(arg)
        cmd_chat()
    elif cmd == "server":
        cmd_server(arg)
        if arg != "stop":
            try:
                while True:
                    time.sleep(1)
            except KeyboardInterrupt:
                server.stop_server()
    elif cmd == "web":
        cmd_web()
    elif cmd == "train":
        cmd_train()
    elif cmd == "config":
        cmd_config()
    elif cmd == "status":
        cmd_status()
    else:
        print(f"Unknown command: {cmd}")
        cmd_help()


if __name__ == "__main__":
    main()
