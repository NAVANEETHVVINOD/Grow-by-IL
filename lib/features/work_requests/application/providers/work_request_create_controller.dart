import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/work_request_draft.dart';
import '../../services/draft_storage/work_request_draft_storage.dart';
import '../../services/work_request_data_source.dart';
import '../../utils/work_request_validators.dart';

enum WorkRequestCreateStep {
  category,
  basics,
  fabrication,
  members,
  designMaterial,
  review,
  confirmation,
}

extension WorkRequestCreateStepLabel on WorkRequestCreateStep {
  String get label {
    return switch (this) {
      WorkRequestCreateStep.category => 'Category',
      WorkRequestCreateStep.basics => 'Basics',
      WorkRequestCreateStep.fabrication => 'Fabrication',
      WorkRequestCreateStep.members => 'Members',
      WorkRequestCreateStep.designMaterial => 'Design',
      WorkRequestCreateStep.review => 'Review',
      WorkRequestCreateStep.confirmation => 'Done',
    };
  }
}

class WorkRequestCreateState {
  const WorkRequestCreateState({
    this.draft = const WorkRequestDraft(),
    this.currentStep = WorkRequestCreateStep.category,
    this.isRestoring = true,
    this.isSaving = false,
    this.isSubmitted = false,
    this.lastError,
    this.validationErrors = const <String>[],
  });

  final WorkRequestDraft draft;
  final WorkRequestCreateStep currentStep;
  final bool isRestoring;
  final bool isSaving;
  final bool isSubmitted;
  final String? lastError;
  final List<String> validationErrors;

  int get currentStepIndex => WorkRequestCreateStep.values.indexOf(currentStep);
  int get totalSteps => WorkRequestCreateStep.values.length;
  double get progress => (currentStepIndex + 1) / totalSteps;

  bool get canGoBack => currentStepIndex > 0;
  bool get isLastInputStep => currentStep == WorkRequestCreateStep.review;

  WorkRequestCreateState copyWith({
    WorkRequestDraft? draft,
    WorkRequestCreateStep? currentStep,
    bool? isRestoring,
    bool? isSaving,
    bool? isSubmitted,
    String? lastError,
    bool clearLastError = false,
    List<String>? validationErrors,
  }) {
    return WorkRequestCreateState(
      draft: draft ?? this.draft,
      currentStep: currentStep ?? this.currentStep,
      isRestoring: isRestoring ?? this.isRestoring,
      isSaving: isSaving ?? this.isSaving,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      lastError: clearLastError ? null : lastError ?? this.lastError,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }
}

final workRequestDraftStorageProvider =
    Provider<WorkRequestDraftStorage>((ref) => const WorkRequestDraftStorage());

final workRequestCreateControllerProvider = StateNotifierProvider.autoDispose<
    WorkRequestCreateController, WorkRequestCreateState>((ref) {
  final controller = WorkRequestCreateController(
    storage: ref.watch(workRequestDraftStorageProvider),
    dataSource: ref.watch(workRequestDataSourceProvider),
  );
  controller.restoreDraft();
  return controller;
});

class WorkRequestCreateController
    extends StateNotifier<WorkRequestCreateState> {
  WorkRequestCreateController({
    required WorkRequestDraftStorage storage,
    required WorkRequestDataSource dataSource,
  })  : _storage = storage,
        _dataSource = dataSource,
        super(const WorkRequestCreateState());

  final WorkRequestDraftStorage _storage;
  final WorkRequestDataSource _dataSource;
  Timer? _debounceTimer;

  @override
  void dispose() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
      // Trigger a final save on dispose to avoid losing in-progress input.
      _storage.saveDraft(state.draft);
    }
    super.dispose();
  }

  Future<void> restoreDraft() async {
    final restored = await _storage.loadDraft();
    if (!mounted) return;
    state = state.copyWith(
      draft: restored ?? const WorkRequestDraft(),
      isRestoring: false,
      clearLastError: true,
    );
  }

  Future<void> updateDraft(WorkRequestDraft draft) async {
    state = state.copyWith(
      draft: draft,
      validationErrors: const <String>[],
      clearLastError: true,
    );

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _saveDraft(state.draft);
    });
  }

  Future<void> clearDraft() async {
    _debounceTimer?.cancel();
    await _storage.clearDraft();
    if (!mounted) return;
    state = state.copyWith(
      draft: const WorkRequestDraft(),
      currentStep: WorkRequestCreateStep.category,
      isSubmitted: false,
      validationErrors: const <String>[],
      clearLastError: true,
    );
  }

  Future<bool> nextStep() async {
    final errors = validateCurrentStep();
    if (errors.isNotEmpty) {
      state = state.copyWith(validationErrors: errors);
      return false;
    }

    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
      await _saveDraft(state.draft);
    }

    final nextIndex = state.currentStepIndex + 1;
    if (nextIndex >= WorkRequestCreateStep.values.length) return true;

    state = state.copyWith(
      currentStep: WorkRequestCreateStep.values[nextIndex],
      validationErrors: const <String>[],
      clearLastError: true,
    );
    await _saveDraft(state.draft);
    return true;
  }

  void previousStep() {
    if (!state.canGoBack) return;
    final previousIndex = state.currentStepIndex - 1;
    state = state.copyWith(
      currentStep: WorkRequestCreateStep.values[previousIndex],
      validationErrors: const <String>[],
      clearLastError: true,
    );
  }

  void goToStep(WorkRequestCreateStep step) {
    if (WorkRequestCreateStep.values.indexOf(step) > state.currentStepIndex) {
      return;
    }
    state = state.copyWith(
      currentStep: step,
      validationErrors: const <String>[],
      clearLastError: true,
    );
  }

  Future<bool> submitMockRequest() async {
    final errors = WorkRequestValidators.validateFinal(state.draft);
    if (errors.isNotEmpty) {
      state = state.copyWith(validationErrors: errors);
      return false;
    }

    _debounceTimer?.cancel();
    state = state.copyWith(isSaving: true);
    await _dataSource.submit(state.draft);
    await _storage.clearDraft();
    if (!mounted) return false;
    state = state.copyWith(
      isSaving: false,
      isSubmitted: true,
      currentStep: WorkRequestCreateStep.confirmation,
      validationErrors: const <String>[],
      clearLastError: true,
    );
    return true;
  }

  List<String> validateCurrentStep() {
    return switch (state.currentStep) {
      WorkRequestCreateStep.category =>
        WorkRequestValidators.validateFabrication(state.draft),
      WorkRequestCreateStep.basics =>
        WorkRequestValidators.validateBasics(state.draft),
      WorkRequestCreateStep.fabrication =>
        WorkRequestValidators.validateFabrication(state.draft),
      WorkRequestCreateStep.members => const <String>[],
      WorkRequestCreateStep.designMaterial =>
        WorkRequestValidators.validateDesignAndMaterial(state.draft),
      WorkRequestCreateStep.review =>
        WorkRequestValidators.validateFinal(state.draft),
      WorkRequestCreateStep.confirmation => const <String>[],
    };
  }

  Future<void> _saveDraft(WorkRequestDraft draft) async {
    if (!draft.hasAnyInput) return;
    state = state.copyWith(isSaving: true);
    try {
      await _storage.saveDraft(draft);
      if (!mounted) return;
      state = state.copyWith(isSaving: false, clearLastError: true);
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(
        isSaving: false,
        lastError: 'Could not save local draft.',
      );
    }
  }
}
