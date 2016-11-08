String getCurrentTimestamp() {
  String timestamp = "";
  timestamp = "[" + String.valueOf(day()) + "-" + String.valueOf(month()) + "-" + String.valueOf(year());
  timestamp += " " + String.valueOf(hour()) + ":" + String.valueOf(minute()) + ":" + String.valueOf(millis()) + "]";
  
  return timestamp;
}

String getTimestampedFilename(String Filename, String Extention) {

  Filename += "-" + String.valueOf(day()) + "-" + String.valueOf(month()) + "-" + String.valueOf(year());
  Filename += "-" + String.valueOf(hour()) + "-" + String.valueOf(minute()) + "-" + String.valueOf(second()) + "." + Extention;
  
  return Filename;
}