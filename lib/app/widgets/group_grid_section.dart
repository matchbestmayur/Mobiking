import 'package:flutter/material.dart';
import '../data/group_model.dart';

class GroupGridSection extends StatelessWidget {
  final List<GroupModel> groups;

  const GroupGridSection({super.key, required this.groups});

  @override
  Widget build(BuildContext context) {
    final itemWidth = MediaQuery.of(context).size.width / 4 - 20;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 16,
        children: groups.map((group) {
          return GestureDetector(
            onTap: () {
              print('Tapped on group: ${group.name}');
              // TODO: Navigate to group detail page
            },
            child: SizedBox(
              width: itemWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey[200],
                      image: DecorationImage(
                        image: NetworkImage(
                          (group.banner.isNotEmpty)
                              ? group.banner
                              : "https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcRbE5vLw1VrGibTbQHOWy5SvqFYKhkq9ilo6MXI-ySv7FCYqjztvx0sVarfxppfI-bJzv941Qbr2qiH0BsXK5lVRimLo-UdoEgrzcp2EX8kcwsn5Y7QPNHk",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    group.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
