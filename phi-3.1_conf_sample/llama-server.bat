REM ƒTƒ“ƒvƒ‹

cd /d C:\work\models\llama-b3496-bin-win-openblas-x64

llama-server.exe -m Phi-3.1-mini-4k-instruct-Q4_K_M.gguf -ngl 0 -c 4096 -n -1 -t 2 --host 127.0.0.1 --port 8086

pause
pause
pause
