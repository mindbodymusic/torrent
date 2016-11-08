/*  
 *  This class draws a grid with a value scale and color rectangles acording to EMG input.
 *  It also draws a table showing current state of the program
 *
 */

class ThresholdGraph {

  // variables of DisplayItems object 
  PFont font;
  int fontsize = 12;
  String fontname = "Monaco-14.vlw";
  String inputName = "";
  float gridSpacing = width/21.0;
  int gridValues = 50;
  int consoleHeight = 300;
  float potiHeight = (height - consoleHeight)/4.0;
  int potiWidth = 30;
  int poti_ID = 0;
  float scaleValue = width/1050.0;
  //float scaleValueY = height/400.0;

  int colWidth = 100;
  int rowHt = 22;
  int consoleTop = height-consoleHeight+10;
  int leftMargin = 10;
  int secondColMargin = colWidth * 6;
  int consolTextSize = 18;

  // constructor
  ThresholdGraph() {
    font = loadFont(fontname);
    textFont(font, fontsize);
  }//end ThresholdGraph

  // draws grid and value scale
  void update() {
    //refresh background
    background(255);
    textSize(fontsize);

    for (int i = 1; i < rawEMG.length-1; i++) {
      // draw thresholds in light(min) and dark(max) grey
      noStroke();
      // draw min bar
      fill(200, 200, 200);
      rect(threshMin[i]*scaleValue-potiWidth/4, (i-1)*potiHeight, potiWidth/2, potiHeight);

      // poti colours and names
      if (i == 1) { 
        fill(255, 107, 39);
        inputName = " EMG1";
      }
      if (i == 2) { 
        fill(29, 141, 224); 
        inputName = " EMG2";
      }
      if (i == 3) { 
        fill(211, 82, 232); 
        inputName = " EMG3";
      }
      if (i == 4) { 
        fill(100, 141, 224); 
        inputName = " EMG4";
      }
      if (i == 5) { 
        fill(2, 82, 232); 
        inputName = " EMG5";
      }

      // draw poti at xpos 
      //rect(rawEMG[i]*scaleValue-potiWidth/2, (i-1)*potiHeight, potiWidth, potiHeight);
      rect(0, (i-1)*potiHeight, rawEMG[i]*scaleValue-potiWidth/2+potiWidth, potiHeight);

      // draw xpos as text
      fill(0);
      text(rawEMG[i]+inputName, rawEMG[i]*scaleValue, (i-1)*potiHeight+potiHeight/2);
    }//end for

    // draw grid to fit window size
    stroke(0);
    strokeWeight(1);

    // vertical lines
    for (int i=0; i<width/gridSpacing; i++) {
      line(i*gridSpacing, 0, i*gridSpacing, height);
      textAlign(LEFT);
      text(i*gridValues, i*gridSpacing+2, fontsize);
    }//end for

    // fill console
    fill(195);
    rect( 0, height-consoleHeight, width, consoleHeight);


    int average = 0;
    textSize(consolTextSize);
    fill(25, 25, 112); // midnight blue
    text("State: ", leftMargin, consoleTop + rowHt*2);
    text("EMG Val:", leftMargin, consoleTop + rowHt*3);
    text("M Val:", leftMargin, consoleTop + rowHt*4);
    text("Amp:", leftMargin, consoleTop + rowHt*5);
    text("MAX:", leftMargin, consoleTop + rowHt*6);
    text("AVG:", leftMargin, consoleTop + rowHt*7);
    text("Count:", leftMargin, consoleTop + rowHt*8);
    text("RA#:", leftMargin, consoleTop + rowHt*9);
    text("RA:", leftMargin, consoleTop + rowHt*10);
    text("FakeD: ", leftMargin, consoleTop + rowHt*11);
    text("Mute:", leftMargin, consoleTop + rowHt*12);

    for (int i=1; i<5; i++) {
      text("EMG" + i, i*colWidth, consoleTop + rowHt);
      String motorState = motorDataOn[i] == 0 ? "Off" : "On";
      text(motorState, i*colWidth, consoleTop + rowHt*2);
      text(rawEMG[i], i*colWidth, consoleTop + rowHt*3);
      text(motorValues[i], i*colWidth, consoleTop + rowHt*4);
      text(ampFactor[i], i*colWidth, consoleTop + rowHt*5);
      String maxVal = "";
      if (maxValues[i] == 0) {
        maxVal = "--";
      } else {
        maxVal = "" + maxValues[i];
      }
      text(maxVal, i*colWidth, consoleTop + rowHt*6);

      if (counts[i] == 0) {
        average = 0;
      } else {
        average = totals[i] / counts[i];
      }
      text(average, i*colWidth, consoleTop + rowHt*7);
      text(counts[i], i*colWidth, consoleTop + rowHt*8);
      switch(i) {
      case 1:
        text(emg1ravg.dataPoints, i*colWidth, consoleTop + rowHt*9);
        text(emg1ravg.average, i*colWidth, consoleTop + rowHt*10);
        break;
      case 2:
        text(emg2ravg.dataPoints, i*colWidth, consoleTop + rowHt*9);
        text(emg2ravg.average, i*colWidth, consoleTop + rowHt*10);
        break;
      case 3:
        text(emg3ravg.dataPoints, i*colWidth, consoleTop + rowHt*9);
        text(emg3ravg.average, i*colWidth, consoleTop + rowHt*10);
        break;
      case 4:
        text(emg4ravg.dataPoints, i*colWidth, consoleTop + rowHt*9);
        text(emg4ravg.average, i*colWidth, consoleTop + rowHt*10);
        break;
      default:
        break;
      }

      String fakeState = fakeData[i] == 0 ? "Off" : "On";
      text(fakeState, i*colWidth, consoleTop + rowHt*11);
      String muteState = muteOn[i] == 0 ? "Off" : "On";
      if ( muteOn[i] == 1) { fill(255, 0, 0); }
      text(muteState, i*colWidth, consoleTop + rowHt*12);
      fill(25, 25, 112); // midnight blue
    }

    // Start the second column of data
    text("Upperlimit: " + upperLimit + " (press o to inc and l to dec)", secondColMargin, consoleTop + rowHt * 1);
    text("LowerLimit: " + lowerLimit + " (press i to inc and k to dec)", secondColMargin, consoleTop + rowHt * 2);
    fill(25, 25, 112, 100); // midnight blue
    text("0 set u:127 l:10, 8 set u:60 l:30, 9 set u:127 l:60", secondColMargin, consoleTop + rowHt * 3);
    fill(25, 25, 112); // midnight blue
    text("Motor mode is: " + getMotorModeText( motorMode ) + " (press m to cycle)", secondColMargin, consoleTop + rowHt * 5);
    int percentChance = int( (chanceOfLow*5 ) );
    text("Chance of low in fake: " + percentChance + "% (6 to inc and 7 to dec)", secondColMargin, consoleTop + rowHt * 7);
    fill(25, 25, 112, 100); // midnight blue
    text("--1, 2, 3, 4 turn motors off and on", secondColMargin, consoleTop + rowHt * 9);
    text("--q, w, e, r turn fake data off and on", secondColMargin, consoleTop + rowHt * 10);
    text("--clt+1, clt+2, clt+3, clt+4 mutes serial data", secondColMargin, consoleTop + rowHt * 11);
    text("--<space> kills all motors", secondColMargin, consoleTop + rowHt * 12);
    text("--<esc> to quit", secondColMargin, consoleTop + rowHt * 13);
    fill(25, 25, 112); // midnight blue
  }// end update

  String getMotorModeText( int mode ) {
    switch( mode ) {
    case 1:
      return "Normal";
    case 2:
      return "Burst";
    case 3:
      return "Past adjusted";
    default:
      return "Error";
    }
  }
}// end class Display