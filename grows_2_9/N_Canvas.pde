
class CanvasPrint extends Sheet_Specialize {
  Simulation sim;
  CanvasPrint(Simulation s) { super("Canvas"); sim = s; }
  Canvas get_new(Macro_Sheet s, String n, sValueBloc b) { return new Canvas(sim, b); }
}


//#######################################################################
//##                              CANVAS                               ##
//#######################################################################


//Canvas can;

//void init_canvas() {
//  can = new Canvas(0, 0, int((width) / cam.cam_scale.get()), int((height) / cam.cam_scale.get()), 4);
//}

class Canvas extends Macro_Sheet {
  
  
  void build_custom_menu(nFrontPanel sheet_front) {
    nFrontTab tab = sheet_front.addTab("Community");
    tab.getShelf()
      .addDrawer(10.25, 0.75)
      .addModel("Label-S4", "-Canvas Control-").setFont(int(ref_size/1.4)).getShelf()
      .addSeparator(0.125)
      .addDrawerTripleButton(val_show, val_show_bound, val_show_grab, 10, 1)
      .addSeparator(0.125)
      ;
      
    selector_list = tab.getShelf(0)
      .addSeparator(0.25)
      .addList(4, 10, 1);
    selector_list.addEventChange_Builder(new Runnable() { public void run() {
      nList sl = ((nList)builder); 
      //logln("a "+sl.last_choice_index +"  "+ sim.list.size());
      if (sl.last_choice_index < sim.list.size()) 
        selected_comu(sim.list.get(sl.last_choice_index));
        //selected_com.set(sim.list.get(sl.last_choice_index).name);
    } } );
    
    selector_list.getShelf()
      .addSeparator(0.125)
      .addDrawer(10.25, 0.75)
      .addWatcherModel("Label-S4", "Selected: ").setLinkedValue(selected_com).getShelf()
      .addSeparator(0.125)
      ;
    
    selector_entry = new ArrayList<String>(); // mmain().data.getCountOfType("flt")
    selector_value = new ArrayList<Community>(); // mmain().data.getCountOfType("flt")
    
    update_com_selector_list();
    
  }
  void update_com_selector_list() {
    selector_entry.clear();
    selector_value.clear();
    for (Community v : sim.list) { 
      selector_entry.add(v.name); 
      selector_value.add(v);
    }
    if (selector_list != null) selector_list.setEntrys(selector_entry);
  }
  
  void selected_comu(Community c) { 
    if (c != null && c.type_value.get().equals("floc")) { fcom = (FlocComu)c; selected_com.set(fcom.name); }
  }
  
  FlocComu fcom;
  
  ArrayList<String> selector_entry;
  ArrayList<Community> selector_value;
  Community selected_value;
  String selected_entry;
  nList selector_list;
  
  Simulation sim;
  
  Runnable tick_run, rst_run; Drawable cam_draw;
  
  sVec val_pos;
  sInt val_w, val_h, can_div;
  sFlt val_scale;
  sBoo val_show, val_show_bound, val_show_grab;
  sStr selected_com;
  sCol val_col_back;
  
  nLinkedWidget canvas_grabber;
  
  PImage can1,can2;
  int active_can = 0;
  int can_st;
  
  Canvas(Simulation m, sValueBloc b) { 
    super(m.inter.macro_main, "Canvas", b);
    sim = m;
    
    int def_pix_size = 10;
    val_pos = newVec("val_pos", "val_pos");
    val_w = menuIntIncr(width / def_pix_size, 100, "val_w");
    val_h = menuIntIncr(height / def_pix_size, 100, "val_h");
    can_div = menuIntIncr(4, 1, "can_div");
    val_scale = menuFltSlide(def_pix_size, 1, 100, "val_scale");
    val_show = newBoo(true, "val_show", "show_canvas");
    val_show_bound = newBoo(true, "val_show_bound", "show_bound");
    val_show_grab = newBoo(true, "val_show_grab", "show_grab");
    selected_com = newStr("selected_com", "scom", "");
    val_col_back = menuColor(color(0), "background");
    val_col_back.addEventChange(new Runnable() { public void run() { 
      reset();
    } });
    
    can_st = can_div.get()-1;
    can_div.addEventChange(new Runnable() { public void run() { 
      reset();
    } });
    
    canvas_grabber = gui.theme.newLinkedWidget(gui, "MC_Grabber")
      .setLinkedValue(val_pos);
    val_show_grab.addEventChange(new Runnable() { public void run() { 
      if (val_show_grab.get()) canvas_grabber.show(); else canvas_grabber.hide();
    } });
    tick_run = new Runnable() { public void run() { tick(); } };
    rst_run = new Runnable() { public void run() { reset(); } };
    cam_draw = new Drawable() { public void drawing() { 
      drawCanvas(); } };
    
    val_w.addEventChange(rst_run);
    val_h.addEventChange(rst_run);
    
    if (sim != null) sim.addEventTick2(tick_run);
    if (sim != null) sim.inter.addToCamDrawerPile(cam_draw);
    if (sim != null) sim.addEventReset(rst_run);
    //if (sim != null) sim.reset();
    reset();
    
    addEventSetupLoad(new Runnable() { public void run() { 
      sim.inter.addEventNextFrame(new Runnable() {public void run() { 
        for (Community c : sim.list) if (c.name.equals(selected_com.get())) selected_comu(c);
        cam_draw.toLayerBottom();
      }}); } } );
  }
  
  void reset() {
    can1 = createImage(val_w.get(), val_h.get(), RGB);
    init_pim(can1);
    can2 = createImage(val_w.get(), val_h.get(), RGB);
    init_pim(can2);
    can_st = can_div.get();
    active_can = 0;
  }
  
  Canvas clear() {
    //sim.removeEventTick(tick_run);
    //sim.removeEventReset(rst_run);
    //cam_draw.clear();
    super.clear();
    return this;
  }
  
  private void init_pim(PImage canvas) {
    for(int i = 0; i < canvas.pixels.length; i++) {
      canvas.pixels[i] = val_col_back.get(); 
    }
  }
  
  private void clear_pim(PImage canvas) {
    for (int i = 0 ; i < canvas.pixels.length ; i++) {
      canvas.pixels[i] = val_col_back.get(); 
    }
  }
  
  void tick() {
    if (fcom != null) {
      for (int i = can_st ; i < fcom.list.size() ; i += max(1, can_div.get()) )
        if (fcom.list.get(i).active) {
          ((Floc)fcom.list.get(i)).draw_halo(this);
      }
    }
    if (active_can == 0) {
      if (can_st <= 0) {
        active_can = 1;
        clear_pim(can1);
        can_st = can_div.get();
      } else can_st--;
    }
    else if (active_can == 1) {
      if (can_st <= 0) {
        active_can = 0;
        clear_pim(can2);
        can_st = can_div.get();
      } else can_st--;
    }
  }
  
  void drawCanvas() {
    if (val_show_bound.get()) {

      stroke(180);
      strokeWeight(ref_size / (10 * mmain().gui.scale) );
      noFill();
      rect(val_pos.get().x, val_pos.get().y, val_w.get() * val_scale.get(), val_h.get() * val_scale.get());
    }
    if (val_show.get()) {
      if (active_can == 0) draw(can1);
      else if (active_can == 1) draw(can2);
    }
  }
  
  void draw(PImage canvas) {
    canvas.updatePixels();
    pushMatrix();
    translate(val_pos.get().x, val_pos.get().y);
    scale(val_scale.get());
    image(canvas, 0, 0);
    popMatrix();
  }
  
  void draw_halo(PVector pos, float halo_size, float halo_density, color c) {
    //walk a box of pix around entity containing the halo (pos +/- halo radius)
    for (float px = int(pos.x - halo_size) ; px < int(pos.x + halo_size) ; px+=val_scale.get())
      for (float py = int(pos.y - halo_size) ; py < int(pos.y + halo_size) ; py+=val_scale.get()) {
        PVector m = new PVector(pos.x - px, pos.y - py);
        if (m.mag() < halo_size) { //get and try distence of current pix
          //the color to add to the current pix is function of his distence to the center
          //the decreasing of the quantity of color to add is soothed
          float a = (halo_density) * soothedcurve(1.0, m.mag() / halo_size);
          if (active_can == 0) addpix(can2, px, py, color(red(c)*a, green(c)*a, blue(c)*a));
          if (active_can == 1) addpix(can1, px, py, color(red(c)*a, green(c)*a, blue(c)*a));
        }
    }
  }
  
  void addpix(PImage canvas, float x, float y, color nc) {
    //x -= int(val_scale.get() / 2);
    //y -= int(val_scale.get() / 2);
    x -= val_pos.get().x;
    y -= val_pos.get().y;
    x /= val_scale.get();
    y /= val_scale.get();
    //x += 1 / val_scale.get();
    //y += 1 / val_scale.get();
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
