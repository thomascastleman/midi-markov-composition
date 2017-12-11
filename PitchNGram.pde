

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
    
    //public boolean equals(Object obj) {
    //    PitchNGram casted = (PitchNGram) obj;
    //    return casted.hash == this.hash;
    //}
    
    // value-by-value comparison to ensure actual equality (expensive)
    public boolean equals(Object obj) {
        PitchNGram casted = (PitchNGram) obj;
        
        int[][] pitchVals = casted.pitchValueSlices;
        for (int s = 0; s < pitchVals.length; s++) {
            if (pitchVals[s].length != this.pitchValueSlices[s].length) {
                return false;
            } else {
                for (int p = 0; p < pitchVals[s].length; p++) {
                    if (pitchVals[s][p] != this.pitchValueSlices[s][p]) {
                        return false;
                    }
                }
            }
        }
        
        return true;
        
    }
    
    
}