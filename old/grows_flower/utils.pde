PVector mouseDir(PVector center) {
  PVector dir = new PVector(0, 0); 
  dir.x = mouseX - center.x;
  dir.y = mouseY - center.y;
  dir.setMag(1);
  return dir;
}

PVector randomVect(int mag) {
  PVector rnd = new PVector(0, 0); 
  rnd.x = random(10) - 5;
  rnd.y = random(10) - 5;
  rnd.setMag(mag);
  return rnd;
}


boolean isInside(float value, float min, float max) {
  if (value > min && value < max) {return true;} else {return false;}
}

float crandom(float d) {
  return pow(random(1.0), d) ;
}
