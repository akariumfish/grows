class FlocComu extends Community {
  
  sFlt POURSUITE = new sFlt(simval, 0.6);
  sFlt FOLLOW = new sFlt(simval, 0.0036);
  sFlt SPACING = new sFlt(simval, 150);
  sFlt SPEED = new sFlt(simval, 2);
  sInt LIMIT = new sInt(simval, 400);
  
  sBoo DRAWMODE_DEF = new sBoo(simval, true);
  sBoo DRAWMODE_DEBUG = new sBoo(simval, false);
  
  sFlt HALO_SIZE = new sFlt(simval, 20);
  sFlt HALO_DENS = new sFlt(simval, 0.2);
  
  sBoo create_grower = new sBoo(simval, true);
  sBoo point_to_mouse = new sBoo(simval, false);
  sBoo point_to_center = new sBoo(simval, false);
  
  int startbox = 400;
  
  FlocComu(ComunityList _c) { super(_c, "Floc", 100); init();
    panel.addSeparator(1)
      .addDrawer(20)
        .addText("Affichage:", 0, 0)
          .setFont(16)
          .getDrawer()
        .addExclusiveSwitchs("def", "debug", 80, 0, DRAWMODE_DEF, DRAWMODE_DEBUG)
        .getPanel()
      .addSeparator(5)
      .addValueController("halosize ", sMode.FACTOR, 2, 1.2, HALO_SIZE)
      .addSeparator(5)
      .addValueController("halodens ", sMode.FACTOR, 2, 1.2, HALO_DENS)
      .addSeparator(5)
      .addValueController("TRACK ", sMode.FACTOR, 2, 1.2, POURSUITE)
      .addSeparator(5)
      .addValueController("FOLLOW ", sMode.FACTOR, 2, 1.2, FOLLOW)
      .addSeparator(5)
      .addValueController("SPACING ", sMode.FACTOR, 2, 1.2, SPACING)
      .addSeparator(5)
      .addValueController("LIMIT ", sMode.FACTOR, 2, 1.2, LIMIT)
      .addSeparator(5)
      .addValueController("SPEED ", sMode.FACTOR, 2, 1.2, SPEED)
      .addSeparator(10)
      .addDrawer(20)
        .addSwitch("CREATE GROWER", 90, 0)
          .setValue(create_grower)
          .setSize(200, 20)
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      .addDrawer(20)
        .addSwitch("TO MOUSE", 30, 0)
          .setValue(point_to_mouse)
          .setSize(160, 20)
          .getDrawer()
        .addSwitch("TO CENTER", 210, 0)
          .setValue(point_to_center)
          .setSize(160, 20)
          .getDrawer()
        .getPanel()
      .addSeparator(10)
      ;
    
  }
  void custom_tick() {
    for (Entity e1 : list)
      for (Entity e2 : list)
        if (e1.id < e2.id && e1 != e2 && e1.active && e2.active)
            ((Floc)e1).pair(((Floc)e2));
          
  }
  
  Floc build() { return new Floc(this); }
  Floc initialEntity() { return newEntity(); }
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
  
  Floc(FlocComu c) { super(c); }
  
  void draw_halo(Canvas canvas, PImage i) {
    //walk a box of pix around entity containing the halo (pos +/- halo radius)
    for (float px = int(pos.x - halo_size) ; px < int(pos.x + halo_size) ; px+=1*canvas.canvas_scale)
      for (float py = int(pos.y - halo_size) ; py < int(pos.y + halo_size) ; py+=1*canvas.canvas_scale) {
        PVector m = new PVector(pos.x - px, pos.y - py);
        if (m.mag() < halo_size) { //get and try distence of current pix
          //the color to add to the current pix is function of his distence to the center
          //the decreasing of the quantity of color to add is soothed
          int a = int( (255.0 * halo_density) * soothedcurve(1.0, m.mag() / halo_size) );
          canvas.addpix(i, px, py, color(a, 0, 0));
        }
    }
  }
  
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
  Floc tick() {
    age++;
    if (age > 2000) {
      if (com().create_grower.get()) {
        Grower ng = gcom.newEntity();
        if (ng != null) ng.define(new PVector(pos.x, pos.y), new PVector(1, 0).rotate(random(2*PI)));
      }
      destroy();
    }
    //point toward mouse
    if (com().point_to_mouse.get()) headTo(cam.screen_to_cam(new PVector(mouseX, mouseY)), 0.01);
    //point toward center
    if (com().point_to_center.get()) headTo(new PVector(0, 0), 0.01);
    pos.add(mov);
    return this;
  }
  Floc drawing() {
    fill(255);
    stroke(255);
    strokeWeight(4/cam.cam_scale.get());
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
