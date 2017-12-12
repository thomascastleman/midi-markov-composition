import themidibus.*;

MidiBus bus;  // midibus interfacew

// keyboard-specific constants:
// at home ypg-625
static final int MINPITCH = 21;
static final int MAXPITCH = 108;
static final int CHANNEL = 0;

// time constants:
static final int FRAMERATE = 60;
static final float FPMS = (float) FRAMERATE / 1000.0; // frames per millisecond
static final float PAUSETIME = 5.0;    // time in seconds between last input received and beginning of composition
static final int MIN_DURATION = 0; //50;  // min duration for silences

ArrayList<DistilledSlice> slices = new ArrayList<DistilledSlice>();  // all slices to be analyzed
DistilledSlice currentSlice;  // current slice being played

// hashmap of raw pitch values to all possible DistilledSlice successors
HashMap<PitchNGram, ArrayList<DistilledSlice>> map = new HashMap<PitchNGram, ArrayList<DistilledSlice>>();

boolean cumulative = false;    // is midi data left in hashmap across playing sessions
boolean listening = true; // is the program listening for MIDI input
int ngram = 3;    // number of slices in an n-gram
int lastNoteOff = 0;    // the frameCount value @ the last note released

void setup() {
  size(300, 300);
  frameRate(FRAMERATE);
  
  MidiBus.list();  // list available midi devices
  println("");
  
  bus = new MidiBus(this, 0, 3);    // init bus
  
  // init current slice
  currentSlice = new DistilledSlice(0, new int[MAXPITCH - MINPITCH + 1]);
  
  println("N-gram: " + ngram);
  println("Cumulative training: " + cumulative);
  println("Ready for MIDI input");
  
}

void draw() {
    
    currentSlice.duration++; // increment age of current slice, always
    
    // if pause since last note long enough
    if (currentSlice.numPitches == 0 && framesToSeconds(frameCount - lastNoteOff) > PAUSETIME && slices.size() > 0) {
        println("Listening deactivated");
        listening = false;    // deactivate listening
        
        println("Running Markov Chain...");
        runMarkov();    // run markov chain on MIDI data
        
        // reset slices and current slice
        slices.clear();
        currentSlice.duration = 0;
        // clear hashmap if not cumulative
        if (!cumulative) {
            map.clear();
        }
        
        // send all notes off
        sendAllOff();
        
        println("Listening resumed");
        listening = true;    // activate listening again
    }
}

// run all markov chain functions
void runMarkov() {
    // trim slice data
    ArrayList<DistilledSlice> trimmed = trimSliceData(slices); //  maybe not necessary??
    
    // train on trimmed version
    print("Training... ");
    train(trimmed);
    println("Complete");
    
    // compose (same length as input)
    print("Composing... ");
    ArrayList<DistilledSlice> comp = compose(trimmed.size(), trimmed);
    println("Complete");
    println("Composition length: " + comp.size() + " slices");
    
    // play back composition
    print("Playing back... ");
    playBack(comp);
    println("Complete");
}