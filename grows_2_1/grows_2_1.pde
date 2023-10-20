/*

           




*/

ControlP5 cp5; //l'objet main pour les menu
SpecialValue simval = new SpecialValue();
Camera cam = new Camera();
ComunityList comlist;

Channel frame_chan = new Channel();
Channel tick_chan = new Channel();

sGraph graph = new sGraph();

sInt tick = new sInt(simval, 0); //conteur de tour depuis le dernier reset ou le debut
sBoo pause = new sBoo(simval, false); //permet d'interompre le defilement des tour
sFlt tick_by_frame = new sFlt(simval, 1); //nombre de tour a executé par frame
float tick_pile = 0; //pile des tour
sInt SEED = new sInt(simval, 548651008); //seed pour l'aleatoire
sInt framerate = new sInt(simval, 0);
sBoo auto_reset = new sBoo(simval, true);
sBoo auto_reset_rng_seed = new sBoo(simval, true);
sInt auto_reset_turn = new sInt(simval, 4000);
sBoo auto_screenshot = new sBoo(simval, false);

GrowerComu gcom;
FlocComu fcom;

void setup() {//executé au demarage
  size(1600, 900);//taille de l'ecran
  //fullScreen();
  setupInput();//voir input plus bas
  noSmooth();//pas d'antialiasing
  //smooth();//anti aliasing
  frameRate(60);
  
  cam.cam_pos.x = -200;
  
  init_panel();
  
  init_canvas();
  
  comlist = new ComunityList();
  
  gcom = new GrowerComu(comlist);
  gcom.hide_entity();
  gcom.hide_menu();
  
  fcom = new FlocComu(comlist);
  
  comlist.comunity_reset();
  
  graph.init();
  
}

void draw() {//executé once by frame
  background(0);//fond noir
  
  //drive l'execution
  if (!pause.get()) {
    tick_pile += tick_by_frame.get();
    
    //auto screenshot before reset
    if (auto_reset.get() && auto_reset_turn.get() == tick.get() + tick_by_frame.get() + tick_by_frame.get() && auto_screenshot.get()) {
        cam.screenshot = true; }
    
    while (tick_pile >= 1) {
      //tick call
      callChannel(tick_chan);
      
      //tick communitys
      comlist.tick();
      
      tick.set(tick.get()+1);
      tick_pile--;
      
      //auto reset
      if (auto_reset.get() && auto_reset_turn.get() <= tick.get()) {
        if (auto_reset_rng_seed.get()) {
          SEED.set(int(random(1000000000)));
        }
        reset();
      }
    }
    
    //run_each_unpaused_frame
    
    //get value pour le graph
    graph.update(gcom.active_Entity_Nb(), gcom.grower_Nb());
    
    //add halo for each entity of floc community
    can.drawHalo(fcom);
  }
  
  //run_each_frame
  callChannel(frame_chan);
  
  //update des macros
  mList.update();
  
  // affichage
  // apply camera view
  cam.pushCam();
  
  //canvas
  can.drawCanvas();
  
  //community
  comlist.draw();
  
  //pop cam view and cam updates
  cam.popCam();
  
  graph.draw();
  
  mList.drawing();
  
  //framerate:
  fill(255); textSize(16);
  text(int(frameRate),10,height - 10 );
  
  simval.unFlagChange();
  
  framerate.set(int(frameRate));
  
  inputUpdate(); //voir l'onglet input
}

void reset() {
  comlist.comunity_reset();
  tick.set(0);
}




//#######################################################################
//##                             CAMERA                                ##
//#######################################################################


class Camera {
  PVector cam_pos = new PVector(0, 0); //position de la camera
  float cam_scale = 1.0; //facteur de grossicement
  float ZOOM_FACTOR = 1.1; //facteur de modification de cam_scale quand on utilise la roulette de la sourie
  boolean GRAB = true;
  boolean screenshot = false; //enregistre une image de la frame sans les menu si true puis se desactive
  
  boolean matrixPushed = false;
  
  sBoo grid = new sBoo(simval, true);
  
  Channel zoom_chan = new Channel();
  
  PVector cam_to_screen(PVector p) {
    PVector r = new PVector();
    if (matrixPushed) {
      r.x = screenX(p.x, p.y); r.y = screenY(p.x, p.y);
    } else {
      pushMatrix();
      translate(width / 2, height / 2);
      scale(cam_scale);
      translate((cam_pos.x / cam_scale), (cam_pos.y / cam_scale));
      
      r.x = screenX(p.x, p.y); r.y = screenY(p.x, p.y);
      
      popMatrix();
    }
    return r;
  }
  
  PVector screen_to_cam(PVector p) {
    PVector r = new PVector();
    if (matrixPushed) {
      pushMatrix();
      translate(-(cam_pos.x / cam_scale), -(cam_pos.y / cam_scale));
      scale(1/cam_scale);
      translate(-width / 2, -height / 2);
      
      translate(-(cam_pos.x / cam_scale), -(cam_pos.y / cam_scale));
      scale(1/cam_scale);
      translate(-width / 2, -height / 2);
      
      r.x = screenX(p.x, p.y); r.y = screenY(p.x, p.y);
      popMatrix();
    } else {
      pushMatrix();
      translate(-(cam_pos.x / cam_scale), -(cam_pos.y / cam_scale));
      scale(1/cam_scale);
      translate(-width / 2, -height / 2);
      r.x = screenX(p.x, p.y); r.y = screenY(p.x, p.y);
      popMatrix();
    }
    return r;
  }
  
  void pushCam() {
    pushMatrix();
    translate(width / 2, height / 2);
    scale(cam_scale);
    translate((cam_pos.x / cam_scale), (cam_pos.y / cam_scale));
    matrixPushed = true;
    
    if (grid.get() && cam_scale > 0.0008) {
      int spacing = 200;
      if (cam_scale > 2) spacing /= 5;
      if (cam_scale < 0.2) spacing *= 5;
      if (cam_scale < 0.04) spacing *= 5;
      if (cam_scale < 0.008) spacing *= 5;
      stroke(100);
      strokeWeight(2.0 / cam_scale);
      PVector s = screen_to_cam(new PVector(-spacing * cam_scale, -spacing * cam_scale));
      s.x -= s.x%spacing; s.y -= s.y%spacing;
      PVector m = screen_to_cam( new PVector(width, height) );
      for (float x = s.x ; x < m.x ; x += spacing) {
        if ( ( (x-(x%spacing)) / spacing) % 5 == 0 ) stroke(100); else stroke(70);
        if (x == 0) stroke(150, 0, 0);
        line(x, s.y, x, m.y);
      }
      for (float y = s.y ; y < m.y ; y += spacing) {
        if ( ( (y-(y%spacing)) / spacing) % 5 == 0 ) stroke(100); else stroke(70);
        if (y == 0) stroke(150, 0, 0);
        line(s.x, y, m.x, y);
      }
    }
  }
  
  void popCam() {
    popMatrix();
    matrixPushed = false;
    if (screenshot) { saveFrame("image/shot-########.png"); }
    screenshot = false;
    
    //permet le cliquer glisser le l'ecran
    if (mouseButtons[0] && GRAB) { cam_pos.add(mouseX - pmouseX, mouseY - pmouseY); }
    
    //permet le zoom
    if (mouseWheelUp) { cam_scale /= ZOOM_FACTOR; cam_pos.mult(1/ZOOM_FACTOR); callChannel(zoom_chan); }
    if (mouseWheelDown) { cam_scale *= ZOOM_FACTOR; cam_pos.mult(ZOOM_FACTOR); callChannel(zoom_chan); }
  }
}



//#######################################################################
//##                             INPUT                                 ##
//#######################################################################

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
