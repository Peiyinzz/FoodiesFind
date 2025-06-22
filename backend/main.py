from fastapi import FastAPI
from firebase_admin import credentials, firestore, initialize_app
from recommend import router as recommend_router

import os
import json

import os, sys, json
# dump out exactly what env-vars look like inside the container
sys.stdout.write("FIREBASE_PRIVATE_KEY repr:\n")
sys.stdout.write(repr(os.getenv("FIREBASE_PRIVATE_KEY")) + "\n\n")
# if you’re building a dict for credentials:
creds = {
    "type":               os.getenv("FIREBASE_TYPE"),
    "project_id":         os.getenv("FIREBASE_PROJECT_ID"),
    "private_key_id":     os.getenv("FIREBASE_PRIVATE_KEY_ID"),
    "private_key":        os.getenv("FIREBASE_PRIVATE_KEY", "").replace("\\n", "\n"),
    "client_email":       os.getenv("FIREBASE_CLIENT_EMAIL"),
    "client_id":          os.getenv("FIREBASE_CLIENT_ID"),
    "auth_uri":           os.getenv("FIREBASE_AUTH_URI"),
    "token_uri":          os.getenv("FIREBASE_TOKEN_URI"),
    "auth_provider_x509_cert_url": os.getenv("FIREBASE_AUTH_PROVIDER_CERT_URL"),
    "client_x509_cert_url":        os.getenv("FIREBASE_CLIENT_CERT_URL"),
}
sys.stdout.write("Creds dict preview:\n")
sys.stdout.write(json.dumps({k: (v[:30] + "…") if isinstance(v, str) else v for k,v in creds.items()}, indent=2))
sys.stdout.write("\n")


# Load Firebase from env (Railway loads it this way)
cred_dict = {
    "type": "service_account",
    "project_id": os.getenv("FIREBASE_PROJECT_ID"),
    "private_key_id": os.getenv("FIREBASE_PRIVATE_KEY_ID"),
    "private_key": os.getenv("FIREBASE_PRIVATE_KEY").replace("\\n", "\n"),
    "client_email": os.getenv("FIREBASE_CLIENT_EMAIL"),
    "client_id": os.getenv("FIREBASE_CLIENT_ID"),
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": os.getenv("FIREBASE_CLIENT_CERT_URL")
}
cred = credentials.Certificate(cred_dict)
initialize_app(cred)

app = FastAPI()

@app.get("/")
def root():
    return {"message": "Backend is running!"}

app.include_router(recommend_router)
