

DistilledSlice[] castToArray(ArrayList<DistilledSlice> arr) {
  DistilledSlice[] copy = new DistilledSlice[arr.size()];
  for (int i = 0; i < arr.size(); i++) {
    copy[i] = arr.get(i);
  }
  return copy;
}

void logArray(int[] arr) {
  for (int i : arr) {
    print(i + " ");
  }
  println("");
}

// copy an integer array
int[] copyArray(int[] arr) {
  int[] copy = new int[arr.length];
  
  for (int i = 0; i < arr.length; i++) {
    copy[i] = arr[i];
  }
  return copy;
}

// make copy of distilled slice
DistilledSlice copySlice(DistilledSlice s) {
  DistilledSlice copy = new DistilledSlice((int) s.duration, copyArray(s.pitchValues));
  copy.numPitches = s.numPitches;
  return copy;
}

// convert frames to their duration in ms
float framesToMillis(int frames) {
  return frames * (1 / FPMS);
}

// get pitch index from a given pitch value
int scaleToPitchIndex(int pitch) {
  return pitch - MINPITCH;
}
// get pitch from a pitch index 
int scaleFromPitchIndex(int index) {
  return index + MINPITCH;
}

void delay(float time) {
  int current = millis();
  while (millis () < current+time) Thread.yield();
}