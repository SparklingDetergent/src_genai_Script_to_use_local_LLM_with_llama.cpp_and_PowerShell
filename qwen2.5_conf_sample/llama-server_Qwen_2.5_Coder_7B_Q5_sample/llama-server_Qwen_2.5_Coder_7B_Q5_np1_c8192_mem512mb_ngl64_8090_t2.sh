./llama-server -m ./qwen2.5-coder-7b-instruct-q5_0.gguf -np 1 -ngl 64 -b 1024 -ub 64 -c 8192 -n -1 -cb -dt 0.1 -t 2 -fa --host 192.168.10.10 --port 8090
