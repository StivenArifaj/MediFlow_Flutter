import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenFDAService {
  static const _base = 'https://api.fda.gov/drug/label.json';

  static Future<Map<String, dynamic>?> lookupBarcode(String barcode) async {
    final searches = [
      '$_base?search=openfda.upc_ndc:"$barcode"&limit=1',
      '$_base?search=openfda.package_ndc:"$barcode"&limit=1',
      '$_base?search=openfda.product_ndc:"$barcode"&limit=1',
      '$_base?search="$barcode"&limit=1',
    ];

    for (final url in searches) {
      try {
        final res = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 5));
        if (res.statusCode != 200) continue;

        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final results = json['results'] as List?;
        if (results == null || results.isEmpty) continue;

        final result = results[0] as Map<String, dynamic>;
        final openfda = result['openfda'] as Map<String, dynamic>? ?? {};

        final brandName = (openfda['brand_name'] as List?)?.first as String?;
        final genericName = (openfda['generic_name'] as List?)?.first as String?;
        final manufacturer = (openfda['manufacturer_name'] as List?)?.first as String?;
        final rawForm = (openfda['dosage_form'] as List?)?.first as String? ?? '';

        final activeIngredient = result['active_ingredient'] as List?;
        final ingredientText =
            activeIngredient?.isNotEmpty == true ? activeIngredient!.first as String : '';

        final strengthMatch = RegExp(
          r'(\d+(?:\.\d+)?)\s*(mg|g|ml|mcg|IU|%)',
          caseSensitive: false,
        ).firstMatch(ingredientText);

        final strength = strengthMatch != null
            ? '${strengthMatch.group(1)}${strengthMatch.group(2)?.toLowerCase()}'
            : null;

        final form = _mapForm(rawForm);
        final name = genericName ?? brandName;
        if (name == null) continue;

        return {
          'name': name,
          'brandName': brandName,
          'genericName': genericName,
          'manufacturer': manufacturer,
          'strength': strength,
          'form': form,
        };
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  static String _mapForm(String raw) {
    final f = raw.toLowerCase();
    if (f.contains('tablet')) return 'tablet';
    if (f.contains('capsule')) return 'capsule';
    if (f.contains('liquid') || f.contains('solution') || f.contains('syrup') || f.contains('suspension')) return 'liquid';
    if (f.contains('injection') || f.contains('injectable')) return 'injection';
    if (f.contains('cream') || f.contains('ointment') || f.contains('gel')) return 'cream';
    if (f.contains('drop')) return 'drops';
    if (f.contains('inhaler') || f.contains('aerosol')) return 'inhaler';
    if (f.contains('patch') || f.contains('transdermal')) return 'patch';
    if (f.contains('spray')) return 'spray';
    return 'other';
  }
}
