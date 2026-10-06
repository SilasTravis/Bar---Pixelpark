import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'core/local_source/local_source.dart';
import 'core/localization/locale_cubit.dart';
import 'core/network/api_client.dart';
import 'core/network/token_refresher.dart';
import 'core/printing/bar_receipt_printer.dart';
import 'core/update/release_source.dart';
import 'core/update/update_service.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/bloc/login_bloc.dart';
import 'features/auth/presentation/cubit/session_cubit.dart';
import 'features/products/data/products_remote_data_source.dart';
import 'features/products/data/products_repository_impl.dart';
import 'features/products/domain/products_repository.dart';
import 'features/sale/data/sales_remote_data_source.dart';
import 'features/sale/data/sales_repository_impl.dart';
import 'features/sale/domain/sales_repository.dart';
import 'features/sale/presentation/cubit/sale_cubit.dart';
import 'features/sales_history/presentation/cubit/sales_history_cubit.dart';
import 'features/shift/data/shift_remote_data_source.dart';
import 'features/shift/data/shift_repository_impl.dart';
import 'features/shift/domain/shift_repository.dart';
import 'features/shift/presentation/cubit/shift_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  await _initHive();

  sl.registerLazySingleton<TokenRefresher>(() => TokenRefresher(sl()));
  sl.registerLazySingleton<Dio>(() => buildDio(sl(), sl()));

  // Read once at startup: the version is fixed for the process lifetime.
  final packageInfo = await PackageInfo.fromPlatform();
  sl.registerSingleton<UpdateService>(
    UpdateService(
      // GitHub Releases of the bar's own repo only — the bar has no backend
      // update mirror in v1 (see GithubReleaseSource).
      source: GithubReleaseSource(),
      currentVersion: packageInfo.version,
      supportDirectory: getApplicationSupportDirectory,
    ),
    dispose: (service) => service.dispose(),
  );

  sl.registerFactory<LocaleCubit>(() => LocaleCubit(sl()));
  sl.registerLazySingleton<BarReceiptPrinter>(
    () =>
        BarReceiptPrinter(printerName: sl<LocalSource>().getReceiptPrinterName),
  );

  _authFeature();
  _shiftFeature();
  _productsFeature();
  _saleFeature();
}

Future<void> _initHive() async {
  final dir = await getApplicationSupportDirectory();
  Hive.init(dir.path);
  final box = await Hive.openBox<dynamic>(LocalSource.boxName);
  sl.registerSingleton<LocalSource>(LocalSource(box));
}

void _authFeature() {
  sl.registerFactory<LoginBloc>(() => LoginBloc(sl()));
  sl.registerFactory<SessionCubit>(() => SessionCubit(sl()));
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
}

void _shiftFeature() {
  sl.registerFactory<ShiftCubit>(() => ShiftCubit(sl()));
  sl.registerLazySingleton<ShiftRepository>(() => ShiftRepositoryImpl(sl()));
  sl.registerLazySingleton<ShiftRemoteDataSource>(
    () => ShiftRemoteDataSourceImpl(sl()),
  );
}

void _productsFeature() {
  sl.registerLazySingleton<ProductsRepository>(
    () => ProductsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ProductsRemoteDataSource>(
    () => ProductsRemoteDataSourceImpl(sl()),
  );
}

void _saleFeature() {
  sl.registerFactory<SaleCubit>(() => SaleCubit(sl(), sl()));
  sl.registerFactory<SalesHistoryCubit>(() => SalesHistoryCubit(sl()));
  sl.registerLazySingleton<SalesRepository>(() => SalesRepositoryImpl(sl()));
  sl.registerLazySingleton<SalesRemoteDataSource>(
    () => SalesRemoteDataSourceImpl(sl()),
  );
}
