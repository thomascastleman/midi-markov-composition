
// handles critical info of a slice from the distilled format
class DistilledSlice {
  
  int duration;
  int[] pitchValues;
  
  DistilledSlice(int _duration, int[] _pitchValues) {
    this.duration = _duration;
    this.pitchValues = _pitchValues;
  }
  
}