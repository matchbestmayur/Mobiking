class AddressModel {
  final String fullName;
  final String phoneNumber;
  final String street;
  final String city;
  final String state;
  final String pinCode;
  final String label;

  AddressModel({
    required this.fullName,
    required this.phoneNumber,
    required this.street,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.label,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'phoneNumber': phoneNumber,
    'street': street,
    'city': city,
    'state': state,
    'pinCode': pinCode,
    'label': label,
  };

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      street: json['street'],
      city: json['city'],
      state: json['state'],
      pinCode: json['pinCode'],
      label: json['label'],
    );
  }
}
