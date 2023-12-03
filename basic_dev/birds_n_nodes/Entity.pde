
/*
ici on definie les objet de structure

*/



int SEED = 548651008;

class ComunityList {
  ArrayList<Community> list = new ArrayList<Community>();
  Panel mainPanel;
  
  ComunityList() {
    init();
  }
  
  void init() {
    mainPanel = addPanel("SIMULATION CONTROL", width - 410, 20);
    mainPanel.addButton("p", 12, 
                   50, 50, 300, 20, 
                   new ControlListener() {
          public void controlEvent(final ControlEvent ev) {  
            pause = !pause;
          }
        });
  }
  
  void run() {
    for (Community c : list) c.run_All();
  }
  
  void draw() {
    for (Community c : list) c.draw_All();
  }
  
  void reset() {
    randomSeed(SEED);
    for (Community c : list) c.reset();
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

class CommunityParam {
  int MAX_ENT = 50; //longueur max de l'array d'objet
  int INIT_ENT = 20;
  CommunityParam() {}
  CommunityParam(int m, int i) { MAX_ENT = m; INIT_ENT = i; }
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
  }
  
  void reset() { //deactivate all then create starting situation from parameters
    this.destroy_All();
    Entity e = null;
    for (int i = 0 ; i < p.INIT_ENT ; i++) {
      for (Entity g : list) if (!g.active) { e = g; break; }
      if (e != null) e.activate();
      else break;
      e = null;
    }
  }
  
  void run_All() {
    for (Entity e : list) if (e.active) e.run(); }
  void draw_All() {
    for (Entity e : list) if (e.active) e.drawing(); }
  void destroy_All() {
    for (Entity e : list) e.destroy(); }
  
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
  Entity activate() {
    if (!active) { active = true; init(); }
    return this;
  }
  Entity destroy() {
    if (active) { active = false; clear(); }
    return this;
  }
  abstract Entity run();      //exec by community in run all
  abstract Entity drawing();  //exec by community in draw all
  abstract Entity init();     //exec by activate and community.reset
  abstract Entity clear();    //exec by destroy
  
}
