import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DatabaseConnection {
  late PostgreSQLConnection connection;

  Future<String> connectToDatabase() async {
    await dotenv.load();  // Ensure .env is loaded

    String host = dotenv.get('DB_HOST');
    int port = int.parse(dotenv.get('DB_PORT'));
    String dbName = dotenv.get('DB_NAME');
    String username = dotenv.get('DB_USER');
    String password = dotenv.get('DB_PASSWORD');

    connection = PostgreSQLConnection(
      host,  // host from .env
      port,  // port from .env
      dbName, // database name from .env
      username: username, // username from .env
      password: password, // password from .env
      useSSL: true, // SSL enabled
    );

    try {
      await connection.open();
      return "Connected to database";
    } catch (e) {
      return "Failed to connect to database: $e";
    }
  }

  void closeConnection() {
    connection.close();
  }
}