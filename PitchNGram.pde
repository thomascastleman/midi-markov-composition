

class PitchNGram {
    
    int[][] pitchValueSlices;
    int hash;
   
    PitchNGram(int[][] values) {
        this.pitchValueSlices = values;
        this.hash = this.hashCode();
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
    
    public boolean equals(Object obj) {
        PitchNGram casted = (PitchNGram) obj;
        return casted.hash == this.hash;
    }
    
    
}