import 'dart:io';
// ignore_for_file: avoid_print
import 'package:dio/dio.dart';

/// A script to synchronize the PermissionConstants in the frontend with the backend's permission map.
/// Run this script using: `dart bin/sync_permissions.dart`
void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart bin/sync_permissions.dart <access_token>');
    exit(1);
  }

  final String accessToken = args[0];
  const String baseUrl = 'https://bomachauth.bgbot.app';
  const String endpoint = '/api/v1/roles/permissions-map';
  const String targetFile = 'lib/src/constants/permissions.dart';

  print('Fetching permissions map from $baseUrl$endpoint...');

  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    },
  ));

  try {
    final response = await dio.get(endpoint);

    if (response.statusCode != 200) {
      print('Error: Received status code ${response.statusCode}');
      exit(1);
    }

    final Map<String, dynamic> permissionsMap =
        response.data['permissions_map'] ?? {};

    if (permissionsMap.isEmpty) {
      print('Error: Received empty permissions map');
      exit(1);
    }

    final StringBuffer buffer = StringBuffer();
    buffer.writeln('class PermissionConstants {');
    buffer.writeln('  // Resources');

    final List<String> resources = permissionsMap.keys.toList()..sort();
    final Set<String> allActions = {};

    for (final resource in resources) {
      final String constantName = _toCamelCase('res_$resource');
      buffer.writeln("  static const String $constantName = '$resource';");

      final List<dynamic> actions = permissionsMap[resource] ?? [];
      for (final action in actions) {
        allActions.add(action.toString());
      }
    }

    buffer.writeln('\n  // Actions');
    final List<String> sortedActions = allActions.toList()..sort();
    for (final action in sortedActions) {
      final String constantName = _toCamelCase('act_$action');
      buffer.writeln("  static const String $constantName = '$action';");
    }

    buffer.writeln('\n  // Combined permission strings for convenience');
    buffer.writeln(
        "  static String perm(String resource, String action) => '\$resource:\$action';");
    buffer.writeln('}');

    final File file = File(targetFile);
    await file.writeAsString(buffer.toString());

    print(
        'Successfully synchronized $targetFile with ${resources.length} resources and ${allActions.length} unique actions.');
  } catch (e) {
    print('Failed to synchronize permissions: $e');
    exit(1);
  }
}

String _toCamelCase(String text) {
  final parts = text.split('_');
  final buffer = StringBuffer(parts[0]);
  for (var i = 1; i < parts.length; i++) {
    if (parts[i].isEmpty) continue;
    buffer.write(parts[i][0].toUpperCase() + parts[i].substring(1));
  }
  return buffer.toString();
}
