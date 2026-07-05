/// Pure-Dart core of **attest**: the accessibility rule engine, data model,
/// reporting and baseline logic.
///
/// This library depends on nothing Flutter — every rule is a pure function over
/// a serializable [SemanticsSnapshot], so rules are unit-testable without a
/// widget tester. Flutter-specific collection lives in `attest_flutter`.
///
/// This barrel is the only supported entry point. Nothing under `src/` is
/// exported directly; import only `package:attest/attest.dart`.
library;

export 'src/engine/fingerprint.dart';
export 'src/engine/rule.dart';
export 'src/engine/rule_config.dart';
export 'src/engine/rule_engine.dart';
export 'src/engine/snapshot_index.dart';
export 'src/model/audit_meta.dart';
export 'src/model/audit_report.dart';
export 'src/model/confidence.dart';
export 'src/model/contrast_sample.dart';
export 'src/model/criterion.dart';
export 'src/model/finding.dart';
export 'src/model/rect_data.dart';
export 'src/model/semantics_action.dart';
export 'src/model/semantics_flag.dart';
export 'src/model/semantics_node_data.dart';
export 'src/model/semantics_snapshot.dart';
export 'src/model/severity.dart';
export 'src/model/source_location.dart';
export 'src/model/standard.dart';
export 'src/model/target_size_mode.dart';
export 'src/model/text_direction_data.dart';
export 'src/model/text_scale_observation.dart';
export 'src/model/text_style_data.dart';
export 'src/report/baseline.dart';
export 'src/report/baseline_gate.dart';
export 'src/report/flow_analysis.dart';
export 'src/report/sarif.dart';
export 'src/report/transcript.dart';
export 'src/rules/adjustable_value_rule.dart';
export 'src/rules/ambiguous_name_rule.dart';
export 'src/rules/contrast_rule.dart';
export 'src/rules/criteria.dart';
export 'src/rules/field_label_rule.dart';
export 'src/rules/focus_order_rule.dart';
export 'src/rules/focus_trap_rule.dart';
export 'src/rules/generic_link_text_rule.dart';
export 'src/rules/heading_structure_rule.dart';
export 'src/rules/image_alt_rule.dart';
export 'src/rules/interactive_name_rule.dart';
export 'src/rules/non_text_contrast_rule.dart';
export 'src/rules/placeholder_name_rule.dart';
export 'src/rules/state_exposed_rule.dart';
export 'src/rules/target_size_rule.dart';
export 'src/rules/text_overflow_rule.dart';
export 'src/standards/conformance_report.dart';
export 'src/standards/coverage_matrix.dart';
export 'src/standards/criterion_coverage.dart';
export 'src/standards/wcag_registry.dart';
