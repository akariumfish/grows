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

public class grows_1_1 extends PApplet {

/*

            -- GROWING STRUCTURES GENERATOR --



--corriger les beug d'affichage des macro (irregularité en y sur les bp des i/o) 
--corriger numerotation des screenshots
    la numerotation des fichier est baser sur le framecount
    deux fichier identique sur deux run et l'ancien est supprimer
    faire un truc mieux, il faut juste trouver comment test l'existance d'un fichier facilement


sauvegarde !!
  la traduction en StringList de macroworld est faite <- a verif apres merge macro world et list
  la remise a zero de macroworld aussi <- a verif apres merge macro world et list
  a faire :
    --construction de macrolist a partir d'un stringlist
    --selecteur de fichier source/cible
    --menu group dedier
    --sauvegarde sous different titre dans un fichier
    --lecture
    
Les macro sont un outils de patch/programmation visuelle
qui permettra par exemple une auto regulation des pop parametrable
  grow regulé par nb de pop
  sprout par nb de grower
  stop par nb de grower
  mort par :
    age (def age min)
    nb de pop
ajouter:
  --ajout et suppression de macros
  --collapsing macros
  type de macro:
    --on/off growing behaviors
    --switch pause
    --change speed
    trig chaque bp des menu en gros...
    --multi val one trig
    --1 line delay
    --environs = : 3 float in , 1 trig out
    --trigger chain : 1 trig X float in (times), X trig out

--ajouter des menu pour control taille baselist
--bp pour faire passer juste un tour (+raccourcie clavier)
--affichage du framerate plus lisible : calcul du framerate moyen sur la derniere sec
--add switch pour afficher graph des objets qui pousse si bp graph est on
--sur le graph, faire apparaitre d'une autre couleur les "echec" : pop au max ou pop a zero
garder une image du graph ( le complet depuis le tour 0 de chaque run)
--switch antialiasing



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





*/

//definition des variable principale
boolean DEBUG = true; //utilisable dans draw pour print
int counter = 0; //conteur de tour depuis le dernier reset ou le debut
boolean pause = false; //permet d'interompre le defilement des tour
float repeat_runAll = 4; //nombre de fois ou il faut executé runall par frame
float repeating_pile = 0; //pile pour stocker les portion de repeat_runall quand il est < a 1
int SEED = 548651008; //seed pour l'aleatoire
int slide = 0;
int maxSlide = 1;
int repeat_turn = 2000;
boolean auto_repeat = true;
boolean repeat_random = true;

boolean adding_type = true;
int adding_pile = 0;
float adding_step = 30; // add one new object each adding_step turn
float adding_counter = 0;

//ici on as les fonctions principale de processing, 
//elles geres l'arrengement des differente features
//plus bas ya des methodes utile qui vont nul par ailleur

public void setup() {//executé au demarage
  //size(1720, 900);//taille de l'ecran
  
  
  setupInput();//voir onglet input
  //pas d'antialiasing
  //smooth();//anti aliasing
  frameRate(60);
  
  //for (String s : PFont.list()) println(s); // liste toute les police de text qui existe
  
  init_panel(); //onglet panel : initialise le menu
  init_base();
  
  //saving();
  
}

public void draw() {//executé once by frame
  background(0);//fond noir
  
  if (!pause) {
    repeating_pile += repeat_runAll;
    while (repeating_pile > 1) {
      
      //run_speeded:  execute a un ritme definie par repeat_runall
      
      if (adding_type && adding_pile >= 1) {
        adding_counter++;
        if (adding_counter >= adding_step) {
          adding_counter = 0;
          create_init_base();
          adding_pile--;
        }
      }
      
      runAll();
      
      counter++;
      repeating_pile--;
      if (auto_repeat && repeat_turn <= counter) {
        if (repeat_random) {
          SEED = PApplet.parseInt(random(1000000000));
          textfieldSeed.setValue("" + SEED);
        }
        reset();
      }
    }
    
    //run_each_unpaused_frame:
    update_graph();
  }
  
  //run_each_frame:
  //raccourcie barre espace -> pause
  if (keysClick[6]) {
    Button b = (Button)cp5.getController("running");
    if (b.isOn()) b.setOff(); else b.setOn();
  }
  update_all_menu();
  mList.update();

  // affichage
  
  //draw_on_screen:
  draw_graphs(); // population et grower tracking graph
  if (!cp5.getTab("default").isActive()) {// draw framerate
    fill(255);
    textSize(16);
    text(PApplet.parseInt(frameRate),10,height - 10 );
  }
  
  pushMatrix();
  cam_movement(); // matrice d'affichage pour la camera
  
  //draw_on_camera:
  
  drawAll();
  
  popMatrix(); // fin de la matrice d'affichage
  try_screenshot();
  
  //draw_after_screenshot:
  mList.drawing();
  
  
  //peut servir
  if (DEBUG) {
    //println("Frame rate: " + int(frameRate));
    //println( " " );
    //println( counter + " " + growsNb());
  }
  
  cam_input_update();
  inputUpdate(); //voir l'onglet input
}

public void simcontrol_to_strings() {
  file.append("simcontrol:");
  file.append(str(counter));
  file.append(str(pause));
  file.append(str(repeat_runAll));
  file.append(str(repeating_pile));
  file.append(str(SEED));
  file.append(str(slide));
  file.append(str(maxSlide));
}

public void reset() {
  
  
  
  reset_base();
  init_graphs();

  //reset le conter de tour
  counter = 0;
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

public void inputUpdate() {
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

public void setupInput() {
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

public void mouseWheel(MouseEvent event) {
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

public void keyPressed()
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

public void keyReleased()
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

public void mousePressed()
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

public void mouseReleased()
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

public void mouseDragged() { mouseMove = true; }

public void mouseMoved() { mouseMove = true; }





//#######################################################################
//##                             CAMERA                                ##
//#######################################################################


PVector cam_pos = new PVector(0, 0); //position de la camera
float cam_scale = 8; //facteur de grossicement
float ZOOM_FACTOR = 1.1f; //facteur de modification de cam_scale quand on utilise la roulette de la sourie
boolean GRAB = true;

boolean screenshot = false; //enregistre une image de la frame sans les menu si true puis se desactive
//int shot_cnt = 0; //prevue pour la sauvegarde d'image avec des num coherent

public void cam_input_update() {
  //permet le cliquer glisser le l'ecran
  if (mouseButtons[0] && GRAB) {
    cam_pos.x += mouseX - pmouseX;
    cam_pos.y += mouseY - pmouseY;
  }
  
  //permet le zoom
  if (mouseWheelUp || keysClick[2]) {
    cam_scale /= ZOOM_FACTOR;
    cam_pos.x /= ZOOM_FACTOR;
    cam_pos.y /= ZOOM_FACTOR;
  }
  if (mouseWheelDown || keysClick[3]) {
    cam_scale *= ZOOM_FACTOR;
    cam_pos.x *= ZOOM_FACTOR;
    cam_pos.y *= ZOOM_FACTOR;
  }
}

public void cam_movement() {
  translate((width - PANEL_WIDTH) / 2, height / 2);
  scale(cam_scale);
  translate((cam_pos.x / cam_scale), (cam_pos.y / cam_scale));
}

public void try_screenshot() {
  // enregistrement d'un screenshot si le flag est true
  if (screenshot) {
    //String name = "shot" + shot_cnt + ".png";
    
    //File file = new File(sketchPath(name));
    //while (file.exists()) {
    //  shot_cnt++;
    //  name = "shot" + shot_cnt + ".png";
    //  file = new File(sketchPath(name));
    //}
    saveFrame("image/shot-########.png");
  }
  screenshot = false;
}





//#######################################################################
//##                         METHODES UTILES                           ##
//#######################################################################


public String popStrLst(StringList sl) {
  String s = sl.get(sl.size() - 1);
  sl.remove(sl.size() - 1);
  return s;
}

public float distancePointToLine(float x, float y, float x1, float y1, float x2, float y2) {
  float r =  ( ((x-x1)*(x2-x1)) + ((y-y1)*(y2-y1)) ) / pow(distancePointToPoint(x1, y1, x2, y2), 2);
  if (r <= 0) {return distancePointToPoint(x1, y1, x, y);}
  if (r >= 1) {return distancePointToPoint(x, y, x2, y2);}
  float px = x1 + (r * (x2-x1));
  float py = y1 + (r * (y2-y1));
  return distancePointToPoint(x, y, px, py);
}

public float distancePointToPoint(float xa, float ya, float xb, float yb) {
  return sqrt( pow((xb-xa), 2) + pow((yb-ya), 2) );
}

public float crandom(float d) {
  return pow(random(1.0f), d) ;
}

/*

crandom results :
difficulty   nb > 0.5 pour 1000
       0.04 999
       0.08 999
       0.16 986
       0.32 885
       0.64 661
       1.28 418
       2.56 236
       5.12 126
      10.24 65
      20.48 33
      40.96 16
      81.92 8
     163.84 4
     327.68 2
     655.36 1
    1310.72 0
    2621.44 0

*/

//ici on definie les objet que l'on vas generer

/*

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

Base[] BaseList = new Base[0]; //contien les objet
int MAX_LIST_SIZE = 5000; //longueur max de l'array d'objet
int INIT_BASE = 30; //nombre de grower au debut puis apres un reset MODIFIABLE PAR MENU INIT
boolean REGULAR_START = false;

float DEVIATION = 8; //drifting (rotation posible en portion de pi (PI/drift))
float L_MIN = 2; //longeur minimum de chaque section
float L_MAX = 15; //longeur max de chaque section MODIFIABLE PAR MENU MOVE minimum 1 , limité dans l'update de sont bp
float L_DIFFICULTY = 90;

// un switch les control dans le menu
boolean ON_GROW = true; // active la pousse de nouveau grower au bout des grower actif
boolean ON_SPROUT = true; // active le bourgeonnement de nouveau grower sur les branche
boolean ON_STOP = true; // active l'arret (devien vert)
boolean ON_DIE = true; // active la mort

//les dificulté sont appliqué a crandom, voir dans l'onglet utils elles on toute un control dans le menu
float GROW_DIFFICULTY = 0.5f;
float SPROUT_DIFFICULTY = 2080.0f;
float STOP_DIFFICULTY = 1.25f;
float DIE_DIFFICULTY = 3.6f;
int OLD_AGE = 666;

int TEEN_AGE = OLD_AGE / 20;

//diminue de autant la dificulté de la mort quand l'array est bientot plein
//float DIE_DIFFICULTY_DIVIDER = 8.0; //when array close to full

float MAX_LINE_WIDTH = 1.5f; //epaisseur max des ligne, diminuer par l'age, un peut, se vois pas
float MIN_LINE_WIDTH = 0.2f; //epaisseur min des ligne


public void init_base() {
  // redimensionement de l'array a ca taille max
  BaseList = (Base[]) expand(BaseList, MAX_LIST_SIZE);
  //initialisation de chaque element
  for (int i = 0 ; i < MAX_LIST_SIZE ; i++) {
    BaseList[i] = new Base();
    BaseList[i].id = i;
    //BaseList[i].init(new PVector(0, 0), new PVector(0, 0), i);
  }
  reset_base();
  init_graphs();
}

float reset_angle = 0;
float reset_angle_incr = 0;

public void reset_base() {
  //tout le monde sur off
  deleteAll();
  //reset du generateur de nombre aleatoire
  randomSeed(SEED);
  //creation des grower initiaux
  reset_angle = random( 2 * PI);
  reset_angle_incr = 2 * PI / INIT_BASE;
  if (!adding_type) for (int i = 0; i < INIT_BASE; i++) create_init_base();
  else adding_pile = INIT_BASE;
}

public void create_init_base() {
  if (REGULAR_START) {
    createFirstBase(reset_angle);
    reset_angle += reset_angle_incr; }
  else createFirstBase(random( 2 * PI));
}


public void grower_to_strings() {
  file.append("grower:");
  file.append(str(MAX_LIST_SIZE));
  file.append(str(INIT_BASE));
  file.append(str(L_MIN));
  file.append(str(L_MAX));
  file.append(str(L_DIFFICULTY));
  file.append(str(ON_GROW));
  file.append(str(ON_SPROUT));
  file.append(str(ON_STOP));
  file.append(str(ON_DIE));
  file.append(str(GROW_DIFFICULTY));
  file.append(str(SPROUT_DIFFICULTY));
  file.append(str(STOP_DIFFICULTY));
  file.append(str(DIE_DIFFICULTY));
  file.append(str(OLD_AGE));
}
public void baselist_to_strings() {
  file.append("baselist:");
  for (Base b : BaseList) b.to_strings();
}

class Base {
  
  int id;
  boolean exist;
  
  Base() {
    exist = false;
    id = 0;
  }
  
  // PERSO    ----------------
  PVector pos = new PVector();
  PVector grows = new PVector();
  PVector dir = new PVector();
  
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
  float start = 0.0f;
  
  // PERSO    ----------------
  
  public void to_strings() {
    file.append("base:");
    file.append(str(id));
    file.append(str(exist));
    file.append(str(pos.x));
    file.append(str(pos.y));
    file.append(str(grows.x));
    file.append(str(grows.y));
    file.append(str(dir.x));
    file.append(str(dir.y));
    file.append(str(end));
    file.append(str(sprouts));
    file.append(str(age));
  }
  
  public void init(PVector _p, PVector _d, int _root_id) {    //argument are passed through createBase
    exist = true;
    // PERSO    ----------------
    //root_id = _root_id;
    //rang = BaseList[root_id].rang + 1;
    
    end = false;
    sprouts = 0;
    age = 0;
    start = 0.0f;
    
    pos = _p;
    grows = new PVector(L_MIN + crandom(L_DIFFICULTY)*(L_MAX - L_MIN), 0);
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
    
    if (age < TEEN_AGE) {
      start = (float)age / (float)TEEN_AGE;
    } else start = 1;
    
    // grow
    if (ON_GROW && start == 1 && !end && sprouts == 0 && crandom(GROW_DIFFICULTY) > 0.5f) {
      if(createBase(grows, dir, id) != null) sprouts++;
    }
    
    // sprout
    if (ON_SPROUT && start == 1 && !end && crandom(SPROUT_DIFFICULTY) > 0.5f) {
      PVector _p = new PVector(0, 0);
      PVector _d = new PVector(0, 0);
      _d.add(grows).sub(pos);
      _d.setMag(random(1.0f) * _d.mag());
      _p.add(pos).add(_d);
      createBase(_p, _d, id);
      sprouts++;
      //sprouts = (int[]) expand(sprouts, sprouts.length + 1);
      //sprouts[sprouts.length - 1] = temp_b.id;
      //temp_b.this_sprout_index = sprouts.length - 1;
      //sprouts_nb++;
    }
    
    // stop growing
    if (ON_STOP && start >= 1 && !end && sprouts == 0 && crandom(STOP_DIFFICULTY) > 0.5f) {
      end = true;
    }
    
    // die
    float rng = crandom(DIE_DIFFICULTY);
    if (ON_DIE && start == 1 && !(!end && sprouts == 0) &&
         (rng > ( (float)OLD_AGE / (float)age ) //||
          //rng / DIE_DIFFICULTY_DIVIDER > ((float)MAX_LIST_SIZE - (float)baseNb()) / (float)MAX_LIST_SIZE
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
    if (!end && sprouts == 0) { stroke(255); strokeWeight(MAX_LINE_WIDTH / cam_scale); }
    else if (end) { stroke(0, ca, 0); strokeWeight((MAX_LINE_WIDTH+1) / cam_scale); }
    else { stroke(ca, ca, ca); strokeWeight(((float)MIN_LINE_WIDTH + ((float)MAX_LINE_WIDTH * (float)ca / 255.0f)) / cam_scale); }              
    //fill(255);
    //ellipseMode(CENTER);
    //ellipse(pos.x, pos.y, 2, 2);
    
    PVector e = new PVector(dir.x, dir.y);
    if (start < 1) e = e.setMag(e.mag() * start);
    e = e.add(pos);
    line(pos.x,pos.y,e.x,e.y);
    
    //strokeWeight(MAX_LINE_WIDTH+1 / cam_scale);
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
class LinkList {
  ArrayList<LinkB> linkBList = new ArrayList<LinkB>(0);
  ArrayList<LinkF> linkFList = new ArrayList<LinkF>(0);
  MacroList macroList;
  
  LinkList(MacroList m) {
    macroList = m;
  }
  
  public void clear() {
    linkBList.clear();
    linkFList.clear();
  }
  
  public void to_strings() {
    for (LinkB m : linkBList)
      m.to_strings();
    for (LinkF m : linkFList)
      m.to_strings();
  }
  
  public LinkB createLinkB() {
    LinkB l = new LinkB(macroList);
    linkBList.add(l);
    return l;
  }

  public LinkF createLinkF() {
    LinkF l = new LinkF(macroList);
    linkFList.add(l);
    return l;
  }
}

class LinkB {
  MacroList macroList;
  InputB in;
  OutputB out;
  LinkB(MacroList m) {
    macroList = m;
  }
  public void to_strings() {
    if (this != macroList.NOTB) {
      file.append("linkB");
      file.append(str(in.id));
      file.append(str(out.id));
    }
  }
  public boolean collision(int x, int y) {
    if (this != macroList.NOTB && in != macroList.NOTBI && out != macroList.NOTBO) {
      return distancePointToLine(x, y, in.x, in.y, out.x, out.y) < 3;
    }
    return false;
  }
  public void drawing() {
    if (this != macroList.NOTB && in != macroList.NOTBI && out != macroList.NOTBO) {
      if (distancePointToLine(mouseX, mouseY, in.x, in.y, out.x, out.y) < 3) {
        if (out.bang) {stroke(255,255,0,180); fill(255,255,0);} else {stroke(182,182,0,180); fill(182,182,0);}
      } else {
        if (out.bang) {stroke(255,180); fill(255);} else {stroke(182,180); fill(182);}
      }
      if (in.in.getTab().isActive() && out.out.getTab().isActive()) {
        strokeWeight(3);
        line(in.x,in.y,out.x,out.y);
      }
      ellipseMode(RADIUS);
      noStroke();
      if (out.out.getTab().isActive()) {
        ellipse(out.x,out.y,6,6);
      }
      if (in.in.getTab().isActive()) {
        if (distancePointToLine(mouseX, mouseY, in.x, in.y, out.x, out.y) < 3) {
          if (in.in.isOn()) {fill(255,255,0);} else {fill(182,182,0);}
        } else {
          if (in.in.isOn()) {fill(255);} else {fill(182);}
        }
        ellipse(in.x,in.y,6,6);
      }
    }
  }
}

class LinkF {
  MacroList macroList;
  InputF in;
  OutputF out;
  float value = 0;
  LinkF(MacroList m) {
    macroList = m;
  }
  public void to_strings() {
    if (this != macroList.NOTF) {
      file.append("linkF");
      file.append(str(in.id));
      file.append(str(out.id));
    }
  }
  public boolean collision(int x, int y) {
    if (this != macroList.NOTF && in != macroList.NOTFI && out != macroList.NOTFO) {
      return distancePointToLine(x, y, in.x, in.y, out.x, out.y) < 3;
    }
    return false;
  }
  public void drawing() {
    if (this != macroList.NOTF && in != macroList.NOTFI && out != macroList.NOTFO) {
      if (distancePointToLine(mouseX, mouseY, in.x, in.y, out.x, out.y) < 3) {
        if (out.bang) {stroke(255,255,0,180); fill(255,255,0);} else {stroke(182,182,0,180); fill(182,182,0);}
      } else {
        if (out.bang) {stroke(255,180); fill(255);} else {stroke(182,180); fill(182);}
      }
      if (in.in.getTab().isActive() && out.out.getTab().isActive()) {
        strokeWeight(3);
        line(in.x,in.y,out.x,out.y);
      }
      ellipseMode(RADIUS);
      noStroke();
      if (out.out.getTab().isActive()) {
        ellipse(out.x,out.y,6,6);
      }
      if (in.in.getTab().isActive()) {
        if (distancePointToLine(mouseX, mouseY, in.x, in.y, out.x, out.y) < 3) {
          if (in.in.isOn()) {fill(255,255,0);} else {fill(182,182,0);}
        } else {
          if (in.in.isOn()) {fill(255);} else {fill(182);}
        }
        ellipse(in.x,in.y,6,6);
      }
    }
  }
}

abstract class InputA {
  MacroList macroList;
  int x,y,n;
  int id = 0;
  Group g;
  Button in;
  boolean bang = false;
  InputA(MacroList m, String s_, int _id, Group g_, int n_) {
    macroList = m;
    id = _id;
    g = g_;
    n = n_;
    in = cp5.addButton(s_ + str(id))
       .setSwitch(true)
       .setLabelVisible(false)
       .setPosition(0, 3 + (n*26))
       .setSize(12,22)
       .setGroup(g)
       ;
    x = PApplet.parseInt(g.getPosition()[0]); y = PApplet.parseInt(g.getPosition()[1] + 12 + (n*26));
  }
  public void clear() {
    in.remove();
    g.remove();
  }
  public void to_strings() {
    file.append("input");
    file.append(str(id));
    file.append(str(x));
    file.append(str(y));
    file.append(str(n));
  }
}

class InputB extends InputA {
  ArrayList<LinkB> l = new ArrayList<LinkB>(0);
  Textlabel t;
  InputB(MacroList m, int id, Group g_, int i, String text, int n_) {
    super(m, "inB", id, g_, n_);
    t = cp5.addTextlabel("Ctrl" + str(i) + "inBText" + str(n))
                    .setText(text)
                    .setPosition(28, 3 + (n*26))
                    .setColorValue(color(255))
                    .setFont(createFont("Arial",18))
                    .setGroup(g)
                    ;
  }
  public void clear() {
    t.remove();
    super.clear();
  }
  public void to_strings() {
    super.to_strings();
    file.append("B");
  }
  public boolean getUpdate() {
    if (in.isMouseOver() && mouseClick[0] && macroList.creatingLinkB) {macroList.addLinkSelectInB(this);}
    x = PApplet.parseInt(g.getPosition()[0]); y = PApplet.parseInt(g.getPosition()[1] + 14 + (n*26));
    bang = false;
    for (LinkB b : l) {
      if (!b.out.updated) {return false;}
    }
    for (LinkB b : l) {
      bang |= b.out.bang;
    }
    if (bang) {in.setOn();} else {in.setOff();}
    return true;
  }
  public boolean get() {
    return bang;
  }
}

class InputF extends InputA {
  ArrayList<LinkF> l = new ArrayList<LinkF>(0);
  float value;
  Textfield textf;
  Textlabel t;
  InputF(MacroList m, int id, Group g_, int i, String text, int n_, float d) {
    super(m, "inF", id, g_, n_);
    value = d;
    t = cp5.addTextlabel("Ctrl" + str(id) + "inFText" + str(n))
                    .setText(text)
                    .setPosition(88, 3 + (n*26))
                    .setColorValue(color(255))
                    .setFont(createFont("Arial",18))
                    .setGroup(g)
                    ;
    textf = cp5.addTextfield("Ctrl" + str(id) + "inFTextfield" + str(n_))
       .setLabel("")
       .setPosition(28, 3 + (n_*26))
       .setSize(60,22)
       .setAutoClear(false)
       .setDecimalPrecision(3)
       //.lock()
       .setInputFilter(cp5.FLOAT)
       .setGroup(g)
       .setFocus(true)
       .setText(str(value))
       .setFocus(false)
       .addCallback(new CallbackListener() {
          public void controlEvent(final CallbackEvent ev) {  
            value = PApplet.parseFloat(textf.getText());
          }
        }) 
       ;
    textf.getValueLabel().setFont(createFont("Arial",18));
  }
  public void clear() {
    textf.remove();
    t.remove();
    super.clear();
  }
  public boolean getUpdate() {
    if (in.isMouseOver() && mouseClick[0] && macroList.creatingLinkF) {macroList.addLinkSelectInF(this);}
    x = PApplet.parseInt(g.getPosition()[0]); y = PApplet.parseInt(g.getPosition()[1] + 14 + (n*26));
    bang = false;
    for (LinkF f : l) {
      if (!f.out.updated) {return false;}
    }
    for (LinkF f : l) {
      bang |= f.out.bang;
      if (f.out.bang) {value = f.out.value;}
    }
    if (bang) {in.setOn(); textf.setFocus(true); textf.setText(str(value)); textf.setFocus(false);} else {in.setOff();}
    return true;
  }
  public boolean bang() {
    return bang;
  }
  public float get() {
    float d = value;
    getUpdate();
    return d;
  }
  public void set(float d) {
    value = d;
    textf.setFocus(true);
    textf.setText(str(d));
    textf.setFocus(false);
  }
  public void to_strings() {
    super.to_strings();
    file.append("F");
    file.append(str(value));
  }
}

abstract class OutputA {
  MacroList macroList;
  boolean updated = false;
  int x = -100; int y = -100;
  int n = 0;
  int id = 0;
  Group g;
  Button out;
  boolean bang = false;

  OutputA(MacroList m, String s_, int _id, Group g_, int n_) {
    g = g_;
    n = n_;
    id = _id;
    macroList = m;
    out = cp5.addButton(s_ + str(id))
       .setSwitch(true)
       .setLabelVisible(false)
       .setPosition(g.getWidth() - 12, 3 + (n*26))
       .setSize(12,22)
       .setGroup(g)
       ;
    x = PApplet.parseInt(g.getPosition()[0] + g.getWidth()); y = PApplet.parseInt(g.getPosition()[1] + 14 + (n*26));
  }
  
  public void clear() {
    g.remove();
    out.remove();
  }
  public void to_strings() {
    file.append("output");
    file.append(str(id));
    file.append(str(x));
    file.append(str(y));
    file.append(str(n));
  }
}

class OutputB extends OutputA {
  ArrayList<LinkB> l = new ArrayList<LinkB>(0);
  Textlabel t;
  OutputB(MacroList m, int id, Group g_, int i, String text, int n_) {
    super(m, "outB", id, g_, n_);
    t = cp5.addTextlabel("Ctrl" + str(i) + "outBText" + str(n))
                    .setText(text)
                    .setPosition(g.getWidth() - 100, 3 + (n*26))
                    .setColorValue(color(255))
                    .setFont(createFont("Arial",18))
                    .setGroup(g)
                    ;
  }
  public void clear() {
    t.remove();
    super.clear();
  }
  public void to_strings() {
    super.to_strings();
    file.append("B");
  }
  public void set(boolean v) {
    bang = v;
    if (bang) {
      for (LinkB b : l) {
        b.in.bang = bang;
      }
    }
    update();
  }
  public void bang() { set(true); }
  public void unBang() { set(false); }
  public boolean get() {
    return bang;
  }
  public void update() {
    if (out.isMouseOver() && mouseClick[0]) {macroList.addLinkSelectOutB(this);}
    updated = true;
    x = PApplet.parseInt(g.getPosition()[0] + g.getWidth()); y = PApplet.parseInt(g.getPosition()[1] + 14 + (n*26));
    if (bang) {out.setOn();} else {out.setOff();}
  }
  public OutputB linkTo(InputB in) {
    LinkB nl = macroList.linkList.createLinkB();
    nl.in = in; nl.out = this;
    in.l.add(nl); this.l.add(nl);
    return this;
  }
}

class OutputF extends OutputA {
  ArrayList<LinkF> l = new ArrayList<LinkF>(0);
  float value;
  Textfield textf;
  Textlabel t;
  OutputF(MacroList m, int id, Group g_, int i, String text, int n_, float d) {
    super(m, "outF", id, g_, n_);
    value = d;
    t = cp5.addTextlabel("Ctrl" + str(i) + "outFText" + str(n_))
                    .setText(text)
                    .setPosition(g.getWidth() - 160, 3 + (n_*26))
                    .setColorValue(color(255))
                    .setFont(createFont("Arial",18))
                    .setGroup(g)
                    ;
    textf = cp5.addTextfield("Ctrl" + str(i) + "outFTextfield" + str(n_))
       .setLabel("")
       .setPosition(g.getWidth() - 76, 3 + (n_*26))
       .setSize(60,22)
       .setAutoClear(false)
       .setDecimalPrecision(3)
       .lock()
       .setGroup(g)
       .setFocus(true)
       .setText(str(value))
       .setFocus(false)
       ;
    textf.getValueLabel().setFont(createFont("Arial",18));
  }
  public void clear() {
    t.remove();
    textf.remove();
    super.clear();
  }
  public void to_strings() {
    super.to_strings();
    file.append("F");
    file.append(str(value));
  }
  public void set(float v) {
    value = v;
  }
  public void setBang(float v) {
    if (value != v) { value = v; bang(); return; }
    value = v;
  }
  public void unBang() {bang = false;}
  public void bang() {
    bang = true;
    for (LinkF f : l) {
      f.in.bang = true;
    }
    update();
  }
  public float get() {return value;}
  public void update() {
    if (out.isMouseOver() && mouseClick[0]) {macroList.addLinkSelectOutF(this);}
    updated = true;
    x = PApplet.parseInt(g.getPosition()[0] + g.getWidth()); y = PApplet.parseInt(g.getPosition()[1] + 12 + (n*26));
    if (value < 0.000001f) {value = 0;}
    if (bang) {out.setOn(); textf.setFocus(true); textf.setText(str(value).trim()); textf.setFocus(false);} else {out.setOff();}
    //bang = false;
  }
  public OutputF linkTo(InputF in) {
    LinkF nl = macroList.linkList.createLinkF();
    nl.in = in; nl.out = this;
    in.l.add(nl); this.l.add(nl);
    return this;
  }
}


class GrowingParam extends Macro {
  InputF growI,sproutI,stopI,dieI,ageI;
  float grow,sprout,stop,die,age;
  
  GrowingParam(MacroList l_, int i_, int x_, int y_) {
    super(l_, i_, x_, y_);
    g.setLabel("GROW");
    g.setWidth(200);
    growI = createInputF("GROW", GROW_DIFFICULTY);
    grow = GROW_DIFFICULTY;
    sproutI = createInputF("SPROUT", SPROUT_DIFFICULTY);
    sprout = SPROUT_DIFFICULTY;
    stopI = createInputF("STOP", STOP_DIFFICULTY);
    stop = STOP_DIFFICULTY;
    dieI = createInputF("DIE", DIE_DIFFICULTY);
    die = DIE_DIFFICULTY;
    ageI = createInputF("AGE", OLD_AGE);
    age = OLD_AGE;
  }
  public void clear() {
    super.clear();
  }
  public void to_strings() {
    super.to_strings();
    file.append("GrowingControl");
    file.append(str(grow));
    file.append(str(sprout));
    file.append(str(stop));
    file.append(str(die));
  }
  
  public void drawing(float x, float y) {}
  
  public void update() {
    float g = growI.get();
    float sp = sproutI.get();
    float st = stopI.get();
    float d = dieI.get();
    float a = ageI.get();
    
    if (g != grow) {
      grow = g; GROW_DIFFICULTY = grow;
      update_textlabel("GROW", " = r^", GROW_DIFFICULTY); }
    else if (g != GROW_DIFFICULTY) {
      grow = GROW_DIFFICULTY; growI.set(grow); }
    
    if (sp != sprout) {
      sprout = sp; SPROUT_DIFFICULTY = sprout;
      update_textlabel("BLOOM", " = r^", SPROUT_DIFFICULTY); }
    else if (sp != SPROUT_DIFFICULTY) {
      sprout = SPROUT_DIFFICULTY; sproutI.set(sprout); }
    
    if (st != stop) {
      stop = st; STOP_DIFFICULTY = stop;
      update_textlabel("STOP", " = r^", STOP_DIFFICULTY); }
    else if (st != STOP_DIFFICULTY) {
      stop = STOP_DIFFICULTY; stopI.set(stop); }
    
    if (d != die) {
      die = d; DIE_DIFFICULTY = die;
      update_textlabel("DIE", " = r^", DIE_DIFFICULTY); }
    else if (d != DIE_DIFFICULTY) {
      die = DIE_DIFFICULTY; dieI.set(die); }
      
    if (a != age) {
      age = a; OLD_AGE = (int)age;
      update_textlabel("AGING", " at ", OLD_AGE);
    }
    else if (a != OLD_AGE) {
      age = OLD_AGE; ageI.set(age); }
    
    super.update();
    updated = true;
  }
}

class GrowingActive extends Macro {
  InputB growI,sproutI,stopI,dieI,growoffI,sproutoffI,stopoffI,dieoffI;
  
  GrowingActive(MacroList l_, int i_, int x_, int y_) {
    super(l_, i_, x_, y_);
    g.setLabel("GROW");
    g.setWidth(200);
    growI = createInputB("GROW ON");
    sproutI = createInputB("SPROUT ON");
    stopI = createInputB("STOP ON");
    dieI = createInputB("DIE ON");
    growoffI = createInputB("GROW OFF");
    sproutoffI = createInputB("SPROUT OFF");
    stopoffI = createInputB("STOP OFF");
    dieoffI = createInputB("DIE OFF");
  }
  public void clear() {
    super.clear();
  }
  public void to_strings() {
    super.to_strings();
    file.append("GrowingActiv");
  }
  
  public void drawing(float x, float y) {}
  
  public void update() {
    if (growI.getUpdate() && sproutI.getUpdate() && stopI.getUpdate() && dieI.getUpdate() && 
        growoffI.getUpdate() && sproutoffI.getUpdate() && stopoffI.getUpdate() && dieoffI.getUpdate() ) {
      if (growI.get()   && !ON_GROW)   bGrow.setOn();
      if (sproutI.get() && !ON_SPROUT) bSprout.setOn();
      if (stopI.get()   && !ON_STOP)   bStop.setOn();
      if (dieI.get()    && !ON_DIE)    bDie.setOn();
      if (growoffI.get()   && ON_GROW)   bGrow.setOff();
      if (sproutoffI.get() && ON_SPROUT) bSprout.setOff();
      if (stopoffI.get()   && ON_STOP)   bStop.setOff();
      if (dieoffI.get()    && ON_DIE)    bDie.setOff();
    }
    super.update();
    updated = true;
  }
}

class GrowingControl extends Macro {
  InputB in;
  
  RadioButton r1, r2, r3;
  
  GrowingControl(MacroList l_, int i_, int x_, int y_) {
    super(l_, i_, x_, y_);
    g.setLabel("GROW");
    g.setWidth(200);
    in = createInputB("");
    g.setSize(g.getWidth(), 28 + (inCount*28));
    
    r1 = cp5.addRadioButton("radioButton1" + id)
         .setGroup(g)
         .setPosition(20,6)
         .setSize(15,15)
         .setItemsPerRow(1)
         .setSpacingRow(8)
         .addItem("x" + id,1)
         .addItem("/" + id,2)
         ;
         
     r2 = cp5.addRadioButton("radioButton2" + id)
         .setGroup(g)
         .setPosition(55,6)
         .setSize(15,15)
         .setItemsPerRow(1)
         .setSpacingRow(8)
         .addItem("1.2" + id,1)
         .addItem("2" + id,2)
         ;
     
     r3 = cp5.addRadioButton("radioButton3" + id)
         .setGroup(g)
         .setPosition(100,6)
         .setSize(15,15)
         .setItemsPerRow(2)
         .setSpacingRow(8)
         .setSpacingColumn(35)
         .addItem("GROW" + id,1)
         .addItem("BLOOM" + id,2)
         .addItem("STOP" + id,3)
         .addItem("DIE" + id,4)
         ;
     
     r1.getItem("x" + id).getCaptionLabel().setText("x");
     r1.getItem("/" + id).getCaptionLabel().setText("/");
     r2.getItem("1.2" + id).getCaptionLabel().setText("1.2");
     r2.getItem("2" + id).getCaptionLabel().setText("2");
     r3.getItem("GROW" + id).getCaptionLabel().setText("GROW");
     r3.getItem("BLOOM" + id).getCaptionLabel().setText("BLOOM");
     r3.getItem("STOP" + id).getCaptionLabel().setText("STOP");
     r3.getItem("DIE" + id).getCaptionLabel().setText("DIE");
     
     for(Toggle t:r1.getItems())
       t.getCaptionLabel().setFont(createFont("Arial",16));
     r1.getItem("x" + id).setState(true);
     for(Toggle t:r2.getItems())
       t.getCaptionLabel().setFont(createFont("Arial",16));
     r2.getItem("2" + id).setState(true);
  }
  public void clear() {
    super.clear();
  }
  public void to_strings() {
    super.to_strings();
    file.append("GrowingActiv");
  }
  
  public void drawing(float x, float y) {}
  
  public void update() {
    if (in.getUpdate()) {
      float m = 0;
      if (r2.getItem("1.2" + id).getState()) m = 1.2f;
      else if (r2.getItem("2" + id).getState()) m = 2;
      if (r1.getItem("/" + id).getState()) m = 1 / m;
      if (in.get()) {
        if (r3.getItem("GROW" + id).getState()) {
          GROW_DIFFICULTY *= m;
          update_textlabel("GROW", " = r^", GROW_DIFFICULTY); }
        if (r3.getItem("SPROUT" + id).getState()) {
          SPROUT_DIFFICULTY *= m;
          update_textlabel("SPROUT", " = r^", SPROUT_DIFFICULTY); }
        if (r3.getItem("STOP" + id).getState()) {
          STOP_DIFFICULTY *= m;
          update_textlabel("STOP", " = r^", STOP_DIFFICULTY); }
        if (r3.getItem("DIE" + id).getState()) {
          DIE_DIFFICULTY *= m;
          update_textlabel("DIE", " = r^", DIE_DIFFICULTY); }
      }
    }
    super.update();
    updated = true;
  }
}

class GrowingWatcher extends Macro {
  OutputF popO,growO;
  float pop,grow;
  
  GrowingWatcher(MacroList l_, int i_, int x_, int y_) {
    super(l_, i_, x_, y_);
    g.setLabel("Watcher");
    g.setWidth(150);
    popO = createOutputF("      POP", 0);
    growO = createOutputF("  GROW", 0);
  }
  public void clear() {
    super.clear();
  }
  public void to_strings() {
    super.to_strings();
    file.append("GrowWatcher");
    file.append(str(pop));
    file.append(str(grow));
  }
  
  public void drawing(float x, float y) {}
  
  public void update() {
    int p = baseNb();
    int g = growsNb();
    popO.set(p);
    growO.set(g);
    if (pop != p) popO.bang();
    if (grow != g) growO.bang();
    pop = baseNb(); grow = growsNb();
    super.update();
    updated = true;
  }
}

class SimControl extends Macro {
  InputB inR,inRng,inP;
  
  SimControl(MacroList l_, int i_, int x_, int y_) {
    super(l_, i_, x_, y_);
    g.setLabel("SIMULATION");
    g.setWidth(150);
    inR = createInputB("RESET");
    inRng = createInputB("RNG");
    inP = createInputB("PAUSE");
  }
  public void clear() {
    super.clear();
  }
  public void to_strings() {
    super.to_strings();
    file.append("Sim Control");
  }
  
  public void drawing(float x, float y) {}
  
  public void update() {
    if (inR.getUpdate() && inRng.getUpdate()) {
      if (inR.get()) reset();
      if (inRng.get()) {
        SEED = PApplet.parseInt(random(1000000000));
        textfieldSeed.setValue("" + SEED);
        reset();
      }
      if (inP.get()) {
        Button b = (Button)cp5.getController("running");
        if (b.isOn()) b.setOff(); else b.setOn();
      }
    }
    super.update();
    updated = true;
  }
}

class Keyboard extends Macro {
  boolean w,c,a,p;
  OutputB wO,cO,aO,pO;
  
  Keyboard(MacroList l_, int i_, int x_, int y_) {
    super(l_, i_, x_, y_);
    w = false; c = false; a = false; p = false;
    g.setLabel("Key");
    g.setWidth(150);
    aO = createOutputB("          A");
    wO = createOutputB("          W");
    pO = createOutputB("          P");
    cO = createOutputB("          C");
  }
  public void clear() {
    super.clear();
  }
  public void to_strings() {
    super.to_strings();
    file.append("Keyboard");
  }
  
  public void update() {
    w = false; c = false; a = false; p = false;
    if (keysClick[4]) {w = true;}
    if (keysClick[5]) {c = true;}
    if (keysClick[7]) {a = true;}
    if (keysClick[8]) {p = true;}
    wO.set(w);
    cO.set(c);
    aO.set(a);
    pO.set(p);
    super.update();
    updated = true;
  }
  
  public void drawing(float x, float y) {}
}

class MacroVAL extends Macro {
  OutputF out;
  InputB in;
  InputF inV;
  float value;
  //Textfield txtf;
  
  MacroVAL(MacroList ml, float v_, int i_, int x_, int y_) {
    super(ml, i_, x_, y_);
    value = v_;
    g.setLabel("Value");
    in =  createInputB("IN");
    inV =  createInputF("  VAL",value);
    out = createOutputF("    OUT",v_);
    //txtf = cp5.addTextfield("textVal" + str(id))
    //   .setLabel("")
    //   .setPosition(100,2)
    //   .setSize(70,22)
    //   .setAutoClear(false)
    //   .setGroup(g)
    //   .setText(str(value))
    //   ;
    //txtf.getValueLabel().setFont(createFont("Arial",18));
  }
  public void clear() {
    //txtf.remove();
    super.clear();
  }
  public void to_strings() {
    super.to_strings();
    file.append("macroVAL");
    file.append(str(value));
  }

  public void update() {
    super.update();
    if (in.getUpdate() && inV.getUpdate()) {
      //value = float(txtf.getText());
      if (inV.bang()) {value = inV.get(); }//txtf.setText(str(value));}
      out.set(value);
      if (in.get()) {out.bang();} else {out.unBang();}
      out.update();
      updated = true;
    }
  }
}

class MacroDELAY extends Macro {
  OutputB out;
  InputB in;
  int count;
  int actualCount;
  boolean on = false;
  Textfield txtf;
  boolean temp = false;
  
  MacroDELAY(MacroList ml, int v_, int i_, int x_, int y_) {
    super(ml, i_, x_, y_);
    count = v_;
    g.setLabel("Delay");
    in =  createInputB("IN");
    out = createOutputB("    OUT");
    txtf = cp5.addTextfield("textDel" + str(id))
       .setLabel("")
       .setPosition(100,2)
       .setSize(70,22)
       .setAutoClear(false)
       .setGroup(g)
       .setText(str(count))
       ;
    txtf.getValueLabel().setFont(createFont("Arial",18));
  }
  public void clear() {
    txtf.remove();
    super.clear();
  }
  public void to_strings() {
    super.to_strings();
    file.append("macroDELAY");
    file.append(str(count));
    file.append(str(actualCount));
    file.append(str(on));
  }
  public void update() {
    super.update();
    count = PApplet.parseInt(txtf.getText());
    if (in.getUpdate()) {
      if (in.get()) {
        if (!on && !temp) {
          on = true;
          actualCount = count;
        }
      }
      temp = false;
      if (on) {
        actualCount -= 1;
        if (actualCount <= 0) {
          on = false;
          out.set(true);
          temp = true;
        } else {
          out.set(false);
        }
      } else {
        out.set(false);
      }
      updated = true;
    }
  }

}

class MacroCOMP extends Macro {
  OutputB out;
  InputF in1,in2;
  float v1,v2;
  
  RadioButton r1;
  Button b1;
  
  MacroCOMP(MacroList ml, int i_, int x_, int y_) {
    super(ml, i_, x_, y_);
    g.setLabel("Comp>");
    in1 =  createInputF("   IN",0);
    in2 = createInputF("   IN",0);
    out = createOutputB("    OUT");
    v1 = 0; v2 = 0;
    
    r1 = cp5.addRadioButton("radioButton" + id)
         .setGroup(g)
         .setPosition(150,29)
         .setSize(20,20)
         .setItemsPerRow(3)
         .setSpacingColumn(20)
         .addItem("sup" + id,1)
         .addItem("inf" + id,2)
         ;
     r1.getItem("sup" + id).getCaptionLabel().setText(">");
     r1.getItem("inf" + id).getCaptionLabel().setText("<");
     b1 = cp5.addButton("macrocompButton" + id)
         .setGroup(g)
         .setPosition(230,29)
         .setSize(20,20)
         .setSwitch(true)
         ;
     b1.getCaptionLabel().setFont(createFont("Arial",16)).setText("        =");
     
     for(Toggle t:r1.getItems())
       t.getCaptionLabel().setFont(createFont("Arial",16));
     r1.getItem("sup" + id).setState(true);
  }
  public void clear() {
    super.clear();
  }
  public void to_strings() {
    super.to_strings();
    file.append("macroCOMP");
  }

  public void update() {
    super.update();
    if (in1.getUpdate() && in2.getUpdate()) {
      
      v1 = in1.get();
      v2 = in2.get();
      
      if ( (r1.getItem("sup" + id).getState() && v1 > v2) || 
           (r1.getItem("inf" + id).getState() && v1 < v2) ||
           (b1.isOn() && v1 == v2) )
        {out.bang();}
      else {out.unBang();}

      out.update();
      updated = true;
    }
  }
}

class MacroBOOL extends Macro {
  OutputB out;
  InputB in1,in2;
  
  RadioButton r1;
  
  MacroBOOL(MacroList ml, int i_, int x_, int y_) {
    super(ml, i_, x_, y_);
    g.setLabel("BOOL");
    in1 =  createInputB("   IN");
    in2 = createInputB("   IN");
    out = createOutputB("    OUT");
    
    r1 = cp5.addRadioButton("radioButton" + id)
         .setGroup(g)
         .setPosition(80,29)
         .setSize(15,15)
         .setItemsPerRow(4)
         .setSpacingColumn(40)
         .addItem("AND" + id,1)
         .addItem("OR" + id,2)
         .addItem("XOR" + id,3)
         .addItem("NOT" + id,4)
         ;
     r1.getItem("AND" + id).getCaptionLabel().setText("AND");
     r1.getItem("OR" + id).getCaptionLabel().setText("OR");
     r1.getItem("XOR" + id).getCaptionLabel().setText("XOR");
     r1.getItem("NOT" + id).getCaptionLabel().setText("NOT");
     
     for(Toggle t:r1.getItems())
       t.getCaptionLabel().setFont(createFont("Arial",16));
     r1.getItem("AND" + id).setState(true);
  }
  public void clear() {
    super.clear();
  }
  public void to_strings() {
    super.to_strings();
    file.append("macroBOOL");
  }

  public void update() {
    super.update();
    if (in1.getUpdate() && in2.getUpdate()) {
      if (r1.getItem("AND" + id).getState())  
        if (in1.get() && in2.get()) {out.bang();} else {out.unBang();}
      else if (r1.getItem("OR" + id).getState()) 
        if (in1.get() || in2.get()) {out.bang();} else {out.unBang();}
      else if (r1.getItem("XOR" + id).getState()) 
        if (!(in1.get() == in2.get())) {out.bang();} else {out.unBang();}
      else if (r1.getItem("NOT" + id).getState()) 
        if (!in1.get()) {out.bang();} else {out.unBang();}

      out.update();
      updated = true;
    }
  }
}

class MacroCALC extends Macro {
  OutputF out;
  InputF in1,in2;
  float v1,v2;
  
  RadioButton r1;
  
  MacroCALC(MacroList ml, int i_, int x_, int y_) {
    super(ml, i_, x_, y_);
    g.setLabel("CALC");
    in1 =  createInputF("   IN", 0);
    in2 = createInputF("   IN", 0);
    out = createOutputF("    OUT", 0);
    v1 = 0; v2 = 0;
    
    r1 = cp5.addRadioButton("calcradioButton" + id)
         .setGroup(g)
         .setPosition(150,29)
         .setSize(15,15)
         .setItemsPerRow(4)
         .setSpacingColumn(20)
         .addItem("+" + id,1)
         .addItem("-" + id,2)
         .addItem("x" + id,3)
         .addItem("/" + id,4)
         ;
     r1.getItem("+" + id).getCaptionLabel().setText("+");
     r1.getItem("-" + id).getCaptionLabel().setText("-");
     r1.getItem("x" + id).getCaptionLabel().setText("x");
     r1.getItem("/" + id).getCaptionLabel().setText("/");
     
     for(Toggle t:r1.getItems())
       t.getCaptionLabel().setFont(createFont("Arial",16));
     r1.getItem("+" + id).setState(true);
  }
  public void clear() {
    super.clear();
  }
  public void to_strings() {
    super.to_strings();
    file.append("macroCALC");
  }

  public void update() {
    super.update();
    if (in1.getUpdate() && in2.getUpdate()) {
      
      if (r1.getItem("+" + id).getState())  
        out.set(in1.get() + in2.get());
      else if (r1.getItem("-" + id).getState())  
        out.set(in1.get() - in2.get());
      else if (r1.getItem("x" + id).getState())  
        out.set(in1.get() * in2.get());
      else if (r1.getItem("/" + id).getState())  
        out.set(in1.get() / in2.get());
      
      if (v1 != in1.get() || v2 != in2.get()) out.bang();
      else out.unBang();
      v1 = in1.get(); v2 = in2.get(); 

      out.update();
      updated = true;
    }
  }
}


MacroList mList;

Keyboard keyb;
GrowingControl gcC;
GrowingWatcher gwC;

MacroVAL mv1,mv2;

public void init_macro() {
  mList = new MacroList();
  mList.addGrowingParam(1400, 50);
  mList.addGrowingActive(1400, 230);
  mList.addGrowingControl(1400, 500);
  mList.addGrowingWatcher(50, 250);
  mList.addKeyboard(50, 50);
  mList.addSimControl(60, 400);
  
  mList.addMacroVAL(20, height - 80, 0);
  mList.addMacroVAL(360, height - 80, 0);
  mList.addMacroVAL(700, height - 80, 0);
  mList.addMacroVAL(1040, height - 80, 0);
  mList.addMacroVAL(1380, height - 80, 0);
  mList.addMacroVAL(20, height - 180, 0);
  mList.addMacroVAL(360, height - 180, 0);
  mList.addMacroVAL(700, height - 180, 0);
  mList.addMacroCALC(1040, height - 180);
  mList.addMacroCALC(1380, height - 180);
  mList.addMacroCOMP(20, height - 280);
  mList.addMacroCOMP(360, height - 280);
  mList.addMacroBOOL(700, height - 280);
  mList.addMacroBOOL(1040, height - 280);
  mList.addMacroDELAY(1380, height - 280, 10);
  
  //gcC = mList.addGrowingControl(800, 50);
  //gwC = mList.addGrowingWatcher(50, 400);
  //keyb = mList.addKeyboard(50, 50);
  
  //mv1 = mList.addMacroVAL(300, 50, 0.16);
  //mv2 = mList.addMacroVAL(300, 200, 0.833);
  
  //keyb.wO.linkTo(mv1.in);
  //keyb.aO.linkTo(mv2.in);
  
  //mv1.out.linkTo(gcC.growI);
  //mv2.out.linkTo(gcC.growI);
}

class MacroList {
  ArrayList<Macro> macroList = new ArrayList<Macro>(0);
  ArrayList<InputB> inBList = new ArrayList<InputB>(0);
  ArrayList<OutputB> outBList = new ArrayList<OutputB>(0);
  ArrayList<InputF> inFList = new ArrayList<InputF>(0);
  ArrayList<OutputF> outFList = new ArrayList<OutputF>(0);
  
  LinkList linkList = new LinkList(this);
  
  Group g;
  LinkB NOTB = linkList.createLinkB();
  LinkF NOTF = linkList.createLinkF();
  InputB NOTBI;
  InputF NOTFI;
  OutputB NOTBO;
  OutputF NOTFO;
  
  boolean creatingLinkB = false;
  OutputB selectOutB;
  boolean creatingLinkF = false;
  OutputF selectOutF;
  
  MacroList() {
    g = cp5.addGroup("Main")
                  .setVisible(false)
                  .setPosition(-200,-200)
                  .moveTo("Macros")
                  ;
    NOTBO = createOutputB(g, -1,"",0);
    NOTFO = createOutputF(g,-1,"",1,0);
    NOTBI = createInputB(g,-1,"",0);
    NOTFI = createInputF(g,-1,"",1,0);
  }
  
  public void clear() {
    g.remove();
    for (Macro m : macroList) m.clear();
    for (InputB i : inBList) i.clear();
    for (InputF i : inFList) i.clear();
    for (OutputB o : outBList) o.clear();
    for (OutputF o : outFList) o.clear();
    macroList.clear();
    inBList.clear();
    outBList.clear();
    inFList.clear();
    outFList.clear();
    linkList.clear();
  }
  
  public void to_strings() {
    file.append("macros:");
    for (Macro m : macroList)
      m.to_strings();
    file.append("in/out:");
    for (InputB m : inBList)
      m.to_strings();
    for (InputF m : inFList)
      m.to_strings();
    for (OutputB m : outBList)
      m.to_strings();
    for (OutputF m : outFList)
      m.to_strings();
    file.append("links:");
    linkList.to_strings();
  }
  
  public void drawing() {
    if (creatingLinkB) {
      stroke(255);
      fill(255);
      strokeWeight(3);
      line(mouseX,mouseY,selectOutB.x,selectOutB.y);
      ellipseMode(RADIUS);
      noStroke();
      ellipse(mouseX,mouseY,6,6);
      ellipse(selectOutB.x,selectOutB.y,6,6);
    } else if (creatingLinkF) {
      stroke(255);
      fill(255);
      strokeWeight(3);
      line(mouseX,mouseY,selectOutF.x,selectOutF.y);
      ellipseMode(RADIUS);
      noStroke();
      ellipse(mouseX,mouseY,6,6);
      ellipse(selectOutF.x,selectOutF.y,6,6);
    }
    for (LinkB l : linkList.linkBList) {
      l.drawing();
    }
    for (LinkF l : linkList.linkFList) {
      l.drawing();
    }
  }
  
  public void update() {
    int counter = 0;
    while (counter < macroList.size()) {
      for (Macro m : macroList) {
        if (!m.updated) {
          m.update();
          if (m.updated) {counter += 1;}
        }
      }
    }
    for (Macro m : macroList) {
      m.updated = false;
    }
    if (mouseClick[1]) {
      creatingLinkB = false;
      creatingLinkF = false;
      for (int i = linkList.linkBList.size() - 1; i >= 0; i--) {
        LinkB l = linkList.linkBList.get(i);
        if (l.collision(mouseX, mouseY)) {
          l.in.l.remove(l);
          l.out.l.remove(l);
          linkList.linkBList.remove(l);
        }
      }
      for (int i = linkList.linkFList.size() - 1; i >= 0; i--) {
        LinkF l = linkList.linkFList.get(i);
        if (l.collision(mouseX, mouseY)) {
          l.in.l.remove(l);
          l.out.l.remove(l);
          linkList.linkFList.remove(l);
        }
      }
    }
  }
  
  public void addLinkSelectOutB(OutputB out) {
    creatingLinkB = true;
    selectOutB = out;
  }
  
  public void addLinkSelectInB(InputB in) {
    creatingLinkB = false;
    selectOutB.linkTo(in);
  }
  
  public void addLinkSelectOutF(OutputF out) {
    creatingLinkF = true;
    selectOutF = out;
  }
  
  public void addLinkSelectInF(InputF in) {
    creatingLinkF = false;
    selectOutF.linkTo(in);
  }
  
  public Keyboard addKeyboard(int _x, int _y) {
    int id = macroList.size();
    return new Keyboard(this, id, _x, _y);
  }
  
  public SimControl addSimControl(int _x, int _y) {
    int id = macroList.size();
    return new SimControl(this, id, _x, _y);
  }
  
  public GrowingParam addGrowingParam(int _x, int _y) {
    int id = macroList.size();
    return new GrowingParam(this, id, _x, _y);
  }
  
  public GrowingControl addGrowingControl(int _x, int _y) {
    int id = macroList.size();
    return new GrowingControl(this, id, _x, _y);
  }
  
  public GrowingActive addGrowingActive(int _x, int _y) {
    int id = macroList.size();
    return new GrowingActive(this, id, _x, _y);
  }
  
  public GrowingWatcher addGrowingWatcher(int _x, int _y) {
    int id = macroList.size();
    return new GrowingWatcher(this, id, _x, _y);
  }
  
  public MacroVAL addMacroVAL(int _x, int _y, float v) {
    int id = macroList.size();
    return new MacroVAL(this, v, id, _x, _y);
  }
  
  public MacroCOMP addMacroCOMP(int _x, int _y) {
    int id = macroList.size();
    return new MacroCOMP(this, id, _x, _y);
  }
  
  public MacroBOOL addMacroBOOL(int _x, int _y) {
    int id = macroList.size();
    return new MacroBOOL(this, id, _x, _y);
  }
  
  public MacroCALC addMacroCALC(int _x, int _y) {
    int id = macroList.size();
    return new MacroCALC(this, id, _x, _y);
  }
  
  public MacroDELAY addMacroDELAY(int _x, int _y, int v) {
    int id = macroList.size();
    return new MacroDELAY(this, v, id, _x, _y);
  }
  
  public Macro addMacro(Macro m) {
    macroList.add(m);
    return m;
  }
  
  public InputB createInputB(Group g, int i, String text, int n) {
    int id = inBList.size();
    InputB o = new InputB(this, id, g, i, text, n);
    inBList.add(o);
    return o;
  }

  public InputF createInputF(Group g, int i, String text, int n, float d) {
    int id = inFList.size();
    InputF o = new InputF(this, id, g, i, text, n, d);
    inFList.add(o);
    return o;
  }
  
  public OutputB createOutputB(Group g, int i, String text, int n) {
    int id = outBList.size();
    OutputB o = new OutputB(this, id, g, i, text, n);
    outBList.add(o);
    return o;
  }
  
  public OutputF createOutputF(Group g, int i, String text, int n, float d_) {
    int id = outFList.size();
    OutputF o = new OutputF(this, id, g, i, text, n, d_);
    outFList.add(o);
    return o;
  }
  
}

abstract class Macro {
  MacroList macroList;
  boolean updated = false;
  Group g;
  int id; int x,y; float mx = 0; float my = 0;
  int inCount = 0;
  int outCount = 0;
  
  Macro(MacroList ml, int i_, int x_, int y_) {
    ml.addMacro(this);
    macroList = ml;
    id = i_;
    x = x_; y = y_;
    g = cp5.addGroup("Macro" + str(id))
                  .activateEvent(true)
                  .setPosition(x,y)
                  .setSize(320,22)
                  .setBackgroundColor(color(60, 200))
                  .disableCollapse()
                  .moveTo("Macros")
                  .setHeight(22)
                  ;
  g.getCaptionLabel().setFont(createFont("Arial",16));
  }
  public void clear() {
    g.remove();
  }
  public void to_strings() {
    file.append("macro");
    file.append(str(id));
    file.append(str(x));
    file.append(str(y));
    file.append(str(inCount));
    file.append(str(outCount));
  }
  
  public void update() {
    if (cp5.getTab("Macros").isActive()) {
      if (g.isMouseOver() && mouseClick[0]) {
        mx = g.getPosition()[0] - mouseX;
        my = g.getPosition()[1] - mouseY;
        GRAB = false; //deactive le deplacement camera
      }
      if (g.isMouseOver() && mouseUClick[0]) {
        GRAB = true;
      }
      if (g.isMouseOver() && mouseButtons[0]) {
        x = PApplet.parseInt(mouseX + mx); y = PApplet.parseInt(mouseY + my);
        g.setPosition(mouseX + mx,mouseY + my);
      }
    }
  }
  
  public InputB createInputB(String text) {
    InputB in = macroList.createInputB(g, id, text, inCount);
    if (inCount >= outCount) {
      g.setSize(g.getWidth(), 28 + (inCount*28));
    }
    inCount +=1;
    return in;
  }

  public InputF createInputF(String text, float d) {
    InputF in = macroList.createInputF(g, id, text, inCount, d);
    if (inCount >= outCount) {
      g.setSize(g.getWidth(), 28 + (inCount*28));
    }
    inCount +=1;
    return in;
  }
  
  public OutputB createOutputB(String text) {
    OutputB out = macroList.createOutputB(g, id, text, outCount);
    if (outCount >= inCount) {
      g.setSize(g.getWidth(), 28 + (outCount*28));
    }
    outCount +=1;
    return out;
  }

  public OutputF createOutputF(String text, float d) {
    OutputF out = macroList.createOutputF(g, id, text, outCount, d);
    if (outCount >= inCount) {
      g.setSize(g.getWidth(), 28 + (outCount*28));
    }
    outCount +=1;
    return out;
  }
}
//easy building


public Textlabel addText(Group g, String name, String label, float x, float y, int st) {
  return cp5.addTextlabel(name)
     .setText(label)
     .setPosition(x, y)
     .setSize(10, st)
     .setColorValue(0xffffffff)
     .setFont(createFont("Arial",st))
     .setGroup(g)
     ;
}

public Textlabel addText(Group g, String name, String label, float x, float y) {
  return addText(g, name, label, x, y, TEXT_SIZE);
}

public Button addButton(Group g, String name, String label, float x, float y, int sx, int sy, int id, float st) {
  Button b = cp5.addButton(name)
     .setPosition(x, y)
     .setSize(sx,sy)
     .setGroup(g)
     .setId(id)
     ;
  b.getCaptionLabel().setText(label).setFont(createFont("Arial",st));
  return b;
}

// modify by a factor
public void build_line_factor(Group g, String name, String comp, float val, float x, float y, int id) {
  addText(g, name + "-label", name + comp + val, x + 140, y + 10).setId(id);
  id *= maxctrlerByLine;
  addButton(g, name + "-x2", "x2", x + 340, y + 0, BTN_SIZE, BTN_SIZE, id+1, TEXT_SIZE);
  addButton(g, name + "-x1", "x1.2", x + 290, y + 0, BTN_SIZE, BTN_SIZE, id+2, TEXT_SIZE);
  addButton(g, name + "-/1", "/1.2", x + 50, y + 0, BTN_SIZE, BTN_SIZE, id+3, TEXT_SIZE);
  addButton(g, name + "-/2", "/2", x + 0, y + 0, BTN_SIZE, BTN_SIZE, id+4, TEXT_SIZE);
}

// modify by increment
public void build_line_incr(Group g, String name, String comp, float val, float x, float y, int id) {
  id *= maxctrlerByLine;
  addButton(g, name + "-min10", "-10", x + 0, y + 0, BTN_SIZE, BTN_SIZE, id+5, TEXT_SIZE);
  addButton(g, name + "-min1", "-1", x + 50, y + 0, BTN_SIZE, BTN_SIZE, id+6, TEXT_SIZE);
  addButton(g, name + "-maj1", "+1", x + 290, y + 0, BTN_SIZE, BTN_SIZE, id+7, TEXT_SIZE);
  addButton(g, name + "-maj10", "+10", x + 340, y + 0, BTN_SIZE, BTN_SIZE, id+8, TEXT_SIZE);
  addText(g, name + "-label", name + comp + val, x + 140, y + 15).setId(id);
}

Group group_grow; // la grande tab 
Textlabel info3, info4; // les texte d'info, declarer pour pouvoir les modif
Button bGrow,bSprout,bStop,bDie;

public void init_panel_grower() {
  group_grow = cp5.addGroup("group_grow")
             .setPosition(width - PANEL_WIDTH, 330)
             .setSize(PANEL_WIDTH, 10)
             .setBackgroundHeight(750)
             .setBackgroundColor(color(60, 200))
             .disableCollapse()
             .moveTo("Menu")
             ;
  group_grow.getCaptionLabel().setText("");
  
  addText(group_grow, "title1", "GROWING STRUCTURES", 15, 0, 30).setFont(createFont("Arial Bold",30));
  
  addText(group_grow, "title2", "Behavior", 150, 40, 24);
  build_line_factor(group_grow, "GROW", " * r^", GROW_DIFFICULTY, 10, 70, 0);
  build_line_factor(group_grow, "BLOOM", " * r^", SPROUT_DIFFICULTY, 10, 120, 1);
  build_line_factor(group_grow, "STOP", " * r^", STOP_DIFFICULTY, 10, 170, 2);
  build_line_factor(group_grow, "DIE", " * r^", DIE_DIFFICULTY, 10, 220, 3);
  build_line_factor(group_grow, "AGING", " at ", OLD_AGE, 10, 270, 4);
  
  Button b; //pointer
  
  bGrow = addButton(group_grow, "ON_GROW", "", 110+5, 70+5, BTN_SIZE-10, BTN_SIZE-10, utilctrlid + 4, TEXT_SIZE)
    .setSwitch(true);
  if (ON_GROW) bGrow.setOn();
  bSprout = addButton(group_grow, "ON_SPROUT", "", 110+5, 120+5, BTN_SIZE-10, BTN_SIZE-10, utilctrlid + 5, TEXT_SIZE)
    .setSwitch(true);
  if (ON_SPROUT) bSprout.setOn();
  bStop = addButton(group_grow, "ON_STOP", "", 110+5, 170+5, BTN_SIZE-10, BTN_SIZE-10, utilctrlid + 6, TEXT_SIZE)
    .setSwitch(true);
  if (ON_STOP) bStop.setOn();
  bDie = addButton(group_grow, "ON_DIE", "", 110+5, 220+5, BTN_SIZE-10, BTN_SIZE-10, utilctrlid + 7, TEXT_SIZE)
    .setSwitch(true);
  if (ON_DIE) bDie.setOn();
  
  addText(group_grow, "title3", "Movement", 140, 320, 24);
  build_line_factor(group_grow, "DRIFT", " = PI/", DEVIATION, 10, 350, 7);
  build_line_factor(group_grow, "L", " * r^", L_DIFFICULTY, 10, 400, 8);
  build_line_factor(group_grow, "LMIN", " = ", L_MIN, 10, 450, 9);
  build_line_factor(group_grow, "LMAX", " = ", L_MAX, 10, 500, 10);
  
  addText(group_grow, "title4", "Utilitaires", 140, 545, 24);
  info3 = addText(group_grow, "info3", " ", 50, 580);
  info4 = addText(group_grow, "info4", " ", 200, 580);
  
  b = addButton(group_grow, "GRAPH", "graphic", 150, 710, 100, 30, utilctrlid + 8, TEXT_SIZE)
    .setSwitch(true);
  if (SHOW_GRAPH) b.setOn();
  
  build_line_incr(group_grow, "INIT", " ", INIT_BASE, 10, 610, 6);
  build_line_incr(group_grow, "STEP", " ", adding_step, 10, 660, 11);
  
  addButton(group_grow, "HIDE_GROW", "H", 370, 720, 20, 20, utilctrlid + 12, 16);
  
  
  b = addButton(group_grow, "REGSTR", "R", 110, 615, BTN_SIZE-10, BTN_SIZE-10, utilctrlid + 22, TEXT_SIZE)
    .setSwitch(true);
  if (REGULAR_START) b.setOn();
  
  b = addButton(group_grow, "addstep", "", 110, 665, BTN_SIZE-10, BTN_SIZE-10, utilctrlid + 23, TEXT_SIZE)
    .setSwitch(true);
  if (adding_type) b.setOn();
  
}

public void event_panel_grower(int id, int line, float modifier) {
  if (id == utilctrlid + 8) { //button graph
    SHOW_GRAPH = ((Button)cp5.getController("GRAPH")).isOn(); }
  if (id == utilctrlid + 12) { group_grow.hide(); } // boutton hide
  if (id == utilctrlid + 22) {
    REGULAR_START = ((Button)cp5.getController("REGSTR")).isOn(); }
  if (id == utilctrlid + 23) {
    adding_type = ((Button)cp5.getController("addstep")).isOn(); }
  
  //activation
  if (id == utilctrlid + 4) {
    ON_GROW = ((Button)cp5.getController("ON_GROW")).isOn(); }
  if (id == utilctrlid + 5) {
    ON_SPROUT = ((Button)cp5.getController("ON_SPROUT")).isOn(); }
  if (id == utilctrlid + 6) {
    ON_STOP = ((Button)cp5.getController("ON_STOP")).isOn(); }
  if (id == utilctrlid + 7) {
    ON_DIE = ((Button)cp5.getController("ON_DIE")).isOn(); }
  
  // apply modifier
  if (line == 0) { GROW_DIFFICULTY *= modifier; update_textlabel("GROW", " * r^", GROW_DIFFICULTY); }
  if (line == 1) { SPROUT_DIFFICULTY *= modifier; update_textlabel("BLOOM", " * r^", SPROUT_DIFFICULTY); }
  if (line == 2) { STOP_DIFFICULTY *= modifier; update_textlabel("STOP", " * r^", STOP_DIFFICULTY); }
  if (line == 3) { DIE_DIFFICULTY *= modifier; update_textlabel("DIE", " * r^", DIE_DIFFICULTY); }
  if (line == 4) { OLD_AGE *= modifier; update_textlabel("AGING", " at ", OLD_AGE); }
  if (line == 7) { DEVIATION *= modifier; update_textlabel("DRIFT", " = PI/", DEVIATION); }
  if (line == 8) { L_DIFFICULTY *= modifier;  update_textlabel("L", " * r^", L_DIFFICULTY);}
  if (line == 9) { L_MIN *= modifier;  update_textlabel("LMIN", " = ", L_MIN);}
  if (line == 10) { L_MAX *= modifier;  update_textlabel("LMAX", " = ", L_MAX);}
  if (line == 6) { INIT_BASE += modifier; update_textlabel("INIT", " ", INIT_BASE); }
  if (line == 11) { adding_step += modifier; update_textlabel("STEP", " ", adding_step); }
}

public void update_panel_grower() {
  //mise a jour des text du menu
  info3.setText("object nb: " + baseNb());
  info4.setText("growing objects: " + growsNb());
  //moving control panel
  if (group_grow.isMouseOver() && mouseClick[0]) {
    mx = group_grow.getPosition()[0] - mouseX;
    my = group_grow.getPosition()[1] - mouseY;
    GRAB = false;//deactive le deplacement camera
  }
  if (group_grow.isMouseOver() && mouseUClick[0]) {
    GRAB = true;
  }
  if (group_grow.isMouseOver() && mouseButtons[0]) {
    group_grow.setPosition(mouseX + mx,mouseY + my);
  }
}

public void update_textlabel(String name, String comp, float val) {
  Textlabel t = (Textlabel)cp5.getController(name + "-label");
  t.setText(name + comp + val);
}
//ici on gere les menus
//plus bas il y a les graphs


 //la lib pour les menu

ControlP5 cp5; //l'objet main pour les menu

Group group_control; // la grande tab
Textlabel info_slide, info_framerate, info_turn, info_repeat;
Textfield textfieldSeed;

float mx = 0; 
float my = 0; //pour bouger les fenetres
int PANEL_WIDTH = 400; //largeur de la tab
PVector def_ctrlpanel_pos = new PVector(0, 0);
int TEXT_SIZE = 18;
int BTN_SIZE = 40;
int maxctrlerByLine = 10;
int utilctrlid = 1000;

public void init_panel() {
  cp5 = new ControlP5(this);

  cp5.addTab("Menu")
    .getCaptionLabel().setFont(createFont("Arial", 16))
    ;
  cp5.addTab("Macros")
    .getCaptionLabel().setFont(createFont("Arial", 16))
    ;

  cp5.getTab("default")
    // .activateEvent(true)
    .setLabel("Main")
    .getCaptionLabel().setFont(createFont("Arial", 16))
    ;
  cp5.getTab("Menu").bringToFront();

  init_panel_grower();
  init_macro();

  cp5.addButton("HIDE_MENUS")
    .setPosition(35, height - 27)
    .setSize(20, 20)
    .setId(utilctrlid + 11)
    .setTab("Menu")
    .getCaptionLabel().setText("M").setFont(createFont("Arial", 16))
    ;

  group_control = cp5.addGroup("group_control")
    .setPosition(width - (PANEL_WIDTH), 10)
    .setSize(PANEL_WIDTH, 10)
    .setBackgroundHeight(310)
    .setBackgroundColor(color(60, 200))
    .disableCollapse()
    .moveTo("Menu")
    ;
  group_control.getCaptionLabel().setText("");

  addText(group_control, "ctrl_title1", "STRUCTURE GENERATOR", 5, 7, 30).setFont(createFont("Arial Bold", 30));

  //addButton(group_control, "prev_slide", "<", 10, 40, 90, 40, utilctrlid + 13, TEXT_SIZE * 2);
  //addButton(group_control, "next_slide", ">", 300, 40, 90, 40, utilctrlid + 14, TEXT_SIZE * 2);
  //info_slide = addText(group_control, "info_slide", "SLIDE: 1", 160, 50).setFont(createFont("Arial Bold",20));

  addText(group_control, "title_seed", "Seed", 20, 55, TEXT_SIZE);
  textfieldSeed = cp5.addTextfield("seed_input")
    .setPosition(90, 50)
    .setSize(220, 30)
    .setCaptionLabel("")
    .setValue("" + SEED)
    .setFont(createFont("Arial", TEXT_SIZE))
    .setColor(color(255))
    .setGroup(group_control)
    ;
  addButton(group_control, "readseed", "V", 320, 50, 30, 30, utilctrlid + 9, TEXT_SIZE);
  addButton(group_control, "rngseed", "R", 360, 50, 30, 30, utilctrlid + 10, TEXT_SIZE);

  info_framerate = addText(group_control, "info_framerate", " ", 50, 90);
  info_turn = addText(group_control, "info_turn", " ", 250, 90);

  build_line_factor(group_control, "SPEED", " ", repeat_runAll, 10, 120, 5);

  Button b; //pointer

  b = addButton(group_control, "running", "p", 25, 170, 50, 50, utilctrlid + 3, TEXT_SIZE * 1.5f)
    .setSwitch(true);
  if (pause) b.setOn();
  addButton(group_control, "reset", "RESET", 100, 170, 95, 50, utilctrlid + 1, TEXT_SIZE * 1.2f);
  addButton(group_control, "reset-rng", "RNG", 205, 170, 95, 50, utilctrlid + 15, TEXT_SIZE * 1.2f);
  addButton(group_control, "saveframe", "I", 325, 170, 50, 50, utilctrlid + 2, TEXT_SIZE * 1.5f);

  //addButton(group_control, "save-param", "S", 100, 270, 95, 50, utilctrlid + 16, TEXT_SIZE * 1.5);
  //addButton(group_control, "load-param", "L", 205, 270, 95, 50, utilctrlid + 17, TEXT_SIZE * 1.5);

  b = addButton(group_control, "repeat", "RP", 10, 230, 50, 18, utilctrlid + 18, TEXT_SIZE)
    .setSwitch(true);
  if (auto_repeat) b.setOn();
  b = addButton(group_control, "repeatrng", "RNG", 10, 254, 50, 18, utilctrlid + 21, TEXT_SIZE)
    .setSwitch(true);
  if (repeat_random) b.setOn();
  addButton(group_control, "repeat-100", "-100", 80, 230, 60, 40, utilctrlid + 20, TEXT_SIZE * 1.2f);
  addButton(group_control, "repeat+100", "+100", 330, 230, 60, 40, utilctrlid + 19, TEXT_SIZE * 1.2f);
  info_repeat = addText(group_control, "info_repeat", "repeat at turn " + repeat_turn, 150, 240);
  addText(group_control, "info_fullscreen", "space : pause  ;  H : hide  ;  clic then ESC : quit", 10, 280);

  //cp5.printControllerMap(); // print all ui element
}

public void controlEvent(ControlEvent theEvent) {
  int id = theEvent.getId(); //on va retrouver le controlleur corespondant par sont id

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

  event_panel_grower(id, line, modifier);


  if (id == utilctrlid + 18) { // boutton repeat
    auto_repeat = ((Button)cp5.getController("repeat")).isOn();
  }
  if (id == utilctrlid + 21) { // boutton repeat
    repeat_random = ((Button)cp5.getController("repeatrng")).isOn();
  }
  if (id == utilctrlid + 19) { // boutton +100
    repeat_turn += 100;
    info_repeat.setText("repeat at turn " + repeat_turn);
  }
  if (id == utilctrlid + 20) { // boutton -100
    repeat_turn -= 100;
    info_repeat.setText("repeat at turn " + repeat_turn);
  }
  if (id == utilctrlid + 16) { // boutton save
    save_parameters();
  }
  if (id == utilctrlid + 17) { // boutton load

    reset();
  }
  if (id == utilctrlid + 13) { // boutton < slide
    slide = constrain(slide - 1, 0, maxSlide);
    info_slide.setText("SLIDE: " + (slide + 1));
    reset();
  }
  if (id == utilctrlid + 14) { // boutton > slide
    slide = constrain(slide + 1, 0, maxSlide);
    info_slide.setText("SLIDE: " + (slide + 1));
    reset();
  }
  if (id == utilctrlid + 1) { 
    reset();
  } // boutton reset
  if (id == utilctrlid + 15) { // boutton rng + reset
    SEED = PApplet.parseInt(random(1000000000));
    textfieldSeed.setValue("" + SEED);
    reset();
  }
  if (id == utilctrlid + 2) { 
    screenshot = true;
  }// boutton print
  if (id == utilctrlid + 3) { 
    pause = ((Button)cp5.getController("running")).isOn();
  }//button pause
  if (id == utilctrlid + 11) { // boutton hide
    if (!group_control.isVisible() && !group_grow.isVisible()) {
      group_control.show(); 
      group_grow.show();
    } else {
      if (group_control.isVisible()) group_control.hide();
      if (group_grow.isVisible()) group_grow.hide();
    }
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

  if (line == 5) { 
    repeat_runAll *= modifier; 
    update_textlabel("SPEED", " ", repeat_runAll);
  }
}

boolean BACK_SHOW_GRAPH = true;

public void update_all_menu() {
  // hide show panel with 'h'
  if (keysClick[9]) {
    if (!group_control.isVisible() && !group_grow.isVisible()) {
      group_control.show(); 
      group_grow.show();
      cp5.getTab("Macros").show();
      cp5.getTab("Menu").show();
      cp5.getTab("default").show();
      SHOW_GRAPH = BACK_SHOW_GRAPH;
    } else {
      if (group_control.isVisible()) group_control.hide();
      if (group_grow.isVisible()) group_grow.hide();
      cp5.getTab("Macros").hide();
      cp5.getTab("Menu").hide();
      cp5.getTab("default").hide();
      BACK_SHOW_GRAPH = SHOW_GRAPH;
      SHOW_GRAPH = false;
    }
  }
  //moving control panel
  if (group_control.isMouseOver() && mouseClick[0]) {
    mx = group_control.getPosition()[0] - mouseX;
    my = group_control.getPosition()[1] - mouseY;
    GRAB = false;//deactive le deplacement camera
  }
  if (group_control.isMouseOver() && mouseUClick[0]) {
    GRAB = true;
  }
  if (group_control.isMouseOver() && mouseButtons[0]) {
    group_control.setPosition(mouseX + mx, mouseY + my);
  }

  info_framerate.setText("framerate: " + PApplet.parseInt(frameRate));
  info_turn.setText("turn: " + counter);
  update_panel_grower();
}






//#######################################################################
//##                             GRAPHS                                ##
//#######################################################################

//permet l'enregistrement de donné pour le graphique
int larg =             1200;
int[] graph  = new int[1200];
int[] graph2 = new int[1200];
int gc = 0;
int max = 10;

boolean SHOW_GRAPH = false;// affichage du graph a un bp

public void init_graphs() {
  //initialisation des array des graph
  for (int i = 0; i < larg; i++) { 
    graph[i] = 0; 
    graph2[i] = 0;
  }
  max = 10;
}

public void draw_graphs() {
  if (SHOW_GRAPH && !cp5.getTab("default").isActive()) {
    strokeWeight(0.5f);
    stroke(255);
    for (int i = 1; i < larg; i++) if (i != gc) {
      stroke(255);
      line( (i-1), height - 10 - (graph[(i-1)] * (height-20) / 5000), 
        i, height - 10 - (graph[i] * (height-20) / 5000) );
      stroke(255, 255, 0);
      line( (i-1), height - 10 - (graph2[(i-1)] * (height-20) / max), 
        i, height - 10 - (graph2[i] * (height-20) / max) );
    }
    stroke(255, 0, 0);
    strokeWeight(7);
    if (gc != 0) {
      point(gc-1, height - 10 - (graph[gc-1] * (height-20) / 5000) );
      point(gc-1, height - 10 - (graph2[gc-1] * (height-20) / max) );
    }
  }
}

public void update_graph() {
  //enregistrement des donner dans les array
  graph[gc] = baseNb();

  int g = growsNb();
  if (max < g) max = g;
  if (graph2[gc] == max) {
    max = 10;
    for (int i = 0; i < graph2.length; i++) if (i != gc && max < graph2[i]) max = graph2[i];
  }
  graph2[gc] = g;

  if (gc < larg-1) gc++; 
  else gc = 0;
}

// ici on gere les fichiers


StringList file = new StringList(0);

public void saving() {
  file.append("start");
  simcontrol_to_strings();
  grower_to_strings();
  //baselist_to_strings(); //ok mais lour, illisible
  //mworld.macroWorld_to_string();
  String[] sl = new String[file.size()];
  for (int i = 0 ; i < file.size() ; i++)
    sl[i] = file.get(i);
  //saveStrings("save.txt", sl);
  //println(file);
  //mworld.clear();
  //if (mworld.build_from_string(file)) println("loading complete");
  //else println("error");
  file.clear();
}

public void save_parameters() {
  String[] sl = loadStrings("param.txt");
  for (int i = 0 ; i < sl.length ; i++)
    file.append(sl[i]);
  file.append("Parameters:");
  simcontrol_to_strings();
  grower_to_strings();
  sl = new String[file.size()];
  for (int i = 0 ; i < file.size() ; i++)
    sl[i] = file.get(i);
  saveStrings("param.txt", sl);
  file.clear();
}

//file = loadStrings("save.txt"); //String[]

//saveStrings("save.txt", file);
  public void settings() {  fullScreen();  noSmooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "grows_1_1" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
