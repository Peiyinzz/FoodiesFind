from fastapi import FastAPI
from firebase_admin import credentials, firestore
import firebase_admin
from recommend import router as recommend_router
import uvicorn

# Initialize Firebase Admin
cred = credentials.Certificate("firebase_config.json")  # Replace with your actual service account key file path
firebase_admin.initialize_app(cred)
db = firestore.client()

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "FoodiesFind Backend Running!"}

# Include modular recommendation router
app.include_router(recommend_router)

# Required to run app on Railway
if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000)
