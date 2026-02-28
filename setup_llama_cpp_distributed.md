## Master Server

The master server distributes SSH public keys to workers via HTTP and Zeroconf discovery. It allows workers to discover the master and fetch the public key for SSH access.

### Prerequisites

- [uv](https://docs.astral.sh/uv/) - Modern Python package manager

Install uv if not already installed:
```sh
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Running the Master

The easiest way to run the master server:

```sh
cd scripts
./run_master.sh
```

Or manually with uv:
```sh
cd scripts
uv run master.py
```

The master will:
1. Generate an SSH key pair at `~/.ssh/id_rsa` if it doesn't exist
2. Start an HTTP server on port 8000 serving the public key
3. Register the service via Zeroconf for worker discovery
4. Keep running until interrupted (Ctrl+C)

**Note:** Workers can discover the master using `discover_master.py` which outputs the URL to fetch the public key.

---

## llama cpp build

```sh
git clone https://github.com/ggml-org/llama.cpp
cd llama.cpp
```

Ubuntu
```sh
cmake -B build -DGGML_VULKAN=OFF -DGGML_RPC=ON  -DBUILD_SHARED_LIBS=OFF  -DGGML_CUDA=ON
```

Mac os
```sh
cmake -B build  -DGGML_RPC=ON -DGGML_METAL=ON -DGGML_ACCELERATE=ON  -DGGML_CUDA=OFF -DGGML_VULKAN=OFF -DCMAKE_BUILD_TYPE=Release
```
Termux
```sh
cmake -B build -DGGML_VULKAN=1 -DGGML_RPC=ON  -DBUILD_SHARED_LIBS=OFF   -DGGML_ACCELERATE=ON
```

Build
```sh
cmake --build build --config Release -j $(nproc)
```


Restore termux_build
```sh
rsync -avz -e 'ssh -p 8022' termux_build/ u0_a1228@192.168.0.149:~/termux_build/
```

### Worker
```sh
CUDA_VISIBLE_DEVICES=0 ./rpc-server -p 50052 -H 0.0.0.0
```


### LLM Server
```sh

./build/bin/llama-server \
    -hf unsloth/Qwen3.5-27B-GGUF:UD-Q4_K_XL \
    --alias "unsloth/Qwen3.5-27B" \
    --temp 0.6 \
    --top-p 0.95 \
    --ctx-size 16384 \
    --top-k 20 \
    --min-p 0.00 \
    --port 8001

```

### Curl Test
```sh
curl -X POST http://localhost:8001/v1/chat/completions     -H "Content-Type: application/json"     -d '{
        "messages": [
            {"role": "user", "content": "Hello! How are you today?"}
        ],
        "temperature": 0.7
    }'
```
