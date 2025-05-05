import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

class RichTextEditor extends StatefulWidget {
  final bool removeAt;
  const RichTextEditor({super.key, this.removeAt = false});

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<TextEditingValue> _undoHistory = [];
  final List<TextEditingValue> _redoHistory = [];
  int _currentListIndex = 1;

  // Formatting options
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderlined = false;
  bool _isStrikethrough = false;
  double _fontSize = 16.0;

  // Task and project references
  final List<String> _projectTags = ['#123TSK', '#PROJ01', '#DESIGN'];
  bool _showProjectTagSuggestions = false;
  String _currentTagQuery = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    setState(() {
      // Save to undo history when text changes
      if (_undoHistory.isEmpty || _controller.text != _undoHistory.last.text) {
        _undoHistory.add(_controller.value);
        _redoHistory.clear();
      }
    });
  }

  void _undo() {
    if (_undoHistory.length > 1) {
      setState(() {
        _redoHistory.add(_undoHistory.removeLast());
        _controller.value = _undoHistory.last;
      });
    }
  }

  void _redo() {
    if (_redoHistory.isNotEmpty) {
      setState(() {
        _undoHistory.add(_redoHistory.removeLast());
        _controller.value = _undoHistory.last;
      });
    }
  }

  void _toggleBold() {
    setState(() => _isBold = !_isBold);
  }

  void _toggleItalic() {
    setState(() => _isItalic = !_isItalic);
  }

  void _toggleUnderline() {
    setState(() => _isUnderlined = !_isUnderlined);
  }

  void _toggleStrikethrough() {
    setState(() => _isStrikethrough = !_isStrikethrough);
  }

  void _changeFontSize(double size) {
    setState(() => _fontSize = size);
  }

  void _addListItem() {
    final currentText = _controller.text;
    final selection = _controller.selection;

    final listItem = '\n${_currentListIndex + 1}. ';
    final newText =
        currentText.replaceRange(selection.end, selection.end, listItem);

    _controller.value = TextEditingValue(
      text: newText,
      selection:
          TextSelection.collapsed(offset: selection.end + listItem.length),
    );

    setState(() {
      _currentListIndex++;
    });
  }

  void _checkForTagTrigger(String value) {
    if (widget.removeAt) {
      return;
    }
    // Check if '@' is typed and show project tag suggestions
    final selection = _controller.selection;
    if (selection.isCollapsed && selection.start > 0) {
      final textBeforeCursor = value.substring(0, selection.start);
      final matches = RegExp(r'@(\w*)$').firstMatch(textBeforeCursor);

      if (matches != null) {
        setState(() {
          _showProjectTagSuggestions = true;
          _currentTagQuery = matches.group(1) ?? '';
        });
      } else {
        setState(() {
          _showProjectTagSuggestions = false;
        });
      }
    }
  }

  void _insertProjectTag(String tag) {
    final selection = _controller.selection;
    final textBeforeCursor = _controller.text.substring(0, selection.start);
    final lastAtIndex = textBeforeCursor.lastIndexOf('@');

    if (lastAtIndex >= 0) {
      final newText =
          _controller.text.replaceRange(lastAtIndex, selection.start, '@$tag');
      _controller.value = TextEditingValue(
        text: newText,
        selection:
            TextSelection.collapsed(offset: lastAtIndex + tag.length + 1),
      );
    }

    setState(() {
      _showProjectTagSuggestions = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 232,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormatToolbar(),
          Expanded(
            child: Stack(
              children: [
                _buildTextEditor(),
                if (_showProjectTagSuggestions) _buildTagSuggestions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatToolbar() {
    return Container(
      color: AppColors.white,
      child: Wrap(
        children: [
          _buildFontSizeDropdown(),
          const SizedBox(width: 8),
          _buildFormatButton(
            Icon(Icons.format_bold,
                color: _isBold ? AppColors.blue : AppColors.black),
            _toggleBold,
          ),
          _buildFormatButton(
            Icon(Icons.format_italic,
                color: _isItalic ? AppColors.blue : AppColors.black),
            _toggleItalic,
          ),
          _buildFormatButton(
            Icon(Icons.format_underlined,
                color: _isUnderlined ? AppColors.blue : AppColors.black),
            _toggleUnderline,
          ),
          _buildFormatButton(
            Icon(Icons.strikethrough_s,
                color: _isStrikethrough ? AppColors.blue : AppColors.black),
            _toggleStrikethrough,
          ),
          if (!widget.removeAt)
            _buildFormatButton(
              const Icon(Icons.alternate_email),
              () {
                // Insert @ symbol at current cursor position
                final selection = _controller.selection;
                final newText = _controller.text
                    .replaceRange(selection.start, selection.end, '@');
                _controller.value = TextEditingValue(
                  text: newText,
                  selection:
                      TextSelection.collapsed(offset: selection.start + 1),
                );
                setState(() {
                  _showProjectTagSuggestions = true;
                  _currentTagQuery = '';
                });
                _focusNode.requestFocus();
              },
            ),
          if (!widget.removeAt) ...[
            Expanded(
              child: MyText(
                '(use the @ button to make reference to a particular project or Tasks. E.g @#123TSK)',
                maxLines: 1,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            const MyText('*',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ]
        ],
      ),
    );
  }

  Widget _buildFontSizeDropdown() {
    return DropdownButton<double>(
      value: _fontSize,
      items: [12.0, 14.0, 16.0, 18.0, 20.0, 24.0, 28.0, 32.0]
          .map((size) => DropdownMenuItem<double>(
                value: size,
                child: MyText(
                  "Size $size",
                  isSelectable: false,
                ),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) _changeFontSize(value);
      },
      underline: Container(height: 0),
      icon: const Icon(Icons.arrow_drop_down),
      style: const TextStyle(color: Colors.black, fontSize: 14),
    );
  }

  Widget _buildFormatButton(Icon icon, VoidCallback onPressed) {
    return IconButton(
      icon: icon,
      onPressed: onPressed,
      splashRadius: 20,
    );
  }

  Widget _buildTextEditor() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Start typing...',
        ),
        style: TextStyle(
          fontSize: _fontSize,
          fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
          fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
          decoration: _buildTextDecoration(),
        ),
        onChanged: _checkForTagTrigger,
        onSubmitted: (value) {
          if (value.trim().endsWith('.')) {
            _addListItem();
          }
        },
      ),
    );
  }

  TextDecoration _buildTextDecoration() {
    if (_isUnderlined && _isStrikethrough) {
      return TextDecoration.combine(
          [TextDecoration.underline, TextDecoration.lineThrough]);
    } else if (_isUnderlined) {
      return TextDecoration.underline;
    } else if (_isStrikethrough) {
      return TextDecoration.lineThrough;
    }
    return TextDecoration.none;
  }

  Widget _buildTagSuggestions() {
    final filteredTags = _projectTags
        .where(
            (tag) => tag.toLowerCase().contains(_currentTagQuery.toLowerCase()))
        .toList();

    return Positioned(
      top: 50, // Position below where @ was typed
      left: 20,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 200,
          constraints: const BoxConstraints(maxHeight: 200),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: filteredTags.length,
            itemBuilder: (context, index) {
              return ListTile(
                dense: true,
                title: MyText(
                  filteredTags[index],
                  isSelectable: false,
                ),
                onTap: () => _insertProjectTag(filteredTags[index]),
              );
            },
          ),
        ),
      ),
    );
  }
}
