

// MARKOV CHAIN FUNCTIONS

void train(ArrayList<DistilledSlice> trainingData) {
  ArrayList<DistilledSlice> gram;
  
  // for all training data
  for (int i = 0; i < trainingData.size(); i++) {
    
    if (i < trainingData.size() - ngram) {
        // get n-gram
        gram = new ArrayList<DistilledSlice>(trainingData.subList(i, i + ngram));
    } else {
        // wrap around to beginning of slices
       gram = new ArrayList<DistilledSlice>(trainingData.subList(i, trainingData.size()));
        int remaining = ngram - gram.size();
        gram.addAll(new ArrayList<DistilledSlice>(trainingData.subList(0, remaining)));
    }
    
    // convert slices to raw pitch values
    int[][] pitches = new int[ngram][];
    for (int j = 0; j < ngram; j++) {
        pitches[j] = distilledToPitchArray(gram.get(j));
    }
    
    // create key for hashmap
    PitchNGram k = new PitchNGram(pitches);

    // get value following ngram
    DistilledSlice value;
    if (i < trainingData.size() - ngram) {
        value = trainingData.get(i + ngram);
    } else {
        // wrap around once again
        value = trainingData.get((i +  ngram) % trainingData.size());
    }
    
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
}

// compose a new series of slices of a given length
ArrayList<DistilledSlice> compose(int slices, ArrayList<DistilledSlice> training) {
    // get random ngram sequence from training data to start of composition
    int rand = (int) (Math.random() * (training.size() - ngram));
    ArrayList<DistilledSlice> composition = new ArrayList<DistilledSlice>(training.subList(rand, rand + ngram));

    // for given composition length
    for (int i = 0; i < slices; i++) {
        // get last ngram as pitchngram object
        PitchNGram gram = slicesToPitchNGram(new ArrayList<DistilledSlice>(composition.subList(composition.size() - ngram, composition.size())));
        
        // get all possible following slices
        ArrayList<DistilledSlice> possibleFollowing = map.get(gram);

        // add random slice to composition
        rand = (int) (Math.random() * possibleFollowing.size());
        composition.add(possibleFollowing.get(rand));
    }

    return composition;
}