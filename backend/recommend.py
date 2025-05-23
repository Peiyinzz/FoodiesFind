from fastapi import APIRouter, HTTPException
from firebase_admin import firestore

router = APIRouter()

@router.get("/recommendations/{user_id}")
async def get_recommendations(user_id: str):
    db = firestore.client()

    # ── 1) Load the user's profile ─────────────────────────────
    user_ref = db.collection("users").document(user_id)
    user_snap = user_ref.get()
    if not user_snap.exists:
        raise HTTPException(status_code=404, detail="User not found")
    user_data = user_snap.to_dict() or {}

    # ←— NOTE: use your actual Firestore keys here:
    allergies     = set(user_data.get("allergies", []))
    dietary_prefs = set(user_data.get("dietary", []))   # was "dietaryPreferences"
    taste_prefs   = set(user_data.get("taste", []))     # was "tastePreferences"

    # If they haven’t set either, fall back to original tag_counter logic
    use_simple_counter = not dietary_prefs and not taste_prefs

    # ── 2) Build a global tag counter from THIS user’s reviews ──
    user_reviews = db.collection("user_reviews") \
                     .where("userId", "==", user_id) \
                     .stream()

    tag_counter = {}
    for review in user_reviews:
        data = review.to_dict()
        for dish in data.get("dishes", []):
            for group in ("taste", "ingredients", "dietary"):
                for tag in dish.get(group, []):
                    tag_counter[tag] = tag_counter.get(tag, 0) + 1

    # ── 3) Score every dish across all reviews ──────────────────
    dish_scores = {}
    all_reviews = db.collection("user_reviews").stream()

    for review in all_reviews:
        data = review.to_dict()
        rest_id = data.get("restaurantId")
        for dish in data.get("dishes", []):
            name = dish.get("name")
            # collect tags
            tags = set(
                dish.get("taste", []) +
                dish.get("ingredients", []) +
                dish.get("dietary", [])
            )

            # 3a) allergy guard
            if tags & allergies:
                continue

            # 3b) compute score
            if use_simple_counter:
                # original “mention count” fallback
                score = sum(tag_counter.get(t, 0) for t in tags)
            else:
                # weighted by prefs
                diet_matches  = len(tags & dietary_prefs)
                taste_matches = len(tags & taste_prefs)
                score = 2 * diet_matches + 1 * taste_matches

            if score <= 0:
                continue

            key = f"{rest_id}_{name}"
            existing = dish_scores.get(key)
            # keep the highest‐scoring occurrence
            if existing is None or existing["score"] < score:
                dish_scores[key] = {
                    "restaurantId": rest_id,
                    "dishName":     name,
                    "score":        score
                }

    # ── 4) Sort + return top 10 ───────────────────────────────
    sorted_dishes = sorted(
        dish_scores.values(),
        key=lambda x: x["score"],
        reverse=True
    )[:10]

    return {"recommendations": sorted_dishes}
