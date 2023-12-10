
/*
  Macro_Main(Input, Data, Interface)
    tick()
    addTickAskMethod
    add show/hide button in sim toolpanel ( go back n forth between two camera view )
    add entry to sim main menu to create macro main panel
    macro main panel
      tab file
        select save file
        clear/save/load all
      tab add to selected sheet
        child sheet
        sheet in/out
          can be named
        basic macro
        macro for svalue watch/ctrl
        macro to launch referanced runnables
      tab templates
        select template list file
        save selected sheet as template
        template list 
          trigger creation of selected template as child in selected sheet
          can trigger deletion of selected template

*/



/*

objet principale qui contient tout le patch

extended from sheet object
non reductible

*/



class Macro_Main extends Macro_Sheet {
  ArrayList<Runnable> tickAskMethods = new ArrayList<Runnable>();
  void addTickAskMethod(Runnable r) { tickAskMethods.add(r); }
  void askTick() { runEvents(tickAskMethods); }
  Ticking_pile tickpile;
  
  //nWidget sload, ssave;
  nExcludeGroup menugroup = null;
  int menu_layer = 50;
  nInfo info;
  Macro_Sheet selecting_sheet = null;
  ArrayList<nWidget> selected_macro_grabber = new ArrayList<nWidget>();
  
  sInterface inter;
  
  Macro_Main(sInterface _int) {
    super(_int.cam_gui, null, 0, 0);
    inter = _int;
    info = new nInfo(gui, int(ref_size/1.5)).setLayer(menu_layer+1);
    tickpile = new Ticking_pile();
    
    front.hide();
    setLayer(0);
    toLayerTop();
    reduc.hide(); 
    closer.hide(); 
    grabber.setSX(ref_size*9.25);
    grabber.setText("MACRO");
    
    grabber.hide();
    
    //gui.szone.addEventEndSelect(new Runnable() { public void run() {
    //  ;
    //}}).addEventStartSelect(new Runnable() { public void run() {
    //  selecting_sheet = null;
    //  selected_macro_grabber.clear();
    //}});
    //menugroup = gui.newExcludeGroup();
    //for (nWidget w : menubuttons) menugroup.add(w);
    //sload = new nWidget(gui, "Load", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
    //  .setTrigger()
    //  .setParent(ssheet)
    //  .setLayer(menu_layer)
    //  .stackDown()
    //  .hide()
    //  .addEventTrigger(new Runnable() { public void run() {
    //    sdata_load();
    //    childDragged();
    //    getBase().menugroup.closeAll();
    //  }})
    //  ;
    //ssave = new nWidget(gui, "Save", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
    //  .setTrigger()
    //  .setParent(sload)
    //  .setLayer(getBase().menu_layer)
    //  .stackDown()
    //  .hide()
    //  .addEventTrigger(new Runnable() { 
    //  public void run() {
    //    sdata_save();
    //    getBase().menugroup.closeAll();
    //  }
    //}
    //)
    //;
    //subMenuWidgets.add(ssave);
    //if (menubuttons.size() > 0) menubuttons.get(0).setParent(grabber);
    
  }
  void clear() {
    empty();
    super.clear();
    //sload.clear();
  }
  Macro_Abstract setWidth(float w) {
    super.setWidth(w);
    grabber.setSX(ref_size*9.25);
    return this;
  }
  void toLayerTop() {
    super.toLayerTop();
    //sload.toLayerTop();
  }
  void setLayer(int l) {
    super.setLayer(l);
    //sload.setLayer(menu_layer);
  }
}
















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
  
  int layer = 0;
  nWidget grabber, inputs_ref, outputs_ref, panel, back, closer, front;
  
  float sheet_width;
  float ref_size = 40;
  String name = null;
  
  boolean isHided = false;
  
  void parentReduc() {
    hide();
  }
  void parentEnlarg() {
    show();
  }
  
  boolean selected = false;
  
  Macro_Abstract(nGUI _gui, Macro_Sheet p, String n, float x, float y) {
    gui = _gui;
    parent = p;
    name = n;
    if (parent != null) parent.child_macro.add(this);
    
    sheet_width = ref_size;
    
    grabber = new nWidget(gui, name, int(ref_size/1.5), 
                          x, y, sheet_width - ref_size * 0.75, ref_size * 0.75)
      .setLayer(layer)
      .addEventDrag(new Runnable() { public void run() { 
        if (selected) for (nWidget w : mmain().selected_macro_grabber) if (w != grabber) {
          //w.setPX(w.getLocalX() + cam.getCamMouse().x - cam.getPCamMouse().x);
          //w.setPY(w.getLocalY() + cam.getCamMouse().y - cam.getPCamMouse().y);
        }
        if (parent != null) parent.childDragged(); 
      } } )
      .setGrabbable()
      .setOutlineColor(color(100))
      .setOutlineWeight(ref_size / 16)
      .setOutline(true)
      .setField(true)
      ;
    if (parent != null) grabber.setParent(parent.grabber);
    closer = new nWidget(gui, "X", int(ref_size/1.5), 
                         0, 0, ref_size * 0.75, ref_size * 0.75)
      .setTrigger()
      .addEventTrigger(new Runnable() { public void run() { 
        // selected group clear
        //if (selected) for (Macro_Abstract w : getBase().selected_macro) if (w.grabber != grabber) w.clear();
        clear(); 
      } } )
      .setParent(grabber)
      .stackRight()
      .setLayer(layer)
      .setOutlineColor(color(100))
      .setOutlineWeight(ref_size / 16)
      .setOutline(true)
      ;
    back = new nWidget(gui, 0, 0) {
      public void customShapeChange() {
        front.setSize(back.getLocalSX(), back.getLocalSY());
      }
    }
      .setParent(grabber)
      .setLayer(layer)
      .setStandbyColor(color(50, 200))
      .setOutlineColor(color(255, 60))
      .setOutlineWeight(ref_size / 8)
      .setOutline(true)
      ;
    front = new nWidget(gui, 0, 0)
      .setParent(back)
      .setLayer(layer+1)
      .setStandbyColor(color(255, 0))
      .setOutlineWeight(ref_size/15)
      .addEventFrame(new Runnable() { public void run() { 
        //if (gui.szone.isSelecting()) {
        //  if (getBase().selecting_sheet == null && gui.szone.isUnder(front)) getBase().selecting_sheet = parent;
        //  if (getBase().selecting_sheet == parent) {
        //    if (gui.szone.isUnder(front)) front.setOutline(true);
        //    else front.setOutline(false);
        //  }
        //}
      } } )
      ;
    //gui.szone.addEventStartSelect(new Runnable() { public void run() { 
    //  selected = false;
    //  getBase().selected_macro_grabber.remove(grabber);
    //  front.setOutline(false);
    //} } );
    //gui.szone.addEventEndSelect(new Runnable() { public void run() { 
    //  if (getBase().selecting_sheet == parent && gui.szone.isUnder(front))  {
    //    getBase().selected_macro_grabber.add(grabber);
    //    selected = true;
    //  }
    //} } );
    
    panel = new nWidget(gui, 0, 0)
      .setParent(grabber)
      .setLayer(layer)
      .stackDown()
      ;
    inputs_ref = new nWidget(gui, ref_size / 8, 0)
      .setParent(grabber)
      .stackDown()
      ;
    outputs_ref = new nWidget(gui, 0, 0)
      .setParent(grabber)
      .stackDown()
      ;
    grabber.toLayerTop();
    closer.toLayerTop();
    
  }
  
  Macro_Main mmain() { if (parent == null) return (Macro_Main)this; return parent.mmain(); }
  
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
    if (inCount > 1) w += ref_size;
    if (outCount > 1) w += ref_size;
    grabber.setSX(w - ref_size * 0.75);
    back.setSX(w);
    outputs_ref.setPX(w - ref_size * 9 / 8);
    return this;
  }
  
  float getW() {
    return back.getSX(); }
  float getH() {
    return back.getSY(); }
  
  abstract void childDragged();
  
  void up_back() {
    int h = max(inCount, outCount);
    back.setSY(h * ref_size * 1.125 + ref_size * 0.875);
    if (inCount > 0) panel.setPX(ref_size + ref_size / 8);
  }
  
  int inCount = 0;
  int outCount = 0;
  
  Macro_Input addExtInput() {
    Macro_Input m = new Macro_Input(gui, parent, 0, inCount * ref_size * 1.125 + ref_size / 8 )
      .setParent(inputs_ref)
      ;
    extinputs.add(m);
    inCount++;
    up_back();
    return m;
  }
  
  Macro_Output addExtOutput() {
    Macro_Output m = new Macro_Output(gui, parent, 0, outCount * ref_size * 1.125 + ref_size / 8 )
      .setParent(outputs_ref)
      ;
    extoutputs.add(m);
    outCount++;
    up_back();
    return m;
  }
  
  Macro_Abstract addLine() { if (inCount >= outCount) inCount++; else outCount++; up_back(); return this; }
  
  float getLastLineY() { 
    if (inCount >= outCount) return (inCount-1) * ref_size + ref_size / 8; 
    else                     return (outCount-1) * ref_size + ref_size / 8; 
  }
  
  void clear() {
    for (Macro_Input m : extinputs) m.clear(); extinputs.clear();
    for (Macro_Output m : extoutputs) m.clear(); extoutputs.clear();
    if (parent != null) parent.child_macro.remove(this);
    grabber.clear(); inputs_ref.clear(); outputs_ref.clear(); 
    panel.clear(); back.clear(); closer.clear(); front.clear();
    parent.childDragged();
  }
  
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
    
    reduc_pos = sheet.ref_size * 1 / 8 + sheet.sheet_inCount * sheet.ref_size * 1.125;
    enlarged_pos = sheet.ref_size * 9 / 8 + sheet.sheet_inCount * sheet.ref_size * 1.125;
    sheet.sheet_inputs.add(this);
    sheet.sheet_inCount++;
    
    grabber = new nWidget(gui, 0, enlarged_pos, sheet.ref_size * 0.75, sheet.ref_size)
      .setParent(sheet.inputs_ref)
      .setLayer(sheet.layer+2)
      .addEventDrag(new Runnable() { public void run() { 
        enlarged_pos = grabber.getLocalY();
        sheet.childDragged(); 
      } } )
      .setGrabbable()
      .setConstrainX(true)
      .setOutlineColor(color(100))
      .setOutlineWeight(sheet.ref_size / 16)
      .setOutline(true)
      ;
    if (parent == null) grabber.setPX(-sheet.ref_size);
    out = new Macro_Output(gui, sheet, 0, 0 )
      .setParent(grabber)
      .setLayer(sheet.layer+2)
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
  Macro_Sheet_Input setLayer(int l) {
    grabber.setLayer(l);
    if (in != null) in.setLayer(l);
    out.setLayer(l+2);
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
    
    reduc_pos = sheet.ref_size * 1 / 8 + sheet.sheet_outCount * sheet.ref_size * 1.125;
    enlarged_pos = sheet.ref_size * 9 / 8 + sheet.sheet_outCount * sheet.ref_size * 1.125;
    sheet.sheet_outputs.add(this);
    sheet.sheet_outCount++;
    
    grabber = new nWidget(gui, -sheet.ref_size * 0.75, enlarged_pos, sheet.ref_size * 0.75, sheet.ref_size)
      .setParent(sheet.outputs_ref)
      .setLayer(sheet.layer+2)
      .addEventDrag(new Runnable() { public void run() { 
        enlarged_pos = grabber.getLocalY();
        sheet.childDragged(); 
      } } )
      .setGrabbable()
      .setConstrainX(true)
      .setOutlineColor(color(100))
      .setOutlineWeight(sheet.ref_size / 16)
      .setOutline(true)
      ;
    if (parent == null) grabber.setPX(sheet.ref_size * 0.25);
    if (parent != null) {
      out = new Macro_Output(gui, parent, 0, 0 )
        .setParent(grabber)
        .setLayer(sheet.layer)
        ;
      out.connect.stackRight();
      sheet.extoutputs.add(out);
    }
    
    in = new Macro_Input(gui, sheet, 0, 0 )
      .setParent(grabber)
      .setLayer(sheet.layer+2)
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
  
  Macro_Sheet_Output setLayer(int l) {
    grabber.setLayer(l);
    in.setLayer(l+2);
    if (out != null) out.setLayer(l);
    return this;
  }
  
  void toLayerTop() {
    grabber.toLayerTop();
    in.toLayerTop();
    if (out != null) out.toLayerTop();
  }
  
}






Macro_Packet newPacketBang() { return new Macro_Packet("bang"); }

Macro_Packet newPacketFloat(float f) { return new Macro_Packet("float").addMsg(str(f)); }
Macro_Packet newPacketFloat(String f) { return new Macro_Packet("float").addMsg(f); }

Macro_Packet newPacketInt(int f) { return new Macro_Packet("int").addMsg(str(f)); }

Macro_Packet newPacketBool(boolean b) { 
  String r; 
  if (b) r = "T"; else r = "F"; 
  return new Macro_Packet("bool").addMsg(r); }

class Macro_Packet {
  String def = new String();
  ArrayList<String> messages = new ArrayList<String>();
  Macro_Packet(String d) {
    def = d;
  }
  Macro_Packet addMsg(String m) { messages.add(m); return this; }
  
  boolean isBang()  { return def.equals("bang"); }
  boolean isFloat() { return def.equals("float"); }
  boolean isInt()   { return def.equals("int"); }
  boolean isBool()  { return def.equals("bool"); }
  
  float   asFloat()   { if (isFloat()) return float(messages.get(0)); else return 0; }
  int     asInt()   { if (isInt()) return int(messages.get(0)); else return 0; }
  boolean asBool()   {
    if (isBool() && messages.get(0).equals("T")) return true; else return false; }
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
        stroke(connect.look.outlineColor);
        strokeWeight(connect.look.outlineWeight);
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
        //if (distancePointToLine(cam.getCamMouse().x, cam.getCamMouse().y, 
        //    getCenterX(), getCenterY(), m.getCenterX(), m.getCenterY()) < connect.outlineWeight ) { 
        //  if (pack_info != null && hasSend > 0) macro.getBase().info.showText(pack_info);
        //  fill(connect.selectedColor); stroke(connect.selectedColor); 
        //}
        //else 
        if (sending || hasSend > 0)
          { fill(connect.look.outlineColor); stroke(connect.look.outlineColor); }
        else { fill(color(255, 120)); stroke(color(255, 120)); }
        strokeWeight(connect.look.outlineWeight);
        PVector l = new PVector(m.getCenterX() - getCenterX(), m.getCenterY() - getCenterY());
        PVector lm = new PVector(l.x, l.y);
        lm.setMag(getSize()/2);
        line(getCenterX()+lm.x, getCenterY()+lm.y, 
             getCenterX()+l.x-lm.x, getCenterY()+l.y-lm.y);
        ellipseMode(CENTER);
        fill(255, 0);
        ellipse(m.getCenterX(), m.getCenterY(), 
                getSize(), getSize() );
        fill(255, 0);
        ellipse(getCenterX(), getCenterY(), 
                getSize(), getSize() );
      }
      if (hasSend > 0) hasSend--;
    } };
    
    connect = new nWidget(_gui, x, y, macro.ref_size, macro.ref_size)
      {
        public void customVisibilityChange() {
          if (connect.isHided()) line_drawer.active = false;
          else line_drawer.active = true;
        }
      }
      .setTrigger()
      .setLayer(macro.layer)
      .setOutlineWeight(macro.ref_size/6)
      .setDrawer(new Drawer(_gui.drawing_pile) { public void drawing() {
        if (connect.isClicked)                     { fill(connect.look.pressColor); } 
        else if (connect.isHovered || hasSend > 0) { fill(connect.look.hoveredColor); } 
        else                                       { fill(connect.look.standbyColor); }
        //stroke(connect.outlineColor);
        //strokeWeight(connect.outlineWeight);
        noStroke();
        rect(connect.getX(), connect.getY(), connect.getSX(), connect.getSY());
        
        fill(255);
        noStroke();
        ellipseMode(CENTER);
        ellipse(getCenterX(), getCenterY(), 
                connect.getSX() / 1.9, connect.getSY() / 1.9 );
        fill(0);
        textFont(getFont(int(macro.ref_size/2.5)));
        if (last_def != null) text(last_def, connect.getX()+macro.ref_size/2, connect.getY()+macro.ref_size*5/8);
        
        if (DEBUG) {
          fill(255);
          textFont(getFont(int(macro.ref_size/4)));
          text(""+index, connect.getX()+macro.ref_size*5/4, connect.getY()+macro.ref_size/4);
        }
      } } )
      .addEventPress(new Runnable() { public void run() {
        buildingLine = true;
        for (Macro_Input i : macro.inputs) i.connect.setTrigger();
      } } )
      .addEventFrame(new Runnable(this) { public void run() {
        sending = false;
        //if (buildingLine) {
        //  newLine.x = cam.getCamMouse().x;
        //  newLine.y = cam.getCamMouse().y;
        //  if (kb.mouseClick[1]) buildingLine = false;
        //  if (kb.mouseClick[0]) {
        //    for (Macro_Input m : macro.inputs) {
        //      boolean found = false;
        //      for (Macro_Input n : connected_inputs)
        //        if (m == n) found = true;
        //      if (!found && m.connect.isHovered()) {
        //        connect_to(m);
        //        buildingLine = false;
        //        for (Macro_Input i : macro.inputs) i.connect.setPassif();
        //        break;
        //      }
        //    }
        //  }
        //}
        //if (kb.mouseClick[1]) for (Macro_Input m : connected_inputs) {
        //  if (distancePointToLine(cam.getCamMouse().x, cam.getCamMouse().y, 
        //      getCenterX(), getCenterY(), m.getCenterX(), m.getCenterY()) < connect.outlineWeight) {
        //    disconnect_from(m);
        //    break;
        //  }
        //}
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
  
  String last_def = null;
  
  String pack_info = null;
  
  Macro_Output send(Macro_Packet p) {
    last_def = copy(p.def);
    pack_info = copy(p.def);
    for (String m : p.messages) pack_info = pack_info + " " + m;
    sending = true;
    hasSend = 5;
    for (Macro_Input m : connected_inputs) m.receive(p);
    return this;
  }
  Macro_Output sendBang() { send(newPacketBang()); return this; }
  Macro_Output sendFloat(float v) { send(newPacketFloat(v)); return this; }
  Macro_Output sendInt(int v) { send(newPacketInt(v)); return this; }
  Macro_Output sendBool(boolean v) { send(newPacketBool(v)); return this; }
  Macro_Output setDefBang() { last_def = "bang"; return this; }
  Macro_Output setDefBool() { last_def = "bool"; return this; }
  Macro_Output setDefInt() { last_def = "int"; return this; }
  Macro_Output setDefFloat() { last_def = "float"; return this; }
  Macro_Output setDefNumber() { last_def = "num"; return this; }
  Macro_Output setDefVal() { last_def = "val"; return this; }
  
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
    connect = new nWidget(_gui, x, y, macro.ref_size, macro.ref_size)
      .setLayer(macro.layer)
      .setDrawer(new Drawer(_gui.drawing_pile) { public void drawing() {
        if (connect.isClicked)      { fill(connect.look.pressColor); } 
        else if (connect.isHovered) { fill(connect.look.hoveredColor); } 
        else                        { fill(connect.look.standbyColor); }
        noStroke();
        rect(connect.getX(), connect.getY(), connect.getSX(), connect.getSY());
        noStroke();
        fill(0);
        ellipseMode(CENTER);
        ellipse(getCenterX(), getCenterY(), 
                connect.getSX() / 1.9, connect.getSY() / 1.9 );
        fill(255);
        textFont(getFont(int(macro.ref_size/3)));
        if (filter != null) text(filter, connect.getX()+macro.ref_size/2, connect.getY()+macro.ref_size*5/8);
        if (DEBUG) {
          textFont(getFont(int(macro.ref_size/4)));
          text(""+index, connect.getX()-macro.ref_size/4, connect.getY()+macro.ref_size/4);
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
    if (filter == null || p.def.equals(filter) || 
        (filter.equals("num") && (p.def.equals("float") || p.def.equals("int"))) ||
        (filter.equals("val") && (p.def.equals("float") || p.def.equals("int") || p.def.equals("bool"))) ) {
      last_packet = p;
      for (Runnable r : eventReceiveRun) r.run();
      if (direct_out != null) direct_out.send(p);
    }
  }
  
  ArrayList<Runnable> eventReceiveRun = new ArrayList<Runnable>();
  Macro_Input addEventReceive(Runnable r)    { eventReceiveRun.add(r); return this; }
  Macro_Input removeEventReceive(Runnable r) { eventReceiveRun.remove(r); return this; }
  
  Macro_Output direct_out = null;
  void direct_connect(Macro_Output o) { direct_out = o; }
  
  String filter = null;
  
  Macro_Input setFilter(String f) {
    filter = copy(f);
    return this; }
  Macro_Input clearFilter() {
    filter = null;
    return this; }
  Macro_Input setFilterBang() {
    filter = "bang";
    return this; }
  Macro_Input setFilterInt() {
    filter = "int";
    return this; }
  Macro_Input setFilterFloat() {
    filter = "float";
    return this; }
  Macro_Input setFilterNumber() { //int and float
    filter = "num";
    return this; }
  Macro_Input setFilterBool() {
    filter = "bool";
    return this; }
  Macro_Input setFilterValue() { //bool int and float
    filter = "val";
    return this; }
}





 
 
