import '../../../../core/utils/result.dart';
import '../entities/client.dart';
import '../repositories/client_repository.dart';

/// Use case for getting a list of clients
/// 
/// This encapsulates the business logic for retrieving clients,
/// keeping it separate from the presentation layer.
class GetClients {
  final ClientRepository _repository;

  GetClients(this._repository);

  /// Executes the use case
  /// 
  /// [params] - Optional parameters for filtering and sorting
  Future<Result<List<Client>>> call([GetClientsParams? params]) {
    return _repository.getClients(
      filter: params?.filter,
      sortBy: params?.sortBy ?? ClientSortBy.name,
      ascending: params?.ascending ?? true,
    );
  }

  /// Returns a stream of clients for real-time updates
  Stream<List<Client>> watch([GetClientsParams? params]) {
    return _repository.watchClients(
      filter: params?.filter,
      sortBy: params?.sortBy ?? ClientSortBy.name,
      ascending: params?.ascending ?? true,
    );
  }
}

/// Parameters for GetClients use case
class GetClientsParams {
  final ClientFilter? filter;
  final ClientSortBy sortBy;
  final bool ascending;

  const GetClientsParams({
    this.filter,
    this.sortBy = ClientSortBy.name,
    this.ascending = true,
  });

  /// Creates params for getting today's scheduled clients
  factory GetClientsParams.todaySchedule() => const GetClientsParams(
        filter: ClientFilter(hasScheduleToday: true),
        sortBy: ClientSortBy.name,
      );

  /// Creates params for searching clients
  factory GetClientsParams.search(String query) => GetClientsParams(
        filter: ClientFilter(searchQuery: query),
        sortBy: ClientSortBy.name,
      );

  /// Creates params for getting recently active clients
  factory GetClientsParams.recentlyActive() => GetClientsParams(
        filter: ClientFilter(
          lastWorkoutAfter: DateTime.now().subtract(const Duration(days: 7)),
        ),
        sortBy: ClientSortBy.lastWorkout,
        ascending: false,
      );
}

