


class FlocPrint extends Blueprint {
  FlocPrint(Simulation s) { super(s, "Floc"); }
  FlocComu build(String n) { return new FlocComu(sim, n); }
}



class FlocComu extends Community {
  
  void comPanelBuild(nFrontPanel sim_front) {
    nFrontTab tab = com_front.addTab(name);
    tab.getShelf()
      .addDrawerDoubleButton(DRAWMODE_DEF, DRAWMODE_DEBUG, 10, 1)
      .addSeparator(0.125)
      .addDrawerDoubleButton(point_to_mouse, point_to_center, 10, 1)
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
      ;
  }
  
  sFlt POURSUITE, FOLLOW, SPACING, SPEED, HALO_SIZE, HALO_DENS ;
  sInt LIMIT, AGE ;
  sBoo DRAWMODE_DEF, DRAWMODE_DEBUG, create_grower, point_to_mouse, point_to_center;
  
  int startbox = 400;
  
  GrowerComu gcom;
  
  FlocComu(Simulation _c, String n) { super(_c, n+" Floc ", "floc", 100); 
    POURSUITE = new sFlt(sbloc, 0.3, name+"floc POURSUITE", "poursuite");
    FOLLOW = new sFlt(sbloc, 0.0036, name+"floc FOLLOW", "follox");
    SPACING = new sFlt(sbloc, 95, name+"floc SPACING", "space");
    SPEED = new sFlt(sbloc, 2, name+"floc SPEED", "speed");
    LIMIT = new sInt(sbloc, 1600, name+"floc limit", "limit");
    AGE = new sInt(sbloc, 2000, name+"floc age", "age");
    HALO_SIZE = new sFlt(sbloc, 80, name+"floc HALO_SIZE", "Size");
    HALO_DENS = new sFlt(sbloc, 0.15, name+"floc HALO_DENS", "Dens");
    
    DRAWMODE_DEF = new sBoo(sbloc, true, name+"floc DRAWMODE_DEF", "draw1");
    DRAWMODE_DEBUG = new sBoo(sbloc, false, name+"floc DRAWMODE_DEBUG", "draw2");
    
    create_grower = new sBoo(sbloc, true, name+"floc create_grower", "create grow");
    point_to_mouse = new sBoo(sbloc, false, name+"floc point_to_mouse", "to center");
    point_to_center = new sBoo(sbloc, true, name+"floc point_to_center", "to mouse");
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
    pos.x = random(-com().startbox, com().startbox);
    pos.y = random(-com().startbox, com().startbox);
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
    if (com().point_to_mouse.get()) headTo(com().sim.inter.cam.screen_to_cam(new PVector(mouseX, mouseY)), 0.01);
    //point toward center
    if (com().point_to_center.get()) headTo(new PVector(0, 0), 0.01);
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
