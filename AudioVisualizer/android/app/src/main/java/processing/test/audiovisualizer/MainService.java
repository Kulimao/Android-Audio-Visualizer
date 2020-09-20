package processing.test.audiovisualizer;
        
import processing.android.PWallpaper;
import processing.core.PApplet;
        
public class MainService extends PWallpaper {  
  @Override
  public PApplet createSketch() {
    PApplet sketch = new AudioVisualizer();
    
    return sketch;
  }
}
