import themidibus.*;

MidiBus bus;  // midibus interfacew

// at home ypg-625
static final int MINPITCH = 21;
static final int MAXPITCH = 108;
static final int CHANNEL = 0;

static final int MAXVELOCITY = 127;  // seems to be 127 for some reason

static final int FRAMERATE = 60;
static final float FPMS = (float) FRAMERATE / 1000.0; // frames per millisecond

static final int MIN_DURATION = 0; //50;  // min duration for silences

boolean listening = true;

ArrayList<DistilledSlice> slices = new ArrayList<DistilledSlice>();  // all slices to be analyzed
DistilledSlice currentSlice;  // current slice being played

// hashmap of raw pitch values to all possible DistilledSlice successors
HashMap<PitchNGram, ArrayList<DistilledSlice>> map = new HashMap<PitchNGram, ArrayList<DistilledSlice>>();

// number of slices in an n-gram
int ngram = 2;

void setup() {
  size(300, 300);
  frameRate(FRAMERATE);
  
  MidiBus.list();  // list available midi devices
  bus = new MidiBus(this, 0, 3);
  
  // init current slice
  currentSlice = new DistilledSlice(0, new int[MAXPITCH - MINPITCH + 1]);
  
}




void draw() {
  currentSlice.duration++;  // increment age of current slice, always
  
  //debug
  if (frameCount > 3000 && listening == true) {
    listening = false;
    noLoop();
    
    // trim slices
    ArrayList<DistilledSlice> trimmed = trimSliceData(slices);
    
    println("\nTRAINING DATA:");
    for (DistilledSlice sl : trimmed) {
        logArray(sl.pitchValues);
    }
    
    // train on data
    train(trimmed);
    
    // generate composition
    print("Composing... ");
    ArrayList<DistilledSlice> comp = compose(300, trimmed);
    println("Complete");
    
    print("Playing back... ");
    playBack(comp);
    println("Complete");
  }
}

// AUDIO PLAYBACK
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