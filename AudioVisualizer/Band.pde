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
    value = (byte)lerp(value, target, 0.4);
    target = (byte)lerp(target, 0, 0.05);
  }
  
}
