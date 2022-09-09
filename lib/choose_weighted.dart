import 'dart:math';

dynamic chooseWeighted(Map<dynamic, num> selectionMap){
  var sumOfValues = selectionMap.values.reduce((a, b) => a + b);
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