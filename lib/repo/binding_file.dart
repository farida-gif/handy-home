import 'package:get/get.dart';
import 'package:handy_home2/repo/available_workers_repo.dart';
//import 'package:handy_home2/pages/clients_pages/booking_pages/worker_booking_calender.dart';
import 'package:handy_home2/repo/workers_repo.dart';
import 'package:handy_home2/repo/service_repo.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ServiceRepo());
    Get.put(WorkersRepo.instance); //  Correct way to inject singleton
 Get.put(AvailableWorkersRepo.instance);
  }
}