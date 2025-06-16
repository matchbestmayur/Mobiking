import 'package:flutter/material.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const QuantitySelector({
    Key? key,
    required this.quantity,
    this.onIncrement,
    this.onDecrement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: onDecrement != null ? () => onDecrement!() : null,
          color: onDecrement == null ? Colors.grey : Colors.black,
        ),
        Text(quantity.toString()),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: onIncrement != null ? () => onIncrement!() : null,
          color: onIncrement == null ? Colors.grey : Colors.black,
        ),
      ],
    );
  }
}
