

// remove intermediate negligible silences to allow training
ArrayList<DistilledSlice> trimSliceData(ArrayList<DistilledSlice> rawSlices) {
  ArrayList<DistilledSlice> trimmed = new ArrayList<DistilledSlice>();
  
  // remove initial silence if exists
  if (rawSlices.get(0).numPitches == 0) {
      rawSlices.remove(0);
  }
  
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
  s.numPitches = s.numPitches >= 0 ? s.numPitches : 0;
  int[] active = new int[s.numPitches];
  int index = 0;
  if (active.length > 0) {
      for (int p = 0; p < s.pitchValues.length; p++) {
        if (s.pitchValues[p] != 0) {
          active[index] = p;
          index++;
        }
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

// log int array to console horizontally
void logArray(int[] arr) {
  for (int i : arr) {
    print(i + " ");
  }
  println("");
}

// make a copy of a distilled slice object
DistilledSlice copySlice(DistilledSlice s) {
    return new DistilledSlice(s.duration, s.pitchValues.clone(), s.numPitches);
}

// get pitch index from a given pitch value
int scaleToPitchIndex(int pitch) {
  return pitch - MINPITCH;
}
// get pitch from a pitch index 
int scaleFromPitchIndex(int index) {
  return index + MINPITCH;
}

// convert frames to their duration in ms
float framesToMillis(int frames) {
  return (float) frames / FPMS;
}

// convert frames to duration in seconds
float framesToSeconds(int frames) {
    return (float) frames / frameRate;
}

// delay a given amount of time in ms
void delay(float time) {
  int current = millis();
  while (millis () < current+time) Thread.yield();
}

// send all notes off
void sendAllOff() {
    for (int p = MINPITCH; p <= MAXPITCH; p++) {
        bus.sendNoteOff(CHANNEL, p, 0);
    }
}

// audio playback
void playBack(ArrayList<DistilledSlice> distSlices) {
  DistilledSlice previous = null;
  DistilledSlice current = null;
  
  // for each slice
  for (int i = 0; i < distSlices.size(); i++) {
    if (i > 0) {
      previous = distSlices.get(i - 1);
    }
    
    current = distSlices.get(i); 
    
    for (int p = 0; p < current.pitchValues.length; p++) {
      // if previously inactive, but now active
      if (current.pitchValues[p] != 0 && (previous == null || previous.pitchValues[p] == 0)) {
        bus.sendNoteOn(CHANNEL, scaleFromPitchIndex(p), current.pitchValues[p]);
      }
      // if previously active, but now inactive
      if (current.pitchValues[p] == 0 && (previous != null && previous.pitchValues[p] != 0)) {
        bus.sendNoteOff(CHANNEL, scaleFromPitchIndex(p), 0);
      }
    }
    
    delay(framesToMillis(current.duration));
  }
  
  // end last slice
  DistilledSlice last = distSlices.get(distSlices.size() - 1);
  for (int p = 0; p < last.pitchValues.length; p++) {
    if (last.pitchValues[p] != 0) {
      bus.sendNoteOff(CHANNEL, scaleFromPitchIndex(p), 0);
    }
  }
  
}