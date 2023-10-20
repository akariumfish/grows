//#######################################################################
//##                              CANVAS                               ##
//#######################################################################

Canvas can;

void init_canvas() {
  can = new Canvas(0, 0, int((width) / cam.cam_scale), int((height) / cam.cam_scale), 4);
}

class Canvas extends Callable {
  PVector pos = new PVector(0, 0);
  float canvas_scale = 1.0;
  PImage can1,can2;
  
  int active_can = 0;
  int can_div = 4;
  int can_st = can_div-1;
  
  sBoo show_canvas = new sBoo(simval, false);
  sBoo show_canvas_bound = new sBoo(simval, true);
  
  sGrabable can_grab;
  
  Canvas() { construct(0, 0, width, height, 1); }
  Canvas(float x, float y, int w, int h, float s) { construct(x, y, w, h, s); }
  
  void construct(float x, float y, int w, int h, float s) {
    w /= s; h /= s;
    can1 = createImage(w, h, RGB);
    init(can1);
    can2 = createImage(w, h, RGB);
    init(can2);
    pos.x = x - int(w) / 2;
    pos.y = y - int(h) / 2;
    can_grab = new sGrabable(cp5, x, y + 20);
    addChannel(frame_chan);
    if (show_canvas.get()) can_grab.show(); else can_grab.hide();
    canvas_scale = s;
  }
  
  
  void answer(Channel channel, float value) {
    pos = cam.screen_to_cam(can_grab.getP());
    pos.y -= 20 / cam.cam_scale;
  }
  
  void drawHalo(Community com) {
    if (active_can == 0) {
      for (int i = can_st ; i < com.list.size() ; i += can_div)
        if (com.list.get(i).active) {
          com.list.get(i).draw_halo(this, can2);
      }
      if (can_st == 0) {
        active_can = 1;
        clear(can1);
        can_st = can_div - 1;
      } else can_st--;
    }
    else if (active_can == 1) {
      for (int i = can_st ; i < com.list.size() ; i += can_div)
        if (com.list.get(i).active) {
          com.list.get(i).draw_halo(this, can1);
      }
      if (can_st == 0) {
        active_can = 0;
        clear(can2);
        can_st = can_div - 1;
      } else can_st--;
    }
  }
  
  void drawCanvas() {
    if (show_canvas.get()) {
      if (show_canvas_bound.get()) {
        stroke(255);
        strokeWeight(3 / cam.cam_scale);
        noFill();
        rect(pos.x, pos.y, can1.width * canvas_scale, can1.height * canvas_scale);
      }
      if (active_can == 0) draw(can1);
      else if (active_can == 1) draw(can2);
    }
  }
  
  private void init(PImage canvas) {
    for(int i = 0; i < canvas.pixels.length; i++) {
      canvas.pixels[i] = color(0); 
    }
  }
  
  void clear(PImage canvas) {
    for (int i = 0 ; i < canvas.pixels.length ; i++) {
      canvas.pixels[i] = color(0);
    }
  }
  
  void draw(PImage canvas) {
    canvas.updatePixels();
    pushMatrix();
    translate(pos.x, pos.y);
    scale(canvas_scale);
    image(canvas, 0, 0);
    popMatrix();
  }
  
  void addpix(PImage canvas, float x, float y, color nc) {
    x += canvas_scale/2;
    y += canvas_scale/2;
    x -= pos.x;
    y -= pos.y;
    x /= canvas_scale;
    y /= canvas_scale;
    if (x < 0 || y < 0 || x > canvas.width || y > canvas.height) return;
    int pi = canvas.width * int(y) + int(x);
    if (pi >= 0 && pi < canvas.pixels.length) {
      color oc = canvas.pixels[pi];
      canvas.pixels[pi] = color(min(255, red(oc) + red(nc)), min(255, green(oc) + green(nc)), min(255, blue(oc) + blue(nc)));
    }
  }
  //color getpix(PImage canvas, PVector v) { return getpix(canvas, v.x, v.y); }
  //color getpix(PImage canvas, float x, float y) {
  //  color co = 0;
  //  int pi = canvas.width * int(y + canvas.height / 2) + int(x + canvas.width/2);
  //  if (pi >= 0 && pi < canvas.pixels.length) {
  //    co = canvas.pixels[pi];
  //  }
  //  return co;
  //}
  //void setpix(PImage canvas, PVector v, color c) { setpix(canvas, v.x, v.y, c); }
  //void setpix(PImage canvas, float x, float y, color c) {
  //  int pi = canvas.width * int(y + canvas.height / 2) + int(x + canvas.width/2);
  //  if (pi >= 0 && pi < canvas.pixels.length) {
  //    canvas.pixels[pi] = c;
  //  }
  //}
  
  //void canvas_croix(PImage canvas, float x, float y, int c) {
  //  color co = getpix(canvas, x, y);
  //  setpix(canvas, x, y, color(c + red(co)) );
  //  setpix(canvas, x + 1, y, color(c/2 + red(co)) );
  //  setpix(canvas, x - 1, y, color(c/2 + red(co)) );
  //  setpix(canvas, x, y + 1, color(c/2 + red(co)) );
  //  setpix(canvas, x, y - 1, color(c/2 + red(co)) );
  //}
  
  //void canvas_line(PImage canvas, PVector v1, PVector v2, int c) {
  //  PVector m = new PVector(v1.x - v2.x, v1.y - v2.y);
  //  int l = int(m.mag());
  //  m.setMag(-1);
  //  PVector p = new PVector(v1.x, v1.y);
  //  for (int i = 0 ; i < l ; i++) {
  //    color co = getpix(canvas, p.x, p.y);
  //    setpix(canvas, p.x, p.y, color(c + red(co)) );
  //    p.add(m);
  //  }
  //}
}
