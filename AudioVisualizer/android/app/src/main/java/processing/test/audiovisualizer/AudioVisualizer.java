package processing.test.audiovisualizer;

import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import android.media.audiofx.Visualizer; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class AudioVisualizer extends PApplet {



Visualizer vis;
int captureRate;
Band[] bands = new Band[512];
int bassRange = 13;
byte[] bassValues = new byte[bassRange];
float scoreLow = 0;
float r = 0;
int c = 0;

public void setup() {
  
  background(0);
  strokeWeight(3);
  colorMode(HSB);
  noFill();
  stroke(255);
  for (int i = 0; i < bands.length; i++) {
    bands[i] = new Band();
  }
  vis = new Visualizer(0);
  vis.setEnabled(false);
  vis.setCaptureSize(Visualizer.getCaptureSizeRange()[1]);
  Visualizer.OnDataCaptureListener captureListener = new Visualizer.OnDataCaptureListener()
  {
    @Override
      public void onWaveFormDataCapture(Visualizer visualizer, byte[] bytes, int samplingRate)
    {
    }

    @Override
      public void onFftDataCapture(Visualizer visualizer, byte[] bytes, int samplingRate)
    {
      for (int i = 0; i < bands.length; i++) {
        bands[i].addValue(bytes[i]);
        if (i < bassRange) {
          bassValues[i] = bytes[i];
        }
      }
    }
  };
  vis.setDataCaptureListener(captureListener, Visualizer.getMaxCaptureRate(), false, true);
  vis.setEnabled(true);
}

public void draw() {
  background(0);
  translate(width/2, height/2);
  rotate(-HALF_PI);
  scoreLow = 0;
  for (int i = 0; i < bassRange; i++)
  {
    scoreLow += Math.abs(bassValues[i]);
  }
  scoreLow /= bassRange;
  scoreLow *= 3;
  r = lerp(r, 250+scoreLow, 0.4f);
  if (c > 255) {
    c=0;
  }
  beginShape();
  for (int i = 0; i < bands.length; i++) {
    stroke((map(i, 0, bands.length-1, 0, 255)+c)%255, 255, 255);
    curveVertex((5*Math.abs(bands[i].getValue())+r)*cos(map(i, 0, bands.length-1, 0, PI)), (5*Math.abs(bands[i].getValue())+r)*sin(map(i, 0, bands.length-1, 0, PI)));
    bands[i].lerpValue();
  }

  for (int i = bands.length-1; i >= 0; i--) {
    stroke((map(i, 0, bands.length-1, 0, 255)+c)%255, 255, 255);
    curveVertex((5*Math.abs(bands[i].getValue())+r)*cos(map(i, 0, bands.length-1, TWO_PI, PI)), (5*Math.abs(bands[i].getValue())+r)*sin(map(i, 0, bands.length-1, TWO_PI, PI)));
    bands[i].lerpValue();
  }
  endShape(CLOSE);
  c++;
}

class Band{
  
  private byte value;
  private byte target;
  
  public byte getValue(){
    return target;
  }
  
  public void addValue(byte value){
    this.target += value;
  }
  
  public void lerpValue(){
    value = (byte)lerp(value, target, 0.4f);
    target = (byte)lerp(target, 0, 0.05f);
  }
  
}
  public void settings() {  fullScreen(P2D); }
}
