import java.util.*;

Graph hrv, sdnn, rmssd, ebc;

void setup() {
  size(512, 256);
  hrv = new Graph();
  
  float offset = millis();
  for(int i = 0; i < 512; i++) {
    float x = 0;
    x += 1000; // 60 bpm
    x += noiseu(offset + i / 200.) * 200; // heart rate signal
    float raw = pow(noise(offset + i / 50.), 6); // raw hrv
    x += noiseu(offset + i / 2.) * raw * 400; // hrv signal
    hrv.add(x);
  }
  
  int window = 16;
  
  sdnn = new Graph();
  rmssd = new Graph();
  ebc = new Graph();
  for(int i = 0; i < hrv.size() - window; i++) {
    sdnn.add(SDNN(hrv.subList(i, i + window)));
    rmssd.add(RMSSD(hrv.subList(i, i + window)));
    ebc.add(EBC(hrv.subList(i, i + window)));
  }
  
  println("SDNN: " + SDNN(hrv));
  println("RMSSD: " + RMSSD(hrv));
  println("EBC: " + EBC(hrv));
  println("NN50: " + NN50(hrv));
  println("pNN50: " + pNN50(hrv));
  println("NN20: " + NN20(hrv));
  println("pNN20: " + pNN20(hrv));
  println();
}

void draw() {
  background(255);
  
  stroke(0);
  hrv.draw(width, height);
  hrv.drawPoincare(width, height);
  
  stroke(255, 0, 0);
  sdnn.draw(width, height);
  stroke(0, 255, 0);
  rmssd.draw(width, height);
  stroke(0, 0, 255);
  ebc.draw(width, height);
}

void mousePressed() {
  setup();
}
