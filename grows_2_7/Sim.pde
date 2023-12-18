
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
 screen width 1200
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
  
  Macro_Sheet sheet;
  
  sInt tick_counter; //conteur de tour depuis le dernier reset ou le debut
  sBoo pause; //permet d'interompre le defilement des tour
  sInt force_next_tick; 
  sFlt tick_by_frame; //nombre de tour a executé par frame
  sInt SEED; //seed pour l'aleatoire
  sBoo auto_reset, auto_reset_rng_seed, auto_reset_screenshot, show_com;
  sInt auto_reset_turn;
  sRun srun_reset, srun_rngr, srun_nxtt;

  float tick_pile = 0; //pile des tick a exec

  Simulation(sInterface _int) {
    inter = _int;
    ref_size = inter.size;
    cam_gui = inter.cam_gui;
    
    sheet = inter.macro_main.addSheet("Simulation");
    sheet.reduc();
    //sheet.setPosition(0, -ref_size*3);
    
    //sbloc = sheet.sheet_data;
    ticking_pile = new Ticking_pile();
    tick_counter = sheet.newLinkedInt(0, "tick_counter", "tick");
    tick_by_frame = sheet.newLinkedFlt(2, "tick by frame", "tck/frm");
    pause = sheet.newLinkedBoo(false, "pause", "pause");
    force_next_tick = sheet.newLinkedInt(0, "force_next_tick", "nxt tick");
    auto_reset = sheet.newLinkedBoo(true, "auto_reset", "auto reset");
    auto_reset_rng_seed = sheet.newLinkedBoo(true, "auto_reset_rng_seed", "auto rng");
    auto_reset_screenshot = sheet.newLinkedBoo(false, "auto_rest_screenshot", "auto shot");
    show_com = sheet.newLinkedBoo(true, "show_com", "show");
    auto_reset_turn = sheet.newLinkedInt(4000, "auto_reset_turn", "auto turn");
    SEED = sheet.newLinkedInt(548651008, "SEED", "SEED");

    inter.addEventFrame(new Runnable() { 
      public void run() { 
        frame();
      }
    }
    );
    inter.addToCamDrawerPile(new Drawable() { 
      public void drawing() { 
        draw_to_cam();
      }
    } 
    );
    inter.addToScreenDrawerPile(new Drawable() { 
      public void drawing() { 
        draw_to_screen();
      }
    } 
    );

    srun_reset = sheet.newLinkedRun("sim reset", "reset", new Runnable() { 
      public void run() { 
        reset();
      }
    } 
    );
    srun_rngr = sheet.newLinkedRun("sim rng reset", "rst rng", new Runnable() { 
      public void run() { 
        resetRng();
      }
    } 
    );
    srun_nxtt = sheet.newLinkedRun("sim next tick", "nxt tck", new Runnable() { 
      public void run() { 
        force_next_tick.add(1);
      }
    } 
    );
    
    inter.macro_main.addTickAskMethod(new Runnable() { public void run() {
      srun_nxtt.run();
    } });
    
    macromain_tickable = new Tickable(ticking_pile) { public void tick(float f) { inter.macro_main.tick(); } };
    
    inter.macro_main.childDragged();
    
    build_ui();
    
  }

  ArrayList<Runnable> eventsReset = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsFrame = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsUnpausedFrame = new ArrayList<Runnable>();
  ArrayList<Runnable> eventsTick = new ArrayList<Runnable>();
  Simulation addEventReset(Runnable r) { 
    eventsReset.add(r); 
    return this;
  }
  Simulation addEventFrame(Runnable r) { 
    eventsFrame.add(r); 
    return this;
  }
  Simulation addEventUnpausedFrame(Runnable r) { 
    eventsUnpausedFrame.add(r); 
    return this;
  }
  Simulation addEventTick(Runnable r) { 
    eventsTick.add(r); 
    return this;
  }

  void resetRng() { 
    SEED.set(int(random(1000000000))); 
    reset();
  }
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
        inter.cam.screenshot = true;
      }

      while (tick_pile >= 1) {
        tick();
        tick_pile--;
      }

      //run_each_unpaused_frame
      runEvents(eventsUnpausedFrame);
    }

    // tick by tick control
    if (pause.get() && force_next_tick.get() > 0) { 
      for (int i = 0; i < force_next_tick.get(); i++) tick(); 
      force_next_tick.set(0);
    }
    if (!pause.get() && force_next_tick.get() > 0) { 
      force_next_tick.set(0);
    }

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

    ticking_pile.tick();

    //tick communitys
    for (Community c : list) c.tick();

    //tick call
    runEvents(eventsTick);

    tick_counter.set(tick_counter.get()+1);
  }

  void draw_to_cam() { 
    if (show_com.get()) {
      for (Community c : list) if (c.show_entity.get()) c.custom_cam_draw_pre_entity();
      for (Community c : list) if (c.show_entity.get()) c.draw_Cam();
      for (Community c : list) if (c.show_entity.get()) c.custom_cam_draw_post_entity();
    }
  }
  void draw_to_screen() { 
    for (Community c : list) if (c.show_entity.get()) c.draw_Screen();
  }
  
  
  nFrontPanel sim_front;
  nDrawer val_drawer;
  
  void build_ui() {
    inter.toolpanel.getShelf(0)
      .addDrawer(10, 0.75)
      .addModel("Label-S4", "-  GROWERS  -").setFont(int(ref_size)).getShelf()
      .addSeparator(0.25)
      .addDrawer(10, 1)
      .addCtrlModel("Button-S3-P1", "RESET")
      .setRunnable(new Runnable() { 
      public void run() { 
        reset();
      }
    }
    ).getDrawer()
      .addCtrlModel("Button-S3-P2", "RESET RNG")
      .setRunnable(new Runnable() { 
      public void run() { 
        resetRng();
      }
    }
    ).getShelf()
      .addDrawer(10, 1)
      .addCtrlModel("Button-S3-P1", "Quick Save")
      .setRunnable(new Runnable() { 
      public void run() { 
        //inter.file_save();
      }
    }
    ).getDrawer()
      .addCtrlModel("Button-S3-P2", "Quick Load")
      .setRunnable(new Runnable() { 
      public void run() { 
        //inter.file_load();
      }
    }
    ).getDrawer()
      .getShelfPanel()
      .addShelf()
      .addDrawer(10, 1)
      .addCtrlModel("Button-S2-P1", "tick").setRunnable(new Runnable() { 
      public void run() { 
        force_next_tick.set(1);
      }
    }
    ).getDrawer()
      .addLinkedModel("Button-S2-P2", "PAUSE").setLinkedValue(pause).getDrawer()
      .addCtrlModel("Button-S2-P3", "frame").setRunnable(new Runnable() { 
      public void run() { 
        force_next_tick.set(int(tick_by_frame.get()));
      }
    }
    ).getShelf()
      .addDrawer(10, 1)
      .addCtrlModel("Button-S1-P2", "<<").setLinkedValue(tick_by_frame).setFactor(0.5).getDrawer()
      .addCtrlModel("Button-S1-P3", "<").setLinkedValue(tick_by_frame).setFactor(0.8).getDrawer()
      .addWatcherModel("Label_Back-S2-P2", "--").setLinkedValue(tick_by_frame).getDrawer()
      .addCtrlModel("Button-S1-P7", ">").setLinkedValue(tick_by_frame).setFactor(1.25).getDrawer()
      .addCtrlModel("Button-S1-P8", ">>").setLinkedValue(tick_by_frame).setFactor(2).getShelf()
      .addDrawer(10, 1)
      .addWatcherModel("Label_Back-S3-P1")
      //.setLinkedValue(inter.test)
      .getDrawer()
      .addWatcherModel("Label_Back-S3-P2").setLinkedValue(tick_counter).getShelf()
      .addDrawer(10, 1)
      .addWatcherModel("Label_Back-S3-P1")
      .setLinkedValue(inter.framerate.median_framerate).getDrawer()
      .addLinkedModel("Button-S1-P9", "S")
      .setLinkedValue(show_com)
      .getShelfPanel()
      ;
    
    selector_entry = new ArrayList<String>(); // mmain().data.getCountOfType("flt")
    selector_value = new ArrayList<Community>(); // mmain().data.getCountOfType("flt")
    
    inter.main_menu.addEntry("Simulation", new Runnable() { 
      public void run() { 
        build_sim_frontpanel(inter.screen_gui);
      }
    } 
    );
    inter.screen_gui.addEventSetup(new Runnable() { 
      public void run() { 
        for (Blueprint c : com_blueprint) c.simPanelBuild(sim_front);

        if (list.size() > 0) {
          update_com_selector_list();
        }
      }
    } 
    );  
  }
  
  void build_sim_frontpanel(nGUI screen_gui) {
    if (sim_front == null) {
      sim_front = new nFrontPanel(screen_gui, inter.taskpanel, "Simulation");
      nFrontTab tab = sim_front.addTab("Base");

      tab.getShelf()
        .addDrawer(10, 0.6)
        .addModel("Label-S4", "- Simulation Control -").setFont(int(ref_size/1.4)).getShelf()
        .addSeparator(0.125)
        .addDrawerWatch(tick_counter, 10, 1)
        .addSeparator(0.125)
        .addDrawerLargeFieldCtrl(SEED, 10, 1)
        .addSeparator(0.125)
        .addDrawerFactValue(tick_by_frame, 2, 10, 1)
        .addSeparator(0.125)
        .addDrawerIncrValue(auto_reset_turn, 100, 10, 1)
        .addSeparator(0.125)
        .addDrawerTripleButton(auto_reset, auto_reset_rng_seed, auto_reset_screenshot, 10, 1)
        .addSeparator(0.125)
        .addDrawerTripleButton(srun_reset, srun_rngr, srun_nxtt, 10, 1)
        .addSeparator(0.125)
        .addDrawerTripleButton(pause, show_com, inter.cam.grid, 10, 1)
        .addSeparator(0.125)
        .addDrawer(10, 0.75)
        .addModel("Label-SS4", "- New Community -").setFont(int(ref_size/1.5)).getShelf()
        
        ;
      
      val_drawer = tab.getShelf(0)
        .addSeparator(0.25).addDrawer(1);
        
      /// >>>> fait ca au start apres le build des print    -----------------------------------------------
        int count = 0;
        for (Blueprint r : com_blueprint) {
          nWidget tsw = val_drawer.addModel("Button-S2-P"+(count+1), com_blueprint.get(count).name)
            .setTrigger()
            .addEventTrigger(new Runnable(r) { 
            public void run() {
              ((Blueprint)builder).build(""); 
              update_com_selector_list(); } } );
          count++;
        }
      val_drawer.getShelf().addSeparator(0.125)
        .addDrawer(10, 0.75)
        .addModel("Label-SS4", "- Active Community -").setFont(int(ref_size/1.5)).getShelf()
        //.addSeparator(0.25)
        
        ;
        
      selector_list = tab.getShelf(0)
        .addSeparator(0.25)
        .addList(5, 10, 1);
      selector_list.addEventChange_Builder(new Runnable() { public void run() {} } );
          
          
          
          //  int ind = ((nList)builder).last_choice_index;
          //  if (ind < selector_value.size()) {
          //    selected_value = selector_value.get(ind);
          //    selected_entry = selected_value.name;
          //    selected_value.build_com_frontpanel(inter.screen_gui, inter.size);
              
              
      
      selector_list.getShelf()
        .addSeparator(0.0625)
        ;
        
      //selector_list.getShelf().addSeparator(0.125)
      //  .addDrawer(10, 0.75)
      //  .addModel("Label-SS4", "- Selected : -").setFont(int(ref_size/1.5)).getShelf()
      //  .addSeparator(0.0625)
      //  .addDrawer(0.75)
      //  //.addWatcherModel("Field-SS4").setLinkedValue(selected_entry)
      //  .getShelf()
      //  .addSeparator(0.0625)
      //;
      
      update_com_selector_list();

      sim_front.setNonClosable();
    } else sim_front.popUp();
  }

  void update_com_selector_list() {
    selector_entry.clear();
    selector_value.clear();
    for (Community v : list) { 
      selector_entry.add(v.name); 
      selector_value.add(v);
    }
    if (selector_list != null) selector_list.setEntrys(selector_entry);
  }

  ArrayList<String> selector_entry;
  ArrayList<Community> selector_value;
  Community selected_value;
  String selected_entry;
  nList selector_list;

  sInterface inter;
  sValueBloc sbloc;
  nGUI cam_gui;
  float ref_size;
  Ticking_pile ticking_pile;
  Tickable macromain_tickable;

  ArrayList<Community> list = new ArrayList<Community>();
  ArrayList<Blueprint> com_blueprint = new ArrayList<Blueprint>();

  //ArrayList<Runnable> eventNewCom = new ArrayList<Runnable>();
  //void addEventNewCom(Runnable r) { 
  //  eventNewCom.add(r);
  //}
  
}


static abstract class Blueprint {
  static int count = 0;
  static ArrayList<Blueprint> list = new ArrayList<Blueprint>();

  Simulation sim;
  String name;
  
  Blueprint(Simulation s, String nam) { name = nam; sim = s;
    list.add(this); 
    count++;
    sim.com_blueprint.add(this);
  
  }
  
  int getCount() { return count; }
  void simPanelBuild(nFrontPanel sim_front) {
    simPanelCustom(sim_front); }
  
  abstract Community build(String n);
  void simPanelCustom(nFrontPanel sim_front) {}
}


abstract class Community {
  
  nFrontPanel com_front;

  abstract void comPanelBuild(nFrontPanel sim_front);

  void build_com_frontpanel(nGUI screen_gui, float ref_size) {
    if (com_front == null) {
      com_front = new nFrontPanel(screen_gui, sim.inter.taskpanel, "Community "+name);
      nFrontTab tab = com_front.addTab("community");
      tab.getShelf()
        .addDrawer(10, 0.75)
        .addModel("Label-S4", "-"+name+" Community Control-").setFont(int(ref_size/1.4)).getShelf()
        .addSeparator(0.125)
        .addDrawerWatch(active_entity, 10, 1)
        .addSeparator(0.125)
        .addDrawerIncrValue(max_entity, 100, 10, 1)
        .addSeparator(0.125)
        .addDrawerIncrValue(adding_entity_nb, 10, 10, 1)
        .addSeparator(0.125)
        .addDrawerIncrValue(adding_step, 10, 10, 1)
        .addSeparator(0.125)
        .addDrawerTripleButton(show_entity, srun_add, adding_cursor.show, 10, 1)
        .addSeparator(0.125)
        ;
      //build_Preset_Tab(com_front, sbloc);
      comPanelBuild(com_front);
    } else com_front.popUp();
  }

  Simulation sim;
  sValueBloc sbloc;
  Macro_Sheet sheet;
  String name = "";
  String type;

  ArrayList<Entity> list = new ArrayList<Entity>(); //contien les objet

  sInt max_entity; //longueur max de l'array d'objet
  sInt active_entity, adding_entity_nb, adding_step; // add one new object each adding_step turn
  int adding_pile = 0;
  int adding_counter = 0;

  sBoo show_entity;
  sRun srun_add;
  sStr type_value;

  nCursor adding_cursor;

  Community(Simulation _c, String n, String ty, int max) { 
    sim = _c; 
    name = n;
    sim.list.add(this);
    type = ty;

    sheet = sim.inter.macro_main.addSheet("Community" + n);
    sheet.reduc();
    //sheet.setPosition(0, -sim.ref_size*5);
    sbloc = sheet.sheet_data;
    max_entity = sheet.newLinkedInt(500, "max_entity", "max_pop");
    type_value = sheet.newLinkedStr(ty, "type", "type");
    active_entity = sheet.newLinkedInt(0, "active_entity ", "active_pop");
    adding_entity_nb = sheet.newLinkedInt(10, "adding_entity_nb ", "add nb");
    adding_step = sheet.newLinkedInt(0, "adding_step ", "add stp");
    show_entity = sheet.newLinkedBoo(true, "show_entity ", "show");

    //sim.inter.main_menu.addEntry(n, new Runnable() { public void run() { ; } });
    adding_cursor = new nCursor(sim.cam_gui, sheet.sheet_data, sim.ref_size / 2, "addCursor "+n);
    sheet.addLinkedValue(adding_cursor.show);
    sheet.addLinkedValue(adding_cursor.sval);
    max_entity.set(max); 

    srun_add = sheet.newLinkedRun("add_entity", "add_pop", new Runnable() { 
      public void run() { 
        adding_pile += adding_entity_nb.get();
      }
    }
    );

    reset();
  }

  Community show_entity() { 
    show_entity.set(true); 
    return this;
  }
  Community hide_entity() { 
    show_entity.set(false); 
    return this;
  }

  void custom_reset() {
  }
  void custom_frame() {
  }
  abstract void custom_pre_tick();
  abstract void custom_post_tick();
  abstract void custom_cam_draw_pre_entity();
  abstract void custom_cam_draw_post_entity();
  void custom_screen_draw() {
  }

  void init_array() {
    list.clear();
    for (int i = 0; i < max_entity.get(); i++)
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

  void draw_Cam() { 
    for (Entity e : list) if (e.active) e.draw();
  }
  void draw_Screen() { 
    custom_screen_draw();
  }

  void destroy_All() { 
    for (Entity e : list) e.destroy();
  }

  int active_Entity_Nb() {
    int n = 0;
    for (Entity e : list) if (e.active) n++;
    return n;
  }

  abstract Entity build();
  abstract Entity addEntity();
}






abstract class Entity { 
  Community com;
  int age = 0, id;
  boolean active = false;
  Entity(Community c) { 
    com = c; 
    id = com.list.size();
  }
  Entity activate() {
    if (!active) { 
      active = true; 
      age = 0; 
      init();
    }
    return this;
  }
  Entity destroy() {
    if (active) { 
      active = false; 
      clear();
    }
    return this;
  }
  abstract Entity tick();     //exec by community 
  abstract Entity frame();    //exec by community 
  abstract Entity draw();    //exec by community 
  abstract Entity init();     //exec by activate and community.reset
  abstract Entity clear();    //exec by destroy
}
