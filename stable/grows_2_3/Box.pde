
class Rect {
  PVector pos = new PVector(0, 0);
  PVector size = new PVector(0, 0);
  Rect() {}
  Rect(float x, float y, float w, float h) {pos.x = x; pos.y = y; size.x = w; size.y = h;}
  Rect(Rect r) {pos.x = r.pos.x; pos.y = r.pos.y; size.x = r.size.x; size.y = r.size.y;}
  void draw() { rect(pos.x, pos.y, size.x, size.y); }
}

boolean rectCollide(Rect rect1, Rect rect2) {
  return (rect1.pos.x < rect2.pos.x + rect2.size.x &&
          rect1.pos.x + rect1.size.x > rect2.pos.x &&
          rect1.pos.y < rect2.pos.y + rect2.size.y &&
          rect1.pos.y + rect1.size.y > rect2.pos.y   );
}

boolean rectCollide(Rect rect1, Rect rect2, float s) {
  Rect r1 = new Rect(rect1); r1.pos.x -= s; r1.pos.y -= s; r1.size.x += 2*s; r1.size.y += 2*s;
  Rect r2 = new Rect(rect2); r2.pos.x -= s; r2.pos.y -= s; r2.size.x += 2*s; r2.size.y += 2*s;
  return (r1.pos.x < r2.pos.x + r2.size.x &&
          r1.pos.x + r1.size.x > r2.pos.x &&
          r1.pos.y < r2.pos.y + r2.size.y &&
          r1.pos.y + r1.size.y > r2.pos.y   );
}

boolean rectCollide(PVector p, Rect rect) {
  return (p.x >= rect.pos.x && p.x <= rect.pos.x + rect.size.x &&
          p.y >= rect.pos.y && p.y <= rect.pos.y + rect.size.y );
}

class Box extends Entity {
  Rect rect = new Rect();
  Box origin;
  int generation = 1;
  PVector connect1 = new PVector(0, 0);
  PVector connect2 = new PVector(0, 0);
  PVector origin_co = new PVector(0, 0); //origin box to ext co
  float space = 0;
  
  Box(BoxComu c) { super(c); }
  
  //void draw_halo(Canvas canvas, PImage i) {}
  
  void pair(Box b2) {}
  
  Box init() {
    rect.size.x = random(com().box_size_min.get(), com().box_size_max.get()); 
    rect.size.y = random(com().box_size_min.get(), com().box_size_max.get());
    rect.pos.x = -rect.size.x/2; rect.pos.y = -rect.size.y/2;
    connect1.x = rect.pos.x; connect1.y = rect.pos.y;
    connect2.x = rect.pos.x; connect2.y = rect.pos.y;
    origin = null;
    origin_co.x = 0;
    origin_co.y = 0;
    generation = 1;
    space = com().spacing_min.get();
    rotation = -0.008;
    col = 0;
    return this;
  }
  void define_bis(Box b2, float x, float y, String dir) {
    rect.pos.x = x; rect.pos.y = y;
    for (Entity e : com().list) if (e.active) {
      Box b = (Box)e;
      if (b != this && rectCollide(rect, b.rect, com().spacing_min.get()/2)) {//-2
        this.destroy(); return; } }
    origin = b2;
    generation = b2.generation + 1;
    float corner_space = com().corner_space.get();
    if (dir.charAt(0) == 'v') {
      if (dir.charAt(1) == 'u') {
        connect1.x = random(rect.pos.x + corner_space, rect.pos.x + rect.size.x - (2*corner_space));
        connect1.y = rect.pos.y + rect.size.y;
        connect2.x = random(b2.rect.pos.x + corner_space, b2.rect.pos.x + b2.rect.size.x - (2*corner_space));
        connect2.y = b2.rect.pos.y;
      } else {
        connect1.x = random(rect.pos.x + corner_space, rect.pos.x + rect.size.x - (2*corner_space));
        connect1.y = rect.pos.y;
        connect2.x = random(b2.rect.pos.x + corner_space, b2.rect.pos.x + b2.rect.size.x - (2*corner_space));
        connect2.y = b2.rect.pos.y + b2.rect.size.y;
      }
    } else {
      if (dir.charAt(1) == 'l') {
        connect1.y = random(rect.pos.y + corner_space, rect.pos.y + rect.size.y - (2*corner_space));
        connect1.x = rect.pos.x + rect.size.x;
        connect2.y = random(b2.rect.pos.y + corner_space, b2.rect.pos.y + b2.rect.size.y - (2*corner_space));
        connect2.x = b2.rect.pos.x;
      } else {
        connect1.y = random(rect.pos.y + corner_space, rect.pos.y + rect.size.y - (2*corner_space));
        connect1.x = rect.pos.x;
        connect2.y = random(b2.rect.pos.y + corner_space, b2.rect.pos.y + b2.rect.size.y - (2*corner_space));
        connect2.x = b2.rect.pos.x + b2.rect.size.x;
      }
    }
    origin_co.x = connect2.x - origin.rect.pos.x;
    origin_co.y = connect2.y - origin.rect.pos.y; //origin box to ext co
    //PVector connect_line = new PVector(connect1.x - connect2.x, connect1.y - connect2.y); //ext co to self co
    
    rotation = 0;//.008 * (6000 - connect_line.mag()) / 6000;
    //PVector box_local = new PVector(rect.pos.x - connect1.x, rect.pos.y - connect1.y); //self co to box pos
    //connect_line.rotate(rotation + burst);
    //connect1.x = connect_line.x + connect2.x;
    //connect1.y = connect_line.y + connect2.y;
    //rect.pos.x = box_local.x + connect1.x;
    //rect.pos.y = box_local.y + connect1.y;
  }
  
  Box define(Box b2) {
    space = com().spacing_min.get() + 
            ( 2 * com().spacing_max.get() * min(1, b2.rect.pos.mag()
            / com().spacing_max_dist.get()) ) * crandom(com().spacing_diff.get());
    //space = crandom( com().spacing_min.get(), 
    //                 com().spacing_max.get(), 
    //                 ( min(0, com().spacing_max_dist.get() - b2.rect.pos.mag()) / com().spacing_max_dist.get()) * com().spacing_diff.get() );
    rect.size.x = random(com().box_size_min.get(), com().box_size_max.get()); 
    rect.size.y = random(com().box_size_min.get(), com().box_size_max.get());
    boolean axe = random(10) < 5;
    float dir_mod = 0;
    if (axe && b2.rect.pos.y > 0) dir_mod = -2.5;
    if (axe && b2.rect.pos.y < 0) dir_mod = 2.5;
    if (!axe && b2.rect.pos.x > 0) dir_mod = -2.5;
    if (!axe && b2.rect.pos.x < 0) dir_mod = 2.5;
    boolean side = random(10) < 5 + dir_mod;
    if (axe) {
      if (side) {
        define_bis(b2, b2.rect.pos.x - rect.size.x - space + random(b2.rect.size.x + rect.size.x + 2*space), 
                       b2.rect.pos.y - (rect.size.y + space), "vu"); }
      else {
        define_bis(b2, b2.rect.pos.x - rect.size.x - space + random(b2.rect.size.x + rect.size.x + 2*space),
                       b2.rect.pos.y + b2.rect.size.y + space, "vd"); } }
    else {
      if (side) {  
        define_bis(b2, b2.rect.pos.x - (rect.size.x + space),
                       b2.rect.pos.y - rect.size.y - space + random(b2.rect.size.y + rect.size.y + 2*space), "hl"); }
      else {                 
        define_bis(b2, b2.rect.pos.x + b2.rect.size.x + space,
                       b2.rect.pos.y - rect.size.y - space + random(b2.rect.size.y + rect.size.y + 2*space), "hr"); } }
    return this;
  }
  
  float rotation = -0.008;
  int col = 0;
  float burst = 0;
  boolean blocked = false;
  
  Box tick() {
    for (Entity e : fcom.list) if (e.active) {
      Floc f = (Floc)e;
      if (rectCollide(f.pos, rect)) {
        this.destroy();
      }
    }
    
    if (random(100) < com().duplicate_prob.get()) {
      Box nb = com().newEntity();
      if (nb != null) {
        nb.define(this); } }
    
    float rspeed = 0.008 / generation;
    int pcol = col;
    col = 0;
    for (Entity e : com().list) if (e.active) {
      Box b = (Box)e;
      //if (col >= 1) { rotation = 0; }
      if (b != this && rectCollide(rect, b.rect, com().spacing_min.get()/2)) {//-2
        //if (col > 0 && !blocked) rotation *= 1.01;
        if (col == 0 && !blocked) rotation *= -1;
        col += 1;
        //if (col == 0 && abs(rotation) > rspeed*2) rotation = 0;
      } }
    //if (blocked) rotation -= 0.00001;
    //if (abs(rotation) > rspeed*2) { blocked = true; burst = 0.1; if (rotation < 0) burst *= -1; rotation = 0;  }
    //if (col == 0 && abs(rotation) > rspeed) rotation /= 1.01;
    if (pcol == 0) blocked = false;
    //if (blocked && rotation == 0) rotation = rspeed;
    //println(com().comList.tick.get() + " " + col + " " + rotation);
    
    PVector connect_line = new PVector(connect1.x - connect2.x, connect1.y - connect2.y); //ext co to self co
    if (origin != null && origin.active) {
      //connect2.x = origin.rect.pos.x + origin_co.x;
      //connect2.y = origin.rect.pos.y + origin_co.y;
      //PVector box_local = new PVector(rect.pos.x - connect1.x, rect.pos.y - connect1.y); //self co to box pos
      ////connect_line.rotate(rotation + burst);
      //connect1.x = connect_line.x + connect2.x;
      //connect1.y = connect_line.y + connect2.y;
      //rect.pos.x = box_local.x + connect1.x;
      //rect.pos.y = box_local.y + connect1.y;
      
      //burst /= 1.01;
    }
    return this; }
  
  Box drawing() {
    float connect_bubble_size = com().corner_space.get();
    
    
    float rd = 255.0 * (float)((10.0 - float(abs(generation - int(com().cnt/60.0)))) / 10.0);
    float stroke_limit = 1;
    if (rd <= stroke_limit) rd = 255.0 * (float)((10.0 - float(abs(generation - int((com().cnt+1200)/60.0)))) / 10.0);
    if (rd <= stroke_limit) rd = 255.0 * (float)((10.0 - float(abs(generation - int((com().cnt-1200)/60.0)))) / 10.0);
    if (rd <= stroke_limit) rd = 255.0 * (float)((10.0 - float(abs(generation - int((com().cnt+2400)/60.0)))) / 10.0);
    if (rd <= stroke_limit) rd = 255.0 * (float)((10.0 - float(abs(generation - int((com().cnt-2400)/60.0)))) / 10.0);
    //if (abs(generation - int(com().cnt/60)) < 10) 
    color filling = color(40, max(100, int(rd-20)), 0);
    float fc = max( 150, 255 - max(0, int(rd)) ) / 255.0;
    color lining = color(100*fc, 255*fc, 100*fc);
    //println(lining);
    noFill();
    stroke(lining);
    strokeWeight(max(2/cam.cam_scale.get(), connect_bubble_size/1.3));
    line(connect1.x, connect1.y, connect2.x, connect2.y);
    if (connect_bubble_size*cam.cam_scale.get() > 3) {
      fill(filling);
      stroke(lining);
      strokeWeight(4/cam.cam_scale.get());
      ellipse(connect1.x, connect1.y, connect_bubble_size, connect_bubble_size);
      ellipse(connect2.x, connect2.y, connect_bubble_size, connect_bubble_size); }
    fill(filling);
    stroke(lining);
    strokeWeight(2/cam.cam_scale.get());
    rect.draw();
    noFill();
    stroke(0, 255, 0);
    strokeWeight(3/cam.cam_scale.get());
    //rect(rect.pos.x - space/2, rect.pos.y - space/2, rect.size.x + space, rect.size.y + space);
    if (connect_bubble_size*cam.cam_scale.get() > 3) {
      fill(filling);
      noStroke();
      ellipse(connect1.x, connect1.y, connect_bubble_size, connect_bubble_size);
      ellipse(connect2.x, connect2.y, connect_bubble_size, connect_bubble_size); }
    noFill();
    stroke(filling);
    strokeWeight(max(0, connect_bubble_size/1.3 - 4/cam.cam_scale.get()));
    line(connect1.x, connect1.y, connect2.x, connect2.y);
    
    fill(lining);
    textFont(getFont(int(rect.size.y/3)));
    text(""+generation, rect.pos.x + rect.size.x/3, rect.pos.y + rect.size.y/1.41);
    return this; }
  Box clear() { return this; }
  BoxComu com() { return ((BoxComu)com); }
}


class BoxComu extends Community {
  sFlt spacing_min = new sFlt(simval, 50);
  sFlt spacing_max = new sFlt(simval, 200);
  sFlt spacing_diff = new sFlt(simval, 1);
  sFlt spacing_max_dist = new sFlt(simval, 10000);
  sFlt box_size_min = new sFlt(simval, 100);
  sFlt box_size_max = new sFlt(simval, 400);
  sFlt duplicate_prob = new sFlt(simval, 5.0);
  sFlt corner_space = new sFlt(simval, 40);
  
  //sBoo draw_circle = new sBoo(simval, false);
  
  int cnt = 0;
  
  BoxComu(Simulation _c) { super(_c, "Box ", 0); init(); }
  void custom_pre_tick() {}
  void custom_build() {
    panel.addSeparator(1)
      .addValueController("size min ", sMode.FACTOR, 2, 1.2, box_size_min)
      .addSeparator(5)
      .addValueController("size max ", sMode.FACTOR, 2, 1.2, box_size_max)
      .addSeparator(5)
      .addValueController("space min", sMode.FACTOR, 2, 1.2, spacing_min)
      .addSeparator(5)
      .addValueController("space max", sMode.FACTOR, 2, 1.2, spacing_max)
      .addSeparator(5)
      .addValueController("comu rad", sMode.FACTOR, 2, 1.2, spacing_max_dist)
      .addSeparator(5)
      .addValueController("space diff", sMode.FACTOR, 2, 1.2, spacing_diff)
      .addSeparator(5)
      .addValueController("duplic% ", sMode.FACTOR, 2, 1.2, duplicate_prob)
      .addSeparator(5)
      .addValueController("corner ", sMode.FACTOR, 2, 1.2, corner_space)
      .addSeparator(5)
      ;
      
    plane.build_panel.addDrawer(30).addButton("PARAM", 0, 0).setSize(120, 30)
      .addListener(new ControlListener() {
        public void controlEvent(final ControlEvent ev) { newMacroFlocIN1(); } } )
      .getDrawer().getPanel().addSeparator(10);
  }
  
  void newMacroFlocIN1() {
    //new MacroCUSTOM(plane).setLabel("CUSTOM").setWidth(140)
    //  .addMCsFltControl().setValue(spacing).setText("param").getMacro();
  }
  
  void custom_post_tick() { 
    cnt+=2;
    if (cnt > 2400) cnt -= 2400;
  }
  void custom_cam_draw_pre_entity() {}
  void custom_reset() { cnt = 0; }
  void custom_cam_draw_post_entity() { 
    float r = spacing_max_dist.get();  
    noFill();
    stroke(255);
    //ellipse(0, 0, r, r);
    
  }//
  
  Box build() { return new Box(this); }
  Box initialEntity() { return newEntity(); }
  Box newEntity() { 
    for (Entity e : list) if (!e.active) { e.activate(); return (Box)e; } return null; }
}
