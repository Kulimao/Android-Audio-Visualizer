class Band{
  
  private float value;
  private float target;
  
  public float getValue(){
    return value;
  }
  
  public void setTarget(float target){
    this.target = target;
  }
  
  public void lerpValue(){
    value = lerp(value, target, 0.2);
  }
  
}
