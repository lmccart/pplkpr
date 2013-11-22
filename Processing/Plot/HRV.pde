float SDNN(List<Float> list) {
  return standardDeviation(list); //<>//
}

float RMSSD(List<Float> list) {
  return sqrt(sum(sq(successiveDifferences(list))));
}

float SDSD(List<Float> list) {
  return standardDeviation(successiveDifferences(list));
}

float NN50(List<Float> list) {
  return countGreater(successiveDifferences(list), 50);
}

float pNN50(List<Float> list) {
  return countGreater(successiveDifferences(list), 50) / (float) list.size();
}

float NN20(List<Float> list) {
  return countGreater(successiveDifferences(list), 20);
}

float pNN20(List<Float> list) {
  return countGreater(successiveDifferences(list), 20) / (float) list.size();
}

float EBC(List<Float> list) {
  return range(list);
}
