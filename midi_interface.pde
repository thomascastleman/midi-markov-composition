

// MIDI INPUT FUNCTIONS:


void noteOn(int c, int p, int v) {
  if (listening) {
    
    // debug
    println(currentSlice.duration);
    
    // update slice at pitch position to reflect note activation
    slices.add(copySlice(currentSlice));  // add copy of previous slice to slices
    
    currentSlice.pitchValues[scaleToPitchIndex(p)] = v;  // update current slice to reflect new note
    currentSlice.numPitches++;
    
    // debug
    logArray(currentSlice.pitchValues);
    
    
    currentSlice.duration = 0;  // reset duration
  }
}

void noteOff(int c, int p, int v) {
  if (listening) {
    
    // debug 
    println(currentSlice.duration);
    
    // if not just empty space
    if (currentSlice.numPitches > 0) {
      logArray(currentSlice.pitchValues);
      
      // update slice at pitch position to reflect note deactivation
      slices.add(copySlice(currentSlice));  // add copy of previous slice to slices
    }
    
    currentSlice.pitchValues[scaleToPitchIndex(p)] = 0;  // reset note to 0
    currentSlice.numPitches--;
    
    
    currentSlice.duration = 0;  // reset duration
  }
}