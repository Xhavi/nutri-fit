class OnboardingProfile {
  const OnboardingProfile({
    required this.name,
    required this.age,
    required this.sex,
    required this.weightKg,
    required this.heightCm,
    required this.primaryGoal,
    required this.activityLevel,
    required this.foodRestrictions,
  });

  final String name;
  final int age;
  final String sex;
  final double weightKg;
  final double heightCm;
  final String primaryGoal;
  final String activityLevel;
  final String foodRestrictions;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'age': age,
    'sex': sex,
    'weightKg': weightKg,
    'heightCm': heightCm,
    'primaryGoal': primaryGoal,
    'activityLevel': activityLevel,
    'foodRestrictions': foodRestrictions,
  };

  factory OnboardingProfile.fromJson(Map<String, dynamic> json) {
    return OnboardingProfile(
      name: json['name'] as String? ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      sex: json['sex'] as String? ?? '',
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0,
      heightCm: (json['heightCm'] as num?)?.toDouble() ?? 0,
      primaryGoal: json['primaryGoal'] as String? ?? '',
      activityLevel: json['activityLevel'] as String? ?? '',
      foodRestrictions: json['foodRestrictions'] as String? ?? '',
    );
  }
}
