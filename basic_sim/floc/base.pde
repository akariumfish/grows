
//

/*
ici on definie les objet que l'on vas generer

*/

Base[] BaseList = new Base[0]; //contien les objet
int MAX_LIST_SIZE = 100; //longueur max de l'array d'objet
int INIT_BASE = 40; //nombre de grower au debut puis apres un reset MODIFIABLE PAR MENU INIT

float POURSUITE = 0.6;
float FOLLOW = 0.036;
float SPACING = 150;
boolean ON = true;

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
  for (int i = 0; i < INIT_BASE; i++) createBase();
}


class Base {
  
  int id;
  boolean exist;
  
  PVector pos;
  PVector mov;
  float speed = 1;
  
  Base() {
    exist = false;
    id = 0;
    pos = new PVector(0, 0);
    mov = new PVector(0, 0);
  }
  
  void init(int i) {    //argument are passed through createBase
    exist = true;
    id = i;
    pos.x = random(-100, 100);
    pos.y = random(-100, 100);
    mov.x = speed;
    mov.rotate(random(PI * 2));
  }
  
  void destroy() {
    if (exist) { exist = false; }
  }
  
  void run() {
    pos.add(mov);
    mov.rotate(random(PI/16) - PI/32);
    speed = crandom(1) * 10;
    mov.setMag(speed);
  }
  
  void pair(Base b2) {
    float d = dist(pos.x, pos.y, b2.pos.x, b2.pos.y);
    float r1 = 0; float r2 = 0;
    if (d < SPACING) {
      r1 = mapToCircularValues(mov.heading(), b2.mov.heading(), FOLLOW / d, -PI, PI);
      r2 = mapToCircularValues(b2.mov.heading(), mov.heading(), FOLLOW / d, -PI, PI);
    } else {
      PVector l = new PVector(b2.pos.x, b2.pos.y);
      l.add(pos.x * -1, pos.y * -1);
      r1 = mapToCircularValues(mov.heading(), l.heading(), POURSUITE / d, -PI, PI);
      l.mult(-1);
      r2 = mapToCircularValues(b2.mov.heading(), l.heading(), POURSUITE / d, -PI, PI);
    }
    mov.x = speed; mov.y = 0;
    mov.rotate(r1);
    b2.mov.x = b2.speed; b2.mov.y = 0;
    b2.mov.rotate(r2);
  }
  
  void drawing() {
    fill(255);
    stroke(255);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(mov.heading());
    line(0, 0, -10, -10);
    line(2, 0, -10, 0);
    line(0, 0, -10, 10);
    popMatrix();
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

float mapToCircularValues(float current, float cible, float increment, float start, float stop) {
  if (start > stop) {float i = start; start = stop; stop = i;}
  increment = abs(increment);
  
  while (cible > stop) {cible -= (stop - start);}
  while (current > stop) {current -= (stop - start);}
  while (cible < start) {cible += (stop - start);}
  while (current < start) {current += (stop - start);}
  
  if (cible < current) {
    if ( (current - cible) <= (stop - current + cible - start) ) {
      if (increment >= current - cible) {return cible;}
      else                              {return current - increment;}
    } else {
      if (increment >= stop - current + cible - start) {return cible;}
      else if (current + increment < stop)             {return current + increment;}
      else                                             {return start + (increment - (stop - current));}
    }
  } else if (cible > current) {
    if ( (cible - current) <= (stop - cible + current - start) ) {
      if (increment >= cible - current) {return cible;}
      else                              {return current + increment;}
    } else { 
      if (increment >= stop - cible + current - start) {return cible;}
      else if (current - increment > start)            {return current - increment;}
      else                                             {return stop - (increment - (current - start));}
    }
  }
  return cible;
}

void pairAll() {
  for (int i = 0; i < BaseList.length-1 ; i++)
    for (int j = i+1 ; j < BaseList.length ; j++)
      if (BaseList[i].exist && BaseList[j].exist)
        BaseList[i].pair(BaseList[j]);
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
