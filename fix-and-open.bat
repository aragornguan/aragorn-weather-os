@echo off
echo Embedding world.jpg texture into weather-os.html...
"C:\Users\arago\AppData\Local\Python\pythoncore-3.14-64\python.exe" "C:\Users\arago\Documents\Claude\Projects\FUI\embed_texture.py"
if exist "C:\Users\arago\Documents\Claude\Projects\FUI\embed_done.txt" (
    echo Success! Opening weather-os.html...
    start "" "C:\Users\arago\Documents\Claude\Projects\FUI\weather-os.html"
) else (
    echo Something went wrong. Check embed_texture.py
    pause
)
