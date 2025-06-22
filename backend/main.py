from fastapi import FastAPI
from firebase_admin import credentials, firestore, initialize_app
import os, sys, json

# (you can keep or remove the debug prints – up to you)
sys.stdout.write("FIREBASE_PRIVATE_KEY repr:\n")
sys.stdout.write(repr(os.getenv("FIREBASE_PRIVATE_KEY")) + "\n\n")

# Build _one_ creds dict – with the replace() applied here:
cred_dict = {
    "type":                        os.getenv("FIREBASE_TYPE"),
    "project_id":                  os.getenv("FIREBASE_PROJECT_ID"),
    "private_key_id":              os.getenv("FIREBASE_PRIVATE_KEY_ID"),
    "private_key":                 os.getenv("FIREBASE_PRIVATE_KEY", "")
                                         .replace("\\n", "\n"),
    "client_email":                os.getenv("FIREBASE_CLIENT_EMAIL"),
    "client_id":                   os.getenv("FIREBASE_CLIENT_ID"),
    "auth_uri":                    os.getenv("FIREBASE_AUTH_URI"),
    "token_uri":                   os.getenv("FIREBASE_TOKEN_URI"),
    "auth_provider_x509_cert_url": os.getenv("FIREBASE_AUTH_PROVIDER_CERT_URL"),
    "client_x509_cert_url":        os.getenv("FIREBASE_CLIENT_CERT_URL"),
}

sys.stdout.write("Creds dict preview:\n")
sys.stdout.write(
  json.dumps(
    { k: (v[:30] + "…") if isinstance(v, str) else v for k,v in cred_dict.items() },
    indent=2
  )
)
sys.stdout.write("\n\n")

# Now initialize with that same dict
cred = credentials.Certificate(cred_dict)
initialize_app(cred)

app = FastAPI()

@app.get("/")
def root():
    return {"message": "Backend is running!"}

# import and mount your router afterwards
from recommend import router as recommend_router
app.include_router(recommend_router)
