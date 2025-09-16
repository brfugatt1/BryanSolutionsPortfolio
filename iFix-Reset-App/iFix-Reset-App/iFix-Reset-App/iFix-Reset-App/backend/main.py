from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional
import os
import requests

# If you add a .env later, uncomment:
# from dotenv import load_dotenv; load_dotenv()

WEBHOOK_URL = os.getenv("WEBHOOK_URL")  # e.g., Teams/Slack webhook (optional)

app = FastAPI(title="iFix Reset Request API", version="1.0.0")

# Allow local dev from Vite (5173 default) or any origin if you prefer
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],     # tighten to your frontend origin in prod
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ResetRequest(BaseModel):
    line: str = Field(..., description="Production line or area")
    station: str = Field(..., description="Station or HMI identifier")
    operator: Optional[str] = Field(None, description="Operator name or badge")
    reason: Optional[str] = Field(None, description="Short description of why reset is needed")

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/request-reset")
def request_reset(payload: ResetRequest):
    # Basic validation
    if not payload.line.strip() or not payload.station.strip():
        raise HTTPException(status_code=400, detail="line and station are required")

    # Construct a human-friendly message
    msg = (
        " iFix Reset Requested\n"
        f"- Line: {payload.line}\n"
        f"- Station: {payload.station}\n"
        f"- Operator: {payload.operator or 'N/A'}\n"
        f"- Reason: {payload.reason or 'N/A'}"
    )

    # Try to forward to webhook if configured
    forwarded = False
    error = None
    if WEBHOOK_URL:
        try:
            # Slack works with {"text": "..."}; Teams may need its card payload.
            r = requests.post(WEBHOOK_URL, json={"text": msg}, timeout=6)
            r.raise_for_status()
            forwarded = True
        except Exception as e:
            error = str(e)

    return {
        "queued": True,
        "forwarded": forwarded,
        "message": msg,
        "error": error,
    }
