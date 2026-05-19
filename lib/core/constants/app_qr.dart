/// QR code format constants for Grow~.
///
/// All QR generation and parsing MUST use these helpers.
/// Format: `{prefix}{uuid}`
class AppQr {
  AppQr._();

  static const userPrefix = 'GROWLAB-USER-';
  static const toolPrefix = 'GROWLAB-TOOL-';

  /// Generate a user QR code string.
  static String generateUserQr(String userId) => '$userPrefix$userId';

  /// Generate a tool QR code string.
  static String generateToolQr(String toolId) => '$toolPrefix$toolId';

  /// Returns `true` if the raw value is a valid user QR.
  static bool isUserQr(String raw) => raw.startsWith(userPrefix);

  /// Returns `true` if the raw value is a valid tool QR.
  static bool isToolQr(String raw) => raw.startsWith(toolPrefix);

  /// Extract the user ID from a user QR string.
  /// Returns `null` if the format is invalid.
  static String? parseUserId(String raw) {
    if (!isUserQr(raw)) return null;
    final id = raw.substring(userPrefix.length);
    return id.isEmpty ? null : id;
  }

  /// Extract the tool ID from a tool QR string.
  /// Returns `null` if the format is invalid.
  static String? parseToolId(String raw) {
    if (!isToolQr(raw)) return null;
    final id = raw.substring(toolPrefix.length);
    return id.isEmpty ? null : id;
  }
}
