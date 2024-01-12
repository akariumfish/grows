/*

            ------- GROWING STRUCTURES GENERATOR -------





avancer sur menu :
  cree les methode d'easy build en creant le menu main
  
methode pour changer grower param depuis un svt







une simulation est constituer d'un nombre indefini et evolutif d'objet au comportement divert.

On vas les organiser en groupe d'objet au modele comportemental identique. Ces groupe seront apeller community
et les objet simulé seront apeller entity. Un objet communitylist gére la creation et l'execution des
differente community.
Un modele comportemental est un ensemble d'alteration applicable a une entity du type approprié et 
les condition d'aplication de ses alteration. Ses condition serons souvent aleatoire.
Different parametre peuvent modifier l'amplitude et la nature des alteration ou 
influencé les condition d'application d'une alteration. Ses parametre sont commun a une communauté et 
doivent pouvoir etre modifier en cour d'execution par l'utilisateur.
Si chaque entity d'une meme community suis donc un modele comportemental identique, sont 
evolution est unique car le resultat de ses test lui est propre. L'objet entity contient ses caracteristique.

des class abstract definise le modele a suivre pour cree un nouvel objet.




------------------------- Objects description -------------------------

communityList               conteneur principale, gestion des comunity
  arraylist of all community
  index of active community
  methods run draw reset :
    executed at right time in main loop
    launch corresponding methods of the active community

community       abstract    modele pour les community, gestion des entity
  arraylist of all entity
  communityparam
  methods :
    init              fill list with unactive entity object using the abstract method build()
    new entity        search for an inactive entity, reset it and return it
    reset             kill all, set randomseed, and create new entity following parameters
    run all           launch run method of all active entity
    draw all          launch draw //
    destroy all       launch destroy methods of all entity
    kill all          launch kill //
    active entity nb  get nb of active entity
    build             abstract pour la creation de nouvelle entity

entity          abstract    modele pour les entity, gestion des comportement
  index et etat d'activation
  methods :
    reset             active l'entity et launch init
    destroy           si active desactive et launch clear
    kill              deactive
  methods abstract :
    run               seras launch each tick
    draw              seras launch dans la matrice d'affichage camera
    init              seras launch a chaque activation
    clear             seras launch a chaque deactivation non forcé (not through kill)
    randomize         is launch par community reset to set random param for initially activated entity

communityparam              conteneur de data
  max entity
  initial entity
  random seed

randomtryparam              conteneur de data
  utilisé avec la methode crandom
  float difficulty   dif pour le crandom
  bool on            activation


programmation d'un nouvel objet simulable : Grower
on doit extends les objet community et entity
grower          extends entity      entity qui pousse comme un vegetal
growercomu      extends community
  growerparam
growerparam     conteneur de data




------------------------- MENU -------------------------

chaque panel:
  titre
  deplacable

simulation
  seed selection
  info : framerate / turn
  speed
  pause reset reset-rng print
  repeat repeat-rng select repeat turn

community panel
  param community size (reset if changed)
  param generation initial
  info : active object number
  show/hide graphs
  
FUTUR:
chaque panel
  collapsable (button) / hidable (button)
simulation
  open community menu
comunity menu
  community list
  open selected community panel




------------------------- BUG -------------------------

--corriger les beug d'affichage des macro (irregularité en y sur les bp des i/o) 
--corriger numerotation des screenshots
    la numerotation des fichier est baser sur le framecount
    deux fichier identique sur deux run et l'ancien est supprimer
    faire un truc mieux, il faut juste trouver comment test l'existance d'un fichier facilement




------------------------- sauvegarde -------------------------

  la traduction en StringList de macroworld est faite <- a verif apres merge macro world et list
  la remise a zero de macroworld aussi <- a verif apres merge macro world et list
  a faire :
    --construction de macrolist a partir d'un stringlist
    --selecteur de fichier source/cible
    --menu dedier
    --sauvegarde sous different titre dans un fichier
    --lecture
cree objet param abstract :
  void save_to(SVT, name, nodename)
    create a new node under nodename named name or modify it if it already exist
  void load from(SVT, name, nodeName)
    load data if it exist
menu pour selectionner un fichier




------------------------- macros -------------------------

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
    --change speed
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

*/

ArrayList<sInt> sintlist = new ArrayList<sInt>(); //enregistreur
ArrayList<sFlt> sfltlist = new ArrayList<sFlt>();
ArrayList<sBoo> sboolist = new ArrayList<sBoo>();

//definition des variable principale
boolean DEBUG = true; //utilisable dans draw pour print
int counter = 0; //conteur de tour depuis le dernier reset ou le debut
boolean pause = false; //permet d'interompre le defilement des tour
float repeat_runAll = 1; //nombre de fois ou il faut executé runall par frame
float repeating_pile = 0; //pile pour stocker les portion de repeat_runall quand il est < a 1
int repeat_turn = 600;
boolean auto_repeat = false;
boolean repeat_random = true;

ComunityList coml;
NodeComu nodec;
BirdComu b;

Channel run_chan = new Channel();
Channel frame_chan = new Channel();



//ici on as les fonctions principale de processing, 
//elles geres l'arrengement des differente features
//plus bas ya des methodes utile qui vont nul par ailleur

void setup() {//executé au demarage
  size(1600, 900);//taille de l'ecran
  setupInput();//voir onglet input
  noSmooth();//pas d'antialiasing
  //smooth();//anti aliasing
  frameRate(60);
  
  init_canvas();
  
  init_UI();
  
  coml = new ComunityList();
  
  nodec = new NodeComu(coml);
  b = new BirdComu(coml);
  b.p.INIT_ENT = 10;
  
  coml.reset();
  
  //saving();
  //loading();
  //print(SPEED.get());
  
  //println(c.active_Entity_Nb() + " " + b.active_Entity_Nb());
  //println();
}

void draw() {//executé once by frame
  background(0);//fond noir
  
  if (!pause) {
    repeating_pile += repeat_runAll;
    while (repeating_pile > 1) {
      
      //run_speeded:  execute a un ritme definie par repeat_runall
      coml.run();
      callChannel(run_chan);
      
      int diff = 20;
      for (int i = -width / 2 ; i < width / 2 ; i++)
        for (int j = -height / 2 ; j < height / 2 ; j++) {
          color co = getpix(i, j);
          color cv = getpix(i + 1, j);
          if (red(co) > red(cv) + diff) {
            setpix(i+1, j, color(diff+red(cv)));
            setpix(i, j, color(red(co)-diff));
          }
          cv = getpix(i - 1, j);
          if (red(co) > red(cv) + diff) {
            setpix(i-1, j, color(diff+red(cv)));
            setpix(i, j, color(red(co)-diff));
          }
          cv = getpix(i, j+1);
          if (red(co) > red(cv) + diff) {
            setpix(i, j+1, color(diff+red(cv)));
            setpix(i, j, color(red(co)-diff));
          }
          cv = getpix(i, j-1);
          if (red(co) > red(cv) + diff) {
            setpix(i, j-1, color(diff+red(cv)));
            setpix(i, j, color(red(co)-diff));
          }
      }
      
      counter++;
      repeating_pile--;
      if (auto_repeat && repeat_turn <= counter) {
        if (repeat_random) {
          SEED = int(random(1000000000));
          //textfieldSeed.setValue("" + SEED);
        }
        reset();
      }
    }
    
    //run_each_unpaused_frame:
    
  }
  
  //run_each_frame:
  callChannel(frame_chan);
  //raccourcie barre espace -> pause
  if (keysClick[6]) {
    Button b = (Button)cp5.getController("running");
    if (b.isOn()) b.setOff(); else b.setOn();
  }
  
  

  // AFFICHAGE
  //draw_on_screen:
  
  pushMatrix();
  cam_movement(); // matrice d'affichage pour la camera
  canvas.updatePixels();
  image(canvas, -width / 2, -height / 2);
  //draw_on_camera:
  coml.draw();
  
  //PVector v = new PVector(mouseX, mouseY);
  //v = to_cam_view(v);
  //ellipse(v.x, v.y, 10, 10);
  
  popMatrix(); // fin de la matrice d'affichage
  try_screenshot();
  
  //draw_after_screenshot:
  
  
  //peut servir
  if (DEBUG) {
    //println( counter );
  }
  
  cam_input_update();
  inputUpdate(); //voir l'onglet input
}

void reset() {
  
  coml.reset();
  
  //reset_base();
  //init_graphs();

  //reset le conter de tour
  counter = 0;
}





//#######################################################################
//##                             CAMERA                                ##
//#######################################################################


PVector cam_pos = new PVector(0, 0); //position de la camera
float cam_scale = 1.0; //facteur de grossicement
float ZOOM_FACTOR = 1.1; //facteur de modification de cam_scale quand on utilise la roulette de la sourie
boolean GRAB = true;

boolean screenshot = false; //enregistre une image de la frame sans les menu si true puis se desactive
//int shot_cnt = 0; //prevue pour la sauvegarde d'image avec des num coherent

PVector to_cam_view(PVector v) {
  PVector t = new PVector();
  t.x = v.x;
  t.y = v.y;
  t.add(-width / 2, -height / 2);
  t.mult(1 / cam_scale);
  t.add(-(cam_pos.x / cam_scale), -(cam_pos.y / cam_scale));
  return t;
}

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
  translate(width / 2, height / 2);
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
