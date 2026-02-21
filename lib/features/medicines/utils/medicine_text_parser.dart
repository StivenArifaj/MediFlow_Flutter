/// Parses raw OCR text from a medicine box into structured fields.
class MedicineTextParser {
  MedicineTextParser._();

  static Map<String, String?> parse(String rawText) {
    final lines = rawText.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    return {
      'verifiedName': _parseName(lines, rawText),
      'strength': _parseStrength(rawText),
      'form': _parseForm(rawText),
      'manufacturer': _parseManufacturer(rawText),
      'expiryDate': _parseExpiry(rawText),
      'quantity': _parseQuantity(rawText),
    };
  }

  /// Name: first long/prominent line (typically top of box)
  static String? _parseName(List<String> lines, String raw) {
    // Skip very short lines and likely noise
    for (final line in lines) {
      if (line.length >= 3 && !_looksLikeNoise(line)) {
        return _capitalize(line);
      }
    }
    return null;
  }

  static bool _looksLikeNoise(String s) {
    // Only numbers, only symbols, etc.
    return RegExp(r'^[\d\W]+$').hasMatch(s);
  }

  /// Strength: e.g. 500mg, 10ml, 1g, 250mcg
  static String? _parseStrength(String raw) {
    final match = RegExp(
      r'(\d+(?:\.\d+)?)\s*(mg|mcg|g|ml|%|IU|mmol)',
      caseSensitive: false,
    ).firstMatch(raw);
    if (match == null) return null;
    return '${match.group(1)}${match.group(2)!.toLowerCase()}';
  }

  /// Form: tablet, capsule, syrup, etc.
  static String? _parseForm(String raw) {
    final forms = [
      'tablet', 'capsule', 'liquid', 'syrup', 'drops', 'injection',
      'cream', 'ointment', 'inhaler', 'patch', 'spray', 'gel', 'powder',
    ];
    final lower = raw.toLowerCase();
    for (final form in forms) {
      if (lower.contains(form)) {
        return form[0].toUpperCase() + form.substring(1);
      }
    }
    return null;
  }

  /// Manufacturer: after keywords like "manufactured by", "product of"
  static String? _parseManufacturer(String raw) {
    final match = RegExp(
      r'(?:manufactured by|product of|marketed by|distributed by)[:\s]+(.+)',
      caseSensitive: false,
    ).firstMatch(raw);
    if (match != null) {
      return match.group(1)?.trim().split('\n').first.trim();
    }
    return null;
  }

  /// Expiry: EXP, Exp, Best Before + date patterns
  static String? _parseExpiry(String raw) {
    final match = RegExp(
      r'(?:EXP|Exp\.?|Expiry|Best Before|Use Before)[:\s]+'
      r'(\d{1,2}[\/\-\.]\d{1,2}[\/\-\.]\d{2,4}|\d{4}[\/\-]\d{2})',
      caseSensitive: false,
    ).firstMatch(raw);
    return match?.group(1)?.trim();
  }

  /// Quantity: e.g. "10 tablets", "30 capsules"
  static String? _parseQuantity(String raw) {
    final match = RegExp(
      r'(\d+)\s*(?:tablets?|capsules?|vials?|ampoules?|sachets?)',
      caseSensitive: false,
    ).firstMatch(raw);
    return match?.group(1)?.trim();
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
}
