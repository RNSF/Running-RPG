import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class SaveDataHandler {
  var _data = <String, dynamic>{};


  Future<void> loadData() async {
    var file = await getFile();
    if(file == null) {return null;}
    if(await file.exists()){
      var dataString = await file.readAsString();
      _data = jsonDecode(dataString);
    }
  }

  Future<void> saveData() async {
    var stringData = jsonEncode(_data);
    var file = await getFile(create: true);
    if(file == null) {return null;}
    file.createSync();
    file.writeAsString(stringData);
  }

  Future<File?> getFile({bool create = false}) async {
    final directory = await getExternalStorageDirectory();
    if(directory == null) {return null;}
    var file = File(directory.path+"/save_data.json");
    if(create && !await file.exists()){
      file = await File(directory.path+"/save_data.json").create(recursive: true);
    }
    return file;
  }

  Map<String, dynamic>? findMap(List<String> keys){
    Map<String, dynamic>? map = _data;
    for(var key in keys){
      map = map?[key];
      if(map == null){return null;}
    }
    return map;
  }

  void updateMap(List<String> keys, Map<String, dynamic> newData, {bool override = false}){
    Map<String, dynamic> map = _data;
    for(var key in keys){
      if(map[key] == null){ map[key] = <String, dynamic>{}; }
      map = map[key];
    }
    if(override){ map.clear(); }
    map.addAll(newData);
  }
}

