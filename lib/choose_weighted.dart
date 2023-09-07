import 'dart:math';

dynamic chooseWeighted(Map<dynamic, num> selectionMap){
  var sumOfValues = 0.0;
  for(var value in selectionMap.values){
    sumOfValues += value;
  }
  var rng = Random();
  var score = rng.nextDouble()*sumOfValues;
  var currentItem;
  selectionMap.forEach((key, value) {
    score -= value;
    if(score <= 0 && currentItem == null){
      currentItem = key;
    }
  });
  return currentItem;
}