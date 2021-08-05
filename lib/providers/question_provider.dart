import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:polls_app/models/questions_model.dart';

import 'package:polls_app/user_preferences/user_preferences.dart';

class QuestionProvider {
  final _prefs = new PreferenciasUsuario();

  Future<List<QuestionsModel>> getQuestionsPolls(int pollId) async {
    final resp = await http.get(
      Uri.parse('http://192.168.1.31/api/polls/$pollId/questions'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${_prefs.token}',
      },
    );

    // print(resp.body);
    Map<String, dynamic>? decodedResp = json.decode(resp.body);
    final List<QuestionsModel> questions = [];

    if (decodedResp == null) return [];
    if (decodedResp['data'] == null) return [];

    List<dynamic> data = decodedResp['data'];

    data.forEach((element) {
      final questionTemp = QuestionsModel.fromJson(element);

      questions.add(questionTemp);
    });

    return questions;
  }

  Future<Map<String, dynamic>?> saveQuestion(
      int pollId, QuestionsModel question, List<String> options) async {
    // print(options);
    final dataPoll = {
      "poll_id": pollId,
      "question": question.question,
      "type": question.type,
      "options" : options,
      "required": question.required
    };
    // print(dataPoll);

    final resp =
        await http.post(Uri.parse('http://192.168.1.31/api/questions'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
              'Authorization': 'Bearer ${_prefs.token}',
            },
            body: json.encode(dataPoll));
    
    if (resp.statusCode == 500) return {'success': false};

    Map<String, dynamic>? decodedResp = json.decode(resp.body);

    // return {};
    return decodedResp;
  }

  Future<Map<String, dynamic>?> updateQuestion(
      int pollId, QuestionsModel question, List<String> options) async {
    
    final dataPoll = {
      "poll_id" : pollId,
      "question": question.question,
      "type"    : question.type,
      "options" : options,
      "required": question.required
    };

    final resp =
        await http.put(Uri.parse('http://192.168.1.31/api/questions/${question.id}'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer ${_prefs.token}',
            },
            body: json.encode(dataPoll));
    
    if (resp.statusCode == 500) return {'success': false};

    Map<String, dynamic>? decodedResp = json.decode(resp.body);

    // return {};
    return decodedResp;
  }
}