void generateFakeData() {
  int minVal = 0;
  int maxVal = 1024;
  int maxJump = 300;
  int value = 0;

  for (int id=1; id<5; id++) {
    if ( fakeData[id] == 1 ) {
      value = fakeDataValue[id];
      int jump = int(random(maxJump));

      if (weightedJumpDirection( value ) == 1) {
        value += jump;
        if (value > maxVal) {
          value = maxVal;
        }
      } else {
        value -= jump;
        if (value < minVal) {
          value = minVal;
        }
      }

      fakeDataValue[id] = value;
      rawEMG[id] = value;
      
      // keep tracking of the running average
        switch(emgID) {
        case 1:
          emg1ravg.addNewValue(value);
          break;
        case 2:
          emg2ravg.addNewValue(value);
          break;
        case 3:
          emg3ravg.addNewValue(value);
          break;
        case 4:
          emg4ravg.addNewValue(value);
          break;
        default:
          // do nothing yet
          break;
        }
      
      // If we are in burst mode do not set the motor here
      if ( motorMode != 2 ) {
        motorEvent(id, value);
      }

      //println(getCurrentTimestamp() + " " + id + ":" + value);
      delay(100);
    }
  }
}

// return 1 (up) or 0 (down) depending on the seed and the previous value
// the higher the value the more likely it is to go down
int weightedJumpDirection( int value ) {
  int seed = int(random(20));
  
  int convertedValue = int(map(value, 0, 1024, 0, 20));
  if ( convertedValue < 400 ) {
    // if the value is low it is more likely to stay low
    if ( seed < chanceOfLow ) {
      return 0;  
    } else {
      return 1;
    }
  } else {
    if ( seed < convertedValue ) {
      return 0;
    } else {
      return 1;
    }
  }
}