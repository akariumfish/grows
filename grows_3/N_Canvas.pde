





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
        .addDrawerButton(ref_cursor.show, 10, 1)
        .addSeparator(0.125)
        .addDrawerFactValue(val_dens, 2, 10, 1)
        .addSeparator(0.125)
        .addDrawerFactValue(val_disp, 2, 10, 1)
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
        shape.dir.setMag(hm/4);
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
  
  Face(Canvas m, sValueBloc b) { 
    super(m.mmain(), "Face", b);
    can = m;
    can.faces.add(this);
    shape = new nBase();
    val_scale = menuFltSlide(100, 10, 400, "scale");
    val_linew = menuFltSlide(0.05, 0.01, 0.2, "line_weight");
    shape.line_w = val_linew.get();
    val_dens = newFlt(0.5, "val_dens", "val_dens");
    val_disp = newFlt(5, "val_disp", "val_disp");
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
    ref_cursor = new nCursor(this, "center", "center");
    //ref_cursor.show.set(true);
    ref_cursor.pval.addEventChange(new Runnable() { public void run() { 
      shape.pos.set(ref_cursor.pval.get()); }});
    ref_cursor.dval.addEventChange(new Runnable() { public void run() {
      shape.dir.set(shape.dir.mag(), 0);
      shape.dir.rotate(ref_cursor.dval.get().heading());
    }});
  }
  
  void tick() {
    can.draw_halo(shape.pos, val_scale.get()*val_disp.get(), val_dens.get(), val_fill.get());
  }
  
  void draw() { shape.draw(); }
  
  Face clear() {
    can.faces.remove(this);
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
  sFlt val_scale, color_keep_thresh;
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
      ref_cursor.show.set(val_show.get() && val_show_grab.get());
    } });
    val_show.addEventChange(new Runnable() { public void run() { 
      ref_cursor.show.set(val_show.get() && val_show_grab.get());
    } });
    
    ref_cursor = new nCursor(this, "center", "center");
    ref_cursor.show.set(val_show.get() && val_show_grab.get());
    ref_cursor.pval.set(val_pos.get());
    ref_cursor.pval.addEventChange(new Runnable() { public void run() { 
      val_pos.set(ref_cursor.pval.get()); }});
    val_pos.addEventChange(new Runnable() { public void run() { 
      ref_cursor.pval.set(val_pos.get()); }});
    
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
  
  private void clear_pim(PImage canvas) {
    for (int i = 0 ; i < canvas.pixels.length ; i++) {
      if (sat(canvas.pixels[i]) < color_keep_thresh.get()) canvas.pixels[i] = val_col_back.get(); 
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
    for (Face f : faces) f.draw();
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








  
