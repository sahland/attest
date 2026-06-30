import '../model/semantics_flag.dart';
import '../model/semantics_node_data.dart';
import '../model/semantics_snapshot.dart';

/// Precomputed lookups over a [SemanticsSnapshot] that rules and the engine share.
///
/// Building this once per audit avoids every rule re-walking the tree to find a
/// node's parent or its structural path.
class SnapshotIndex {
  SnapshotIndex._(this._parents, this._paths);

  /// Builds an index for [snapshot] by walking the tree once.
  factory SnapshotIndex.build(SemanticsSnapshot snapshot) {
    final parents = <int, SemanticsNodeData?>{};
    final paths = <int, String>{};

    void visit(SemanticsNodeData node, SemanticsNodeData? parent, String path) {
      parents[node.id] = parent;
      paths[node.id] = path;
      final children = node.childrenInTraversalOrder;
      for (var i = 0; i < children.length; i++) {
        final child = children[i];
        visit(child, node, '$path/${_roleOf(child)}:$i');
      }
    }

    visit(snapshot.root, null, _roleOf(snapshot.root));
    return SnapshotIndex._(parents, paths);
  }

  final Map<int, SemanticsNodeData?> _parents;
  final Map<int, String> _paths;

  /// The parent of [node], or `null` if it is the root or absent from the index.
  SemanticsNodeData? parentOf(SemanticsNodeData node) => _parents[node.id];

  /// The structural path of [node] from the root, e.g. `node/button:0/text:1`.
  ///
  /// Segments are `role:siblingIndex`, so the path is stable under layout shifts
  /// (no coordinates) but changes when the tree structure changes.
  String pathOf(SemanticsNodeData node) => _paths[node.id] ?? _roleOf(node);

  /// A coarse role label for [node], derived from its flags, used in paths.
  static String _roleOf(SemanticsNodeData node) {
    if (node.hasFlag(SemanticsFlagData.isButton)) return 'button';
    if (node.hasFlag(SemanticsFlagData.isLink)) return 'link';
    if (node.hasFlag(SemanticsFlagData.isTextField)) return 'textField';
    if (node.hasFlag(SemanticsFlagData.isImage)) return 'image';
    if (node.hasFlag(SemanticsFlagData.isHeader)) return 'header';
    if (node.label.isNotEmpty) return 'text';
    return 'node';
  }
}
