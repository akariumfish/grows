
import java.util.Map;

/*

 extend l'objet macro abstract
 
 can create child macro inside
 
 peut ce cree des interconnections entre sont plan et le plan du parent 
 
 peut etre reduit cachant sont plan interne 
 
 background englobe automatiquement sont plan 
 
 */


class Macro_Sheet extends Macro_Abstract {
  nWidget  reduc 
           , sclear, sfield, ssheet, 
           addSheet, addExtIn, addExtOut, smenu, menu, tmenu;//, 
           //templates, tfield, tselect, tup, tdown
           ; 

  ArrayList<Macro_Sheet_Input> sheet_inputs = new ArrayList<Macro_Sheet_Input>(0);
  ArrayList<Macro_Sheet_Output> sheet_outputs = new ArrayList<Macro_Sheet_Output>(0);

  int sheet_inCount = 0;
  int sheet_outCount = 0;

  ArrayList<Macro_Input> inputs = new ArrayList<Macro_Input>(0);
  ArrayList<Macro_Output> outputs = new ArrayList<Macro_Output>(0);

  ArrayList<Macro_Abstract> child_macro = new ArrayList<Macro_Abstract>(0);

  String savepath = "macro.sdata";
  //String templatepath = "templates";

  ArrayList<nWidget> subMenuWidgets = new ArrayList<nWidget>();
  ArrayList<nWidget> subHeadWidgets = new ArrayList<nWidget>();

  boolean isReduc = false;
  
  sFlt choice_flt = null;
  sInt choice_int = null;
  sBoo choice_boo = null;
  
  void reduc() {
    isReduc = true;
    setWidth(ref_size*4);
    back.setStandbyColor(color(50, 200));
    front.show();
    if (menubuttons.size() > 0) menubuttons.get(0).hide();
    for (Macro_Abstract m : child_macro) m.parentReduc();
    for (Macro_Sheet_Input m : sheet_inputs) m.reduc();
    for (Macro_Sheet_Output m : sheet_outputs) m.reduc();
    childDragged();
  }
  void enlarg() {
    isReduc = false;
    setWidth(ref_size*8);
    back.setStandbyColor(color(150, 60));
    front.hide();
    mmain().selected_macro_grabber.remove(grabber);
    for (Macro_Abstract m : child_macro) m.parentEnlarg();
    for (Macro_Sheet_Input m : sheet_inputs) m.enlarg();
    for (Macro_Sheet_Output m : sheet_outputs) m.enlarg();
    if (menubuttons.size() > 0) menubuttons.get(0).show();
    for (nWidget w : subHeadWidgets) w.hide();
    mmain().menugroup.closeAll();
    childDragged();
  }
  
  void parentReduc() {
    super.parentReduc();
    for (Macro_Abstract m : child_macro) m.parentReduc();
  }
  void parentEnlarg() {
    super.parentEnlarg();
    if (isReduc) reduc(); 
    else { 
      enlarg();
      for (Macro_Abstract m : child_macro) m.parentEnlarg(); 
    }
  }
  
  void show() {
    super.show();
    for (nWidget w : subHeadWidgets) w.hide();
    for (Macro_Sheet_Input m : sheet_inputs) m.show();
    for (Macro_Sheet_Output m : sheet_outputs) m.show();
  }
  void hide() {
    super.hide();
    for (Macro_Sheet_Input m : sheet_inputs) m.hide();
    for (Macro_Sheet_Output m : sheet_outputs) m.hide();
  }
  
  ArrayList<nWidget> menubuttons = new ArrayList<nWidget>(0);

  nWidget newMenu(String name) {
    float new_width = (sheet_width + ref_size*1.25) / (menubuttons.size() + 1);
    nWidget menu = new nWidget(gui, name, int(ref_size/1.85), 0, 0, new_width, ref_size * 0.75)
      .setSwitch()
      .setLayer(layer)
      .setOutlineColor(color(100))
      .setOutlineWeight(ref_size / 16)
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
    float new_width = (sheet_width + ref_size*1.25) / (menubuttons.size());
    for (nWidget m : menubuttons) m.setSX(new_width);
    return this;
  }

  ArrayList<nWidget> addbuttons = new ArrayList<nWidget>(0);

  Macro_Sheet newAdd(String name, Runnable run) {
    nWidget add = new nWidget(gui, name, int(ref_size/1.5), 0, 0, ref_size*5, ref_size)
      .setTrigger()
      .setLayer(mmain().menu_layer)
      .stackDown()
     // .hide()
      .addEventTrigger(new Runnable() { 
      public void run() { 
        mmain().menugroup.closeAll();
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

    back.setSize(ref_size*3, ref_size * 0.75)
      .setStandbyColor(color(150, 60))
      .setPassif();
    closer.setSX(ref_size);
    closer.setParent(grabber);
    grabber.setText("");
    
    front.hide();

    setWidth(ref_size*8);

    reduc = new nWidget(_gui, "-", int(ref_size/1.5), 0, 0, ref_size, ref_size * 0.75)
      .setTrigger()
      .setParent(grabber)
      .setLayer(layer)
      .stackLeft()
      .setOutlineColor(color(100))
      .setOutlineWeight(ref_size / 16)
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
    addSheet = new nWidget(_gui, "Child Sheet", int(ref_size/1.5), 0, 0, ref_size*5, ref_size)
      .setTrigger()
      .setParent(menu)
      .setLayer(mmain().menu_layer)
      .stackDown()
     // .hide()
      .addEventTrigger(new Runnable() { 
      public void run() {
        mmain().menugroup.closeAll();
        addSheet();
      }
    }
    )
    ;
    addExtIn = new nWidget(_gui, "Sheet Input", int(ref_size/1.5), 0, 0, ref_size*5, ref_size)
      .setTrigger()
      .setParent(addSheet)
      .setLayer(mmain().menu_layer)
      .stackDown()
     // .hide()
      .addEventTrigger(new Runnable(this) { 
      public void run() {
        mmain().menugroup.closeAll();
        addSheetInput();
      }
    }
    )
    ;
    addExtOut = new nWidget(_gui, "Sheet Output", int(ref_size/1.5), 0, 0, ref_size*5, ref_size)
      .setTrigger()
      .setParent(addExtIn)
      .setLayer(mmain().menu_layer)
      .stackDown()
     // .hide()
      .addEventTrigger(new Runnable(this) { 
      public void run() {
        mmain().menugroup.closeAll();
        addSheetOutput();
      }
    }
    )
    ;
    
    newAdd("Basic Macro", new Runnable() { public void run() { addPanelBasicMacro(); } } );
    newAdd("Custom sFlt", new Runnable() { public void run() { addPanelsFlt(); } } );
    newAdd("Custom sInt", new Runnable() { public void run() { addPanelsInt(); } } );
    newAdd("Custom sBoo", new Runnable() { public void run() { addPanelsBoo(); } } );
    newAdd("Custom Run", new Runnable() { public void run() { addPanelRun(); } } );

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
    
    sclear = new nWidget(_gui, "Clear", int(ref_size/1.5), 0, 0, ref_size*5, ref_size)
      .setTrigger()
      .setParent(smenu)
      .setLayer(mmain().menu_layer)
      .stackDown()
     // .hide()
      .addEventTrigger(new Runnable() { 
      public void run() {
        empty();
        mmain().menugroup.closeAll();
      }
    }
    )
    ;
    sfield = new nWidget(_gui, 0, 0, ref_size*5, ref_size)
      .setParent(sclear)
      .stackDown()
      .setLayer(mmain().menu_layer)
      .setFont(int(ref_size/1.5))
      .setText(savepath)
      .setField(true)
      //.setOutlineColor(color(180, 60))
      .setOutlineWeight(ref_size / 16)
      //.setOutline(true)
     // .hide()
      .addEventFieldChange(new Runnable() { 
      public void run() {
        savepath = sfield.getText();
      }
    }
    )
    ;
    
    ssheet = new nWidget(_gui, "Load as sheet", int(ref_size/1.5), 0, 0, ref_size*5, ref_size)
      .setTrigger()
      .setParent(sfield)
      .setLayer(mmain().menu_layer)
      .stackDown()
      .addEventTrigger(new Runnable() { 
      public void run() {
        sdata_load_as();
        childDragged();
        mmain().menugroup.closeAll();
      }
    }
    )
    ;
    
    
    subMenuWidgets.add(addSheet);
    subMenuWidgets.add(addExtIn);
    subMenuWidgets.add(addExtOut);
    subMenuWidgets.add(sclear);
    subMenuWidgets.add(sfield);
    subMenuWidgets.add(ssheet);
    ////subMenuWidgets.add(templates);
    
    subHeadWidgets.add(addSheet);
    subHeadWidgets.add(sclear);
    ////subHeadWidgets.add(templates);
    
    for (nWidget w : subHeadWidgets) w.hide();
    ////addSheet.hide(); sclear.hide(); templates.hide();
    
    if (mmain().menugroup != null) {
      for (nWidget w : menubuttons) mmain().menugroup.add(w);
    }
    childDragged();
  }
  
  Macro_Sheet addPanelBasicMacro() {
    nPanel pan = new nPanel(mmain().screen_gui, "Add Basic Macro", ref_size, ref_size)
      .setWidth(ref_size*8.5)
      .setItemHeight(ref_size*0.75)
      .addDrawer(ref_size*1.25)
        .addWidget("Bang", int(ref_size/1.9), ref_size*0.25, ref_size*0.25, ref_size*2.5, ref_size).setTrigger().addEventTrigger_Builder(new Runnable() { public void run() {
            //((nWidget)builder).getPanelDrawer().getPanel().clear();
            addBang(); }}).getPanelDrawer()
        .addWidget("Switch", int(ref_size/1.9), ref_size*3, ref_size*0.25, ref_size*2.5, ref_size).setTrigger().addEventTrigger_Builder(new Runnable() { public void run() {
            addSwitch(); }}).getPanelDrawer()
        .addWidget("Key", int(ref_size/1.9), ref_size*5.75, ref_size*0.25, ref_size*2.5, ref_size).setTrigger().addEventTrigger_Builder(new Runnable() { public void run() {
            addKeyboard(); }}).getPanelDrawer()
        .getPanel()
      .addDrawer(ref_size*1.25)
        .addWidget("Value", int(ref_size/1.9), ref_size*0.25, ref_size*0.25, ref_size*2.5, ref_size).setTrigger().addEventTrigger_Builder(new Runnable() { public void run() {
            addValue(); }}).getPanelDrawer()
        .addWidget("Calc", int(ref_size/1.9), ref_size*3, ref_size*0.25, ref_size*2.5, ref_size).setTrigger().addEventTrigger_Builder(new Runnable() { public void run() {
            addCalc(); }}).getPanelDrawer()
        .addWidget("Comp", int(ref_size/1.9), ref_size*5.75, ref_size*0.25, ref_size*2.5, ref_size).setTrigger().addEventTrigger_Builder(new Runnable() { public void run() {
            addComp(); }}).getPanelDrawer()
        .getPanel()
      .addDrawer(ref_size*1.25)
        .addWidget("Delay", int(ref_size/1.9), ref_size*0.25, ref_size*0.25, ref_size*2.5, ref_size).setTrigger().addEventTrigger_Builder(new Runnable() { public void run() {
            addDelay(); }}).getPanelDrawer()
        .addWidget("Pulse", int(ref_size/1.9), ref_size*3, ref_size*0.25, ref_size*2.5, ref_size).setTrigger().addEventTrigger_Builder(new Runnable() { public void run() {
            addPulse(); }}).getPanelDrawer()
        .addWidget("Gate", int(ref_size/1.9), ref_size*5.75, ref_size*0.25, ref_size*2.5, ref_size).setTrigger().addEventTrigger_Builder(new Runnable() { public void run() {
            addGate(); }}).getPanelDrawer()
        .getPanel()
      .addDrawer(ref_size*1.25)
        .addWidget("Bool", int(ref_size/1.9), ref_size*0.25, ref_size*0.25, ref_size*2.5, ref_size).setTrigger().addEventTrigger_Builder(new Runnable() { public void run() {
            addBool(); }}).getPanelDrawer()
        .addWidget("Not", int(ref_size/1.9), ref_size*3, ref_size*0.25, ref_size*2.5, ref_size).setTrigger().addEventTrigger_Builder(new Runnable() { public void run() {
            addNot(); }}).getPanelDrawer()
        .addWidget("Bool Val", int(ref_size/1.9), ref_size*5.75, ref_size*0.25, ref_size*2.5, ref_size).setTrigger().addEventTrigger_Builder(new Runnable() { public void run() {
            addValue().setBool(); }}).getPanelDrawer()
        .getPanel()
      .addDrawer(ref_size*1.25)
        .addWidget("Comment", int(ref_size/1.9), ref_size*0.25, ref_size*0.25, ref_size*2.5, ref_size).setTrigger().addEventTrigger_Builder(new Runnable() { public void run() {
            addComment(); }}).getPanelDrawer()
        .addWidget("Bin", int(ref_size/1.5), ref_size*3, ref_size*0.25, ref_size*2.5, ref_size).setTrigger().addEventTrigger_Builder(new Runnable() { public void run() {
            addBin(); }}).getPanelDrawer()
        //.addWidget("Bool Val", int(ref_size/1.5), ref_size*5.75, ref_size*0.25, ref_size*2.5, ref_size).setTrigger().addEventTrigger_Builder(new Runnable() { public void run() {
        //    addValue().setBool(); }}).getPanelDrawer()
        .getPanel()
      .addSeparator(ref_size*0.25)
      .setLayer(mmain().menu_layer+1)
      .toLayerTop()
      //.setPosition(- ref_size*20, - ref_size*1)
      .addEventClose(new Runnable() { public void run() {
        ;
      }})
      ;
    //pan.getGrabWidget().setParent(grabber);
    return this;
  }
  Macro_Sheet addPanelsFlt() {
    int descnb = 0;
    for (Map.Entry me : mmain().data.blocs.entrySet()) {
      sValueBloc vb = ((sValueBloc)me.getValue());
      //logln(vb.ref);
      for (Map.Entry me2 : vb.values.entrySet()) {
        sValue v = ((sValue)me2.getValue());
      //logln(v.ref);
        if (v.type.equals("flt")) descnb++;
      }
    }
    String[] t = new String[descnb];
    int cnt = 0;
    for (Map.Entry me : mmain().data.blocs.entrySet()) {
      sValueBloc vb = ((sValueBloc)me.getValue());
      for (Map.Entry me2 : vb.values.entrySet()) {
        sValue v = ((sValue)me2.getValue());
        if (v.type.equals("flt")) { t[cnt] = v.ref; cnt++; }
      }
    }
    nPanel pan = new nPanel(mmain().screen_gui, "Add sFlt Connexion", ref_size, ref_size)
      .setWidth(ref_size*8.5)
      .setItemHeight(ref_size*0.75)
      .addDrawer(ref_size*1.25)
        .addWidget("ctrl", int(ref_size/1.5), ref_size*0.25, ref_size*0.25, ref_size*2.5, ref_size)
          .setTrigger()
          .addEventTrigger(new Runnable() { public void run() {
            if (choice_flt != null) {
              Macro_Custom m = addCustom()
                .addValueController()
                  .setValue(choice_flt)
                  .getMacro()
                ;
              adding(m);
              childDragged();
            }
          }})
          .getPanelDrawer()
        .addWidget("watch", int(ref_size/1.5), ref_size*3, ref_size*0.25, ref_size*2.5, ref_size)
          .setTrigger()
          .addEventTrigger(new Runnable() { public void run() {
            if (choice_flt != null) {
              Macro_Custom m = addCustom()
                .addValueWatcher()
                  .setValue(choice_flt)
                  .getMacro()
                ;
              adding(m);
              childDragged();
            }
          }})
          .getPanelDrawer()
        .addWidget("--", int(ref_size/1.5), ref_size*5.75, ref_size*0.25, ref_size*2.5, ref_size)
          .setStandbyColor(color(255, 0))
          .addEventFrame_Builder(new Runnable() { public void run() {
            if (choice_flt != null) {
              ((nWidget)builder).setText(str(choice_flt.get()));
            }
          }})
          .getPanelDrawer()
        .getPanel()
      .addDrawer(ref_size*5.25)
        .addList(ref_size*0.25, ref_size*0.25, ref_size*8, ref_size*1)
          .setEntrys(t)
          .addEventChange_Builder(new Runnable() { public void run() {
            for (Map.Entry me : mmain().data.blocs.entrySet()) {
              sValueBloc vb = ((sValueBloc)me.getValue());
              for (Map.Entry me2 : vb.values.entrySet()) {
                sValue v = ((sValue)me2.getValue());
                if (v.ref.equals(((nList)builder).last_choice_text)) { choice_flt = ((sFlt)v); }
              }
            }
          }})
          .getPanelDrawer()
        .getPanel()
      .addSeparator(ref_size*0.25)
      .setLayer(mmain().menu_layer+1)
      .toLayerTop()
      //.setPosition(- ref_size*20, ref_size*7)
      ;
    //pan.getGrabWidget().setParent(grabber);
    return this;
  }
  Macro_Sheet addPanelsInt() {
    int descnb = 0;
    //for (sInt v : simval.sintlist) if (!v.name.equals("int")) descnb++;
    String[] t = new String[descnb];
    int cnt = 0;
    //for (sInt v : simval.sintlist) if (!v.name.equals("int")) {
    //  t[cnt] = v.name;
    //  cnt++; }
    
    nPanel pan = new nPanel(mmain().screen_gui, "Add sInt Connexion", ref_size, ref_size)
      .setWidth(ref_size*8.5)
      .setItemHeight(ref_size*0.75)
      .addDrawer(ref_size*1.25)
        .addWidget("ctrl", int(ref_size/1.5), ref_size*0.25, ref_size*0.25, ref_size*2.5, ref_size)
          .setTrigger()
          .addEventTrigger(new Runnable() { public void run() {
            if (choice_int != null) {
              Macro_Custom m = addCustom()
                .addValueController()
                  .setValue(choice_int)
                  .getMacro()
                ;
              adding(m);
              childDragged();
            }
          }})
          .getPanelDrawer()
        .addWidget("watch", int(ref_size/1.5), ref_size*3, ref_size*0.25, ref_size*2.5, ref_size)
          .setTrigger()
          .addEventTrigger(new Runnable() { public void run() {
            if (choice_int != null) {
              Macro_Custom m = addCustom()
                .addValueWatcher()
                  .setValue(choice_int)
                  .getMacro()
                ;
              adding(m);
              childDragged();
            }
          }})
          .getPanelDrawer()
        .addWidget("--", int(ref_size/1.5), ref_size*5.75, ref_size*0.25, ref_size*2.5, ref_size)
          .setStandbyColor(color(255, 0))
          .addEventFrame_Builder(new Runnable() { public void run() {
            if (choice_int != null) {
              ((nWidget)builder).setText(str(choice_int.get()));
            }
          }})
          .getPanelDrawer()
        .getPanel()
      .addDrawer(ref_size*5.25)
        .addList(ref_size*0.25, ref_size*0.25, ref_size*8, ref_size*1)
          .setEntrys(t)
          .addEventChange_Builder(new Runnable() { public void run() {
            //for (sInt v : simval.sintlist) if (v.name.equals(((nList)builder).last_choice_text))
              //choice_int = v;
          }})
          .getPanelDrawer()
        .getPanel()
      .addSeparator(ref_size*0.25)
      .setLayer(mmain().menu_layer+1)
      .toLayerTop()
      //.setPosition(- ref_size*20, ref_size*15)
      .addEventClose(new Runnable() { public void run() {
        ;
      }})
      ;
    //pan.getGrabWidget().setParent(grabber);
    return this;
  }
  Macro_Sheet addPanelsBoo() {
    int descnb = 0;
    //for (sBoo v : simval.sboolist) if (!v.name.equals("boo")) descnb++;
    String[] t = new String[descnb];
    int cnt = 0;
    //for (sBoo v : simval.sboolist) if (!v.name.equals("boo")) {
    //  t[cnt] = v.name;
    //  cnt++; }
    
    nPanel pan = new nPanel(mmain().screen_gui, "Add sBoo Connexion", ref_size, ref_size)
      .setWidth(ref_size*8.5)
      .setItemHeight(ref_size*0.75)
      .addDrawer(ref_size*1.25)
        .addWidget("ctrl", int(ref_size/1.5), ref_size*0.25, ref_size*0.25, ref_size*2.5, ref_size)
          .setTrigger()
          .addEventTrigger(new Runnable() { public void run() {
            if (choice_boo != null) {
              Macro_Custom m = addCustom()
                .addValueController()
                  .setValue(choice_boo)
                  .getMacro()
                ;
              adding(m);
              childDragged();
            }
          }})
          .getPanelDrawer()
        .addWidget("watch", int(ref_size/1.5), ref_size*3, ref_size*0.25, ref_size*2.5, ref_size)
          .setTrigger()
          .addEventTrigger(new Runnable() { public void run() {
            if (choice_boo != null) {
              Macro_Custom m = addCustom()
                .addValueWatcher()
                  .setValue(choice_boo)
                  .getMacro()
                ;
              adding(m);
              childDragged();
            }
          }})
          .getPanelDrawer()
        .addWidget("--", int(ref_size/1.5), ref_size*5.75, ref_size*0.25, ref_size*2.5, ref_size)
          .setStandbyColor(color(255, 0))
          .addEventFrame_Builder(new Runnable() { public void run() {
            if (choice_boo != null) {
              ((nWidget)builder).setText(str(choice_boo.get()));
            }
          }})
          .getPanelDrawer()
        .getPanel()
      .addDrawer(ref_size*5.25)
        .addList(ref_size*0.25, ref_size*0.25, ref_size*8, ref_size*1)
          .setEntrys(t)
          .addEventChange_Builder(new Runnable() { public void run() {
            //for (sBoo v : simval.sboolist) if (v.name.equals(((nList)builder).last_choice_text))
              //choice_boo = v;
          }})
          .getPanelDrawer()
        .getPanel()
      .addSeparator(ref_size*0.25)
      .setLayer(mmain().menu_layer+1)
      .toLayerTop()
      //.setPosition(ref_size*20, -ref_size*1)
      .addEventClose(new Runnable() { public void run() {
        ;
      }})
      ;
    //pan.getGrabWidget().setParent(grabber);
    return this;
  }
  Macro_Sheet addPanelRun() {
    //String[] t = new String[custom_runnable_map.size()];
    int cnt = 0;
    //for (Map.Entry me : custom_runnable_map.entrySet()) {
      //t[cnt] = (String)me.getKey();
      //cnt++; }
    
    nPanel pan = new nPanel(mmain().screen_gui, "Add Runnable Connexion", ref_size, ref_size)
      .setWidth(ref_size*8.5)
      .setItemHeight(ref_size*0.75)
      .addDrawer(ref_size*5.25)
        .addList(ref_size*0.25, ref_size*0.25, ref_size*8, ref_size*1)
          //.setEntrys(t)
          .addEventChange_Builder(new Runnable() { public void run() {
            Macro_Custom m = addCustom()
              .addRun()
                .setRunnable(((nList)builder).last_choice_text)
                .getMacro()
              ;
            adding(m);
            childDragged();
          }})
          .getPanelDrawer()
        .getPanel()
      .addSeparator(ref_size*0.25)
      .setLayer(mmain().menu_layer+1)
      .toLayerTop()
      //.setPosition(ref_size*20, ref_size*7)
      ;
    //pan.getGrabWidget().setParent(grabber);
    return this;
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
  
  ArrayList<nWidget> phantom_widgets = new ArrayList<nWidget>();

  void childDragged() {
    float minx = 0, miny = 0, maxx = grabber.getLocalSX() + ref_size, maxy = ref_size*1.75;
    if (isReduc) { maxx = ref_size*3; maxy = 0;}
    if (!isReduc) for (nWidget w : phantom_widgets) if (!w.isHided()) {
      if (minx > w.getLocalX()) 
        minx = w.getLocalX();
      if (miny > w.getLocalY()) 
        miny = w.getLocalY();
      if (maxx < w.getLocalX() + w.getSX()) 
        maxx = w.getLocalX() + w.getSX();
      if (maxy < w.getLocalY() + w.getSY()) 
        maxy = w.getLocalY() + w.getSY();
    }
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
    if (!isReduc && maxy < max(inCount, outCount) * ref_size * 1.25 + ref_size * 0.75)
      maxy = max(inCount, outCount) * ref_size * 1.25 + ref_size * 0.75;

    for (Macro_Sheet_Input m : sheet_inputs) {
      if (maxy < m.grabber.getLocalY() + inputs_ref.getLocalY() + m.grabber.getLocalSY() + ref_size*0.125)
        maxy = m.grabber.getLocalY() + inputs_ref.getLocalY() + m.grabber.getLocalSY() + ref_size*0.125;
      if (miny > m.grabber.getLocalY() + inputs_ref.getLocalY() + ref_size*1.375)
        miny = m.grabber.getLocalY() + inputs_ref.getLocalY() + ref_size*1.375;
    }
    for (Macro_Sheet_Output m : sheet_outputs) {
      if (maxy < m.grabber.getLocalY() + outputs_ref.getLocalY() + m.grabber.getLocalSY() + ref_size*0.125)
        maxy = m.grabber.getLocalY() + outputs_ref.getLocalY() + m.grabber.getLocalSY() + ref_size*0.125;
      if (miny > m.grabber.getLocalY() + outputs_ref.getLocalY() + ref_size*1.375)
        miny = m.grabber.getLocalY() + outputs_ref.getLocalY() + ref_size*1.375;
    }
    if (isReduc) {
      back.setPosition(minx - ref_size, miny);
      back.setSize(maxx - minx + ref_size*2.25, maxy - miny + ref_size*0.75);
      inputs_ref.setPX(minx + ref_size * 1 / 8);
      outputs_ref.setPX(maxx + ref_size*0.875);
    } else {
      back.setPosition(minx - ref_size*5, miny - ref_size);
      back.setSize(maxx - minx + ref_size*9.5, maxy - miny + ref_size*2);
      inputs_ref.setPX(minx - ref_size * 31 / 8);
      outputs_ref.setPX(maxx + ref_size * 27 / 8);
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
    Macro_Sheet m = new Macro_Sheet(gui, this, 0, ref_size*1.25);
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
  Macro_Bin addBin() {
    Macro_Bin m = new Macro_Bin(gui, this, 0, 0);
    adding(m); 
    return m;
  }
  Macro_Gate addGate() {
    Macro_Gate m = new Macro_Gate(gui, this, 0, 0);
    adding(m); 
    return m;
  }
  Macro_Keyboard addKeyboard() {
    Macro_Keyboard m = new Macro_Keyboard(gui, this, 0, 0);
    adding(m); 
    return m;
  }
  Macro_Comment addComment() {
    Macro_Comment m = new Macro_Comment(gui, this, 0, 0);
    adding(m); 
    return m;
  }
  Macro_Custom addCustom() {
    Macro_Custom m = new Macro_Custom(gui, this, 0, 0);
    //adding(m); 
    return m;
  }

  void adding(Macro_Abstract m) {
    float add_pos = m.grabber.getLocalY() + ref_size*2;
    boolean found = false;
    while (!found) {
      m.grabber.setPosition(0, add_pos);
      add_pos += ref_size*0.375;
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
    for (nWidget w : addbuttons) w.setLayer(mmain().menu_layer);
    for (nWidget w : subMenuWidgets) w.setLayer(mmain().menu_layer);
    for (Macro_Sheet_Input m : sheet_inputs) m.setLayer(l);
    for (Macro_Sheet_Output m : sheet_outputs) m.setLayer(l);
  }
  void toLayerTop() {
    super.toLayerTop();
    reduc.toLayerTop();
    for (nWidget w : menubuttons) w.toLayerTop();
    for (nWidget w : addbuttons) w.toLayerTop();
    for (nWidget w : subMenuWidgets) w.toLayerTop();
    for (Macro_Sheet_Input m : sheet_inputs) m.toLayerTop();
    for (Macro_Sheet_Output m : sheet_outputs) m.toLayerTop();
  }
  void clear() {
    super.clear(); 
    reduc.clear(); 
    for (int i = menubuttons.size() - 1; i >= 0; i--) menubuttons.get(i).clear(); 
    for (int i = subMenuWidgets.size() - 1; i >= 0; i--) subMenuWidgets.get(i).clear(); 
    for (int i = addbuttons.size() - 1; i >= 0; i--) addbuttons.get(i).clear(); 

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
    m.grabber.setPosition(0, m.grabber.getLocalY() - m.back.getLocalY() + ref_size*1);
    adding(m);
    childDragged();
    m.reduc();
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
        if      (bloc.getData("name").equals("sheet"))  addSheet().from_save(bloc);
        else if (bloc.getData("name").equals("bang"))   addBang().from_save(bloc);
        else if (bloc.getData("name").equals("switch")) addSwitch().from_save(bloc);
        else if (bloc.getData("name").equals("delay"))  addDelay().from_save(bloc);
        else if (bloc.getData("name").equals("pulse"))  addPulse().from_save(bloc);
        else if (bloc.getData("name").equals("value"))  addValue().from_save(bloc);
        else if (bloc.getData("name").equals("calc"))   addCalc().from_save(bloc);
        else if (bloc.getData("name").equals("comp"))   addComp().from_save(bloc);
        else if (bloc.getData("name").equals("bool"))   addBool().from_save(bloc);
        else if (bloc.getData("name").equals("not"))    addNot().from_save(bloc);
        else if (bloc.getData("name").equals("bin"))    addBin().from_save(bloc);
        else if (bloc.getData("name").equals("key"))    addKeyboard().from_save(bloc);
        else if (bloc.getData("name").equals("gate"))   addGate().from_save(bloc);
        else if (bloc.getData("name").equals("com"))    addComment().from_save(bloc);
        else if (bloc.getData("name").equals("custom")) { 
          Macro_Custom m = addCustom(); 
          m.from_save(bloc); 
          m.setLayer(layer+2);
          m.toLayerTop(); }
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
    
    mmain().menugroup.closeAll();
  }
}
