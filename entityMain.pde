
/*
ici on definie les objet que l'on vas generer

*/




class ComunityList {
  ArrayList<Community> comList = new ArrayList<Community>();
  int active_comu = -1;
  
  ComunityList() {
    
  }
  
  Community new_comu() {
    Community c = new Community(comList.size());
    comList.add(c);
    return c;
  }
  
  void init() {
    // - TEMP - TEMP - TEMP - TEMP - TEMP
    Community c = init_As_Grower(new_comu());
    active_comu = c.id;
  }
  
  void run() {
    if (comList.get(active_comu) != null)
      comList.get(active_comu).run_All();
  }
  
  void draw() {
    if (comList.get(active_comu) != null)
      comList.get(active_comu).draw_All();
  }
  
  // from reset :
  //growerComune.reset_Entity_List();
  //growerComune.new_Entity();
  
  //growerComune.run_All_Entity();
  //growerComune.draw_All_Entity();
  
//  slide = selection de comu qui seront run et draw
//  add event
//  add try
//  get param
  //ajoute une methode qui lie les entité d'une comu, un event et un try
  //peut etre parametrer par string
  //meme string retourné par func du genre comu.tostrings()[i]
}

class Community {
  ArrayList<Entity> list = new ArrayList<Entity>(); //contien les objet
  CommunityParam p;
  int id; //index dans comu list
  
  Community(int i) { id = i; p = new CommunityParam(); }
  Community(int i, CommunityParam _p) { id = i; p = _p; }
  
  Entity new_Entity() { for (Entity g : list) if (!g.active) return g.reset(); return null; }
  
  void reset() { //deactivate all then create starting situation from parameters
    this.kill_All();
    randomSeed(p.SEED);
    for (int i = 0 ; i < p.INIT_ENT ; i++) this.new_Entity();
  }
  
  void run_All() {
    for (Entity e : list) if (e.active) e.run(); }
  void draw_All() {
    for (Entity e : list) if (e.active) e.drawing(); }
  
  void destroy_All() {  //deactivate and clear
    for (Entity e : list) e.destroy(); }
  void kill_All() {    //just deactivate
    for (Entity e : list) e.kill(); }
  
  int inactive_Entity_Nb() {
    int n = 0;
    for (Entity e : list) if (e.active) n++;
    return n;
  }
}

abstract class Entity { // l'objet, func draw run reset destroy ; Event.action test dans run
  Community com;
  int id;
  boolean active;
  Entity(Community c, int i) {
    active = false;
    id = i;
    com = c;
  }
  Entity reset() {
    active = true;
    init();
    return this;
  }
  Entity destroy() { if (active) { active = false; clear(); } return this; }
  Entity kill() { active = false; return this; }
  abstract Entity run();
  abstract Entity drawing();
  abstract Entity init();
  abstract Entity clear();
  
}
