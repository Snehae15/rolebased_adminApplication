import 'package:get/get.dart';

import '../../core/network/dio_client.dart';
import '../../core/services/token_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DioClient(), permanent: true);
    Get.put(TokenService(), permanent: true);
  }
}
