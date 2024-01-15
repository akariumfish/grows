



class OrganismPrint extends Sheet_Specialize {
  Simulation sim;
  OrganismPrint(Simulation s) { super("Organism"); sim = s; }
  Organism get_new(Macro_Sheet s, String n, sValueBloc b) { return new Organism(sim, n, b); }
  Organism get_new(Macro_Sheet s, String n, Organism b) { return new Organism(sim, n, b); }
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


class Organism extends Macro_Sheet {
  
  void build_custom_menu(nFrontPanel sheet_front) {
    nFrontTab tab = sheet_front.addTab("Cursors");

    selector_list = tab.getShelf(0)
      .addSeparator(0.125)
      .addDrawer(10.25, 1)
        .addCtrlModel("Auto_Ctrl_Button-S3-P1", "new cursor")
        .setRunnable(new Runnable(this) { public void run() { 
          //nCursor nc = new nCursor(custom_tab.gui, ((Macro_Sheet)builder), 
          //                         "cursor_"+cursors_list.size(), "curs");
          //cursors_list.add(nc);
          //nc.show.set(true);
          //update_curs_selector_list();
        } } ).getShelf()
      .addDrawer(10.25, 1)
        .addLinkedModel("Auto_Ctrl_Button-S3-P1", "add cursor show")
        .setLinkedValue(adding_cursor.show).getDrawer()
        .addCtrlModel("Auto_Ctrl_Button-S3-P2", "duplicate")
        .setLinkedValue(srun_duplic).getShelf()
      .addSeparator(0.125)
      .addList(4, 10, 0.8);
    selector_list.addEventChange_Builder(new Runnable() { public void run() {
      nList sl = ((nList)builder); 
      nCursor c;
      if (sl.last_choice_index < cursors_list.size()) 
        c = cursors_list.get(sl.last_choice_index);
    } } );
    
    selector_entry = new ArrayList<String>();
    selector_value = new ArrayList<nCursor>();
    cursors_list = new ArrayList<nCursor>();
    
    selector_list.getShelf()
      .addSeparator(0.0625)
      ;
    update_curs_selector_list();
    sheet_front.toLayerTop();
  }
  void update_curs_selector_list() {
    selector_entry.clear();
    selector_value.clear();
    for (nCursor v : cursors_list) { 
      selector_entry.add(v.ref); 
      selector_value.add(v);
    }
    if (selector_list != null) selector_list.setEntrys(selector_entry);
  }

  ArrayList<nCursor> cursors_list;
  
  ArrayList<String> selector_entry;
  ArrayList<nCursor> selector_value;
  nCursor selected_cursor;
  String selected_entry;
  nList selector_list;
  
  sRun srun_duplic;
  
  Simulation sim;

  Runnable tick_run, rst_run; Drawable cam_draw;
  
  ArrayList<Cell> list = new ArrayList<Cell>(); //contien les objet

  sInt max_entity, active_entity;
  
  sFlt blarg, larg, lon, dev, shrt, branch;
  
  sCol val_fill1, val_fill2, val_stroke;
  
  nCursor adding_cursor;
  
  sRun srun_reset;
  
  Organism(Simulation _s, String n, sValueBloc b) { 
    super(_s.inter.macro_main, n, b);
    sim = _s;
    sim.organ = this;
    
    branch = menuFltFact(500, 2, "branch");
    shrt = menuFltFact(0.95, 1.02, "shortening");
    dev = menuFltFact(4, 2, "deviation");
    lon = menuFltSlide(40, 5, 400, "length");
    blarg = menuFltSlide(0.3, 0.05, 3, "base larg");
    larg = menuFltFact(1, 1.02, "large");
    
    val_stroke = menuColor(color(10, 190, 40), "val_stroke");
    val_fill2 = menuColor(color(30, 90, 20), "val_fill2");
    val_fill1 = menuColor(color(20, 130, 40), "val_fill1");
    
    max_entity = menuIntIncr(40, 100, "max_entity");
    
    organ_init();
    
    adding_cursor = new nCursor(this, n, "add");
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
    
    adding_cursor = new nCursor(this, n, "add");
    adding_cursor.pval.set(b.adding_cursor.pval.get());
    adding_cursor.pval.add(ref_size * 4, 0);
  }
  
  void organ_init() {
    
    active_entity = menuIntWatch(0, "active_entity");
    
    srun_reset = newRun("organ_reset", "reset", new Runnable() { 
      public void run() { reset(); } } );
    srun_duplic = newRun("duplication", "duplic", new Runnable() { public void run() { duplicate(); } } );
    
    tick_run = new Runnable() { public void run() { tick(); } };
    rst_run = new Runnable() { public void run() { reset(); } };
    cam_draw = new Drawable() { public void drawing() { 
      draw_All(); } };
    
    if (sim != null) sim.addEventTick(tick_run);
    if (sim != null) sim.inter.addToCamDrawerPile(cam_draw);
    if (sim != null) sim.reset();
    if (sim != null) sim.addEventReset(rst_run);
  }

  Organism clear() {
    this.destroy_All();
    sim.removeEventTick(tick_run);
    sim.removeEventReset(rst_run);
    cam_draw.clear();
    super.clear();
    return this;
  }
  
  void duplicate() {
    if (selected_cursor != null) {
      Organism m = (Organism)sheet_specialize.add_new(sim, null, this);
      m.setPosition(selected_cursor.pos().x, selected_cursor.pos().y);
    }
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
  float standard_aire = 10;
  PVector p1,p2,p3;
  void norma() {
    //float a = standard_aire; //trig aire
    //p1.mult(standard_aire/a);
    //p2.mult(standard_aire/a);
    //p3.mult(standard_aire/a);
  }
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
    face.norma();
  }
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
      
      shape.face.p1.set(1, 0);
      shape.face.p2.set(0, com().blarg.get());
      shape.face.p3.set(-1, -com().blarg.get());
    
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
        state = 2;
      }
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
