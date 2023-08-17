

//ici c'est super mal foutu

//mais sa gere les boutton du clavier et de la sourie

boolean[] keysButtons;
boolean[] keysClick;
boolean[] keysJClick;
boolean[] keysUClick;
boolean[] keysJUClick;
boolean[] mouseButtons;
boolean[] mouseClick;
boolean[] mouseJClick;
boolean[] mouseUClick;
boolean[] mouseJUClick;
boolean mouseMove = false;
boolean mouseWheelUp = false;
boolean mouseWheelDown = false;
PVector mouseCoord = new PVector(0,0);
PVector mouseGridCoord = new PVector(0,0);

int keyNb = 10;

void inputUpdate() {
  mouseCoord.x = mouseX; mouseCoord.y = mouseY;
  mouseWheelUp = false; mouseWheelDown = false;
  if (mouseX == pmouseX && mouseY == pmouseY) {mouseMove = false;}
  for (int i = mouseClick.length-1; i >= 0; i--) {if (mouseClick[i] == true && mouseJClick[i] == false) {mouseJClick[i] = true;}}
  for (int i = mouseJClick.length-1; i >= 0; i--) {if (mouseClick[i] == true && mouseJClick[i] == true) {mouseClick[i] = false; mouseJClick[i] = false;}}
  for (int i = mouseUClick.length-1; i >= 0; i--) {if (mouseUClick[i] == true && mouseJUClick[i] == false) {mouseJUClick[i] = true;}}
  for (int i = mouseJUClick.length-1; i >= 0; i--) {if (mouseUClick[i] == true && mouseJUClick[i] == true) {mouseUClick[i] = false; mouseJUClick[i] = false;}}
  for (int i = keysClick.length-1; i >= 0; i--) {if (keysClick[i] == true) {keysJClick[i] = true;}}
  for (int i = keysJClick.length-1; i >= 0; i--) {if (keysClick[i] == true && keysJClick[i] == true) {keysClick[i] = false; keysJClick[i] = false;}}
  for (int i = keysUClick.length-1; i >= 0; i--) {if (keysUClick[i] == true) {keysJUClick[i] = true;}}
  for (int i = keysJUClick.length-1; i >= 0; i--) {if (keysUClick[i] == true && keysJUClick[i] == true) {keysUClick[i] = false; keysJUClick[i] = false;}}
}

void setupInput() {
  keysButtons = new boolean[keyNb];
  for (int i = keysButtons.length-1; i >= 0; i--) {keysButtons[i] = false;}
  keysClick = new boolean[keyNb];
  for (int i = keysClick.length-1; i >= 0; i--) {keysClick[i] = false;}
  keysJClick = new boolean[keyNb];
  for (int i = keysJClick.length-1; i >= 0; i--) {keysJClick[i] = false;}
  keysUClick = new boolean[keyNb];
  for (int i = keysUClick.length-1; i >= 0; i--) {keysUClick[i] = false;}
  keysJUClick = new boolean[keyNb];
  for (int i = keysJUClick.length-1; i >= 0; i--) {keysJUClick[i] = false;}
  mouseButtons = new boolean[3];
  for (int i = mouseButtons.length-1; i >= 0; i--) {mouseButtons[i] = false;}
  mouseClick = new boolean[3];
  for (int i = mouseClick.length-1; i >= 0; i--) {mouseClick[i] = false;}
  mouseJClick = new boolean[3];
  for (int i = mouseJClick.length-1; i >= 0; i--) {mouseJClick[i] = false;}
  mouseUClick = new boolean[3];
  for (int i = mouseUClick.length-1; i >= 0; i--) {mouseUClick[i] = false;}
  mouseJUClick = new boolean[3];
  for (int i = mouseJUClick.length-1; i >= 0; i--) {mouseJUClick[i] = false;}
}

void mouseWheel(MouseEvent event) {
  float e = event.getAmount();
  if (e>0) {
    mouseWheelUp =true; 
    mouseWheelDown =false;
  }
  if (e<0) {
    mouseWheelDown = true; 
    mouseWheelUp=false;
  }
}  

void keyPressed()
{
  if(key==CODED) {
  if(keyCode==UP) {
    keysButtons[0]=true;
    keysClick[0]=true; }
  if(keyCode==DOWN) {
    keysButtons[1]=true;
    keysClick[1]=true; }
  if(keyCode==LEFT) {
    keysButtons[2]=true;
    keysClick[2]=true; }
  if(keyCode==RIGHT) {
    keysButtons[3]=true;
    keysClick[3]=true; } }
  if(key=='w') {
    keysButtons[4]=true;
    keysClick[4]=true; }
  if(key=='c') {
    keysButtons[5]=true;
    keysClick[5]=true; }
  if(key==' ') {
    keysButtons[6]=true;
    keysClick[6]=true; }
  if(key=='a') {
    keysButtons[7]=true;
    keysClick[7]=true; }
  if(key=='p') {
    keysButtons[8]=true;
    keysClick[8]=true; }
  if(key=='h') {
    keysButtons[9]=true;
    keysClick[9]=true; }
}

void keyReleased()
{
  if(key==CODED) {
  if(keyCode==UP) {
    keysButtons[0]=false;
    keysUClick[0]=true; }
  if(keyCode==DOWN) {
    keysButtons[1]=false;
    keysUClick[1]=true; }
  if(keyCode==LEFT) {
    keysButtons[2]=false;
    keysUClick[2]=true; }
  if(keyCode==RIGHT) {
    keysButtons[3]=false;
    keysUClick[3]=true; } }
  if(key=='w') {
    keysButtons[4]=false;
    keysUClick[4]=true; }
  if(key=='c') {
    keysButtons[5]=false;
    keysUClick[5]=true; }
  if(key==' ') {
    keysButtons[6]=false;
    keysUClick[6]=true; }
  if(key=='a') {
    keysButtons[7]=false;
    keysUClick[7]=true; }
  if(key=='p') {
    keysButtons[8]=false;
    keysUClick[8]=true; }
  if(key=='h') {
    keysButtons[9]=false;
    keysUClick[9]=true; }
}

void mousePressed()
{
  if(mouseButton==LEFT) {
    mouseButtons[0]=true;
    mouseClick[0]=true; }
  if(mouseButton==RIGHT) {
    mouseButtons[1]=true;
    mouseClick[1]=true; }
  if(mouseButton==CENTER) {
    mouseButtons[2]=true;
    mouseClick[2]=true; }
}

void mouseReleased()
{
  if(mouseButton==LEFT) {
    mouseButtons[0]=false;
    mouseUClick[0]=true; }
  if(mouseButton==RIGHT) {
    mouseButtons[1]=false;
    mouseUClick[1]=true; }
  if(mouseButton==CENTER) {
    mouseButtons[2]=false;
    mouseUClick[2]=true; }
}

void mouseDragged() { mouseMove = true; }

void mouseMoved() { mouseMove = true; }
