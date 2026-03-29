import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nutri_fit/app/router/app_router.dart';
import 'package:nutri_fit/core/utils/date_time_utils.dart';
import 'package:nutri_fit/features/exercise/domain/entities/workout.dart';
import 'package:nutri_fit/features/exercise/domain/repositories/exercise_repository.dart';
import 'package:nutri_fit/features/exercise/presentation/controllers/exercise_providers.dart';
import 'package:nutri_fit/features/exercise/presentation/pages/exercise_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets('ExercisePage avoids overflow on narrow screens', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _buildTestApp(
        repository: _FakeExerciseRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Agregar entrenamiento'), findsOneWidget);
    expect(find.text('Ver historial'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Exercise flow supports validation, add, history, detail, and delete',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          repository: _FakeExerciseRepository(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Aún no registras entrenamientos para hoy.'), findsOneWidget);

      await tester.tap(find.text('Ver historial'));
      await tester.pumpAndSettle();

      expect(find.text('Todavía no hay entrenamientos registrados.'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Agregar entrenamiento'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Guardar entrenamiento'));
      await tester.pump();

      expect(find.text('Completa nombre y duración válida.'), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(0), 'Circuito total');
      await tester.enterText(find.byType(TextField).at(1), '45');
      await tester.enterText(find.byType(TextField).at(2), 'Sesión de QA');

      await tester.tap(find.text('Guardar entrenamiento'));
      await tester.pumpAndSettle();

      expect(find.text('Circuito total'), findsOneWidget);
      expect(find.text('Entrenamientos: 1'), findsOneWidget);

      await tester.tap(find.text('Ver historial'));
      await tester.pumpAndSettle();

      expect(find.text('Circuito total'), findsOneWidget);

      await tester.tap(find.text('Circuito total'));
      await tester.pumpAndSettle();

      expect(find.text('Detalle de entrenamiento'), findsOneWidget);
      expect(find.textContaining('Duración total: 56 min'), findsOneWidget);
      expect(find.text('Notas: Sesión de QA'), findsOneWidget);
      expect(find.text('Actividad complementaria'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      final Finder workoutTile = find.widgetWithText(ListTile, 'Circuito total');
      final Finder deleteButton = find.descendant(
        of: workoutTile,
        matching: find.widgetWithIcon(IconButton, Icons.delete_outline),
      );

      await tester.ensureVisible(workoutTile);
      final IconButton deleteIconButton = tester.widget<IconButton>(deleteButton);
      expect(deleteIconButton.onPressed, isNotNull);
      deleteIconButton.onPressed!();
      await tester.pumpAndSettle();

      expect(find.text('Aún no registras entrenamientos para hoy.'), findsOneWidget);

      await tester.tap(find.text('Ver historial'));
      await tester.pumpAndSettle();

      expect(find.text('Todavía no hay entrenamientos registrados.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _buildTestApp({required ExerciseRepository repository}) {
  return ProviderScope(
    overrides: <Override>[
      exerciseRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: AppRoutePaths.exercise,
        routes: <GoRoute>[
          GoRoute(
            path: AppRoutePaths.home,
            builder: (BuildContext context, GoRouterState state) => const _PlaceholderPage(),
          ),
          GoRoute(
            path: AppRoutePaths.nutrition,
            builder: (BuildContext context, GoRouterState state) => const _PlaceholderPage(),
          ),
          GoRoute(
            path: AppRoutePaths.exercise,
            builder: (BuildContext context, GoRouterState state) => const ExercisePage(),
          ),
          GoRoute(
            path: AppRoutePaths.progress,
            builder: (BuildContext context, GoRouterState state) => const _PlaceholderPage(),
          ),
          GoRoute(
            path: AppRoutePaths.aiCoach,
            builder: (BuildContext context, GoRouterState state) => const _PlaceholderPage(),
          ),
          GoRoute(
            path: AppRoutePaths.profile,
            builder: (BuildContext context, GoRouterState state) => const _PlaceholderPage(),
          ),
          GoRoute(
            path: AppRoutePaths.settings,
            builder: (BuildContext context, GoRouterState state) => const _PlaceholderPage(),
          ),
        ],
      ),
    ),
  );
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}

class _FakeExerciseRepository implements ExerciseRepository {
  _FakeExerciseRepository({List<Workout>? initialWorkouts})
      : _workouts = <Workout>[...?initialWorkouts];

  List<Workout> _workouts;

  @override
  Future<void> deleteWorkout(String workoutId) async {
    _workouts = _workouts.where((Workout workout) => workout.id != workoutId).toList();
  }

  @override
  Future<DailyActivitySummary> getDailySummary({
    required DateTime date,
    required double weightKg,
  }) async {
    final List<Workout> workouts = await getWorkoutsForDate(date);
    final int totalMinutes = workouts.fold<int>(
      0,
      (int total, Workout workout) => total + workout.totalDuration.inMinutes,
    );
    final double calories = workouts.fold<double>(
      0,
      (double total, Workout workout) => total + workout.estimatedCalories(weightKg: weightKg),
    );

    return DailyActivitySummary(
      date: DateTimeUtils.normalizeDate(date),
      totalMinutes: totalMinutes,
      estimatedCalories: calories,
      workoutCount: workouts.length,
    );
  }

  @override
  Future<List<Workout>> getRecentWorkouts({int limit = 20}) async {
    final List<Workout> sorted = <Workout>[..._workouts]
      ..sort((Workout a, Workout b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }

  @override
  Future<List<Workout>> getWorkoutsForDate(DateTime date) async {
    final DateTime normalizedDate = DateTimeUtils.normalizeDate(date);
    final List<Workout> entries = _workouts
        .where((Workout workout) => DateTimeUtils.normalizeDate(workout.date) == normalizedDate)
        .toList()
      ..sort((Workout a, Workout b) => b.totalDuration.inMinutes.compareTo(a.totalDuration.inMinutes));
    return entries;
  }

  @override
  Future<void> saveWorkout(Workout workout) async {
    final int existingIndex = _workouts.indexWhere((Workout existing) => existing.id == workout.id);
    if (existingIndex == -1) {
      _workouts = <Workout>[..._workouts, workout];
      return;
    }

    _workouts = <Workout>[
      for (int index = 0; index < _workouts.length; index += 1)
        if (index == existingIndex) workout else _workouts[index],
    ];
  }
}
