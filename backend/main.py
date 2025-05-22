from fastapi import FastAPI
from firebase_admin import credentials, firestore
import firebase_admin
from recommend import router as recommend_router
import os
import json

# Initialize Firebase Admin
#cred = credentials.Certificate("firebase_config.json")  # Replace with your actual service account key file path

firebase_creds = {
    "type": "service_account",
    "project_id": os.environ["FIREBASE_PROJECT_ID"],
    "private_key_id": os.environ["FIREBASE_PRIVATE_KEY_ID"],
    "private_key": os.environ["FIREBASE_PRIVATE_KEY"],
    "client_email": os.environ["FIREBASE_CLIENT_EMAIL"],
    "client_id": os.environ["FIREBASE_CLIENT_ID"],
    "auth_uri": os.environ["FIREBASE_AUTH_URI"],
    "token_uri": os.environ["FIREBASE_TOKEN_URI"],
    "auth_provider_x509_cert_url": os.environ["FIREBASE_AUTH_PROVIDER_CERT_URL"],
    "client_x509_cert_url": os.environ["FIREBASE_CLIENT_CERT_URL"]
}
cred = credentials.Certificate(firebase_creds)
firebase_admin.initialize_app(cred)
db = firestore.client()

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "FoodiesFind Backend Running!"}

# Include modular recommendation router
app.include_router(recommend_router)
