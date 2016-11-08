class runningAvg {
  int[] data;
  int total;
  float average;
  int pnter;
  int n;
  int dataPoints;
  

  // construtor - points must be at least 1 - the size of the data points to keep track of
  runningAvg(int points) {
    if( points < 1) points = 1;
    dataPoints = points;
    data = new int[points];
    total = 0;
    average = 0;
    n = 0;
    pnter = 0;
    // set data to 0
    for(int i=0;i<points;i++) {
      data[i] = 0;
    }
  }
  
  void addNewValue(int value) {
    total -= data[pnter];
    data[pnter] = value;
    total += value;
    pnter = ++pnter % data.length;
    if(n < data.length) n++;
    average = total / n;
  }
  
  int getMaxValue() {
    int max = data[0];
    for(int i=1; i<dataPoints; i++) {
      if( max < data[i] ) {
        max = data[1];
      }
    }
    return max;
  }
}

  