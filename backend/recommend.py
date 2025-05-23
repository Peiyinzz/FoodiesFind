from fastapi import APIRouter, HTTPException
from firebase_admin import firestore

router = APIRouter()

@router.get("/recommendations/{user_id}")
async def get_recommendations(user_id: str):
    db = firestore.client()

    # 1) Load the user's profile
    user_ref = db.collection("users").document(user_id)
    user_snap = user_ref.get()
    if not user_snap.exists:
        raise HTTPException(status_code=404, detail="User not found")
    user_data = user_snap.to_dict() or {}
    allergies     = set(user_data.get("allergies", []))
    dietary_prefs = set(user_data.get("dietaryPreferences", []))
    taste_prefs   = set(user_data.get("tastePreferences", []))

    # 2) Aggregate all dishes from reviews
    dish_scores = {}
    all_reviews = db.collection("user_reviews").stream()
    for review in all_reviews:
        data = review.to_dict()
        rest_id = data.get("restaurantId")
        for dish in data.get("dishes", []):
            name = dish.get("name")
            # collect tags
            tags = set(dish.get("dietary", []) +
                       dish.get("taste", []) +
                       dish.get("ingredients", []))
            # 3) Skip if any allergy tag is present
            if tags & allergies:
                continue

            # 4) Score = 2*dietaryMatches + 1*tasteMatches
            diet_matches  = len(tags & dietary_prefs)
            taste_matches = len(tags & taste_prefs)
            score = 2 * diet_matches + 1 * taste_matches

            # ignore zero-score dishes
            if score <= 0:
                continue

            key = f"{rest_id}_{name}"
            # keep the highest score if dish appears multiple times
            existing = dish_scores.get(key)
            if existing is None or existing["score"] < score:
                dish_scores[key] = {
                    "restaurantId": rest_id,
                    "dishName":     name,
                    "score":        score
                }

    # 5) Return the top 10
    sorted_dishes = sorted(
        dish_scores.values(),
        key=lambda x: x["score"],
        reverse=True
    )[:10]

    return {"recommendations": sorted_dishes}
