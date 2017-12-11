

// remove intermediate negligible silences to allow training
ArrayList<DistilledSlice> trimSliceData(ArrayList<DistilledSlice> rawSlices) {
  ArrayList<DistilledSlice> trimmed = new ArrayList<DistilledSlice>();
  
  for (DistilledSlice s : rawSlices) {   
    // include non-silences AND all silences above a certain duration (cut out negligible silences)
    if (s.numPitches != 0 || s.duration > MIN_DURATION) {
      trimmed.add(s);
    }
  }
  return trimmed;
}

// convert distilled slice to an array of only the activated pitch values (for hashmap)
int[] distilledToPitchArray(DistilledSlice s) {
  int[] active = new int[s.numPitches];
  int index = 0;
  for (int p = 0; p < s.pitchValues.length; p++) {
    if (s.pitchValues[p] != 0) {
      active[index] = p;
      index++;
    }
  }
  return active;
}

// convert an n-gram of distilled slices to a single pitchngram object for hashmap lookup
PitchNGram slicesToPitchNGram(ArrayList<DistilledSlice> gram) {
    int[][] values = new int[ngram][];
    for (int i = 0; i < gram.size(); i++) {
        values[i] = distilledToPitchArray(gram.get(i));
    }
    return new PitchNGram(values);
}

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