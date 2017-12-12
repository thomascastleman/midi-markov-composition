
// MIDI INPUT FUNCTIONS:

// when note on received
void noteOn(int c, int p, int v) {
  if (listening) {
    
    // debug
    println("Note @ pitch " + p);  

    // add copy of previous slice to slices (now that duration has been recorded)
    slices.add(copySlice(currentSlice));
    
    // update current slice to reflect new note addition
    currentSlice.pitchValues[scaleToPitchIndex(p)] = v;
    currentSlice.numPitches++;
    currentSlice.duration = 0;    // reset duration, because new slice
  }
}

// when note off received
void noteOff(int c, int p, int v) {
  if (listening) {
      
      slices.add(copySlice(currentSlice));  // add copy of previous slice to slices
      
      // update slice to reflect note deactivation
      currentSlice.pitchValues[scaleToPitchIndex(p)] = 0;  // reset note to 0
      currentSlice.numPitches--;
      currentSlice.duration = 0;  // reset duration
      
      lastNoteOff = frameCount;    // record last note off at current frame count
  }
}