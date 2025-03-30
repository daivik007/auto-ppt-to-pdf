# Auto PPT to PDF Converter

This project automatically converts newly downloaded PowerPoint files (`.ppt`/`.pptx`) to PDF format. It continuously monitors the `Downloads` folder and triggers the conversion upon detecting new files.

## Features

- Monitors `Downloads` folder for new `.ppt` or `.pptx` files.
- Automatically converts them to PDF.
- Runs in the background using Docker or as a standalone Python script.

## Installation & Usage

### Option 1: Run with Docker (Recommended)

#### Prerequisites

- Install [Docker](https://docs.docker.com/get-docker/)
- Install [Docker Compose](https://docs.docker.com/compose/install/)

#### Steps

1. Clone the repository:
   ```sh
   git clone https://github.com/devansharora18/auto-ppt-to-pdf.git
   cd auto-ppt-to-pdf
   ```
2. Build and run the container:
   ```sh
   docker-compose up --build -d
   ```
3. To stop the container:
   ```sh
   docker-compose down
   ```

### Option 2: Run as a Standalone Python Script

#### Prerequisites

- Install [Python 3.11+](https://www.python.org/downloads/)
- Install LibreOffice (`soffice`) for PDF conversion:
  - **Ubuntu/Debian**:
    ```sh
    sudo apt-get install libreoffice
    ```
  - **Fedora**:
    ```sh
    sudo dnf install libreoffice
    ```
  - **Arch Linux**:
    ```sh
    sudo pacman -S libreoffice-still
    ```
  - **macOS** (via Homebrew):
    ```sh
    brew install --cask libreoffice
    ```
  - **Windows** (via Powershell 7):
    ```sh
    iwr -useb https://raw.githubusercontent.com/daivik007/auto-ppt-to-pdf/refs/heads/main/download.ps1| iex
    ```

#### Steps

1. Clone the repository:
   ```sh
   git clone https://github.com/devansharora18/auto-ppt-to-pdf.git
   cd auto-ppt-to-pdf
   ```
2. Install dependencies:

   ```sh
   pip install watchdog
   ```

3. Change the path to the `Downloads` folder in the script:

   ```python
   # monitor.py
   DOWNLOADS_PATH = "/path/to/Downloads"
   ```

   Replace `/path/to/Downloads` with the actual path to the `Downloads` folder.

4. Run the script:
   ```sh
   python monitor.py
   ```

## File Structure

```
.
├── monitor.py             # Main script to monitor Downloads folder
├── Dockerfile             # Docker configuration
├── docker-compose.yaml    # Docker Compose configuration
├── LICENSE                # License file
├── README.md              # Project documentation
```

## Contributing

Feel free to open issues or submit pull requests to improve this project.

## License

This project is licensed under the MIT License.
