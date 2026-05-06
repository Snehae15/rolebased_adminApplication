import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/error/app_exception.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../../domain/usecases/dashboard_usecases.dart';

class CitiesController extends GetxController {
  final DashboardUseCases _useCases;
  CitiesController(this._useCases);

  final cities = <CityEntity>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  int _page = 1;
  static const int _limit = 20;
  late String stateName;

  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    stateName = Get.arguments as String;
    fetchCities();
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore.value && hasMore.value) fetchMore();
    }
  }

  Future<void> fetchCities() async {
    isLoading.value = true;
    try {
      final result = await _useCases.getCities(state: stateName, page: 1, limit: _limit);
      cities.assignAll(result.data);
      hasMore.value = result.page < result.totalPages;
      _page = 2;
    } on AppException catch (e) {
      Get.snackbar('Error', e.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMore() async {
    isLoadingMore.value = true;
    try {
      final result = await _useCases.getCities(state: stateName, page: _page, limit: _limit);
      cities.addAll(result.data);
      hasMore.value = result.page < result.totalPages;
      _page++;
    } on AppException catch (e) {
      Get.snackbar('Error', e.message);
    } finally {
      isLoadingMore.value = false;
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
