// http://circ.ahajournals.org/content/93/5/1043.full
// http://www.dantest.com/dt_hrv1.htm
// http://www.appliedmeditation.org/dome/201/stimulation/RSA
// http://physionet.org/tutorials/hrv-toolkit/

// http://knowledgetranslation.ca/sysrev/articles/project21/Ref%20ID%208067-20090628231006.pdf
// http://www2.le.ac.uk/departments/engineering/people/academic-staff/fernando-schlindwein/publications/A%20study%20on%20the%20optimum%20order_pm2208.pdf
// http://www.plosone.org/article/fetchObject.action?uri=info%3Adoi%2F10.1371%2Fjournal.pone.0037731&representation=PDF

// http://physionet.org/events/hrv-2006/course-materials.html

// stress causes sympathetic changes
// LF is sympathetic (or maybe also parasympathetic)
// HF is parasypathetic
// LF/HF ratio should vary wrt stress

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
