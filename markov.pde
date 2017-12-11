

// MARKOV CHAIN FUNCTIONS

void train(ArrayList<DistilledSlice> trainingData) {
  
  // for all training data
  for (int i = 0; i < trainingData.size() - ngram; i++) {
    
    // get n-gram
    ArrayList<DistilledSlice> gram = new ArrayList<DistilledSlice>(trainingData.subList(i, i + ngram));
    
    // convert slices to raw pitch values
    int[][] pitches = new int[ngram][];
    for (int j = 0; j < ngram; j++) {
        pitches[j] = distilledToPitchArray(gram.get(j));
    }
    
    // create key for hashmap
    PitchNGram k = new PitchNGram(pitches);

    // get value following ngram
    DistilledSlice value = trainingData.get(i + ngram);
    
    // if no entry exists
    if (map.get(k) == null) {
        // make new entry with empty list
        ArrayList<DistilledSlice> valueArray = new ArrayList<DistilledSlice>();
        valueArray.add(value);
        map.put(k, valueArray);
    } else {
        // update previous entry
        ArrayList<DistilledSlice> newValue = map.get(k);
        newValue.add(value);
        map.put(k, newValue);
    }
  }
  
  ArrayList<PitchNGram> keys = new ArrayList<PitchNGram>(map.keySet());
  
  for (PitchNGram ngram : keys) {
      println("key: ");
      for (int[] arr : ngram.pitchValueSlices) {
          logArray(arr);
      }
      println("values: ");
      for (DistilledSlice s : map.get(ngram)) {
          logArray(s.pitchValues);
      }
  }
  
  
}


DistilledSlice[] compose() {
  return new DistilledSlice[0];
}