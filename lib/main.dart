import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_task_tracker_app/core/constants/colors.dart';
import 'package:flutter_task_tracker_app/core/services/connectivity_service.dart';
import 'package:flutter_task_tracker_app/data/datasources/task_local_datasource.dart';
import 'package:flutter_task_tracker_app/data/datasources/task_remote_datasource.dart';
import 'package:flutter_task_tracker_app/data/repositories/task_repository.dart';
import 'package:flutter_task_tracker_app/presentation/task/blocs/task_bloc.dart';
import 'package:flutter_task_tracker_app/presentation/task/pages/task_list_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColors.primary,
      statusBarBrightness: Brightness.dark,
    ));

    // Inisialisasi services & datasources
    final connectivityService = ConnectivityService();
    final taskRepository = TaskRepository(
      remote: TaskRemoteDatasource(),
      local: TaskLocalDatasource(),
      connectivity: connectivityService,
    );

    return MultiBlocProvider(
      providers: [
        // Connectivity service tersedia di seluruh app
        RepositoryProvider<ConnectivityService>.value(
          value: connectivityService,
        ),
        // TaskBloc dengan repository
        BlocProvider(
          create: (context) => TaskBloc(taskRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Task Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
          textTheme: GoogleFonts.interTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        home: const TaskListPage(),
      ),
    );
  }
}
