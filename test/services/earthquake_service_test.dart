import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:emsc_usgs_mobile/services/earthquake_service_integrated.dart';
import 'package:emsc_usgs_mobile/models/earthquake.dart';

// Mock classes
class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('EarthquakeServiceIntegrated Tests', () {
    late EarthquakeServiceIntegrated service;
    late MockHttpClient mockHttpClient;

    setUp(() {
      service = EarthquakeServiceIntegrated();
      mockHttpClient = MockHttpClient();
    });

    group('API Data Fetching', () {
      test('should fetch earthquakes from EMSC API', () async {
        // Arrange
        const mockResponse = '''
        {
          "type": "FeatureCollection",
          "features": [
            {
              "type": "Feature",
              "properties": {
                "unid": "test123",
                "mag": 5.2,
                "place": "Test Location",
                "time": "2024-01-15T14:30:00Z"
              },
              "geometry": {
                "type": "Point",
                "coordinates": [32.8597, 39.9334, 10.5]
              }
            }
          ]
        }
        ''';

        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response(mockResponse, 200));

        // Act
        final earthquakes = await service.getAllEarthquakes(limit: 10);

        // Assert
        expect(earthquakes, isNotEmpty);
        expect(earthquakes.first.magnitude, equals(5.2));
        expect(earthquakes.first.source, equals('EMSC'));
      });

      test('should handle API errors gracefully', () async {
        // Arrange
        when(mockHttpClient.get(any))
            .thenAnswer((_) async => http.Response('Server Error', 500));

        // Act
        final earthquakes = await service.getAllEarthquakes();

        // Assert
        expect(earthquakes, isEmpty);
      });

      test('should validate earthquake data', () {
        // Arrange
        const testData = {
          'id': 'test123',
          'magnitude': 5.2,
          'place': 'Test Location',
          'time': '2024-01-15T14:30:00Z',
          'latitude': 39.9334,
          'longitude': 32.8597,
          'depth': 10.5,
          'source': 'TEST'
        };

        // Act
        final earthquake = Earthquake(
          id: testData['id'] as String,
          magnitude: testData['magnitude'] as double,
          place: testData['place'] as String,
          time: DateTime.parse(testData['time'] as String),
          latitude: testData['latitude'] as double,
          longitude: testData['longitude'] as double,
          depth: testData['depth'] as double,
          source: testData['source'] as String,
        );

        // Assert
        expect(earthquake.id, equals('test123'));
        expect(earthquake.magnitude, equals(5.2));
        expect(earthquake.latitude, equals(39.9334));
        expect(earthquake.longitude, equals(32.8597));
      });
    });

    group('Data Validation', () {
      test('should validate latitude range', () {
        expect(() => Earthquake(
          id: 'test',
          magnitude: 5.0,
          place: 'Test',
          time: DateTime.now(),
          latitude: 91.0, // Invalid
          longitude: 0.0,
          depth: 0.0,
          source: 'TEST',
        ), throwsArgumentError);
      });

      test('should validate longitude range', () {
        expect(() => Earthquake(
          id: 'test',
          magnitude: 5.0,
          place: 'Test',
          time: DateTime.now(),
          latitude: 0.0,
          longitude: 181.0, // Invalid
          depth: 0.0,
          source: 'TEST',
        ), throwsArgumentError);
      });

      test('should validate magnitude range', () {
        expect(() => Earthquake(
          id: 'test',
          magnitude: -1.0, // Invalid
          place: 'Test',
          time: DateTime.now(),
          latitude: 0.0,
          longitude: 0.0,
          depth: 0.0,
          source: 'TEST',
        ), throwsArgumentError);
      });
    });

    group('Offline Mode', () {
      test('should detect offline mode', () async {
        // Arrange
        when(mockHttpClient.get(any))
            .thenThrow(const SocketException('No internet'));

        // Act
        final isOffline = await service.isOfflineMode();

        // Assert
        expect(isOffline, isTrue);
      });

      test('should return cached data when offline', () async {
        // This test would require mocking the database service
        // Implementation depends on the actual cache structure
      });
    });

    group('Data Processing', () {
      test('should remove duplicate earthquakes', () {
        // Arrange
        final earthquakes = [
          Earthquake(
            id: 'test1',
            magnitude: 5.0,
            place: 'Location A',
            time: DateTime.now(),
            latitude: 39.0,
            longitude: 32.0,
            depth: 10.0,
            source: 'TEST',
          ),
          Earthquake(
            id: 'test1', // Duplicate ID
            magnitude: 5.0,
            place: 'Location A',
            time: DateTime.now(),
            latitude: 39.0,
            longitude: 32.0,
            depth: 10.0,
            source: 'TEST',
          ),
        ];

        // Act
        final uniqueEarthquakes = service.removeDuplicates(earthquakes);

        // Assert
        expect(uniqueEarthquakes.length, equals(1));
      });

      test('should sort earthquakes by time descending', () {
        // Arrange
        final now = DateTime.now();
        final earthquakes = [
          Earthquake(
            id: 'old',
            magnitude: 4.0,
            place: 'Old',
            time: now.subtract(Duration(hours: 2)),
            latitude: 39.0,
            longitude: 32.0,
            depth: 10.0,
            source: 'TEST',
          ),
          Earthquake(
            id: 'new',
            magnitude: 5.0,
            place: 'New',
            time: now,
            latitude: 39.0,
            longitude: 32.0,
            depth: 10.0,
            source: 'TEST',
          ),
        ];

        // Act
        earthquakes.sort((a, b) => b.time.compareTo(a.time));

        // Assert
        expect(earthquakes.first.id, equals('new'));
        expect(earthquakes.last.id, equals('old'));
      });
    });
  });
}
