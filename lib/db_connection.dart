import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DatabaseConnection {
  PostgreSQLConnection? _connection;
  bool _isConnected = false;

  DatabaseConnection() {
    connectToDatabase();
  }

  Future<void> connectToDatabase() async {
    await dotenv.load();

    String host = dotenv.get('DB_HOST');
    int port = int.parse(dotenv.get('DB_PORT'));
    String dbName = dotenv.get('DB_NAME');
    String username = dotenv.get('DB_USER');
    String password = dotenv.get('DB_PASSWORD');

    if (!_isConnected || _connection == null || _connection!.isClosed) {
      _connection = PostgreSQLConnection(
        host,
        port,
        dbName,
        username: username,
        password: password,
        useSSL: true,
      );

      try {
        await _connection!.open();
        _isConnected = true;
        print("Connected to the database");
      } catch (e) {
        print("Failed to connect to database: $e");
        throw Exception("Database connection failed");
      }
    }
  }

  PostgreSQLConnection get connection {
    if (_connection == null) {
      throw Exception("Database connection is not initialized.");
    }
    return _connection!;
  }

  Future<void> closeConnection() async {
    if (_isConnected && _connection != null) {
      await _connection!.close();
      _isConnected = false;
      print("Database connection closed");
    }
  }
}
