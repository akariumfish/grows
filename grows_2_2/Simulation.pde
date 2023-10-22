
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
          .setSize(160, 30)
          .getDrawer()
        .addButton("NEXT TICK", 200, 0)
          .setSize(160, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { next_tick = true; } } )
          .getDrawer()
        .getPanel()
        .addSeparator(10)
      .addDrawer(30)
        
        .addButton("RESET", 80, 0)
          .setSize(100, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { reset(); } } )
          .getDrawer()
        .addButton("RNG", 200, 0)
          .setSize(100, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { SEED.set(int(random(1000000000))); reset(); } } )
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
    plane.build_panel
      .addText("SIMULATION :", 0, 0, 18)
      .addSeparator(8)
      .addDrawer(30)
        .addButton("SIM IN", 30, 0)
          .setSize(150, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { newMacroSimIN(); } } )
          .getDrawer()
        .addButton("SIM OUT", 200, 0)
          .setSize(150, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { newMacroSimOUT(); } } )
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      ;
    for (Community c : list) c.building();
  }
  
  void newMacroSimIN() {
    new MacroCUSTOM(plane)
      .setLabel("SIM IN")
      .setWidth(170)
      .addMCRun()
        .addRunnable(new Runnable() { public void run() { reset(); }})
        .setText("reset")
        .getMacro()
      .addMCRun()
        .addRunnable(new Runnable() { public void run() { SEED.set(int(random(1000000000))); reset(); }})
        .setText("rng")
        .getMacro()
      .addMCRun()
        .addRunnable(new Runnable() { public void run() { next_tick = true; }})
        .setText("tick")
        .getMacro()
      .addMCsBooControl()
        .setValue(pause)
        .setText("pause")
        .getMacro()
      .addMCsFltControl()
        .setValue(tick_by_frame)
        .setText("speed")
        .getMacro()
      ;
  }
  
  void newMacroSimOUT() {
    new MacroCUSTOM(plane)
      .setLabel("SIM OUT")
      .setWidth(150)
      .addMCsBooWatcher()
        .addValue(pause)
        .setText("pause")
        .getMacro()
      .align()
      .addMCsFltWatcher()
        .addValue(tick)
        .setText("   tick")
        .getMacro()
      .addMCsFltWatcher()
        .addValue(tick_by_frame)
        .setText("   speed")
        .getMacro()
      .addMCsIntWatcher()
        .addValue(fr.value)
        .setText("framerate")
        .getMacro()
      .addMCsIntWatcher()
        .addValue(fr.time)
        .setText("time s")
        .getMacro()
      ;
  }
  
  void reset() {
    randomSeed(SEED.get());
    for (Community c : list) c.reset();
    tick.set(0);
    fr.reset();
  }
  
  void frame() {
    if (!pause.get()) {
      tick_pile += tick_by_frame.get();
      
      //auto screenshot before reset
      if (auto_reset.get() && auto_reset_turn.get() == tick.get() + tick_by_frame.get() + tick_by_frame.get() && auto_screenshot.get()) {
          cam.screenshot = true; }
      
      while (tick_pile >= 1) {
        tick();
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
  
  Community(Simulation _c, String n, int max) { comList = _c; name = n; MAX_ENT.set(max); }
  
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
    
    panel = new sPanel(cp5, 30 + id*50, 50 + id*30)
      .addTitle("COMMUNITY CONTROL", 30, 0, 28)
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
    
    plane.build_panel
      .addText("Community: " + name, 0, 0, 18)
      .addSeparator(8)
      .addDrawer(30)
        .addButton("COM IN", 30, 0)
          .setSize(150, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { newMacroComuIN(); } } )
          .getDrawer()
        .addButton("COM OUT", 200, 0)
          .setSize(150, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) { newMacroComuOUT(); } } )
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      ;
    custom_build();
  }
  
  void newMacroComuIN() {
    new MacroCUSTOM(plane)
      .setLabel("COMU IN " + name)
      .setWidth(200)
      .addMCsIntControl()
        .setValue(initial_entity)
        .setText("init")
        .getMacro()
      .addMCsIntControl()
        .setValue(adding_step)
        .setText("step")
        .getMacro()
      .addMCsBooControl()
        .setValue(adding_type)
        .setText("step")
        .getMacro()
      .addMCRun()
        .addRunnable(new Runnable() { public void run() { adding_pile += initial_entity.get(); }})
        .setText("add")
        .getMacro()
      ;
  }
  
  void newMacroComuOUT() {
    new MacroCUSTOM(plane)
      .setLabel("COMU OUT " + name)
      .setWidth(200)
      .addMCsIntWatcher()
        .addValue(activeEntity)
        .setText("  active")
        .getMacro()
      .addMCsIntWatcher()
        .addValue(initial_entity)
        .setText("  init")
        .getMacro()
      .addMCsIntWatcher()
        .addValue(adding_step)
        .setText("  step")
        .getMacro()
      .addMCsBooWatcher()
        .addValue(adding_type)
        .setText("  step")
        .getMacro()
      ;
  }
  
  Community show_menu() { panel.g.show(); show_menu.set(true); return this; }
  Community hide_menu() { panel.g.hide(); show_menu.set(false); return this; }
  Community show_entity() { show_entity.set(true); return this; }
  Community hide_entity() { show_entity.set(false); return this; }
  
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
    for (Entity e : list) if (e.active) e.tick();
    activeEntity.set(active_Entity_Nb());
    custom_tick();
  }
  
  void custom_build() {}
  void custom_frame() {}
  void custom_tick() {}
  void custom_cam_draw_pre_entity() {}
  void custom_cam_draw_post_entity() {}
  void custom_screen_draw() {}
  
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
  
  void draw_halo(Canvas canvas, PImage i) {}
}
