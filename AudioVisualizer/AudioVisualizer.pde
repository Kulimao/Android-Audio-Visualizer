import android.media.audiofx.Visualizer;

Visualizer vis;
int captureRate;
Band[] bands = new Band[512];
int bassRange = 5;
float scoreLow = 0;
float r = 0;
int c = 0;

void setup() {
  fullScreen(P2D);
  background(0);
  strokeWeight(1);
  colorMode(HSB);
  noFill();
  stroke(255);
  for (int i = 0; i < bands.length; i++) {
    bands[i] = new Band();
  }
  vis = new Visualizer(0);
  vis.setEnabled(false);
  vis.setCaptureSize(Visualizer.getCaptureSizeRange()[1]);
  vis.setMeasurementMode(Visualizer.MEASUREMENT_MODE_NONE);
  Visualizer.OnDataCaptureListener captureListener = new Visualizer.OnDataCaptureListener()
  {
    @Override
      public void onWaveFormDataCapture(Visualizer visualizer, byte[] bytes, int samplingRate)
    {
    }

    @Override
      public void onFftDataCapture(Visualizer visualizer, byte[] bytes, int samplingRate)
    {
      println(log10(Math.abs(bytes[0])+1)*100f);
      for (int i = 0; i < bands.length; i++) {
        bands[i].setTarget(log10(Math.abs(bytes[i])+1)*100f);
        if (i < bassRange) {
          scoreLow = 0;
          //scoreLow += bytes[i];
        }
      }
      //scoreLow *= 2;
    }
  };
  vis.setDataCaptureListener(captureListener, Visualizer.getMaxCaptureRate(), false, true);
  vis.setEnabled(true);
}

void draw() {
  background(0);
  translate(width/2, height/2);
  rotate(-HALF_PI);
  r = lerp(r, 300+scoreLow, 0.3);
  if (c > 255) {
    c=0;
  }
  beginShape();
  for (int i = 0; i < bands.length; i++) {
    stroke((map(i, 0, bands.length-1, 0, 255)+c)%255, 255, 255);
    vertex((bands[i].getValue()+r)*cos(map(i, 0, bands.length-1, 0, PI)), (bands[i].getValue()+r)*sin(map(i, 0, bands.length-1, 0, PI)));
    bands[i].lerpValue();
  }

  for (int i = bands.length-1; i >= 0; i--) {
    stroke((map(i, 0, bands.length-1, 0, 255)+c)%255, 255, 255);
    vertex((bands[i].getValue()+r)*cos(map(i, bands.length-1, 0, PI, TWO_PI)), (bands[i].getValue()+r)*sin(map(i, bands.length-1, 0, PI, TWO_PI)));
    bands[i].lerpValue();
  }
  endShape();
  c++;
}

float log10 (int x) {
  return (log(x) / log(10));
}
