

// MARKOV CHAIN FUNCTIONS

// remove intermediate negligible silences to allow training
ArrayList<DistilledSlice> trimSliceData(ArrayList<DistilledSlice> rawSlices) {
  ArrayList<DistilledSlice> trimmed = new ArrayList<DistilledSlice>();
  
  for (DistilledSlice s : rawSlices) {   
    // include non-silences AND all silences above a certain duration
    if (s.numPitches != 0 || s.duration > MIN_DURATION) {
      trimmed.add(s);
    }
  }
  return trimmed;
}

void train(ArrayList<DistilledSlice> trainingData) {
  ArrayList<RawPitch> keyArray;
  ArrayList<DistilledSlice> valueArray;
  
  for (int i = 0; i < trainingData.size(); i++) {
    
    
    
  }
  
  
  
}


DistilledSlice[] compose() {
  return new DistilledSlice[0];
}