





//objet de base des bloc macro

/*
peut etre contenue dans un bloc parent et contenir des enfant
a une liste d'entre sortie connectable entre eux
peut s'attacher une connection presente dans l'espace du bloc parent
a des widget pour etre bouger (grabber) et detruit 
a des widget invisible comme ref de position pour les connection et les widget custom
a un widget en background
*/

abstract class Macro_Abstract {
  
  ArrayList<Macro_Input> extinputs = new ArrayList<Macro_Input>(0);
  ArrayList<Macro_Output> extoutputs = new ArrayList<Macro_Output>(0);
  
  Macro_Sheet parent;
  
  nGUI gui;
  
  float macro_size = 40;
  int layer = 0;
  nWidget grabber, inputs_ref, outputs_ref, panel, back, closer, front;
  
  float sheet_width = macro_size;
  String name = null;
  
  boolean isHided = false;
  
  
  void parentReduc() {
    hide();
  }
  void parentEnlarg() {
    show();
  }
  
  Macro_Abstract(nGUI _gui, Macro_Sheet p, String n, float x, float y) {
    gui = _gui;
    parent = p;
    name = n;
    if (parent != null) parent.child_macro.add(this);
    
    grabber = new nWidget(gui, name, int(macro_size/1.5), x, y, sheet_width - macro_size * 0.75, macro_size * 0.75)
      .setLayer(layer)
      .addEventDrag(new Runnable() { public void run() { if (parent != null) parent.childDragged(); } } )
      .setGrabbable()
      .setOutlineColor(color(100))
      .setOutlineWeight(macro_size / 16)
      .setOutline(true)
      .setField(true)
      ;
    if (parent != null) grabber.setParent(parent.grabber);
    closer = new nWidget(gui, "X", int(macro_size/1.5), 0, 0, macro_size * 0.75, macro_size * 0.75)
      .setTrigger()
      .addEventTrigger(new Runnable() { public void run() { clear(); } } )
      .setParent(grabber)
      .stackRight()
      .setLayer(layer)
      .setOutlineColor(color(100))
      .setOutlineWeight(macro_size / 16)
      .setOutline(true)
      ;
    back = new nWidget(gui, 0, 0) {
      public void customShapeChange() {
        front.setSize(back.getLocalSX(), back.getLocalSY());
      }
    }
      .setParent(grabber)
      .setLayer(layer)
      .setStandbyColor(color(180, 60))
      .setOutlineColor(color(180, 60))
      .setOutlineWeight(macro_size / 8)
      .setOutline(true)
      //.stackDown()
      ;
    front = new nWidget(gui, 0, 0)
      .setParent(back)
      .setLayer(layer+1)
      .setStandbyColor(color(255, 0))
      .setOutlineWeight(macro_size/15)
      .addEventFrame(new Runnable() { public void run() { 
        if (gui.szone.isSelecting()) {
          if (gui.szone.isUnder(front)) front.setOutline(true);
          else front.setOutline(false);
        }
      } } )
      //.stackDown()
      ;
    gui.szone.addEventEndSelect(new Runnable() { public void run() { 
      if (gui.szone.isUnder(front)) front.setOutline(true);
      else front.setOutline(false);
    } } );
    
    panel = new nWidget(gui, 0, 0)
      .setParent(grabber)
      .setLayer(layer)
      .stackDown()
      ;
    inputs_ref = new nWidget(gui, macro_size / 8, 0)
      .setParent(grabber)
      .stackDown()
      ;
    outputs_ref = new nWidget(gui, 0, 0)
      .setParent(grabber)
      .stackDown()
      ;
    grabber.toLayerTop();
    closer.toLayerTop();
    
    //opener = new nWidget(gui, "-", 24, 0, 0, macro_size, macro_size)
    //  .addEventTrigger(new Runnable() { public void run() {
    //    //if (ref.hide) ref.show(); else ref.hide(); 
    //    //if (pan.hide) pan.show(); else pan.hide(); 
    //  } } )
    //  .setParent(grabber)
    //  .stackDown()
    //  .setTrigger()
    //  .setLayer(layer)
    //  ;
  }
  
  Macro_Main getBase() { if (parent == null) return (Macro_Main)this; return parent.getBase(); }
  
  void hide() {
    isHided = true;
    grabber.hide(); inputs_ref.hide(); outputs_ref.hide(); panel.hide(); back.hide(); closer.hide(); 
    front.hide();
    for (Macro_Input m : extinputs) m.hide();
    for (Macro_Output m : extoutputs) m.hide();
  }
  void show() {
    isHided = false;
    grabber.show(); inputs_ref.show(); outputs_ref.show(); panel.show(); back.show(); closer.show(); 
    front.show();
    for (Macro_Input m : extinputs) m.show();
    for (Macro_Output m : extoutputs) m.show();
  }
  
  void setLayer(int l) {
    layer = l;
    grabber.setLayer(l);
    closer.setLayer(l);
    back.setLayer(l); front.setLayer(l+1);
    for (Macro_Input m : extinputs) m.connect.setLayer(l);
    for (Macro_Output m : extoutputs) { m.connect.setLayer(l); m.line_drawer.setLayer(l+1); }
  }
  
  void toLayerTop() {
    back.toLayerTop();
    grabber.toLayerTop(); closer.toLayerTop(); 
    for (Macro_Input m : extinputs) m.connect.toLayerTop();
    for (Macro_Output m : extoutputs) { m.connect.toLayerTop(); m.line_drawer.toLayerTop(); }
    front.toLayerTop();
  }
  
  Macro_Abstract setWidth(float w) {
    sheet_width = w;
    if (inCount > 1) w += macro_size;
    if (outCount > 1) w += macro_size;
    grabber.setSX(w - macro_size * 0.75);
    back.setSX(w);
    outputs_ref.setPX(w - macro_size * 9 / 8);
    return this;
  }
  
  float getW() {
    return back.getSX(); }
  float getH() {
    return back.getSY(); }
  
  abstract void childDragged();
  
  void up_back() {
    int h = max(inCount, outCount);
    back.setSY(h * macro_size * 1.125 + macro_size * 0.875);
    if (inCount > 0) panel.setPX(macro_size + macro_size / 8);
  }
  
  int inCount = 0;
  int outCount = 0;
  
  Macro_Input addExtInput() {
    Macro_Input m = new Macro_Input(gui, parent, 0, inCount * macro_size * 1.125 + macro_size / 8 )
      .setParent(inputs_ref)
      ;
    extinputs.add(m);
    inCount++;
    up_back();
    return m;
  }
  
  Macro_Output addExtOutput() {
    Macro_Output m = new Macro_Output(gui, parent, 0, outCount * macro_size * 1.125 + macro_size / 8 )
      .setParent(outputs_ref)
      ;
    extoutputs.add(m);
    outCount++;
    up_back();
    return m;
  }
  
  Macro_Abstract addLine() { if (inCount >= outCount) inCount++; else outCount++; return this; }
  
  float getLastLineY() { 
    if (inCount >= outCount) return (inCount-1) * macro_size + macro_size / 8; 
    else                     return (outCount-1) * macro_size + macro_size / 8; 
  }
  
  void clear() {
    for (Macro_Input m : extinputs) m.clear(); extinputs.clear();
    for (Macro_Output m : extoutputs) m.clear(); extoutputs.clear();
    if (parent != null) parent.child_macro.remove(this);
    grabber.clear(); inputs_ref.clear(); outputs_ref.clear(); 
    panel.clear(); back.clear(); closer.clear(); front.clear();
    parent.childDragged();
  }
  
  /*
  macro basic bloc build order
  
  from abstract:
    position
    ext co index
  basic bloc datas
  
  */
  
  //pos x - pos y
  //void pos_to_string(String[] s, int id) {
  //  log("start - to string - abstract - pos");
  //  s[id] = str(grabber.getLocalX());
  //  s[id+1] = str(grabber.getLocalY());
  //  log("id " + id + " px " + s[id] + " py " + s[id+1]);
  //  log("end - to string - abstract - pos");
  //}
  
  //void pos_from_string(String[] s, int id) {
  //  log("start - from string - abstract - pos");
  //  grabber.setPX(float(s[id]))
  //    .setPY(float(s[id+1]));
  //  log("id " + id + " px " + s[id] + " py " + s[id+1]);
  //  log("end - from string - abstract - pos");
  //}
  
  //int pos_string_size() { return 2; }
  
  //// extin nb - ext in to string - extout nb - extout to string
  //void extco_to_string(String[] s, int id) {
  //  log("start - to string - abstract - extco");
    
  //  int vnb = 0;
  //  for (Macro_Input v : extinputs) vnb += v.size();
  //  s[id] = str(vnb);
  //  log("extin nb " + id + " " + s[id]); 
  //  id++;
  //  for (Macro_Input v : extinputs) {
  //    v.to_string(s, id);
  //    id += v.size(); }
    
  //  vnb = 0;
  //  for (Macro_Output v : extoutputs) vnb += v.size();
  //  s[id] = str(vnb);
  //  log("extout nb " + id + " " + s[id]); 
  //  id++;
  //  for (Macro_Output v : extoutputs) {
  //    v.to_string(s, id);
  //    id += v.size(); }
    
  //  log("end - to string - abstract - extco");
  //}
  
  //void extco_from_string(String[] s, int id) {
  //  log("start - from string - abstract - extco");
    
  //  int l = int(s[id]);
  //  log("ext in nb " + id + " " + s[id]);
  //  id++;
  //  for (int i = 0; i < l ; i++) {
  //    Macro_Input m = extinputs.get(i);
  //    m.from_string(s, id);
  //    id += m.size();
  //  }
  //  l = int(s[id]);
  //  log("ext out nb " + id + " " + s[id]);
  //  id++;
  //  for (int i = 0; i < l ; i++) {
  //    Macro_Output m = extoutputs.get(i);
  //    m.from_string(s, id);
  //    id += m.size();
  //  }
    
  //  log("end - from string - abstract - extco");
  //}
  
  //int extco_string_size() { 
  //  int vnb = 2;
  //  for (Macro_Input v : extinputs) vnb += v.size();
  //  for (Macro_Output v : extoutputs) vnb += v.size();
  //  return vnb;
  //}
  
  void to_save(Save_Bloc sbloc) {
    sbloc.newData("name", name);
    sbloc.newData("title", name);
    sbloc.newData("x",grabber.getLocalX());
    sbloc.newData("y",grabber.getLocalY());
    extco_to_save(sbloc);
  }
  
  void from_save(Save_Bloc sbloc) {
    name = sbloc.getData("name");
    grabber.setText(sbloc.getData("title"));
    grabber.setPX(sbloc.getFloat("x"));
    grabber.setPY(sbloc.getFloat("y"));
    extco_from_save(sbloc);
  }
  
  void extco_to_save(Save_Bloc parent) {
    for (Macro_Input m : extinputs) {
      Save_Bloc bloc = parent.newBloc("ext in");
      bloc.newData("index", m.index); }
    for (Macro_Output m : extoutputs) {
      Save_Bloc bloc = parent.newBloc("ext out");
      bloc.newData("index", m.index); }
  }
  
  void extco_from_save(Save_Bloc bloc) {
    Save_Bloc extin_blocs = bloc.getBloc("ext in");
    if (extin_blocs != null) extin_blocs.runIterator(new Iterator<Save_Bloc>() { 
      public void run(Save_Bloc bloc, int i) { extinputs.get(i).index = bloc.getInt("index"); } } );
    Save_Bloc extout_blocs = bloc.getBloc("ext out");
    if (extout_blocs != null) extout_blocs.runIterator(new Iterator<Save_Bloc>() { 
      public void run(Save_Bloc bloc, int i) { extoutputs.get(i).index = bloc.getInt("index"); } } );
    
  }
  
  void to_string(String[] s, int id) {
    log("to string abstract");
    
    //pos_to_string(s, id);
    //id += pos_string_size();
    
    //extco_to_string(s, id);
    
    s[id] = copy(name);
    int vnb = 7;
    for (Macro_Input v : extinputs) vnb += v.size();
    for (Macro_Output v : extoutputs) vnb += v.size();
    s[id+1] = str(vnb);
    s[id+2] = str(grabber.getLocalX());
    s[id+3] = str(grabber.getLocalY());
    s[id+4] = str(sheet_width);
    log("id " + id + " name " + s[id] + " size " + s[id+1] + 
        " px " + s[id+2] + " py " + s[id+3] + " w " + s[id+4]);
    id+=5;
    
    vnb = 0;
    for (Macro_Input v : extinputs) vnb += v.size();
    s[id] = str(vnb);
    log("extin nb " + id + " " + s[id]); 
    id++;
    for (Macro_Input v : extinputs) {
      v.to_string(s, id);
      id += v.size(); }
      
    vnb = 0;
    for (Macro_Output v : extoutputs) vnb += v.size();
    s[id] = str(vnb);
    log("extout nb " + id + " " + s[id]); 
    id++;
    for (Macro_Output v : extoutputs) {
      v.to_string(s, id);
      id += v.size(); }
    log("end to string abstract");
  }
  
  void from_string(String[] s, int id) {
    log("from string abstract");
    
    //pos_from_string(s, id);
    //id += pos_string_size();
    //extco_from_string(s, id);
    
    name = s[id].substring(0, s[id].length());
    grabber.setPX(float(s[id+2]))
      .setPY(float(s[id+3]));
    setWidth(float(s[id+4]));
    log("id " + id + " name " + s[id] + " size " + s[id+1] + 
        " px " + s[id+2] + " py " + s[id+3] + " w " + s[id+4]);
    id+=5;
    int l = int(s[id]);
    log("ext in nb " + id + " " + s[id]);
    id++;
    for (int i = 0; i < l ; i++) {
      Macro_Input m = extinputs.get(i);
      m.from_string(s, id);
      id += m.size();
    }
    l = int(s[id]);
    log("ext out nb " + id + " " + s[id]);
    id++;
    for (int i = 0; i < l ; i++) {
      Macro_Output m = extoutputs.get(i);
      m.from_string(s, id);
      id += m.size();
    }
    
    log("end from string abstract");
  }
  
  int size() { 
    int vnb = 7;
    for (Macro_Input v : extinputs) vnb += v.size();
    for (Macro_Output v : extoutputs) vnb += v.size();
    return vnb;
  }
  
}




/*

objet principale qui contient tout le patch

extended from sheet object
non reductible

fonction save load

can create like sheet object

*/



class Macro_Main extends Macro_Sheet {
  Ticking_pile tickpile;
  nWidget sload, ssave;
  nExcludeGroup menugroup = null;
  int menu_layer = 50;
  Macro_Main(nGUI _gui, Ticking_pile t, float x, float y) {
    super(_gui, null, x, y);
    tickpile = t;
    menugroup = gui.newExcludeGroup();
    for (nWidget w : menubuttons) menugroup.add(w);
    front.hide();
    sload = new nWidget(_gui, "Load", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(ssheet)
      .setLayer(menu_layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable() { public void run() {
        sdata_load();
        //do_load();
        childDragged();
        smenu.setOff();
      }})
      ;
    ssave = new nWidget(_gui, "Save", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(sload)
      .setLayer(getBase().menu_layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable() { 
      public void run() {
        //do_save();
        sdata_save();
        getBase().menugroup.closeAll();
      }
    }
    )
    ;
    subMenuWidgets.add(ssave);
    //back.toLayerTop();
    setLayer(0);
    toLayerTop();
    if (menubuttons.size() > 0) menubuttons.get(0).setParent(grabber);
    reduc.hide(); 
    
    closer.hide(); 
    
    grabber.setSX(macro_size*9.25);
    
    grabber.setText("MACRO");
    
    
    
    sPanel build_panel = new sPanel(cp5, 100, 200)
      .setTab("Macros")
      .addTitle("- NEW  MACRO -", 85, 0, 28)
      .addSeparator(12)
      .addDrawer(30)
        .addButton("", 30, 0)
          .setSize(100, 30)
          .addListener(new ControlListener() {
            public void controlEvent(final ControlEvent ev) {
              Macro_Custom m = new Macro_Custom(gui, macro_main, 0, 0)
                .addValueWatcher(gcom.OLD_AGE)
                  .getMacro()
                ;
              macro_main.adding(m);
              macro_main.childDragged();;
            } } )
          .getDrawer()
        .getPanel()
      .addLine(12)
      .addSeparator(5)
      ;
    
    
    
  }
  void clear() {
    empty();
    super.clear();
    sload.clear();
  }
  Macro_Abstract setWidth(float w) {
    super.setWidth(w);
    grabber.setSX(macro_size*9.25);
    return this;
  }
  void toLayerTop() {
    super.toLayerTop();
    sload.toLayerTop();
  }
  void setLayer(int l) {
    super.setLayer(l);
    sload.setLayer(menu_layer);
  }
}












/*

objets des connection in et out linkable
objet out 
  cree et affiche les links
  envois les packet
  
objet in
  peut register des runnable a exec quand un packet est recus

objet packet : est transporté
    string definition plus array de string

*/






class Macro_Sheet_Input {
  nGUI gui;
  Macro_Sheet sheet,parent;
  Macro_Input in = null;
  Macro_Output out = null;
  nWidget grabber;
  
  float enlarged_pos = 0;
  float reduc_pos = 0;
  
  Macro_Sheet_Input(nGUI _gui, Macro_Sheet _parent, Macro_Sheet _sheet) {
    gui = _gui;
    parent = _parent;
    sheet = _sheet;
    
    reduc_pos = sheet.macro_size * 1 / 8 + sheet.sheet_inCount * sheet.macro_size * 1.125;
    enlarged_pos = sheet.macro_size * 9 / 8 + sheet.sheet_inCount * sheet.macro_size * 1.125;
    sheet.sheet_inputs.add(this);
    sheet.sheet_inCount++;
    
    grabber = new nWidget(gui, 0, enlarged_pos, sheet.macro_size * 0.75, sheet.macro_size)
      .setParent(sheet.inputs_ref)
      .setLayer(sheet.layer+2)
      .addEventDrag(new Runnable() { public void run() { 
        enlarged_pos = grabber.getLocalY();
        sheet.childDragged(); 
      } } )
      .setGrabbable()
      .setConstrainX(true)
      ;
    if (parent == null) grabber.setPX(-sheet.macro_size);
    out = new Macro_Output(gui, sheet, 0, 0 )
      .setParent(grabber)
      .setLayer(sheet.layer+3)
      ;
    out.connect.stackRight();
    
    if (parent != null) {
      in = new Macro_Input(gui, parent, 0, 0 )
        .setParent(grabber)
        .setLayer(sheet.layer)
        ;
      in.connect.stackLeft();
      sheet.extinputs.add(in);
      in.direct_connect(out);
    }
  }
  void reduc() {
    grabber.setPY(reduc_pos)
      .hide();
    out.hide();
    if (in != null) in.show();
  }
  void enlarg() {
    grabber.setPY(enlarged_pos)
      .show();
    out.show();
  }
  void hide() {
    grabber.hide();
  }
  void show() {
    grabber.show();
  }
  void clear() {
    sheet.extinputs.remove(in);
    sheet.sheet_inCount--;
    sheet.sheet_inputs.remove(this);
    if (in != null) in.clear();
    out.clear();
    grabber.clear();
  }
  
  void to_save(Save_Bloc parent) {
    Save_Bloc bloc = parent.newBloc("sheet in");
    bloc.newData("enlarged", enlarged_pos);
    bloc.newData("reducted", reduc_pos);
    if (in != null) bloc.newData("parent co", in.index);
    bloc.newData("sheet co", out.index);
  }
  void from_save(Save_Bloc bloc) {
    enlarged_pos = bloc.getFloat("enlarged");
    reduc_pos = bloc.getFloat("reducted");
    grabber.setPY(enlarged_pos);
    if (in != null)  {
      if (bloc.getData("parent co") != null) in.index = bloc.getInt("parent co");
      else in.index = parent.getFreeInputIndex(); }
    
    out.index = bloc.getInt("sheet co");
  }
  
  void to_string(String[] s, int id) {
    s[id] = str(enlarged_pos);
    s[id+1] = str(reduc_pos);
    log("to string sheet input " + id + " enlarged " + s[id] + " reduc " + s[id+1]);
  }
  void from_string(String[] s, int id) {
    enlarged_pos = float(s[id]);
    reduc_pos = float(s[id+1]);
    log("from string sheet input " + id + " enlarged " + s[id] + " reduc " + s[id+1]);
  }
  int size() { return 2; }
  
  Macro_Sheet_Input setLayer(int l) {
    grabber.setLayer(l);
    if (in != null) in.setLayer(l-2);
    out.setLayer(l);
    return this;
  }
  
  void toLayerTop() {
    grabber.toLayerTop();
    if (in != null) in.toLayerTop();
    out.toLayerTop();
  }
  
}



class Macro_Sheet_Output {
  nGUI gui;
  Macro_Sheet sheet,parent;
  Macro_Input in = null;
  Macro_Output out = null;
  nWidget grabber;
  
  float enlarged_pos = 0;
  float reduc_pos = 0;
  
  Macro_Sheet_Output(nGUI _gui, Macro_Sheet _parent, Macro_Sheet _sheet) {
    gui = _gui;
    parent = _parent;
    sheet = _sheet;
    
    reduc_pos = sheet.macro_size * 1 / 8 + sheet.sheet_outCount * sheet.macro_size * 1.125;
    enlarged_pos = sheet.macro_size * 9 / 8 + sheet.sheet_outCount * sheet.macro_size * 1.125;
    sheet.sheet_outputs.add(this);
    sheet.sheet_outCount++;
    
    grabber = new nWidget(gui, -sheet.macro_size * 0.75, enlarged_pos, sheet.macro_size * 0.75, sheet.macro_size)
      .setParent(sheet.outputs_ref)
      .setLayer(sheet.layer+2)
      .addEventDrag(new Runnable() { public void run() { 
        enlarged_pos = grabber.getLocalY();
        sheet.childDragged(); 
      } } )
      .setGrabbable()
      .setConstrainX(true)
      ;
    if (parent == null) grabber.setPX(sheet.macro_size * 0.25);
    if (parent != null) {
      out = new Macro_Output(gui, parent, 0, 0 )
        .setParent(grabber)
        .setLayer(sheet.layer+2)
        ;
      out.connect.stackRight();
      sheet.extoutputs.add(out);
    }
    
    in = new Macro_Input(gui, sheet, 0, 0 )
      .setParent(grabber)
      .setLayer(sheet.layer)
      ;
    in.connect.stackLeft();
    in.direct_connect(out);
    
  }
  void reduc() {
    grabber.setPY(reduc_pos)
      .hide();
    in.hide();
    if (out != null) out.show();
  }
  void enlarg() {
    grabber.setPY(enlarged_pos)
      .show();
    in.show();
  }
  void hide() {
    grabber.hide();
  }
  void show() {
    grabber.show();
  }
  void clear() {
    sheet.extoutputs.remove(in);
    sheet.sheet_outCount--;
    sheet.sheet_outputs.remove(this);
    in.clear();
    if (out != null) out.clear();
    grabber.clear();
  }
  
  void to_save(Save_Bloc parent) {
    Save_Bloc bloc = parent.newBloc("sheet out");
    bloc.newData("enlarged", enlarged_pos);
    bloc.newData("reducted", reduc_pos);
    if (out != null) bloc.newData("parent co", out.index);
    bloc.newData("sheet co", in.index);
  }
  void from_save(Save_Bloc bloc) {
    enlarged_pos = bloc.getFloat("enlarged");
    reduc_pos = bloc.getFloat("reducted");
    grabber.setPY(enlarged_pos);
    in.index = bloc.getInt("sheet co");
    if (out != null) {
      if (bloc.getData("parent co") != null) out.index = bloc.getInt("parent co");
      else out.index = parent.getFreeOutputIndex(); }
  }
  
  void to_string(String[] s, int id) {
    s[id] = str(enlarged_pos);
    s[id+1] = str(reduc_pos);
    log("to string sheet input " + id + " enlarged " + s[id] + " reduc " + s[id+1]);
  }
  void from_string(String[] s, int id) {
    enlarged_pos = float(s[id]);
    reduc_pos = float(s[id+1]);
    log("from string sheet input " + id + " enlarged " + s[id] + " reduc " + s[id+1]);
  }
  int size() { return 2; }
  
  Macro_Sheet_Output setLayer(int l) {
    grabber.setLayer(l);
    in.setLayer(l);
    if (out != null) out.setLayer(l-2);
    return this;
  }
  
  void toLayerTop() {
    grabber.toLayerTop();
    in.toLayerTop();
    if (out != null) out.toLayerTop();
  }
  
}






Macro_Packet newBang() { return new Macro_Packet("bang"); }
Macro_Packet newFloat(float f) { return new Macro_Packet("float").addMsg(str(f)); }
Macro_Packet newFloat(String f) { return new Macro_Packet("float").addMsg(f); }

class Macro_Packet {
  String def = new String();
  ArrayList<String> messages = new ArrayList<String>();
  Macro_Packet(String d) {
    def = d;
  }
  Macro_Packet addMsg(String m) { messages.add(m); return this; }
  boolean isBang() { return def.equals("bang"); }
  boolean isFloat() { return def.equals("float"); }
  float asFloat() { return float(messages.get(0)); }
}







class Macro_Output {
  Macro_Sheet macro;
  Drawer line_drawer;
  nWidget connect;
  
  boolean buildingLine = false;
  PVector newLine = new PVector();
  
  ArrayList<Macro_Input> connected_inputs = new ArrayList<Macro_Input>();
  
  boolean sending = false;
  int hasSend = 0;
  
  int index = -1;
  
  Macro_Output setLayer(int l) {
    line_drawer.setLayer(l + 1);
    connect.setLayer(l);
    return this;
  }
  
  Macro_Output toLayerTop() {
    line_drawer.toLayerTop();
    connect.toLayerTop();
    return this;
  }
  
  Macro_Output(nGUI _gui, Macro_Sheet _s, float x, float y) {
    
    macro = _s;
    index = macro.getFreeOutputIndex();
    macro.outputs.add(this);
    
    line_drawer = new Drawer(_gui.drawing_pile, macro.layer + 1) { public void drawing() {
      if (buildingLine) {
        stroke(connect.outlineColor);
        strokeWeight(connect.outlineWeight);
        line(getCenterX(), getCenterY(), 
             newLine.x, newLine.y);
        fill(255);
        ellipseMode(CENTER);
        ellipse(getCenterX(), getCenterY(), 
                getSize(), getSize() );
        fill(0);
        ellipse(newLine.x, newLine.y, 
                getSize(), getSize() );
      }
      for (Macro_Input m : connected_inputs) {
        if (distancePointToLine(cam.getCamMouse().x, cam.getCamMouse().y, 
            getCenterX(), getCenterY(), m.getCenterX(), m.getCenterY()) < connect.outlineWeight ) 
          { fill(connect.selectedColor); stroke(connect.selectedColor); }
        else if (sending || hasSend > 0)
          { fill(connect.outlineColor); stroke(connect.outlineColor); }
        else { fill(color(255, 120)); stroke(color(255, 120)); }
        strokeWeight(connect.outlineWeight);
        line(getCenterX(), getCenterY(), 
             m.getCenterX(), m.getCenterY());
        ellipseMode(CENTER);
        fill(0);
        ellipse(m.getCenterX(), m.getCenterY(), 
                getSize(), getSize() );
        fill(255);
        ellipse(getCenterX(), getCenterY(), 
                getSize(), getSize() );
      }
      if (hasSend > 0) hasSend--;
    } };
    
    connect = new nWidget(_gui, x, y, macro.macro_size, macro.macro_size)
      {
        public void customVisibilityChange() {
          if (connect.isHided()) line_drawer.active = false;
          else line_drawer.active = true;
        }
      }
      .setTrigger()
      .setLayer(macro.layer)
      .setOutlineWeight(macro.macro_size/6)
      .setDrawer(new Drawer(_gui.drawing_pile) { public void drawing() {
        if (connect.isClicked)                     { fill(connect.clickedColor); } 
        else if (connect.isHovered || hasSend > 0) { fill(connect.hoveredColor); } 
        else                                       { fill(connect.standbyColor); }
        //stroke(connect.outlineColor);
        //strokeWeight(connect.outlineWeight);
        noStroke();
        rect(connect.getX(), connect.getY(), connect.getSX(), connect.getSY());
        
        fill(255);
        noStroke();
        ellipseMode(CENTER);
        ellipse(getCenterX(), getCenterY(), 
                connect.getSX() / 1.9, connect.getSY() / 1.9 );
        if (DEBUG) {
          fill(255);
          textFont(getFont(6));
          text(""+index, connect.getX()+25, connect.getY()+6);
        }
      } } )
      .addEventPress(new Runnable() { public void run() {
        buildingLine = true;
        for (Macro_Input i : macro.inputs) i.connect.setTrigger();
      } } )
      .addEventFrame(new Runnable(this) { public void run() {
        sending = false;
        if (buildingLine) {
          newLine.x = cam.getCamMouse().x;
          newLine.y = cam.getCamMouse().y;
          if (kb.mouseClick[1]) buildingLine = false;
          if (kb.mouseClick[0]) {
            for (Macro_Input m : macro.inputs) {
              boolean found = false;
              for (Macro_Input n : connected_inputs)
                if (m == n) found = true;
              if (!found && m.connect.isHovered()) {
                connect_to(m);
                buildingLine = false;
                for (Macro_Input i : macro.inputs) i.connect.setPassif();
                break;
              }
            }
          }
        }
        if (kb.mouseClick[1]) for (Macro_Input m : connected_inputs) {
          if (distancePointToLine(cam.getCamMouse().x, cam.getCamMouse().y, 
              getCenterX(), getCenterY(), m.getCenterX(), m.getCenterY()) < connect.outlineWeight) {
            disconnect_from(m);
            break;
          }
        }
      } } )
      ;
  }
  
  void hide() { connect.hide(); line_drawer.active = false; }
  void show() { connect.show(); line_drawer.active = true; }
  
  void connect_to(Macro_Input m) {
    connected_inputs.add(m);
    m.connected_outputs.add(this); }
  void disconnect_from(Macro_Input m) {
    connected_inputs.remove(m);
    m.connected_outputs.remove(this); }
  
  void to_string(String[] s, int id) {
    s[id] = str(index);
    log("to string output " + id + " index " + s[id]);
  }
  void from_string(String[] s, int id) {
    index = int(s[id]);
    log("from string output " + id + " index " + s[id]);
  }
  int size() { return 1; }
  void clear() {
    for (Macro_Input m : connected_inputs) m.connected_outputs.remove(this);
    connected_inputs.clear();
    connect.clear();
    line_drawer.clear();
    macro.outputs.remove(this);
  }
  
  float getCenterX() { return connect.getX() + connect.getSX() / 2; }
  float getCenterY() { return connect.getY() + connect.getSY() / 2; }
  float getSize() { return connect.getSX() / 1.6; }
  Macro_Abstract getMacro() { return macro; }
  
  Macro_Output setParent(nWidget w) { connect.setParent(w); return this; }
  
  void send(Macro_Packet p) {
    sending = true;
    hasSend = 5;
    for (Macro_Input m : connected_inputs) m.receive(p);
  }
  
}







class Macro_Input {
  Macro_Sheet macro;
  nWidget connect;
  ArrayList<Macro_Output> connected_outputs = new ArrayList<Macro_Output>();
  int index = -1;
  Macro_Input(nGUI _gui, Macro_Sheet _s, float x, float y) {
    macro = _s;
    index = macro.getFreeInputIndex();
    macro.inputs.add(this);
    connect = new nWidget(_gui, x, y, macro.macro_size, macro.macro_size)
      .setLayer(macro.layer)
      .setDrawer(new Drawer(_gui.drawing_pile) { public void drawing() {
        if (connect.isClicked)      { fill(connect.clickedColor); } 
        else if (connect.isHovered) { fill(connect.hoveredColor); } 
        else                        { fill(connect.standbyColor); }
        noStroke();
        rect(connect.getX(), connect.getY(), connect.getSX(), connect.getSY());
        noStroke();
        fill(0);
        ellipseMode(CENTER);
        ellipse(getCenterX(), getCenterY(), 
                connect.getSX() / 1.9, connect.getSY() / 1.9 );
        if (DEBUG) {
          fill(255);
          textFont(getFont(int(macro.macro_size/4)));
          text(""+index, connect.getX()-5, connect.getY()+6);
        }
      } } )
      //.setTrigger()
      ;
    
  }
  Macro_Input setLayer(int l) {
    connect.setLayer(l);
    return this;
  }
  Macro_Input toLayerTop() {
    connect.toLayerTop();
    return this;
  }
  void hide() { connect.hide(); }
  void show() { connect.show(); }
  
  void to_save(Save_Bloc parent) {
    
  }
  void from_save(Save_Bloc bloc) {
    
  }
  
  void to_string(String[] s, int id) {
    s[id] = str(index);
    log("to string input " + id + " index " + s[id]);
    
  }
  void from_string(String[] s, int id) {
    index = int(s[id]);
    log("from string input " + id + " index " + s[id]);
  }
  int size() { return 1; }
  void clear() {
    for (Macro_Output m : connected_outputs) m.connected_inputs.remove(this);
    connected_outputs.clear();
    connect.clear();
    macro.inputs.remove(this);
  }
  
  Macro_Input setParent(nWidget w) { connect.setParent(w); return this; }
  
  float getCenterX() { return connect.getX() + connect.getSX() / 2; }
  float getCenterY() { return connect.getY() + connect.getSY() / 2; }
  Macro_Abstract getMacro() { return macro; }
  
  Macro_Packet last_packet = null;
  
  Macro_Packet getLastPacket() { return last_packet; }
  
  void receive(Macro_Packet p) {
    last_packet = p;
    for (Runnable r : eventReceiveRun) r.run();
    if (direct_out != null) direct_out.send(p);
  }
  
  ArrayList<Runnable> eventReceiveRun = new ArrayList<Runnable>();
  Macro_Input addEventReceive(Runnable r)    { eventReceiveRun.add(r); return this; }
  Macro_Input removeEventReceive(Runnable r) { eventReceiveRun.remove(r); return this; }
  
  Macro_Output direct_out = null;
  void direct_connect(Macro_Output o) { direct_out = o; }
}




 
