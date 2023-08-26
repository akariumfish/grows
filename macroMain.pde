
MacroWorld mworld;

Keyboard keyb;
MacroVAL mv1,mv2,mv3,mv4,mv5,mv6;
MacroDELAY md1,md2;
MacroCOMP mc1;
GrowingControl gcC;
GrowingWatcher gwC;

void init_macro() {
  mworld = new MacroWorld();
  gcC = mworld.addGrowingControl();
    
  //keyb = mworld.addKeyboard();
  //mv1 = mworld.macroList.addMacroVAL(0.16);
  //mv2 = mworld.macroList.addMacroVAL(0.833);
  //md1 = mworld.macroList.addMacroDELAY(1);
  
  //mv3 = mworld.macroList.addMacroVAL(1);
  //mv4 = mworld.macroList.addMacroVAL(1);
  mv5 = mworld.macroList.addMacroVAL(2500);
  //mv6 = mworld.macroList.addMacroVAL(5);
  //md2 = mworld.macroList.addMacroDELAY(5);
  
  mc1 = mworld.macroList.addMacroCOMP();
  
  gwC = mworld.addGrowingWatcher();

  //keyb.wO.linkTo(mv1.in)
  //       .linkTo(md1.in);
  //md1.out.linkTo(mv2.in);
  //mv1.out.linkTo(gcC.growI);
  //mv2.out.linkTo(gcC.growI);
  
  //keyb.cO.linkTo(mv3.in)
  //       .linkTo(mv4.in)
  //       .linkTo(md2.in);
  //md2.out.linkTo(mv5.in)
  //       .linkTo(mv6.in);
  //mv3.out.linkTo(gcC.sproutI);
  //mv4.out.linkTo(gcC.stopI);
  //mv5.out.linkTo(gcC.sproutI);
  //mv6.out.linkTo(gcC.stopI);
}

class MacroWorld {
  ArrayList<Controller> control = new ArrayList<Controller>(0);
  MacroList macroList;
  
  MacroWorld() {
    macroList = new MacroList();
  }
  
  void macroWorld_to_string() {
    file.append("macroworld:");
    file.append("controller:");
    for (Controller c : control)
      c.to_strings();
    macroList.to_strings();
  }
  boolean build_from_string(StringList file) {
    file.reverse();
    return  popStrLst(file).equals("macroworld:") &&
            popStrLst(file).equals("controller:") ;
  }
  void clear() {
    control.clear();
    for (Controller c : control) c.clear();
    macroList.clear();
  }
  
  void update() {
    for (Controller p : control)  p.update();
    macroList.update();
  }
  
  //drawing
  void drawing() {
    //if (!cp5.getTab("Macros").isActive()) {
    //  for (int i = 0; i < control.size(); i++) {
    //    control.get(i).drawing(20, 150 + (30 * i));
    //  }
    //}
    macroList.drawing();
  }

  Controller addController(Controller p) {
    control.add(p);
    return p;
  }
  
  Keyboard addKeyboard() {
    int id = control.size();
    return (Keyboard) addController(new Keyboard(this, id, 30, 100 + (110 * id)));
  }
  
  GrowingControl addGrowingControl() {
    int id = control.size();
    return (GrowingControl) addController(
      new GrowingControl(this, id, 800, 100 + (100 * id)) );
  }
  
  GrowingWatcher addGrowingWatcher() {
    int id = control.size();
    return (GrowingWatcher) addController(
      new GrowingWatcher(this, id, 30, 100 + (130 * id)) );
  }
  
  void removeControl(Controller p) {
    control.remove(p);
  }
  
}
