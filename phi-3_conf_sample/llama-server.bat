REM �T���v��

cd /d C:\work\models\llama-b3058-bin-win-openblas-x64

server.exe -m Phi-3-mini-4k-instruct-q4.gguf -np 32 -ngl 0 -b 1024 -ub 64 -c 4096 -n -1 -cb -dt 0.1 -t 2  --host 127.0.0.1 --port 8085

pause
pause
pause
