### llama cpp build

```sh
git clone https://github.com/ggml-org/llama.cpp
cd llama.cpp

cmake -B build -DGGML_VULKAN=ON -DGGML_RPC=ON
cmake --build build --config Release
```

### Worker
```sh
CUDA_VISIBLE_DEVICES=0 ./rpc-server -p 50052 -H 0.0.0.0
```


### LLM Server
'''sh
./llama-cli -hf unsloth/DeepSeek-R1-0528-Qwen3-8B-GGUF:IQ4_XS  -p "Create a python code sempla that uses zeconfig"   -ngl 99   --rpc  192.168.0.44:50052
```

