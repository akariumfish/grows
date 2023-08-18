/*

            -- GROWING STRUCTURES GENERATOR --

Les macro sont un outils de patch/programmation visuelle
qui permettra une auto regulation des pop parametrable
  grow regulé par nb de pop
  sprout par nb de grower
  stop par nb de grower
  mort par :
    age (def age min)
    nb de pop

corriger les beug d'affichage des macro (irregularité en y sur les bp des i/o)


bp pour faire passer juste un tour (+raccourcie clavier)

affichage du framerate plus lisible : calcul du framerate moyen sur la derniere sec

sauvegarder un screenshot
    attention! 
    la numerotation des fichier est baser sur le framecount
    deux fichier identique sur deux run et l'ancien est supprimer
    faire un truc mieux, il faut juste trouver comment test l'existance d'un fichier facilement

add switch pour afficher graph des objets qui pousse si bp graph est on
sur le graph, faire apparaitre d'une autre couleur les "echec" : pop au max ou pop a zero
garder une image du graph ( le complet depuis le tour 0 de chaque run)

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



boolean DEBUG = true; //utilisable dans draw pour print

int counter = 0; //conteur de tour depuis le dernier reset ou le debut
boolean pause = false; //permet d'interompre le defilement des tour
float repeat_runAll = 1; //nombre de fois ou il faut executé runall par frame
float repeating_pile = 0; //pile pour stocker les portion de repeat_runall quand il est < a 1
int SEED = 548651008; //seed pour l'aleatoire
int slide = 0;
int maxSlide = 1;

World world;
Player p1;

void setup() {//executé au demarage
  size(1600, 900);//taille de l'ecran
  setupInput();//voir onglet input
  noSmooth();//pas d'antialiasing
  //smooth();//anti aliasing
  frameRate(60);
  
  //for (String s : PFont.list()) println(s); // liste toute les police de text qui existe
  

  init_panel(); //onglet panel : initialise le menu
  init_base();
  
}

void draw() {//executé once by frame
  background(0);//fond noir
  
  //raccourcie barre espace -> pause
  if (keysClick[6]) {
    Button b = (Button)cp5.getController("running");
    if (b.isOn()) b.setOff(); else b.setOn();
  }
  
  cam_input_update();
  
  //execute les fonction run de tout les objet actif dans baselist (a un ritme definie par repeat_runall)
  if (!pause) {
    repeating_pile += repeat_runAll;
    while (repeating_pile > 1) {
      run_speeded();
      counter++;
      repeating_pile--;
    }
    run_each_unpaused_frame();
  }
  
  update_all_menu();
  
  // affichage
  draw_on_screen();
  pushMatrix();
  cam_movement(); // matrice d'affichage pour la camera
  draw_on_camera(); //execution des draw de tout les objet actif dans baselist
  popMatrix(); // fin de la matrice d'affichage
  try_screenshot();
  
  //peut servir
  if (DEBUG) {
    //println("Frame rate: " + int(frameRate));
    //println( " " );
    //println( counter + " " + growsNb());
  }
  
  world.checkOrders();
  world.update();
  world.drawing();
  
  inputUpdate(); //voir l'onglet input
}

void run_speeded() {
  switch (slide) {
    case 0: {
      runAll();
      break;
    }
    case 1: {
      
      break;
    }
  }
}

void run_each_unpaused_frame() {
  switch (slide) {
    case 0: {
      update_graph();
      break;
    }
    case 1: {
      
      break;
    }
  }
}

void draw_on_screen() {
  switch (slide) {
    case 0: {
      draw_graphs(); // population et grower tracking graph
      break;
    }
    case 1: {
      
      break;
    }
  }
}

void draw_on_camera() {
  switch (slide) {
    case 0: {
      drawAll();
      break;
    }
    case 1: {
      
      break;
    }
  }
}

void reset() {
  switch (slide) {
    case 0: {
      reset_base();
      init_graphs();
      break;
    }
    case 1: {
      
      break;
    }
  }
  
  //reset le conter de tour
  counter = 0;
}
