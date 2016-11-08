int motorEventFilter(int value) {
  return int(map(value, 0, 1024, lowerLimit, upperLimit));
  //return value;
}

//
void motorEvent(int id, int rawval) {
  if (id >= 1 && id <=4 ) {
    int value = rawval;
    // is motor mode is past filter mode
    if (motorMode == 3) {
      value = motorPastFilter(id, rawval);
    }

    // dont filter the motor data if we are in mode 2
    if ( motorMode != 2 ) {
      value = motorEventFilter( rawval );
    }
    
    // sanity check the value so we dont send the motors out of range value
    value = (value < 0) ? 0 : value;
    value = (value > 127) ? 127 : value;
    
    // if this motor is on then send the packet to the arduino
    if ( motorDataOn[id] == 1 ) {
      outport.write(id + ":" + value + 'X');
    }
    //println("TO Motor: " + id + ":" + value);
    motorValues[id] = value;
    delay(10);
  }
}

int motorPastFilter(int id, int rawval) {
  int maxValue = 1024;
  int pivot = 2;
  float mid = maxValue / pivot; //USE A PIVOT 2 OR GREATER
  float avg;
  float adjustment;
  switch(id) {
  case 1:
    avg = emg1ravg.average;
    break;
  case 2:
    avg = emg2ravg.average;
    break;
  case 3:
    avg = emg3ravg.average;
    break;
  case 4:
    avg = emg4ravg.average;
    break;
  default:
    return rawval;
  }
  if ( avg > mid ) {
    // avg is greater than mid - closer to max double the value
    adjustment = avg / maxValue - 1 / pivot + 1;
    println("Adjustment: " + adjustment + " (" + id + ")");
    return int( adjustment * rawval );
  } else {
    adjustment = avg / maxValue + (pivot - 1) / pivot;
    //println("Adjustment: " + adjustment + " (" + id + ")");
    return int( adjustment * rawval );
  }
}