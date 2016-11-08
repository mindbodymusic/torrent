
/*
*  By Hannah Perner-Wilson, www.plusea.at
 *  Modified 3/30/2012 By Brian E Kaminski, www.AdvancerTechnologies.com
 *  Modified 1/31/2016 By Eric Pattison, 
 *  Modified 6/14/2016 By Eric Pattison
 *
 *  IMPORTANT!!:
 *  Scroll down to set your serial port
 *  Scroll down to set your thresholds
 */

import processing.serial.*;
//import controlP5.*;
import g4p_controls.*;
import netP5.*;
import oscP5.*;


// definition of window size
// you can change the size of the window as you like
// the thresholdGraph will be scaled to fit
// the optimal size for the thresholdGraph is 1000 x 400
int xWidth = 1200;
int yHeight = 750;

// xPos input array, using prefix
int[] rawEMG= {0, 0, 0, 0, 0, 0}; 

// this seems to only be used by the thresHolding function but no where else
int[] adjustedData= {0, 0, 0, 0, 0, 0}; 
float[] ampFactor = {1, 1, 1, 1, 1};

// keep the latest motor value
int[] motorValues= {0, 0, 0, 0, 0, 0};
int motorSpeedJump = 10;

// Arrays for threshholding
int[] threshMax= {0, 0, 0, 0, 0, 0}; 
int[] threshMin= {0, 0, 0, 0, 0, 0}; 
int[] maxValues= {0, 0, 0, 0, 0, 0};
int[] minValues= {5555, 5555, 5555, 5555, 5555, 5555};
int[] counts= {0, 0, 0, 0, 0, 0};
int[] totals= {0, 0, 0, 0, 0, 0};
// variables for serial connection. portname and baudrate are user specific
Serial port1;
Serial outport;  // just 1 arduino
int baudrate = 9600;

int prefix = 0;
String serialIN = "";
String serialINPUT = ""; 
String buffer = ""; 
//int value = 0; 
int emgID = 0;

// running averages
int runningAvgPoints = 5;
runningAvg emg1ravg = new runningAvg(runningAvgPoints);
runningAvg emg2ravg = new runningAvg(runningAvgPoints);
runningAvg emg3ravg = new runningAvg(runningAvgPoints);
runningAvg emg4ravg = new runningAvg(runningAvgPoints);

// State 
int[] fakeData = {0, 0, 0, 0, 0};
int[] fakeDataValue = {0, 0, 0, 0, 0};
int[] motorDataOn = {0, 0, 0, 0, 0};
int[] muteOn = {0, 0, 0, 0, 0};
int upperLimit = 127;
int lowerLimit = 10;
// the modes are 1 = normal, 2 = burst, 3 = past adjust
int motorMode = 1; // dont change here, use m key in the client
int chanceOfLow = 14; // valid values 1 to 19 higher means more lower values

// class to handle exit the program and close file stream
DisposeHandler dh;


// GUI
//ControlP5 cp5;

// Timer for burst mode
GTimer timer;
int secondsToBurst = 3;
int burstSteps = 12;
// we want 2 seconds or 2004 ms with 12 steps = 2004/12 = 167 ms
int burstRate = 200; //secondsToBurst * 1000 / burstSteps;

// Create file handler
PrintWriter fileOut;

// OSC objects
OscP5 oscP5;

// ThresholdGraph draws grid and poti states
ThresholdGraph userInterface;

void setup() {
  dh = new DisposeHandler(this);
  // set size and framerate
  size(1200, 750);
  frameRate(25);
  background(255);
  strokeWeight(5);
  stroke(0);
  smooth();
  strokeCap(ROUND); 


  printArray(Serial.list());  // print serial list
  // establish serial port connection  
  //Set your serial port here (look at list printed when you run the application once)
  String portname1 = Serial.list()[9];// PUT IN LIST NUMBER FOR /dev/tty.usbserial-A700eEll - usually 9
  String outportName = Serial.list()[8]; //PUT LIST NUMBER FOR /dev/tty.usbmodemfa131 - usually 8
  port1 = new Serial(this, portname1, baudrate);
  port1.bufferUntil('\n');
  outport = new Serial(this, outportName, baudrate);
  
  // start oscP5 and listen on port 6449
  oscP5 = new OscP5(this, 6450);

  // create DisplayItems object
  userInterface = new ThresholdGraph();

  fileOut = createWriter(getTimestampedFilename("emgDataDump", "txt"));

  // Create a GTimer object that will call the method burstStep
  // Parameter 1 : the PApplet class i.e. 'this'
  //           2 : the object that has the method to call
  //           3 : the name of the method (parameterless) to call
  //           4 : the interval in millisecs bewteen method calls
  timer = new GTimer(this, this, "burstStep", burstRate);
}//end setup

// draw listens to serial port, draw 
void draw() {

  generateFakeData();

  // draw serial input
  userInterface.update();
}//end draw()

void keyPressed(KeyEvent e) {
  
  if ( e.isControlDown() ) {
    switch (key) {
      case '1':
        toggleSerialMute( 1 ); 
        break;
      case '2':
        toggleSerialMute( 2 ); 
        break;
      case '3':
        toggleSerialMute( 3 ); 
        break;
      case '4':
        toggleSerialMute( 4 ); 
        break;
      default:
        // nada
        break;
    }
  } else {
      int value = 0;
      switch (key) {
      case '6':
        adjustChanceOfLow( "up" );
        break;
      case '7':
        adjustChanceOfLow( "down" );
        break;
      case 'A':
      case 'a':
        increaseAmpFactor(1);
        break;
      case 'Z':
      case 'z':
        decreaseAmpFactor(1);
        break;
      case 'S':
      case 's':
        increaseAmpFactor(2);
        break;
      case 'X':
      case 'x':
        decreaseAmpFactor(2);
        break;
      case 'D':
      case 'd':
        increaseAmpFactor(3);
        break;
      case 'C':
      case 'c':
        decreaseAmpFactor(3);
        break;  
      case 'F':
      case 'f':
        increaseAmpFactor(4);
        break;
      case 'V':
      case 'v':
        decreaseAmpFactor(4);
        break;
      case 0:
        exit();
        break;
      case '1':
        toggleMotorOn( 1 );
        break;
      case 'q':
      case 'Q':
        toggleFakeData( 1 );
        break;
      case '2':
        toggleMotorOn( 2 );
        break;
      case 'w':
      case 'W':
        toggleFakeData( 2 );
        break;
      case '3':
        toggleMotorOn( 3 );
        break;
      case 'e':
      case 'E':
        toggleFakeData( 3 );
        break;
      case '4':
        toggleMotorOn( 4 );
        break;
      case 'r':
      case 'R':
        toggleFakeData( 4 );
        break;
      case 'i':
      case 'I':
        adjustLowerLimit( "up" );
        break;
      case 'k':
      case 'K':
        adjustLowerLimit( "down" );
        break;
      case 'o':
      case 'O':
        adjustUpperLimit( "up" );
        break;
      case 'l':
      case 'L':
        adjustUpperLimit( "down" );
        break;
      case '0':
        lowerLimit = 10;
        upperLimit = 127;
        break;
      case '8':
        lowerLimit = 30;
        upperLimit = 60;
        break;
      case '9':
        lowerLimit = 60;
        upperLimit = 127;
        break;
      case 'm':
      case 'M':
        switch (motorMode) {
        case 1:
          motorMode = 2;
          timer.start();
          break;
        case 2:
          motorMode = 3;
          timer.stop();
          break;
        case 3:
        default:
          motorMode = 1;
          break;
        }
        break;
      case ' ':
        // this is always full abort, turn all off
        for (int i=1; i<=4; i++) {
          motorDataOn[i] = 0; 
          outport.write(i + ":0X");  
          motorValues[i] = 0;
          delay(10);
        }
        break;
      default:
        break;
      }
    }
}

void decreaseAmpFactor(int id) {
  if( ampFactor[id] <= 1) {
    ampFactor[id] = ampFactor[id] - 0.1;
  } else {
    ampFactor[id] = ampFactor[id] - 0.25;
  }
  if ( ampFactor[id] < 0.1 ) { 
    ampFactor[id] = 0.1;
  }
}

void increaseAmpFactor(int id) {
  if ( ampFactor[id] < 1 ) {
    ampFactor[id] = ampFactor[id] + 0.1;  
  } else {
    ampFactor[id] = ampFactor[id] + 0.25;
  }
}

void adjustLowerLimit( String direction ) {
  direction = direction.toLowerCase();
  int bufferBetweenUpandLower = 10;
  switch ( direction ) {
  case "up":
    lowerLimit++;
    break;
  case "down":
    lowerLimit--;
    break;
  default:
    break;
  }

  if ( lowerLimit >= upperLimit - bufferBetweenUpandLower ) {
    lowerLimit = upperLimit - bufferBetweenUpandLower;
  }
  if ( lowerLimit < 0 ) {
    lowerLimit = 0;
  }
}

void adjustChanceOfLow( String direction ) {
  direction = direction.toLowerCase();
  switch ( direction ) {
  case "up":
    chanceOfLow++;
    break;
  case "down":
    chanceOfLow--;
    break;
  default:
    break;
  }  
  if ( chanceOfLow < 1 ) {
    chanceOfLow = 1;
  }
  if ( chanceOfLow > 20 ) {
    chanceOfLow = 20;
  }
}

void adjustUpperLimit( String direction ) {
  direction = direction.toLowerCase();
  int bufferBetweenUpandLower = 10;
  switch ( direction ) {
  case "up":
    upperLimit++;
    break;
  case "down":
    upperLimit--;
    break;
  default:
    break;
  }

  if ( upperLimit <= lowerLimit + bufferBetweenUpandLower ) {
    upperLimit = lowerLimit + bufferBetweenUpandLower;
  }
  if ( upperLimit > 127 ) {
    upperLimit = 127;
  }
}

void toggleFakeData( int id ) {
  if ( fakeData[id] == 0 ) {
    fakeData[id] = 1;
  } else {
    fakeData[id] = 0;
  }
}

void toggleMotorOn( int id ) {
  if ( motorDataOn[id] == 0) {
    motorDataOn[id] = 1;
  } else {
    motorDataOn[id] = 0;
    motorValues[id] = 0;
    outport.write(id + ":0X");
  }
}

void toggleSerialMute( int id ) {
  if ( muteOn[id] == 0) {
    muteOn[id] = 1;
    motorValues[id] = 0;
    outport.write(id + ":0X");
  } else {
    muteOn[id] = 0;
  }
}

// Called whenever there is something available to read
void serialEvent(Serial thisport) {
  // Data from the Serial port is read in serialEvent() using the read()
  String input = thisport.readStringUntil('\n');

  if ( thisport == outport )
  {
    // For debugging
    if ( input != null ) {
      print("Arduino: " + input);
    }
  }
  if ( thisport == port1 )
  {
    if (input != "") {
      serialEvent(input);  
      //print("Radio: " + input);
    } else {
      println("found empty");
    }
  }
}

// across 2 seconds or 2004 ms each burst is 167 ms long
//EMG 1-200: 1/10 - 1 on 11 off
//EMG 201-400: 2/20 - 1 on 5 off
//EMG 401-600: 3/40 - 1 on 3 off
//EMG 601-800: 4/60 - 1 on 2 off
//EMG 800+: 6/90 - 1 on 1 off
int[][] burstLvls = { 
  {0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0}, // lvl 1: 1on 11off
  {0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0}, // lvl 2: 1on 5off
  {0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0}, // lvl 3: 1on 3off
  {0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0}, // lvl 4: 1on 2off
  {0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0} }; // lvl 5: 1on 1off
int[] motorBurstLvl = {0, 0, 0, 0, 0};
int[] motorSpeedLvl = {0, 0, 0, 0, 0};
int currentStep = 1;
void burstStep(GTimer timer) {

  if ( currentStep > burstSteps ) {
    currentStep = 1;
  }

  // if this our first 1 step figure out what lvl each motor will be on based on the current emg reading
  if ( currentStep == 1 ) {
    // check motor 1
    int max = emg1ravg.getMaxValue();
    motorBurstLvl[1] = getBurstLvl( max );
    motorSpeedLvl[1] = getSpeedLvl( motorBurstLvl[1] );
    max = emg2ravg.getMaxValue();
    motorBurstLvl[2] = getBurstLvl( max );
    motorSpeedLvl[2] = getSpeedLvl( motorBurstLvl[2] );
    max = emg3ravg.getMaxValue();
    motorBurstLvl[3] = getBurstLvl( max );
    motorSpeedLvl[3] = getSpeedLvl( motorBurstLvl[3] );
    max = emg4ravg.getMaxValue();
    motorBurstLvl[4] = getBurstLvl( max );
    motorSpeedLvl[4] = getSpeedLvl( motorBurstLvl[4] );
    //println("Step 1:  1:" + motorBurstLvl[1] + ":" + motorSpeedLvl[1] + " 2:" + motorBurstLvl[2] + ":" + motorSpeedLvl[2] + " 3:" + motorBurstLvl[3] + ":" + motorSpeedLvl[3]);
  }
  int speed = 0;
  for (int i=1; i<=4; i++) {
    if ( burstLvls[motorBurstLvl[i]][currentStep] == 1 ) {
      speed = motorSpeedLvl[i];
    } else {
      speed = 0;
    }
    motorEvent(i, speed);
    delay(8);
  }

  //println(burstLvls[motorBurstLvl[1]][currentStep] + " " + burstLvls[motorBurstLvl[2]][currentStep] + " " + burstLvls[motorBurstLvl[3]][currentStep] + " " + burstLvls[motorBurstLvl[4]][currentStep]);

  // done step to inc
  currentStep++;
}

int getBurstLvl( int value ) {
  //EMG 1-200: 1/10 - 1 on 11 off
  //EMG 201-400: 2/20 - 1 on 5 off
  //EMG 401-600: 3/40 - 1 on 3 off
  //EMG 601-800: 4/60 - 1 on 2 off
  //EMG 800+: 6/90 - 1 on 1 off  
  if ( value < 200 ) {
    return 0;
  } else if ( value < 400 ) {
    return 1;
  } else if ( value < 600 ) {
    return 2;
  } else if ( value < 800 ) {
    return 3;
  } else if ( value < 1025 ) {
    return 4;
  } else {
    return 0;
  }
}

int getSpeedLvl( int value ) {
  switch( value ) {
  case 0:
  default:
    // EMG 1-200
    return 30;
  case 1:
    // EMG 201-400
    return 50;
  case 2:
    // EMG 401-600
    return 65;
  case 3:
    // EMG 601-800
    return 80;
  case 4:
    // EMG 800+
    return 90;
  }
}

void oscEvent(OscMessage themsg) {
  /* get and print the address pattern and the typetag of the received OscMessage */
  // check if the address pattern is motors
  if ( themsg.checkAddrPattern("/motors")==true ) {
    int motorValue = themsg.get(0).intValue();
    if ( motorValue == 0 ) {
      // this is always full abort, turn all off
        for (int i=1; i<=4; i++) {
          motorDataOn[i] = 0; 
          outport.write(i + ":0X");  
          motorValues[i] = 0;
          delay(10);
        }  
    } else {
      toggleMotorOn( motorValue );
    }
  } else if ( themsg.checkAddrPattern("/amplify")==true ) {
    String ampValue = themsg.get(0).stringValue(); 
    switch ( ampValue ) {
        case "A":
        case "a":
          increaseAmpFactor(1);
          break;
        case "Z":
        case "z":
          decreaseAmpFactor(1);
          break;
        case "S":
        case "s":
          increaseAmpFactor(2);
          break;
        case "X":
        case "x":
          decreaseAmpFactor(2);
          break;
        case "D":
        case "d":
          increaseAmpFactor(3);
          break;
        case "C":
        case "c":
          decreaseAmpFactor(3);
          break;  
        case "F":
        case "f":
          increaseAmpFactor(4);
          break;
        case "V":
        case "v":
          decreaseAmpFactor(4);
          break;  
        default:
          break;
    }
  } else if( themsg.checkAddrPattern("/mode")==true ) {
    String modeValue = themsg.get(0).stringValue(); 
    switch ( modeValue ) {
      default:
        // do nothing;
        break;
      case "m":
      case "M":
        switch (motorMode) {
        case 1:
          motorMode = 2;
          timer.start();
          break;
        case 2:
          motorMode = 3;
          timer.stop();
          break;
        case 3:
        default:
          motorMode = 1;
          break;
        }
        break;
        case "burst":
          motorMode = 2;
          timer.start();
          break;
        case "normal":
          if ( 2 == motorMode ) { timer.stop(); }
          motorMode = 1;
          break;
        case "past":
          if ( 2 == motorMode ) { timer.stop(); }
          motorMode = 3;
          break;
    }
    
  } else if( themsg.checkAddrPattern("/limits")==true ) {
    String limitValue = themsg.get(0).stringValue(); 
    switch ( limitValue ) {
      case "i":
      case "I":
        adjustLowerLimit( "up" );
        break;
      case "k":
      case "K":
        adjustLowerLimit( "down" );
        break;
      case "o":
      case "O":
        adjustUpperLimit( "up" );
        break;
      case "l":
      case "L":
        adjustUpperLimit( "down" );
        break;  
    }
  } else if( themsg.checkAddrPattern("preset")==true ) {
    int presetValue = themsg.get(0).intValue(); 
    switch ( presetValue ) {
      default:
      case 0:
        lowerLimit = 10;
        upperLimit = 127;
        break;
      case 8:
        lowerLimit = 30;
        upperLimit = 60;
        break;
      case 9:
        lowerLimit = 60;
        upperLimit = 127;
        break;
    }
  } else {
    println("### received an osc message with addrpattern "+themsg.addrPattern()+" and typetag "+themsg.typetag());
    themsg.print();
  }
}

public void lightToggle(int theValue) {
  motorEvent(0, 230);
  //outport.write('\n');
  println("Sent 0:203");
}

public class DisposeHandler {

  DisposeHandler(PApplet pa)
  {
    pa.registerMethod("dispose", this);
  }

  public void dispose()
  {      
    print("Flushing and closing files... ");
    fileOut.flush();
    fileOut.close();
    println(" Done");
    println("Closing EMG Vis Tool");
    // Place here the code you want to execute on exit
  }
}