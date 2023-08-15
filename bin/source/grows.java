import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class grows extends PApplet {

/*

            -- GROWING STRUCTURES GENERATOR --

projet version 2.0 : 
  l'auto regulation des pop parametrable
  grow regulé par nb de pop
  sprout par nb de grower
  stop par nb de grower
  mort par :
    age (def age min)
    nb de pop
    


add sauvegarder un screenshot sur le bouton I du panel
    attention! 
    la numerotation des fichier est baser sur le framecount
    deux fichier identique sur deux run et l'ancien est supprimer
    faire un truc mieux, il faut juste trouver comment test l'existance d'un fichier facilement

add graph pour les objets qui pousse en jaune (max afficher 60?)
  + switch pour l'afficher si bp graph est on

sur le graph:
faire apparaitre d'une autre couleur les "echec" : pop au max ou pop a zero

garder une image du graph ( le complet depuis le tour 0 de chaque run)

verifier la condition de mort par max de pop ateinte, limite trop franche (pixel perf) bizzard...

bp deactivation mort par max de pop ateint

switch antialiasing



une image peut ce reduire a 12 valeur

une seed
un nombre de tour depuit le debut

une camera :
  position x, y
  scale factor
  
un comportement:
  les difficulté:
    grow
    sprout
    stop
    die
  la limite d'age
  le deplacement:
    drifting (rotation posible en portion de pi (PI/drift))
    move (longeur max de chaque section)

add la possibilité d'afficher les valeur qui definisse l'image sur le screenshot
cree un soft dans lequel on entre les 12 valeur et qui genere l'image correspondante




quelque parametre valide :

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

presque stable a grande pop
GROW: true 0.48109692
SPROUT: true 717.9206
STOP: true 1.2851914
DIE: true 0.0015025112
OLD AGE: 140

*/
 //la lib pour les menu

ControlP5 cp5; //l'objet main pour les menu
Group cp5_g; // la grande tab 
Textlabel info1, info2, info3, info4; // les texte d'info, declarer pour pouvoir les modif
int PANEL_WIDTH = 400; //largeur de la tab

Base[] BaseList = new Base[0]; //contien les objet qui pousse (grower)
int MAX_LIST_SIZE = 5000; //longueur max de l'array d'objet

boolean DEBUG = true; //utilisable dans draw pour print
PVector cam_pos = new PVector(0, 0); //position de la camera
float cam_scale = 0.2f; //facteur de grossicement
float ZOOM_FACTOR = 1.1f; //facteur de modification de cam_scale quand on utilise la roulette de la sourie

int counter = 0; //conteur de tour depuis le dernier reset ou le debut

boolean screenshot = false; //enregistre une image de la frame sans les menu si true puis se desactive
//int shot_cnt = 0; //prevue pour la sauvegarde d'image avec des num coherent

// PERSO    ----------------
boolean pause = false; //permet d'interompre le defilement des tour

int SEED = 420; //seed pour l'aleatoire

int INIT_BASE = 50; //nombre de grower au debut puis apres un reset MODIFIABLE PAR MENU INIT

float DEVIATION = 8; //drifting (rotation posible en portion de pi (PI/drift))
float L_MIN = 1; //longeur minimum de chaque section
float L_MAX = 100; //longeur max de chaque section MODIFIABLE PAR MENU MOVE minimum 1 , limité dans l'update de sont bp

float MAX_LINE_WIDTH = 1.5f; //epaisseur max des ligne, diminuer par l'age, un peut, se vois pas
float MIN_LINE_WIDTH = 0.2f; //epaisseur min des ligne

// un switch les control dans le menu
boolean ON_GROW = true; // active la pousse de nouveau grower au bout des grower actif
boolean ON_SPROUT = true; // active le bourgeonnement de nouveau grower sur les branche
boolean ON_STOP = true; // active l'arret (devien vert)
boolean ON_DIE = true; // active la mort

//les dificulté sont appliqué a crandom, voir dans l'onglet utils elles on toute un control dans le menu
float GROW_DIFFICULTY = 1.0f;
float SPROUT_DIFFICULTY = 5000.0f;
float STOP_DIFFICULTY = 10.0f;
float DIE_DIFFICULTY = 7.2f;
int OLD_AGE = 400;

//diminue de autant la dificulté de la mort quand l'array est bientot plein
float DIE_DIFFICULTY_DIVIDER = 8.0f; //when array close to full

//permet l'enregistrement de donné pour le graphique
int larg =             1200;
int[] graph  = new int[1200];
int[] graph2 = new int[1200];
int gc = 0;

boolean SHOW_GRAPH = false;// affichage du graph a un bp
float repeat_runAll = 1; //nombre de fois ou il faut executé runall par frame
float repeating_pile = 0; //pile pour stocker les portion de repeat_runall quand il est < a 1

// PERSO    ----------------

public void setup() {//executé au demarage
  //taille de l'ecran
  setupInput();//voir onglet input
  //pas d'antialiasing
  //smooth();//anti aliasing
  
  //for (String s : PFont.list()) println(s); // liste toute les police de text qui existe

  init_panel(); //onglet panel : initialise le menu
  
  // redimensionement de l'array a ca taille max
  BaseList = (Base[]) expand(BaseList, MAX_LIST_SIZE);
  //initialisation de chaque element
  for (int i = 0 ; i < MAX_LIST_SIZE ; i++) {
    BaseList[i] = new Base();
    BaseList[i].id = i;
    BaseList[i].init(new PVector(0, 0), new PVector(0, 0), i);
  }
  //tout le monde sur off
  deleteAll();
  //reset du generateur de nombre aleatoire
  randomSeed(SEED);
  //creation des grower initiaux
  for (int i = 0; i < INIT_BASE; i++) {
    createFirstBase(random( 2 * PI));
  }
  
  //initialisation des array des graph
  for (int i = 0; i < larg; i++) { graph[i] = 0; graph2[i] = 0; }
  
}

public void draw() {//executé once by frame
  background(0);//fond noir
  
  // population tracking graph :
  //dessin
  if (SHOW_GRAPH) {
    strokeWeight(0.5f);
    stroke(255);
    for (int i = 1; i < larg; i++) if (i != gc) {
      stroke(255);
      line( (i-1), height - 10 - (graph[(i-1)] * (height-20) / 5000) ,
            i, height - 10 - (graph[i] * (height-20) / 5000) );
      stroke(255, 255, 0);
      line( (i-1), height - 10 - (graph2[(i-1)] * (height-20) / 80) ,
            i, height - 10 - (graph2[i] * (height-20) / 80) );
    }
    stroke(255, 0, 0);
    strokeWeight(7);
    if (gc != 0) {
      point(gc-1, height - 10 - (graph[gc-1] * (height-20) / 5000) );
      point(gc-1, height - 10 - (graph2[gc-1] * (height-20) / 80) );
    }
  }
  //enregistrement des donner dans les array
  if (!pause) {
    graph[gc] = baseNb();
    graph2[gc] = growsNb();
    if (gc < larg-1) gc++; else gc = 0;
  }
  
  //raccourcie barre espace -> pause
  if (keysClick[5]) {
    Button b = (Button)cp5.getController("running");
    if (b.isOn()) b.setOff(); else b.setOn();
  }
  
  //permet le cliquer glisser le l'ecran
  if (mouseButtons[0]) {
    cam_pos.x += mouseX - pmouseX;
    cam_pos.y += mouseY - pmouseY;
  }
  
  //permet le zoom
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
  
  //execute les fonction run de tout les objet actif dans baselist (a un ritme definie par repeat_runall)
  if (!pause) {
    repeating_pile += repeat_runAll;
    while (repeating_pile > 1) {
      runAll();
      counter++;
      repeating_pile--;
    }
  }
  
  // affichage
  // matrice d'affichage pour la camera
  pushMatrix();
  translate((width - PANEL_WIDTH) / 2, height / 2);
  scale(cam_scale);
  translate((cam_pos.x / cam_scale), (cam_pos.y / cam_scale));
  
  //execution des draw de tout les objet actif dans baselist
  drawAll();
  popMatrix(); // fin de la matrice d'affichage
  
  // enregistrement d'un screenshot si le flag est true
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
  
  //mise a jour des text du menu
  info1.setText("framerate: " + PApplet.parseInt(frameRate));
  info2.setText("turn: " + counter);
  info3.setText("object nb: " + baseNb());
  info4.setText("growing objects: " + growsNb());
  
  //peut servir
  if (DEBUG) {
    //println("Frame rate: " + int(frameRate));
    //println( " " );
    //println( counter + " " + growsNb());
  }
  
  inputUpdate(); //voir l'onglet input
}

//ici on definie les objet que l'on vas generer


class Base {
  
  int id;
  boolean exist;
  
  Base() {
    exist = false;
    id = 0;
  }
  
  // PERSO    ----------------
  PVector pos;
  PVector grows;
  PVector dir;
  
  // data
  //int root_id = 0;
  //int this_sprout_index = 0;
  //int sprouts_nb = 0;
  //int[] sprouts = new int[0];
  //int rang = 1;
  
  // condition de croissance
  boolean end = false;
  int sprouts = 0;
  float age = 0.0f;
  
  // PERSO    ----------------
  
  public void init(PVector _p, PVector _d, int _root_id) {    //argument are passed through createBase
    exist = true;
    // PERSO    ----------------
    //root_id = _root_id;
    //rang = BaseList[root_id].rang + 1;
    
    end = false;
    sprouts = 0;
    age = 0;
    
    pos = _p;
    grows = new PVector(L_MIN + crandom(3)*(L_MAX - L_MIN), 0);
    grows.rotate(_d.heading());
    grows.rotate(random(PI / DEVIATION) - ((PI / DEVIATION) / 2));
    dir = new PVector();
    dir = grows;
    grows = PVector.add(pos, grows);
    
     // PERSO    ----------------
  }
  
  public void destroy() {
    if (exist) {
      exist = false;
      // PERSO    ----------------
      //if (id != 0 && BaseList.length > 1) {
      //  for (int i = 0 ; i < sprouts.length ; i++) 
      //    if (sprouts[i] < BaseList.length) {
      //      //BaseList[sprouts[i]].destroy();
      //  }
      //  if (root_id < BaseList.length) {
      //    //BaseList[root_id].bourgeon = 
      //    //  int(constrain(BaseList[root_id].bourgeon - 1, 1, MAX_BOURGONS + 1 ));
      //    //BaseList[root_id].sprouts = 
      //    //  subset(BaseList[root_id].sprouts, this_sprout_index);
      //  } else { exist = true; }
      //}
      // PERSO    ----------------
    }
  }
  
  public void run() {
    // PERSO    ----------------
    
    age++;
    
    // grow
    if (ON_GROW && !end && sprouts == 0 && crandom(GROW_DIFFICULTY) > 0.5f) {
      createBase(grows, dir, id);
      sprouts++;
    }
    
    // sprout
    if (ON_SPROUT && !end && crandom(SPROUT_DIFFICULTY) > 0.5f) {
      createBase(grows, dir, id);
      sprouts++;
      //sprouts = (int[]) expand(sprouts, sprouts.length + 1);
      //sprouts[sprouts.length - 1] = temp_b.id;
      //temp_b.this_sprout_index = sprouts.length - 1;
      //sprouts_nb++;
    }
    
    // stop growing
    if (ON_STOP && !end && sprouts == 0 && crandom(STOP_DIFFICULTY) > 0.5f) {
      end = true;
    }
    
    // die
    float rng = crandom(DIE_DIFFICULTY);
    if (ON_DIE && 
         (rng > ( (float)OLD_AGE / (float)age ) ||
          rng / DIE_DIFFICULTY_DIVIDER > ((float)MAX_LIST_SIZE - (float)baseNb()) / (float)MAX_LIST_SIZE
       )) {
      this.destroy();
    }
    
    // PERSO    ----------------
  }
  
  public void drawing() {
    // PERSO    ----------------
    
    // aging color
    int ca = 255;
    if (age > OLD_AGE / 2) ca = (int)constrain(255 + PApplet.parseInt(OLD_AGE/2) - PApplet.parseInt(age/1.2f), 90, 255);
    if (!end && sprouts == 0) { stroke(255, 0, 0); strokeWeight(MAX_LINE_WIDTH+1 / cam_scale); }
    else if (end) { stroke(0, ca, 0); strokeWeight((MAX_LINE_WIDTH+1) / cam_scale); }
    else { stroke(ca, ca, ca); strokeWeight(((float)MIN_LINE_WIDTH + ((float)MAX_LINE_WIDTH * (float)ca / 255.0f)) / cam_scale); }              
    //fill(255);
    //ellipseMode(CENTER);
    //ellipse(pos.x, pos.y, 2, 2);
    
    line(pos.x,pos.y,grows.x,grows.y);
    strokeWeight(MAX_LINE_WIDTH+1 / cam_scale);
    //point(grows.x,grows.y);
    
    // PERSO    ----------------
  }

}

public Base createFirstBase(float r) { return createBase(new PVector(0, 0), new PVector(1, 0).rotate(r), 0); }

public Base createBase(PVector p, PVector d, int id) {
  for (int i = BaseList.length-1; i >= 0; i--) {
    if (!BaseList[i].exist) {
      BaseList[i].init(p, d, id);
      return BaseList[i];
    }
  }
  return null;
}

public void runAll() {
  for (int i = BaseList.length-1; i >= 0; i--) {
    if (BaseList[i].exist ) {
      BaseList[i].run();
    }
  }
}

public void drawAll() {
  for (int i = BaseList.length-1; i >= 0; i--) {
    if (BaseList[i].exist ) {
      BaseList[i].drawing();
    }
  }
}

public void deleteAll() {
  for (int i = BaseList.length-1; i >= 0; i--) {
    if (BaseList[i].exist) {
      BaseList[i].destroy();
    }
  }
}

public int baseNb() {
  int n = 0;
  for (int i = BaseList.length-1; i >= 0; i--) {
    if (BaseList[i].exist ) {
      n++;
    }
  }
  return n;
}

public int growsNb() {
  int n = 0;
  for (int i = BaseList.length-1; i >= 0; i--) {
    if (BaseList[i].exist && !BaseList[i].end && BaseList[i].sprouts == 0) {
      n++;
    }
  }
  return n;
}


//ici c'est super mal foutu

//mais sa gere les boutton du clavier et de la sourie

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

public void inputUpdate() {
  mouseCoord.x = mouseX; mouseCoord.y = mouseY;
  //mouseGridCoord = screenCoordTOGridCoord(mouseCoord);
  mouseWheelUp = false; mouseWheelDown = false;
  if (mouseX == pmouseX && mouseY == pmouseY) {mouseMove = false;}
  for (int i = mouseClick.length-1; i >= 0; i--) {if (mouseJClick[i] == true && mouseClick[i] == true) {mouseJClick[i] = false; mouseClick[i] = false;}}
  for (int i = mouseJClick.length-1; i >= 0; i--) {if (mouseJClick[i] == true) {mouseClick[i] = true;}}
  for (int i = keysClick.length-1; i >= 0; i--) {if (keysJClick[i] == true && keysClick[i] == true) {keysJClick[i] = false; keysClick[i] = false;}}
  for (int i = keysJClick.length-1; i >= 0; i--) {if (keysJClick[i] == true) {keysClick[i] = true;}}
}

public void setupInput() {
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

public boolean upPress() {
  if (keysButtons[0]) {return true;}
  return false;
}

public boolean downPress() {
  if (keysButtons[1]) {return true;}
  return false;
}

public boolean leftPress() {
  if (keysButtons[2]) {return true;}
  return false;
}

public boolean rightPress() {
  if (keysButtons[3]) {return true;}
  return false;
}

public void mouseWheel(MouseEvent event) {
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

public void keyPressed()
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
  if(key==' ') {
    keysButtons[5]=true;}
    
  if(key=='p' && DEBUG) {
    //RUN = !RUN;
  }
  if(key==' ' && DEBUG) {
    //energyGrid.updateCells();
  }
}

public void keyReleased()
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
  if(key==' ') {
    keysButtons[5]=false;
    keysJClick[5]=true;}
  
  //if(key=='p' && DEBUG) {
  //  RUN = true;
  //}
}

public void mousePressed()
{
  if(mouseButton==LEFT) {
    mouseButtons[0]=true;}
  if(mouseButton==RIGHT) {
    mouseButtons[1]=true;}
  if(mouseButton==CENTER) {
    mouseButtons[2]=true;}
}

public void mouseReleased()
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

public void mouseDragged() { mouseMove = true; }

public void mouseMoved() { mouseMove = true; }

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

//ici on gere le menu


int TEXT_SIZE = 18;
int BTN_SIZE = 40;

Textfield textfieldSeed;

int maxctrlerByLine = 10;
int utilctrlid = 1000;

// modify by a factor
public void build_line_factor(String name, float val, float x, float y, int id) {
  id *= maxctrlerByLine;
  addButton(name + "-x2", "x2", x + 340, y + 0, BTN_SIZE, BTN_SIZE, id+1, TEXT_SIZE);
  addButton(name + "-x1", "x1.2", x + 290, y + 0, BTN_SIZE, BTN_SIZE, id+2, TEXT_SIZE);
  addButton(name + "-/1", "/1.2", x + 50, y + 0, BTN_SIZE, BTN_SIZE, id+3, TEXT_SIZE);
  addButton(name + "-/2", "/2", x + 0, y + 0, BTN_SIZE, BTN_SIZE, id+4, TEXT_SIZE);
  addText(name + "-label", name + ": " + val, x + 140, y + 10).setId(id);
}

// modify by increment
public void build_line_incr(String name, float val, float x, float y, int id) {
  id *= maxctrlerByLine;
  addButton(name + "-min10", "-10", x + 0, y + 0, BTN_SIZE, BTN_SIZE, id+5, TEXT_SIZE);
  addButton(name + "-min1", "-1", x + 50, y + 0, BTN_SIZE, BTN_SIZE, id+6, TEXT_SIZE);
  addButton(name + "-maj1", "+1", x + 290, y + 0, BTN_SIZE, BTN_SIZE, id+7, TEXT_SIZE);
  addButton(name + "-maj10", "+10", x + 340, y + 0, BTN_SIZE, BTN_SIZE, id+8, TEXT_SIZE);
  addText(name + "-label", name + ": " + val, x + 140, y + 15).setId(id);
}

public void init_panel() {
  cp5 = new ControlP5(this);
  
  cp5_g = cp5.addGroup("g1")
             .setPosition(width - PANEL_WIDTH, 10)
             .setSize(PANEL_WIDTH, 10)
             .setBackgroundHeight(height)
             .setBackgroundColor(color(255,50))
             ;
             
  addText("title1", "GROWING STRUCTURES", 15, 0, 30).setFont(createFont("Arial Bold",30));
  
  addText("title2", "Difficulty", 140, 40, 24);
  build_line_factor("GROW", GROW_DIFFICULTY, 10, 70, 0);
  build_line_factor("SPROUT", SPROUT_DIFFICULTY, 10, 120, 1);
  build_line_factor("STOP", STOP_DIFFICULTY, 10, 170, 2);
  build_line_factor("DIE", DIE_DIFFICULTY, 10, 220, 3);
  build_line_factor("AGING", OLD_AGE, 10, 270, 4);
  
  Button b; //pointer
  
  b = addButton("ON_GROW", "", 110+5, 70+5, BTN_SIZE-10, BTN_SIZE-10, utilctrlid + 4, TEXT_SIZE)
    .setSwitch(true);
  if (ON_GROW) b.setOn();
  b = addButton("ON_SPROUT", "", 110+5, 120+5, BTN_SIZE-10, BTN_SIZE-10, utilctrlid + 5, TEXT_SIZE)
    .setSwitch(true);
  if (ON_SPROUT) b.setOn();
  b = addButton("ON_STOP", "", 110+5, 170+5, BTN_SIZE-10, BTN_SIZE-10, utilctrlid + 6, TEXT_SIZE)
    .setSwitch(true);
  if (ON_STOP) b.setOn();
  b = addButton("ON_DIE", "", 110+5, 220+5, BTN_SIZE-10, BTN_SIZE-10, utilctrlid + 7, TEXT_SIZE)
    .setSwitch(true);
  if (ON_DIE) b.setOn();
  
  addText("title3", "Movement", 140, 400, 24);
  build_line_factor("DRIFT", DEVIATION, 10, 430, 7);
  build_line_factor("MOVE", L_MAX, 10, 480, 8);
  
  addText("title4", "Utilitaires", 140, 550, 24);
  
  info1 = addText("info1", " ", 50, 590);
  info2 = addText("info2", " ", 50, 620);
  info3 = addText("info3", " ", 200, 590);
  info4 = addText("info4", " ", 200, 620);
  
  b = addButton("GRAPH", "graphic", 150, 660, 100, 30, utilctrlid + 8, TEXT_SIZE)
    .setSwitch(true);
  if (SHOW_GRAPH) b.setOn();
  
  addText("title5", "Seed", 20, 705, TEXT_SIZE);
  textfieldSeed = cp5.addTextfield("seed_input")
     .setPosition(90,700)
     .setSize(220,30)
     .setCaptionLabel("")
     .setValue("" + SEED)
     .setFont(createFont("Arial",TEXT_SIZE))
     .setColor(color(255))
     .setGroup(cp5_g)
     ;
  addButton("readseed", "V", 320, 700, 30, 30, utilctrlid + 9, TEXT_SIZE);
  addButton("rngseed", "R", 360, 700, 30, 30, utilctrlid + 10, TEXT_SIZE);
  
  build_line_factor("SPEED", repeat_runAll, 10, 740, 5);
  build_line_incr("INIT", INIT_BASE, 10, 785, 6);
  
  b = addButton("running", "p", 25, 830, 50, 50, utilctrlid + 3, TEXT_SIZE * 1.5f)
    .setSwitch(true);
  if (pause) b.setOn();
  addButton("reset", "RESET", 100, 830, 200, 50, utilctrlid + 1, TEXT_SIZE * 1.5f);
  addButton("print", "I", 325, 830, 50, 50, utilctrlid + 2, TEXT_SIZE * 1.5f);
}



public void controlEvent(ControlEvent theEvent) {
  int id = theEvent.getId(); //on va retrouver le controlleur corespondant par sont id
  
  // boutton reset
  if (id == utilctrlid + 1) {
    deleteAll();
    randomSeed(SEED);
    for (int i = 0; i < INIT_BASE; i++) {
      createFirstBase(random( 2 * PI));
    }
    //reset le graph
    for (int i = 0; i < larg; i++) { graph[i] = 0; graph2[i] = 0; }
    gc = 0;
    //reset le conter de tour
    counter = 0;
    return;
  }
  
  // boutton print
  if (id == utilctrlid + 2) {
    println();
    println("GROW: " + ON_GROW + " " + GROW_DIFFICULTY);
    println("SPROUT: " + ON_SPROUT + " " + SPROUT_DIFFICULTY);
    println("STOP: " + ON_STOP + " " + STOP_DIFFICULTY);
    println("DIE: " + ON_DIE + " " + DIE_DIFFICULTY);
    println("OLD AGE: " + OLD_AGE);
    println();
    screenshot = true;
    return;
  }
  
  //button pause
  if (id == utilctrlid + 3) {
    Button b = (Button)cp5.getController("running");
    pause = b.isOn();
  }
  //button graph
  if (id == utilctrlid + 8) {
    Button b = (Button)cp5.getController("GRAPH");
    SHOW_GRAPH = b.isOn();
  }
  //button seed
  if (id == utilctrlid + 9) { //read
    int val = PApplet.parseInt(textfieldSeed.getText());
    if (val != 0) {
      SEED = val;
      textfieldSeed.setColor(color(255));
    } else {
      textfieldSeed.setColor(color(255, 0, 0));
    }
  }
  if (id == utilctrlid + 10) { //rng
    SEED = PApplet.parseInt(random(1000000000));
    textfieldSeed.setValue("" + SEED);
  }
  //activation
  if (id == utilctrlid + 4) {
    Button b = (Button)cp5.getController("ON_GROW");
    ON_GROW = b.isOn();
  }
  if (id == utilctrlid + 5) {
    Button b = (Button)cp5.getController("ON_SPROUT");
    ON_SPROUT = b.isOn();
  }
  if (id == utilctrlid + 6) {
    Button b = (Button)cp5.getController("ON_STOP");
    ON_STOP = b.isOn();
  }
  if (id == utilctrlid + 7) {
    Button b = (Button)cp5.getController("ON_DIE");
    ON_DIE = b.isOn();
  }
  
  //find the right ctrl
  int line = PApplet.parseInt((float)id / (float)maxctrlerByLine);
  int ctrl = id - (line * maxctrlerByLine);
  float modifier = 1.0f;
  if (ctrl == 1) modifier = 2.0f;
  if (ctrl == 2) modifier = 1.2f;
  if (ctrl == 3) modifier = 0.833f;
  if (ctrl == 4) modifier = 0.5f;
  if (ctrl == 5) modifier = -10;
  if (ctrl == 6) modifier = -1;
  if (ctrl == 7) modifier = 1;
  if (ctrl == 8) modifier = 10;
  
  // apply modifier
  if (line == 0) { GROW_DIFFICULTY *= modifier; update_textlabel("GROW", GROW_DIFFICULTY); }
  if (line == 1) { SPROUT_DIFFICULTY *= modifier; update_textlabel("SPROUT", SPROUT_DIFFICULTY); }
  if (line == 2) { STOP_DIFFICULTY *= modifier; update_textlabel("STOP", STOP_DIFFICULTY); }
  if (line == 3) { DIE_DIFFICULTY *= modifier; update_textlabel("DIE", DIE_DIFFICULTY); }
  if (line == 4) { OLD_AGE *= modifier; update_textlabel("AGING", OLD_AGE); }
  
  if (line == 7) { DEVIATION *= modifier; update_textlabel("DRIFT", DEVIATION); }
  if (line == 8) { L_MAX *= modifier; L_MAX = max(L_MAX, 1); update_textlabel("MOVE", L_MAX);}
  
  if (line == 5) { repeat_runAll *= modifier; update_textlabel("SPEED", repeat_runAll); }
  if (line == 6) { INIT_BASE += modifier; update_textlabel("INIT", INIT_BASE); }
  
  
}

public void update_textlabel(String name, float val) {
  Textlabel t = (Textlabel)cp5.getController(name + "-label");
  t.setText(name + ": " + val);
}


//easy building

public Textlabel addText(String name, String label, float x, float y, int st) {
  return cp5.addTextlabel(name)
     .setText(label)
     .setPosition(x, y)
     .setColorValue(0xffffffff)
     .setFont(createFont("Arial",st))
     .setGroup(cp5_g)
     ;
}

public Textlabel addText(String name, String label, float x, float y) {
  return addText(name, label, x, y, TEXT_SIZE);
}

public Button addButton(String name, String label, float x, float y, int sx, int sy, int id, float st) {
  Button b = cp5.addButton(name)
     .setPosition(x, y)
     .setSize(sx,sy)
     .setGroup(cp5_g)
     .setId(id)
     ;
  b.getCaptionLabel().setText(label).setFont(createFont("Arial",st));
  return b;
}
// des truc utils en vrac

public PVector mouseDir(PVector center) {
  PVector dir = new PVector(0, 0); 
  dir.x = mouseX - center.x;
  dir.y = mouseY - center.y;
  dir.setMag(1);
  return dir;
}

public PVector randomVect(int mag) {
  PVector rnd = new PVector(0, 0); 
  rnd.x = random(10) - 5;
  rnd.y = random(10) - 5;
  rnd.setMag(mag);
  return rnd;
}


public boolean isInside(float value, float min, float max) {
  if (value > min && value < max) {return true;} else {return false;}
}

public float crandom(float d) {
  return pow(random(1.0f), d) ;
}
  public void settings() {  size(1600, 900);  noSmooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "grows" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
