import 'dart:convert';

import 'package:flutter_movies/model/api_response.dart';
import "package:http/http.dart" as http;

class API {
  String url = "http://api.themoviedb.org/3/movie";
  final apiKey = "53133282dc48b97f36b50a6a54ac8d48";

  Future<List<Movie>> getUpcomingMovies(int pageId) async {
    final response = await http.get(Uri.parse("$url/upcoming?api_key=$apiKey&page=$pageId"));

    if (response.statusCode == 200) {
      var apiResponse = ApiResponse.fromJSON(json.decode(response.body));
      return apiResponse.results;
    } else {
      throw Exception('Failed to load data.');
    }
  }
}