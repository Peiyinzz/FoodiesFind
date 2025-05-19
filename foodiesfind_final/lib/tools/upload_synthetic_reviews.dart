import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> uploadSyntheticReviews() async {
  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJxcxcoBXASjARkDHkwjnW_X4',
    'userId': 'at1VuTgY0tQ77x95sntsQmoz7QF3',
    'rating': 3,
    'text':
        '''Really enjoyed the flavors, everything was fresh and delicious.''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Grilled Chicken & Cheese Sandwich',
        'taste': ["Tangy", "Spicy"],
        'ingredients': ["Soy"],
        'dietary': ["Halal", "Vegan"],
      },
      {
        'name': 'Mushroom Soup',
        'taste': ["Earthy", "Spicy"],
        'ingredients': ["Gluten", "Eggs"],
        'dietary': ["Vegetarian"],
      },
      {
        'name': 'Soft-shell Crab Fettuccine',
        'taste': ["Spicy", "Sweet"],
        'ingredients': ["Gluten"],
        'dietary': ["Vegetarian", "Nut-free"],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJxcxcoBXASjARkDHkwjnW_X4',
    'userId': 'RQatDUprR6SsiP4abqoEeSRvdHF3',
    'rating': 4,
    'text': '''Amazing value for the quality—definitely coming back!''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Smoked Duck Carbonara',
        'taste': ["Creamy"],
        'ingredients': [],
        'dietary': ["Vegan", "Nut-free"],
      },
      {
        'name': 'Classic Tiramisu',
        'taste': ["Crunchy"],
        'ingredients': ["Gluten", "Shellfish"],
        'dietary': ["Low-carb"],
      },
      {
        'name': 'Grilled Chicken & Cheese Sandwich',
        'taste': ["Creamy"],
        'ingredients': ["Soy"],
        'dietary': ["Nut-free", "Dairy-free"],
      },
      {
        'name': 'Salted Egg French Fries',
        'taste': ["Creamy"],
        'ingredients': ["Dairy"],
        'dietary': ["Pescatarian", "Gluten-free"],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJxcxcoBXASjARkDHkwjnW_X4',
    'userId': '10aUUXfPyfg82YIpEBxZNP3J2782',
    'rating': 4,
    'text': '''A unique twist on classic dishes, highly recommended.''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Soft-shell Crab Fettuccine',
        'taste': ["Tangy", "Creamy"],
        'ingredients': ["Soy"],
        'dietary': ["Low-sugar"],
      },
      {
        'name': 'Grilled Chicken & Cheese Sandwich',
        'taste': ["Earthy", "Crunchy"],
        'ingredients': [],
        'dietary': ["Low-sugar"],
      },
      {
        'name': 'Classic Tiramisu',
        'taste': ["Savoury"],
        'ingredients': ["Soy", "Fish"],
        'dietary': [],
      },
      {
        'name': 'Smoked Duck Carbonara',
        'taste': ["Earthy"],
        'ingredients': ["Shellfish", "Peanuts"],
        'dietary': ["Low-fat", "Vegan"],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJxcxcoBXASjARkDHkwjnW_X4',
    'userId': 'RQatDUprR6SsiP4abqoEeSRvdHF3',
    'rating': 4,
    'text': '''Amazing value for the quality—definitely coming back!''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Mushroom Soup',
        'taste': ["Tangy"],
        'ingredients': ["Fish"],
        'dietary': ["Dairy-free"],
      },
      {
        'name': 'Smoked Duck Carbonara',
        'taste': ["Spicy", "Creamy"],
        'ingredients': [],
        'dietary': ["Halal", "Pescatarian"],
      },
      {
        'name': 'Arang Chicken Chop',
        'taste': ["Creamy"],
        'ingredients': ["Eggs"],
        'dietary': ["Vegan", "Vegetarian"],
      },
      {
        'name': 'Spaghetti Carbonara',
        'taste': ["Tangy", "Earthy"],
        'ingredients': ["Shellfish"],
        'dietary': ["Vegetarian", "Dairy-free"],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJxcxcoBXASjARkDHkwjnW_X4',
    'userId': '10aUUXfPyfg82YIpEBxZNP3J2782',
    'rating': 4,
    'text': '''Portions are generous and presentation was on point.''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Smoked Duck Carbonara',
        'taste': ["Crunchy", "Tangy"],
        'ingredients': ["Dairy", "Soy"],
        'dietary': ["Low-carb", "Dairy-free"],
      },
      {
        'name': 'Soft-shell Crab Fettuccine',
        'taste': ["Tangy"],
        'ingredients': ["Eggs"],
        'dietary': ["Low-sugar", "Vegan"],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJxcxcoBXASjARkDHkwjnW_X4',
    'userId': '10aUUXfPyfg82YIpEBxZNP3J2782',
    'rating': 5,
    'text': '''A bit too salty for my taste, but still quite good overall.''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Soft-shell Crab Fettuccine',
        'taste': ["Sweet", "Tangy"],
        'ingredients': ["Fish"],
        'dietary': ["Pescatarian", "Low-carb"],
      },
      {
        'name': 'Smoked Duck Carbonara',
        'taste': ["Spicy"],
        'ingredients': ["Eggs"],
        'dietary': ["Nut-free"],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJxcxcoBXASjARkDHkwjnW_X4',
    'userId': '10aUUXfPyfg82YIpEBxZNP3J2782',
    'rating': 3,
    'text': '''Could be improved slightly, but solid experience overall.''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Classic Tiramisu',
        'taste': ["Creamy", "Earthy"],
        'ingredients': [],
        'dietary': ["Low-fat"],
      },
      {
        'name': 'Soft-shell Crab Fettuccine',
        'taste': ["Crunchy"],
        'ingredients': [],
        'dietary': [],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJxcxcoBXASjARkDHkwjnW_X4',
    'userId': 'kxUxacQB6Cd151lvkZVZAadZWA12',
    'rating': 4,
    'text': '''A bit too salty for my taste, but still quite good overall.''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Soft-shell Crab Fettuccine',
        'taste': ["Crunchy", "Savoury"],
        'ingredients': ["Dairy"],
        'dietary': [],
      },
      {
        'name': 'Classic Tiramisu',
        'taste': ["Earthy"],
        'ingredients': [],
        'dietary': ["Vegan", "Vegetarian"],
      },
      {
        'name': 'Mushroom Soup',
        'taste': ["Sweet", "Crunchy"],
        'ingredients': [],
        'dietary': ["Low-carb", "Low-fat"],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJxcxcoBXASjARkDHkwjnW_X4',
    'userId': 'yOP6Ugkx6oWJtD8cQ6QcoWuJe0z2',
    'rating': 5,
    'text': '''A unique twist on classic dishes, highly recommended.''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Mushroom Soup',
        'taste': ["Savoury"],
        'ingredients': ["Tree nuts"],
        'dietary': ["Low-carb"],
      },
      {
        'name': 'Classic Tiramisu',
        'taste': ["Tangy"],
        'ingredients': ["Eggs"],
        'dietary': [],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJxcxcoBXASjARkDHkwjnW_X4',
    'userId': 'WsqPIZCrY7SpG6PU05FXTAOsgUr1',
    'rating': 5,
    'text': '''Loved the texture and the balance of spices in these dishes!''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Soft-shell Crab Fettuccine',
        'taste': ["Sweet"],
        'ingredients': [],
        'dietary': [],
      },
      {
        'name': 'Arang Chicken Chop',
        'taste': ["Tangy"],
        'ingredients': ["Eggs"],
        'dietary': ["Gluten-free"],
      },
      {
        'name': 'Mushroom Soup',
        'taste': ["Creamy", "Earthy"],
        'ingredients': [],
        'dietary': ["Low-sugar"],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJxcxcoBXASjARkDHkwjnW_X4',
    'userId': 'yOP6Ugkx6oWJtD8cQ6QcoWuJe0z2',
    'rating': 5,
    'text': '''Amazing value for the quality—definitely coming back!''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Mushroom Soup',
        'taste': ["Crunchy", "Savoury"],
        'ingredients': [],
        'dietary': ["Halal"],
      },
      {
        'name': 'Grilled Chicken & Cheese Sandwich',
        'taste': ["Creamy", "Crunchy"],
        'ingredients': ["Dairy"],
        'dietary': [],
      },
      {
        'name': 'Salted Egg Chicken Chop',
        'taste': ["Spicy"],
        'ingredients': ["Fish", "Tree nuts"],
        'dietary': ["Dairy-free", "Pescatarian"],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJxcxcoBXASjARkDHkwjnW_X4',
    'userId': 'yOP6Ugkx6oWJtD8cQ6QcoWuJe0z2',
    'rating': 3,
    'text': '''A bit too salty for my taste, but still quite good overall.''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Arang Chicken Chop',
        'taste': ["Earthy", "Sweet"],
        'ingredients': ["Peanuts"],
        'dietary': ["Low-sugar"],
      },
      {
        'name': 'Classic Tiramisu',
        'taste': ["Crunchy"],
        'ingredients': ["Shellfish", "Fish"],
        'dietary': [],
      },
      {
        'name': 'Salted Egg French Fries',
        'taste': ["Spicy", "Crunchy"],
        'ingredients': ["Dairy", "Shellfish"],
        'dietary': [],
      },
      {
        'name': 'Chocolate Muffin',
        'taste': ["Earthy"],
        'ingredients': [],
        'dietary': [],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJxcxcoBXASjARkDHkwjnW_X4',
    'userId': 'RQatDUprR6SsiP4abqoEeSRvdHF3',
    'rating': 5,
    'text': '''Pretty good, but one item was a bit too oily for me.''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Grilled Chicken & Cheese Sandwich',
        'taste': ["Crunchy", "Creamy"],
        'ingredients': ["Eggs"],
        'dietary': ["Pescatarian"],
      },
      {
        'name': 'Salted Egg French Fries',
        'taste': ["Spicy"],
        'ingredients': [],
        'dietary': ["Halal", "Dairy-free"],
      },
      {
        'name': 'Hawaiian Chicken Polo Burger',
        'taste': ["Creamy", "Crunchy"],
        'ingredients': ["Fish", "Soy"],
        'dietary': [],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJxcxcoBXASjARkDHkwjnW_X4',
    'userId': 'kxUxacQB6Cd151lvkZVZAadZWA12',
    'rating': 5,
    'text': '''Loved the texture and the balance of spices in these dishes!''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Soft-shell Crab Fettuccine',
        'taste': ["Sweet"],
        'ingredients': ["Eggs", "Soy"],
        'dietary': ["Low-carb"],
      },
      {
        'name': 'Smoked Duck Carbonara',
        'taste': ["Tangy"],
        'ingredients': [],
        'dietary': ["Halal"],
      },
      {
        'name': 'Classic Tiramisu',
        'taste': ["Earthy"],
        'ingredients': ["Dairy"],
        'dietary': ["Vegan", "Nut-free"],
      },
      {
        'name': 'Fish & Chips',
        'taste': ["Sweet", "Earthy"],
        'ingredients': ["Gluten", "Peanuts"],
        'dietary': ["Halal"],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJxcxcoBXASjARkDHkwjnW_X4',
    'userId': 'WsqPIZCrY7SpG6PU05FXTAOsgUr1',
    'rating': 4,
    'text': '''A bit too salty for my taste, but still quite good overall.''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Arang Chicken Chop',
        'taste': ["Savoury"],
        'ingredients': ["Shellfish"],
        'dietary': ["Halal", "Pescatarian"],
      },
      {
        'name': 'Classic Tiramisu',
        'taste': ["Crunchy"],
        'ingredients': ["Peanuts"],
        'dietary': ["Low-carb"],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJ0zK1oufBSjARMtRgmhhDmvg',
    'userId': 'yOP6Ugkx6oWJtD8cQ6QcoWuJe0z2',
    'rating': 5,
    'text':
        '''Really enjoyed the flavors, everything was fresh and delicious.''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Wasabi Prawn Taco',
        'taste': ["Earthy", "Creamy"],
        'ingredients': ["Dairy"],
        'dietary': ["Gluten-free", "Vegetarian"],
      },
      {
        'name': 'Truffle Mushroom',
        'taste': ["Sweet", "Earthy"],
        'ingredients': ["Gluten"],
        'dietary': ["Pescatarian"],
      },
      {
        'name': 'Gochujang Parmigiana',
        'taste': ["Earthy"],
        'ingredients': [],
        'dietary': ["Pescatarian"],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJ0zK1oufBSjARMtRgmhhDmvg',
    'userId': '10aUUXfPyfg82YIpEBxZNP3J2782',
    'rating': 3,
    'text': '''A bit too salty for my taste, but still quite good overall.''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Truffle Mushroom',
        'taste': ["Sweet"],
        'ingredients': ["Soy"],
        'dietary': [],
      },
      {
        'name': 'Halibut & Chips',
        'taste': ["Spicy", "Earthy"],
        'ingredients': ["Shellfish"],
        'dietary': [],
      },
      {
        'name': 'Alfredo Mushroom',
        'taste': ["Earthy"],
        'ingredients': [],
        'dietary': [],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJ0zK1oufBSjARMtRgmhhDmvg',
    'userId': 'at1VuTgY0tQ77x95sntsQmoz7QF3',
    'rating': 5,
    'text': '''Could be improved slightly, but solid experience overall.''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Truffle Mushroom',
        'taste': ["Spicy"],
        'ingredients': ["Peanuts"],
        'dietary': ["Low-sugar", "Pescatarian"],
      },
      {
        'name': 'Wasabi Prawn Taco',
        'taste': ["Tangy"],
        'ingredients': [],
        'dietary': ["Vegan"],
      },
      {
        'name': 'Alfredo Mushroom',
        'taste': ["Earthy", "Sweet"],
        'ingredients': ["Fish"],
        'dietary': ["Pescatarian"],
      },
      {
        'name': 'Sam Rot Wing [NEW]',
        'taste': ["Spicy"],
        'ingredients': ["Dairy", "Eggs"],
        'dietary': ["Dairy-free", "Low-fat"],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJ0zK1oufBSjARMtRgmhhDmvg',
    'userId': 'WsqPIZCrY7SpG6PU05FXTAOsgUr1',
    'rating': 5,
    'text': '''Amazing value for the quality—definitely coming back!''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Dalgona Coffee',
        'taste': ["Savoury", "Crunchy"],
        'ingredients': ["Dairy"],
        'dietary': [],
      },
      {
        'name': 'Gochujang Parmigiana',
        'taste': ["Crunchy"],
        'ingredients': ["Shellfish", "Gluten"],
        'dietary': [],
      },
      {
        'name': 'Wasabi Prawn Taco',
        'taste': ["Crunchy", "Creamy"],
        'ingredients': ["Gluten", "Shellfish"],
        'dietary': ["Vegan", "Gluten-free"],
      },
      {
        'name': 'Halibut & Chips',
        'taste': ["Creamy"],
        'ingredients': ["Shellfish", "Gluten"],
        'dietary': ["Nut-free", "Vegetarian"],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJ0zK1oufBSjARMtRgmhhDmvg',
    'userId': 'kxUxacQB6Cd151lvkZVZAadZWA12',
    'rating': 5,
    'text': '''A unique twist on classic dishes, highly recommended.''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Truffle Mushroom',
        'taste': ["Earthy"],
        'ingredients': [],
        'dietary': [],
      },
      {
        'name': 'Dalgona Coffee',
        'taste': ["Crunchy"],
        'ingredients': ["Dairy"],
        'dietary': ["Low-fat", "Vegetarian"],
      },
      {
        'name': 'Halibut & Chips',
        'taste': ["Sweet"],
        'ingredients': ["Dairy"],
        'dietary': ["Low-fat"],
      },
      {
        'name': 'Taro Matcha [NEW]',
        'taste': ["Savoury", "Crunchy"],
        'ingredients': ["Gluten", "Peanuts"],
        'dietary': ["Low-carb", "Low-fat"],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJ0zK1oufBSjARMtRgmhhDmvg',
    'userId': 'WsqPIZCrY7SpG6PU05FXTAOsgUr1',
    'rating': 5,
    'text': '''Loved the texture and the balance of spices in these dishes!''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Wasabi Prawn Taco',
        'taste': ["Crunchy", "Creamy"],
        'ingredients': [],
        'dietary': ["Low-carb"],
      },
      {
        'name': 'Truffle Fries',
        'taste': ["Creamy"],
        'ingredients': [],
        'dietary': ["Dairy-free"],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJ0zK1oufBSjARMtRgmhhDmvg',
    'userId': 'kxUxacQB6Cd151lvkZVZAadZWA12',
    'rating': 4,
    'text':
        '''Really enjoyed the flavors, everything was fresh and delicious.''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Truffle Fries',
        'taste': ["Savoury"],
        'ingredients': ["Peanuts"],
        'dietary': ["Vegetarian"],
      },
      {
        'name': 'Dalgona Coffee',
        'taste': ["Sweet", "Savoury"],
        'ingredients': ["Shellfish", "Eggs"],
        'dietary': ["Vegetarian", "Low-sugar"],
      },
      {
        'name': 'Wasabi Prawn Taco',
        'taste': ["Creamy", "Savoury"],
        'ingredients': ["Shellfish"],
        'dietary': [],
      },
      {
        'name': 'Unagi Tempura Taco',
        'taste': ["Spicy"],
        'ingredients': [],
        'dietary': ["Gluten-free", "Nut-free"],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJ0zK1oufBSjARMtRgmhhDmvg',
    'userId': 'Q9IOGLR644WpJEAufIerlOrp5Aa2',
    'rating': 3,
    'text': '''Amazing value for the quality—definitely coming back!''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Wasabi Prawn Taco',
        'taste': ["Earthy", "Creamy"],
        'ingredients': [],
        'dietary': ["Low-sugar", "Gluten-free"],
      },
      {
        'name': 'Halibut & Chips',
        'taste': ["Creamy"],
        'ingredients': ["Dairy"],
        'dietary': ["Halal"],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJ0zK1oufBSjARMtRgmhhDmvg',
    'userId': 'at1VuTgY0tQ77x95sntsQmoz7QF3',
    'rating': 5,
    'text': '''Could be improved slightly, but solid experience overall.''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Dalgona Coffee',
        'taste': ["Tangy"],
        'ingredients': ["Tree nuts", "Soy"],
        'dietary': [],
      },
      {
        'name': 'Halibut & Chips',
        'taste': ["Sweet", "Crunchy"],
        'ingredients': [],
        'dietary': ["Nut-free", "Low-fat"],
      },
      {
        'name': 'Gochujang Parmigiana',
        'taste': ["Savoury"],
        'ingredients': ["Peanuts"],
        'dietary': ["Gluten-free", "Dairy-free"],
      },
      {
        'name': 'Alfredo Mushroom',
        'taste': ["Tangy", "Creamy"],
        'ingredients': ["Dairy"],
        'dietary': ["Pescatarian"],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJ0zK1oufBSjARMtRgmhhDmvg',
    'userId': 'yOP6Ugkx6oWJtD8cQ6QcoWuJe0z2',
    'rating': 4,
    'text': '''Great blend of textures and flavors—savory and satisfying.''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Halibut & Chips',
        'taste': ["Savoury"],
        'ingredients': ["Tree nuts", "Shellfish"],
        'dietary': ["Low-sugar"],
      },
      {
        'name': 'Truffle Mushroom',
        'taste': ["Crunchy"],
        'ingredients': ["Soy", "Fish"],
        'dietary': [],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJ0zK1oufBSjARMtRgmhhDmvg',
    'userId': 'RQatDUprR6SsiP4abqoEeSRvdHF3',
    'rating': 4,
    'text': '''A unique twist on classic dishes, highly recommended.''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Gochujang Parmigiana',
        'taste': ["Crunchy"],
        'ingredients': ["Tree nuts"],
        'dietary': ["Gluten-free", "Nut-free"],
      },
      {
        'name': 'Truffle Fries',
        'taste': ["Tangy", "Savoury"],
        'ingredients': [],
        'dietary': [],
      },
      {
        'name': 'Halibut & Chips',
        'taste': ["Creamy", "Savoury"],
        'ingredients': [],
        'dietary': ["Vegetarian"],
      },
      {
        'name': 'Salmon Nori Miso [NEW]',
        'taste': ["Earthy"],
        'ingredients': [],
        'dietary': ["Low-fat", "Nut-free"],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJ0zK1oufBSjARMtRgmhhDmvg',
    'userId': 'yOP6Ugkx6oWJtD8cQ6QcoWuJe0z2',
    'rating': 4,
    'text': '''Amazing value for the quality—definitely coming back!''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Halibut & Chips',
        'taste': ["Creamy"],
        'ingredients': [],
        'dietary': ["Low-sugar", "Low-fat"],
      },
      {
        'name': 'Wasabi Prawn Taco',
        'taste': ["Creamy", "Spicy"],
        'ingredients': [],
        'dietary': ["Nut-free"],
      },
      {
        'name': 'Gochujang Parmigiana',
        'taste': ["Earthy", "Crunchy"],
        'ingredients': ["Peanuts", "Gluten"],
        'dietary': ["Low-carb"],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJ0zK1oufBSjARMtRgmhhDmvg',
    'userId': 'yOP6Ugkx6oWJtD8cQ6QcoWuJe0z2',
    'rating': 4,
    'text': '''Could be improved slightly, but solid experience overall.''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Wasabi Prawn Taco',
        'taste': ["Spicy"],
        'ingredients': [],
        'dietary': [],
      },
      {
        'name': 'Truffle Mushroom',
        'taste': ["Creamy", "Savoury"],
        'ingredients': ["Dairy"],
        'dietary': [],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJ0zK1oufBSjARMtRgmhhDmvg',
    'userId': 'at1VuTgY0tQ77x95sntsQmoz7QF3',
    'rating': 4,
    'text': '''Portions are generous and presentation was on point.''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Truffle Mushroom',
        'taste': ["Earthy"],
        'ingredients': ["Gluten"],
        'dietary': ["Vegetarian", "Low-sugar"],
      },
      {
        'name': 'Gochujang Parmigiana',
        'taste': ["Tangy", "Earthy"],
        'ingredients': [],
        'dietary': ["Pescatarian", "Halal"],
      },
    ],
  });

  await FirebaseFirestore.instance.collection('user_reviews').add({
    'restaurantId': 'ChIJ0zK1oufBSjARMtRgmhhDmvg',
    'userId': '10aUUXfPyfg82YIpEBxZNP3J2782',
    'rating': 5,
    'text': '''Pretty good, but one item was a bit too oily for me.''',
    'createdAt': FieldValue.serverTimestamp(),
    'dishes': [
      {
        'name': 'Gochujang Parmigiana',
        'taste': ["Crunchy"],
        'ingredients': ["Eggs"],
        'dietary': ["Low-carb", "Vegetarian"],
      },
      {
        'name': 'Halibut & Chips',
        'taste': ["Spicy"],
        'ingredients': ["Shellfish"],
        'dietary': [],
      },
      {
        'name': 'Truffle Mushroom',
        'taste': ["Spicy", "Earthy"],
        'ingredients': ["Eggs", "Dairy"],
        'dietary': [],
      },
    ],
  });
}
