
/*
ici on definie les objet que l'on vas generer

*/



GrowerComunity growerComune = new GrowerComunity();

//class ComunityList
//  add growerComu(list size, init pos, init nb, ...) 
//  add crystalComu
//  slide = selection de comu qui seront run et draw


abstract class CommunityA {
  ArrayList<Entity> entityList = new ArrayList<Entity>(); //contien les objet
  CommunityParam p = new CommunityParam();
  
  void init_Entity_List() { //setting up the list
    init_list();
    delete_All_Entity();
    randomSeed(SEED);
    for (int i = 0 ; i < p.INIT_ENT ; i++) new_Entity();
  }
  abstract void init_list();
  abstract Entity new_Entity();
  
  //ajoute une methode qui lie les entité d'une comu, un event et un try
  //peut etre parametrer par string
  //meme string retourné par func du genre comu.tostrings()[i]
  
  void reset_Entity_List() { //set it ready to grow
    delete_All_Entity();
    randomSeed(SEED);
  }
  
  void run_All_Entity() {
    for (Entity e : entityList) if (e.active) e.run(); }
  void draw_All_Entity() {
    for (Entity e : entityList) if (e.active) e.drawing(); }
  void delete_All_Entity() {
    for (Entity e : entityList) if (e.active) e.destroy(); }
  
  int inactive_Entity_Nb() {
    int n = 0;
    for (Entity e : entityList) if (e.active) n++;
    return n;
  }
}

class GrowerComunity extends CommunityA {
  ArrayList<Grower> list = new ArrayList<Grower>(); //contien les objet

  void init_list() { //setting up the list
    list.clear();
    for (int i = 0; i < p.MAX_ENT ; i++) {
      Grower g = new Grower(this, i);
      list.add(g);
      entityList.add((Entity)g); // !!! pour qu'il sois run et draw !!!
    }
  }
  
  Entity new_Entity() { for (Grower g : list) if (!g.active) return g.reset(); return null; }
  Grower new_Grower() { for (Grower g : list) if (!g.active) { g.reset(); return g; } return null; }
  //void reset_Entity_List() { super.reset_Entity_List(); }//set it ready to grow
}

abstract class Entity { // l'objet, func draw run reset destroy ; Event.action test dans run
  CommunityA comune;
  int id;
  boolean active;
  Entity(CommunityA c, int i) {
    active = false;
    id = i;
    comune = c;
  }
  Entity reset() {
    active = true;
    return this;
  }
  Entity destroy() { if (active) { active = false; } return this; }
  abstract Entity run();
  abstract Entity drawing();
}
  


class Grower extends Entity {
  
  GrowerComunity growCom;
  PVector pos = new PVector();
  PVector grows = new PVector();
  PVector dir = new PVector();
  GrowingEvent growE = new GrowingEvent();
  RandomTry rT= new RandomTry();
  
  Grower(GrowerComunity c, int i) { super(c, i); growCom = c; }
  Grower run() {
    if (rT.trying()) growE.tryAction(this);// grow
    return this;
  }
  Grower drawing() {
    stroke(255); strokeWeight(2);
    line(pos.x,pos.y,grows.x,grows.y);
    return this;
  }
}
