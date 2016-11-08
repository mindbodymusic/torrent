void threshHolding(){
  for (int i=0; i<threshMin.length; i++) {
    float maxi=threshMax[i];
    float mini=threshMin[i];
    float dif = (maxi-mini)/255;
    adjustedData[i]= rawEMG[i]-threshMin[i];
    if (adjustedData[i] <0) adjustedData[i]=0;
    float temp = adjustedData[i];   
    temp = temp/dif;
    adjustedData[i] = int(temp);
    if (adjustedData[i] <0) adjustedData[i]=0;
    if (adjustedData[i] >255) adjustedData[i]=255;
    }
}