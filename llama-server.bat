REM ƒTƒ“ƒvƒ‹

cd /d C:\work\models\llama-b3496-bin-win-openblas-x64

llama-server.exe -m gemma-2-2b-it-Q4_K_M.gguf -np 32 -ngl 0 -b 1024 -ub 64 -c 8192 -ns 8192 -n -1 -cb -dt 0.1 -t 2  --host 127.0.0.1 --port 8087

pause
pause
pause
