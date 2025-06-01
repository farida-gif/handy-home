import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MultiSelectDropdown extends StatefulWidget {
  final String label;
  final String hintText;
  final List<String> options; // untranslated
  final List<String> selectedValues;
  final void Function(List<String>) onChanged;

  const MultiSelectDropdown({
    super.key,
    required this.label,
    required this.hintText,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
  });

  @override
  State<MultiSelectDropdown> createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  bool _isExpanded = false;
  late List<String> _tempSelectedValues;

  @override
  void initState() {
    super.initState();
    _tempSelectedValues = List<String>.from(widget.selectedValues);
  }

  void _toggleSelection(String value) {
    setState(() {
      if (_tempSelectedValues.contains(value)) {
        _tempSelectedValues.remove(value);
      } else {
        _tempSelectedValues.add(value);
      }
      widget.onChanged(_tempSelectedValues);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 12),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.primary),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _tempSelectedValues.map((value) {
    return Chip(
  label: Text(value.tr),
  avatar: const Icon(Icons.check_circle, color: Colors.green, size: 15),
  deleteIcon: const Icon(Icons.cancel, color: Colors.grey, size: 15),
  onDeleted: () => _toggleSelection(value),
);
  }).toList(),
                  ),
                ),
                Icon(_isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: widget.options.map((value) {
                final isSelected = _tempSelectedValues.contains(value);
                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (_) => _toggleSelection(value),
                  title: Text(value.tr),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
