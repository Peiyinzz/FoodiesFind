# FoodiesFind 🍽️  
**Discover. Review. Enjoy.** An all-in-one Flutter-based food discovery social platform powered by Firebase and FastAPI.

## 🚀 Overview
FoodiesFind is an Android mobile application that helps users explore restaurants and dishes, view and manage menus, manage restaurant information, read and write reviews, generate crowdsourced food tags, and get smart recommendations based on food allergy constraints, taste profiles, and dietary preferences.


## 🛠️ Tech Stack
- **Frontend**: Flutter (Dart)  
- **Backend**: Firebase Firestore, Firebase Storage, Firebase Auth  
- **Maps & Geolocation**: Google Maps API, Google Places API, Directions API  
- **Analytics**: Firestore tag aggregation + recommendation logic

## 📦 Setup & Installation
Follow these steps to run the FoodiesFind Flutter app locally:

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/FoodiesFind.git
cd FoodiesFind
```

### 2. Install Flutter dependencies
```bash
flutter pub get
```

### 3. Configure Firebase
Go to Firebase Console and create a project

Enable:

- Cloud Firestore

- Firebase Authentication

- Firebase Storage

Download your platform config files:

- Android: google-services.json → place in android/app/

- iOS: GoogleService-Info.plist → place in ios/Runner/

### 4. Run the app
```bash
flutter run
```

### 5. (Optional) Build APK for distribution
```bash
flutter build apk --release
```
The APK will be located at:
```bash
build/app/outputs/flutter-apk/app-release.apk
```
