/*****************************************************************
XBee_Serial_Passthrough.ino

Set up a software serial port to pass data between an XBee Shield
and the serial monitor.

Hardware Hookup:
  The XBee Shield makes all of the connections you'll need
  between Arduino and XBee. If you have the shield make
  sure the SWITCH IS IN THE "DLINE" POSITION. That will connect
  the XBee's DOUT and DIN pins to Arduino pins 2 and 3.

*****************************************************************/
// We'll use SoftwareSerial to communicate with the XBee:
#include <SoftwareSerial.h>
// XBee's DOUT (TX) is connected to pin 2 (Arduino's Software RX)
// XBee's DIN (RX) is connected to pin 3 (Arduino's Software TX)
SoftwareSerial XBee(2, 3); // RX, TX

// variables for input pins and
int analogInput;
  
// variable to store the value 
int value; 
int emgID;

int count;
int average;
int hz;

void setup()
{
    // declaration of pin modes
    analogInput = A9;
    value = 0;
    hz = 5000;
    average = 0;   
    emgID = 1;
    count = 0;  
    pinMode(analogInput, INPUT);    
  // Set up both ports at 9600 baud. This value is most important
  // for the XBee. Make sure the baud rate matches the config
  // setting of your XBee.
  Serial.begin(9600);
//  Serial.begin(9600);
}

void loop()
{
   value = analogRead(analogInput); 
   count++; 
 // Serial.print("hello I'm EMG5");
   if(count >= hz) 
   {
     float av = average/hz;
     Serial.println( String(emgID) + ":" + String(value));
    // delay(750);
    count = 0;
    average = 0;
   }
   else
   {
     average += value;
   }
}

