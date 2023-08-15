boolean[] keysButtons;
boolean[] keysClick;
boolean[] keysJClick;
boolean[] mouseButtons;
boolean[] mouseClick;
boolean[] mouseJClick;
boolean mouseMove = false;
boolean mouseWheelUp = false;
boolean mouseWheelDown = false;
PVector mouseCoord = new PVector(0,0);
PVector mouseGridCoord = new PVector(0,0);

void inputUpdate() {
  mouseCoord.x = mouseX; mouseCoord.y = mouseY;
  //mouseGridCoord = screenCoordTOGridCoord(mouseCoord);
  mouseWheelUp = false; mouseWheelDown = false;
  if (mouseX == pmouseX && mouseY == pmouseY) {mouseMove = false;}
  for (int i = mouseClick.length-1; i >= 0; i--) {if (mouseJClick[i] == true && mouseClick[i] == true) {mouseJClick[i] = false; mouseClick[i] = false;}}
  for (int i = mouseJClick.length-1; i >= 0; i--) {if (mouseJClick[i] == true) {mouseClick[i] = true;}}
  for (int i = keysClick.length-1; i >= 0; i--) {if (keysJClick[i] == true && keysClick[i] == true) {keysJClick[i] = false; keysClick[i] = false;}}
  for (int i = keysJClick.length-1; i >= 0; i--) {if (keysJClick[i] == true) {keysClick[i] = true;}}
}

void setupInput() {
  keysButtons = new boolean[6];
  for (int i = keysButtons.length-1; i >= 0; i--) {keysButtons[i] = false;}
  keysClick = new boolean[6];
  for (int i = keysClick.length-1; i >= 0; i--) {keysClick[i] = false;}
  keysJClick = new boolean[6];
  for (int i = keysJClick.length-1; i >= 0; i--) {keysJClick[i] = false;}
  mouseButtons = new boolean[3];
  for (int i = mouseButtons.length-1; i >= 0; i--) {mouseButtons[i] = false;}
  mouseClick = new boolean[3];
  for (int i = mouseClick.length-1; i >= 0; i--) {mouseClick[i] = false;}
  mouseJClick = new boolean[3];
  for (int i = mouseJClick.length-1; i >= 0; i--) {mouseJClick[i] = false;}
}

boolean upPress() {
  if (keysButtons[0]) {return true;}
  return false;
}

boolean downPress() {
  if (keysButtons[1]) {return true;}
  return false;
}

boolean leftPress() {
  if (keysButtons[2]) {return true;}
  return false;
}

boolean rightPress() {
  if (keysButtons[3]) {return true;}
  return false;
}

void mouseWheel(MouseEvent event) {
  float e = event.getAmount();
  if (e<0) {
    mouseWheelUp =true; 
    mouseWheelDown =false;
  }
  if (e>0) {
    mouseWheelDown = true; 
    mouseWheelUp=false;
  }
}  

void keyPressed()
{
  if(key=='z') {
    keysButtons[0]=true;}
  if(key=='s') {
    keysButtons[1]=true;}
  if(key=='q') {
    keysButtons[2]=true;}
  if(key=='d') {
    keysButtons[3]=true;}
  if(key=='w') {
    keysButtons[4]=true;}
  if(key=='c') {
    keysButtons[5]=true;}
    
  if(key=='p' && DEBUG) {
    //RUN = !RUN;
  }
  if(key==' ' && DEBUG) {
    //energyGrid.updateCells();
  }
}

void keyReleased()
{
  if(key=='z') {
    keysButtons[0]=false;
    keysJClick[0]=true;}
  if(key=='s') {
    keysButtons[1]=false;
    keysJClick[1]=true;}
  if(key=='q') {
    keysButtons[2]=false;
    keysJClick[2]=true;}
  if(key=='d') {
    keysButtons[3]=false;
    keysJClick[3]=true;}
  if(key=='w') {
    keysButtons[4]=false;
    keysJClick[4]=true;}
  if(key=='c') {
    keysButtons[5]=false;
    keysJClick[5]=true;}
  
  //if(key=='p' && DEBUG) {
  //  RUN = true;
  //}
}

void mousePressed()
{
  if(mouseButton==LEFT) {
    mouseButtons[0]=true;}
  if(mouseButton==RIGHT) {
    mouseButtons[1]=true;}
  if(mouseButton==CENTER) {
    mouseButtons[2]=true;}
}

void mouseReleased()
{
  if(mouseButton==LEFT) {
    mouseButtons[0]=false;
    mouseJClick[0]=true;}
  if(mouseButton==RIGHT) {
    mouseButtons[1]=false;
    mouseJClick[1]=true;}
  if(mouseButton==CENTER) {
    mouseButtons[2]=false;
    mouseJClick[2]=true;}
}

void mouseDragged() { mouseMove = true; }

void mouseMoved() { mouseMove = true; }

//ArrayList<> append(ArrayList<> part1, ArrayList<> part2) {
//  ArrayList<> partf = new ArrayList<>(0);
//  for (Part p : part1) {
//    partf.add(p);
//  }
//  for (Part p : part2) {
//    partf.add(p);
//  }
//  return partf;
//}
