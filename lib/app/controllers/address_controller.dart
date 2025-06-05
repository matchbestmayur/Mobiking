import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../data/AddressModel.dart';


class AddressController extends GetxController {
  final box = GetStorage();
  final RxList<AddressModel> addresses = <AddressModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  void loadAddresses() {
    final data = box.read<List>('addresses');
    if (data != null) {
      addresses.value = data.map((e) => AddressModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }
  }

  void saveAddress({
    required String fullName,
    required String phoneNumber,
    required String street,
    required String city,
    required String state,
    required String pinCode,
    required String label,
  }) {
    final address = AddressModel(
      fullName: fullName,
      phoneNumber: phoneNumber,
      street: street,
      city: city,
      state: state,
      pinCode: pinCode,
      label: label,
    );

    addresses.add(address);
    box.write('addresses', addresses.map((e) => e.toJson()).toList());
  }
}
