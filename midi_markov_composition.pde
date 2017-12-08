import themidibus.*;

MidiBus bus;  // midibus interface

// at home ypg-625
static final int MINPITCH = 21;
static final int MAXPITCH = 108;
static final int CHANNEL = 0;

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
  
  // debug 
  println(currentSlice.pitchValues);
}

// make copy of distilled slice
DistilledSlice copySlice(DistilledSlice s) {
  return new DistilledSlice(s.duration, s.pitchValues);
}

// get pitch index from a given pitch value
int scaleToPitchIndex(int pitch) {
  return pitch - MINPITCH;
}

// MIDI INPUT FUNCTIONS:
void noteOn(int c, int p, int v) {
  if (listening) {
    // update slice at pitch position to reflect note activation
    slices.add(copySlice(currentSlice));  // add copy of previous slice to slices
    currentSlice.pitchValues[scaleToPitchIndex(p)] = v;  // update current slice to reflect new note
    currentSlice.duration = 1;  // reset duration
  }
}

void noteOff(int c, int p, int v) {
  if (listening) {
    // update slice at pitch position back to 0
    slices.add(copySlice(currentSlice));  // add copy of previous to slices
    currentSlice.pitchValues[scaleToPitchIndex(p)] = 0;  // reset note to 0
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
  DistilledSlice slice;
  for (int i = 0; i < distSlices.length; i++) {
    slice = distSlices[i];
    
    if (i > 0) {
      previous = distSlices[i - 1];
      
      for (int p = 0; p < slice.pitchValues.length; p++) {
        // if note now off
        if (slice.pitchValues[p] == 0 && previous.pitchValues[p] != 0) {
          bus.sendNoteOff(CHANNEL, p, 0);
        }
      }
      
    }
    
    for (int p = 0; p < slice.pitchValues.length; p++) {
        if (slice.pitchValues[p] != 0 && (previous == null || previous.pitchValues[p] == 0)) {
          bus.sendNoteOn(CHANNEL, p, slice.pitchValues[p]);
        }
    }
    delay(slice.duration);
    
  }
  
}

void delay(int time) {
  int current = millis();
  while (millis () < current+time) Thread.yield();
}