REM ƒTƒ“ƒvƒ‹

cd /d C:\work\models\llama-b3808-bin-win-openblas-x64

llama-server.exe -m qwen2.5-coder-7b-instruct-q5_0.gguf -np 4 -ngl 0 -b 1024 -ub 64 -c 8192 -n -1 -cb -dt 0.1 -t 2  --host 127.0.0.1 --port 8088

pause
pause
pause
