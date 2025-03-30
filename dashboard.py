from fastapi import FastAPI, UploadFile, File
from fastapi.responses import HTMLResponse, FileResponse
import os
import subprocess

app = FastAPI()
UPLOAD_FOLDER = "./uploads"
OUTPUT_FOLDER = "./downloads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

@app.get("/", response_class=HTMLResponse)
async def home():
    files = os.listdir(OUTPUT_FOLDER)
    file_list = "".join(f'<li><a href="/download/{f}">{f}</a></li>' for f in files)
    
    return f"""
    <html>
        <body>
            <h2>Upload a PowerPoint File</h2>
            <form action="/upload" method="post" enctype="multipart/form-data">
                <input type="file" name="file">
                <button type="submit">Upload & Convert</button>
            </form>
        </body>
    </html>
    """

@app.post("/upload")
async def upload_file(file: UploadFile = File(...)):
    file_path = os.path.join(UPLOAD_FOLDER, file.filename)
    output_path = os.path.join(OUTPUT_FOLDER, file.filename.replace('.pptx', '.pdf').replace('.ppt', '.pdf'))
    
    with open(file_path, "wb") as f:
        f.write(await file.read())
    
    try:
        subprocess.run(["soffice", "--headless", "--convert-to", "pdf", "--outdir", OUTPUT_FOLDER, file_path], check=True)
    except subprocess.CalledProcessError as e:
        return {"error": f"Conversion failed: {e}"}
    
    return FileResponse(output_path, media_type='application/pdf', filename=os.path.basename(output_path))
