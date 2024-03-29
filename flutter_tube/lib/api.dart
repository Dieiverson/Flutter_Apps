import 'dart:convert';

import 'package:flutter_tube/models/video.dart';
import 'package:http/http.dart' as http;
const API_KEY = "AIzaSyCthZbtSZirFWLOkYY9MkOe6bgE6c-M4LA";

class Api{

  String _search;
  String _nextToken;

  Future<List<Video>> search(String search) async
  {
    _search = search;
    var url = Uri.parse("https://www.googleapis.com/youtube/v3/search?part=snippet&q=$search&type=video&key=$API_KEY&maxResults=10");
    http.Response response = await http.get(url);

    return decode(response);
  }

  Future<List<Video>> nextPage() async
    {
      var url = Uri.parse("https://www.googleapis.com/youtube/v3/search?part=snippet&q=$_search&type=video&key=$API_KEY&maxResults=10&pageToken=$_nextToken");
      http.Response response = await http.get(url);

      return decode(response);
    }


  List<Video> decode(http.Response response)
  {
    if(response.statusCode == 200){
        var decoded = json.decode(response.body);
        _nextToken = decoded["nextPageToken"];
        List<Video> videos = decoded["items"].map<Video>((map)
            {
              return Video.fromJson(map);
            }
        ).toList();
        return videos;
      }
    else
      {
        throw new Exception("Failed to load videos.");
      }
  }
}




