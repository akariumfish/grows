/*
PApplet
  Log
    DEBUG_SAVE
    DEBUG_SCREEN_INFO
    log(string)
    logln()

  void setup()
    Interface
    Simulation(Interface)

  void draw()
    Interface.frame  >  frame events, drawing
*/


boolean DEBUG = true;
void log(String s) {
  if (DEBUG) print(s);
}
void logln(String s) {
  if (DEBUG) println(s);
}

sInterface interf;

Simulation sim;
GrowerComu gcom;


void setup() {//executé au demarage
  size(1600, 900);//taille de l'ecran
  //fullScreen();
  noSmooth();//pas d'antialiasing
  //smooth();//anti aliasing
  
  interf = new sInterface();
  sim = new Simulation(interf);
  gcom = new GrowerComu(sim);
  
  background(0);//fond noir
}


void draw() {//executé once by frame
  interf.frame();
}
