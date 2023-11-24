
/*

objet principale qui contient tout le patch

extended from sheet object
non reductible

fonction save load

can create like sheet object

*/



class Macro_Main extends Macro_Sheet {
  Ticking_pile tickpile;
  nWidget sload,ssheet;
  int menu_layer = 50;
  Macro_Main(nGUI _gui, Ticking_pile t, float x, float y) {
    super(_gui, null, x, y);
    tickpile = t;
    
    
    sload = new nWidget(_gui, "load", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(ssave)
      .setLayer(menu_layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable() { public void run() {
        do_load();
        childDragged();
        smenu.setOff();
      }})
      ;
    ssheet = new nWidget(_gui, "as sheet", int(macro_size/1.5), 0, 0, macro_size*5, macro_size)
      .setTrigger()
      .setParent(sload)
      .setLayer(menu_layer)
      .stackDown()
      .hide()
      .addEventTrigger(new Runnable() { public void run() {
        do_load_as();
        childDragged();
        smenu.setOff();
      }})
      ;
    //back.toLayerTop();
    setLayer(0);
    toLayerTop();
    reduc.hide(); menu.show(); closer.hide(); addSheet.hide(); sclear.hide();
    
    //addBang.setParent(addSheet);
    //addExtOut.clear();
    //addExtIn.clear();
  }
  void clear() {
    empty();
    super.clear();
    sload.clear(); ssheet.clear(); 
  }
  
  void toLayerTop() {
    super.toLayerTop();
    sload.toLayerTop();
    ssheet.toLayerTop();
  }
  void setLayer(int l) {
    layer = l;
    grabber.setLayer(l);
    closer.setLayer(l);
    back.setLayer(l);
    for (Macro_Input m : extinputs) m.connect.setLayer(l);
    for (Macro_Output m : extoutputs) { m.connect.setLayer(l); m.line_drawer.setLayer(l+1); }
    reduc.setLayer(l);
    menu.setLayer(l);
    addSheet.setLayer(menu_layer);
    addExtIn.setLayer(menu_layer);
    addExtOut.setLayer(menu_layer);
    addBang.setLayer(menu_layer);
    addSwitch.setLayer(menu_layer);
    addDelay.setLayer(menu_layer);
    addPulse.setLayer(menu_layer);
    addValue.setLayer(menu_layer);
    addComp.setLayer(menu_layer);
    addCalc.setLayer(menu_layer);
    addNot.setLayer(menu_layer);
    addBool.setLayer(menu_layer);
    sload.setLayer(menu_layer);
    smenu.setLayer(l);
    sfield.setLayer(menu_layer);
    ssave.setLayer(menu_layer);
    sclear.setLayer(menu_layer);
    ssheet.setLayer(menu_layer);
  }
  
  
}
