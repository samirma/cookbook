### llama cpp build

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


./build/bin/llama-server -hf unsloth/Qwen3-235B-A22B-Instruct-2507-GGUF:Q2_K --host 0.0.0.0 --port 8080  --no-prefill-assistant  --ctx-size 32768 --jinja   -sm row --temp 0.6 --top-k 20 --top-p 0.95 --min-p 0  -fit on  --rpc  192.168.0.44:50052

./build/bin/llama-server -hf unsloth/GLM-4.7-Flash-GGUF:Q5_K_XL \
    --alias "unsloth/GLM-4.7-Flash" \
    --threads -1 \
    --fit on \
    --seed 3407 \
    --temp 1.0 \
    --top-p 0.95 \
    --min-p 0.01 \
    --ctx-size 16384 \
    --host 0.0.0.0 --port 8080 \
    --jinja

```

### Curl Test
```sh
curl -X POST http://localhost:8080/v1/chat/completions     -H "Content-Type: application/json"     -d '{
        "messages": [
            {"role": "user", "content": "Hello! How are you today?"}
        ],
        "temperature": 0.7
    }'
```
