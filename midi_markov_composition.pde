import themidibus.*;

MidiBus bus;  // midibus interface

// at home ypg-625
static final int MINPITCH = 21;
static final int MAXPITCH = 108;

ArrayList<DistilledSlice> slices = new ArrayList<DistilledSlice>();
DistilledSlice currentSlice;

void setup() {
  size(300, 300);
  
  MidiBus.list();  // list available midi devices
  bus = new MidiBus(this, 0, 3);
  
  currentSlice = new DistilledSlice(0, new int[MAXPITCH - MINPITCH + 1]);
}

void draw() {
  currentSlice.duration++;  // increment age of current slice, always
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
  // update slice at pitch position to reflect note activation
  slices.add(copySlice(currentSlice));
  currentSlice.pitchValues[scaleToPitchIndex(p)] = v;
  currentSlice.duration = 1;
}

void noteOff(int c, int p, int v) {
  // update slice at pitch position back to 0
  slices.add(copySlice(currentSlice));
  currentSlice.pitchValues[scaleToPitchIndex(p)] = 0;
  currentSlice.duration = 1;
}