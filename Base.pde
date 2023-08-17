
//ici on definie les objet que l'on vas generer
Base[] BaseList = new Base[0]; //contien les objet
int MAX_LIST_SIZE = 5000; //longueur max de l'array d'objet
int INIT_BASE = 30; //nombre de grower au debut puis apres un reset MODIFIABLE PAR MENU INIT

float DEVIATION = 4; //drifting (rotation posible en portion de pi (PI/drift))
float L_MIN = 1; //longeur minimum de chaque section
float L_MAX = 100; //longeur max de chaque section MODIFIABLE PAR MENU MOVE minimum 1 , limité dans l'update de sont bp
float L_DIFFICULTY = 4;

// un switch les control dans le menu
boolean ON_GROW = true; // active la pousse de nouveau grower au bout des grower actif
boolean ON_SPROUT = true; // active le bourgeonnement de nouveau grower sur les branche
boolean ON_STOP = true; // active l'arret (devien vert)
boolean ON_DIE = true; // active la mort

//les dificulté sont appliqué a crandom, voir dans l'onglet utils elles on toute un control dans le menu
float GROW_DIFFICULTY = 0.833;
float SPROUT_DIFFICULTY = 2500.0;
float STOP_DIFFICULTY = 5.0;
float DIE_DIFFICULTY = 1.8;
int OLD_AGE = 333;

//diminue de autant la dificulté de la mort quand l'array est bientot plein
//float DIE_DIFFICULTY_DIVIDER = 8.0; //when array close to full

float MAX_LINE_WIDTH = 1.5; //epaisseur max des ligne, diminuer par l'age, un peut, se vois pas
float MIN_LINE_WIDTH = 0.2; //epaisseur min des ligne


void init_base() {
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

void reset_base() {
  //tout le monde sur off
  deleteAll();
  //reset du generateur de nombre aleatoire
  randomSeed(SEED);
  //creation des grower initiaux
  for (int i = 0; i < INIT_BASE; i++) {
    createFirstBase(random( 2 * PI));
  }
}

class Base {
  
  int id;
  boolean exist;
  
  Base() {
    exist = false;
    id = 0;
  }
  
  // PERSO    ----------------
  PVector pos;
  PVector grows;
  PVector dir;
  
  // data
  //int root_id = 0;
  //int this_sprout_index = 0;
  //int sprouts_nb = 0;
  //int[] sprouts = new int[0];
  //int rang = 1;
  
  // condition de croissance
  boolean end = false;
  int sprouts = 0;
  float age = 0.0;
  
  // PERSO    ----------------
  
  void init(PVector _p, PVector _d, int _root_id) {    //argument are passed through createBase
    exist = true;
    // PERSO    ----------------
    //root_id = _root_id;
    //rang = BaseList[root_id].rang + 1;
    
    end = false;
    sprouts = 0;
    age = 0;
    
    pos = _p;
    grows = new PVector(L_MIN + crandom(L_DIFFICULTY)*(L_MAX - L_MIN), 0);
    grows.rotate(_d.heading());
    grows.rotate(random(PI / DEVIATION) - ((PI / DEVIATION) / 2));
    dir = new PVector();
    dir = grows;
    grows = PVector.add(pos, grows);
    
     // PERSO    ----------------
  }
  
  void destroy() {
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
  
  void run() {
    // PERSO    ----------------
    
    age++;
    
    // grow
    if (ON_GROW && !end && sprouts == 0 && crandom(GROW_DIFFICULTY) > 0.5) {
      if(createBase(grows, dir, id) != null) sprouts++;
    }
    
    // sprout
    if (ON_SPROUT && !end && crandom(SPROUT_DIFFICULTY) > 0.5) {
      PVector _p = new PVector(0, 0);
      PVector _d = new PVector(0, 0);
      _d.add(grows).sub(pos);
      _d.setMag(random(1.0) * _d.mag());
      _p.add(pos).add(_d);
      createBase(_p, _d, id);
      sprouts++;
      //sprouts = (int[]) expand(sprouts, sprouts.length + 1);
      //sprouts[sprouts.length - 1] = temp_b.id;
      //temp_b.this_sprout_index = sprouts.length - 1;
      //sprouts_nb++;
    }
    
    // stop growing
    if (ON_STOP && !end && sprouts == 0 && crandom(STOP_DIFFICULTY) > 0.5) {
      end = true;
    }
    
    // die
    float rng = crandom(DIE_DIFFICULTY);
    if (ON_DIE && !(!end && sprouts == 0) &&
         (rng > ( (float)OLD_AGE / (float)age ) //||
          //rng / DIE_DIFFICULTY_DIVIDER > ((float)MAX_LIST_SIZE - (float)baseNb()) / (float)MAX_LIST_SIZE
       )) {
      this.destroy();
    }
    
    // PERSO    ----------------
  }
  
  void drawing() {
    // PERSO    ----------------
    
    // aging color
    int ca = 255;
    if (age > OLD_AGE / 2) ca = (int)constrain(255 + int(OLD_AGE/2) - int(age/1.2), 90, 255);
    if (!end && sprouts == 0) { stroke(255, 0, 0); strokeWeight(MAX_LINE_WIDTH+1 / cam_scale); }
    else if (end) { stroke(0, ca, 0); strokeWeight((MAX_LINE_WIDTH+1) / cam_scale); }
    else { stroke(ca, ca, ca); strokeWeight(((float)MIN_LINE_WIDTH + ((float)MAX_LINE_WIDTH * (float)ca / 255.0)) / cam_scale); }              
    //fill(255);
    //ellipseMode(CENTER);
    //ellipse(pos.x, pos.y, 2, 2);
    
    line(pos.x,pos.y,grows.x,grows.y);
    //strokeWeight(MAX_LINE_WIDTH+1 / cam_scale);
    //point(grows.x,grows.y);
    
    // PERSO    ----------------
  }

}

Base createFirstBase(float r) { return createBase(new PVector(0, 0), new PVector(1, 0).rotate(r), 0); }

Base createBase(PVector p, PVector d, int id) {
  for (int i = BaseList.length-1; i >= 0; i--) {
    if (!BaseList[i].exist) {
      BaseList[i].init(p, d, id);
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

int growsNb() {
  int n = 0;
  for (int i = BaseList.length-1; i >= 0; i--) {
    if (BaseList[i].exist && !BaseList[i].end && BaseList[i].sprouts == 0) {
      n++;
    }
  }
  return n;
}
