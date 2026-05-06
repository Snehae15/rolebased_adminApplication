class RevenueEntity {
  final double totalRevenue;
  const RevenueEntity(this.totalRevenue);
}

class SalesSummaryItem {
  final String label;
  final int count;
  const SalesSummaryItem(this.label, this.count);
}

class SalesSummaryEntity {
  final SalesSummaryItem successful;
  final SalesSummaryItem cancelled;
  const SalesSummaryEntity(this.successful, this.cancelled);
}

class CountryEntity {
  final String name;
  final double amount;
  const CountryEntity(this.name, this.amount);
}

class StateEntity {
  final String name;
  final double amount;
  const StateEntity(this.name, this.amount);
}

class CityEntity {
  final String name;
  final double amount;
  const CityEntity(this.name, this.amount);
}

class CityPageEntity {
  final List<CityEntity> data;
  final int page;
  final int totalPages;
  const CityPageEntity(this.data, this.page, this.totalPages);
}

class HourlyGrowthEntity {
  final String label;
  final double amount;
  const HourlyGrowthEntity(this.label, this.amount);
}
