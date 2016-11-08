# torrent
Torrent is a music composition for flute choir and live water sounds, inspired by the Calgary Floods of 2013. Electromyography sensors worn by four flutists measure their tension as they play, and use this to control motors in a large container of water. The agitation of the water is a musification and physicalization of the flutists' muscle tension and accompanies them as they perform the music. You can find out more and see images at http://www.aurapon.ca/torrent-for-flutes-and-water.html

The system consists of the following hardware and software:

Sensor packs:
The 4 EMG sensor packs each contain an Advancer Technologies V3 Muscle Sensor plus electrodes, hooked up to an Arduino Mega with an Xbee shield. Arduino_Xbee_router.ino is the code on this Arduino to route the sensor data to the Xbee and onward to the Xbee coordinator connected to a laptop.

Water Motors and control box: 
Four submersible pump motors with model boat propellers are submerged in a large container of water. These motors are driven by 2  Sabertooth 2x25 motor drivers, connected to one Arduino Mega. This Arduino is running Arduino_MotorControlVer2.ino, which receives the motor speed from the Processing code and sends the motor speed to the motor driver. Ideally 4 condensor mics plus 1 hydrophone are mounted around and in the water container for audio input of the water sounds. 

Laptop:
The laptop is running Processing sketch EMGVisAndWaterOutputv4.pde, which performs the following functions: 1) receives the sensor data, 2) visualize the data dynamically in a bar graph, 3) simulates the data in emergency cases if a sensor is malfunctioning, 4) allows the administrator input to adjust the way the data is mapped to motor speeds via modes and settings, 5) receives Open Sound Control network messages to also allow control of the same administrator functions as per 4) above from within MaxMSP, and 6) send speed control messages to the propeller motors. You need the controlP5 library and the Sabertooth Arduino Library.
The laptop is also running MaxMSP 6 project file Max2Processing_All.maxproj. This allows all the same administrator functions that the Processing sketch allows to be controlled from within Max, because on the top layer of the laptop, the composer/operator would be running Max patch Mic_Router1.maxpat to route the mic input to speaker output and monitor sound levels.

We have also included our study surveys and interview questions in "Surveys&Interviews".

You can direct any questions to mail@aurapon.ca.
