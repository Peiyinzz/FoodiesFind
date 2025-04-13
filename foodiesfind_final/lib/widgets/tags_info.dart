import 'package:flutter/material.dart';

/// A map of allergy tag → human‑readable explanation.
const Map<String, String> allergyTagDescriptions = {
  'Peanuts': 'Avoid any products containing peanuts or peanut oil.',
  'Tree nuts': 'Includes almonds, cashews, walnuts, etc.',
  'Soy': 'Soybeans and derivatives (tofu, soy sauce).',
  'Dairy': 'Milk, cheese, yogurt, butter, and other dairy.',
  'Shellfish': 'Shrimp, crab, lobster, and other shellfish.',
  'Fish': 'All kinds of finned fish (salmon, tuna, etc.).',
  'Eggs': 'Chicken, duck, quail eggs and products.',
  'Gluten': 'Wheat, barley, rye, and foods containing them.',
};

/// A map of dietary preference tag → explanation.
const Map<String, String> dietaryTagDescriptions = {
  'Vegan': 'No animal products at all (meat, dairy, eggs).',
  'Vegetarian': 'No meat or fish, but may include dairy & eggs.',
  'Halal': 'Prepared according to Islamic dietary laws.',
  'Pescatarian': 'No meat, but fish and seafood are allowed.',
  'Dairy-free': 'No milk, cheese, butter, or other dairy.',
  'Gluten-free': 'No wheat, barley, rye, or cross‑contaminated grains.',
  'Nut-free': 'No tree nuts or peanuts in any form.',
  'Low-sugar': 'Minimal added sugars; may contain natural sugars.',
  'Low-carb': 'Restricted carbohydrates; focus on proteins & fats.',
  'Low-fat': 'Limited fat content; lean proteins & low‑fat dairy.',
};

/// A map of taste profile tag → explanation.
const Map<String, String> tasteTagDescriptions = {
  'Savoury': 'Rich, umami‑driven flavors (e.g., soy sauce, cheese).',
  'Sweet': 'Sugary or honeyed tastes (e.g., desserts, fruits).',
  'Bitter': 'Sharp, pungent flavors (e.g., coffee, dark greens).',
  'Spicy': 'Heat‑driven flavors (e.g., chili, pepper).',
  'Creamy': 'Rich and smooth mouthfeel (e.g., cream, yogurt).',
  'Crunchy': 'Textured, crisp elements (e.g., nuts, fried items).',
  'Tangy': 'Sharp acidic notes (e.g., vinegar, citrus).',
  'Earthy': 'Deep, soil‑like flavors (e.g., mushrooms, beets).',
};

/// A reusable dialog that displays a list of tag descriptions.
class TagInfoDialog extends StatelessWidget {
  final String title;
  final Map<String, String> descriptions;

  const TagInfoDialog({
    Key? key,
    required this.title,
    required this.descriptions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFF4F4F4),
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children:
              descriptions.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Text('• ', style: TextStyle(fontSize: 20)),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                            children: [
                              TextSpan(
                                text: '${entry.key}: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: entry.value),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
