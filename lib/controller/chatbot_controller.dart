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

  // Map<String, Map<String, Map<String, String>>> tablesInfo = {
  //   // Sleep_Tracking table
  //   "sleep_tracking": {
  //     "users_id": {"description": "The mode of delivery for the skill (Online or Physical only)"},
  //     "hours_asleep": {"description": "The domain or area of the skill, where for Online mode are Business, Computer Science, Personal Development, Information Technology only. While Physical mode are skill, SPEED, and information technology only.)"},
  //     "sleep_start": {"description": "The specific name of the skill or course (e.g., Python, Data Science, Project Management)"},
  //     "sleep_end": {"description": "The URL or link to the source or website offering the course"},
  //     "created_at": {"description": "The instructor, platform, or organization delivering the course (e.g., Udemy, Coursera)"},
  //   },
  //   // Glucose_Tracking table
  //   "glucose_tracking": {
  //     "users_id": {"description": "The headline or title of the news article"},
  //     "glucose_level": {"description": "The person or entity that authored the news article"},
  //     "created_at": {"description": "A brief summary or overview of the news content"},
  //   },
  // };

  // Main conversation logic
  Future<String> runConversation(String userID, String content) async {
    // Define the tools
    final List<Map<String, dynamic>> tools = [
      {
        "name": "handle_general_app_info_question",
        "description":
        "Handles general inquiries about the app, including greetings (e.g., 'Hello!', 'Thank you!') and questions about its purpose, features, and functionality. Covers non-data-specific topics such as sleep tracking, glucose monitoring, and cognitive games for mental assistance.",
        "parameters": {
          "type": "object",
          "properties": {
            "content": {
              "type": "string",
              "description": "The user's general inquiry or interaction."
            }
          },
          "required": ["content"]
        }
      },
      {
        "name": "handle_mental_health_question",
        "description":
        "Handles user questions or statements related to mental health, emotions, or well-being. This includes expressions of feelings, seeking emotional support, or guidance on stress, anxiety, and mood-related concerns.",
        "parameters": {
          "type": "object",
          "properties": {
            "content": {
              "type": "string",
              "description": "The user's mental health-related question or statement."
            }
          },
          "required": ["content"]
        }
      },
      {
        "name": "handle_physical_health_question",
        "description":
        "Handles user inquiries related to physical health, symptoms, fitness, or medical concerns. Covers questions on illnesses, pain, body conditions, nutrition, exercise, and general well-being.",
        "parameters": {
          "type": "object",
          "properties": {
            "content": {
              "type": "string",
              "description": "The user's physical health-related question."
            }
          },
          "required": ["content"]
        }
      }
    ];


    // System prompt to guide function usage
    const String systemPrompt = """
    You are a chatbot for the HealthMate mobile app, designed to assist users with health management, symptom tracking, medication reminders, and general app-related inquiries.
    
    Follow these rules:
    1. Use the 'handle_general_app_info_question' function for general app-related queries, greetings, and casual interactions. This includes questions about the app's purpose, features, and functionality, such as sleep tracking, glucose monitoring, and cognitive games.
    2. Use the 'handle_mental_health_question' function when the user expresses emotions, seeks emotional support, or asks about mental health topics such as stress, anxiety, or mood-related concerns.
    3. Use the 'handle_physical_health_question' function for user inquiries related to physical health, symptoms, fitness, illnesses, body conditions, nutrition, and exercise.
    4. Only call a function if the user's request is relevant to it. If no function is applicable, respond conversationally without invoking a function.
    5. Ensure the user's input matches the function's expected parameters before making a function call.
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
            "handle_general_app_info_question": handleGeneralAppInfoQuestion,
            "handle_mental_health_question": handleMentalHealthQuestion,
            "handle_physical_health_question": handlePhysicalHealthQuestion
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

  // Function to handle general app info questions
  Future<String> handleGeneralAppInfoQuestion(String content) async {
    String prompt = """
    You are a knowledgeable and concise assistant dedicated to answering questions about the HealthMate app. 
    
    - If the user's question is about the app's features, purpose, or functionality (e.g., sleep tracking, glucose monitoring, cognitive games), provide a clear, concise, and accurate response.  
    - If the question is unrelated to the app, politely redirect the user to focus on HealthMate-related inquiries.  
    - If the user is engaging in casual interaction rather than asking a question, respond in a friendly and conversational manner to maintain a natural user experience.  
    
    User's question: "$content"
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

  // Function to handle mental health questions
  Future<String> handleMentalHealthQuestion(String content) async {
    String prompt = """
    You are a compassionate and supportive assistant in HealthMate application designed to help users with mental health concerns. 
  
    - If the user expresses emotions or discusses stress, anxiety, or mood-related issues, provide a calm, supportive, and understanding response.  
    - Offer general well-being advice, such as relaxation techniques, stress management tips, or encouragement.  
    - Do not provide medical diagnoses or professional therapy; instead, suggest seeking professional help if necessary.  
  
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

  // Function to handle physical health questions
  Future<String> handlePhysicalHealthQuestion(String content) async {
    String prompt = """
    You are an AI assistant specializing in physical health-related guidance for a HealthMate application. 
  
    - If the user asks about symptoms, fitness, nutrition, or general health concerns, provide a concise and accurate response based on common medical knowledge.  
    - Offer general health tips, such as exercise recommendations, healthy eating habits, and self-care advice.  
    - Do not provide medical diagnoses; instead, suggest consulting a healthcare professional for serious concerns.  
  
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
