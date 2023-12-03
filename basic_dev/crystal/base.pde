
//

/*
ici on definie les objet que l'on vas generer

*/

Base[] BaseList = new Base[0]; //contien les objet
int MAX_LIST_SIZE = 100; //longueur max de l'array d'objet
int INIT_BASE = 1; //nombre de grower au debut puis apres un reset MODIFIABLE PAR MENU INIT

int INIT_SIZE = 400;

float DIFICULTY = 2.77;
boolean ON = true;

float MIN_SIZE = 10;
float SPACING = 2;
float LINE_SIZE = 1;

void init_base() {
  // redimensionement de l'array a ca taille max
  BaseList = (Base[]) expand(BaseList, MAX_LIST_SIZE);
  
  for (int i = 0 ; i < MAX_LIST_SIZE ; i++) {
    BaseList[i] = new Base();
    BaseList[i].id = i;
    BaseList[i].init(i);
  }
  
  reset_base();
}

void reset_base() {
  deleteAll();
  randomSeed(SEED);
  createBase();
}

boolean between(float a, float min, float max) { return (a >= min && a <= max); }

class Base {
  
  int id;
  boolean exist;
  
  PVector pos = new PVector();
  PVector sz = new PVector();
  
  Base() {
    exist = false;
    id = 0;
  }
  
  boolean contact(Base b) {
    return pos.x + sz.x >= b.pos.x - 1 && 
           pos.x        <= b.pos.x + b.sz.x + 1 && 
           pos.y + sz.y >= b.pos.y - 1 && 
           pos.y        <= b.pos.y + b.sz.y + 1 ; }
  
  boolean contact(float x, float y) {
    return (x >= pos.x - 1 &&
            x <= pos.x + sz.x + 1 &&
            y >= pos.y - 1 &&
            y <= pos.y + sz.y + 1); }
  
  void init(int i) {    //argument are passed through createBase
    exist = true;
    id = i;
    
    pos = new PVector(- INIT_SIZE / 2, - INIT_SIZE / 2);
    sz = new PVector(INIT_SIZE,INIT_SIZE);
    
  }
  
  void destroy() {
    if (exist) { exist = false; }
  }
  
  void run() {
    if ((ON && crandom(DIFICULTY) > 0.5)) {
      float f = random(1.0);
      float rng = random(1.0);
      if (rng > 0.5 && sz.x * f > MIN_SIZE && sz.x * (1-f) > MIN_SIZE) {
        Base n = createBase();
        if (n != null) {
          n.pos = new PVector(pos.x, pos.y);
          n.sz = new PVector(sz.x, sz.y);
          n.sz.x *= f;
          sz.x -= n.sz.x;
          n.pos.x += sz.x;
        }
      } else if (rng < 0.5 && sz.y * f > MIN_SIZE && sz.y * (1-f) > MIN_SIZE) {
        Base n = createBase();
        if (n != null) {
          n.pos = new PVector(pos.x, pos.y);
          n.sz = new PVector(sz.x, sz.y);
          n.sz.y *= f;
          sz.y -= n.sz.y;
          n.pos.y += sz.y;
        }
      }
    }
    PVector c = new PVector(pos.x, pos.y);
    c.x += sz.x / 2;
    c.y += sz.y / 2;
    
    if (c.mag() > INIT_SIZE / 2.0) {
      destroy();
    }
    
    if (contact(mouse_pos.x, mouse_pos.y)) {
      if (mouseClick[0]) {
        float fx = (mouse_pos.x - pos.x) / sz.x;
        fx = 1 - fx;
        if (sz.x * fx > MIN_SIZE && sz.x * (1-fx) > MIN_SIZE) {
          Base n = createBase();
          if (n != null) {
            n.pos = new PVector(pos.x, pos.y);
            n.sz = new PVector(sz.x, sz.y);
            n.sz.x *= fx;
            sz.x -= n.sz.x;
            n.pos.x += sz.x;
          }
        }
      } 
      if (mouseClick[1]) {
        float fy = (mouse_pos.y - pos.y) / sz.y;
        fy = 1 - fy;
        if (sz.y * fy > MIN_SIZE && sz.y * (1-fy) > MIN_SIZE) {
          Base n = createBase();
          if (n != null) {
            n.pos = new PVector(pos.x, pos.y);
            n.sz = new PVector(sz.x, sz.y);
            n.sz.y *= fy;
            sz.y -= n.sz.y;
            n.pos.y += sz.y;
          }
        }
      }
    }
  }
  
  void drawing() {
    noFill();
    stroke(255);
    for (Base b : BaseList) {
      if (b.id != this.id && !this.contact(b) && b.contact(mouse_pos.x, mouse_pos.y)) stroke(255, 0, 0);
    }
    //if (contact(mouse_pos.x, mouse_pos.y)) stroke(255, 0, 0);
    strokeWeight(LINE_SIZE);
    //rectMode(CENTER);
    rect(pos.x, pos.y, sz.x - SPACING - (LINE_SIZE / 2), sz.y - SPACING - (LINE_SIZE / 2));
    //stroke(255, 0, 0);
    //point(pos.x, pos.y);
  }

}

Base createBase() {
  for (int i = BaseList.length-1; i >= 0; i--) {
    if (!BaseList[i].exist) {
      BaseList[i].init(i);
      return BaseList[i];
    }
  }
  return null;
}

void runAll() {
  for (int i = BaseList.length-1; i >= 0; i--) {
    if (BaseList[i].exist ) {
      BaseList[i].run();
    }
  }
}

void drawAll() {
  for (int i = BaseList.length-1; i >= 0; i--) {
    if (BaseList[i].exist ) {
      BaseList[i].drawing();
    }
  }
}

void deleteAll() {
  for (int i = BaseList.length-1; i >= 0; i--) {
    if (BaseList[i].exist) {
      BaseList[i].destroy();
    }
  }
}

int baseNb() {
  int n = 0;
  for (int i = BaseList.length-1; i >= 0; i--) {
    if (BaseList[i].exist ) {
      n++;
    }
  }
  return n;
}
