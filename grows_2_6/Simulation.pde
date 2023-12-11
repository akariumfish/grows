
/*

  Simulation(Input, Data, Interface)
    Build with interface
      toolPanel down left to down center with main function
        right
          next tick,  pause,  next frame
          tick/frame            5 widget
          time counter,     tick counter
          framerate,            tickrate
        
        down left
          Hide all
        
        left
                open menus      <align to panel top
                  title
            Quick save, load
            restart,    RNG
        
        time control (tick by frame, pause, trigger tick by tick or frame by frame)
        restart control and RNG
        Quick save / load
        button to hide all guis (toolpanel reducted)
        Openning main dropdown menu to open main panels
          file selection panel
          communitys panel
            open save / load parameters panel
            basic info n param
            completed by each community type
          shortcut panel
            can link key to preselected button
      taskBar on down right side
      SelectZone working in camera
      Info
    TickPile
    one Drawer for all communitys in camera drawerpile
      simpler before more coding
    community
      has an adding point as an svalue and grabbable
      grower as also an adding direction
      floc an adding radius
    Entity
      position, direction, size
      custom parameters
      list of geometrical shapes and colors
        shapes contain energy???                            <<<<<< THE GAME MECHANIC MAKE HER ENTRY
        to excenge energy throug macro link output need a received method called by receiving input to
        confirm transfer 
      width 1200
      draw : invisible, particle 1px, pebble 5px, small 25px, med 100px, 
             big 400px, fullscreen 1100px, zoom in 3000px, micro 10 000px, too big 100 000px
    frame()
      drive ticking
    macro_main
      each community have her sheet inside whom community param and runnable can be acsessed
      maybe for each community her is an independent macro space who can acsess an entity
      property and who can be applyed to each entity of this commu
      there can be plane who take entity from different commu to make them interact
*/

class Simulation {
  void build_ui(float ref_size) {
    
    new nBuilder(inter.cam_gui, ref_size)
      .addModel("Button-S1")
        .setPosition(-ref_size/2, -ref_size/2)
        .setTrigger()
        .setOutlineConstant(true);
    inter.toolpanel.addShelf()
      .addDrawer()
        .getShelfPanel()
    .addShelf()
      .addDrawer()
        .getShelf()
      .addDrawer()
      //  .getShelf()
        ;
    //inter.toolpanel
    //  .getDrawer(0, 1)
    //    .addWatcherModel("Label-S3")
    //      .setLinkedValue(tick_counter).getShelfPanel()
    //  .getDrawer(0, 0)
    //    .addLinkedModel("Button-S3", "Pause")
    //      .setLinkedValue(pause).getShelfPanel()
    //  .getDrawer(1, 0)
    //    .addCtrlModel("Button-S1", "P")
    //      .setLinkedValue(pause).getShelfPanel()
    //  .getDrawer(0, 2)
    //    .addLinkedModel("Field-S2-P1")
    //      .setLinkedValue(tick_by_frame).getDrawer()
    //    .addLinkedModel("Field-S2-P2")
    //      .setLinkedValue(auto_reset_turn).getDrawer()
    //    .addLinkedModel("Field-S2-P3")
    //      .setLinkedValue(tick_by_frame).getDrawer()
    //  ;
  }
  
  sInterface inter;
  sValueBloc sbloc;
  
  Ticking_pile ticking_pile;
  
  ArrayList<Community> list = new ArrayList<Community>();
  
  sInt tick_counter; //conteur de tour depuis le dernier reset ou le debut
  sBoo pause; //permet d'interompre le defilement des tour
  sBoo force_next_tick; 
  sFlt tick_by_frame; //nombre de tour a executé par frame
  sInt SEED; //seed pour l'aleatoire
  sBoo auto_reset, auto_reset_rng_seed, auto_reset_screenshot;
  sInt auto_reset_turn;
  
  float tick_pile = 0; //pile des tick a exec
  
  Simulation(sInterface _int) {
    inter = _int;
    sbloc = new sValueBloc(inter.sbloc, "Simulation");
    
    tick_counter = new sInt(sbloc, 0, "tick_counter");
    tick_by_frame = new sFlt(sbloc, 16, "tick by frame");
    pause = new sBoo(sbloc, false, "pause");
    force_next_tick = new sBoo(sbloc, false, "force_next_tick");
    auto_reset = new sBoo(sbloc, true, "auto_reset");
    auto_reset_rng_seed = new sBoo(sbloc, true, "auto_reset_rng_seed");
    auto_reset_screenshot = new sBoo(sbloc, false, "auto_rest_screenshot");
    auto_reset_turn = new sInt(sbloc, 4000, "auto_reset_turn");
    SEED = new sInt(sbloc, 548651008, "SEED");
    
    inter.addEventFrame(new Runnable() { public void run() { frame(); }});
    inter.addCamDrawer(new Drawable() { public void drawing() { draw_to_cam(); } } );
    inter.addScreenDrawer(new Drawable() { public void drawing() { draw_to_screen(); } } );
    
    inter.data.addReferedRunnable("sim reset", new Runnable() { public void run() { 
      reset(); } } );
    inter.data.addReferedRunnable("sim rng reset", new Runnable() { public void run() { 
      SEED.set(int(random(1000000000))); reset(); } } );
    inter.data.addReferedRunnable("sim next tick", new Runnable() { public void run() { 
      force_next_tick.set(true); } } );
    
    build_ui(inter.size);
  }
  
  ArrayList<Runnable> eventsReset = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsFrame = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsUnpausedFrame = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsTick = new ArrayList<Runnable>();
  Simulation addEventReset(Runnable r) { eventsReset.add(r); return this; }
  Simulation addEventFrame(Runnable r) { eventsFrame.add(r); return this; }
  Simulation addEventUnpausedFrame(Runnable r) { eventsUnpausedFrame.add(r); return this; }
  Simulation addEventTick(Runnable r) { eventsTick.add(r); return this; }
  
  
  void reset() {
    randomSeed(SEED.get());
    tick_counter.set(0);
    inter.framerate.reset();
    for (Community c : list) c.reset();
    runEvents(eventsReset);
  }
  
  void frame() {
    if (!pause.get()) {
      tick_pile += tick_by_frame.get();
      
      //auto screenshot before reset
      if (auto_reset.get() && auto_reset_screenshot.get() &&
          auto_reset_turn.get() == tick_counter.get() + tick_by_frame.get() + tick_by_frame.get()) {
          inter.cam.screenshot = true; }
      
      while (tick_pile >= 1) {
        tick();
        tick_pile--;
      }
      
      //run_each_unpaused_frame
      runEvents(eventsUnpausedFrame);
    }
    
    // tick by tick control
    if (pause.get() && force_next_tick.get()) { force_next_tick.set(false); tick(); }
    if (!pause.get() && force_next_tick.get()) { force_next_tick.set(false); }
    
    //run custom frame methods
    for (Community c : list) c.frame();
    runEvents(eventsFrame);
  }
  
  void tick() {
    
    //auto reset
    if (auto_reset.get() && auto_reset_turn.get() <= tick_counter.get()) {
      if (auto_reset_rng_seed.get()) {
        SEED.set(int(random(1000000000)));
      }
      reset();
    }
    
    //tick communitys
    for (Community c : list) c.tick();
    
    //tick call
    runEvents(eventsTick);
    
    tick_counter.set(tick_counter.get()+1);
  }
  
  void draw_to_cam() {
    for (Community c : list) if (c.show_entity.get()) c.custom_cam_draw_pre_entity();
    for (Community c : list) if (c.show_entity.get()) c.draw_Cam();
    for (Community c : list) if (c.show_entity.get()) c.custom_cam_draw_post_entity();
  }
  void draw_to_screen() { for (Community c : list) if (c.show_entity.get()) c.draw_Screen(); }
}


abstract class Community {
  Simulation sim;
  sValueBloc sbloc;
  String name = "";
  
  ArrayList<Entity> list = new ArrayList<Entity>(); //contien les objet
  
  sInt max_entity; //longueur max de l'array d'objet
  sInt active_entity, adding_entity_nb, adding_step; // add one new object each adding_step turn
  int adding_pile = 0;
  int adding_counter = 0;
  
  sBoo show_entity;
  
  //sBoo show_menu = new sBoo(simval, true);
  
  Community(Simulation _c, String n, int max) { 
    sim = _c; name = n;
    sim.list.add(this);
    
    sbloc = new sValueBloc(sim.inter.sbloc, "Community " + n);
    max_entity = new sInt(sbloc, 500, "max_entity " + n);
    active_entity = new sInt(sbloc, 0, "active_entity " + n);
    adding_entity_nb = new sInt(sbloc, 10, "adding_entity_nb " + n);
    adding_step = new sInt(sbloc, 0, "adding_step " + n);
    show_entity = new sBoo(sbloc, true, "show_entity " + n);
    
    max_entity.set(max); 
    
    sim.inter.data.addReferedRunnable(n+" add", new Runnable() { public void run() { 
      adding_pile += adding_entity_nb.get();
    }});
    
    reset();
    
  }
  
  Community show_entity() { show_entity.set(true); return this; }
  Community hide_entity() { show_entity.set(false); return this; }
  
  void custom_reset() {}
  void custom_frame() {}
  abstract void custom_pre_tick();
  abstract void custom_post_tick();
  abstract void custom_cam_draw_pre_entity();
  abstract void custom_cam_draw_post_entity();
  void custom_screen_draw() {}
  
  void init_array() {
    list.clear();
    for (int i = 0; i < max_entity.get() ; i++)
      list.add(build());
  }
  
  void reset() { //deactivate all then create starting situation from parameters
    this.destroy_All();
    if (max_entity.get() != list.size()) init_array();
    adding_pile += adding_entity_nb.get();
    custom_reset();
  }
  
  void frame() {
    custom_frame();
    for (Entity e : list) if (e.active) e.frame();
  }
  
  void tick() {
    if (adding_counter > 0) adding_counter--;
    while (adding_counter == 0 && adding_pile > 0) {
      adding_counter += adding_step.get();
      adding_pile--;
      addEntity();
    }
    custom_pre_tick();
    for (Entity e : list) if (e.active) e.tick();
    for (Entity e : list) if (e.active) e.age++;
    active_entity.set(active_Entity_Nb());
    custom_post_tick();
  }
  
  void draw_Cam() { for (Entity e : list) if (e.active) e.draw(); }
  void draw_Screen() { custom_screen_draw(); }
  
  void destroy_All() { for (Entity e : list) e.destroy(); }
  
  int active_Entity_Nb() {
    int n = 0;
    for (Entity e : list) if (e.active) n++;
    return n; }
  
  abstract Entity build();
  abstract Entity addEntity();
}



abstract class Entity { 
  Community com;
  int age = 0;
  boolean active = false;
  Entity(Community c) { com = c; }
  Entity activate() {
    if (!active) { active = true; age = 0; init(); }
    return this;
  }
  Entity destroy() {
    if (active) { active = false; clear(); }
    return this;
  }
  abstract Entity tick();     //exec by community 
  abstract Entity frame();    //exec by community 
  abstract Entity draw();    //exec by community 
  abstract Entity init();     //exec by activate and community.reset
  abstract Entity clear();    //exec by destroy
}
