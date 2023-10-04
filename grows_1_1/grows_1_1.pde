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

PVector start_point;

//ici on as les fonctions principale de processing, 
//elles geres l'arrengement des differente features
//plus bas ya des methodes utile qui vont nul par ailleur

void setup() {//executé au demarage
  //size(1720, 900);//taille de l'ecran
  
  fullScreen();
  setupInput();//voir onglet input
  noSmooth();//pas d'antialiasing
  //smooth();//anti aliasing
  frameRate(60);
  
  //for (String s : PFont.list()) println(s); // liste toute les police de text qui existe
  
  init_panel(); //onglet panel : initialise le menu
  init_base();
  
  //saving();
  
}

void draw() {//executé once by frame
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
          SEED = int(random(1000000000));
          textfieldSeed.setValue("" + SEED);
        }
        reset();
      }
    }
    
    //run_each_unpaused_frame:
    update_graph();
    
    //if (random(1) > 0.9) {
    //  start_point.set(1, 0);
    //  start_point.setMag(random(100));
    //  start_point.rotate(random(2 * PI));
    //}
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
    text(int(frameRate),10,height - 10 );
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

void simcontrol_to_strings() {
  file.append("simcontrol:");
  file.append(str(counter));
  file.append(str(pause));
  file.append(str(repeat_runAll));
  file.append(str(repeating_pile));
  file.append(str(SEED));
  file.append(str(slide));
  file.append(str(maxSlide));
}

void reset() {
  
  
  
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





//#######################################################################
//##                             CAMERA                                ##
//#######################################################################


PVector cam_pos = new PVector(0, 0); //position de la camera
float cam_scale = 8; //facteur de grossicement
float ZOOM_FACTOR = 1.1; //facteur de modification de cam_scale quand on utilise la roulette de la sourie
boolean GRAB = true;

boolean screenshot = false; //enregistre une image de la frame sans les menu si true puis se desactive
//int shot_cnt = 0; //prevue pour la sauvegarde d'image avec des num coherent

void cam_input_update() {
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

void cam_movement() {
  translate((width - PANEL_WIDTH) / 2, height / 2);
  scale(cam_scale);
  translate((cam_pos.x / cam_scale), (cam_pos.y / cam_scale));
}

void try_screenshot() {
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


String popStrLst(StringList sl) {
  String s = sl.get(sl.size() - 1);
  sl.remove(sl.size() - 1);
  return s;
}

float distancePointToLine(float x, float y, float x1, float y1, float x2, float y2) {
  float r =  ( ((x-x1)*(x2-x1)) + ((y-y1)*(y2-y1)) ) / pow(distancePointToPoint(x1, y1, x2, y2), 2);
  if (r <= 0) {return distancePointToPoint(x1, y1, x, y);}
  if (r >= 1) {return distancePointToPoint(x, y, x2, y2);}
  float px = x1 + (r * (x2-x1));
  float py = y1 + (r * (y2-y1));
  return distancePointToPoint(x, y, px, py);
}

float distancePointToPoint(float xa, float ya, float xb, float yb) {
  return sqrt( pow((xb-xa), 2) + pow((yb-ya), 2) );
}

float crandom(float d) {
  return pow(random(1.0), d) ;
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
