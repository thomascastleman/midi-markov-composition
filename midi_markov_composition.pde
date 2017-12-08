import themidibus.*;

MidiBus bus;  // midibus interface

// at home ypg-625
static final int MINPITCH = 21;
static final int MAXPITCH = 108;
static final int CHANNEL = 0;

static final int MAXVELOCITY = 127;  // seems to be 127 for some reason

static final int FRAMERATE = 60;
static final float FPMS = 0.06; // frames per millisecond

boolean listening = true;

ArrayList<DistilledSlice> slices = new ArrayList<DistilledSlice>();  // all slices to be analyzed
DistilledSlice currentSlice;  // current slice being played

// hashmap of raw pitch values to all possible DistilledSlice successors
HashMap<ArrayList<RawPitch>, ArrayList<DistilledSlice>> nextSlice = new HashMap<ArrayList<RawPitch>, ArrayList<DistilledSlice>>();
// number of slices in an n-gram
int ngram = 3;

void setup() {
  size(300, 300);
  frameRate(FRAMERATE);
  
  MidiBus.list();  // list available midi devices
  bus = new MidiBus(this, 0, 3);
  
  currentSlice = new DistilledSlice(0, new int[MAXPITCH - MINPITCH + 1]);
 
  
}

void draw() {
  currentSlice.duration++;  // increment age of current slice, always
  
  //debug
  if (frameCount > 500 && listening == true) {
    println("FINISHED LISTENING");
    listening = false;
    
    DistilledSlice[] s = castToArray(slices);
    for (DistilledSlice sl : s) {
      logArray(sl.pitchValues);
      println(sl.duration);
    }
    playBack(s);
    
  }
}

// AUDIO PLAYBACK

void playBack(DistilledSlice[] distSlices) {
  DistilledSlice previous = null;
  DistilledSlice current = null;
  
  // for each slice
  for (int i = 0; i < distSlices.length; i++) {
    if (i > 0) {
      previous = distSlices[i - 1];
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
    
    delay(framesToMillis(current.duration));
  }
  // STILL NEED TO SEND OFF FOR THE LAST SLICE
}