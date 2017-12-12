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