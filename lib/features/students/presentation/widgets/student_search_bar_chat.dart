// lib/features/students/presentation/widgets/student_search_bar.dart
import 'package:flutter/material.dart';

class StudentSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  const StudentSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<StudentSearchBar> createState() => _StudentSearchBarState();
}

class _StudentSearchBarState extends State<StudentSearchBar> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {}); // Rebuild to show/hide clear button
  }

  void _clearSearch() {
    widget.controller.clear();
    widget.onChanged?.call('');
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.isNotEmpty;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focusNode.hasFocus 
              ? Theme.of(context).primaryColor.withOpacity(0.5)
              : Colors.grey[300]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        decoration: InputDecoration(
          hintText: 'Search students by name or phone...',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 16,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.search,
              color: _focusNode.hasFocus 
                  ? Theme.of(context).primaryColor
                  : Colors.grey[400],
              size: 22,
            ),
          ),
          suffixIcon: hasText
              ? IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.grey[600],
                      size: 16,
                    ),
                  ),
                  onPressed: _clearSearch,
                  tooltip: 'Clear search',
                )
              : widget.enabled 
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.filter_list,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                    )
                  : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        onChanged: widget.onChanged,
        textInputAction: TextInputAction.search,
      ),
    );
  }
}