class RandomTryParam extends Callable {
  //constructeur avec param values
  sFlt DIFFICULTY = new sFlt(simval, 4);
  sBoo ON = new sBoo(simval, true);
  sFlt test_by_tick = new sFlt(simval, 0);
  int count = 0;
  RandomTryParam(float d, boolean b) { DIFFICULTY.set(d); ON.set(b); addChannel(frameend_chan); }
  boolean test() { if(ON.get()) count++; test_by_tick.set(count / sim.tick_by_frame.get()); return ON.get() && crandom(DIFFICULTY.get()) > 0.5; }
  void answer(Channel chan, float v) { count = 0; test_by_tick.set(0); }
}

class GrowerComu extends Community {
  
  //constructeur avec param values
  sFlt DEVIATION = new sFlt(simval, 8); //drifting (rotation posible en portion de pi (PI/drift))
  sFlt L_MIN = new sFlt(simval, 20); //longeur minimum de chaque section
  sFlt L_MAX = new sFlt(simval, 350); //longeur max de chaque section MODIFIABLE PAR MENU MOVE minimum 1 , limité dans l'update de sont bp
  sFlt L_DIFFICULTY = new sFlt(simval, 180);
  sFlt OLD_AGE = new sFlt(simval, 666);
  //int TEEN_AGE = OLD_AGE / 20;
  RandomTryParam growP = new RandomTryParam(0.5, true);
  RandomTryParam sproutP = new RandomTryParam(2080, true);
  RandomTryParam stopP = new RandomTryParam(1.25, true);
  RandomTryParam leafP = new RandomTryParam(2080, true);
  RandomTryParam dieP = new RandomTryParam(3.6, true);
  float MAX_LINE_WIDTH = 1.5; //epaisseur max des ligne, diminuer par l'age, un peut, se vois pas
  float MIN_LINE_WIDTH = 0.2; //epaisseur min des ligne
  
  sBoo create_floc = new sBoo(simval, true);
  
  sLabel grower_nb_label;
  
  sInt activeGrower = new sInt(simval, 0);
  
  sGraph graph = new sGraph();
  
  GrowerComu(Simulation _c) { super(_c, "Grower", 500); init();
    
    graph.init();
    
  }
  void custom_cam_draw_pre_entity() {}
  void custom_cam_draw_post_entity() {}
  void custom_pre_tick() {}
  void custom_post_tick() {}
  void custom_build() {
    //creation du menu
    panel.addText("Shape", 150, 0, 22)
      .addSeparator(8)
      .addValueController("DEV ", sMode.FACTOR, 2, 1.2, DEVIATION)
      .addSeparator(10)
      .addValueController("L_MIN ", sMode.FACTOR, 2, 1.2, L_MIN)
      .addSeparator(10)
      .addValueController("L_MAX ", sMode.FACTOR, 2, 1.2, L_MAX)
      .addSeparator(10)
      .addValueController("L_DIFF ", sMode.FACTOR, 2, 1.2, L_DIFFICULTY)
      .addLine(22)
      .addText("Behavior", 140, 0, 22)
      .addSeparator(8)
      .addRngTryCtrl("GROW ", growP)
      .addSeparator(5)
      .addRngTryCtrl("SPROUT ", sproutP)
      .addSeparator(5)
      .addRngTryCtrl("STOP ", stopP)
      .addSeparator(5)
      .addRngTryCtrl("LEAF ", leafP)
      .addSeparator(5)
      .addRngTryCtrl("DIE ", dieP)
      .addSeparator(5)
      .addValueController("age ", sMode.FACTOR, 2, 1.2, OLD_AGE)
      .addSeparator(10)
      .addDrawer(20)
        .addSwitch("CREATE FLOC", 90, 0)
          .setValue(create_floc)
          .setSize(200, 20)
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      .addDrawer(30)
        .addText("test by tick: ", 140, 0)
          .getDrawer()
        .getPanel()
      .addDrawer(60)
        .addText("grow try: ", 30, 0)
          .setValue(growP.test_by_tick)
          .getDrawer()
        .addText("sprout try: ", 200, 0)
          .setValue(sproutP.test_by_tick)
          .getDrawer()
        .addText("stop try: ", 30, 30)
          .setValue(stopP.test_by_tick)
          .getDrawer()
        .addText("leaf try: ", 200, 30)
          .setValue(leafP.test_by_tick)
          .getDrawer()
        .getPanel()
      ;
    grower_nb_label = new sLabel(cp5) { 
        public void answer(Channel channel, float value) {
          grower_nb_label.setText("grower: ", str(grower_Nb())); } }
      .setText("grower: ")
      .setPos(200, 66)
      .setPanel(panel)
      .setFont(20)
      ;
    grower_nb_label.addChannel(frame_chan);
    new sSwitch(cp5, "G", 320, 62)
      .setValue(graph.SHOW_GRAPH)
      .setPanel(panel)
      .setSize(30, 30)
      ;
    
    //creation de macro custom
    //plane.build_panel
    //  .addDrawer(30)
    //    .addButton("SHAPE", 260, 0)
    //      .setSize(120, 30)
    //      .addListener(new ControlListener() {
    //        public void controlEvent(final ControlEvent ev) { newMacroGrowerINShape(); } } )
    //      .getDrawer()
    //    .addButton("BEHAVIOR", 130, 0)
    //      .setSize(120, 30)
    //      .addListener(new ControlListener() {
    //        public void controlEvent(final ControlEvent ev) { newMacroGrowerINMove(); } } )
    //      .getDrawer()
    //    .addButton("LIFE", 0, 0)
    //      .setSize(120, 30)
    //      .addListener(new ControlListener() {
    //        public void controlEvent(final ControlEvent ev) { newMacroGrowerOUT(); } } )
    //      .getDrawer()
    //    .getPanel()
    //  .addSeparator(10)
    //  ;
  }
  
  void newMacroGrowerINShape() {
    //new MacroCUSTOM(plane)
    //  .setLabel("GROWER Shape")
    //  .setWidth(150)
    //  .addMCsFltControl()
    //    .setValue(DEVIATION)
    //    .setText("dev")
    //    .getMacro()
    //  .addMCsFltControl()
    //    .setValue(L_MIN)
    //    .setText("l min")
    //    .getMacro()
    //  .addMCsFltControl()
    //    .setValue(L_MAX)
    //    .setText("l max")
    //    .getMacro()
    //  .addMCsFltControl()
    //    .setValue(L_DIFFICULTY)
    //    .setText("dif")
    //    .getMacro()
    //  ;
  }
  
  void newMacroGrowerINMove() {
    //MacroCUSTOM m = new MacroCUSTOM(plane)
    //  .setLabel("GROWER Move")
    //  .setWidth(150)
    //  ;
    //addRngTry(m, growP, "grow");
    //addRngTry(m, sproutP, "sprout");
    //addRngTry(m, leafP, "leaf");
    //addRngTry(m, stopP, "stop");
    //addRngTry(m, dieP, "die");
  }
  
  //void addRngTry(MacroCUSTOM m, RandomTryParam r, String s) {
  //  m.addMCsBooControl()
  //      .setValue(r.ON)
  //      .setText(s)
  //      .getMacro()
  //    .addMCsFltControl()
  //      .setValue(r.DIFFICULTY)
  //      .setText("")
  //      .getMacro()
  //    ;
  //}
  
  void newMacroGrowerOUT() {
    //new MacroCUSTOM(plane)
    //  .setLabel("GROWER LIFE")
    //  .setWidth(280)
    //  .addMCsIntWatcher()
    //    .addValue(activeGrower)
    //    .setText("   growing")
    //    .getMacro()
    //  .addMCsBooControl()
    //    .setValue(create_floc)
    //    .setText("create floc")
    //    .getMacro()
    //  ;
  }
  
  Grower build() { return new Grower(this); }
  Grower initialEntity() {
    Grower ng = newEntity();
    if (ng != null) ng.define(new PVector(0, 0), new PVector(1, 0).rotate(random(2*PI)));
    return ng;
  }
  Grower newEntity() {
    Grower ng = null;
    for (Entity e : list) 
      if (!e.active && ng == null) { ng = (Grower)e; e.activate(); }
    return ng;
  }
  void custom_frame() {
    graph.update(activeEntity.get(), activeGrower.get());
  }
  void custom_tick() {
    activeGrower.set(grower_Nb());
  }
  void custom_screen_draw() {
    graph.draw();
  }
  int grower_Nb() {
    int n = 0;
    for (Entity e : list) if (e.active && !((Grower)e).end && ((Grower)e).sprouts == 0) n++;
    return n;
  }
}

class Grower extends Entity {
  
  PVector pos = new PVector();
  PVector grows = new PVector();
  PVector dir = new PVector();
  
  float halo_size = 10;
  float halo_density = 0.2;
  
  // condition de croissance
  boolean end = false;
  int sprouts = 0;
  float age = 0.0;
  float start = 0.0;

  Grower(GrowerComu c) { super(c); }
  
  Grower init() {
    end = false;
    sprouts = 0;
    age = 0;
    start = 0.0;
    return this;
  }
  Grower define(PVector _p, PVector _d) {
    pos = _p;
    grows = new PVector(com().L_MIN.get() + crandom(com().L_DIFFICULTY.get())*(com().L_MAX.get() - com().L_MIN.get()), 0);
    grows.rotate(_d.heading());
    grows.rotate(random(PI / com().DEVIATION.get()) - ((PI / com().DEVIATION.get()) / 2));
    dir = new PVector();
    dir = grows;
    grows = PVector.add(pos, grows);
    return this;
  }
  Grower tick() {
    age++;
    if (age < com().OLD_AGE.get()/20) {
      start = (float)age / (float)com().OLD_AGE.get()/20;
    } else start = 1;
    
    //grow
    if (start == 1 && !end && sprouts == 0 && com().growP.test()) {
      Grower n = com().newEntity();
      if (n != null) {
        n.define(grows, dir);
        sprouts++;
      }
    }
    
    // sprout
    if (start == 1 && !end && com().sproutP.test()) {
      Grower n = com().newEntity();
      if (n != null) {
        PVector _p = new PVector(0, 0);
        PVector _d = new PVector(0, 0);
        _d.add(grows).sub(pos);
        _d.setMag(random(1.0) * _d.mag());
        _p.add(pos).add(_d);
        n.define(_p, _d);
        sprouts++;
      }
      //sprouts = (int[]) expand(sprouts, sprouts.length + 1);
      //sprouts[sprouts.length - 1] = temp_b.id;
      //temp_b.this_sprout_index = sprouts.length - 1;
      //sprouts_nb++;
    }
    
    // leaf
    if (start == 1 && !end && com().leafP.test()) {
      PVector _p = new PVector(0, 0);
      PVector _d = new PVector(0, 0);
      _d.add(grows).sub(pos);
      _d.setMag(random(1.0) * _d.mag());
      _p.add(pos).add(_d);
      Grower n = com().newEntity();
      if (n != null) {
        n.define(_p, _d);
        n.end = true;
        sprouts++;
      }
    }
    
    // stop growing
    if (start == 1 && !end && sprouts == 0 && com().stopP.test()) {
      if (com().create_floc.get()) {
        Floc f = fcom.newEntity();
        if (f != null) {
          f.pos.x = pos.x;
          f.pos.y = pos.y;
        }
      }
      end = true;
    }
    
    // die
    float rng = crandom(com().dieP.DIFFICULTY.get());
    if (com().dieP.ON.get() && start == 1 && !(!end && sprouts == 0) &&
         (rng > ( (float)com().OLD_AGE.get() / (float)age ) //||
          //rng / DIE_DIFFICULTY_DIVIDER > ((float)MAX_LIST_SIZE - (float)baseNb()) / (float)MAX_LIST_SIZE
       )) {
      this.destroy();
    }
    return this;
  }
  Grower drawing() {
    // aging color
    int ca = 255;
    if (age > com().OLD_AGE.get() / 2) ca = (int)constrain(255 + int(com().OLD_AGE.get()/2) - int(age/1.2), 90, 255);
    //if (!end && sprouts == 0) { stroke(255, 0, 0); strokeWeight(param.MAX_LINE_WIDTH+1 / cam_scale); } //BIG red head
    if (!end && sprouts == 0) { stroke(255); strokeWeight((com().MAX_LINE_WIDTH+1) / cam.cam_scale.get()); }
    else if (end) { stroke(0, ca, 0); strokeWeight((com().MAX_LINE_WIDTH+1) / cam.cam_scale.get()); }
    else { stroke(ca, ca, ca); strokeWeight(((float)com().MIN_LINE_WIDTH + ((float)com().MAX_LINE_WIDTH * (float)ca / 255.0)) / cam.cam_scale.get()); }              
    
    PVector e = new PVector(dir.x, dir.y);
    if (start < 1) e = e.setMag(e.mag() * start);
    //e = e.add(pos);
    //line(pos.x,pos.y,e.x,e.y);
    pushMatrix();
    translate(pos.x, pos.y);
    if (end) {
      PVector e2 = new PVector(e.x, e.y);
      e.div(2);
      e.rotate(-PI/16);
      line(0, 0,e.x,e.y);
      line(e2.x,e2.y,e.x,e.y);
      e.rotate(PI/8);
      line(0, 0,e.x,e.y);
      line(e2.x,e2.y,e.x,e.y);
    } else line(0, 0,e.x,e.y);
    popMatrix();
    
    //line(pos.x,pos.y,grows.x,grows.y);
    
    //DEBUG
    //fill(255); ellipseMode(CENTER);
    //ellipse(pos.x, pos.y, 2, 2);
    //strokeWeight(MAX_LINE_WIDTH+1 / cam_scale);
    //point(grows.x,grows.y);
    return this;
  }
  Grower clear() { return this; }
  GrowerComu com() { return ((GrowerComu)com); }
}
