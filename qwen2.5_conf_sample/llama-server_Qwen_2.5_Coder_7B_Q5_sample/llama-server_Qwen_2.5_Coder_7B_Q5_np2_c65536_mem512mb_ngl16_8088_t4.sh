./llama-server -m ./qwen2.5-coder-7b-instruct-q5_0.gguf -np 2 -ngl 16 -b 1024 -ub 64 -c 65536 -n -1 -cb -dt 0.1 -t 4 -fa --host 192.168.10.10 --port 8088
