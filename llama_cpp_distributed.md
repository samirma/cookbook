### llama cpp build

```sh
git clone https://github.com/ggml-org/llama.cpp
cd llama.cpp

cmake -B build -DGGML_VULKAN=ON -DGGML_RPC=ON  -DBUILD_SHARED_LIBS=OFF  -DGGML_CUDA=ON
cmake --build build --config Release -j $(nproc)
```

Build in Ubuntu and send to termux
```sh
echo "Cloning llama.cpp repository..."
git clone https://github.com/ggml-org/llama.cpp
cd llama.cpp

# --- 3. Configuring the Build (Vulkan GPU) ---
echo "Configuring build with CMake for Vulkan..."

cmake -B termux_build -DGGML_VULKAN=ON -DGGML_RPC=ON -DBUILD_SHARED_LIBS=OFF

# --- 4. Compiling the Code ---
echo "Compiling the source code..."
cmake --build termux_build --config Release -j $(nproc)

# --- 5. Deploying with rsync ---
echo "Deploying build directory to remote server..."
# This command syncs the 'build' directory to a 'llama_build' directory
# in the home folder on the remote server.

echo "Build and deployment complete!"
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
./llama-cli -hf unsloth/DeepSeek-R1-0528-Qwen3-8B-GGUF:IQ4_XS  -p "Create a python code sempla that uses zeconfig"   -ngl 99   --rpc  192.168.0.44:50052
```

