import '../../../../core/utils/result.dart';
import '../entities/client.dart';

/// Parameters for creating a new client
class CreateClientParams {
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final ClientProfile? profile;

  const CreateClientParams({
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.profile,
  });
}

/// Parameters for updating a client
class UpdateClientParams {
  final String id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? avatarUrl;
  final ClientProfile? profile;

  const UpdateClientParams({
    required this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.avatarUrl,
    this.profile,
  });
}

/// Filter options for listing clients
class ClientFilter {
  final String? searchQuery;
  final bool? hasActiveWorkout;
  final bool? hasScheduleToday;
  final DateTime? lastWorkoutAfter;
  final DateTime? lastWorkoutBefore;

  const ClientFilter({
    this.searchQuery,
    this.hasActiveWorkout,
    this.hasScheduleToday,
    this.lastWorkoutAfter,
    this.lastWorkoutBefore,
  });
}

/// Sort options for clients list
enum ClientSortBy {
  name,
  lastWorkout,
  createdAt,
  attendanceRate,
}

/// Repository interface for client operations
/// 
/// This is the contract that the data layer must implement.
/// The domain layer only knows about this interface, not the implementation.
abstract interface class ClientRepository {
  /// Gets all clients for the current trainer
  /// 
  /// [filter] - Optional filter criteria
  /// [sortBy] - Sort order (defaults to name)
  /// [ascending] - Sort direction (defaults to true)
  Future<Result<List<Client>>> getClients({
    ClientFilter? filter,
    ClientSortBy sortBy = ClientSortBy.name,
    bool ascending = true,
  });

  /// Gets a single client by ID
  Future<Result<Client>> getClientById(String id);

  /// Creates a new client
  Future<Result<Client>> createClient(CreateClientParams params);

  /// Updates an existing client
  Future<Result<Client>> updateClient(UpdateClientParams params);

  /// Deletes a client
  /// 
  /// This is a soft delete - client data is archived, not permanently removed
  Future<Result<void>> deleteClient(String id);

  /// Gets stats for a client
  Future<Result<ClientStats>> getClientStats(String clientId);

  /// Watches clients list for real-time updates
  Stream<List<Client>> watchClients({
    ClientFilter? filter,
    ClientSortBy sortBy = ClientSortBy.name,
    bool ascending = true,
  });

  /// Watches a single client for real-time updates
  Stream<Client?> watchClient(String id);

  /// Gets clients scheduled for a specific date
  Future<Result<List<Client>>> getClientsForDate(DateTime date);

  /// Searches clients by name or email
  Future<Result<List<Client>>> searchClients(String query);
}

