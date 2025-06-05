import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../dummy/products_data.dart';
import '../../profile/wishlist/Wish_list_card.dart';

class pro {
  final String name;
  final double price;
  final List<String> variants;

  pro({
    required this.name,
    required this.price,
    this.variants = const [],
  });

  bool get hasVariants => variants.isNotEmpty;
}

class VariantSelectorBottomSheet extends StatelessWidget {
  final pro product;

  const VariantSelectorBottomSheet({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    String? selectedVariant;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                "Select Variant",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: product.variants.map((variant) {
                  final isSelected = variant == selectedVariant;
                  return ChoiceChip(
                    label: Text(
                      variant,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selectedColor: Colors.teal,
                    backgroundColor: Colors.grey[200],
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        selectedVariant = variant;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: isSelected ? 6 : 0,
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: selectedVariant == null
                      ? null
                      : () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "${product.name} ($selectedVariant) added to cart",
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        backgroundColor: Colors.green[700],
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Add to Cart",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {


    List<pro> dummyProducts = [
      pro(name: "Rockwear 45C", price: 1499.0, variants: ["Black", "Gray"]),
      pro(name: "Airbuds 14T", price: 1099.0), // No variant
      pro(name: "Gaming Headset", price: 1999.0, variants: ["Red", "Blue", "Green"]),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: ListView.builder(
        itemCount: dummyProducts.length,
        itemBuilder: (context, index) {
          final product = dummyProducts[index];
          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              title: Text(product.name),
              subtitle: Text("₹${product.price.toStringAsFixed(2)}"),
              trailing: ElevatedButton(
                onPressed: () {
                  if (product.hasVariants) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (_) {
                        final height = MediaQuery.of(context).size.height * 0.5; // 50% height
                        return SizedBox(
                          height: height,
                          child: Material( // Required for ChoiceChip
                            child: VariantSelectorBottomSheet(product: product),
                          ),
                        );
                      },
                    );

                  } else {
                    // Add to cart directly (mock)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${product.name} added to cart")),
                    );
                  }
                },
                child: const Text("ADD"),
              ),
            ),
          );
        },
      ),
    );
  }
}
