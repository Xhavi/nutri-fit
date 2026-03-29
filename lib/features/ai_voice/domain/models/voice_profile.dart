class VoiceProfile {
  const VoiceProfile({
    required this.id,
    required this.label,
    required this.locale,
    this.description,
    this.styleInstructions,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String locale;
  final String? description;
  final String? styleInstructions;
  final bool isDefault;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'locale': locale,
      if (description != null) 'description': description,
      if (styleInstructions != null) 'styleInstructions': styleInstructions,
      'isDefault': isDefault,
    };
  }

  factory VoiceProfile.fromJson(Map<String, dynamic> json) {
    return VoiceProfile(
      id: json['id'] as String? ?? 'default',
      label: json['label'] as String? ?? 'Default',
      locale: json['locale'] as String? ?? 'es-ES',
      description: json['description'] as String?,
      styleInstructions: json['styleInstructions'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}
