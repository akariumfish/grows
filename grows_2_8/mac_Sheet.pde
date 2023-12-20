
//import java.util.Map;

///*

// extend l'objet macro abstract
 
// can create child macro inside
 
// peut ce cree des interconnections entre sont plan et le plan du parent 
 
// peut etre reduit cachant sont plan interne 
 
// background englobe automatiquement sont plan 
 
// */


//class Macro_Sheet extends Macro_Abstract {
//  nWidget  reduc; 

//  ArrayList<Macro_Sheet_Input> sheet_inputs = new ArrayList<Macro_Sheet_Input>(0);
//  ArrayList<Macro_Sheet_Output> sheet_outputs = new ArrayList<Macro_Sheet_Output>(0);

//  int sheet_inCount = 0;
//  int sheet_outCount = 0;

//  ArrayList<Macro_Input> inputs = new ArrayList<Macro_Input>(0);
//  ArrayList<Macro_Output> outputs = new ArrayList<Macro_Output>(0);

//  ArrayList<Macro_Abstract> child_macro = new ArrayList<Macro_Abstract>(0);

//  boolean isReduc = false;
  
//  Macro_Sheet setTitle(String t) {
//    grabber.setText(t);
//    return this;
//  }
  
//  void reduc() {
//    isReduc = true;
//    selectable = true;
//    setWidth(ref_size*4);
//    back.setStandbyColor(color(50, 200));
//    front.show()
//      .setOutlineColor(color(255))
//      .setOutline(false)
//      .setOutlineWeight(ref_size/15);
//    if (mmain().selecting_sheet == this) { 
//      mmain().selecting_sheet = null;
//      for (Macro_Abstract m : mmain().selected_macro) { m.selected = false; m.front.setOutline(false); }
//      mmain().selected_macro.clear();
//    }
//    for (Macro_Abstract m : child_macro) m.parentReduc();
//    for (Macro_Sheet_Input m : sheet_inputs) m.reduc();
//    for (Macro_Sheet_Output m : sheet_outputs) m.reduc();
//    childDragged();
//  }
//  void enlarg() {
//    isReduc = false;
//    selectable = false;
//    setWidth(ref_size*8);
//    back.show().setStandbyColor(color(150, 60));
//    front.setOutlineColor(color(200, 200, 0))
//      .setOutlineWeight(ref_size/10);
//    mmain().selected_macro.remove(this);
//    for (Macro_Abstract m : child_macro) m.parentEnlarg();
//    for (Macro_Sheet_Input m : sheet_inputs) m.enlarg();
//    for (Macro_Sheet_Output m : sheet_outputs) m.enlarg();
//    childDragged();
//  }
  
//  void parentReduc() {
//    super.parentReduc();
//    for (Macro_Abstract m : child_macro) m.parentReduc();
//  }
//  void parentEnlarg() {
//    super.parentEnlarg();
//    if (isReduc) reduc(); 
//    else { 
//      enlarg();
//      for (Macro_Abstract m : child_macro) m.parentEnlarg(); 
//    }
//  }
  
//  void show() {
//    super.show();
//    if (isReduc) reduc(); 
//    else { 
//      enlarg();
//      for (Macro_Abstract m : child_macro) m.parentEnlarg(); 
//    }
//  }
//  void hide() {
//    super.hide();
//    for (Macro_Sheet_Input m : sheet_inputs) m.hide();
//    for (Macro_Sheet_Output m : sheet_outputs) m.hide();
//  }
  
//  sValueBloc sheet_data;
//  void init_databloc() {
//    if (parent != null) sheet_data = new sValueBloc(parent.sheet_data, "Sheet_"+grabber.getText());
//  }
  
//  Macro_Sheet(nGUI _gui, Macro_Sheet p, float x, float y, String tit) {
//    super(_gui, p, "sheet", x, y);
  
//    back.setSize(ref_size*3, ref_size * 0.75)
//      .setStandbyColor(color(150, 60))
//      .setPassif();
//    closer.setSX(ref_size);
//    closer.setParent(grabber);
//    grabber.setText(tit);
    
//    //front.hide();
//    selectable = false;
//    front.setOutlineColor(color(200, 200, 0))
//      .setOutlineWeight(ref_size/10);
    
//    if (mmain() != this) {
//      mmain().szone.addEventStartSelect(new Runnable() { public void run() { 
        
//      } } );
//      mmain().szone.addEventEndSelect(new Runnable() { public void run() { 
        
//      } } );
//    }
//    front.addEventFrame(new Runnable(this) { public void run() { 
//      if (mmain().selected_macro.size() == 0 && mmain().szone.isSelecting()) {
//        if ((mmain().selecting_sheet == null || mmain().selecting_sheet.sheet_depth < sheet_depth) && mmain().szone.isUnder(front)) {
//          mmain().selecting_sheet = (Macro_Sheet)builder;
//          front.setOutline(true);
//        }
//        if (!(mmain().selecting_sheet == (Macro_Sheet)builder)) front.setOutline(false);
//      } 
//    } } );

//    setWidth(ref_size*8);

//    reduc = new nWidget(_gui, "-", int(ref_size/1.5), 0, 0, ref_size, ref_size * 0.75)
//      .setTrigger()
//      .setParent(grabber)
//      .setLayer(layer)
//      .stackLeft()
//      .setOutlineColor(color(100))
//      .setOutlineWeight(ref_size / 16)
//      .setOutline(true)
//      .addEventTrigger(new Runnable() { 
//      public void run() {
//        if (isReduc) enlarg(); 
//        else reduc();
//       // childDragged();
//      }
//    }
//    )
//    ;
//    childDragged();
    
//    init_databloc();
//  }
  
//  Macro_Input getInputByIndex(int i) {
//    for (Macro_Input m : inputs) if (m.index == i) return m;
//    return null;
//  }
//  Macro_Output getOutputByIndex(int i) {
//    for (Macro_Output m : outputs) if (m.index == i) return m;
//    return null;
//  }

//  int getFreeInputIndex() {
//    int i = 0;
//    boolean found = false;
//    while (!found) {
//      int t = i;
//      for (Macro_Input m : inputs) if (m.index == i) i++;
//      if (t == i) found = true;
//    }
//    return i;
//  }

//  int getFreeOutputIndex() {
//    int i = 0;
//    boolean found = false;
//    while (!found) {
//      int t = i;
//      for (Macro_Output m : outputs) if (m.index == i) i++;
//      if (t == i) found = true;
//    }
//    return i;
//  }
  
//  ArrayList<nWidget> phantom_widgets = new ArrayList<nWidget>();

//  void childDragged() {
//    float minx = 0, miny = 0, maxx = grabber.getLocalSX() + ref_size, maxy = ref_size*1.75;
//    if (isReduc) { maxx = ref_size*3; maxy = 0;}
//    if (!isReduc) for (nWidget w : phantom_widgets) if (!w.isHided()) {
//      if (minx > w.getLocalX()) 
//        minx = w.getLocalX();
//      if (miny > w.getLocalY()) 
//        miny = w.getLocalY();
//      if (maxx < w.getLocalX() + w.getSX()) 
//        maxx = w.getLocalX() + w.getSX();
//      if (maxy < w.getLocalY() + w.getSY()) 
//        maxy = w.getLocalY() + w.getSY();
//    }
//    for (Macro_Abstract m : child_macro) if (!m.isHided) {
//      if (minx > m.grabber.getLocalX() + m.back.getLocalX()) 
//        minx = m.grabber.getLocalX() + m.back.getLocalX();
//      if (miny > m.grabber.getLocalY() + m.back.getLocalY()) 
//        miny = m.grabber.getLocalY() + m.back.getLocalY();
//      if (maxx < m.grabber.getLocalX() + m.back.getLocalX() + m.getW()) 
//        maxx = m.grabber.getLocalX() + m.back.getLocalX() + m.getW();
//      if (maxy < m.grabber.getLocalY() + m.back.getLocalY() + m.getH()) 
//        maxy = m.grabber.getLocalY() + m.back.getLocalY() + m.getH();
//    }
//    if (!isReduc && maxy < max(inCount, outCount) * ref_size * 1.25 + ref_size * 0.75)
//      maxy = max(inCount, outCount) * ref_size * 1.25 + ref_size * 0.75;

//    for (Macro_Sheet_Input m : sheet_inputs) {
//      if (maxy < m.grabber.getLocalY() + inputs_ref.getLocalY() + m.grabber.getLocalSY() + ref_size*0.125)
//        maxy = m.grabber.getLocalY() + inputs_ref.getLocalY() + m.grabber.getLocalSY() + ref_size*0.125;
//      if (miny > m.grabber.getLocalY() + inputs_ref.getLocalY() + ref_size*1.375)
//        miny = m.grabber.getLocalY() + inputs_ref.getLocalY() + ref_size*1.375;
//    }
//    for (Macro_Sheet_Output m : sheet_outputs) {
//      if (maxy < m.grabber.getLocalY() + outputs_ref.getLocalY() + m.grabber.getLocalSY() + ref_size*0.125)
//        maxy = m.grabber.getLocalY() + outputs_ref.getLocalY() + m.grabber.getLocalSY() + ref_size*0.125;
//      if (miny > m.grabber.getLocalY() + outputs_ref.getLocalY() + ref_size*1.375)
//        miny = m.grabber.getLocalY() + outputs_ref.getLocalY() + ref_size*1.375;
//    }
//    if (isReduc) {
//      back.setPosition(minx - ref_size, miny);
//      back.setSize(maxx - minx + ref_size*2.25, maxy - miny + ref_size*0.75);
//      inputs_ref.setPX(minx + ref_size * 1 / 8);
//      outputs_ref.setPX(maxx + ref_size*0.875);
//    } else {
//      back.setPosition(minx - ref_size*5, miny - ref_size);
//      back.setSize(maxx - minx + ref_size*9.5, maxy - miny + ref_size*2);
//      inputs_ref.setPX(minx - ref_size * 31 / 8);
//      outputs_ref.setPX(maxx + ref_size * 27 / 8);
//    }
//    if (parent != null) parent.childDragged();
//  }

//  Macro_Sheet_Input addSheetInput() {
//    Macro_Sheet_Input m = new Macro_Sheet_Input(gui, parent, this);
//    childDragged();
//    return m;
//  }

//  Macro_Sheet_Output addSheetOutput() {
//    Macro_Sheet_Output m = new Macro_Sheet_Output(gui, parent, this);
//    childDragged();
//    return m;
//  }
//  Macro_Sheet addSheet(String t) {
//    Macro_Sheet m = new Macro_Sheet(gui, this, 0, ref_size*1.25, t);
//    adding(m); 
//    return m;
//  }
//  Macro_Sheet addSheet() {
//    Macro_Sheet m = new Macro_Sheet(gui, this, 0, ref_size*1.25, "");
//    adding(m); 
//    return m;
//  }
//  Macro_Delay addDelay() {
//    Macro_Delay m = new Macro_Delay(gui, this, 0, 0);
//    adding(m); 
//    return m;
//  }
//  Macro_Bang addBang() {
//    Macro_Bang m = new Macro_Bang(gui, this, 0, 0);
//    adding(m); 
//    return m;
//  }
//  Macro_Switch addSwitch() {
//    Macro_Switch m = new Macro_Switch(gui, this, 0, 0);
//    adding(m); 
//    return m;
//  }
//  Macro_Pulse addPulse() {
//    Macro_Pulse m = new Macro_Pulse(gui, this, 0, 0);
//    adding(m); 
//    return m;
//  }
//  Macro_Bool addBool() {
//    Macro_Bool m = new Macro_Bool(gui, this, 0, 0);
//    adding(m); 
//    return m;
//  }
//  Macro_Value addValue() {
//    Macro_Value m = new Macro_Value(gui, this, 0, 0);
//    adding(m); 
//    return m;
//  }
//  Macro_Comp addComp() {
//    Macro_Comp m = new Macro_Comp(gui, this, 0, 0);
//    adding(m); 
//    return m;
//  }
//  Macro_Calc addCalc() {
//    Macro_Calc m = new Macro_Calc(gui, this, 0, 0);
//    adding(m); 
//    return m;
//  }
//  Macro_Not addNot() {
//    Macro_Not m = new Macro_Not(gui, this, 0, 0);
//    adding(m); 
//    return m;
//  }
//  Macro_Bin addBin() {
//    Macro_Bin m = new Macro_Bin(gui, this, 0, 0);
//    adding(m); 
//    return m;
//  }
//  Macro_Vec addVec() {
//    Macro_Vec m = new Macro_Vec(gui, this, 0, 0);
//    adding(m); 
//    return m;
//  }
//  Macro_Gate addGate() {
//    Macro_Gate m = new Macro_Gate(gui, this, 0, 0);
//    adding(m); 
//    return m;
//  }
//  Macro_Keyboard addKeyboard() {
//    Macro_Keyboard m = new Macro_Keyboard(gui, this, 0, 0);
//    adding(m); 
//    return m;
//  }
//  Macro_Comment addComment() {
//    Macro_Comment m = new Macro_Comment(gui, this, 0, 0);
//    adding(m); 
//    return m;
//  }
//  Macro_Custom addCustom() {
//    Macro_Custom m = new Macro_Custom(gui, this, 0, 0);
//    //adding(m); 
//    return m;
//  }
//  Macro_Custom addLinkedValue(sValue v) {
//    Macro_Custom m = new Macro_Custom(gui, this, 0, 0);
//    m.addValueWatcher().setValue(v);
//    m.addValueController().setValue(v);
//    adding(m); 
//    return m;
//  }
//  sInt newLinkedInt(int v, String n, String s) { 
//    sInt i = new sInt(sheet_data, v, n, s);
//    addLinkedValue(i); return i; }
//  sFlt newLinkedFlt(float v, String n, String s) { 
//    sFlt i = new sFlt(sheet_data, v, n, s);
//    addLinkedValue(i); return i; }
//  sBoo newLinkedBoo(boolean v, String n, String s) { 
//    sBoo i = new sBoo(sheet_data, v, n, s);
//    addLinkedValue(i); return i; }
//  sStr newLinkedStr(String v, String n, String s) { 
//    sStr i = new sStr(sheet_data, v, n, s);
//    addLinkedValue(i); return i; }
//  sVec newLinkedVec(PVector v, String n, String s) { 
//    sVec i = new sVec(sheet_data, n, s).set(v);
//    addLinkedValue(i); return i; }
//  sRun newLinkedRun(String n, String s, Runnable v) { 
//    sRun i = new sRun(sheet_data, n, s, v);
//    addLinkedValue(i); return i; }
  
//  void adding(Macro_Abstract m) {
//    float add_pos = m.grabber.getLocalY() + ref_size*2;
//    boolean found = false;
//    while (!found) {
//      m.grabber.setPosition(0, add_pos);
//      add_pos += ref_size*0.5;
//      boolean col = false;
//      for (Macro_Abstract c : child_macro)
//        if (m != c && rectCollide(m.back.getRect(), c.back.getRect())) col = true;
//      if (!col) found = true;
//    }

//    m.setLayer(layer+2);
//    m.toLayerTop();
//    childDragged();
//  }
  
//  void setLayer(int l) {
//    super.setLayer(l);
//    reduc.setLayer(l);
//    for (Macro_Sheet_Input m : sheet_inputs) m.setLayer(l);
//    for (Macro_Sheet_Output m : sheet_outputs) m.setLayer(l);
//  }
//  void toLayerTop() {
//    super.toLayerTop();
//    reduc.toLayerTop();
//    for (Macro_Sheet_Input m : sheet_inputs) m.toLayerTop();
//    for (Macro_Sheet_Output m : sheet_outputs) m.toLayerTop();
//  }
//  void clear() {
//    super.clear(); 
//    reduc.clear(); 

//    for (int i = child_macro.size() - 1; i >= 0; i--) child_macro.get(i).clear(); 
//    for (int i = inputs.size() - 1; i >= 0; i--) inputs.get(i).clear(); 
//    inputs.clear(); 
//    for (int i = outputs.size() - 1; i >= 0; i--) outputs.get(i).clear(); 
//    outputs.clear(); 

//    for (int i = sheet_inputs.size() - 1; i >= 0; i--) sheet_inputs.get(i).clear(); 
//    for (int i = sheet_outputs.size() - 1; i >= 0; i--) sheet_outputs.get(i).clear();
    
//    sheet_data.clear();
//  }
  
//  void empty() {
//    for (int i = child_macro.size() - 1; i >= 0; i--) child_macro.get(i).clear();
//    for (int i = inputs.size() - 1; i >= 0; i--) inputs.get(i).clear(); 
//    inputs.clear();
//    for (int i = outputs.size() - 1; i >= 0; i--) outputs.get(i).clear(); 
//    outputs.clear();

//    for (int i = sheet_inputs.size() - 1; i >= 0; i--) sheet_inputs.get(i).clear();
//    for (int i = sheet_outputs.size() - 1; i >= 0; i--) sheet_outputs.get(i).clear();
    
//    childDragged();
//  }
  
//  Save_Bloc sheet_savebloc;
//  void save_to_templates() {
//    mlog("templ save " + grabber.getText());
//    if (sheet_savebloc != null) sheet_savebloc.clear();
//    sheet_savebloc = mmain().templates_sbloc.newBloc("Tmplt_"+grabber.getText());
//    PVector p = new PVector(grabber.getLocalX(), grabber.getLocalY());
//    grabber.setPosition(0, 0);
//    to_save(sheet_savebloc);
//    grabber.setPosition(p.x, p.y);
//  }
  
//  void to_save(Save_Bloc sbloc) {
//    clean_links();
    
//    mlogln("to save");
//    //name title pos extco index
//    super.to_save(sbloc);
    
//    //sheet co
//    Save_Bloc sheetin_blocs = sbloc.newBloc("sheet in");
//    for (Macro_Sheet_Input m : sheet_inputs) { m.to_save(sheetin_blocs); }
//    Save_Bloc sheetout_blocs = sbloc.newBloc("sheet out");
//    for (Macro_Sheet_Output m : sheet_outputs) { m.to_save(sheetout_blocs); }
    
//    //child
//    Save_Bloc child_blocs = sbloc.newBloc("childs");
//    for (Macro_Abstract m : child_macro) { m.to_save(child_blocs.newBloc("child")); }
    
//    //links
//    Save_Bloc links_bloc = sbloc.newBloc("links");
//    for (Macro_Output o : outputs) for (Macro_Input i : o.connected_inputs) {
//      Save_Bloc b = links_bloc.newBloc("link");
//      b.newData("out", o.index); b.newData("in", i.index); }
    
//    //isreduc
//    sbloc.newData("reduc", isReduc);
    
//  }
  
//  void clean_links() {
//    int cnt = 0;
//    for (Macro_Output o : outputs) { o.index = cnt; cnt++; }
//    cnt = 0;
//    for (Macro_Input i : inputs) { i.index = cnt; cnt++; }
//    for (Macro_Abstract m : child_macro) m.clean_links();
//  }
  
//  void from_save(Save_Bloc sbloc) {
//    //name title pos extco index
//    super.from_save(sbloc);
    
//    //sheet co
//    Save_Bloc sheetin_blocs = sbloc.getBloc("sheet in");
//    if (sheetin_blocs != null) sheetin_blocs.runIterator(new Iterator<Save_Bloc>() { 
//      public void run(Save_Bloc bloc) { addSheetInput().from_save(bloc); } } );
//    Save_Bloc sheetout_blocs = sbloc.getBloc("sheet out");
//    if (sheetout_blocs != null) sheetout_blocs.runIterator(new Iterator<Save_Bloc>() { 
//      public void run(Save_Bloc bloc) { addSheetOutput().from_save(bloc); } } );
    
//    //child
//    Save_Bloc childs_blocs = sbloc.getBloc("childs");
//    if (childs_blocs != null) childs_blocs.runIterator(new Iterator<Save_Bloc>() { 
//      public void run(Save_Bloc bloc) { 
//        if      (bloc.getData("name").equals("sheet"))  addSheet().from_save(bloc);
//        else if (bloc.getData("name").equals("bang"))   addBang().from_save(bloc);
//        else if (bloc.getData("name").equals("switch")) addSwitch().from_save(bloc);
//        else if (bloc.getData("name").equals("delay"))  addDelay().from_save(bloc);
//        else if (bloc.getData("name").equals("pulse"))  addPulse().from_save(bloc);
//        else if (bloc.getData("name").equals("value"))  addValue().from_save(bloc);
//        else if (bloc.getData("name").equals("calc"))   addCalc().from_save(bloc);
//        else if (bloc.getData("name").equals("comp"))   addComp().from_save(bloc);
//        else if (bloc.getData("name").equals("bool"))   addBool().from_save(bloc);
//        else if (bloc.getData("name").equals("not"))    addNot().from_save(bloc);
//        else if (bloc.getData("name").equals("bin"))    addBin().from_save(bloc);
//        else if (bloc.getData("name").equals("key"))    addKeyboard().from_save(bloc);
//        else if (bloc.getData("name").equals("gate"))   addGate().from_save(bloc);
//        else if (bloc.getData("name").equals("com"))    addComment().from_save(bloc);
//        else if (bloc.getData("name").equals("vec"))    addVec().from_save(bloc);
//        else if (bloc.getData("name").equals("custom")) { 
//          Macro_Custom m = addCustom(); 
//          m.from_save(bloc); 
//          m.setLayer(layer+2);
//          m.toLayerTop(); }
//    } } );
    
//    //link
//    Save_Bloc links_blocs = sbloc.getBloc("links");
//    if (links_blocs != null) links_blocs.runIterator(new Iterator<Save_Bloc>() { 
//      public void run(Save_Bloc bloc) { 
//        Macro_Output o = getOutputByIndex(bloc.getInt("out"));
//        Macro_Input i = getInputByIndex(bloc.getInt("in"));
//        if (o != null && i != null) o.connect_to(i);
//      } } );
    
//    //isreduc
//    if (sbloc.getBoolean("reduc")) reduc(); else childDragged();
    
//  }
//}
