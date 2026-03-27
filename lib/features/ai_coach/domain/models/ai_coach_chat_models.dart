class AiCoachChatRequest {
  const AiCoachChatRequest({
    required this.userMessage,
    this.profile,
    this.goal,
    this.recentMeals,
    this.recentActivity,
  });

  final String userMessage;
  final AiCoachUserProfileContext? profile;
  final AiCoachGoalContext? goal;
  final List<AiCoachMealContextItem>? recentMeals;
  final List<AiCoachActivityContextItem>? recentActivity;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userMessage': userMessage,
      if (profile != null) 'profile': profile!.toJson(),
      if (goal != null) 'goal': goal!.toJson(),
      if (recentMeals != null)
        'recentMeals': recentMeals!.map((AiCoachMealContextItem item) => item.toJson()).toList(),
      if (recentActivity != null)
        'recentActivity': recentActivity!
            .map((AiCoachActivityContextItem item) => item.toJson())
            .toList(),
    };
  }
}

class AiCoachUserProfileContext {
  const AiCoachUserProfileContext({
    this.age,
    this.sex,
    this.heightCm,
    this.weightKg,
    this.dietaryPreferences,
    this.allergies,
    this.medicalNotes,
  });

  final int? age;
  final String? sex;
  final double? heightCm;
  final double? weightKg;
  final List<String>? dietaryPreferences;
  final List<String>? allergies;
  final List<String>? medicalNotes;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (age != null) 'age': age,
      if (sex != null) 'sex': sex,
      if (heightCm != null) 'heightCm': heightCm,
      if (weightKg != null) 'weightKg': weightKg,
      if (dietaryPreferences != null) 'dietaryPreferences': dietaryPreferences,
      if (allergies != null) 'allergies': allergies,
      if (medicalNotes != null) 'medicalNotes': medicalNotes,
    };
  }
}

class AiCoachGoalContext {
  const AiCoachGoalContext({required this.primaryGoal, this.targetDateIso, this.notes});

  final String primaryGoal;
  final String? targetDateIso;
  final String? notes;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'primaryGoal': primaryGoal,
      if (targetDateIso != null) 'targetDateIso': targetDateIso,
      if (notes != null) 'notes': notes,
    };
  }
}

class AiCoachMealContextItem {
  const AiCoachMealContextItem({
    required this.summary,
    this.eatenAtIso,
    this.estimatedCalories,
  });

  final String summary;
  final String? eatenAtIso;
  final int? estimatedCalories;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'summary': summary,
      if (eatenAtIso != null) 'eatenAtIso': eatenAtIso,
      if (estimatedCalories != null) 'estimatedCalories': estimatedCalories,
    };
  }
}

class AiCoachActivityContextItem {
  const AiCoachActivityContextItem({
    required this.summary,
    this.occurredAtIso,
    this.durationMinutes,
    this.intensity,
  });

  final String summary;
  final String? occurredAtIso;
  final int? durationMinutes;
  final String? intensity;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'summary': summary,
      if (occurredAtIso != null) 'occurredAtIso': occurredAtIso,
      if (durationMinutes != null) 'durationMinutes': durationMinutes,
      if (intensity != null) 'intensity': intensity,
    };
  }
}

class AiCoachChatResponse {
  const AiCoachChatResponse({
    required this.assistantMessage,
    required this.safety,
    required this.meta,
  });

  final String assistantMessage;
  final AiCoachSafetyMetadata safety;
  final AiCoachChatMeta meta;

  factory AiCoachChatResponse.fromJson(Map<String, dynamic> json) {
    return AiCoachChatResponse(
      assistantMessage: json['assistantMessage'] as String? ?? '',
      safety: AiCoachSafetyMetadata.fromJson(
        json['safety'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      meta: AiCoachChatMeta.fromJson(
        json['meta'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }
}

class AiCoachSafetyMetadata {
  const AiCoachSafetyMetadata({
    required this.containsSensitiveContent,
    required this.disclaimerShown,
    required this.escalationRecommended,
  });

  final bool containsSensitiveContent;
  final bool disclaimerShown;
  final bool escalationRecommended;

  factory AiCoachSafetyMetadata.fromJson(Map<String, dynamic> json) {
    return AiCoachSafetyMetadata(
      containsSensitiveContent: json['containsSensitiveContent'] as bool? ?? false,
      disclaimerShown: json['disclaimerShown'] as bool? ?? false,
      escalationRecommended: json['escalationRecommended'] as bool? ?? false,
    );
  }
}

class AiCoachChatMeta {
  const AiCoachChatMeta({
    required this.model,
    required this.provider,
    required this.requestId,
  });

  final String model;
  final String provider;
  final String requestId;

  factory AiCoachChatMeta.fromJson(Map<String, dynamic> json) {
    return AiCoachChatMeta(
      model: json['model'] as String? ?? 'unknown',
      provider: json['provider'] as String? ?? 'unknown',
      requestId: json['requestId'] as String? ?? '',
    );
  }
}
