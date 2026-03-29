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

  static const String defaultId = 'coach_default';

  static List<VoiceProfile> presets() {
    return const <VoiceProfile>[
      VoiceProfile(
        id: 'warm',
        label: 'Cálida',
        locale: 'es-ES',
        description: 'Cercana, empática y conversacional.',
        styleInstructions:
            'Responde con una voz cálida, amable y cercana. Mantén claridad, ritmo natural y apoyo emocional.',
        isDefault: true,
      ),
      VoiceProfile(
        id: 'energetic',
        label: 'Energética',
        locale: 'es-ES',
        description: 'Activa, motivante y con mayor dinamismo.',
        styleInstructions:
            'Responde con energía positiva, tono motivador y frases breves de impulso, sin sonar agresivo.',
      ),
      VoiceProfile(
        id: 'calm',
        label: 'Calmada',
        locale: 'es-ES',
        description: 'Serena, pausada y tranquilizadora.',
        styleInstructions:
            'Responde en tono sereno y pausado, con lenguaje simple, respirable y orientado a reducir estrés.',
      ),
      VoiceProfile(
        id: 'professional',
        label: 'Profesional',
        locale: 'es-ES',
        description: 'Directa, estructurada y formal.',
        styleInstructions:
            'Responde con tono profesional, claro y estructurado, priorizando precisión y acciones concretas.',
      ),
    ];
  }

  static VoiceProfile fallback() {
    return presets().firstWhere(
      (VoiceProfile profile) => profile.isDefault,
      orElse: () => presets().first,
    );
  }
}
