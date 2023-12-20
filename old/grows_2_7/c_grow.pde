





class GrowerPrint extends Blueprint {
  GrowerPrint(Simulation s) { super(s, "Grower"); }
  GrowerComu build(String n) { return new GrowerComu(sim, n); }
}



class GrowerComu extends Community {

  sFlt DEVIATION; //drifting (rotation posible en portion de pi (PI/drift))
  sFlt L_MIN; //longeur minimum de chaque section
  sFlt L_MAX; //longeur max de chaque section MODIFIABLE PAR MENU MOVE minimum 1 , limité dans l'update de sont bp
  sFlt L_DIFFICULTY;
  sFlt OLD_AGE;
  //int TEEN_AGE = OLD_AGE / 20;

  RandomTryParam growP;
  RandomTryParam sproutP;
  RandomTryParam stopP;
  RandomTryParam leafP;
  RandomTryParam dieP;
  float MAX_LINE_WIDTH = 1.5; //epaisseur max des ligne, diminuer par l'age, un peut, se vois pas
  float MIN_LINE_WIDTH = 0.2; //epaisseur min des ligne

  sBoo create_floc;
  sInt activeGrower;
  sRun srun_killg;

  //sLabel grower_nb_label;
  //sGraph graph = new sGraph();
  
  FlocComu fcom;

  void comPanelBuild(nFrontPanel sim_front) {
    nFrontTab tab = com_front.addTab(name);
    tab.getShelf()
      .addDrawerWatch(activeGrower, 10, 0.7)
      .addSeparator(0.125)
      .addDrawerDoubleButton(create_floc, srun_killg, 10, 0.9)
      .addSeparator(0.125)
      .addDrawerFactValue(DEVIATION, 2, 10, 1)
      .addSeparator(0.125)
      .addDrawerFactValue(L_MIN, 2, 10, 1)
      .addSeparator(0.125)
      .addDrawerFactValue(L_MAX, 2, 10, 1)
      .addSeparator(0.125)
      .addDrawerFactValue(L_DIFFICULTY, 2, 10, 1)
      .addSeparator(0.125)
      .addDrawerFactValue(OLD_AGE, 2, 10, 1)
      .addSeparator(0.125)
      .addDrawerActFactValue("grow", growP.ON, growP.DIFFICULTY, 2, 10, 1)
      .addSeparator(0.125)
      .addDrawerActFactValue("Sprout", sproutP.ON, sproutP.DIFFICULTY, 2, 10, 1)
      .addSeparator(0.125)
      .addDrawerActFactValue("leaf", leafP.ON, leafP.DIFFICULTY, 2, 10, 1)
      .addSeparator(0.125)
      .addDrawerActFactValue("stop", stopP.ON, stopP.DIFFICULTY, 2, 10, 1)
      .addSeparator(0.125)
      .addDrawerActFactValue("die", dieP.ON, dieP.DIFFICULTY, 2, 10, 1)
      .addSeparator(0.125)
      ;
  }

  GrowerComu(Simulation _c, String n) { 
    super(_c, "Grower_"+n, "grow", 500);
    DEVIATION = new sFlt(sbloc, 8, name+" dev", "dev");
    L_MIN = new sFlt(sbloc, 20, name+" lmin", "lmin");
    L_MAX = new sFlt(sbloc, 350, name+" lmax", "lmax");
    L_DIFFICULTY = new sFlt(sbloc, 180, name+" ldif", "ldif");
    OLD_AGE = new sFlt(sbloc, 666, name+" age", "age");

    growP = new RandomTryParam(sbloc, 0.5, true, name+" grow");
    sproutP = new RandomTryParam(sbloc, 2080, true, name+"  sprout");
    stopP = new RandomTryParam(sbloc, 1.25, true, name+"  stop");
    leafP = new RandomTryParam(sbloc, 2080, true, name+"  leaf");
    dieP = new RandomTryParam(sbloc, 3.6, true, name+"  die");

    create_floc = new sBoo(sbloc, true, name+"  create floc", "create floc");
    activeGrower = new sInt(sbloc, 0, name+" activeGrower", "growers nb");

    srun_killg = new sRun(sbloc, name+"  kill grower", "kill", new Runnable(list) { 
      public void run() { 
        for (Entity e : ((ArrayList<Entity>)builder)) {
          Grower g = (Grower)e;
          if (!g.end && g.sprouts == 0) { 
            g.end = true;
          }
        }
      }
    }
    );

    //graph.init();
  }
  void custom_cam_draw_pre_entity() {
  }
  void custom_cam_draw_post_entity() {
  }
  void custom_pre_tick() {
    activeGrower.set(grower_Nb());
  }
  void custom_post_tick() {
  }

  Grower build() { 
    return new Grower(this);
  }
  Grower addEntity() {
    Grower ng = newEntity();
    if (ng != null) ng.define(new PVector(adding_cursor.x(), adding_cursor.y()), new PVector(1, 0).rotate(random(2*PI)));
    return ng;
  }
  Grower newEntity() {
    Grower ng = null;
    for (Entity e : list) 
      if (!e.active && ng == null) { 
        ng = (Grower)e; 
        e.activate();
      }
    return ng;
  }
  void custom_frame() {
    //graph.update(activeEntity.get(), activeGrower.get());
  }
  void custom_screen_draw() {
    //graph.draw();
  }
  int grower_Nb() {
    int n = 0;
    for (Entity e : list) if (e.active && !((Grower)e).end && ((Grower)e).sprouts == 0) n++;
    return n;
  }
}





class RandomTryParam {// extends Callable
  sValueBloc sbloc;
  sFlt DIFFICULTY;
  sBoo ON;
  //sFlt test_by_tick;
  int count = 0;
  RandomTryParam(sValueBloc bloc, float d, boolean b, String n) { 
    sbloc = new sValueBloc(bloc, n+" rng param");
    DIFFICULTY = new sFlt(sbloc, 4, n+" dif", "dif");
    ON = new sBoo(sbloc, true, n+" on", "on");
    //test_by_tick = new sFlt(sbloc, 0);
    DIFFICULTY.set(d); 
    ON.set(b); 
    //addChannel(frameend_chan);
  }
  boolean test() { 
    if (ON.get()) count++; 
    //test_by_tick.set(count / sim.tick_by_frame.get()); 
    return ON.get() && crandom(DIFFICULTY.get()) > 0.5;
  }
  //void answer(Channel chan, float v) { count = 0; test_by_tick.set(0); }
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

  Grower(GrowerComu c) { 
    super(c);
  }

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
  Grower frame() { 
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
      if (com().create_floc.get() && com().fcom != null) {
        Floc f = com().fcom.newEntity();
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
  Grower draw() {
    // aging color
    int ca = 255;
    if (age > com().OLD_AGE.get() / 2) ca = (int)constrain(255 + int(com().OLD_AGE.get()/2) - int(age/1.2), 90, 255);
    //if (!end && sprouts == 0) { stroke(255, 0, 0); strokeWeight(param.MAX_LINE_WIDTH+1 / cam_scale); } //BIG red head
    if (!end && sprouts == 0) { 
      stroke(255); 
      strokeWeight((com().MAX_LINE_WIDTH+1) / com.sim.inter.cam.cam_scale.get());
    } else if (end) { 
      stroke(0, ca, 0); 
      strokeWeight((com().MAX_LINE_WIDTH+1) / com.sim.inter.cam.cam_scale.get());
    } else { 
      stroke(ca, ca, ca); 
      strokeWeight(((float)com().MIN_LINE_WIDTH + ((float)com().MAX_LINE_WIDTH * (float)ca / 255.0)) / com.sim.inter.cam.cam_scale.get());
    }              

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
      line(0, 0, e.x, e.y);
      line(e2.x, e2.y, e.x, e.y);
      e.rotate(PI/8);
      line(0, 0, e.x, e.y);
      line(e2.x, e2.y, e.x, e.y);
    } else line(0, 0, e.x, e.y);
    popMatrix();

    //line(pos.x,pos.y,grows.x,grows.y);

    //DEBUG
    //fill(255); ellipseMode(CENTER);
    //ellipse(pos.x, pos.y, 2, 2);
    //strokeWeight(MAX_LINE_WIDTH+1 / cam_scale);
    //point(grows.x,grows.y);
    return this;
  }
  Grower clear() { 
    return this;
  }
  GrowerComu com() { 
    return ((GrowerComu)com);
  }
}












         
