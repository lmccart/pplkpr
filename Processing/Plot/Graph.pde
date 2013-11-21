class Graph extends ArrayList<Float> {
  float maxValue, minValue;
  Graph() {
    this.maxValue = Float.NEGATIVE_INFINITY;
    this.minValue = Float.POSITIVE_INFINITY;
  }
  void add(float value) {
    if(value == Float.NEGATIVE_INFINITY ||
      value == Float.POSITIVE_INFINITY ||
      value != value)
      return;
    if(value > maxValue)
      maxValue = value;
    if(value < minValue)
      minValue = value;
    super.add(value);
  }
  float normalize(float x) {
    return constrain(norm(x, minValue, maxValue), 0, 1);
  }
  float getNorm(int i) {
    return normalize(get(i));
  }
  void draw(int width, int height) {
    noFill();
    beginShape();
    for(int i = 0; i < size(); i++) {
      vertex(map(i, 0, size() - 1, 0, width), height - getNorm(i) * height);
    }
    endShape();
    
//    fill(0);
//    textAlign(RIGHT, TOP);
//    text(nf(maxValue, 0, 0), width - 10, 10);
//    textAlign(RIGHT, BOTTOM);
//    text(nf(minValue, 0, 0), width - 10, height - 10);
  }
  void drawPoincare(int width, int height) {
    for(int i = 0; i < size() - 1; i++) {
      point(getNorm(i) * width, height - getNorm(i + 1) * height);
    }
  }
  void save(String filename) {
    String[] out = new String[size()];
    for(int i = 0; i < size(); i++) 
      out[i] = nf(get(i), 0, 0);
    saveStrings(filename + ".csv", out);
  }
}
