

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

ArrayList<DistilledSlice> compose(int slices, ArrayList<DistilledSlice> training) {
    // get random ngram sequence from training data to start of composition
    int rand = (int) (Math.random() * (training.size() - ngram));
    ArrayList<DistilledSlice> composition = new ArrayList<DistilledSlice>(training.subList(rand, rand + ngram));

    // for given composition length
    for (int i = 0; i < slices; i++) {
        // get last ngram as pitchngram object
        PitchNGram gram = slicesToPitchNGram(new ArrayList<DistilledSlice>(composition.subList(composition.size() - ngram, composition.size())));
        
        
        // DEBUGE
        println("NGRAM: ");
        for (int[] arr : gram.pitchValueSlices) {
            logArray(arr);
        }
        
        
        // get all possible following slices
        ArrayList<DistilledSlice> possibleFollowing = map.get(gram);
        
        
        // DEBUGE
        println("POSSIBLE SUCCESSORS: ");
        for (DistilledSlice s : possibleFollowing) {
            logArray(s.pitchValues);
        }
        
        // add random slice to composition
        rand = (int) (Math.random() * possibleFollowing.size());
        composition.add(possibleFollowing.get(rand));
        
        println("CHOOSING: ");
        logArray(possibleFollowing.get(rand).pitchValues);
    }

    return composition;
}