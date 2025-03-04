import 'package:matrix/matrix.dart';

extension LegacyIdpExtension on LoginFlow {
  List<LegacyIdp> get legacyIdps {
    final props = additionalProperties['identity_providers'];
    if (props is! List) {
      return const [];
    }
    return props.map((idp) => LegacyIdp.fromJson(idp)).toList();
  }
}

class LegacyIdp {
  const LegacyIdp({
    required this.id,
    required this.name,
    this.icon,
    this.brand,
  });

  factory LegacyIdp.fromJson(Map<String, Object?> json) => LegacyIdp(
        id: json['id']! as String,
        name: json['name']! as String,
        icon: json.containsKey('icon')
            ? Uri.tryParse(json['icon']! as String)
            : null,
        brand: json['brand'] as String?,
      );

  final String id;
  final String name;
  final Uri? icon;
  final String? brand;
}
