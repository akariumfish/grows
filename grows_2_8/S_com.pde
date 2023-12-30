





class GrowerPrint extends Sheet_Specialize {
  Simulation sim;
  GrowerPrint(Simulation s) { super("Grower"); sim = s; }
  GrowerComu get_new(Macro_Sheet s, String n, sValueBloc b) { return new GrowerComu(sim, n, b); }
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

  //sGraph graph = new sGraph();
  
  FlocComu fcom;

  void comPanelBuild(nFrontPanel sim_front) {
    nFrontTab tab = sim_front.addTab(name);
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
  
  void selected_comu(Community c) { 
    //logln(c.name + c.type_value.get());
    if (c != null && c.type_value.get().equals("floc")) fcom = (FlocComu)c;
  }

  GrowerComu(Simulation _c, String n, sValueBloc t) { 
    super(_c, n, "grow", 1000, t);
    DEVIATION = newFlt(6, "dev", "dev");
    L_MIN = newFlt(2.5, "lmin", "lmin");
    L_MAX = newFlt(40, "lmax", "lmax");
    L_DIFFICULTY = newFlt(1, "ldif", "ldif");
    OLD_AGE = newFlt(100, "age", "age");

    growP = new RandomTryParam(this, 0.2, true, "grow");
    sproutP = new RandomTryParam(this, 3000, true, "sprout");
    stopP = new RandomTryParam(this, 2, true, "stop");
    leafP = new RandomTryParam(this, 5000, true, "leaf");
    dieP = new RandomTryParam(this, 40, true, "die");

    create_floc = newBoo(true, "create_floc", "create floc");
    activeGrower = newInt(0, "active_grower", "growers nb");

    srun_killg = newRun("kill_grower", "kill", new Runnable(list) { 
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
    if (ng != null) ng.define(adding_cursor.pos(), adding_cursor.dir());
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
  sFlt DIFFICULTY;
  sBoo ON;
  //sFlt test_by_tick;
  int count = 0;
  RandomTryParam(Macro_Sheet sheet, float d, boolean b, String n) { 
    DIFFICULTY = sheet.newFlt(4, n+"_dif", "dif");
    ON = sheet.newBoo(true, n+"_on", "on");
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












         















class FlocPrint extends Sheet_Specialize {
  Simulation sim;
  FlocPrint(Simulation s) { super("Floc"); sim = s; }
  FlocComu get_new(Macro_Sheet s, String n, sValueBloc b) { return new FlocComu(sim, n, b); }
}



class FlocComu extends Community {
  
  void comPanelBuild(nFrontPanel sim_front) {
    nFrontTab tab = sim_front.addTab(name);
    tab.getShelf()
      .addDrawerDoubleButton(DRAWMODE_DEF, DRAWMODE_DEBUG, 10, 1)
      .addSeparator(0.125)
      .addDrawerTripleButton(point_to_mouse, point_to_center, point_to_cursor, 10, 1)
      .addSeparator(0.125)
      .addDrawerDoubleButton(create_grower, null, 10, 1)
      .addSeparator(0.125)
      .addDrawerFactValue(POURSUITE, 2, 10, 1)
      .addSeparator(0.125)
      .addDrawerFactValue(FOLLOW, 2, 10, 1)
      .addSeparator(0.125)
      .addDrawerFactValue(SPACING, 2, 10, 1)
      .addSeparator(0.125)
      .addDrawerFactValue(SPEED, 2, 10, 1)
      .addSeparator(0.125)
      .addDrawerFactValue(LIMIT, 2, 10, 1)
      .addSeparator(0.125)
      .addDrawerFactValue(AGE, 2, 10, 1)
      .addSeparator(0.125)
      .addDrawerFactValue(HALO_SIZE, 2, 10, 1)
      .addSeparator(0.125)
      .addDrawerFactValue(HALO_DENS, 2, 10, 1)
      .addSeparator(0.125)
      .addDrawerFactValue(POINT_FORCE, 2, 10, 1)
      .addSeparator(0.125)
      ;
  }
  
  void selected_comu(Community c) { 
    if (c != null && c.type_value.get().equals("grow")) gcom = (GrowerComu)c;
  }
  
  sFlt POURSUITE, FOLLOW, SPACING, SPEED, HALO_SIZE, HALO_DENS, POINT_FORCE ;
  sInt LIMIT, AGE ;
  sBoo DRAWMODE_DEF, DRAWMODE_DEBUG, create_grower, point_to_mouse, point_to_center, point_to_cursor;
  
  int startbox = 400;
  
  GrowerComu gcom;
  
  FlocComu(Simulation _c, String n, sValueBloc b) { super(_c, n, "floc", 50, b); 
    POURSUITE = newFlt(0.3, "POURSUITE", "poursuite");
    FOLLOW = newFlt(0.0036, "FOLLOW", "follox");
    SPACING = newFlt(95, "SPACING", "space");
    SPEED = newFlt(2, "SPEED", "speed");
    LIMIT = newInt(1600, "limit", "limit");
    AGE = newInt(2000, "age", "age");
    HALO_SIZE = newFlt(80, "HALO_SIZE", "Size");
    HALO_DENS = newFlt(0.15, "HALO_DENS", "Dens");
    POINT_FORCE = newFlt(0.01, "POINT_FORCE", "point");
    
    DRAWMODE_DEF = newBoo(true, "DRAWMODE_DEF", "draw1");
    DRAWMODE_DEBUG = newBoo(false, "DRAWMODE_DEBUG", "draw2");
    
    create_grower = newBoo(true, "create_grower", "create grow");
    point_to_mouse = newBoo(false, "point_to_mouse", "to center");
    point_to_center = newBoo(false, "point_to_center", "to mouse");
    point_to_cursor = newBoo(false, "point_to_cursor", "to cursor");
    //init_canvas();
    
  }
  
  void custom_pre_tick() {
    for (Entity e1 : list)
      for (Entity e2 : list)
        if (e1.id < e2.id && e1 != e2 && e1.active && e2.active)
            ((Floc)e1).pair(((Floc)e2));
          
  }
  void custom_post_tick() {}
  void custom_frame() {
    //can.drawHalo(this);
  }
  void custom_cam_draw_post_entity() {}
  void custom_cam_draw_pre_entity() {
    //can.drawCanvas();
  }
  
  Floc build() { return new Floc(this); }
  Floc addEntity() { return newEntity(); }
  Floc newEntity() {
    for (Entity e : list) if (!e.active) { e.activate(); return (Floc)e; } return null; }
}

class Floc extends Entity {
  PVector pos = new PVector(0, 0);
  PVector mov = new PVector(0, 0);
  float speed = 0;
  
  float halo_size = 0;
  float halo_density = 0;
  
  int age = 0;
  int max_age = 2000;
  
  Floc(FlocComu c) { super(c); }
  
  //void draw_halo(Canvas canvas, PImage i) {
  //  //walk a box of pix around entity containing the halo (pos +/- halo radius)
  //  for (float px = int(pos.x - halo_size) ; px < int(pos.x + halo_size) ; px+=1*canvas.canvas_scale)
  //    for (float py = int(pos.y - halo_size) ; py < int(pos.y + halo_size) ; py+=1*canvas.canvas_scale) {
  //      PVector m = new PVector(pos.x - px, pos.y - py);
  //      if (m.mag() < halo_size) { //get and try distence of current pix
  //        //the color to add to the current pix is function of his distence to the center
  //        //the decreasing of the quantity of color to add is soothed
  //        int a = int( (255.0 * halo_density) * soothedcurve(1.0, m.mag() / halo_size) );
  //        canvas.addpix(i, px, py, color(a, 0, 0));
  //      }
  //  }
  //}
  
  void headTo(PVector c, float s) {
    PVector l = new PVector(c.x, c.y);
    l.add(-pos.x, -pos.y);
    float r1 = mapToCircularValues(mov.heading(), l.heading(), s, -PI, PI);
    mov.x = speed; mov.y = 0;
    mov.rotate(r1);
  }
  void headTo(float l, float s) {
    float r1 = mapToCircularValues(mov.heading(), l, s, -PI, PI);
    mov.x = speed; mov.y = 0;
    mov.rotate(r1);
  }
  
  void pair(Floc b2) {
    float d = dist(pos.x, pos.y, b2.pos.x, b2.pos.y);
    if (d < com().SPACING.get()) {
      headTo(b2.mov.heading(), com().FOLLOW.get() / ((com().SPACING.get() - d) / com().SPACING.get()) );
      b2.headTo(mov.heading(), com().FOLLOW.get() / ((com().SPACING.get() - d) / com().SPACING.get()) );
    } else {
      headTo(b2.pos, com().POURSUITE.get() / d);
      b2.headTo(pos, com().POURSUITE.get() / d);
    }
  }
  
  Floc init() {
    age = 0;
    max_age = com().AGE.get();
    halo_size = com().HALO_SIZE.get();
    halo_density = com().HALO_DENS.get();
    halo_size += random(com().HALO_SIZE.get());
    halo_density += random(com().HALO_DENS.get());
    pos = com().adding_cursor.pos();
    //pos.x = random(-com().startbox, com().startbox);
    //pos.y = random(-com().startbox, com().startbox);
    speed = random(0.5, 1) * com().SPEED.get();
    mov.x = speed; mov.y = 0;
    mov.rotate(random(PI * 2.0));
    return this;
  }
  Floc frame() { return this; }
  Floc tick() {
    age++;
    if (age > max_age) {
      if (com().create_grower.get() && com().gcom != null) {
        Grower ng = com().gcom.newEntity();
        if (ng != null) ng.define(new PVector(pos.x, pos.y), new PVector(1, 0).rotate(mov.heading()));
      }
      destroy();
    }
    //point toward mouse
    if (com().point_to_mouse.get()) headTo(com().sim.inter.cam.screen_to_cam(new PVector(mouseX, mouseY)), 
                                           com().POINT_FORCE.get());
    //point toward center
    if (com().point_to_center.get()) headTo(new PVector(0, 0), com().POINT_FORCE.get());
    //point toward cursor
    if (com().point_to_cursor.get()) headTo(com().adding_cursor.pos(), com().POINT_FORCE.get());
    pos.add(mov);
    return this;
  }
  Floc draw() {
    fill(255);
    stroke(255);
    strokeWeight(4/com.sim.cam_gui.scale);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(mov.heading());
    if (com().DRAWMODE_DEF.get()) {
      line(0, 0, -10, -10);
      line(2, 0, -10, 0);
      line(0, 0, -10, 10);
    }
    stroke(255, 0, 0);
    if (com().DRAWMODE_DEBUG.get()) ellipse(0, 0, 1, 1);
    popMatrix();
    return this;
  }
  Floc clear() { return this; }
  FlocComu com() { return ((FlocComu)com); }
}



//#######################################################################
//##          ROTATING TO ANGLE CIBLE BY SHORTEST DIRECTION            ##
//#######################################################################


float mapToCircularValues(float current, float cible, float increment, float start, float stop) {
  if (start > stop) {float i = start; start = stop; stop = i;}
  increment = abs(increment);
  
  while (cible > stop) {cible -= (stop - start);}
  while (current > stop) {current -= (stop - start);}
  while (cible < start) {cible += (stop - start);}
  while (current < start) {current += (stop - start);}
  
  if (cible < current) {
    if ( (current - cible) <= (stop - current + cible - start) ) {
      if (increment >= current - cible) {return cible;}
      else                              {return current - increment;}
    } else {
      if (increment >= stop - current + cible - start) {return cible;}
      else if (current + increment < stop)             {return current + increment;}
      else                                             {return start + (increment - (stop - current));}
    }
  } else if (cible > current) {
    if ( (cible - current) <= (stop - cible + current - start) ) {
      if (increment >= cible - current) {return cible;}
      else                              {return current + increment;}
    } else { 
      if (increment >= stop - cible + current - start) {return cible;}
      else if (current - increment > start)            {return current - increment;}
      else                                             {return stop - (increment - (current - start));}
    }
  }
  return cible;
}



//#######################################################################
//##                              CANVAS                               ##
//#######################################################################


//Canvas can;

//void init_canvas() {
//  can = new Canvas(0, 0, int((width) / cam.cam_scale.get()), int((height) / cam.cam_scale.get()), 4);
//}

//class Canvas extends Callable {
//  PVector pos = new PVector(0, 0);
//  float canvas_scale = 1.0;
//  PImage can1,can2;
  
//  int active_can = 0;
//  int can_div = 4;
//  int can_st = can_div-1;
  
//  sBoo show_canvas = new sBoo(simval, true);
//  sBoo show_canvas_bound = new sBoo(simval, true);
  
//  sGrabable can_grab;
  
//  Canvas() { construct(0, 0, width, height, 1); }
//  Canvas(float x, float y, int w, int h, float s) { construct(x, y, w, h, s); }
  
//  void construct(float x, float y, int w, int h, float s) {
//    w /= s; h /= s;
//    can1 = createImage(w, h, RGB);
//    init(can1);
//    can2 = createImage(w, h, RGB);
//    init(can2);
//    pos.x = x - int(w) / 2;
//    pos.y = y - int(h) / 2;
//    can_grab = new sGrabable(cp5, x, y + 20);
//    addChannel(frame_chan);
//    if (show_canvas.get()) can_grab.show(); else can_grab.hide();
//    canvas_scale = s;
//  }
  
  
//  void answer(Channel chan, float value) {
//    if (chan == frame_chan) {
//      pos = cam.screen_to_cam(can_grab.getP());
//      pos.y -= 20 / cam.cam_scale.get();
//    }
//  }
  
//  void drawHalo(Community com) {
//    if (active_can == 0) {
//      for (int i = can_st ; i < com.list.size() ; i += can_div)
//        if (com.list.get(i).active) {
//          com.list.get(i).draw_halo(this, can2);
//      }
//      if (can_st == 0) {
//        active_can = 1;
//        clear(can1);
//        can_st = can_div - 1;
//      } else can_st--;
//    }
//    else if (active_can == 1) {
//      for (int i = can_st ; i < com.list.size() ; i += can_div)
//        if (com.list.get(i).active) {
//          com.list.get(i).draw_halo(this, can1);
//      }
//      if (can_st == 0) {
//        active_can = 0;
//        clear(can2);
//        can_st = can_div - 1;
//      } else can_st--;
//    }
//  }
  
//  void drawCanvas() {
//    if (show_canvas.get()) {
//      if (show_canvas_bound.get()) {
//        stroke(255);
//        strokeWeight(3 / cam.cam_scale.get());
//        noFill();
//        rect(pos.x, pos.y, can1.width * canvas_scale, can1.height * canvas_scale);
//      }
//      if (active_can == 0) draw(can1);
//      else if (active_can == 1) draw(can2);
//    }
//  }
  
//  private void init(PImage canvas) {
//    for(int i = 0; i < canvas.pixels.length; i++) {
//      canvas.pixels[i] = color(0); 
//    }
//  }
  
//  void clear(PImage canvas) {
//    for (int i = 0 ; i < canvas.pixels.length ; i++) {
//      canvas.pixels[i] = color(0);
//    }
//  }
  
//  void draw(PImage canvas) {
//    canvas.updatePixels();
//    pushMatrix();
//    translate(pos.x, pos.y);
//    scale(canvas_scale);
//    image(canvas, 0, 0);
//    popMatrix();
//  }
  
//  void addpix(PImage canvas, float x, float y, color nc) {
//    x += canvas_scale/2;
//    y += canvas_scale/2;
//    x -= pos.x;
//    y -= pos.y;
//    x /= canvas_scale;
//    y /= canvas_scale;
//    if (x < 0 || y < 0 || x > canvas.width || y > canvas.height) return;
//    int pi = canvas.width * int(y) + int(x);
//    if (pi >= 0 && pi < canvas.pixels.length) {
//      color oc = canvas.pixels[pi];
//      canvas.pixels[pi] = color(min(255, red(oc) + red(nc)), min(255, green(oc) + green(nc)), min(255, blue(oc) + blue(nc)));
//    }
//  }
//  //color getpix(PImage canvas, PVector v) { return getpix(canvas, v.x, v.y); }
//  //color getpix(PImage canvas, float x, float y) {
//  //  color co = 0;
//  //  int pi = canvas.width * int(y + canvas.height / 2) + int(x + canvas.width/2);
//  //  if (pi >= 0 && pi < canvas.pixels.length) {
//  //    co = canvas.pixels[pi];
//  //  }
//  //  return co;
//  //}
//  //void setpix(PImage canvas, PVector v, color c) { setpix(canvas, v.x, v.y, c); }
//  //void setpix(PImage canvas, float x, float y, color c) {
//  //  int pi = canvas.width * int(y + canvas.height / 2) + int(x + canvas.width/2);
//  //  if (pi >= 0 && pi < canvas.pixels.length) {
//  //    canvas.pixels[pi] = c;
//  //  }
//  //}
  
//  //void canvas_croix(PImage canvas, float x, float y, int c) {
//  //  color co = getpix(canvas, x, y);
//  //  setpix(canvas, x, y, color(c + red(co)) );
//  //  setpix(canvas, x + 1, y, color(c/2 + red(co)) );
//  //  setpix(canvas, x - 1, y, color(c/2 + red(co)) );
//  //  setpix(canvas, x, y + 1, color(c/2 + red(co)) );
//  //  setpix(canvas, x, y - 1, color(c/2 + red(co)) );
//  //}
  
//  //void canvas_line(PImage canvas, PVector v1, PVector v2, int c) {
//  //  PVector m = new PVector(v1.x - v2.x, v1.y - v2.y);
//  //  int l = int(m.mag());
//  //  m.setMag(-1);
//  //  PVector p = new PVector(v1.x, v1.y);
//  //  for (int i = 0 ; i < l ; i++) {
//  //    color co = getpix(canvas, p.x, p.y);
//  //    setpix(canvas, p.x, p.y, color(c + red(co)) );
//  //    p.add(m);
//  //  }
//  //}
//}













//class BoxPrint extends Blueprint {
//  BoxPrint(Simulation s) { super(s, "Box", "box"); }
//  BoxComu build(String n, String t) { return new BoxComu(sim, n, t); }
//}




//class BoxComu extends Community {
  
//  void comPanelBuild(nFrontPanel sim_front) {
//    nFrontTab tab = sim_front.addTab(name);
//    tab.getShelf()
//      .addDrawerFactValue(spacing_min, 2, 10, 1)
//      .addSeparator(0.125)
//      .addDrawerFactValue(spacing_max, 2, 10, 1)
//      .addSeparator(0.125)
//      .addDrawerFactValue(spacing_diff, 2, 10, 1)
//      .addSeparator(0.125)
//      .addDrawerFactValue(spacing_max_dist, 2, 10, 1)
//      .addSeparator(0.125)
//      .addDrawerFactValue(box_size_min, 2, 10, 1)
//      .addSeparator(0.125)
//      .addDrawerFactValue(box_size_max, 2, 10, 1)
//      .addSeparator(0.125)
//      .addDrawerFactValue(duplicate_prob, 2, 10, 1)
//      .addSeparator(0.125)
//      .addDrawerFactValue(corner_space, 2, 10, 1)
//      .addSeparator(0.125)
//      .addDrawerFactValue(max_age, 2, 10, 1)
//      .addSeparator(0.125)
//      ;
//  }
  
//  sFlt spacing_min , spacing_max, spacing_diff, spacing_max_dist, box_size_min, 
//    box_size_max, duplicate_prob, corner_space;
  
//  sInt max_age;
  
//  //sBoo draw_circle = new sBoo(simval, false);
  
//  int cnt = 0;
//  FlocComu fcom;
//  BoxComu(Simulation _c, String n, String t) { super(_c, n, t, 0);
//    spacing_min = new sFlt(value_bloc, 50, "box_spacing_min", "sp min");
//    spacing_max = new sFlt(value_bloc, 200, "box_spacing_max", "sp max");
//    spacing_diff = new sFlt(value_bloc, 1, "box_spacing_diff", "sp dif");
//    spacing_max_dist = new sFlt(value_bloc, 10000, "normal_spacing_dist", "norm sp");
//    box_size_min = new sFlt(value_bloc, 100, "box_size_min", "sz min");
//    box_size_max = new sFlt(value_bloc, 400, "box_size_max", "sz max");
//    duplicate_prob = new sFlt(value_bloc, 5.0, "duplicate_prob", "duplic");
//    corner_space = new sFlt(value_bloc, 40, "box_corner_space", "corner");
//    max_age = new sInt(value_bloc, 2000, "max_age", "age");
    
    
//  }
//  void custom_pre_tick() {}
//  void custom_build() {}
  
  
//  void custom_post_tick() { 
//    cnt+=2;
//    if (cnt > 2400) cnt -= 2400;
//  }
//  void custom_cam_draw_pre_entity() {}
//  void custom_reset() { cnt = 0; }
//  void custom_cam_draw_post_entity() { 
//    //float r = spacing_max_dist.get();  
//    //noFill();
//    //stroke(255);
//    ////ellipse(0, 0, r, r);
    
//  }//
  
//  Box build() { return new Box(this); }
//  Box addEntity() { return newEntity(); }
//  Box newEntity() { 
//    for (Entity e : list) if (!e.active) { e.activate(); return (Box)e; } return null; }
//}


//class Box extends Entity {
//  Rect rect = new Rect();
//  Box origin;
//  int generation = 1;
//  PVector connect1 = new PVector(0, 0);
//  PVector connect2 = new PVector(0, 0);
//  PVector origin_co = new PVector(0, 0); //origin box to ext co
//  float space = 0;
//  int age = 0;
  
//  Box(BoxComu c) { super(c); }
  
//  //void draw_halo(Canvas canvas, PImage i) {}
  
//  void pair(Box b2) {}
  
//  Box init() {
//    rect.size.x = random(com().box_size_min.get(), com().box_size_max.get()); 
//    rect.size.y = random(com().box_size_min.get(), com().box_size_max.get());
//    rect.pos.x = -rect.size.x/2; rect.pos.y = -rect.size.y/2;
//    connect1.x = rect.pos.x; connect1.y = rect.pos.y;
//    connect2.x = rect.pos.x; connect2.y = rect.pos.y;
//    origin = null;
//    origin_co.x = 0;
//    origin_co.y = 0;
//    generation = 1;
//    space = com().spacing_min.get();
//    rotation = -0.008;
//    col = 0;
//    age = 0;
//    return this;
//  }
//  void define_bis(Box b2, float x, float y, String dir) {
//    rect.pos.x = x; rect.pos.y = y;
//    for (Entity e : com().list) if (e.active) {
//      Box b = (Box)e;
//      if (b != this && rectCollide(rect, b.rect, com().spacing_min.get()/2)) {//-2
//        this.destroy(); return; } }
//    origin = b2;
//    generation = b2.generation + 1;
//    float corner_space = com().corner_space.get();
//    if (dir.charAt(0) == 'v') {
//      if (dir.charAt(1) == 'u') {
//        connect1.x = random(rect.pos.x + corner_space, rect.pos.x + rect.size.x - (2*corner_space));
//        connect1.y = rect.pos.y + rect.size.y;
//        connect2.x = random(b2.rect.pos.x + corner_space, b2.rect.pos.x + b2.rect.size.x - (2*corner_space));
//        connect2.y = b2.rect.pos.y;
//      } else {
//        connect1.x = random(rect.pos.x + corner_space, rect.pos.x + rect.size.x - (2*corner_space));
//        connect1.y = rect.pos.y;
//        connect2.x = random(b2.rect.pos.x + corner_space, b2.rect.pos.x + b2.rect.size.x - (2*corner_space));
//        connect2.y = b2.rect.pos.y + b2.rect.size.y;
//      }
//    } else {
//      if (dir.charAt(1) == 'l') {
//        connect1.y = random(rect.pos.y + corner_space, rect.pos.y + rect.size.y - (2*corner_space));
//        connect1.x = rect.pos.x + rect.size.x;
//        connect2.y = random(b2.rect.pos.y + corner_space, b2.rect.pos.y + b2.rect.size.y - (2*corner_space));
//        connect2.x = b2.rect.pos.x;
//      } else {
//        connect1.y = random(rect.pos.y + corner_space, rect.pos.y + rect.size.y - (2*corner_space));
//        connect1.x = rect.pos.x;
//        connect2.y = random(b2.rect.pos.y + corner_space, b2.rect.pos.y + b2.rect.size.y - (2*corner_space));
//        connect2.x = b2.rect.pos.x + b2.rect.size.x;
//      }
//    }
//    origin_co.x = connect2.x - origin.rect.pos.x;
//    origin_co.y = connect2.y - origin.rect.pos.y; //origin box to ext co
//    //PVector connect_line = new PVector(connect1.x - connect2.x, connect1.y - connect2.y); //ext co to self co
    
//    rotation = 0;//.008 * (6000 - connect_line.mag()) / 6000;
//    //PVector box_local = new PVector(rect.pos.x - connect1.x, rect.pos.y - connect1.y); //self co to box pos
//    //connect_line.rotate(rotation + burst);
//    //connect1.x = connect_line.x + connect2.x;
//    //connect1.y = connect_line.y + connect2.y;
//    //rect.pos.x = box_local.x + connect1.x;
//    //rect.pos.y = box_local.y + connect1.y;
//  }
  
//  Box define(Box b2) {
//    space = com().spacing_min.get() + 
//            ( 2 * com().spacing_max.get() * min(1, b2.rect.pos.mag()
//            / com().spacing_max_dist.get()) ) * crandom(com().spacing_diff.get());
//    //space = crandom( com().spacing_min.get(), 
//    //                 com().spacing_max.get(), 
//    //                 ( min(0, com().spacing_max_dist.get() - b2.rect.pos.mag()) / com().spacing_max_dist.get()) * com().spacing_diff.get() );
//    rect.size.x = random(com().box_size_min.get(), com().box_size_max.get()); 
//    rect.size.y = random(com().box_size_min.get(), com().box_size_max.get());
//    boolean axe = random(10) < 5;
//    float dir_mod = 0;
//    if (axe && b2.rect.pos.y > 0) dir_mod = -2.5;
//    if (axe && b2.rect.pos.y < 0) dir_mod = 2.5;
//    if (!axe && b2.rect.pos.x > 0) dir_mod = -2.5;
//    if (!axe && b2.rect.pos.x < 0) dir_mod = 2.5;
//    boolean side = random(10) < 5 + dir_mod;
//    if (axe) {
//      if (side) {
//        define_bis(b2, b2.rect.pos.x - rect.size.x - space + random(b2.rect.size.x + rect.size.x + 2*space), 
//                       b2.rect.pos.y - (rect.size.y + space), "vu"); }
//      else {
//        define_bis(b2, b2.rect.pos.x - rect.size.x - space + random(b2.rect.size.x + rect.size.x + 2*space),
//                       b2.rect.pos.y + b2.rect.size.y + space, "vd"); } }
//    else {
//      if (side) {  
//        define_bis(b2, b2.rect.pos.x - (rect.size.x + space),
//                       b2.rect.pos.y - rect.size.y - space + random(b2.rect.size.y + rect.size.y + 2*space), "hl"); }
//      else {                 
//        define_bis(b2, b2.rect.pos.x + b2.rect.size.x + space,
//                       b2.rect.pos.y - rect.size.y - space + random(b2.rect.size.y + rect.size.y + 2*space), "hr"); } }
//    return this;
//  }
  
//  float rotation = -0.008;
//  int col = 0;
//  float burst = 0;
//  boolean blocked = false;
  
//  Box frame() { return this; }
//  Box tick() {
//    age++;
//    if (age > com().max_age.get()) this.destroy();
    
//    if (com().fcom != null) for (Entity e : com().fcom.list) if (e.active) {
//      Floc f = (Floc)e;
//      if (rectCollide(f.pos, rect)) {
//        this.destroy();
//      }
//    }
    
//    if (random(100) < com().duplicate_prob.get()) {
//      Box nb = com().newEntity();
//      if (nb != null) {
//        nb.define(this); } }
    
//    float rspeed = 0.008 / generation;
//    int pcol = col;
//    col = 0;
//    for (Entity e : com().list) if (e.active) {
//      Box b = (Box)e;
//      //if (col >= 1) { rotation = 0; }
//      if (b != this && rectCollide(rect, b.rect, com().spacing_min.get()/2)) {//-2
//        //if (col > 0 && !blocked) rotation *= 1.01;
//        if (col == 0 && !blocked) rotation *= -1;
//        col += 1;
//        //if (col == 0 && abs(rotation) > rspeed*2) rotation = 0;
//      } }
//    //if (blocked) rotation -= 0.00001;
//    //if (abs(rotation) > rspeed*2) { blocked = true; burst = 0.1; if (rotation < 0) burst *= -1; rotation = 0;  }
//    //if (col == 0 && abs(rotation) > rspeed) rotation /= 1.01;
//    if (pcol == 0) blocked = false;
//    //if (blocked && rotation == 0) rotation = rspeed;
//    //println(com().comList.tick.get() + " " + col + " " + rotation);
    
//    PVector connect_line = new PVector(connect1.x - connect2.x, connect1.y - connect2.y); //ext co to self co
//    if (origin != null && origin.active) {
//      //connect2.x = origin.rect.pos.x + origin_co.x;
//      //connect2.y = origin.rect.pos.y + origin_co.y;
//      //PVector box_local = new PVector(rect.pos.x - connect1.x, rect.pos.y - connect1.y); //self co to box pos
//      ////connect_line.rotate(rotation + burst);
//      //connect1.x = connect_line.x + connect2.x;
//      //connect1.y = connect_line.y + connect2.y;
//      //rect.pos.x = box_local.x + connect1.x;
//      //rect.pos.y = box_local.y + connect1.y;
      
//      //burst /= 1.01;
//    }
//    return this; }
  
//  Box draw() {
//    float connect_bubble_size = com().corner_space.get();
    
    
//    float rd = 255.0 * (float)((10.0 - float(abs(generation - int(com().cnt/60.0)))) / 10.0);
//    float stroke_limit = 1;
//    if (rd <= stroke_limit) rd = 255.0 * (float)((10.0 - float(abs(generation - int((com().cnt+1200)/60.0)))) / 10.0);
//    if (rd <= stroke_limit) rd = 255.0 * (float)((10.0 - float(abs(generation - int((com().cnt-1200)/60.0)))) / 10.0);
//    if (rd <= stroke_limit) rd = 255.0 * (float)((10.0 - float(abs(generation - int((com().cnt+2400)/60.0)))) / 10.0);
//    if (rd <= stroke_limit) rd = 255.0 * (float)((10.0 - float(abs(generation - int((com().cnt-2400)/60.0)))) / 10.0);
//    //if (abs(generation - int(com().cnt/60)) < 10) 
//    color filling = color(40, max(100, int(rd-20)), 0);
//    float fc = max( 150, 255 - max(0, int(rd)) ) / 255.0;
//    color lining = color(100*fc, 255*fc, 100*fc);
//    //println(lining);
//    noFill();
//    stroke(lining);
//    strokeWeight(max(2/com.sim.cam_gui.scale, connect_bubble_size/1.3));
//    line(connect1.x, connect1.y, connect2.x, connect2.y);
//    if (connect_bubble_size*com.sim.cam_gui.scale > 3) {
//      fill(filling);
//      stroke(lining);
//      strokeWeight(4/com.sim.cam_gui.scale);
//      ellipse(connect1.x, connect1.y, connect_bubble_size, connect_bubble_size);
//      ellipse(connect2.x, connect2.y, connect_bubble_size, connect_bubble_size); }
//    fill(filling);
//    stroke(lining);
//    strokeWeight(2/com.sim.cam_gui.scale);
//    rect.draw();
//    noFill();
//    stroke(0, 255, 0);
//    strokeWeight(3/com.sim.cam_gui.scale);
//    //rect(rect.pos.x - space/2, rect.pos.y - space/2, rect.size.x + space, rect.size.y + space);
//    if (connect_bubble_size*com.sim.cam_gui.scale > 3) {
//      fill(filling);
//      noStroke();
//      ellipse(connect1.x, connect1.y, connect_bubble_size, connect_bubble_size);
//      ellipse(connect2.x, connect2.y, connect_bubble_size, connect_bubble_size); }
//    noFill();
//    stroke(filling);
//    strokeWeight(max(0, connect_bubble_size/1.3 - 4/com.sim.cam_gui.scale));
//    line(connect1.x, connect1.y, connect2.x, connect2.y);
//    int point_size = 16;
//    int c = 0;
//    strokeWeight(point_size);
//    for (float i = rect.pos.x + (rect.size.x%point_size)/2 + point_size/2; i < rect.pos.x + rect.size.x ; i += point_size) 
//      for (float j = rect.pos.y + (rect.size.y%point_size)/2 + point_size/2; j < rect.pos.y + rect.size.y ; j += point_size) {
//        stroke(0, 255, 0, c);
//        point(i, j);
//        c+=(generation*point_size);
//        if (c > 255) c -= 255;
//      }
//    fill(lining);
//    textFont(getFont(int(rect.size.y/3)));
//    text(""+generation, rect.pos.x + rect.size.x/3, rect.pos.y + rect.size.y/1.41);
//    return this; }
//  Box clear() { return this; }
//  BoxComu com() { return ((BoxComu)com); }
//}










   
