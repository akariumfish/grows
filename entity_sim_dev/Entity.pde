
/*
ici on definie les objet que l'on vas generer

*/



ArrayList<Entity> mainList = new ArrayList<Entity>(); //contien les objet
int MAX_POP = 10000; //longueur max de l'array d'objet
int INIT_BASE = 0; //nombre de grower au debut puis apres un reset MODIFIABLE PAR MENU INIT
int SEED = 548651008; //seed pour l'aleatoire


void init_Entity_List(ArrayList<Entity> list) { //setting up the list
  list.clear();
  for (int i = 0; i < MAX_POP ; i++) {
    Entity e = new Entity(list, i);
    list.add(e);
  }
  reset_Entity_List(list);
  
  new_Entity(mainList, new PVector(0, 0), new PVector(1, 0));
  
}

void reset_Entity_List(ArrayList<Entity> list) { //set it ready to grow
  delete_All_Entity(list);
  randomSeed(SEED);
}

Entity new_Entity(ArrayList<Entity> list, PVector p, PVector d) {
  for (Entity e : list) if (!e.active) return e.reset(p,d);
  return null; }

void run_All_Entity(ArrayList<Entity> list) {
  for (Entity e : list) if (e.active) e.run(); }
void draw_All_Entity(ArrayList<Entity> list) {
  for (Entity e : list) if (e.active) e.drawing(); }
void delete_All_Entity(ArrayList<Entity> list) {
  for (Entity e : list) if (e.active) e.destroy(); }

int inactive_Entity_Nb(ArrayList<Entity> list) {
  int n = 0;
  for (Entity e : list) if (e.active) n++;
  return n;
}

class Entity { // l'objet, func draw run reset destroy ; Event.action test dans run
  ArrayList<Entity> list;
  int id;
  boolean active;
  
  // PERSO    ----------------
  PVector pos = new PVector();
  PVector grows = new PVector();
  PVector dir = new PVector();
  // PERSO    ----------------
  
  Event event;
  Parameters params;
  
  Entity(ArrayList<Entity> l, int i) {
    active = false;
    id = i;
    list = l;
    event = new Event();
    params = new Parameters();
  }
  Entity reset(PVector _p, PVector _d) {
    active = true;
    return this;
  }
  Entity destroy() { if (active) { active = false; } return this; }
  Entity run() {
    event.tryAction(this, params);// grow
    return this;
  }
  Entity drawing() {
    stroke(255); strokeWeight(2);
    line(pos.x,pos.y,grows.x,grows.y);
    return this;
  }
}
