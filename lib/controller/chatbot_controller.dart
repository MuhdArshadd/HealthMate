import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  final String openaiApiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  OpenAIService() {
    if (openaiApiKey.isEmpty) {
      throw Exception("OpenAI API key is missing. Please check your .env file.");
    }
  }

  // Main conversation logic
  Future<String> runConversation(String content) async {
    // Define the tools
    final List<Map<String, dynamic>> tools = [
      {
        "name": "handle_general_question",
        "description":
        "Handle general conversational questions and interactions about the app. This includes: Greetings (e.g., 'Hello!', 'Thank you!'). Questions about the app's purpose, features (non-data specific), functionality, or regarding Human Health.",
        "parameters": {
          "type": "object",
          "properties": {
            "content": {
              "type": "string",
              "description": "The user's question or interaction."
            }
          },
          "required": ["content"]
        }
      }
    ];

    // System prompt to guide function usage
    const String systemPrompt = """
    You are a chatbot for the HelpMate mobile app, designed to assist users with health management, symptom tracking, medication reminders, and general app-related inquiries.
    
    Follow these rules:
    1. Use the 'handle_general_question' function for general app-related queries, greetings, casual interactions about the app's purpose and features. Furthermore, you can use the function for health-related questions too.
    2. If the user prompt is not related to any function, do not use the function.
    3. Ensure the user's question aligns with the function arguments before calling the function.
    """;

    // Prepare the request payload for OpenAI API
    final Map<String, dynamic> payload = {

      'model': 'gpt-4o-2024-08-06',
      "messages": [
        {"role": "system", "content": systemPrompt},
        {"role": "user", "content": content}
      ],
      "functions": tools,
      "function_call": "auto"
    };

    try {
      // Send the API request
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $openaiApiKey',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final responseMessage = responseData['choices'][0]['message'];

        // Check if a function was called
        if (responseMessage.containsKey('function_call')) {
          final String functionName = responseMessage['function_call']['name'];
          final Map<String, dynamic> functionArguments = jsonDecode(responseMessage['function_call']['arguments']);

          // Debugging: Print function name and arguments
          print('Function called: $functionName');
          print('Function arguments: ${jsonEncode(functionArguments, toEncodable: (e) => e.toString())}');

          // Map functions to their implementations
          final Map<String, Function> availableFunctions = {
            "handle_general_question": handleGeneralQuestion
          };

          // Call the selected function if available
          if (availableFunctions.containsKey(functionName)) {
            return availableFunctions[functionName]!(functionArguments['content']);
          }
        }
        // Default response if no function call
        return "I'm sorry, I can only assist with questions related to the app's features and functionalities only.";

      } else {
        // Handle HTTP errors
        return "Error: ${response.statusCode} - ${response.reasonPhrase}";
      }
    } catch (e) {
      // Handle network or other errors
      return "An error occurred: $e";
    }
  }

  // Function to handle general questions
  Future<String> handleGeneralQuestion(String content) async {
    String prompt = """
    You are a helpful assistant specifically designed to answer questions about the HelpMate app. 
    
    - If the question is related to the app or human health, provide a concise, short(summarize) and accurate response.  
    - If the question is not related to the app, provide a polite and general response, redirecting the user to ask questions specific to the HelpMate app.  
    
    The user asked: "$content"
    """;

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $openaiApiKey',
      },
      body: json.encode({
        'model': 'gpt-4o-2024-08-06',
        'messages': [{'role': 'system', 'content': prompt}],
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return responseBody['choices'][0]['message']['content'];
    } else {
      return 'Error in fetching response from OpenAI.';
    }
  }

}
