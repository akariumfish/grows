/*

PApplet
  Log
    DEBUG_SAVE
    DEBUG_SCREEN_INFO
    log(string)
    logln()
  
  void setup()
    Input
    Data
    
    Interface(Input, Data)
    
    Simulation(Interface)
  
  
  void draw()
    Inputs.frame
    Data.frame
    Simulation.frame
    Interface.frame  >  drawing

           
*/


boolean DEBUG = true;
void log(String s) {
  if (DEBUG) print(s);
}
void logln(String s) {
  if (DEBUG) println(s);
}

sInterface interf = new sInterface();



void setup() {//executé au demarage
  size(1600, 900);//taille de l'ecran
  //fullScreen();
  noSmooth();//pas d'antialiasing
  //smooth();//anti aliasing
  
  
  
  
  background(0);//fond noir
}


void draw() {//executé once by frame
  background(0);//fond noir
  //fill(0,0,0,3);
  //noStroke();
  //rect(-10, -10, 10000, 10000);
  //framerate
  
  interf.frame();
  
  //framerate:
  fill(255); 
  textSize(16);
  textAlign(LEFT);
  //text(int(fr.get()) + " " + cam.getCamMouse().x + " " + cam.getCamMouse().y, 400, height - 10 );

  //info
  textSize(24);
  text("test",700,height - 30 );
}
