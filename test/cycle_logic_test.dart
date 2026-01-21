import 'package:flutter_test/flutter_test.dart';
import 'package:secure_flow_mobile/logic/cycle_provider.dart';
import 'package:secure_flow_mobile/data/services/api_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([MockSpec<ApiService>()])
import 'cycle_logic_test.mocks.dart';

void main() {
  group('CycleProvider Logic Tests', () {
    late CycleProvider provider;
    late MockApiService mockApi;

    setUp(() {
      mockApi = MockApiService();
      provider = CycleProvider(mockApi);
    });

    test('Initial state should be null prediction', () {
      expect(provider.prediction, isNull);
    });

    test('Local prediction should default to 28 day cycle', () {
      // We need to access private method or trigger it via refreshData with API fail
      // For this test, we'll just check if refreshData sets a prediction
      
      // Mock API to throw error to trigger local calculation
      when(mockApi.get(any)).thenThrow(Exception('API Error'));

      provider.refreshData().then((_) {
        expect(provider.prediction, isNotNull);
        expect(provider.prediction!.avgCycleLength, 28);
      });
    });
  });
}
