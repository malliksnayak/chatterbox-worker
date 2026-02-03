# chatterbox-worker
worker container for chatterbox tts

## RunPod Serverless Deployment

### Files
- `Dockerfile`: Containerizes the server for RunPod
- `requirements.txt`: Python dependencies
- `handler.py`: RunPod serverless handler (entrypoint)

### Local Development
1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
2. Run locally:
   ```bash
   python handler.py
   ```

### Build and Deploy on RunPod
1. Build Docker image:
   ```bash
   docker build -t chatterbox-worker .
   ```
2. Push to your container registry (e.g., Docker Hub).
3. Deploy on RunPod serverless with your image and set the entrypoint to `handler.py`.

### handler.py Example
The `handler` function receives the event and returns a response. Customize as needed for your application.

---
