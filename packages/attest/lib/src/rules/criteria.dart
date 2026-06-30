import '../model/criterion.dart';

/// The standard criteria the bundled rules cite.
///
/// The EN 301 549 clause numbers follow **v3.2.1**, whose clause 11 (software)
/// mirrors the WCAG principle.guideline.criterion numbering — for example WCAG
/// SC 1.4.3 maps to clause 11.1.4.3. They are gathered here so the mapping is
/// reviewed and versioned in one place; the formal, version-switched packs
/// arrive with the standard-pack work (see roadmap M8).
abstract final class Criteria {
  /// WCAG 4.1.2 Name, Role, Value (Level A).
  static const Criterion nameRoleValue = Criterion(
    wcag: '4.1.2',
    wcagLevel: 'A',
    en301549: '11.4.1.2',
    title: 'Name, Role, Value',
  );

  /// WCAG 1.1.1 Non-text Content (Level A).
  static const Criterion nonTextContent = Criterion(
    wcag: '1.1.1',
    wcagLevel: 'A',
    en301549: '11.1.1.1',
    title: 'Non-text Content',
  );

  /// WCAG 2.4.6 Headings and Labels (Level AA).
  static const Criterion headingsAndLabels = Criterion(
    wcag: '2.4.6',
    wcagLevel: 'AA',
    en301549: '11.2.4.6',
    title: 'Headings and Labels',
  );

  /// WCAG 1.3.1 Info and Relationships (Level A).
  static const Criterion infoAndRelationships = Criterion(
    wcag: '1.3.1',
    wcagLevel: 'A',
    en301549: '11.1.3.1',
    title: 'Info and Relationships',
  );
}
