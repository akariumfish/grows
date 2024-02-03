





class FacePrint extends Sheet_Specialize {
  Canvas sim;
  FacePrint(Canvas s) { super("Face"); sim = s; }
  Face get_new(Macro_Sheet s, String n, sValueBloc b) { return new Face(sim, b); }
}



class Face extends Macro_Sheet {
  nWidget graph;
  Drawable g_draw;
  
  void build_custom_menu(nFrontPanel sheet_front) {
    if (sheet_front != null) {
      
      nDrawer dr = sheet_front.getTab(2).getShelf()
        .addSeparator(0.125)
        .addDrawerFactValue(val_dens, 2, 10, 1)
        .addSeparator(0.125)
        .addDrawerFactValue(val_disp, 2, 10, 1)
        .addSeparator(0.125)
        .addDrawerDoubleButton(val_halo_type, val_halo_type2, 10, 1)
        .addSeparator(0.125)
        .addDrawer(10.25, 6.25);
      
      graph = dr.addModel("Field");
      graph.setPosition(ref_size * 2, ref_size * 2 / 16)
        .setSize(ref_size * 6, ref_size * 6);
      
      g_draw = new Drawable(sheet_front.gui.drawing_pile, 0) { public void drawing() {
        fill(graph.look.standbyColor);
        noStroke();
        rect(graph.getX(), graph.getY(), graph.getSX(), graph.getSY());
        pushMatrix();
        translate(graph.getX() + graph.getSX()/2 - shape.pos.x, 
                  graph.getY() + graph.getSY()/2 - shape.pos.y);
        float hm = shape.dir.mag();
        float thm = hm;
        if (shape.nrad() > 2) thm = thm / (shape.nrad() / 2);
        shape.dir.setMag(thm/4);
        shape.draw();
        shape.dir.setMag(hm);
        strokeWeight(3);
        stroke(255);
        float fac = 1.2 * 100 / val_scale.get();
        line(shape.pos.x,shape.pos.y,shape.pos.x + shape.dir.x*fac,shape.pos.y + shape.dir.y*fac);
        stroke(180);
        line(shape.pos.x,shape.pos.y,shape.pos.x - shape.dir.x*fac,shape.pos.y - shape.dir.y*fac);
        popMatrix();
      } };
      graph.setDrawable(g_draw);
      
      dr.addLinkedModel("Field").setLinkedValue(vpax).setPosition(ref_size * 2 / 16, ref_size * (0+(4.0/16)))
        .setSize(ref_size * 1.75, ref_size * 0.75);
      dr.addLinkedModel("Field").setLinkedValue(vpay).setPosition(ref_size * 2 / 16, ref_size * (1+(4.0/16)))
        .setSize(ref_size * 1.75, ref_size * 0.75);
      dr.addLinkedModel("Field").setLinkedValue(vpbx).setPosition(ref_size * 2 / 16, ref_size * (2+(4.0/16)))
        .setSize(ref_size * 1.75, ref_size * 0.75);
      dr.addLinkedModel("Field").setLinkedValue(vpby).setPosition(ref_size * 2 / 16, ref_size * (3+(4.0/16)))
        .setSize(ref_size * 1.75, ref_size * 0.75);
      dr.addLinkedModel("Field").setLinkedValue(vpcx).setPosition(ref_size * 2 / 16, ref_size * (4+(4.0/16)))
        .setSize(ref_size * 1.75, ref_size * 0.75);
      dr.addLinkedModel("Field").setLinkedValue(vpcy).setPosition(ref_size * 2 / 16, ref_size * (5+(4.0/16)))
        .setSize(ref_size * 1.75, ref_size * 0.75);
      
      sheet_front.addEventClose(new Runnable(this) { public void run() { 
        graph = null; g_draw.clear(); g_draw = null; } } );
      sheet_front.toLayerTop();
    }
  }
  
  Canvas can;
  nBase shape;
  nCursor ref_cursor;
  sFlt val_scale, vpax, vpay, vpbx, vpby, vpcx, vpcy, val_linew, val_dens, val_disp;
  sCol val_fill, val_stroke;
  sInt val_draw_layer;
  sBoo val_halo_type, val_halo_type2;
  
  
  ArrayList<nCursor> duplication_cursors = new ArrayList<nCursor>();
  
  Face(Canvas m, sValueBloc b) { 
    super(m.mmain(), "Face", b);
    can = m;
    can.faces.add(this);
    can.sim.faces.add(this);
    shape = new nBase();
    val_draw_layer = menuIntIncr(0, 1, "val_draw_layer");
    val_scale = menuFltSlide(100, 10, 400, "scale");
    val_linew = menuFltSlide(0.05, 0.01, 0.2, "line_weight");
    shape.line_w = val_linew.get();
    val_dens = newFlt(0.5, "val_dens", "val_dens");
    val_disp = newFlt(5, "val_disp", "val_disp");
    val_halo_type = newBoo(false, "val_halo_type", "val_halo_type");
    val_halo_type2 = newBoo(false, "val_halo_type2", "val_halo_type2");
    vpax = newFlt(shape.face.p1.x, "vpax", "vpax");
    vpay = newFlt(shape.face.p1.y, "vpay", "vpay");
    vpbx = newFlt(shape.face.p2.x, "vpbx", "vpbx");
    vpby = newFlt(shape.face.p2.y, "vpby", "vpby");
    vpcx = newFlt(shape.face.p3.x, "vpcx", "vpcx");
    vpcy = newFlt(shape.face.p3.y, "vpcy", "vpcy");
    
    vpax.addEventChange(new Runnable() { public void run() { shape.face.p1.x = vpax.get(); }});
    vpay.addEventChange(new Runnable() { public void run() { shape.face.p1.y = vpay.get(); }});
    vpbx.addEventChange(new Runnable() { public void run() { shape.face.p2.x = vpbx.get(); }});
    vpby.addEventChange(new Runnable() { public void run() { shape.face.p2.y = vpby.get(); }});
    vpcx.addEventChange(new Runnable() { public void run() { shape.face.p3.x = vpcx.get(); }});
    vpcy.addEventChange(new Runnable() { public void run() { shape.face.p3.y = vpcy.get(); }});
    
    val_stroke = menuColor(color(10, 190, 40), "val_stroke");
    val_fill = menuColor(color(30, 90, 20), "val_fill");
    val_stroke.addEventChange(new Runnable() { public void run() { shape.col_line = val_stroke.get(); }});
    val_fill.addEventChange(new Runnable() { public void run() { shape.col_fill = val_fill.get(); }});
    
    val_scale.addEventChange(new Runnable() { public void run() { shape.dir.setMag(val_scale.get()); }});
    val_linew.addEventChange(new Runnable() { public void run() { shape.line_w = val_linew.get(); }});
    
    ref_cursor = menuCursor("center", true);
    //ref_cursor.show.set(true);
    if (ref_cursor.pval != null) ref_cursor.pval.addEventChange(new Runnable() { public void run() { 
      shape.pos.set(ref_cursor.pval.get()); }});
    if (ref_cursor.dval != null) ref_cursor.dval.addEventChange(new Runnable() { public void run() {
      shape.dir.set(shape.dir.mag(), 0);
      shape.dir.rotate(ref_cursor.dval.get().heading());
    }});
  }
  
  void tick() {
    if (!val_halo_type.get()) {
      if (!val_halo_type2.get()) {
        can.draw_halo(shape.pos, val_scale.get()*val_disp.get(), val_dens.get(), val_fill.get());
      } else { can.draw_halo(shape.pos, val_scale.get()*val_disp.get(), val_dens.get(), val_fill.get()); }
    } else { 
      if (!val_halo_type2.get()) {
        can.draw_shape_line(shape, val_scale.get()*val_disp.get(), val_dens.get(), val_stroke.get());
      } else { can.draw_shape_fill(shape, val_scale.get()*val_disp.get(), val_dens.get(), val_fill.get()); }
    }
  }
  
  void draw() { shape.draw(); }
  
  Face clear() {
    can.faces.remove(this);
    can.sim.faces.remove(this);
    super.clear();
    return this;
  }
}



//#######################################################################
//##                              CANVAS                               ##
//#######################################################################

class CanvasPrint extends Sheet_Specialize {
  Simulation sim;
  CanvasPrint(Simulation s) { super("Canvas"); sim = s; }
  Canvas get_new(Macro_Sheet s, String n, sValueBloc b) { return new Canvas(sim, b); }
}

class Canvas extends Macro_Sheet {
  
  ArrayList<Face> faces = new ArrayList<Face>();
  
  void build_custom_menu(nFrontPanel sheet_front) {
    nFrontTab tab = sheet_front.addTab("Community");
    tab.getShelf()
      .addDrawer(10.25, 0.75)
      .addModel("Label-S4", "-Canvas Control-").setFont(int(ref_size/1.4)).getShelf()
      .addSeparator(0.125)
      .addDrawerDoubleButton(val_show, val_show_bound, 10, 1)
      .addSeparator(0.125)
      .addDrawerDoubleButton(val_rst_run, val_show_grab, 10, 1)
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
    
    sheet_front.toLayerTop();
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
  nCursor ref_cursor;
  
  sVec val_pos;
  sInt val_w, val_h, can_div;
  sFlt val_scale, color_keep_thresh, val_decay;
  sBoo val_show, val_show_bound, val_show_grab;
  sStr selected_com;
  sCol val_col_back;
  sRun val_rst_run;
  
  //nLinkedWidget canvas_grabber;
  
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
    val_scale = menuFltSlide(def_pix_size, 10, 500, "val_scale");
    color_keep_thresh = menuFltSlide(200, 10, 260, "clrkeep_thresh");
    val_decay = menuFltSlide(1, 0.99, 1.01, "decay");
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
    
    val_show_grab.addEventChange(new Runnable() { public void run() { 
      if (ref_cursor.show != null) ref_cursor.show.set(val_show.get() && val_show_grab.get());
    } });
    val_show.addEventChange(new Runnable() { public void run() { 
      if (ref_cursor.show != null) ref_cursor.show.set(val_show.get() && val_show_grab.get());
    } });
    
    ref_cursor = menuCursor("Canvas", false);
    if (ref_cursor.show != null) ref_cursor.show.set(val_show.get() && val_show_grab.get());
    if (ref_cursor.pval != null) ref_cursor.pval.set(val_pos.get());
    if (ref_cursor.pval != null) ref_cursor.pval.addEventChange(new Runnable() { public void run() { 
      val_pos.set(ref_cursor.pval.get()); }});
    val_pos.addEventChange(new Runnable() { public void run() { 
      if (ref_cursor.pval != null) ref_cursor.pval.set(val_pos.get()); }});
    
    tick_run = new Runnable() { public void run() { tick(); } };
    rst_run = new Runnable() { public void run() { reset(); } };
    cam_draw = new Drawable() { public void drawing() { 
      drawCanvas(); } };
    val_rst_run = newRun("val_rst_run", "rst_run", rst_run);
    
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
  
  float sat(color c) {
    return (red(c) + green(c) + blue(c)) / 3; 
  }
  
  color decay(color c) {
    return color(red(c)*val_decay.get(), green(c)*val_decay.get(), blue(c)*val_decay.get()); 
  }
  
  private void clear_pim(PImage canvas) {
    for (int i = 0 ; i < canvas.pixels.length ; i++) {
      if (sat(canvas.pixels[i]) < color_keep_thresh.get()) canvas.pixels[i] = val_col_back.get(); 
      else canvas.pixels[i] = decay(canvas.pixels[i]);
    }
  }
  private void med_pim(PImage canvas1, PImage canvas2) {
    for (int i = 0 ; i < canvas1.pixels.length ; i++) {
      color c = color( (red(canvas1.pixels[i]) + red(canvas2.pixels[i])) / 2.0, 
                       (green(canvas1.pixels[i]) + green(canvas2.pixels[i])) / 2.0, 
                       (blue(canvas1.pixels[i]) + blue(canvas2.pixels[i])) / 2.0 );
      canvas1.pixels[i] = c;
      canvas2.pixels[i] = c;
    }
  }
  
  void tick() {
    if (fcom != null) {
      for (int i = can_st ; i < fcom.list.size() ; i += max(1, can_div.get()) )
        if (fcom.list.get(i).active) {
          ((Floc)fcom.list.get(i)).draw_halo(this);
      }
    }
    
    for (Face f : faces) f.tick();
    
    if (active_can == 0) {
      if (can_st <= 0) {
        active_can = 1;
        med_pim(can1, can2);
        clear_pim(can1);
        can_st = can_div.get();
      } else can_st--;
    }
    else if (active_can == 1) {
      if (can_st <= 0) {
        active_can = 0;
        med_pim(can1, can2);
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
    
    //done in sim
    //if (faces.size() > 0) {
    //  int min = faces.get(0).val_draw_layer.get(), max = min;
    //  for (Face f : faces) {
    //    min = min(min, f.val_draw_layer.get()); max = max(max, f.val_draw_layer.get()); }
    //  for (int i = min ; i <= max ; i++)
    //  for (Face f : faces) if (f.val_draw_layer.get() == i) f.draw();
    //}
  }
  
  void draw(PImage canvas) {
    canvas.updatePixels();
    pushMatrix();
    translate(val_pos.get().x, val_pos.get().y);
    scale(val_scale.get());
    image(canvas, 0, 0);
    popMatrix();
  }
  
  void draw_shape_fill(nBase sh, float halo_size, float halo_density, color c) {
    for (float px = int(sh.pos.x - sh.rad() - halo_size) ; 
         px < int(sh.pos.x + sh.rad() + halo_size) ; px+=val_scale.get())
      for (float py = int(sh.pos.y - sh.rad() - halo_size) ; 
           py < int(sh.pos.y + sh.rad() + halo_size) ; py+=val_scale.get()) {
      PVector p = new PVector(px, py);
      float l1 = distancePointToLine(px, py, sh.p1().x, sh.p1().y, sh.p2().x, sh.p2().y);
      float l2 = distancePointToLine(px, py, sh.p3().x, sh.p3().y, sh.p2().x, sh.p2().y);
      float l3 = distancePointToLine(px, py, sh.p1().x, sh.p1().y, sh.p3().x, sh.p3().y);
      float m = min(l1, l2, l3);
      if (point_in_trig(sh.p1(), sh.p2(), sh.p3(), p)) m = 0;
      if (m < halo_size) { //get and try distence of current pix
        //the color to add to the current pix is function of his distence to the center
        //the decreasing of the quantity of color to add is soothed
        float a = (halo_density) * soothedcurve(1.0, m / halo_size);
        if (active_can == 0) addpix(can2, px, py, color(red(c)*a, green(c)*a, blue(c)*a));
        if (active_can == 1) addpix(can1, px, py, color(red(c)*a, green(c)*a, blue(c)*a));
      }
    }
  }
  void draw_shape_line(nBase sh, float halo_size, float halo_density, color c) {
    for (float px = int(sh.pos.x - sh.rad() - halo_size) ; 
         px < int(sh.pos.x + sh.rad() + halo_size) ; px+=val_scale.get())
      for (float py = int(sh.pos.y - sh.rad() - halo_size) ; 
           py < int(sh.pos.y + sh.rad() + halo_size) ; py+=val_scale.get()) {
      
      float l1 = distancePointToLine(px, py, sh.p1().x, sh.p1().y, sh.p2().x, sh.p2().y);
      float l2 = distancePointToLine(px, py, sh.p3().x, sh.p3().y, sh.p2().x, sh.p2().y);
      float l3 = distancePointToLine(px, py, sh.p1().x, sh.p1().y, sh.p3().x, sh.p3().y);
      float m = min(l1, l2, l3);
      if (m < halo_size) { //get and try distence of current pix
        //the color to add to the current pix is function of his distence to the center
        //the decreasing of the quantity of color to add is soothed
        float a = (halo_density) * soothedcurve(1.0, m / halo_size);
        if (active_can == 0) addpix(can2, px, py, color(red(c)*a, green(c)*a, blue(c)*a));
        if (active_can == 1) addpix(can1, px, py, color(red(c)*a, green(c)*a, blue(c)*a));
      }
    }
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
      canvas.pixels[pi] = color(min(255, max(red(oc), red(nc))), 
                                min(255, max(green(oc),green(nc))), 
                                min(255, max(blue(oc), blue(nc))) );
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











/*
organism
  cell group limited in size
  different etat influence les stat global de l'organisme > preset
  l'etat depand de la situation majoritaire des cells 
    > condition du type "+ de x% des cell sont dans tel etat"

cell
  shape
  spacialization
  different etat / situation constitue le cicle de vie
    condition de changement
    consequance sur les variables
      element graphique
      feedback ?
  ex:
    evenement : naissance
    etat : croissance
    evenement : produit une cell  /  stop croissance   /  fleurie
    etats :     static            /  static            /  bloom
    evenement : meur (rng)        /  produit une cell  /  stop croissance
    etats :     dead              /  static            /  static
    evenement :                   /  meur (age)        /  meur (age)
    etats :     dead              /  dead              /  dead

shape interaction
  slowed down, 

*/


class OrganismPrint extends Sheet_Specialize {
  Simulation sim;
  OrganismPrint(Simulation s) { super("Organism"); sim = s; }
  Organism get_new(Macro_Sheet s, String n, sValueBloc b) { return new Organism(sim, n, b); }
  Organism get_new(Macro_Sheet s, String n, Organism b) { return new Organism(sim, n, b); }
}

class Organism extends Macro_Sheet {
  
  void build_custom_menu(nFrontPanel sheet_front) {
    if (sheet_front != null) {
      
      sheet_front.getTab(2).getShelf()
        .addSeparator(0.125)
        .addDrawerButton(adding_cursor.show, 10, 1)
        .addSeparator(0.125);
        
      sheet_front.toLayerTop();
    }
  }

  sRun srun_duplic;
  
  Simulation sim;

  Runnable tick_run, rst_run; //Drawable cam_draw;
  
  ArrayList<Cell> list = new ArrayList<Cell>(); //contien les objet

  sInt max_entity, active_entity;
  
  sFlt blarg, larg, lon, dev, shrt, branch;
  
  sCol val_fill1, val_fill2, val_stroke;
  
  sInt val_draw_layer;
  
  nCursor adding_cursor;
  
  sRun srun_reset;
  
  sObj face_obj;
  
  Face face_source;
  
  Organism(Simulation _s, String n, sValueBloc b) { 
    super(_s.inter.macro_main, n, b);
    sim = _s;
    sim.organs.add(this);
    
    branch = menuFltFact(10, 2, "branch");
    shrt = menuFltFact(0.95, 1.02, "shortening");
    dev = menuFltFact(4, 2, "deviation");
    lon = menuFltSlide(40, 5, 400, "length");
    blarg = menuFltSlide(0.3, 0.05, 3, "base larg");
    larg = menuFltFact(1, 1.02, "large");
    
    val_draw_layer = menuIntIncr(0, 1, "val_draw_layer");
    
    val_stroke = menuColor(color(10, 190, 40), "val_stroke");
    val_fill2 = menuColor(color(30, 90, 20), "val_fill2");
    val_fill1 = menuColor(color(20, 130, 40), "val_fill1");
    
    max_entity = menuIntIncr(40, 100, "max_entity");
    
    organ_init();
    
    adding_cursor = menuCursor("add", true);
    
  }
  Organism(Simulation _s, String n, Organism b) { 
    super(_s.inter.macro_main, n, null);
    
    sim = _s;
    branch = menuFltFact(b.branch.get(), 2, "branch");
    shrt = menuFltFact(b.shrt.get(), 1.02, "shortening");
    dev = menuFltFact(b.dev.get(), 2, "deviation");
    lon = menuFltSlide(b.lon.get(), 5, 400, "length");
    blarg = menuFltSlide(b.blarg.get(), 5, 400, "base larg");
    larg = menuFltFact(b.larg.get(), 1.02, "large");
    
    val_stroke = menuColor(b.val_stroke.get(), "val_stroke");
    val_fill2 = menuColor(b.val_fill2.get(), "val_fill2");
    val_fill1 = menuColor(b.val_fill1.get(), "val_fill1");
    
    max_entity = menuIntIncr(b.max_entity.get(), 100, "max_entity");
    
    organ_init();
    
    adding_cursor = menuCursor("add", true);
    adding_cursor.pval.set(b.adding_cursor.pval.get());
    adding_cursor.pval.add(ref_size * 4, 0);
  }
  
  void organ_init() {
    
    face_obj = newObj("face_obj", "face_obj");
    face_obj.addEventChange(new Runnable() { public void run() {
      if (face_obj.isSheet()) {
        Macro_Sheet ms = face_obj.asSheet();
        if (ms.specialize.get().equals("Face")) face_source = (Face)ms;
      }
    }});
    
    
    active_entity = menuIntWatch(0, "active_entity");
    
    srun_reset = newRun("organ_reset", "reset", new Runnable() { 
      public void run() { reset(); } } );
    srun_duplic = newRun("duplication", "duplic", new Runnable() { public void run() { duplicate(); } } );
    
    tick_run = new Runnable() { public void run() { tick(); } };
    rst_run = new Runnable() { public void run() { reset(); } };
    //cam_draw = new Drawable() { public void drawing() { 
    //  draw_All(); } };
    
    if (sim != null) sim.addEventTick(tick_run);
    //if (sim != null) sim.inter.addToCamDrawerPile(cam_draw);
    if (sim != null) sim.reset();
    if (sim != null) sim.addEventReset(rst_run);
  }

  Organism clear() {
    sim.organs.remove(this);
    this.destroy_All();
    sim.removeEventTick(tick_run);
    sim.removeEventReset(rst_run);
    //cam_draw.clear();
    super.clear();
    return this;
  }
  
  void duplicate() {
    //if (selected_cursor != null) {
    //  Organism m = (Organism)sheet_specialize.add_new(sim, null, this);
    //  m.setPosition(selected_cursor.pos().x, selected_cursor.pos().y);
    //}
  }
  
  void init_array() {
    list.clear();
    for (int i = 0; i < max_entity.get(); i++)
      list.add(build());
  }

  void reset() { //deactivate all then create starting situation from parameters
    this.destroy_All();
    if (max_entity.get() != list.size()) init_array();
    
    Cell c = newEntity(null);
    
  }

  void tick() {
    active_entity.set(active_Entity_Nb());
    for (Cell e : list) if (e.active) e.tick();
    
  }

  void draw_All() { 
    for (Cell e : list) if (e.active) e.draw(); }
  void destroy_All() { 
    for (Cell e : list) e.destroy(); }

  int active_Entity_Nb() {
    int n = 0;
    for (Cell e : list) if (e.active) n++;
    return n;
  }
  Cell build() { 
    return new Cell(this);
  }
  Cell newEntity(Cell p) {
    Cell ng = null;
    for (Cell e : list) 
      if (!e.active && ng == null) { 
        ng = (Cell)e; 
        e.activate();
      }
    if (ng != null) ng.define(p);
    return ng;
  }
}




/*
class nface
  3 coordinate
  should all have the same surface!!
  
nShape spacialization:
  pos, dir, scale, mirroring
  
nBase 
  an exemple
*/




class nFace {
  //float standard_aire = 10;
  PVector p1,p2,p3;
  //void norma() {
  //  float a = standard_aire; //trig aire
  //  p1.mult(standard_aire/a);
  //  p2.mult(standard_aire/a);
  //  p3.mult(standard_aire/a);
  //}
}

abstract class nShape {
  PVector pos = new PVector(0, 0);
  PVector dir = new PVector(10, 0); //heading : rot , mag : scale
  boolean do_fill = true, do_stroke = true;
  color col_fill = color(20, 130, 40), col_line = color(10, 190, 40);
  float line_w = 0.01;
  void draw() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(dir.heading());
    scale(dir.mag());
    if (do_fill) fill(col_fill); else noFill(); 
    if (do_stroke) stroke(col_line); else noStroke(); strokeWeight(line_w);
    
    drawcall();
    
    popMatrix();
  }
  abstract void drawcall();
}

class nBase extends nShape {
  nFace face;    
  nBase() {
    face = new nFace();
    face.p1 = new PVector(1, 0);
    face.p2 = new PVector(0, 0.3);
    face.p3 = new PVector(-1, -0.3);
    //face.norma();
  }
  float nrad() {
    return max(max(face.p1.mag(), face.p2.mag()), face.p3.mag()); }
  float rad() {
    return dir.mag() * max(max(face.p1.mag(), face.p2.mag()), face.p3.mag()); }
  PVector p1() { 
    PVector p = new PVector(face.p1.x, face.p1.y);
    p.rotate(dir.heading()); p.setMag(face.p1.mag()*dir.mag()); p.add(pos);
    return p; }
  PVector p2() { 
    PVector p = new PVector(face.p2.x, face.p2.y);
    p.rotate(dir.heading()); p.setMag(face.p2.mag()*dir.mag()); p.add(pos);
    return p; }
  PVector p3() { 
    PVector p = new PVector(face.p3.x, face.p3.y);
    p.rotate(dir.heading()); p.setMag(face.p3.mag()*dir.mag()); p.add(pos);
    return p; }
  void drawcall() {
    triangle(face.p1.x, face.p1.y, face.p2.x, face.p2.y, face.p3.x, face.p3.y);
  }
}

class Cell {
  
  nBase shape;

  Organism com;
  int age = 0;
  boolean active = false;
  
  int state = 0;
  Cell(Organism c) { 
    com = c;
  }
  Cell clear() { 
    return this;
  }
  Cell activate() {
    if (!active) { 
      active = true; 
      age = 0; 
      state = 0;
      shape = new nBase();
      if (com().face_source != null) {
        nBase fb = com().face_source.shape;
        shape.face.p1.set(fb.face.p1.x, fb.face.p1.y * com().blarg.get());
        shape.face.p2.set(fb.face.p2.x, fb.face.p2.y * com().blarg.get());
        shape.face.p3.set(fb.face.p3.x, fb.face.p3.y * com().blarg.get());
      } else {
        shape.face.p1.set(1, 0);
        shape.face.p2.set(0, com().blarg.get());
        shape.face.p3.set(-1, -com().blarg.get());
      }
      shape.dir.setMag(com().lon.get());
      float inf = float(com().active_entity.get()) / float(com().max_entity.get());
      float inf2 = (float(com().max_entity.get()) - float(com().active_entity.get())) / 
                   float(com().max_entity.get());
      float re = (com().val_fill2.getred() * inf + com().val_fill1.getred() * inf2) / 1.0;
      float gr = (com().val_fill2.getgreen() * inf + com().val_fill1.getgreen()* inf2) / 1.0;
      float bl = (com().val_fill2.getblue() * inf + com().val_fill1.getblue() * inf2) / 1.0;
      shape.col_fill = color(re, gr, bl);
      shape.col_line = com().val_stroke.get();
    }
    return this;
  }
  Cell destroy() {
    if (active) { 
      active = false; 
      clear();
    }
    return this;
  }
  Cell define(Cell p) {
    if (p != null) {
      PVector _p = p.shape.pos;
      PVector _d = p.shape.dir;
      shape.pos.x = _p.x + _d.x;
      shape.pos.y = _p.y + _d.y;
      shape.dir.set(_d);
      shape.dir.rotate(random(-HALF_PI/com().dev.get(), HALF_PI/com().dev.get()));
      shape.dir.setMag(shape.dir.mag() * random(min(com().shrt.get(), 1), max(com().shrt.get(), 1)) );
      
      shape.face.p2.set(p.shape.face.p2.x, - p.shape.face.p2.y / com().larg.get());
      shape.face.p3.set(p.shape.face.p3.x, - p.shape.face.p3.y / com().larg.get());
    } else if (com().adding_cursor != null) {
      shape.pos.x = com().adding_cursor.pos().x;
      shape.pos.y = com().adding_cursor.pos().y;
      float dm = shape.dir.mag();
      shape.dir.set(com().adding_cursor.dir());
      shape.dir.rotate(random(-HALF_PI/com().dev.get(), HALF_PI/com().dev.get()));
      shape.dir.setMag(dm * shape.dir.mag() * random(min(com().shrt.get(), 1), max(com().shrt.get(), 1)) );
    }
    return this;
  }
  Cell tick() {
    age++;
    if (state == 0) {
      if (age == 2) {
        com().newEntity(this);
        state = 1;
      }
    } else if (state == 1) {
      if (crandom(com().branch.get()) > 0.5) {
        com().newEntity(this);
        //nCursor c = com().newCursor("branch_"+com().cursor_count, true);
        //c.pval.set(shape.pos.x + shape.dir.x, shape.pos.y + shape.dir.y);
        //c.dval.set(shape.dir.x, shape.dir.y);
        //c.show.set(true);
      }
      state = 2;
    } else if (state == 2) {
      
    }
    return this;
  }
  Cell draw() {
    shape.draw();
    return this;
  }
  Organism com() { 
    return ((Organism)com);
  }
}








      
  
