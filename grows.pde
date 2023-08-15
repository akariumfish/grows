/*

            -- GROWING STRUCTURES GENERATOR --



add sauvegarder un screenshot sur le bouton I du panel
    attention! 
    la numerotation des fichier est baser sur le framecount
    deux fichier identique sur deux run et l'ancien est supprimer
    faire un truc mieux, il faut juste trouver comment test l'existance d'un fichier facilement

add choisir la seed pour l'aleatoire

add graph pour les objets qui pousse en jaune (max afficher 60?)
  + switch pour l'afficher si bp graph est on



Valid parameters :

def :
GROW: 1.0
SPROUT: 5000.0
STOP: 10.0
DIE: 7.2
OLD AGE: 400

GROW: 2.4
SPROUT: 20000.0
STOP: 133.28
DIE: 1.2490002
OLD AGE: 400





*/
import controlP5.*;

ControlP5 cp5;
Group cp5_g;
Textlabel info1, info2, info3, info4;
int PANEL_WIDTH = 400;

PFont standard_font;

Base[] BaseList = new Base[0];
int MAX_LIST_SIZE = 5000;

boolean DEBUG = true;
PVector cam_pos = new PVector(0, 0);
float cam_scale = 0.2;
float ZOOM_FACTOR = 1.1;

int counter = 0;
int flip = 0;

boolean screenshot = false;
int shot_cnt = 0;

// PERSO    ----------------
boolean pause = false;

PVector DEF_POS = new PVector(0, 0);
float DEF_DIR = 0.0;
int INIT_BASE = 50;

float DEVIATION = 8;
float L_MIN = 1;
float L_MAX = 100; //minimum 1 , limité dans l'update de sont bp

boolean ON_GROW = true;
boolean ON_SPROUT = true;
boolean ON_STOP = true;
boolean ON_DIE = true;

float GROW_DIFFICULTY = 1.0;
float SPROUT_DIFFICULTY = 5000.0;
float STOP_DIFFICULTY = 10.0;
float DIE_DIFFICULTY = 7.2;
int OLD_AGE = 400;

float DIE_DIFFICULTY_DIVIDER = 8.0; //when array close to full

//util
int larg =            1200;
int[] graph = new int[1200];
int gc = 0;
boolean SHOW_GRAPH = false;
float repeat_runAll = 1;
float repeating_pile = 0;

// PERSO    ----------------

void setup() {
  size(1600, 900);
  setupInput();
  randomSeed(420);
  noSmooth();
  
  //for (String s : PFont.list()) println(s);

  init_panel();
  
  // PERSO    ----------------
  for (int i = 0; i < INIT_BASE; i++) {
    createFirstBase(random( 2 * PI));
  }
  
  for (int i = 0; i < larg; i++) graph[i] = 0;
  // PERSO    ----------------
  
  println();
  
}

void draw() {
  background(0);
  
  counter++;
  
  // PERSO    ----------------
  
  // population tracking graph :
  if (SHOW_GRAPH) {
    strokeWeight(0.5);
    stroke(255);
    for (int i = 1; i < larg; i++) if (i != gc)
      line( (i-1), height - 10 - (graph[(i-1)] * (height-20) / 5000) ,
            i, height - 10 - (graph[i] * (height-20) / 5000) );
    stroke(255, 0, 0);
    strokeWeight(7);
    if (gc != 0)point(gc-1, height - 10 - (graph[gc-1] * (height-20) / 5000) );
  }
  if (!pause) {
    graph[gc] = baseNb();
    if (gc < larg-1) gc++; else gc = 0;
  }
  
  if (keysClick[5]) {
    Button b = (Button)cp5.getController("running");
    if (b.isOn()) b.setOff(); else b.setOn();
  }
  
  if (mouseButtons[0]) {
    cam_pos.x += mouseX - pmouseX;
    cam_pos.y += mouseY - pmouseY;
  }
  
  if (mouseWheelUp || keysClick[2]) {
    cam_scale *= ZOOM_FACTOR;
    cam_pos.x *= ZOOM_FACTOR;
    cam_pos.y *= ZOOM_FACTOR;
  }
  
  if (mouseWheelDown || keysClick[3]) {
    cam_scale /= ZOOM_FACTOR;
    cam_pos.x /= ZOOM_FACTOR;
    cam_pos.y /= ZOOM_FACTOR;
  }
  
  
  if (!pause) {
    repeating_pile += repeat_runAll;
    while (repeating_pile > 1) {
      runAll();
      repeating_pile--;
    }
  }
  
  
  
  pushMatrix();
  translate((width - PANEL_WIDTH) / 2, height / 2);
  scale(cam_scale);
  translate((cam_pos.x / cam_scale), (cam_pos.y / cam_scale));
  
  drawAll();
  popMatrix();
  if (screenshot) {
    //String name = "shot" + shot_cnt + ".png";
    
    //File file = new File(sketchPath(name));
    //while (file.exists()) {
    //  shot_cnt++;
    //  name = "shot" + shot_cnt + ".png";
    //  file = new File(sketchPath(name));
    //}
    saveFrame("shot-########.png");
  }
  screenshot = false;

  if (DEBUG) {
    //println("Frame rate: " + int(frameRate));
    //println( " " );
    //println( counter + " " + growsNb());
    info1.setText("framerate: " + int(frameRate));
    info2.setText("turn: " + counter);
    info3.setText("object nb: " + baseNb());
    info4.setText("growing objects: " + growsNb());
  }
  
  inputUpdate();
}
