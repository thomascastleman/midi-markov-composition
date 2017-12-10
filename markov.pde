

// MARKOV CHAIN FUNCTIONS

void train(ArrayList<DistilledSlice> trainingData) {
  ArrayList<RawPitch> keyArray = new ArrayList<RawPitch>();
  
  // for all training data
  for (int i = 0; i < trainingData.size() - ngram; i++) {
    // get n-gram
    ArrayList<DistilledSlice> gram = new ArrayList<DistilledSlice>(trainingData.subList(i, i + ngram));
    
    // convert slices to raw pitch objects
    for (DistilledSlice s : gram) {
        keyArray.add(distilledToRawPitch(s));
    }
    
    // get value following ngram
    DistilledSlice value = trainingData.get(i + ngram);
    
    // if no entry exists
    if (nextSlice.get(keyArray) == null) {
        // make new entry with empty list
        ArrayList<DistilledSlice> valueArray = new ArrayList<DistilledSlice>();
        valueArray.add(value);
        nextSlice.put(keyArray, valueArray);
    } else {
        // update previous entry
        ArrayList<DistilledSlice> newValue = nextSlice.get(keyArray);
        newValue.add(value);
        nextSlice.put(keyArray, newValue);
    }
  }
  
  
  ArrayList<ArrayList<RawPitch>> keys = new ArrayList<ArrayList<RawPitch>>(nextSlice.keySet());
  
  for (ArrayList<RawPitch> rawList : keys) {
      println("Key: ");
      for (RawPitch r : rawList) {
          logArray(r.activatedPitches);
      }
      println("");
      print("Values: ");
      for (DistilledSlice s : nextSlice.get(rawList)) {
          logArray(s.pitchValues);
      }
  }
  
  
  
}


DistilledSlice[] compose() {
  return new DistilledSlice[0];
}