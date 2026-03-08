import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:restaurant/src/data/models/restaurant.dart';
import 'package:restaurant/src/data/models/tag_model.dart';
import 'package:restaurant/src/data/repositories/restaurants_repository.dart';
import 'package:restaurant/src/domain/restaurants/restaurants_cubit.dart';

class MockRestaurantsRepository extends Mock implements RestaurantsRepository {}

void main() {
  late RestaurantsCubit cubit;
  late MockRestaurantsRepository mockRepo;

  final sampleRestaurants = [
    Restaurant(
      id: '1',
      name: 'Pizza Place',
      tags: [
        RestaurantTag(id: '1', name: 'Italian'),
        RestaurantTag(id: '2', name: 'Pizza'),
      ],
      locationText: 'Main Street',
    ),
    Restaurant(
      id: '2',
      name: 'Sushi Bar',
      tags: [
        RestaurantTag(id: '3', name: 'Japanese'),
        RestaurantTag(id: '4', name: 'Sushi'),
      ],
      locationText: 'Second Ave',
    ),
    Restaurant(
      id: '3',
      name: 'Burger Joint',
      tags: [
        RestaurantTag(id: '5', name: 'American'),
        RestaurantTag(id: '6', name: 'Burgers'),
      ],
      locationText: 'Third Blvd',
    ),
  ];

  setUp(() {
    mockRepo = MockRestaurantsRepository();
    cubit = RestaurantsCubit(repository: mockRepo);
  });

  tearDown(() => cubit.close());

  group('RestaurantsCubit', () {
    group('loadRestaurants', () {
      blocTest<RestaurantsCubit, RestaurantsState>(
        'emits [Loading, Loaded] on success',
        build: () {
          when(() => mockRepo.getRestaurants()).thenAnswer(
            (_) async => RestaurantsListResult(
              success: true,
              restaurants: sampleRestaurants,
            ),
          );
          return cubit;
        },
        act: (c) => c.loadRestaurants(),
        expect: () => [
          isA<RestaurantsLoading>(),
          isA<RestaurantsLoaded>()
              .having((s) => s.restaurants.length, 'count', 3)
              .having((s) => s.filteredRestaurants.length, 'filtered', 3),
        ],
      );

      blocTest<RestaurantsCubit, RestaurantsState>(
        'emits [Loading, Error] on failure',
        build: () {
          when(() => mockRepo.getRestaurants()).thenAnswer(
            (_) async => RestaurantsListResult(
              success: false,
              restaurants: [],
              error: 'Network error',
            ),
          );
          return cubit;
        },
        act: (c) => c.loadRestaurants(),
        expect: () => [
          isA<RestaurantsLoading>(),
          isA<RestaurantsError>().having(
            (s) => s.message,
            'message',
            'Network error',
          ),
        ],
      );

      blocTest<RestaurantsCubit, RestaurantsState>(
        'emits [Loading, Error] on exception',
        build: () {
          when(() => mockRepo.getRestaurants()).thenThrow(Exception('timeout'));
          return cubit;
        },
        act: (c) => c.loadRestaurants(),
        expect: () => [isA<RestaurantsLoading>(), isA<RestaurantsError>()],
      );
    });

    group('searchRestaurants', () {
      blocTest<RestaurantsCubit, RestaurantsState>(
        'filters by name',
        build: () {
          when(() => mockRepo.getRestaurants()).thenAnswer(
            (_) async => RestaurantsListResult(
              success: true,
              restaurants: sampleRestaurants,
            ),
          );
          return cubit;
        },
        act: (c) async {
          await c.loadRestaurants();
          c.searchRestaurants('pizza');
        },
        skip: 2, // Skip loading + first loaded
        expect: () => [
          isA<RestaurantsLoaded>()
              .having((s) => s.filteredRestaurants.length, 'filtered', 1)
              .having(
                (s) => s.filteredRestaurants.first.name,
                'name',
                'Pizza Place',
              )
              .having((s) => s.searchQuery, 'query', 'pizza'),
        ],
      );

      blocTest<RestaurantsCubit, RestaurantsState>(
        'returns all when query is empty',
        build: () {
          when(() => mockRepo.getRestaurants()).thenAnswer(
            (_) async => RestaurantsListResult(
              success: true,
              restaurants: sampleRestaurants,
            ),
          );
          return cubit;
        },
        act: (c) async {
          await c.loadRestaurants();
          c.searchRestaurants('pizza');
          c.searchRestaurants('');
        },
        skip: 3,
        expect: () => [
          isA<RestaurantsLoaded>().having(
            (s) => s.filteredRestaurants.length,
            'all',
            3,
          ),
        ],
      );
    });

    group('applyFilter', () {
      blocTest<RestaurantsCubit, RestaurantsState>(
        'filters restaurants by tag',
        build: () {
          when(() => mockRepo.getRestaurants()).thenAnswer(
            (_) async => RestaurantsListResult(
              success: true,
              restaurants: sampleRestaurants,
            ),
          );
          return cubit;
        },
        act: (c) async {
          await c.loadRestaurants();
          c.applyFilter('Italian');
        },
        skip: 2,
        expect: () => [
          isA<RestaurantsLoaded>()
              .having((s) => s.filteredRestaurants.length, 'count', 1)
              .having((s) => s.activeFilters, 'filters', {'Italian'}),
        ],
      );

      blocTest<RestaurantsCubit, RestaurantsState>(
        'toggles filter off when applied twice',
        build: () {
          when(() => mockRepo.getRestaurants()).thenAnswer(
            (_) async => RestaurantsListResult(
              success: true,
              restaurants: sampleRestaurants,
            ),
          );
          return cubit;
        },
        act: (c) async {
          await c.loadRestaurants();
          c.applyFilter('Italian');
          c.applyFilter('Italian'); // Toggle off
        },
        skip: 3,
        expect: () => [
          isA<RestaurantsLoaded>()
              .having((s) => s.filteredRestaurants.length, 'all back', 3)
              .having((s) => s.activeFilters, 'empty', <String>{}),
        ],
      );
    });

    group('clearFilters', () {
      blocTest<RestaurantsCubit, RestaurantsState>(
        'resets search and filters',
        build: () {
          when(() => mockRepo.getRestaurants()).thenAnswer(
            (_) async => RestaurantsListResult(
              success: true,
              restaurants: sampleRestaurants,
            ),
          );
          return cubit;
        },
        act: (c) async {
          await c.loadRestaurants();
          c.applyFilter('Italian');
          c.searchRestaurants('pizza');
          c.clearFilters();
        },
        skip: 4,
        expect: () => [
          isA<RestaurantsLoaded>()
              .having((s) => s.filteredRestaurants.length, 'all', 3)
              .having((s) => s.activeFilters, 'empty', <String>{})
              .having((s) => s.searchQuery, 'query', ''),
        ],
      );
    });
  });
}
