import os
import json
from fastapi import FastAPI
from firebase_admin import credentials, initialize_app, firestore

# Build a single dict, with the replace applied exactly here:
cred_dict = {
    "type":                        os.getenv("FIREBASE_TYPE"),
    "project_id":                  os.getenv("FIREBASE_PROJECT_ID"),
    "private_key_id":              os.getenv("FIREBASE_PRIVATE_KEY_ID"),
    # 🔑 Replace literal \n with actual newlines
    "private_key":                 os.getenv("FIREBASE_PRIVATE_KEY", "")
                                          .replace("\\n", "\n"),
    "client_email":                os.getenv("FIREBASE_CLIENT_EMAIL"),
    "client_id":                   os.getenv("FIREBASE_CLIENT_ID"),
    "auth_uri":                    os.getenv("FIREBASE_AUTH_URI"),
    "token_uri":                   os.getenv("FIREBASE_TOKEN_URI"),
    "auth_provider_x509_cert_url": os.getenv("FIREBASE_AUTH_PROVIDER_CERT_URL"),
    "client_x509_cert_url":        os.getenv("FIREBASE_CLIENT_CERT_URL"),
}

# (optional) inspect it
print(json.dumps({k: (v[:30]+"…") for k,v in cred_dict.items()}, indent=2))

# Initialize Firebase with that exact dict
cred = credentials.Certificate(cred_dict)
initialize_app(cred)

app = FastAPI()
@app.get("/")
def root():
    return {"message": "Backend is running!"}

# mount your router after init
from recommend import router as recommend_router
app.include_router(recommend_router)
