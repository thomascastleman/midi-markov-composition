import themidibus.*;

MidiBus bus;  // midibus interface

// at home ypg-625
static final int MINPITCH = 21;
static final int MAXPITCH = 108;
static final int CHANNEL = 0;

static final int MAXVELOCITY = 127;  // seems to be 127 for some reason

boolean listening = true;

ArrayList<DistilledSlice> slices = new ArrayList<DistilledSlice>();  // all slices to be analyzed
DistilledSlice currentSlice;  // current slice being played

// hashmap of raw pitch values to all possible DistilledSlice successors
HashMap<ArrayList<RawPitch>, ArrayList<DistilledSlice>> nextSlice = new HashMap<ArrayList<RawPitch>, ArrayList<DistilledSlice>>();
// number of slices in an n-gram
int ngram = 3;

void setup() {
  size(300, 300);
  
  MidiBus.list();  // list available midi devices
  bus = new MidiBus(this, 0, 3);
  
  currentSlice = new DistilledSlice(0, new int[MAXPITCH - MINPITCH + 1]);
 
  
}

void draw() {
  currentSlice.duration++;  // increment age of current slice, always
  
  //debug
  if (frameCount > 500) {
    println("FINISHED LISTENING");
    listening = false;
    noLoop();
    
    DistilledSlice[] s = castToArray(slices);
    for (DistilledSlice sl : s) {
      logArray(sl.pitchValues);
      println(sl.duration);
    }
    playBack(s);
    
  }
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
  return new DistilledSlice((int) s.duration, copyArray(s.pitchValues));
}

// get pitch index from a given pitch value
int scaleToPitchIndex(int pitch) {
  return pitch - MINPITCH;
}
// get pitch from a pitch index 
int scaleFromPitchIndex(int index) {
  return index + MINPITCH;
}

// MIDI INPUT FUNCTIONS:
void noteOn(int c, int p, int v) {
  if (listening) {
    
    // dbeug
    println(currentSlice.duration);
    
    currentSlice.pitchValues[scaleToPitchIndex(p)] = v;  // update current slice to reflect new note
    currentSlice.numPitches++;
    
    // debug
    logArray(currentSlice.pitchValues);
    
    
    // update slice at pitch position to reflect note activation
    slices.add(copySlice(currentSlice));  // add copy of previous slice to slices
    
    currentSlice.duration = 1;  // reset duration
  }
}

void noteOff(int c, int p, int v) {
  if (listening) {
    
    // debug 
    println(currentSlice.duration);
    
    currentSlice.pitchValues[scaleToPitchIndex(p)] = 0;  // reset note to 0
    currentSlice.numPitches--;
    
    // if not just empty space
    if (currentSlice.numPitches > 0) {
      logArray(currentSlice.pitchValues);
      
      // update slice at pitch position to reflect note deactivation
      slices.add(copySlice(currentSlice));  // add copy of previous slice to slices
    }
    
    currentSlice.duration = 1;  // reset duration
  }
}

// MARKOV CHAIN FUNCTIONS:

// train on slices[], populate nextSlice
void train() {
  
}

DistilledSlice[] compose() {
  return new DistilledSlice[0];
}

// AUDIO PLAYBACK

void playBack(DistilledSlice[] distSlices) {
  DistilledSlice previous = null;
  DistilledSlice next = null;
  DistilledSlice current = null;
  
  // for each slice
  for (int i = 0; i < distSlices.length; i++) {
    if (i > 0) {
      previous = distSlices[i - 1];
    }
    if (i < distSlices.length - 1) {
      next = distSlices[i + 1];
    }
    
    current = distSlices[i];
    
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
    
    if (next != null) {
      int scale = 200;
      println("Sustaining for " + next.duration + scale);
      delay(next.duration + scale);
      println("Finished sustaining");
    }
  }
  
}

void delay(int time) {
  int current = millis();
  while (millis () < current+time) Thread.yield();
}