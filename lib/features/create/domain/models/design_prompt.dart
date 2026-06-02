class DesignPrompt {
  final String id;
  final String rawInput;
  final String refinedPrompt;
  final String primaryIntent;
  final String subIntent;
  final double confidence;
  final InputMode inputMode;
  final DateTime createdAt;

  const DesignPrompt({
    required this.id,
    required this.rawInput,
    required this.refinedPrompt,
    required this.primaryIntent,
    required this.subIntent,
    required this.confidence,
    required this.inputMode,
    required this.createdAt,
  });
}

enum InputMode { text, voice, image, ar }
