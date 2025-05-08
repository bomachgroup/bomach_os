import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class RichTextEditor extends StatefulWidget {
  final bool removeAt;
  const RichTextEditor({super.key, this.removeAt = false});

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  final QuillController _controllerQuillEC = QuillController.basic();

  @override
  void dispose() {
    _controllerQuillEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 300),
      child: Column(
        children: [
          Row(
            children: [
              QuillSimpleToolbar(
                controller: _controllerQuillEC,
                config: const QuillSimpleToolbarConfig(
                  showAlignmentButtons: false,
                  showBackgroundColorButton: false,
                  showCenterAlignment: false,
                  showClipboardCut: false,
                  showFontFamily: false,
                  showListNumbers: false,
                  showLineHeightButton: false,
                  showCodeBlock: false,
                  showLink: false,
                  showSubscript: false,
                  showSuperscript: false,
                  showHeaderStyle: false,
                  showSearchButton: false,
                  showIndent: false,
                  showListCheck: false,
                  showInlineCode: false,
                  showUndo: false,
                  showRedo: false,
                  showClearFormat: false,
                  showColorButton: false,
                  showListBullets: false,
                  showQuote: false,
                  // toolbarIconAlignment: WrapAlignment.start,
                  // toolbarIconCrossAlignment: WrapCrossAlignment.start
                  // multiRowsDisplay: false,
                  // showStrikeThrough: false,
                ),
              ),
            ],
          ),
          kSizedBox,
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.card,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: QuillEditor.basic(
                    controller: _controllerQuillEC,
                    config: const QuillEditorConfig(minHeight: 200),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
