import 'package:bhimospeed/routers/app_route_constants.dart';
import 'package:bhimospeed/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouteConfiguration {
  final GoRouter _router;

  AppRouteConfiguration() : _router = GoRouter(
    routes: [
      GoRoute(
          name: AppRouteConstants.dashboardScreen,
          path: '/',
          builder: (context, state) {
            return const Dashboard();
          })
    ],
    errorBuilder: (context, state) {
      return const Scaffold(
        body: Center(child: Text('Halaman tidak ditemukan'),),
      );
    },
  );

  GoRouter get router => _router;
}
