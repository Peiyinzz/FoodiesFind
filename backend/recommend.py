from fastapi import APIRouter
from firebase_admin import firestore
from typing import List

router = APIRouter()

@router.get("/recommendations/{user_id}")
async def get_recommendations(user_id: str):
    db = firestore.client()  # ✅ Initialize Firestore only after Firebase is ready

    # Fetch user's review history to count tag preferences
    user_reviews = db.collection("user_reviews").where("userId", "==", user_id).stream()

    tag_counter = {}

    for review in user_reviews:
        data = review.to_dict()
        for dish in data.get("dishes", []):
            for tag_group in ["taste", "ingredients", "dietary"]:
                for tag in dish.get(tag_group, []):
                    tag_counter[tag] = tag_counter.get(tag, 0) + 1

    if not tag_counter:
        return {"message": "No user preferences found", "recommendations": []}

    # Score all reviewed dishes based on matching tags
    all_reviews = db.collection("user_reviews").stream()
    dish_scores = {}

    for review in all_reviews:
        data = review.to_dict()
        rest_id = data.get("restaurantId")
        for dish in data.get("dishes", []):
            dish_name = dish.get("name")
            score = 0
            for tag_group in ["taste", "ingredients", "dietary"]:
                for tag in dish.get(tag_group, []):
                    score += tag_counter.get(tag, 0)

            if score > 0:
                key = f"{rest_id}_{dish_name}"
                if key not in dish_scores:
                    dish_scores[key] = {
                        "restaurantId": rest_id,
                        "dishName": dish_name,
                        "score": score
                    }
                else:
                    dish_scores[key]["score"] += score

    # Return top 10
    sorted_dishes = sorted(dish_scores.values(), key=lambda x: x["score"], reverse=True)[:10]
    return {"recommendations": sorted_dishes}
