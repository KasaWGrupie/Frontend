import 'dart:io';

enum GroupStatus {
  active,
  closing,
  closed,
}

enum CurrencyEnum {
  pln,
  gbp,
  eur,
  usd,
}

class NewGroup {
  late String name;
  late String? description;
  late final CurrencyEnum currency;
  late List<int> membersId;
  late final String adminEmail;
  late final File? picture;

  NewGroup({
    required this.name,
    this.description,
    required this.currency,
    required this.membersId,
    this.picture,
    required this.adminEmail,
  });
}

class Group {
  late final int id;
  late String name;
  late String? description;
  late final CurrencyEnum currency;
  late GroupStatus status;
  late final int adminId;
  late List<int> membersId;
  late final String invitationCode;

  Group({
    required this.id,
    required this.name,
    this.description,
    required this.currency,
    required this.status,
    required this.adminId,
    required this.membersId,
    required this.invitationCode,
  });

  Group.fromJson(Map<String, dynamic> json) {
    id = json['id']! as int;
    name = json['name']! as String;
    currency = CurrencyEnum.values.firstWhere(
      (e) => e.name == json['currency'],
      orElse: () => CurrencyEnum.eur,
    );
    // Maybe adding new enum for errors would be beneficial but it isn't
    // specified in documentation
    status = GroupStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => GroupStatus.active,
    );
    adminId = json['adminId']! as int;
    membersId = List<int>.from(json['membersId'] as List);
    invitationCode = json['invitationCode']! as String;
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'name': name,
      'currency': currency.name,
      'status': status.name,
      'adminId': adminId,
      'membersId': membersId,
      'invitationCode': invitationCode,
    };
  }

  Group copyWith({
    String? name,
    String? description,
    List<int>? membersId,
    GroupStatus? status,
  }) {
    return Group(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      currency: currency,
      status: status ?? this.status,
      adminId: adminId,
      membersId: membersId ?? this.membersId,
      invitationCode: invitationCode,
    );
  }
}
