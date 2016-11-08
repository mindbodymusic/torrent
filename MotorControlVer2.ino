/* Motor control code 
  Jan 7, 2015

*/

#include <SoftwareSerial.h>
#include <SabertoothSimplified.h>
SoftwareSerial SWSerial34(NOT_A_PIN, 14); // RX on no pin (unused), TX on pin 11 (to S1).
SoftwareSerial SWSerial12(NOT_A_PIN, 16); // RX on no pin (unused), TX on pin 11 (to S1).

SabertoothSimplified ST34(SWSerial34); // Use SWSerial as the serial port.
SabertoothSimplified ST12(SWSerial12); // We'll name the Sabertooth object ST.
                         // For how to configure the Sabertooth, see the DIP Switch Wizard for
                         //   http://www.dimensionengineering.com/datasheets/SabertoothDIPWizard/start.htm
                         // Be sure to select Simplified Serial Mode for use with this library.
                         // This sample uses a baud rate of 9600.
                         //
                         // Connections to make:
                         //   Arduino TX->1  ->  Sabertooth S1
                         //   Arduino GND    ->  Sabertooth 0V
                         //   Arduino VIN    ->  Sabertooth 5V (OPTIONAL, if you want the Sabertooth to power the Arduino)
                         //
                         // If you want to use a pin other than TX->1, see the SoftwareSerial example.

String inputString;
int cMotorID = 0;
int cMotorSpeed = 0;
int myTimeout = 15;  // milliseconds for Serial.readString default is 1000

void setup() {                
// Turn the Serial Protocol ON
  Serial.begin(9600);
  Serial.setTimeout(myTimeout);
  SWSerial12.begin(9600);
  SWSerial34.begin(9600);
}

void loop() {
   /*  check if data has been sent from the computer: */
  while (Serial.available() > 0) {
    char recieved = Serial.read();

    // Process message when new line character is recieved
    if (recieved == 'X')
    {
      parseSerialInput(inputString);
      
      // clear the input string
      inputString = "";
      cMotorID = 0;
      cMotorSpeed = 0;
      
    } else {
      // between 0 and : 
      if ( recieved>47 && recieved<59 ){
        inputString.concat( recieved );
      }
    }
  }
}

void parseSerialInput(String input) {
  int len = input.length();
  int colonAt = input.indexOf(":");
  // Sanity check the serial input
  if (colonAt != -1) {
    // the string contains a colon so lets check the length
    if (len >= 3 && len <= 6) {
      String id = input.substring(0, colonAt);
      String mspeed = input.substring(colonAt + 1);
      // save the current motor id and speed in a global and then deal with it later
      cMotorID = id.toInt();
      cMotorSpeed = mspeed.toInt();  
      setMotorDetails(input);
    } else {
      Serial.print(F("Error: strlen ("));
      Serial.print(len);
      Serial.println(F(")"));
    }
  } else {
    Serial.print(F("Error no colon ("));
    Serial.print(input);
    Serial.println(F(")"));
  }

}

void setMotorDetails(String input) {
  // set the motor based on the values of cMotorID and cMotorSpeed
  int len = input.length();
  //Serial.println("[" + input + "](" + String(len) + ") Motor " + String(cMotorID) + " set to " + String(cMotorSpeed) + ".");
  switch(cMotorID) {
    case 1:
      ST12.motor(1, cMotorSpeed);
      printOKResponse();
      break;
    case 2:
      ST12.motor(2, cMotorSpeed);
      printOKResponse();
      break;    
    case 3:
      ST34.motor(1, cMotorSpeed);
      printOKResponse();
      break;
    case 4:
      ST34.motor(2, cMotorSpeed);
      printOKResponse();
      break;
    default:
      Serial.println(F("Error: unknown motor"));
      break;
  }
  
}

void printOKResponse() {
      Serial.print(F("M:"));
      Serial.print(cMotorID);
      Serial.print(F(" to "));
      Serial.println(cMotorSpeed);
}


