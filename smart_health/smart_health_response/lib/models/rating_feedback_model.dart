class RatingCategory {
  final String categoryName;
  final int categoryScore;

  const RatingCategory({required this.categoryName, required this.categoryScore});

  factory RatingCategory.fromJson(Map<String, dynamic> json) => RatingCategory(
        categoryName: json['categoryName'] as String? ?? '',
        categoryScore: json['categoryScore'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'categoryName': categoryName,
        'categoryScore': categoryScore,
      };

  @override
  String toString() => 'RatingCategory($categoryName: $categoryScore)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RatingCategory &&
          other.categoryName == categoryName &&
          other.categoryScore == categoryScore);

  @override
  int get hashCode => Object.hash(categoryName, categoryScore);
}

class RatingFeedback {
  final String ratingId;
  final String caseId;
  final String responderId;
  final String raterId;
  final int ratingScore;
  final String feedbackText;
  final List<RatingCategory> categories;
  final DateTime ratedAt;

  const RatingFeedback({
    required this.ratingId,
    required this.caseId,
    required this.responderId,
    required this.raterId,
    required this.ratingScore,
    this.feedbackText = '',
    this.categories = const [],
    required this.ratedAt,
  });

  factory RatingFeedback.fromJson(Map<String, dynamic> json) => RatingFeedback(
        ratingId: json['ratingId'] as String? ?? '',
        caseId: json['caseId'] as String? ?? '',
        responderId: json['responderId'] as String? ?? '',
        raterId: json['raterId'] as String? ?? '',
        ratingScore: json['ratingScore'] as int? ?? 0,
        feedbackText: json['feedbackText'] as String? ?? '',
        categories: (json['categories'] as List? ?? [])
            .map((e) => RatingCategory.fromJson(e as Map<String, dynamic>))
            .toList(),
        ratedAt: DateTime.tryParse(json['ratedAt'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'ratingId': ratingId,
        'caseId': caseId,
        'responderId': responderId,
        'raterId': raterId,
        'ratingScore': ratingScore,
        'feedbackText': feedbackText,
        'categories': categories.map((e) => e.toJson()).toList(),
        'ratedAt': ratedAt.toIso8601String(),
      };

  RatingFeedback copyWith({
    String? ratingId,
    String? caseId,
    String? responderId,
    String? raterId,
    int? ratingScore,
    String? feedbackText,
    List<RatingCategory>? categories,
    DateTime? ratedAt,
  }) =>
      RatingFeedback(
        ratingId: ratingId ?? this.ratingId,
        caseId: caseId ?? this.caseId,
        responderId: responderId ?? this.responderId,
        raterId: raterId ?? this.raterId,
        ratingScore: ratingScore ?? this.ratingScore,
        feedbackText: feedbackText ?? this.feedbackText,
        categories: categories ?? this.categories,
        ratedAt: ratedAt ?? this.ratedAt,
      );

  @override
  String toString() => 'RatingFeedback($ratingId, score: $ratingScore)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is RatingFeedback && other.ratingId == ratingId);

  @override
  int get hashCode => ratingId.hashCode;
}
