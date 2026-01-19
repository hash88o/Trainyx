import 'package:get_it/get_it.dart';

// Core
// import '../core/network/api_client.dart';
// import '../core/database/app_database.dart';

// Clients Feature
import '../features/clients/domain/repositories/client_repository.dart';
import '../features/clients/domain/usecases/get_clients.dart';
import '../features/clients/domain/usecases/add_client.dart';
// import '../features/clients/data/repositories/client_repository_impl.dart';
// import '../features/clients/data/datasources/client_remote_datasource.dart';
// import '../features/clients/data/datasources/client_local_datasource.dart';
// import '../features/clients/presentation/bloc/clients_bloc.dart';

// Workouts Feature
import '../features/workouts/domain/repositories/workout_repository.dart';
// import '../features/workouts/data/repositories/workout_repository_impl.dart';
import '../features/workouts/presentation/bloc/active_workout_bloc.dart';

/// Global service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
/// 
/// Call this in main() before runApp()
Future<void> initDependencies() async {
  // Core
  await _initCore();
  
  // Features
  await _initClientsFeature();
  await _initWorkoutsFeature();
  await _initDietFeature();
  await _initAttendanceFeature();
}

Future<void> _initCore() async {
  // Database
  // sl.registerLazySingleton<AppDatabase>(() => AppDatabase());
  
  // Network
  // sl.registerLazySingleton<ApiClient>(() => ApiClient(
  //   baseUrl: 'https://api.jackedlog.com/v1',
  // ));
  
  // Network Info
  // sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
}

Future<void> _initClientsFeature() async {
  // Data Sources
  // sl.registerLazySingleton<ClientRemoteDataSource>(
  //   () => ClientRemoteDataSourceImpl(apiClient: sl()),
  // );
  // sl.registerLazySingleton<ClientLocalDataSource>(
  //   () => ClientLocalDataSourceImpl(database: sl()),
  // );
  
  // Repository
  // sl.registerLazySingleton<ClientRepository>(
  //   () => ClientRepositoryImpl(
  //     remoteDataSource: sl(),
  //     localDataSource: sl(),
  //     networkInfo: sl(),
  //   ),
  // );
  
  // Use Cases
  // sl.registerLazySingleton(() => GetClients(sl()));
  // sl.registerLazySingleton(() => AddClient(sl()));
  
  // Bloc
  // sl.registerFactory(() => ClientsBloc(
  //   getClients: sl(),
  //   addClient: sl(),
  // ));
}

Future<void> _initWorkoutsFeature() async {
  // Data Sources
  // sl.registerLazySingleton<WorkoutRemoteDataSource>(
  //   () => WorkoutRemoteDataSourceImpl(apiClient: sl()),
  // );
  // sl.registerLazySingleton<WorkoutLocalDataSource>(
  //   () => WorkoutLocalDataSourceImpl(database: sl()),
  // );
  
  // Repository
  // sl.registerLazySingleton<WorkoutRepository>(
  //   () => WorkoutRepositoryImpl(
  //     remoteDataSource: sl(),
  //     localDataSource: sl(),
  //     networkInfo: sl(),
  //   ),
  // );
  
  // Bloc
  // sl.registerFactory(() => ActiveWorkoutBloc(
  //   repository: sl(),
  // ));
}

Future<void> _initDietFeature() async {
  // TODO: Implement diet feature DI
}

Future<void> _initAttendanceFeature() async {
  // TODO: Implement attendance feature DI
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await sl.reset();
  await initDependencies();
}

// Convenience getters for common services
// ApiClient get apiClient => sl<ApiClient>();
// AppDatabase get database => sl<AppDatabase>();

