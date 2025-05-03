import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiServices {
  final String apiUrl = "https://api.pexels.com/v1";
  final String apiKey =
      "piJSAmzYYNZG1I752PMCS5w6D3n4aCy7myCRfBoss1WJq59ohIAh4OPH";

  Future<List<dynamic>> fetchImages() async {
    var response = await http.get(
      Uri.parse('$apiUrl/curated?page=1&per_page=60'),
      headers: {
        'Authorization': apiKey,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['photos'];
    } else {
      throw Exception('Failed to load images');
    }
  }

  Future<List<dynamic>> searchImages(String query,
      {int perPage = 60, int page = 1}) async {
    final url = Uri.parse('https://api.pexels.com/v1/search');

    var response = await http.get(
      url.replace(queryParameters: {
        'query': query,
        'per_page': perPage.toString(),
        'page': page.toString(),
      }),
      headers: {'Authorization': apiKey},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['photos'];
      /*
      List<String> imageUrls = [];

      for (var photo in data['photos']) {
        imageUrls.add(photo['src']['original']);
      }
      */
      //return imageUrls;
    } else {
      throw Exception('Failed to load images');
    }
  }
}
