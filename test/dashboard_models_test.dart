import 'package:flutter_test/flutter_test.dart';
import 'package:rolebased_adminapplication/features/dashboard/data/models/dashboard_models.dart';

void main() {
  test('parses sales summary count objects from the API', () {
    final model = SalesSummaryModel.fromJson({
      'successful': {'count': 274820, 'amount': 44182340.5},
      'cancelled': {'count': 37630, 'amount': 4093590.25},
    });

    expect(model.successful.count, 274820);
    expect(model.cancelled.count, 37630);
  });

  test('parses country, state, and city sales fields from the API', () {
    final country = CountryModel.fromJson({
      'country': 'United States',
      'code': 'US',
      'sales': 18450230,
    });
    final state = StateModel.fromJson({
      'country': 'United States',
      'state': 'California',
      'sales': 5230000,
    });
    final city = CityModel.fromJson({
      'state': 'California',
      'city': 'Los Angeles',
      'sales': 292774.68,
    });

    expect(country.name, 'United States');
    expect(country.amount, 18450230);
    expect(state.name, 'California');
    expect(state.amount, 5230000);
    expect(city.name, 'Los Angeles');
    expect(city.amount, 292774.68);
  });
}
