import themidibus.*;

MidiBus bus;  // midibus interface

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
  
  currentSlice = new DistilledSlice(0, new int[MAXPITCH - MINPITCH + 1]);
  
  
  
  
  //// DBUG -------------------------------------------------------------------
  
  //int[][] t1 = new int[3][];
  //t1[0] = new int[]{0, 1, 2};
  //t1[1] = new int[]{3, 2};
  //t1[2] = new int[]{5, 4, 6};
  
  //int[][] t2 = new int[3][];
  //t2[0] = new int[]{0, 1, 2};
  //t2[1] = new int[]{3, 2};
  //t2[2] = new int[]{5, 4, 6};
  
  //HashMap<PitchNGram, ArrayList<Integer>> map = new HashMap<PitchNGram, ArrayList<Integer>>();
  
  //PitchNGram test1 = new PitchNGram(t1);
  //PitchNGram test2 = new PitchNGram(t2);
  
  //println("test 1");
  //for (int[] arr : test1.pitchValueSlices) {
  //    logArray(arr);
  //}
  //println("Hash: " + test1.hashCode());
  
  //println("test 2");
  //for (int[] arr : test2.pitchValueSlices) {
  //    logArray(arr);
  //}
  //println("Hash: " + test2.hashCode());
  
  
  //ArrayList<Integer> value = new ArrayList<Integer>();
  //value.add(12);
  //map.put(test1, value);
  
  //println(map.get(test1));
  //println(map.get(test2));
  
  //ArrayList<Integer> newVal = map.get(test2);
  //newVal.add(132);
  //map.put(test1, newVal);
  
  //println(map.get(test1));
  //println(map.get(test2));
  
}

void draw() {
  currentSlice.duration++;  // increment age of current slice, always
  
  //debug
  if (frameCount > 3000 && listening == true) {
    println("FINISHED LISTENING");
    listening = false;
    
    noLoop();
    
    // convert to prim array for playback
    // DistilledSlice[] s = castToArray(slices);
    // playBack(s);
    
    // trim slices
    println("\n\nTRIMMING");
    ArrayList<DistilledSlice> trimmed = trimSliceData(slices);
    
    println("\nTRAINING DATA:");
    for (DistilledSlice sl : trimmed) {
        logArray(sl.pitchValues);
    }
    
    // train on data
    train(trimmed);
    
    // debug
    println("Training pitch sequence");
    for (DistilledSlice sl : trimmed) {
        logArray(distilledToPitchArray(sl));
    }
    
    
    println("COMPOSIING...");
    // generate composition
    ArrayList<DistilledSlice> comp = compose(300, trimmed);
    println("Complete");
    
    println("PLAYING BACK");
    playBack(castToArray(comp));
    println("Finishd playing back");
    
    
    
    
    
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
  
  // end last slice
  DistilledSlice last = distSlices[distSlices.length - 1];
  for (int p = 0; p < last.pitchValues.length; p++) {
    if (last.pitchValues[p] != 0) {
      bus.sendNoteOff(CHANNEL, scaleFromPitchIndex(p), 0);
    }
  }
  
}