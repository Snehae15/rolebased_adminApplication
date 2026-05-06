import '../../domain/entities/dashboard_entities.dart';

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String) return value;
  }
  throw FormatException('Missing string field. Expected one of: ${keys.join(', ')}');
}

double _readDouble(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toDouble();
  }
  throw FormatException('Missing numeric field. Expected one of: ${keys.join(', ')}');
}

int _readCount(dynamic value) {
  if (value is int) return value;
  if (value is Map<String, dynamic> && value['count'] is int) {
    return value['count'] as int;
  }
  throw const FormatException('Missing sales summary count');
}

class RevenueModel extends RevenueEntity {
  const RevenueModel(super.totalRevenue);
  factory RevenueModel.fromJson(Map<String, dynamic> json) =>
      RevenueModel(_readDouble(json, ['totalRevenue']));
}

class SalesSummaryModel extends SalesSummaryEntity {
  const SalesSummaryModel(super.successful, super.cancelled);
  factory SalesSummaryModel.fromJson(Map<String, dynamic> json) =>
      SalesSummaryModel(
        SalesSummaryItem('Successful', _readCount(json['successful'])),
        SalesSummaryItem('Cancelled', _readCount(json['cancelled'])),
      );
}

class CountryModel extends CountryEntity {
  const CountryModel(super.name, super.amount);
  factory CountryModel.fromJson(Map<String, dynamic> json) => CountryModel(
        _readString(json, ['name', 'country']),
        _readDouble(json, ['amount', 'sales']),
      );
}

class StateModel extends StateEntity {
  const StateModel(super.name, super.amount);
  factory StateModel.fromJson(Map<String, dynamic> json) => StateModel(
        _readString(json, ['name', 'state']),
        _readDouble(json, ['amount', 'sales']),
      );
}

class CityModel extends CityEntity {
  const CityModel(super.name, super.amount);
  factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
        _readString(json, ['name', 'city']),
        _readDouble(json, ['amount', 'sales']),
      );
}

class CityPageModel extends CityPageEntity {
  const CityPageModel(super.data, super.page, super.totalPages);
  factory CityPageModel.fromJson(Map<String, dynamic> json) {
    return CityPageModel(
      (json['data'] as List).map((e) => CityModel.fromJson(e)).toList(),
      json['page'] as int,
      json['totalPages'] as int,
    );
  }
}

class HourlyGrowthModel extends HourlyGrowthEntity {
  const HourlyGrowthModel(super.label, super.amount);
  factory HourlyGrowthModel.fromJson(Map<String, dynamic> json) =>
      HourlyGrowthModel(
        _readString(json, ['label']),
        _readDouble(json, ['amount']),
      );
}
