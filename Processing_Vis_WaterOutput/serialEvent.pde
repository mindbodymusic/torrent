void serialEvent(String serialINPUT) {
  try {
    String[] numbers = split( serialINPUT, ":" );
    emgID = Integer.parseInt(numbers[0].replaceAll("(\\r|\\n)", ""));
    int value = Integer.parseInt(numbers[1].replaceAll("(\\r|\\n)", ""));
    if ( numbers.length == 2 && emgID < 5 ) {  
      //first check if the serial data is being muted
      if ( muteOn[emgID] != 1 && fakeData[emgID] == 0 ) {
        
        // add event to buffer
        counts[emgID]++;
        // amp the value
        value = int(ampFactor[emgID] * value);
        if ( value > 1024 ) {
          value = 1024;
        }
        totals[emgID] += value; 
        rawEMG[emgID] = value;
        if (minValues[emgID] > value ) { 
          minValues[emgID] = value;
        }
        if (maxValues[emgID] < value ) { 
          maxValues[emgID] = value;
        }
  
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
  
        //println("Packet:" + emgID + ":" + value);
        // write the data to the log file
        fileOut.println(getCurrentTimestamp() + "," + emgID + "," + value);
  
        // If we are in burst mode do not set the motor here
        if ( motorMode != 2 ) {
          motorEvent(emgID, value);
        }
      } else {
       //println("ignore packet from sensor: " + emgID);  
      }
    }
  }
  catch(NumberFormatException e) {
    println(e.getMessage());
  }
  catch(NullPointerException e) {
    println(e.getMessage());
  }
}