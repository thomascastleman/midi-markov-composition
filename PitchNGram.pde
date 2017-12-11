

class PitchNGram {
    
    int[][] pitchValueSlices;
   
    PitchNGram(int[][] values) {
        this.pitchValueSlices = values;
    }
    
    // override hashcode function to be value-based for use in hashmap
    public int hashCode() {
        int sum = 0;
        for (int[] slice : pitchValueSlices) {
            for (int pitch : slice) {
                sum += pitch;
            }
        }
        return sum;
    }
    
    
}