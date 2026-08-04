import '../models/work_request_draft.dart';

class WorkRequestValidators {
  WorkRequestValidators._();

  static const minDescriptionLength = 20;
  static const maxDescriptionLength = 2000;

  static String? title(String value) {
    return value.trim().isEmpty ? 'Add a short request title.' : null;
  }

  static String? purpose(String value) {
    return value.trim().isEmpty ? 'Tell us why this work is needed.' : null;
  }

  static String? description(String value) {
    final trimmed = value.trim();
    if (trimmed.length < minDescriptionLength) {
      return 'Description must be at least 20 characters.';
    }
    if (trimmed.length > maxDescriptionLength) {
      return 'Description should stay under 2000 characters.';
    }
    return null;
  }

  static String? quantity(int value) {
    return value < 1 ? 'Quantity must be at least 1.' : null;
  }

  static String? subcategories(List<String> value) {
    return value.isEmpty ? 'Choose at least one fabrication type.' : null;
  }

  static String? preferredCompletionDate(DateTime? value) {
    if (value == null) return null;
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final selectedOnly = DateTime(value.year, value.month, value.day);
    return selectedOnly.isBefore(todayOnly)
        ? 'Preferred date cannot be in the past.'
        : null;
  }

  static String? externalLink(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final uri = Uri.tryParse(trimmed);
    final hasValidScheme = uri?.scheme == 'https' || uri?.scheme == 'http';
    if (uri == null || !hasValidScheme || uri.host.isEmpty) {
      return 'Use a valid http or https link.';
    }
    return null;
  }

  static String? externalLinks(List<String> values) {
    for (final value in values) {
      final error = externalLink(value);
      if (error != null) return error;
    }
    return null;
  }

  static String? materialNotes(WorkRequestDraft draft) {
    if (!draft.needsMaterialProcurement) return null;
    return draft.materialNotes.trim().isEmpty
        ? 'Add material notes or requirements.'
        : null;
  }

  static String? acknowledgements(WorkRequestDraft draft) {
    if (!draft.safetyAcknowledged) {
      return 'Accept the safety and community acknowledgement.';
    }
    if (!draft.editApprovalAcknowledged) {
      return 'Accept the core-team edit acknowledgement.';
    }
    if (!draft.reviewSummaryConfirmed) {
      return 'Confirm the review summary before submitting.';
    }
    return null;
  }

  static List<String> validateBasics(WorkRequestDraft draft) {
    return [
      title(draft.title),
      purpose(draft.purpose),
      description(draft.description),
      quantity(draft.quantity),
    ].whereType<String>().toList(growable: false);
  }

  static List<String> validateFabrication(WorkRequestDraft draft) {
    return [
      subcategories(draft.subcategoryIds),
      preferredCompletionDate(draft.preferredCompletionDate),
      externalLinks(draft.externalLinks),
    ].whereType<String>().toList(growable: false);
  }

  static List<String> validateDesignAndMaterial(WorkRequestDraft draft) {
    return [materialNotes(draft)].whereType<String>().toList(growable: false);
  }

  static List<String> validateFinal(WorkRequestDraft draft) {
    return [
      ...validateBasics(draft),
      ...validateFabrication(draft),
      ...validateDesignAndMaterial(draft),
      acknowledgements(draft),
    ].whereType<String>().toList(growable: false);
  }
}
