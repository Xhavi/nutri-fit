class TranscriptionResult {
  const TranscriptionResult({
    required this.text,
    this.languageCode,
    this.confidence,
    this.isPartial = false,
    this.raw,
  });

  final String text;
  final String? languageCode;
  final double? confidence;
  final bool isPartial;
  final Map<String, dynamic>? raw;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'text': text,
      if (languageCode != null) 'languageCode': languageCode,
      if (confidence != null) 'confidence': confidence,
      'isPartial': isPartial,
      if (raw != null) 'raw': raw,
    };
  }

  factory TranscriptionResult.fromJson(Map<String, dynamic> json) {
    return TranscriptionResult(
      text: json['text'] as String? ?? '',
      languageCode: json['languageCode'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      isPartial: json['isPartial'] as bool? ?? false,
      raw: json['raw'] as Map<String, dynamic>?,
    );
  }
}
