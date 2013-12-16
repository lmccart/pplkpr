import java.util.*;

Graph hrv, sdnn, rmssd, ebc, diffs;

int window = 15;
  
void setup() {
  size(1600, 400);
  hrv = new Graph();
  
  float offset = millis();
  for(int i = 0; i < 512; i++) {
    float x = 0;
    x += 1000; // 60 bpm
    x += noiseu(offset + i / 200.) * 200; // heart rate signal
    float raw = pow(noise(offset + i / 50.), 6); // raw hrv
    x += noiseu(offset + i / 2.) * raw * 400; // hrv signal
   //   hrv.add(x);
  }
  
  float[] all = float(loadStrings("rr.txt"));
  for(int i = 0; i < all.length; i++) {
    hrv.add(all[i]);
  }
  
  sdnn = new Graph();
  rmssd = new Graph();
  ebc = new Graph();
  for(int i = 0; i < hrv.size() - window; i++) {
    sdnn.add(SDNN(hrv.subList(i, i + window)));
    rmssd.add(RMSSD(hrv.subList(i, i + window)));
    ebc.add(EBC(hrv.subList(i, i + window)));
  }
  
  diffs = new Graph();
  ArrayList<Float> rawDiff = successiveDifferences(hrv);
  for(int i = 0; i < rawDiff.size(); i++) {
    diffs.add((float) rawDiff.get(i));
    println(rawDiff.get(i) + " " + diffs.minValue + " " + diffs.maxValue);
  }
  
  println("SDNN: " + SDNN(hrv));
  println("RMSSD: " + RMSSD(hrv));
  println("EBC: " + EBC(hrv));
  println("NN50: " + NN50(hrv));
  println("pNN50: " + pNN50(hrv));
  println("NN20: " + NN20(hrv));
  println("pNN20: " + pNN20(hrv));
  println();
  println(diffs.minValue + " " + diffs.maxValue);
}

void draw() {
  background(255);
  
  stroke(0);
//  hrv.drawPoincare(width, height);
  hrv.draw(width, height);
//  diffs.draw(width, height);
 
  translate(window / 2, 0);
  stroke(255, 0, 0);
  sdnn.draw(width - window, height);
  stroke(0, 255, 0);
  rmssd.draw(width - window, height);
  stroke(0, 0, 255);
  ebc.draw(width - window, height);
}

void mousePressed() {
  setup();
}
