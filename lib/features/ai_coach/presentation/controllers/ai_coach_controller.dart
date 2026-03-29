import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../auth/domain/session_state.dart';
import '../../../exercise/domain/entities/workout.dart';
import '../../../exercise/presentation/controllers/exercise_state.dart';
import '../../../nutrition/domain/entities/meal_entry.dart';
import '../../../nutrition/domain/enums/meal_type.dart';
import '../../../nutrition/presentation/controllers/nutrition_state.dart';
import '../../../profile/data/health_profile_repository.dart';
import '../../../profile/domain/models/health_profile_models.dart';
import '../../domain/models/ai_coach_chat_message.dart';
import '../../domain/models/ai_coach_chat_models.dart';
import '../../domain/repositories/ai_coach_repository.dart';
import 'ai_coach_state.dart';

class AiCoachController extends ChangeNotifier {
  AiCoachController({
    required AiCoachRepository repository,
    required HealthProfileRepository profileRepository,
    required NutritionState Function() getNutritionState,
    required ExerciseState Function() getExerciseState,
    required SessionState Function() getSessionState,
    required bool usesMockBackend,
  }) : _repository = repository,
       _profileRepository = profileRepository,
       _getNutritionState = getNutritionState,
       _getExerciseState = getExerciseState,
       _getSessionState = getSessionState,
       _state = AiCoachState.initial(usesMockBackend: usesMockBackend);

  final AiCoachRepository _repository;
  final HealthProfileRepository _profileRepository;
  final NutritionState Function() _getNutritionState;
  final ExerciseState Function() _getExerciseState;
  final SessionState Function() _getSessionState;
  final Uuid _uuid = const Uuid();

  AiCoachState _state;
  AiCoachState get state => _state;

  Future<void> sendMessage(String input) async {
    final String userInput = input.trim();
    if (userInput.isEmpty || _state.isSending) {
      return;
    }

    final AiCoachChatMessage userMessage = AiCoachChatMessage(
      id: _uuid.v4(),
      text: userInput,
      author: AiCoachMessageAuthor.user,
      createdAt: DateTime.now(),
    );

    _state = _state.copyWith(
      isSending: true,
      clearErrorMessage: true,
      clearLastFailedInput: true,
      messages: <AiCoachChatMessage>[..._state.messages, userMessage],
    );
    notifyListeners();

    await _send(userInput: userInput, appendSystemHint: true);
  }

  Future<void> retryLastMessage() async {
    final String? failedInput = _state.lastFailedInput;
    if (failedInput == null || _state.isSending) {
      return;
    }

    _state = _state.copyWith(
      isSending: true,
      clearErrorMessage: true,
      clearLastFailedInput: true,
    );
    notifyListeners();

    await _send(userInput: failedInput, appendSystemHint: false);
  }

  void dismissDisclaimer() {
    _state = _state.copyWith(disclaimerVisible: false);
    notifyListeners();
  }

  Future<void> _send({required String userInput, required bool appendSystemHint}) async {
    try {
      final AiCoachChatRequest request = await _buildRequest(userInput);
      final AiCoachChatResponse response = await _repository.sendMessage(request);

      final List<AiCoachChatMessage> nextMessages = <AiCoachChatMessage>[
        ..._state.messages,
        AiCoachChatMessage(
          id: _uuid.v4(),
          text: response.assistantMessage,
          author: AiCoachMessageAuthor.assistant,
          createdAt: DateTime.now(),
          isSensitive: response.safety.containsSensitiveContent,
          escalationRecommended: response.safety.escalationRecommended,
        ),
      ];

      if (appendSystemHint && response.safety.disclaimerShown) {
        nextMessages.add(
          AiCoachChatMessage(
            id: _uuid.v4(),
            text:
                'Recuerda: este coach ofrece orientación de bienestar general y no sustituye una evaluación médica profesional.',
            author: AiCoachMessageAuthor.system,
            createdAt: DateTime.now(),
          ),
        );
      }

      _state = _state.copyWith(
        isSending: false,
        clearErrorMessage: true,
        clearLastFailedInput: true,
        messages: nextMessages,
      );
      notifyListeners();
    } catch (error) {
      final String message = error is AppException
          ? error.message
          : 'No se pudo obtener respuesta del AI Coach. Revisa la conexión y reintenta.';

      _state = _state.copyWith(
        isSending: false,
        errorMessage: message,
        lastFailedInput: userInput,
      );
      notifyListeners();
    }
  }

  Future<AiCoachChatRequest> _buildRequest(String userInput) async {
    final WellnessProfile? profile = await _profileRepository.loadProfile();
    final NutritionState nutritionState = _getNutritionState();
    final ExerciseState exerciseState = _getExerciseState();
    final SessionState sessionState = _getSessionState();

    return AiCoachChatRequest(
      userMessage: userInput,
      profile: _buildProfileContext(profile),
      goal: _buildGoalContext(profile, sessionState),
      recentMeals: _buildMealContext(nutritionState.entries),
      recentActivity: _buildActivityContext(exerciseState.history),
    );
  }

  AiCoachUserProfileContext? _buildProfileContext(WellnessProfile? profile) {
    if (profile == null) {
      return null;
    }

    final List<String> restrictions = profile.nutritionPreferences.restrictions
        .map((DietaryRestriction restriction) => restriction.name)
        .toList();

    return AiCoachUserProfileContext(
      age: profile.userProfile.age,
      sex: profile.userProfile.sex.name,
      heightCm: profile.userProfile.heightCm,
      weightKg: profile.userProfile.weightKg,
      dietaryPreferences: <String>[profile.nutritionPreferences.dietaryPreference.name],
      allergies: restrictions,
      medicalNotes: const <String>[],
    );
  }

  AiCoachGoalContext _buildGoalContext(WellnessProfile? profile, SessionState sessionState) {
    final String primaryGoal = profile?.goals.primaryGoal.label ?? 'Mejora de hábitos sostenibles';

    final StringBuffer notes = StringBuffer();
    if (profile?.goals.targetWeightKg != null) {
      notes.write('Peso objetivo: ${profile!.goals.targetWeightKg} kg. ');
    }

    if (sessionState.userId != null) {
      notes.write('userId: ${sessionState.userId}.');
    }

    return AiCoachGoalContext(
      primaryGoal: primaryGoal,
      notes: notes.isEmpty ? null : notes.toString().trim(),
    );
  }

  List<AiCoachMealContextItem> _buildMealContext(List<MealEntry> entries) {
    final List<MealEntry> sortedEntries = <MealEntry>[...entries]
      ..sort((MealEntry a, MealEntry b) => b.date.compareTo(a.date));

    return sortedEntries.take(6).map((MealEntry entry) {
      final String foodSummary = entry.foodItems
          .map((food) => food.name)
          .take(3)
          .join(', ');

      final String summary =
          '${_mealTypeLabel(entry.mealType)}: ${foodSummary.isEmpty ? 'Registro sin detalle' : foodSummary}';

      return AiCoachMealContextItem(
        summary: summary,
        eatenAtIso: entry.date.toIso8601String(),
        estimatedCalories: entry.totalCalories.round(),
      );
    }).toList(growable: false);
  }

  List<AiCoachActivityContextItem> _buildActivityContext(List<Workout> workouts) {
    final List<Workout> sortedWorkouts = <Workout>[...workouts]
      ..sort((Workout a, Workout b) => b.date.compareTo(a.date));

    return sortedWorkouts.take(6).map((Workout workout) {
      return AiCoachActivityContextItem(
        summary: workout.title,
        occurredAtIso: workout.date.toIso8601String(),
        durationMinutes: workout.totalDuration.inMinutes,
        intensity: _resolveWorkoutIntensity(workout),
      );
    }).toList(growable: false);
  }

  String _resolveWorkoutIntensity(Workout workout) {
    final int activities = workout.activities.length;
    final int exercises = workout.exercises.length;

    if (workout.totalDuration.inMinutes >= 70 || exercises >= 6) {
      return 'high';
    }

    if (workout.totalDuration.inMinutes >= 35 || activities >= 2 || exercises >= 3) {
      return 'medium';
    }

    return 'low';
  }

  String _mealTypeLabel(MealType mealType) {
    return mealType.label;
  }
}
