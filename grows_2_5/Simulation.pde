
/*
ici on definie les objet de structure

*/


class Simulation {
  ArrayList<Community> list = new ArrayList<Community>();
  sPanel panel;
  sTextfield file_path_tf;
  
  sFlt tick = new sFlt(simval, 0); //conteur de tour depuis le dernier reset ou le debut
  sBoo pause = new sBoo(simval, false); //permet d'interompre le defilement des tour
  sFlt tick_by_frame = new sFlt(simval, 16); //nombre de tour a executé par frame
  float tick_pile = 0; //pile des tour
  sInt SEED = new sInt(simval, 548651008); //seed pour l'aleatoire
  sBoo auto_reset = new sBoo(simval, true);
  sBoo auto_reset_rng_seed = new sBoo(simval, true);
  sInt auto_reset_turn = new sInt(simval, 4000);
  sBoo auto_screenshot = new sBoo(simval, false);
  
  Channel tick_chan = new Channel();
  Channel unpaused_frame_chan = new Channel();
  
  boolean next_tick = false;
  
  Simulation() {
    
  }
  
  void building() {
    //menu principale de la sim
    panel = new sPanel(cp5, 1190, 430)
      .addTitle("SIMULATION CONTROL", 28, 0, 28)
      .addLine(10)
      .addDrawer(30)
        .addText("SEED: ", 50, 4)
          .getDrawer()
        .addTextfield(130, 5)
          .setValue(SEED)
          .setSize(200, 20)
          .getDrawer()
        .getPanel()
      .addDrawer(60)
        .addText("framerate: ", 30, 0)
          .setValue(fr.value)
          .getDrawer()
        .addText("time (s): ", 200, 0)
          .setValue(fr.time)
          .getDrawer()
        .addText("tickrate: ", 30, 30)
          .setValue(fr.tickrate)
          .getDrawer()
        .addText("tick: ", 200, 30)
          .setValue(tick)
          .getDrawer()
        .getPanel()
      .addValueController("tick / frame:", sMode.FACTOR, 2, 1.2, tick_by_frame)
      .addSeparator(10)
      .addDrawer(30)
        .addSwitch("PAUSE", 20, 0)
          .setValue(pause)
          .setSize(170, 30)
          .getDrawer()
        .addButton("NEXT TICK", 200, 0)
          .setSize(160, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { next_tick = true; } } )
          .getDrawer()
        .getPanel()
        .addSeparator(10)
      .addDrawer(30)
        
        .addButton("RESET", 20, 0)
          .setSize(80, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { reset(); } } )
          .getDrawer()
        .addButton("RNG", 110, 0)
          .setSize(80, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { SEED.set(int(random(1000000000))); reset(); } } )
          .getDrawer()
        .addButton("NEXT FRAME", 200, 0)
          .setSize(160, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) {
              for (int i = 0; i < tick_by_frame.get()-1; i++) tick();
              next_tick = true;
            } } )
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
        .addSwitch("Canvas", 0, 0)
          .setValue(can.show_canvas)
          .setSize(100, 30)
          .setFont(18)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { 
              if (can.show_canvas.get()) can.can_grab.hide(); else can.can_grab.show();
            } } )
          .getDrawer()
        .addSwitch("Bound", 110, 0)
          .setValue(can.show_canvas_bound)
          .setSize(100, 30)
          .setFont(18)
          .getDrawer()
        .addSwitch("Grid", 280, 0)
          .setValue(cam.grid)
          .setSize(100, 30)
          .setFont(18)
          .getDrawer()
        .getPanel().addSeparator(10)
      .addDrawer(30)
        .addButton("S", 0, 0)
          .setSize(60, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { 
              saving(simval, file_path_tf.getText()); } } )
          .getDrawer()
        .addButton("L", 270, 0)
          .setSize(60, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { 
              loading(simval, file_path_tf.getText()); 
              reset(); } } )
          .getDrawer()
        .addButton("I", 340, 0)
          .setSize(20, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { cam.screenshot = true; } } )
          .getDrawer()
        .addSwitch("A", 360, 0)
          .setValue(auto_screenshot)
          .setSize(20, 30)
          .getDrawer()
        .getPanel()
      ;
    file_path_tf = panel.lastDrawer().addTextfield(70, 0)
      .setText("save.txt")
      .setSize(190, 30)
      
      ;
    //file_path_tf.setColor(color(255));
    panel.addSeparator(10);
    
    //macro custom et menu d'ajout
    //plane.build_panel
    //  .addText("Simulation :", 0, 0, 18)
    //  .addSeparator(8)
    //  .addDrawer(30)
    //    .addButton("RESET", 20, 0)
    //      .setSize(80, 30)
    //      .addListener(new ControlListener() {
    //        public void controlEvent(final ControlEvent ev) { newMacroSimIN1(); } } )
    //      .getDrawer()
    //    .addButton("RUN", 110, 0)
    //      .setSize(80, 30)
    //      .addListener(new ControlListener() {
    //        public void controlEvent(final ControlEvent ev) { newMacroSimIN2(); } } )
    //      .getDrawer()
    //    .addButton("AUTO", 200, 0)
    //      .setSize(80, 30)
    //      .addListener(new ControlListener() {
    //        public void controlEvent(final ControlEvent ev) { newMacroSimIN3(); } } )
    //      .getDrawer()
    //    .addButton("OUT", 290, 0)
    //      .setSize(80, 30)
    //      .addListener(new ControlListener() {
    //        public void controlEvent(final ControlEvent ev) { newMacroSimOUT(); } } )
    //      .getDrawer()
    //    .getPanel()
    //  .addSeparator(10)
    //  ;
    for (Community c : list) c.building();
  }
  
  void newMacroSimIN1() {
    //new MacroCUSTOM(plane)
    //  .setLabel("SIM RESET")
    //  .setWidth(170)
    //  .addMCRun()
    //    .addRunnable(new Runnable() { public void run() { reset(); }})
    //    .setText("reset")
    //    .getMacro()
    //  .addMCRun()
    //    .addRunnable(new Runnable() { public void run() { SEED.set(int(random(1000000000))); reset(); }})
    //    .setText("rng")
    //    .getMacro()
    //  ;
  }
  
  void newMacroSimIN2() {
    //new MacroCUSTOM(plane)
    //  .setLabel("SIM RUN")
    //  .setWidth(155)
    //  .addMCsBooWatcher()
    //    .addValue(pause)
    //    .setText("pause")
    //    .getMacro()
    //  .addMCsBooControl()
    //    .setValue(pause)
    //    .setText("")
    //    .getMacro()
    //  .addMCRun()
    //    .addRunnable(new Runnable() { public void run() { next_tick = true; }})
    //    .setText("tick")
    //    .getMacro()
    //  .addMCsFltControl()
    //    .setValue(tick_by_frame)
    //    .setText("speed")
    //    .getMacro()
    //  ;
  }
  
  void newMacroSimIN3() {
    //new MacroCUSTOM(plane)
    //  .setLabel("SIM AUTO")
    //  .setWidth(170)
    //  .addMCsBooControl()
    //    .setValue(auto_reset)
    //    .setText("auto reset")
    //    .getMacro()
    //  .addMCsIntControl()
    //    .setValue(auto_reset_turn)
    //    .setText("reset tick")
    //    .getMacro()
    //  ;
  }
  
  void newMacroSimOUT() {
    //new MacroCUSTOM(plane)
    //  .setLabel("SIM OUT")
    //  .setWidth(170)
    //  .align()
    //  .addMCsFltWatcher()
    //    .addValue(tick)
    //    .setText("   tick")
    //    .getMacro()
    //  .addMCsFltWatcher()
    //    .addValue(tick_by_frame)
    //    .setText("   speed")
    //    .getMacro()
    //  .addMCsIntWatcher()
    //    .addValue(fr.value)
    //    .setText("framerate")
    //    .getMacro()
    //  .addMCsIntWatcher()
    //    .addValue(fr.time)
    //    .setText("time s")
    //    .getMacro()
    //  ;
  }
  
  void reset() {
    randomSeed(SEED.get());
    for (Community c : list) c.reset();
    tick.set(0);
    fr.reset();
  }
  
  void frame() {
    for (Community c : list) c.isFrame = true;
    if (!pause.get()) {
      tick_pile += tick_by_frame.get();
      
      //auto screenshot before reset
      if (auto_reset.get() && auto_reset_turn.get() == tick.get() + tick_by_frame.get() + tick_by_frame.get() && auto_screenshot.get()) {
          cam.screenshot = true; }
      
      boolean flag = true;
      while (tick_pile >= 1) {
        tick();
        if (flag) for (Community c : list) c.isFrame = false;
        flag = false;
        tick_pile--;
      }
      
      //run_each_unpaused_frame
      callChannel(unpaused_frame_chan);
    }
    
    if (next_tick) { tick(); next_tick = false; }
    
    //run custom frame methods
    for (Community c : list) c.frame();
  }
  
  void tick() {
    
    //auto reset
    if (auto_reset.get() && auto_reset_turn.get() <= tick.get()) {
      if (auto_reset_rng_seed.get()) {
        SEED.set(int(random(1000000000)));
      }
      reset();
    }
    
    //tick communitys
    for (Community c : list) c.tick();
    
    //tick call
    callChannel(tick_chan);
    
    tick.set(tick.get()+1);
  }
  
  void draw_to_cam() {
    for (Community c : list) if (c.show_entity.get()) c.custom_cam_draw_pre_entity();
    for (Community c : list) if (c.show_entity.get()) c.draw_Cam();
    for (Community c : list) if (c.show_entity.get()) c.custom_cam_draw_post_entity();
  }
  void draw_to_screen() { for (Community c : list) if (c.show_entity.get()) c.draw_Screen(); }
}

abstract class Community {
  ArrayList<Entity> list = new ArrayList<Entity>(); //contien les objet
  sInt MAX_ENT = new sInt(simval, 500); //longueur max de l'array d'objet
  sInt initial_entity = new sInt(simval, 0);
  int id; //index dans comu list
  sInt activeEntity = new sInt(simval, 0);
  Simulation comList;
  sPanel panel;
  sBoo adding_type = new sBoo(simval, true);
  int adding_pile = 0;
  sInt adding_step = new sInt(simval, 10); // add one new object each adding_step turn
  float adding_counter = 0;
  sBoo show_entity = new sBoo(simval, true);
  sBoo show_menu = new sBoo(simval, true);
  String name = "";
  boolean isFrame = false;
  
  Community(Simulation _c, String n, int max) { comList = _c; name = n; MAX_ENT.set(max); }
  
  Community show_menu() { panel.g.show(); show_menu.set(true); return this; }
  Community hide_menu() { panel.g.hide(); show_menu.set(false); return this; }
  Community show_entity() { show_entity.set(true); return this; }
  Community hide_entity() { show_entity.set(false); return this; }
  
  //void custom_setup() {}
  //void custom_draw() {}
  void custom_build() {}
  void custom_reset() {}
  void custom_frame() {}
  abstract void custom_pre_tick();
  abstract void custom_post_tick();
  abstract void custom_cam_draw_pre_entity();
  abstract void custom_cam_draw_post_entity();
  void custom_screen_draw() {}
  
  void building() {
    comList.panel.addDrawer(20)
        .addText("Community: "+name, 0, 0)
          .setFont(18)
          .getDrawer()
        .addSwitch("M", 280, 0)
          .setValue(show_menu)
          .setSize(50, 20).setFont(18)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { 
              if (show_menu.get()) panel.big.hide(); else panel.big.show(); } } )
          .getDrawer()
        .addSwitch("D", 330, 0)
          .setValue(show_entity)
          .setSize(50, 20).setFont(18)
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      ;
    
    panel = new sPanel(cp5, 20 + id*50, 20 + id*30)
      .addTitle(name+" Control", 90, 0, 28)
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
      .addValueController("Max Entity: ", sMode.INCREMENT, 100, 10, MAX_ENT).lastDrawer()
        .addButton("i", 80, 5)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { init_array(); reset(); } } )
          .setSize(20, 20).setFont(18)
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      .addValueController("To Add: ", sMode.INCREMENT, 10, 1, initial_entity)
      .addSeparator(10)
      .addValueController("Step: ", sMode.INCREMENT, 10, 1, adding_step).lastDrawer()
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
    if (!show_menu.get()) panel.big.hide();
    
    //plane.build_panel
    //  .addText("Community: " + name, 0, 0, 18)
    //  .addSeparator(8)
    //  .addDrawer(30)
    //    .addButton("INIT", 0, 0)
    //      .setSize(120, 30)
    //      .addListener(new ControlListener() {
    //        public void controlEvent(final ControlEvent ev) { newMacroComuINIT(); } } )
    //      .getDrawer()
    //    .addButton("ADD", 130, 0)
    //      .setSize(120, 30)
    //      .addListener(new ControlListener() {
    //        public void controlEvent(final ControlEvent ev) { newMacroComuADD(); } } )
    //      .getDrawer()
    //    .addButton("POP", 260, 0)
    //      .setSize(120, 30)
    //      .addListener(new ControlListener() {
    //        public void controlEvent(final ControlEvent ev) { newMacroComuOUT(); } } )
    //      .getDrawer()
    //    .getPanel()
    //  .addSeparator(10)
    //  ;
    custom_build();
  }
  
  void newMacroComuINIT() {
    //new MacroCUSTOM(plane)
    //  .setLabel(name + " INIT")
    //  .setWidth(250)
    //  .addMCsIntControl()
    //    .setValue(MAX_ENT)
    //    .setText("")
    //    .getMacro()
    //  .addMCsIntControl()
    //    .setValue(initial_entity)
    //    .setText("")
    //    .getMacro()
    //  .addMCsIntControl()
    //    .setValue(adding_step)
    //    .setText("")
    //    .getMacro()
    //  .addMCsBooControl()
    //    .setValue(adding_type)
    //    .setText("              do step")
    //    .getMacro()
    //  .addMCsIntWatcher()
    //    .addValue(MAX_ENT)
    //    .setText("     max")
    //    .getMacro()
    //  .addMCsIntWatcher()
    //    .addValue(initial_entity)
    //    .setText("     add")
    //    .getMacro()
    //  .addMCsIntWatcher()
    //    .addValue(adding_step)
    //    .setText("    step")
    //    .getMacro()
    //  .addMCsBooWatcher()
    //    .addValue(adding_type)
    //    .setText("")
    //    .getMacro()
    //  ;
  }
  
  void newMacroComuADD() {
    //new MacroCUSTOM(plane)
    //  .setLabel("ADD " + name)
    //  .setWidth(120)
    //  .addMCRun()
    //    .addRunnable(new Runnable() { public void run() { adding_pile += initial_entity.get(); }})
    //    .setText("add")
    //    .getMacro()
    //  ;
  }
  
  void newMacroComuOUT() {
    //new MacroCUSTOM(plane)
    //  .setLabel(name + " POP")
    //  .setWidth(160)
    //  .addMCsIntWatcher()
    //    .addValue(activeEntity)
    //    .setText("  active")
    //    .getMacro()
    //  ;
  }
  
  void init_array() {
    list.clear();
    for (int i = 0; i < MAX_ENT.get() ; i++)
      list.add(build());
  }
  
  void init() {
    id = comList.list.size();
    comList.list.add(this);
    init_array();
  }
  
  void reset() { //deactivate all then create starting situation from parameters
    this.destroy_All();
    if (MAX_ENT.get() != list.size()) init_array();
    if (!adding_type.get()) 
      for (int j = 0; j < initial_entity.get(); j++)
        initialEntity();
    if (adding_type.get()) adding_pile = initial_entity.get();
    custom_reset();
  }
  
  void frame() {
    custom_frame();
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
    custom_pre_tick();
    for (Entity e : list) if (e.active) e.tick();
    for (Entity e : list) if (e.active) e.age++;
    activeEntity.set(active_Entity_Nb());
    custom_post_tick();
  }
  
  void draw_Cam() {
    for (Entity e : list) if (e.active) e.drawing(); }
  void draw_Screen() {
    custom_screen_draw(); }
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
  int id, age;
  boolean active;
  Entity(Community c) {
    active = false;
    id = c.list.size();
    com = c;
    age = 0;
  }
  Entity activate() {
    if (!active) { active = true; age = 0; init(); }
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
  
  void draw_halo(Canvas canvas, PImage i) {}
}
