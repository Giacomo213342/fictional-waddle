import 'package:matrix/matrix.dart';

class Msc3231AuthenticationRegistrationToken extends AuthenticationData {
  Msc3231AuthenticationRegistrationToken({
    super.session,
    required this.token,
    this.txnId,
  }) : super(
          type: Msc3231AuthenticationRegistrationToken.authType,
        );

  Msc3231AuthenticationRegistrationToken.fromJson(super.json)
      : token = json['token']! as String,
        txnId = json['txn_id'] as String?,
        super.fromJson();

  static const authType = 'org.matrix.msc3231.login.registration_token';

  String token;

  /// removed in the unstable version of the spec
  String? txnId;

  @override
  Map<String, Object?> toJson() {
    final data = super.toJson();
    data['token'] = token;
    data['txn_id'] = txnId;
    return data;
  }
}
