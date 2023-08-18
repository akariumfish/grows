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
import controlP5.*; //la lib pour les menu

ControlP5 cp5; //l'objet main pour les menu
Group cp5_g; // la grande tab 
Textlabel info1, info2, info3, info4; // les texte d'info, declarer pour pouvoir les modif
int PANEL_WIDTH = 400; //largeur de la tab

Base[] BaseList = new Base[0]; //contien les objet qui pousse (grower)
int MAX_LIST_SIZE = 5000; //longueur max de l'array d'objet

boolean DEBUG = true; //utilisable dans draw pour print
PVector cam_pos = new PVector(0, 0); //position de la camera
float cam_scale = 0.2; //facteur de grossicement
float ZOOM_FACTOR = 1.1; //facteur de modification de cam_scale quand on utilise la roulette de la sourie

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

float MAX_LINE_WIDTH = 1.5; //epaisseur max des ligne, diminuer par l'age, un peut, se vois pas
float MIN_LINE_WIDTH = 0.2; //epaisseur min des ligne

// un switch les control dans le menu
boolean ON_GROW = true; // active la pousse de nouveau grower au bout des grower actif
boolean ON_SPROUT = true; // active le bourgeonnement de nouveau grower sur les branche
boolean ON_STOP = true; // active l'arret (devien vert)
boolean ON_DIE = true; // active la mort

//les dificulté sont appliqué a crandom, voir dans l'onglet utils elles on toute un control dans le menu
float GROW_DIFFICULTY = 1.0;
float SPROUT_DIFFICULTY = 5000.0;
float STOP_DIFFICULTY = 10.0;
float DIE_DIFFICULTY = 7.2;
int OLD_AGE = 400;

//diminue de autant la dificulté de la mort quand l'array est bientot plein
float DIE_DIFFICULTY_DIVIDER = 8.0; //when array close to full

//permet l'enregistrement de donné pour le graphique
int larg =             1200;
int[] graph  = new int[1200];
int[] graph2 = new int[1200];
int gc = 0;

boolean SHOW_GRAPH = false;// affichage du graph a un bp
float repeat_runAll = 1; //nombre de fois ou il faut executé runall par frame
float repeating_pile = 0; //pile pour stocker les portion de repeat_runall quand il est < a 1

// PERSO    ----------------

void setup() {//executé au demarage
  size(1600, 900);//taille de l'ecran
  setupInput();//voir onglet input
  noSmooth();//pas d'antialiasing
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

void draw() {//executé once by frame
  background(0);//fond noir
  
  // population tracking graph :
  //dessin
  if (SHOW_GRAPH) {
    strokeWeight(0.5);
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
  info1.setText("framerate: " + int(frameRate));
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
