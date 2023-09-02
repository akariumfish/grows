
/*
ici on definie les objet que l'on vas generer

*/




class ComunityList {
  ArrayList<Community> list = new ArrayList<Community>();
  int active_comu = -1;
  
  ComunityList() {
    init();
  }
  
  void init() {
    // - TEMP - TEMP - TEMP - TEMP - TEMP
    GrowerComu c = new GrowerComu(this);
    active_comu = c.id;
  }
  
  void run() {
    if (list.get(active_comu) != null)
      list.get(active_comu).run_All();
  }
  
  void draw() {
    if (list.get(active_comu) != null)
      list.get(active_comu).draw_All();
  }
  
  void reset() {
    if (list.get(active_comu) != null)
      list.get(active_comu).reset();
  }
  
//  slide = selection de comu qui seront run et draw

/*
run_speeded
run_each_unpaused_frame
run_each_frame
draw_on_screen
draw_on_camera
draw_after_screenshot
menuEvent
init //run at setup
reset //starting state
hide //dont draw
show //draw
activate //run
deactivate //dont run
*/

}

abstract class Community {
  ArrayList<Entity> list = new ArrayList<Entity>(); //contien les objet
  CommunityParam p;
  int id; //index dans comu list
  ComunityList comList;
  
  Community(ComunityList _c) { comList = _c; p = new CommunityParam(); }
    
  void init() {
    id = comList.list.size();
    comList.list.add(this);
    list.clear();
    for (int i = 0; i < p.MAX_ENT ; i++)
      list.add(build());
    reset();
  }
  
  Entity new_Entity() { for (Entity g : list) if (!g.active) return g.reset(); return null; }
  
  void reset() { //deactivate all then create starting situation from parameters
    this.kill_All();
    randomSeed(p.SEED);
    for (int i = 0 ; i < p.INIT_ENT ; i++) this.new_Entity().randomize();
  }
  
  void run_All() {
    for (Entity e : list) if (e.active) e.run(); }
  void draw_All() {
    for (Entity e : list) if (e.active) e.drawing(); }
  
  void destroy_All() {  //deactivate and clear
    for (Entity e : list) e.destroy(); }
  void kill_All() {    //just deactivate
    for (Entity e : list) e.kill(); }
  
  int active_Entity_Nb() {
    int n = 0;
    for (Entity e : list) if (e.active) n++;
    return n;
  }
  
  abstract Entity build();
}

abstract class Entity { // l'objet, func draw run reset destroy ; Event.action test dans run
  Community com;
  int id;
  boolean active;
  Entity(Community c) {
    active = false;
    id = c.list.size();
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
  abstract Entity randomize();
  
}
