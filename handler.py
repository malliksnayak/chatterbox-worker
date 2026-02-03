import runpod
import torch
import torchaudio
import os
import base64
import io
from chatterbox.tts_turbo import ChatterboxTurboTTS

# Global model variable
model = None

def load_model():
    global model
    if model is None:
        print("Loading Chatterbox model to GPU...")
        model = ChatterboxTurboTTS.from_pretrained(device='cuda')
    return model

def handler(job):
    job_input = job['input']
    text = job_input.get("text", "Hello from Chatterbox on RunPod.")
    
    # Load model (only happens on first request per worker boot)
    tts = load_model()
    
    # Generate audio
    with torch.inference_mode():
        wav = tts.generate(text)
    
    # Convert tensor to base64 bytes for the API response
    buffer = io.BytesIO()
    torchaudio.save(buffer, wav.cpu(), 24000, format="wav")
    audio_base64 = base64.b64encode(buffer.getvalue()).decode('utf-8')
    
    return {
        "audio_base64": audio_base64,
        "format": "wav",
        "sampling_rate": 24000
    }

runpod.serverless.start({"handler": handler})