import android.media.audiofx.Visualizer;

Visualizer vis;
int captureRate;
Band[] bands = new Band[512];
int bassRange = 20;
byte[] bassValues = new byte[bassRange];
float scoreLow = 0;
float r = 0;
int c = 0;
private static int N_SHORTS = 0xffff;
private static final short[] VOLUME_NORM_LUT = new short[N_SHORTS];
private static int MAX_NEGATIVE_AMPLITUDE = 0x8000;

static {
    precomputeVolumeNormLUT();
}    

private static void normalizeVolume(byte[] audioSamples, int start, int len) {
    for (int i = start; i < start+len; i+=2) {
        // convert byte pair to int
        short s1 = audioSamples[i+1];
        short s2 = audioSamples[i];

        s1 = (short) ((s1 & 0xff) << 8);
        s2 = (short) (s2 & 0xff);

        short res = (short) (s1 | s2);

        res = VOLUME_NORM_LUT[Math.min(res + MAX_NEGATIVE_AMPLITUDE, N_SHORTS - 1)];
        audioSamples[i] = (byte) res;
        audioSamples[i+1] = (byte) (res >> 8);
    }
}

private static void precomputeVolumeNormLUT() {
    for(int s=0; s<N_SHORTS; s++) {
        double v = s-MAX_NEGATIVE_AMPLITUDE;
        double sign = Math.signum(v);
        // Non-linear volume boost function
        // fitted exponential 
        VOLUME_NORM_LUT[s]=(short)(sign*33716.25 + (-2.031244e-12 - 33716.25)/Math.pow(1 + (v/6049.125),2.096174));
    }
}


void setup() {
  fullScreen(P2D);
  background(0);
  strokeWeight(3);
  colorMode(HSB);
  noFill();
  stroke(255);
  smooth(4);
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
      if(bytes[0] == 0)
        return;
        
      normalizeVolume(bytes, 0, 1023);
      
      for(int i = 0; i < bytes.length; i++) 
        bytes[i] /= 7;
      
      
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

void draw() {  
  background(0);
  translate(width/2, height/2);
  rotate(-HALF_PI);
  scoreLow = 0;
  for (int i = 0; i < bassRange; i++)
  {
    //System.out.println("BassValue: " + bassValues[i]);
    scoreLow += Math.abs(bassValues[i]);
  }
  scoreLow /= bassRange;
  scoreLow *= 2;
  r = lerp(r, 250+scoreLow, 0.7);
  if (c > 255) {
    c=0;
  }
  beginShape();
  for (int i = 0; i < bands.length; i++) {
    //System.out.println("Bands: " + bands[i]);
    stroke((map(i, 0, bands.length-1, 0, 255)+c)%255, 255, 255);
    curveVertex((5*Math.abs(bands[i].getValue())+r)*cos(map(i, 0, bands.length-1, 0, PI)), (5*Math.abs(bands[i].getValue())+r)*sin(map(i, 0, bands.length-1, 0, PI)));
    bands[i].lerpValue();
  }

  for (int i = bands.length-1; i >= 0; i--) {
    //System.out.println("BandsRev: " + bands[i]);
    stroke((map(i, 0, bands.length-1, 0, 255)+c)%255, 255, 255);
    curveVertex((5*Math.abs(bands[i].getValue())+r)*cos(map(i, 0, bands.length-1, TWO_PI, PI)), (5*Math.abs(bands[i].getValue())+r)*sin(map(i, 0, bands.length-1, TWO_PI, PI)));
    bands[i].lerpValue();
  }
  endShape(CLOSE);
  c++;
}
