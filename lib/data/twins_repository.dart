import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/digital_twin.dart';
import 'firebase_config.dart';
import 'json_helpers.dart';

abstract class TwinsRepository {
  Future<List<RemoteDigitalTwin>> fetchTwins();
}

class FirebaseTwinsRepository implements TwinsRepository {
  FirebaseTwinsRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<List<RemoteDigitalTwin>> fetchTwins() async {
    final response = await _client.get(Uri.parse(twinsCollectionUrl())).timeout(
      const Duration(seconds: 20),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = response.body.trim();
      throw Exception(
        'Falha ao carregar Digital Twins no Firebase (${response.statusCode})'
        '${detail.isNotEmpty ? ': $detail' : ''}',
      );
    }

    if (response.body.isEmpty || response.body == 'null') {
      return const [];
    }

    final decoded = jsonDecode(response.body);
    if (decoded == null) return const [];

    if (decoded is! Map) {
      throw Exception('Resposta inesperada do Firebase ao listar Digital Twins.');
    }

    final twins = <RemoteDigitalTwin>[];
    decoded.forEach((key, value) {
      if (value is Map) {
        twins.add(RemoteDigitalTwin.fromJson(key.toString(), asMap(value)));
      }
    });

    twins.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return twins;
  }
}
