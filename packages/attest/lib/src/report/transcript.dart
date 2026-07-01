import '../model/semantics_flag.dart';
import '../model/semantics_node_data.dart';
import '../model/semantics_snapshot.dart';

/// Produces the screen-reader transcript for a snapshot: the sequence of
/// announcements TalkBack or VoiceOver would make, in traversal order.
///
/// This is a first-class feature and a differentiator — it works because the
/// snapshot captures the real traversal order and each node's role and state.
/// It is a plain-language approximation, not a byte-exact reproduction of any
/// one screen reader.
class TranscriptGenerator {
  /// Creates a [TranscriptGenerator].
  const TranscriptGenerator();

  /// Walks [snapshot] in traversal order and returns one line per announced
  /// node. Hidden and empty nodes are skipped, as a screen reader skips them.
  List<String> generate(SemanticsSnapshot snapshot) {
    final lines = <String>[];
    void visit(SemanticsNodeData node) {
      final line = _announce(node);
      if (line != null) lines.add(line);
      for (final child in node.childrenInTraversalOrder) {
        visit(child);
      }
    }

    visit(snapshot.root);
    return lines;
  }

  String? _announce(SemanticsNodeData node) {
    if (node.hasFlag(SemanticsFlagData.isHidden)) return null;

    final name =
        node.label.trim().isNotEmpty ? node.label.trim() : node.value.trim();
    final role = _role(node);
    final state = _state(node);
    final hint = node.hint.trim();

    if (name.isEmpty && role == null && state == null && hint.isEmpty) {
      return null;
    }

    return [
      if (name.isNotEmpty) name,
      if (role != null) role,
      if (state != null) state,
      if (hint.isNotEmpty) hint,
    ].join(', ');
  }

  String? _role(SemanticsNodeData node) {
    if (node.hasFlag(SemanticsFlagData.isButton)) return 'button';
    if (node.hasFlag(SemanticsFlagData.isLink)) return 'link';
    if (node.hasFlag(SemanticsFlagData.isTextField)) return 'edit box';
    if (node.hasFlag(SemanticsFlagData.hasToggledState)) return 'switch';
    if (node.hasFlag(SemanticsFlagData.hasCheckedState)) return 'checkbox';
    if (node.hasFlag(SemanticsFlagData.isImage)) return 'image';
    if (node.hasFlag(SemanticsFlagData.isHeader)) return 'heading';
    return null;
  }

  String? _state(SemanticsNodeData node) {
    if (node.hasFlag(SemanticsFlagData.hasCheckedState)) {
      return node.hasFlag(SemanticsFlagData.isChecked)
          ? 'checked'
          : 'not checked';
    }
    if (node.hasFlag(SemanticsFlagData.hasToggledState)) {
      return node.hasFlag(SemanticsFlagData.isToggled) ? 'on' : 'off';
    }
    if (node.hasFlag(SemanticsFlagData.isSelected)) return 'selected';
    return null;
  }
}
