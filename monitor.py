import os
import time
import subprocess
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

DOWNLOADS_FOLDER = "/mnt/downloads"  # Change this to your actual downloads folder path (if not running from docker)


class PPTHandler(FileSystemEventHandler):
    def process_file(self, file_path):
        """Process PowerPoint files when they are stable"""
        if file_path.endswith(('.ppt', '.pptx')):
            print(f"Detected stable file: {file_path}")
            self.convert_to_pdf(file_path)

    def on_created(self, event):
        """Triggered when a new file is added"""
        if event.is_directory:
            return
        print(f"File created: {event.src_path}")
        self.process_file(event.src_path)

    def on_modified(self, event):
        """Triggered when a file is modified (helps detect renamed .pptx files)"""
        if event.is_directory:
            return
        print(f"File modified: {event.src_path}")
        self.process_file(event.src_path)

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
    observer.schedule(event_handler, DOWNLOADS_FOLDER, recursive=True)
    observer.start()

    print(f"Monitoring all subfolders inside: {DOWNLOADS_FOLDER}")

    try:
        while True:
            time.sleep(10)
    except KeyboardInterrupt:
        observer.stop()
        observer.join()
