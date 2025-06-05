import 'package:flutter/material.dart';

class CustomColorSelector extends StatefulWidget {
  final List<Map<String, dynamic>> colorOptions;
  final int initialSelectedIndex;
  final Function(int index, Map<String, dynamic> selectedColor) onColorSelected;

  const CustomColorSelector({
    super.key,
    required this.colorOptions,
    this.initialSelectedIndex = 0,
    required this.onColorSelected,
  });

  @override
  State<CustomColorSelector> createState() => _CustomColorSelectorState();
}

class _CustomColorSelectorState extends State<CustomColorSelector> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialSelectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Colour',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(widget.colorOptions.length, (index) {
            final colorItem = widget.colorOptions[index];
            final bool isSelected = index == selectedIndex;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
                widget.onColorSelected(index, colorItem);
              },
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.deepPurple : Colors.grey.shade400,
                    width: 1,
                  ),
                ),
                width: 90,
                height: 95,
                child: Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorItem['color'],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          colorItem['name'],
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
