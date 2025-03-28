import os
import time
import subprocess
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

DOWNLOADS_FOLDER = "/mnt/downloads"


class PPTHandler(FileSystemEventHandler):
    def on_created(self, event):
        """Triggered when a new file is added in any subfolder"""
        if event.is_directory:
            return
        if event.src_path.endswith(('.ppt', '.pptx')):
            print(f"New file detected: {event.src_path}")
            if os.path.exists(event.src_path) and os.path.getsize(event.src_path) > 0:
                self.convert_to_pdf(event.src_path)
                
            else:
                print(f"Skipping: {event.src_path} (File may not be fully downloaded)")

    def convert_to_pdf(self, ppt_path):
        """Convert PPT/PPTX to PDF using LibreOffice's soffice"""
        try:
            output_dir = os.path.dirname(ppt_path)
            cmd = [
                "soffice",
                "--headless",
                "--convert-to", "pdf",
                "--outdir", output_dir,
                ppt_path
            ]
            subprocess.run(cmd, check=True)
            print(f"Converted: {ppt_path} -> {output_dir}/{os.path.basename(ppt_path).replace('.pptx', '.pdf').replace('.ppt', '.pdf')}")
        except subprocess.CalledProcessError as e:
            print(f"Error converting {ppt_path}: {e}")

if __name__ == "__main__":
    event_handler = PPTHandler()
    observer = Observer()
    observer.schedule(event_handler, DOWNLOADS_FOLDER, recursive=True)  # Monitor all subfolders
    observer.start()

    print(f"Monitoring all subfolders inside: {DOWNLOADS_FOLDER}")

    try:
        while True:
            time.sleep(10)
    except KeyboardInterrupt:
        observer.stop()
        observer.join()
