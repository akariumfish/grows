
/*
ici on definie les objet de structure

*/


class ComunityList {
  ArrayList<Community> list = new ArrayList<Community>();
  sPanel panel;
  sTextfield file_path_tf;
  
  ComunityList() {
    panel = new sPanel(cp5, 780, 20)
      .addText("SIMULATION CONTROL", 28, 0, 28)
      .addLine(10)
      .addDrawer(30)
        .addText("SEED: ", 50, 4)
          .getDrawer()
        .addTextfield(130, 5)
          .setValue(SEED)
          .setSize(200, 20)
          .getDrawer()
        .getPanel()
      .addDrawer(30)
        .addText("framerate: ", 30, 0)
          .setValue(framerate)
          .getDrawer()
        .addText("turn: ", 200, 0)
          .setValue(tick)
          .getDrawer()
        .getPanel()
      .addFltController("SPEED: ", tick_by_frame)
      .addSeparator(10)
      .addDrawer(30)
        .addSwitch("P", 20, 0)
          .setValue(pause)
          .setSize(40, 30)
          .getDrawer()
        .addButton("R", 80, 0)
          .setSize(100, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { reset(); } } )
          .getDrawer()
        .addButton("RNG", 200, 0)
          .setSize(100, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { SEED.set(int(random(1000000000))); reset(); } } )
          .getDrawer()
        .addButton("I", 320, 0)
          .setSize(40, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { cam.screenshot = true; } } )
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      .addDrawer(30)
        .addSwitch("AUTO", 0, 0)
          .setValue(auto_reset)
          .setSize(50, 30)
          .setFont(16)
          .getDrawer()
        .addSwitch("RNG", 60, 0)
          .setValue(auto_reset_rng_seed)
          .setSize(50, 30)
          .setFont(16)
          .getDrawer()
        .addButton("-100", 120, 0)
          .setSize(50, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { auto_reset_turn.set(auto_reset_turn.get()-100); } } )
          .getDrawer()
        .addText("restart at: ", 180, 5)
          .setValue(auto_reset_turn)
          .getDrawer()
        .addButton("+100", 330, 0)
          .setSize(50, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { auto_reset_turn.set(auto_reset_turn.get()+100); } } )
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      .addDrawer(30)
        .addButton("S", 0, 0)
          .setSize(60, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { saving(simval, file_path_tf.getText()); } } )
          .getDrawer()
        .addButton("L", 320, 0)
          .setSize(60, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { loading(simval, file_path_tf.getText()); } } )
          .getDrawer()
        .getPanel()
      ;
    file_path_tf = panel.lastDrawer().addTextfield(70, 0)
      .setText("save.txt")
      .setSize(240, 30)
      ;
    panel.addSeparator(10);
  }
  
  void tick() {
    for (Community c : list) c.tick();
  }
  
  void draw() {
    for (Community c : list) c.draw_All();
  }
  
  void comunity_reset() {
    randomSeed(SEED.get());
    for (Community c : list) c.reset();
  }
}

abstract class Community {
  ArrayList<Entity> list = new ArrayList<Entity>(); //contien les objet
  int MAX_ENT = 5000; //longueur max de l'array d'objet
  sInt initial_entity = new sInt(simval, 50);
  int id; //index dans comu list
  sInt activeEntity = new sInt(simval, 0);
  ComunityList comList;
  sPanel panel;
  sBoo adding_type = new sBoo(simval, true);
  int adding_pile = 0;
  sInt adding_step = new sInt(simval, 10); // add one new object each adding_step turn
  float adding_counter = 0;
  
  Community(ComunityList _c) { comList = _c; }
    
  void init() {
    id = comList.list.size();
    comList.list.add(this);
    list.clear();
    for (int i = 0; i < MAX_ENT ; i++)
      list.add(build());
    
    panel = new sPanel(cp5, 1190, 20)
      .addText("COMUNITY CONTROL", 38, 0, 28)
      .addLine(10)
      .addText("Utilities", 140, 0, 22)
      .addSeparator(8)
      .addDrawer(20)
        .addText("Active Entity: ", 0, 0)
          .setValue(activeEntity)
          .setFont(18)
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      .addIntController("To Add: ", initial_entity)
      .addSeparator(10)
      .addIntController("Step: ", adding_step).lastDrawer()
        .addSwitch("S", 80, 5)
          .setValue(adding_type)
          .setSize(20, 20).setFont(18)
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      .addDrawer(30)
        .addButton("ADD", 120, 0)
          .setSize(140, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { adding_pile += initial_entity.get(); } } )
          .getDrawer()
        .getPanel()
      .addLine(22)
      ;
  }
  
  void reset() { //deactivate all then create starting situation from parameters
    this.destroy_All();
    if (!adding_type.get()) 
      for (int j = 0; j < initial_entity.get(); j++)
        initialEntity();
    if (adding_type.get()) adding_pile = initial_entity.get();
  }
  
  void tick() {
    if (adding_type.get() && adding_pile >= 1) {
      adding_counter++;
      if (adding_counter >= adding_step.get()) {
        adding_counter = 0;
        initialEntity();
        adding_pile--;
      }
    }
    for (Entity e : list) if (e.active) e.tick();
    activeEntity.set(active_Entity_Nb());
  }
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
  abstract Entity initialEntity();
  abstract Entity newEntity();
}

abstract class Entity { 
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
  abstract Entity tick();      //exec by community in run all
  abstract Entity drawing();  //exec by community in draw all
  abstract Entity init();     //exec by activate and community.reset
  abstract Entity clear();    //exec by destroy
}
