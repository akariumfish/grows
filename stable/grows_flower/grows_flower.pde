

Base[] BaseList = new Base[0];
int MAX_LIST_SIZE = 5000;
boolean DEBUG = true;
PVector cam_pos = new PVector(0, 0);
float cam_scale = 0.2;
float ZOOM_FACTOR = 1.1;

int counter = 0;

// PERSO    ----------------
PVector DEF_POS = new PVector(0, 0);
float DEF_DIR = 0.0;
int INIT_BASE = 50;

float DEVIATION = PI / 4;
float L_MIN = 1;
float L_MAX = 40;

float GROW_DIFFICULTY = 2.0;
float SPROUT_DIFFICULTY = 200.0;
float STOP_DIFFICULTY = 20.0;
float DIE_DIFFICULTY = 600.0;

int MAX_AGE = 500;

boolean repeat = false;
// PERSO    ----------------

void setup() {
  size(1200, 900);
  setupInput();
  randomSeed(420);
  
  // PERSO    ----------------
  for (int i = 0; i < INIT_BASE; i++) {
    createFirstBase(random( 2 * PI));
  }
  // PERSO    ----------------
  
}

void draw() {
  background(0);
  
  counter++;
  
  // PERSO    ----------------
  if (baseNb() == MAX_LIST_SIZE && repeat) {
    deleteAll();
    //PVector dir = new PVector(0, 0); 
    //dir.x = mouseX - cam_pos.x;
    //dir.y = mouseY - cam_pos.y;
    //DEF_DIR = dir.heading();
    for (int i = 0; i < INIT_BASE; i++) {
      createFirstBase(random( 2 * PI));
    }
  }
  
  // z for pause
  if (keysClick[0]) { repeat = !repeat; }
  
  if (mouseButtons[0]) {
    cam_pos.x += mouseX - pmouseX;
    cam_pos.y += mouseY - pmouseY;
  }
  
  if (mouseWheelUp) { cam_scale *= ZOOM_FACTOR; }
  if (mouseWheelDown) { cam_scale /= ZOOM_FACTOR; }
  
  // PERSO    ----------------
  
  runAll();
  
  pushMatrix();
  translate(cam_pos.x + width / 2, cam_pos.y + height / 2);
  scale(cam_scale);
  drawAll();
  popMatrix();

  if (DEBUG) {
    //println("Frame rate: " + int(frameRate));
    //println( " " );
    println( counter + " " + baseNb());
  }
  
  inputUpdate();
}
