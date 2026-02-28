import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// =============================================================================
// SubjectColor — predefined palette
// =============================================================================

/// A curated set of subject colours that look good on both light and dark
/// surfaces.  Stored in Firestore as the enum's [name] (e.g. `"indigo"`).
///
/// Each entry provides a [color] swatch and a human-readable [label].
enum SubjectColor {
  indigo(Color(0xFF4F46E5), 'Indigo'),
  blue(Color(0xFF2563EB), 'Blue'),
  cyan(Color(0xFF0891B2), 'Cyan'),
  teal(Color(0xFF0D9488), 'Teal'),
  green(Color(0xFF16A34A), 'Green'),
  amber(Color(0xFFD97706), 'Amber'),
  orange(Color(0xFFEA580C), 'Orange'),
  red(Color(0xFFDC2626), 'Red'),
  pink(Color(0xFFDB2777), 'Pink'),
  purple(Color(0xFF9333EA), 'Purple'),
  slate(Color(0xFF64748B), 'Slate');

  const SubjectColor(this.color, this.label);

  /// The actual [Color] value to render in the UI.
  final Color color;

  /// Human-readable name shown in the colour picker.
  final String label;

  /// Parses a Firestore string.  Falls back to [indigo] for unknown values.
  factory SubjectColor.fromString(String? value) {
    return SubjectColor.values.firstWhere(
      (c) => c.name == value,
      orElse: () => SubjectColor.indigo,
    );
  }
}

// =============================================================================
// Subject model
// =============================================================================

/// Mirrors a `subjects/{id}` Firestore document.
///
/// Each subject belongs to a single user ([ownerId]).  Security rules enforce
/// that only the owner can read / write their own subjects.
class Subject {
  const Subject({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String ownerId;
  final SubjectColor color;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ---------------------------------------------------------------------------
  // Firestore serialisation
  // ---------------------------------------------------------------------------

  /// Creates a [Subject] from a Firestore document snapshot.
  ///
  /// Uses null-aware defaults so partially-written documents don't crash.
  factory Subject.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final created =
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    return Subject(
      id: doc.id,
      name: data['name'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      color: SubjectColor.fromString(data['color'] as String?),
      createdAt: created,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? created,
    );
  }

  /// For creating / updating a document.  Does NOT include `id` — that's the
  /// document key, not a field.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'ownerId': ownerId,
      'color': color.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  /// Returns a copy with the given fields replaced.
  /// Automatically bumps [updatedAt] to now.
  Subject copyWith({String? name, SubjectColor? color}) {
    return Subject(
      id: id,
      name: name ?? this.name,
      ownerId: ownerId,
      color: color ?? this.color,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Subject &&
        other.id == id &&
        other.name == name &&
        other.ownerId == ownerId &&
        other.color == color;
  }

  @override
  int get hashCode => Object.hash(id, name, ownerId, color);
}
