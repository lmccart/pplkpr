float noiseu(float t) {
  return noise(t) - .5;
}

float sum(List<Float> list) {
  float sum = 0;
  for(Float x : list) {
    sum += x;
  }
  return sum;
}

float mean(List<Float> list) {
  return sum(list) / list.size();
}

int countGreater(List<Float> list, float cutoff) {
  int count = 0;
  for(Float x : list) {
    if(x > cutoff) {
      count++;
    }
  }
  return count;
}

ArrayList<Float> sq(List<Float> list) {
  ArrayList<Float> results = new ArrayList<Float>();
  for(Float x : list) {
    results.add(x * x);    
  }
  return results;
}

float max(List<Float> list) {
  float max = Float.NEGATIVE_INFINITY;
  for(Float x : list) {
    if(x > max) {
      max = x;
    }
  }
  return max;
}

float min(List<Float> list) {
  float min = Float.POSITIVE_INFINITY;
  for(Float x : list) {
    if(x < min) {
      min = x;
    }
  }
  return min;
}

float range(List<Float> list) {
  return max(list) - min(list);
}

float standardDeviation(List<Float> list) {
  float mean = mean(list);
  return sqrt(sum(sq(differences(list, mean))) / mean);
}

ArrayList<Float> differences(List<Float> list, float subtrahend) {
  ArrayList<Float> results = new ArrayList<Float>();
  for(Float x : list) {
    results.add(x - subtrahend);
  }
  return results;
}

ArrayList<Float> successiveDifferences(List<Float> list) {
  ArrayList<Float> results = new ArrayList<Float>();
  Float prev = null;
  for(Float cur : list) {
    if(prev != null) {
      results.add(cur - prev);
    }
    prev = cur;
  }
  return results;
}
