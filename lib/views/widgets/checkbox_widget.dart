import 'package:flutter/material.dart';

class CheckBoxWidget extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChange;

  const CheckBoxWidget({
    super.key,
    required this.value,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChange(!value),
      child: Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.indigo.shade300),
            color: !value ? Colors.indigo.shade100 : Colors.indigo,
            shape: BoxShape.circle,
          ),
          height: 30,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(
              Icons.check,
              color: !value ? Colors.indigo.shade200 : Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
