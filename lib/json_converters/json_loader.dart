
import 'dart:convert';

import 'package:flutter/cupertino.dart';

class JsonLoader {
  Future<Map> getJson(BuildContext context, String path, {String? errorMessage}) async {
    String data = await DefaultAssetBundle.of(context).loadString(path);
    final jsonResult = jsonDecode(data);
    if(jsonResult is Map){
      return jsonResult;
    } else {
      throw Exception(errorMessage ?? "Failed to load json at $path");
    }
  }
}