

class PitchNGram {
    // each sub array contains pitch values of all activated pitches during that slice
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