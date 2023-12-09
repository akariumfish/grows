


/*

 extend l'objet macro abstract
 
 menu de creation de nouvelle macro a l'interieur
 == dans sont plan de connection interne
 sheet
 bang
 switch
 delay
 pulse
 
 todo:
 bool val comp calc
 
 peut ce cree des interconnections entre sont plan et le plan du parent 
 
 peut etre reduit cachant sont plan interne 
 
 background englobe automatiquement sont plan 
 
 */


class Macro_Sheet extends Macro_Abstract {
  nWidget  sclear, sfield, ssheet, reduc, addSheet, addExtIn, addExtOut, smenu, menu, tmenu, 
           templates, tfield, tselect, tup, tdown; 


  ArrayList<Macro_Sheet_Input> sheet_inputs = new ArrayList<Macro_Sheet_Input>(0);
  ArrayList<Macro_Sheet_Output> sheet_outputs = new ArrayList<Macro_Sheet_Output>(0);

  int sheet_inCount = 0;
  int sheet_outCount = 0;

  ArrayList<Macro_Input> inputs = new ArrayList<Macro_Input>(0);
  ArrayList<Macro_Output> outputs = new ArrayList<Macro_Output>(0);

  ArrayList<Macro_Abstract> child_macro = new ArrayList<Macro_Abstract>(0);

  String savepath = "save.txt";
  String templatepath = "templates";

  ArrayList<nWidget> subMenuWidgets = new ArrayList<nWidget>();
  ArrayList<nWidget> subHeadWidgets = new ArrayList<nWidget>();

  boolean isReduc = false;
  void reduc() {
    isReduc = true;
    setWidth(macro_size*4);
    //for (nWidget w : menubuttons) w.hide();
    if (menubuttons.size() > 0) menubuttons.get(0).hide();
    //closer.show();
    for (Macro_Abstract m : child_macro) m.hide();
    for (Macro_Sheet_Input m : sheet_inputs) m.reduc();
    for (Macro_Sheet_Output m : sheet_outputs) m.reduc();
    childDragged();
  }
  void enlarg() {
    isReduc = false;
    setWidth(macro_size*8);
    for (Macro_Abstract m : child_macro) m.show();
    for (Macro_Sheet_Input m : sheet_inputs) m.enlarg();
    for (Macro_Sheet_Output m : sheet_outputs) m.enlarg();
    //for (nWidget w : menubuttons) w.show();
    if (menubuttons.size() > 0) menubuttons.get(0).show();
    //addSheet.hide();
    //sclear.hide();
    //templates.hide();
    for (nWidget w : subHeadWidgets) w.hide();
    getBase().menugroup.closeAll();
    childDragged();
  }
  
  void show() {
    super.show();
    for (nWidget w : subHeadWidgets) w.hide();
    //for (Macro_Abstract m : child_macro) m.show();
  }
  void hide() {
    super.hide();
    //for (nWidget w : subHeadWidgets) w.hide();
  }
  
  ArrayList<nWidget> menubuttons = new ArrayList<nWidget>(0);

  nWidget newMenu(String name) {
    float new_width = (sheet_width + macro_size*1.25) / (menubuttons.size() + 1);
    nWidget menu = new nWidget(gui, name, int(macro_size/1.85), 0, 0, new_width, macro_size * 0.75)
      .setSwitch()
      .setLayer(layer)
      .setOutlineColor(color(100))
      .setOutlineWeight(macro_size / 16)
      .setOutline(true)
      ;
    if (menubuttons.size() == 0) menu.setParent(reduc).stackDown();
    else menu.setParent(menubuttons.get(menubuttons.size()-1)).stackRight();
    for (nWidget w : menubuttons) w.setSX(new_width);
    menubuttons.add(menu);
    return menu;
  }
  
  Macro_Abstract setWidth(float w) {
    super.setWidth(w);
    float new_width = (sheet_width + macro_size*1.25) / (menubuttons.size());
    for (nWidget m : menubuttons) m.setSX(new_width);
    return this;
  }

  ArrayList<nWidget> addbuttons = new ArrayList<nWidget>(0);

  Macro_Sheet newAdd(String name, Runnable run) {
    nWidget add = new nWidget(gui, name, int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setLayer(getBase().menu_layer)
      .stackDown()
     // .hide()
      .addEventTrigger(new Runnable() { 
      public void run() { 
        getBase().menugroup.closeAll();
      }
    }
    )
    .addEventTrigger(run)
      ;
    if (addbuttons.size() == 0) add.setParent(addExtOut);
    else add.setParent(addbuttons.get(addbuttons.size()-1));
    addbuttons.add(add);
    return this;
  }

  Macro_Sheet(nGUI _gui, Macro_Sheet p, float x, float y) {
    super(_gui, p, "sheet", x, y);

    back.setSize(macro_size*3, macro_size * 0.75);
    closer.setSX(macro_size);
    closer.setParent(grabber);
    grabber.setText("");

    setWidth(macro_size*8);

    reduc = new nWidget(_gui, "-", int(macro_size/1.5), 0, 0, macro_size, macro_size * 0.75)
      .setTrigger()
      .setParent(grabber)
      .setLayer(layer)
      .stackLeft()
      .setOutlineColor(color(100))
      .setOutlineWeight(macro_size / 16)
      .setOutline(true)
      .addEventTrigger(new Runnable() { 
      public void run() {
        if (isReduc) enlarg(); 
        else reduc();
       // childDragged();
      }
    }
    )
    ;
    menu = newMenu("New")
      .addEventSwitchOn(new Runnable() { 
      public void run() {
        addSheet.show();
      }
    }
    )
    .addEventSwitchOff(new Runnable() { 
      public void run() {
        addSheet.hide();
      }
    }
    )
    ;
    addSheet = new nWidget(_gui, "Sheet", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(menu)
      .setLayer(getBase().menu_layer)
      .stackDown()
     // .hide()
      .addEventTrigger(new Runnable() { 
      public void run() {
        getBase().menugroup.closeAll();
        addSheet();
      }
    }
    )
    ;
    addExtIn = new nWidget(_gui, "Input", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(addSheet)
      .setLayer(getBase().menu_layer)
      .stackDown()
     // .hide()
      .addEventTrigger(new Runnable(this) { 
      public void run() {
        getBase().menugroup.closeAll();
        addSheetInput();
      }
    }
    )
    ;
    addExtOut = new nWidget(_gui, "Output", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(addExtIn)
      .setLayer(getBase().menu_layer)
      .stackDown()
     // .hide()
      .addEventTrigger(new Runnable(this) { 
      public void run() {
        getBase().menugroup.closeAll();
        addSheetOutput();
      }
    }
    )
    ;

    newAdd("bang", new Runnable() { 
      public void run() { 
        addBang();
      }
    }
    );
    newAdd("switch", new Runnable() { 
      public void run() { 
        addSwitch();
      }
    }
    );
    newAdd("delay", new Runnable() { 
      public void run() { 
        addDelay();
      }
    }
    );
    newAdd("pulse", new Runnable() { 
      public void run() { 
        addPulse();
      }
    }
    );
    newAdd("bool", new Runnable() { 
      public void run() { 
        addBool();
      }
    }
    );
    newAdd("value", new Runnable() { 
      public void run() { 
        addValue();
      }
    }
    );
    newAdd("comp", new Runnable() { 
      public void run() { 
        addComp();
      }
    }
    );
    newAdd("calc", new Runnable() { 
      public void run() { 
        addCalc();
      }
    }
    );
    newAdd("not", new Runnable() { 
      public void run() { 
        addNot();
      }
    }
    );
    newAdd("key", new Runnable() { 
      public void run() { 
        addKeyboard();
      }
    }
    );

    smenu = newMenu("File")
      .addEventSwitchOn(new Runnable() { 
      public void run() {
        sclear.show();
      }
    }
    )
    .addEventSwitchOff(new Runnable() { 
      public void run() {
        sclear.hide();
      }
    }
    )
    ;
    
    sclear = new nWidget(_gui, "clear", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(smenu)
      .setLayer(getBase().menu_layer)
      .stackDown()
     // .hide()
      .addEventTrigger(new Runnable() { 
      public void run() {
        empty();
        getBase().menugroup.closeAll();
      }
    }
    )
    ;
    sfield = new nWidget(_gui, 0, 0, macro_size*5, macro_size)
      .setParent(sclear)
      .stackDown()
      .setLayer(getBase().menu_layer)
      .setFont(int(macro_size/1.5))
      .setText(savepath)
      .setField(true)
     // .hide()
      .addEventFieldChange(new Runnable() { 
      public void run() {
        savepath = sfield.getText();
      }
    }
    )
    ;
    
    ssheet = new nWidget(_gui, "as sheet", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(sfield)
      .setLayer(getBase().menu_layer)
      .stackDown()
     // .hide()
      .addEventTrigger(new Runnable() { 
      public void run() {
        sdata_load_as();
        //do_load_as();
        childDragged();
        getBase().menugroup.closeAll();
      }
    }
    )
    ;
    
    
    
    
    //tmenu = newMenu("Templates")
    //  .addEventSwitchOn(new Runnable() { 
    //  public void run() {
    //    tfield.show();
    //  }
    //}
    //)
    //.addEventSwitchOff(new Runnable() { 
    //  public void run() {
    //    tfield.hide();
    //  }
    //}
    //)
    //;
    
    //tfield = new nWidget(_gui, 0, 0, macro_size*5, macro_size)
    //  .setParent(tmenu)
    //  .stackDown()
    //  .setLayer(getBase().menu_layer)
    //  .setFont(int(macro_size/1.5))
    //  .setText(templatepath)
    //  .setField(true)
    //  .addEventFieldChange(new Runnable() { 
    //  public void run() {
    //    templatepath = tfield.getText();
    //  } } ) ;
    //subMenuWidgets.add(tfield);
    //subHeadWidgets.add(tfield);
    
    //templates = new nWidget(_gui, "load", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
    //  .setParent(tfield)
    //  .setLayer(getBase().menu_layer)
    //  .setTrigger()
    //  .stackDown().addEventTrigger(new Runnable() { 
    //  public void run() {
    //    //getBase().menugroup.closeAll();
    //  }
    //}
    //)
    //;
    //tup = new nWidget(_gui, "up", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
    //  .setParent(templates)
    //  .setLayer(getBase().menu_layer)
    //  .setTrigger()
    //  .stackDown().addEventTrigger(new Runnable() { 
    //  public void run() {
    //    //getBase().menugroup.closeAll();
    //  }
    //}
    //)
    //;
    //tselect = new nWidget(_gui, "--", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
    //  .setParent(tup)
    //  .setLayer(getBase().menu_layer)
    //  .setTrigger()
    //  .stackDown().addEventTrigger(new Runnable() { 
    //  public void run() {
    //    //getBase().menugroup.closeAll();
    //  }
    //}
    //)
    //;
    
    //tdown = new nWidget(_gui, "down", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
    //  .setParent(tselect)
    //  .setLayer(getBase().menu_layer)
    //  .setTrigger()
    //  .stackDown().addEventTrigger(new Runnable() { 
    //  public void run() {
    //    //getBase().menugroup.closeAll();
    //  }
    //}
    //)
    //;
    
    //subMenuWidgets.add(tup);
    //subMenuWidgets.add(tselect);
    //subMenuWidgets.add(tdown);
    
    
    subMenuWidgets.add(addSheet);
    subMenuWidgets.add(addExtIn);
    subMenuWidgets.add(addExtOut);
    subMenuWidgets.add(sclear);
    subMenuWidgets.add(sfield);
    subMenuWidgets.add(ssheet);
    //subMenuWidgets.add(templates);
    
    subHeadWidgets.add(addSheet);
    subHeadWidgets.add(sclear);
    //subHeadWidgets.add(templates);
    
    for (nWidget w : subHeadWidgets) w.hide();
    //addSheet.hide(); sclear.hide(); templates.hide();
    
    if (getBase().menugroup != null) {
      for (nWidget w : menubuttons) getBase().menugroup.add(w);
    }
    childDragged();
  }

  Macro_Input getInputByIndex(int i) {
    for (Macro_Input m : inputs) if (m.index == i) return m;
    return null;
  }
  Macro_Output getOutputByIndex(int i) {
    for (Macro_Output m : outputs) if (m.index == i) return m;
    return null;
  }

  int getFreeInputIndex() {
    int i = 0;
    boolean found = false;
    while (!found) {
      int t = i;
      for (Macro_Input m : inputs) if (m.index == i) i++;
      if (t == i) found = true;
    }
    return i;
  }

  int getFreeOutputIndex() {
    int i = 0;
    boolean found = false;
    while (!found) {
      int t = i;
      for (Macro_Output m : outputs) if (m.index == i) i++;
      if (t == i) found = true;
    }
    return i;
  }

  void childDragged() {
    float minx = 0, miny = 0, maxx = grabber.getLocalSX() + macro_size, maxy = macro_size*1.75;
    if (isReduc) { maxx = macro_size*3; maxy = 0;}
    for (Macro_Abstract m : child_macro) if (!m.isHided) {
      if (minx > m.grabber.getLocalX() + m.back.getLocalX()) 
        minx = m.grabber.getLocalX() + m.back.getLocalX();
      if (miny > m.grabber.getLocalY() + m.back.getLocalY()) 
        miny = m.grabber.getLocalY() + m.back.getLocalY();
      if (maxx < m.grabber.getLocalX() + m.back.getLocalX() + m.getW()) 
        maxx = m.grabber.getLocalX() + m.back.getLocalX() + m.getW();
      if (maxy < m.grabber.getLocalY() + m.back.getLocalY() + m.getH()) 
        maxy = m.grabber.getLocalY() + m.back.getLocalY() + m.getH();
    }
    if (!isReduc && maxy < max(inCount, outCount) * macro_size * 1.25 + macro_size * 0.75)
      maxy = max(inCount, outCount) * macro_size * 1.25 + macro_size * 0.75;

    for (Macro_Sheet_Input m : sheet_inputs) {
      if (maxy < m.grabber.getLocalY() + inputs_ref.getLocalY() + m.grabber.getLocalSY() + macro_size*0.125)
        maxy = m.grabber.getLocalY() + inputs_ref.getLocalY() + m.grabber.getLocalSY() + macro_size*0.125;
      if (miny > m.grabber.getLocalY() + inputs_ref.getLocalY() + macro_size*1.375)
        miny = m.grabber.getLocalY() + inputs_ref.getLocalY() + macro_size*1.375;
    }
    for (Macro_Sheet_Output m : sheet_outputs) {
      if (maxy < m.grabber.getLocalY() + outputs_ref.getLocalY() + m.grabber.getLocalSY() + macro_size*0.125)
        maxy = m.grabber.getLocalY() + outputs_ref.getLocalY() + m.grabber.getLocalSY() + macro_size*0.125;
      if (miny > m.grabber.getLocalY() + outputs_ref.getLocalY() + macro_size*1.375)
        miny = m.grabber.getLocalY() + outputs_ref.getLocalY() + macro_size*1.375;
    }
    if (isReduc) {
      back.setPosition(minx - macro_size, miny);
      back.setSize(maxx - minx + macro_size*2.25, maxy - miny + macro_size*0.75);
      inputs_ref.setPX(minx + macro_size * 1 / 8);
      outputs_ref.setPX(maxx + macro_size*0.875);
    } else {
      back.setPosition(minx - macro_size*5, miny - macro_size);
      back.setSize(maxx - minx + macro_size*9.5, maxy - miny + macro_size*2);
      inputs_ref.setPX(minx - macro_size * 31 / 8);
      outputs_ref.setPX(maxx + macro_size * 27 / 8);
    }
    if (parent != null) parent.childDragged();
  }

  Macro_Sheet_Input addSheetInput() {
    Macro_Sheet_Input m = new Macro_Sheet_Input(gui, parent, this);
    childDragged();
    return m;
  }

  Macro_Sheet_Output addSheetOutput() {
    Macro_Sheet_Output m = new Macro_Sheet_Output(gui, parent, this);
    childDragged();
    return m;
  }

  Macro_Sheet addSheet() {
    Macro_Sheet m = new Macro_Sheet(gui, this, 0, macro_size*1.25);
    adding(m); 
    return m;
  }
  Macro_Delay addDelay() {
    Macro_Delay m = new Macro_Delay(gui, this, 0, 0);
    adding(m); 
    return m;
  }
  Macro_Bang addBang() {
    Macro_Bang m = new Macro_Bang(gui, this, 0, 0);
    adding(m); 
    return m;
  }
  Macro_Switch addSwitch() {
    Macro_Switch m = new Macro_Switch(gui, this, 0, 0);
    adding(m); 
    return m;
  }
  Macro_Pulse addPulse() {
    Macro_Pulse m = new Macro_Pulse(gui, this, 0, 0);
    adding(m); 
    return m;
  }
  Macro_Bool addBool() {
    Macro_Bool m = new Macro_Bool(gui, this, 0, 0);
    adding(m); 
    return m;
  }
  Macro_Value addValue() {
    Macro_Value m = new Macro_Value(gui, this, 0, 0);
    adding(m); 
    return m;
  }
  Macro_Comp addComp() {
    Macro_Comp m = new Macro_Comp(gui, this, 0, 0);
    adding(m); 
    return m;
  }
  Macro_Calc addCalc() {
    Macro_Calc m = new Macro_Calc(gui, this, 0, 0);
    adding(m); 
    return m;
  }
  Macro_Not addNot() {
    Macro_Not m = new Macro_Not(gui, this, 0, 0);
    adding(m); 
    return m;
  }
  Macro_Keyboard addKeyboard() {
    Macro_Keyboard m = new Macro_Keyboard(gui, this, 0, 0);
    adding(m); 
    return m;
  }

  void adding(Macro_Abstract m) {
    float add_pos = m.grabber.getLocalY() + macro_size*2;
    boolean found = false;
    while (!found) {
      m.grabber.setPosition(0, add_pos);
      add_pos += macro_size*0.375;
      boolean col = false;
      for (Macro_Abstract c : child_macro)
        if (m != c && rectCollide(m.back.getRect(), c.back.getRect())) col = true;
      if (!col) found = true;
    }

    m.setLayer(layer+2);
    m.toLayerTop();
    childDragged();
  }
  
  void setLayer(int l) {
    super.setLayer(l);
    reduc.setLayer(l);
    for (nWidget w : menubuttons) w.setLayer(l);
    //addSheet.setLayer(getBase().menu_layer);
    //addExtIn.setLayer(getBase().menu_layer);
    //addExtOut.setLayer(getBase().menu_layer);
    for (nWidget w : addbuttons) w.setLayer(getBase().menu_layer);
    for (nWidget w : subMenuWidgets) w.setLayer(getBase().menu_layer);
    //sfield.setLayer(getBase().menu_layer);
    //ssave.setLayer(getBase().menu_layer);
    //sclear.setLayer(getBase().menu_layer);
    //ssheet.setLayer(getBase().menu_layer);
    //templates.setLayer(getBase().menu_layer);
    for (Macro_Sheet_Input m : sheet_inputs) m.setLayer(l);
    for (Macro_Sheet_Output m : sheet_outputs) m.setLayer(l);
  }
  void toLayerTop() {
    super.toLayerTop();
    reduc.toLayerTop();
    for (nWidget w : menubuttons) w.toLayerTop();
    //addSheet.toLayerTop();
    //addExtIn.toLayerTop();
    //addExtOut.toLayerTop();
    for (nWidget w : addbuttons) w.toLayerTop();
    for (nWidget w : subMenuWidgets) w.toLayerTop();
    //sfield.toLayerTop();
    //ssave.toLayerTop();
    //sclear.toLayerTop();
    //ssheet.toLayerTop();
    //templates.toLayerTop();
    for (Macro_Sheet_Input m : sheet_inputs) m.toLayerTop();
    for (Macro_Sheet_Output m : sheet_outputs) m.toLayerTop();
  }
  void clear() {
    super.clear(); 
    reduc.clear(); 
    for (int i = menubuttons.size() - 1; i >= 0; i--) menubuttons.get(i).clear(); 
    for (int i = subMenuWidgets.size() - 1; i >= 0; i--) subMenuWidgets.get(i).clear(); 
    //addSheet.clear(); 
    //addExtIn.clear(); 
    //addExtOut.clear(); 
    //templates.clear(); 
    for (int i = addbuttons.size() - 1; i >= 0; i--) addbuttons.get(i).clear(); 
    
    //sfield.clear(); 
    //ssave.clear(); 
    //ssheet.clear(); 
    //sclear.clear();

    for (int i = child_macro.size() - 1; i >= 0; i--) child_macro.get(i).clear(); 
    for (int i = inputs.size() - 1; i >= 0; i--) inputs.get(i).clear(); 
    inputs.clear(); 
    for (int i = outputs.size() - 1; i >= 0; i--) outputs.get(i).clear(); 
    outputs.clear(); 

    for (int i = sheet_inputs.size() - 1; i >= 0; i--) sheet_inputs.get(i).clear(); 
    for (int i = sheet_outputs.size() - 1; i >= 0; i--) sheet_outputs.get(i).clear();
  }
  
  void empty() {
    for (int i = child_macro.size() - 1; i >= 0; i--) child_macro.get(i).clear();
    for (int i = inputs.size() - 1; i >= 0; i--) inputs.get(i).clear(); 
    inputs.clear();
    for (int i = outputs.size() - 1; i >= 0; i--) outputs.get(i).clear(); 
    outputs.clear();

    for (int i = sheet_inputs.size() - 1; i >= 0; i--) sheet_inputs.get(i).clear();
    for (int i = sheet_outputs.size() - 1; i >= 0; i--) sheet_outputs.get(i).clear();
    
    childDragged();
  }
  
  void sdata_save() {
    Save_Bloc sbloc = new Save_Bloc("save");
    to_save(sbloc);
    sbloc.save_to(savepath);
  }
  
  void sdata_load() {
    empty();
    Save_Bloc sbloc = new Save_Bloc("load");
    sbloc.load_from(savepath);
    from_save(sbloc);
    childDragged();
  }
  
  void sdata_load_as() {
    Save_Bloc sbloc = new Save_Bloc("load");
    sbloc.load_from(savepath);
    Macro_Sheet m = addSheet();
    m.from_save(sbloc);
    m.grabber.setPosition(0, m.grabber.getLocalY() - m.back.getLocalY() + macro_size*1);
    adding(m);
    childDragged();
  }
  
  void to_save(Save_Bloc sbloc) {
    //name title pos extco index
    super.to_save(sbloc);
    
    //sheet co
    Save_Bloc sheetin_blocs = sbloc.newBloc("sheet in");
    for (Macro_Sheet_Input m : sheet_inputs) { m.to_save(sheetin_blocs); }
    Save_Bloc sheetout_blocs = sbloc.newBloc("sheet out");
    for (Macro_Sheet_Output m : sheet_outputs) { m.to_save(sheetout_blocs); }
    
    //child
    Save_Bloc child_blocs = sbloc.newBloc("childs");
    for (Macro_Abstract m : child_macro) { m.to_save(child_blocs.newBloc("child")); }
    
    //links
    Save_Bloc links_bloc = sbloc.newBloc("links");
    for (Macro_Output o : outputs) for (Macro_Input i : o.connected_inputs) {
      Save_Bloc b = links_bloc.newBloc("link");
      b.newData("out", o.index); b.newData("in", i.index); }
    
    //isreduc
    sbloc.newData("reduc", isReduc);
    
  }
  
  void from_save(Save_Bloc sbloc) {
    //name title pos extco index
    super.from_save(sbloc);
    
    //sheet co
    Save_Bloc sheetin_blocs = sbloc.getBloc("sheet in");
    if (sheetin_blocs != null) sheetin_blocs.runIterator(new Iterator<Save_Bloc>() { 
      public void run(Save_Bloc bloc) { addSheetInput().from_save(bloc); } } );
    Save_Bloc sheetout_blocs = sbloc.getBloc("sheet out");
    if (sheetout_blocs != null) sheetout_blocs.runIterator(new Iterator<Save_Bloc>() { 
      public void run(Save_Bloc bloc) { addSheetOutput().from_save(bloc); } } );
    
    //child
    Save_Bloc childs_blocs = sbloc.getBloc("childs");
    if (childs_blocs != null) childs_blocs.runIterator(new Iterator<Save_Bloc>() { 
      public void run(Save_Bloc bloc) { 
        if      (bloc.getData("name").equals("sheet"))  { Macro_Sheet m = addSheet(); m.from_save(bloc); }
        else if (bloc.getData("name").equals("bang"))   addBang().from_save(bloc);
        else if (bloc.getData("name").equals("switch")) addSwitch().from_save(bloc);
        else if (bloc.getData("name").equals("delay"))  addDelay().from_save(bloc);
        else if (bloc.getData("name").equals("pulse"))  addPulse().from_save(bloc);
        else if (bloc.getData("name").equals("value"))  addValue().from_save(bloc);
        else if (bloc.getData("name").equals("calc"))   addCalc().from_save(bloc);
        else if (bloc.getData("name").equals("comp"))   addComp().from_save(bloc);
        else if (bloc.getData("name").equals("bool"))   addBool().from_save(bloc);
        else if (bloc.getData("name").equals("not"))    addNot().from_save(bloc);
        else if (bloc.getData("name").equals("key"))    addKeyboard().from_save(bloc);
    } } );
    
    //link
    Save_Bloc links_blocs = sbloc.getBloc("links");
    if (links_blocs != null) links_blocs.runIterator(new Iterator<Save_Bloc>() { 
      public void run(Save_Bloc bloc) { 
        Macro_Output o = getOutputByIndex(bloc.getInt("out"));
        Macro_Input i = getInputByIndex(bloc.getInt("in"));
        if (o != null && i != null) o.connect_to(i);
      } } );
    
    //isreduc
    if (sbloc.getBoolean("reduc")) reduc(); else childDragged();
  }
}
