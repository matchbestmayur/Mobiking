import 'package:flutter/material.dart';
import 'package:mobiking/app/modules/Categories/widgets/CategoryTile.dart';

class CategorySectionScreen extends StatelessWidget {
  final List<Map<String, dynamic>> categorySections = [
    {
      "title": "Headphones",
      "products": List.generate(6, (index) => {
        "title": "Headphone $index",
        "image": "https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcQy5usaO5YjNqYIZ9LzNFT_UHQ_BAgGFtaQYULa-hnMoT59TuWoYtusUNUQQI7UjMfdoS7hxqcDFZ_f7XfW96gM1K8bellkohGRYyQH3BY"
      }),
    },
    {
      "title": "Earbuds",
      "products": List.generate(6, (index) => {
        "title": "Earbud $index",
        "image": "https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcSkVpsleaqQvKDWo-PwENq7-Eh46-fiShjLJU1wzZYNBF2lq7uRC1m7RoaZSHC79xnB1Gw_E_RDOeAXytWI8tk7siEllfximO-AROgVOF8s7Vvp_0FvdFJY"
      }),
    },
    {
      "title": "Speakers",
      "products": List.generate(6, (index) => {
        "title": "Speaker $index",
        "image": "https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcQ_kMhGmETqOSvMTwQjEh9utTGEfXlgm9kHXL786d_8a8Zk-ssLYUQnbMqeCALkkx_-K2lkln7_sJrsbpRoJtTUsHZnJriUHJazQUtOST3-mv3KKbuJUlKa"
      }),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: categorySections.length,
        itemBuilder: (context, sectionIndex) {
          final section = categorySections[sectionIndex];
          final products = section["products"] as List<Map<String, String>>;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section["title"],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.7,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductTile(
                      title: product["title"]!,
                      imageUrl: product["image"]!,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
