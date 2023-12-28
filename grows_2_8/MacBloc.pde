
class MPulse extends Macro_Bloc { //tel throug only 1 bang every <delay> bang
  Macro_Connexion in, out;
  sInt delay;
  nLinkedWidget del_field;
  int count = 0;
  MPulse(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "pulse", "pulse", _bloc); 
    
    delay = ((sInt)(value_bloc.getValue("delay"))); 
    if (_bloc == null) delay = value_bloc.newInt("delay", "delay", 100);
    else delay = (sInt)(value_bloc.getValue("delay"));
    
    addEmptyS(1);
    del_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(delay);
    
    in = addInput(0, "in").setFilterBang().addEventReceive(new Runnable() { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isBang()) {
        count++;
        if (count > delay.get()) { count = 0; out.send(newPacketBang()); }
      } 
    } });
        
    out = addOutput(1, "out")
      .setDefBool();
  }
  MPulse clear() {
    super.clear(); return this; }
}
class MVar extends Macro_Bloc {
  Macro_Connexion in, out;
  Macro_Packet packet;
  nLinkedWidget view;
  sStr val_view; 
  MVar(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "var", "var", _bloc); 
    packet = newPacketFloat(0); 
    val_view = ((sStr)(value_bloc.getValue("val"))); 
    if (_bloc == null) val_view = value_bloc.newStr("val", "val", "0");
    else val_view = (sStr)(value_bloc.getValue("val"));
    addEmptyS(1).addCtrlModel("MC_Element_SButton")
      .setRunnable(new Runnable() { public void run() { if (packet != null) out.send(packet); } });
    view = addEmptyS(0).addLinkedModel("MC_Element_SField").setLinkedValue(val_view);
    view.addEventFieldChange(new Runnable() { public void run() { 
      String t = view.getText();
      if (t.length() > 0) {
        if (t.equals("true")) packet = newPacketBool(true);
        else if (t.equals("false")) packet = newPacketBool(false);
        else if (t.equals("0")) packet = newPacketFloat(0);
        else if (t.equals("0.0")) packet = newPacketFloat(0);
        else if (float(t) != 0) packet = newPacketFloat(float(t));
      }
    } });
    in = addInput(0, "in").addEventReceive(new Runnable() { public void run() { 
      if (in.getLastPacket() != null) {
        if (in.getLastPacket().isBang() && packet != null) out.send(packet);
        else { packet = in.getLastPacket(); view.setText(packet.getText()); } }
    } });
    out = addOutput(1, "out");
  }
  MVar clear() {
    super.clear(); return this; }
}


class MComp extends Macro_Bloc {
  Macro_Connexion in1, in2, out;
  nLinkedWidget widgSUP, widgINF, widgEQ; 
  sBoo valSUP, valINF, valEQ;
  float pin1 = 0, pin2 = 0;
  nLinkedWidget view;
  sStr val_view; 
  MComp(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "comp", "comp", _bloc); 
    
    valSUP = ((sBoo)(value_bloc.getValue("valSUP"))); 
    valINF = ((sBoo)(value_bloc.getValue("valINF"))); 
    valEQ = ((sBoo)(value_bloc.getValue("valEQ"))); 
    
    if (_bloc == null) valSUP = value_bloc.newBoo("valSUP", "valSUP", false);
    else valSUP = (sBoo)(value_bloc.getValue("valSUP"));
    if (_bloc == null) valINF = value_bloc.newBoo("valINF", "valINF", false);
    else valINF = (sBoo)(value_bloc.getValue("valINF"));
    if (_bloc == null) valEQ = value_bloc.newBoo("valEQ", "valEQ", false);
    else valEQ = (sBoo)(value_bloc.getValue("valEQ"));
    
    valSUP.addEventChange(new Runnable() { public void run() { if (valSUP.get()) receive(); } });
    valINF.addEventChange(new Runnable() { public void run() { if (valINF.get()) receive(); } });
    valEQ.addEventChange(new Runnable() { public void run() { if (valEQ.get()) receive(); } });
    
    in1 = addInput(0, "in").setFilterFloat().setLastFloat(0).addEventReceive(new Runnable() { public void run() { 
      if (in1.getLastPacket() != null && in1.getLastPacket().isFloat() && in1.getLastPacket().asFloat() != pin1) {
        pin1 = in1.getLastPacket().asFloat(); receive(); } } });
    in2 = addInput(0, "in").setFilterFloat().setLastFloat(0).addEventReceive(new Runnable() { public void run() { 
      if (in2.getLastPacket() != null && in2.getLastPacket().isFloat() && in2.getLastPacket().asFloat() != pin2) {
        pin2 = in2.getLastPacket().asFloat(); view.setText(trimStringFloat(pin2)); receive(); } } });
    
    out = addOutput(1, "out")
      .setDefFloat();
      
    val_view = ((sStr)(value_bloc.getValue("val"))); 
    if (_bloc == null) val_view = value_bloc.newStr("val", "val", "");
    else val_view = (sStr)(value_bloc.getValue("val"));
    view = addEmptyS(1).addLinkedModel("MC_Element_SField").setLinkedValue(val_view);
    view.addEventFieldChange(new Runnable() { public void run() { 
      String t = view.getText();
      if (t.length() > 0) {
        if (t.equals("0") || t.equals("0.0")) { pin2 = 0; in2.setLastFloat(0); receive(); }
        else if (float(t) != 0) { pin2 = float(t); in2.setLastFloat(pin2); receive(); }
      }
    } });
    
    Macro_Element e = addEmptyL(0);
    widgSUP = e.addLinkedModel("MC_Element_Button_Selector_1", ">").setLinkedValue(valSUP);
    widgINF = e.addLinkedModel("MC_Element_Button_Selector_2", "<").setLinkedValue(valINF);
    widgEQ = e.addLinkedModel("MC_Element_Button_Selector_4", "=").setLinkedValue(valEQ);
    widgSUP.addExclude(widgINF);
    widgINF.addExclude(widgSUP);
    
  }
  void receive() { 
    if      (valSUP.get() && (pin1 > pin2)) out.send(newPacketBool(true));
    else if (valINF.get() && (pin1 < pin2)) out.send(newPacketBool(true));
    else if (valEQ.get() && (pin1 == pin2)) out.send(newPacketBool(true));
    else                                    out.send(newPacketBool(false));
  }
  MComp clear() {
    super.clear(); return this; }
}



class MCalc extends Macro_Bloc {
  Macro_Connexion in1, in2, out;
  nLinkedWidget widgADD, widgSUB, widgMUL, widgDEV; 
  sBoo valADD, valSUB, valMUL, valDEV;
  float pin1 = 0, pin2 = 0;
  nLinkedWidget view;
  sStr val_view; 
  MCalc(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "calc", "calc", _bloc); 
    
    valADD = ((sBoo)(value_bloc.getValue("valADD"))); 
    valSUB = ((sBoo)(value_bloc.getValue("valSUB"))); 
    valMUL = ((sBoo)(value_bloc.getValue("valMUL"))); 
    valDEV = ((sBoo)(value_bloc.getValue("valDEV"))); 
    
    if (_bloc == null) valADD = value_bloc.newBoo("valADD", "valADD", false);
    else valADD = (sBoo)(value_bloc.getValue("valADD"));
    if (_bloc == null) valSUB = value_bloc.newBoo("valSUB", "valSUB", false);
    else valSUB = (sBoo)(value_bloc.getValue("valSUB"));
    if (_bloc == null) valMUL = value_bloc.newBoo("valMUL", "valMUL", false);
    else valMUL = (sBoo)(value_bloc.getValue("valMUL"));
    if (_bloc == null) valDEV = value_bloc.newBoo("valDEV", "valDEV", false);
    else valDEV = (sBoo)(value_bloc.getValue("valDEV"));
    
    valADD.addEventChange(new Runnable() { public void run() { if (valADD.get()) receive(); } });
    valSUB.addEventChange(new Runnable() { public void run() { if (valSUB.get()) receive(); } });
    valMUL.addEventChange(new Runnable() { public void run() { if (valMUL.get()) receive(); } });
    valDEV.addEventChange(new Runnable() { public void run() { if (valDEV.get()) receive(); } });
    
    in1 = addInput(0, "in").setFilterFloat().setLastFloat(0).addEventReceive(new Runnable() { public void run() { 
      if (in1.getLastPacket() != null && in1.getLastPacket().isFloat() && in1.getLastPacket().asFloat() != pin1) {
        pin1 = in1.getLastPacket().asFloat(); receive(); } } });
    in2 = addInput(0, "in").setFilterFloat().setLastFloat(0).addEventReceive(new Runnable() { public void run() { 
      if (in2.getLastPacket() != null && in2.getLastPacket().isFloat() && in2.getLastPacket().asFloat() != pin2) {
        pin2 = in2.getLastPacket().asFloat(); view.setText(trimStringFloat(pin2)); receive(); } } });
    
    out = addOutput(1, "out")
      .setDefFloat();
      
    val_view = ((sStr)(value_bloc.getValue("val"))); 
    if (_bloc == null) val_view = value_bloc.newStr("val", "val", "");
    else val_view = (sStr)(value_bloc.getValue("val"));
    view = addEmptyS(1).addLinkedModel("MC_Element_SField").setLinkedValue(val_view);
    view.addEventFieldChange(new Runnable() { public void run() { 
      String t = view.getText();
      if (t.length() > 0) {
        if (t.equals("0") || t.equals("0.0")) { pin2 = 0; in2.setLastFloat(0); receive(); }
        else if (float(t) != 0) { pin2 = float(t); in2.setLastFloat(pin2); receive(); }
      }
    } });
    
    Macro_Element e = addEmptyL(0);
    widgADD = e.addLinkedModel("MC_Element_Button_Selector_1", "+").setLinkedValue(valADD);
    widgSUB = e.addLinkedModel("MC_Element_Button_Selector_2", "-").setLinkedValue(valSUB);
    widgMUL = e.addLinkedModel("MC_Element_Button_Selector_3", "X").setLinkedValue(valMUL);
    widgDEV = e.addLinkedModel("MC_Element_Button_Selector_4", "/").setLinkedValue(valDEV);
    widgADD.addExclude(widgDEV).addExclude(widgSUB).addExclude(widgMUL);
    widgSUB.addExclude(widgADD).addExclude(widgDEV).addExclude(widgMUL);
    widgMUL.addExclude(widgADD).addExclude(widgSUB).addExclude(widgDEV);
    widgDEV.addExclude(widgADD).addExclude(widgSUB).addExclude(widgMUL);
    
  }
  void receive() { 
    if      (valADD.get()) out.send(newPacketFloat(pin1 + pin2));
    else if (valSUB.get()) out.send(newPacketFloat(pin1 - pin2));
    else if (valMUL.get()) out.send(newPacketFloat(pin1 * pin2));
    else if (valDEV.get() && pin2 != 0) out.send(newPacketFloat(pin1 / pin2));
  }
  MCalc clear() {
    super.clear(); return this; }
}

class MBool extends Macro_Bloc {
  Macro_Connexion in1, in2, out;
  nLinkedWidget widgAND, widgOR; 
  sBoo valAND, valOR;
  boolean pin1 = false, pin2 = false;
  MBool(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "bool", "bool", _bloc); 
    
    valAND = ((sBoo)(value_bloc.getValue("valAND"))); 
    valOR = ((sBoo)(value_bloc.getValue("valOR"))); 
    
    if (_bloc == null) valAND = value_bloc.newBoo("valAND", "valAND", false);
    else valAND = (sBoo)(value_bloc.getValue("valAND"));
    if (_bloc == null) valOR = value_bloc.newBoo("valOR", "valOR", false);
    else valOR = (sBoo)(value_bloc.getValue("valOR"));
    
    in1 = addInput(0, "in").setFilterBool().addEventReceive(new Runnable() { public void run() { 
      if (in1.getLastPacket() != null && in1.getLastPacket().isBool() && in1.getLastPacket().asBool() != pin1) {
        pin1 = in1.getLastPacket().asBool(); receive(); } } });
    in2 = addInput(0, "in").setFilterBool().addEventReceive(new Runnable() { public void run() { 
      if (in2.getLastPacket() != null && in2.getLastPacket().isBool() && in2.getLastPacket().asBool() != pin2) {
        pin2 = in2.getLastPacket().asBool(); receive(); } } });
    
    out = addOutput(1, "out")
      .setDefBool();
    
    Macro_Element e = addEmptyS(1);
    widgAND = e.addLinkedModel("MC_Element_Button_Selector_1", "&&").setLinkedValue(valAND);
    widgOR = e.addLinkedModel("MC_Element_Button_Selector_2", "||").setLinkedValue(valOR);
    widgAND.addExclude(widgOR);
    widgOR.addExclude(widgAND);
    
  }
  void receive() { 
    if (valAND.get() && (pin1 && pin2)) 
        out.send(newPacketBool(true));
    else if (valOR.get() && (pin1 || pin2)) 
      out.send(newPacketBool(true));
    else if (valAND.get() || valOR.get()) 
      out.send(newPacketBool(false));
  }
  MBool clear() {
    super.clear(); return this; }
}


class MBin extends Macro_Bloc {
  Macro_Connexion in, out;
  MBin(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "bin", "bin", _bloc); 
    
    in = addInput(0, "in").setFilterBin().addEventReceive(new Runnable() { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isBool() && 
          in.getLastPacket().asBool()) out.send(newPacketBang()); 
      if (in.getLastPacket() != null && in.getLastPacket().isBang()) out.send(newPacketBool(true)); } });
    out = addOutput(1, "out")
      .setDefBool();
  }
  MBin clear() {
    super.clear(); return this; }
}

class MNot extends Macro_Bloc {
  Macro_Connexion in, out;
  MNot(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "not", "not", _bloc); 
    
    in = addInput(0, "in").setFilterBool().addEventReceive(new Runnable() { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isBool()) {
        if (in.getLastPacket().asBool()) out.send(newPacketBool(false)); 
        else out.send(newPacketBool(true)); } } });
    out = addOutput(1, "out")
      .setDefBool();
  }
  MNot clear() {
    super.clear(); return this; }
}

class MGate extends Macro_Bloc {
  Macro_Connexion in_m, in_b, out;
  MGate(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "gate", "gate", _bloc); 
    
    in_m = addInput(0, "in").addEventReceive(new Runnable() { public void run() { receive(); } });
    in_b = addInput(0, "gate").addEventReceive(new Runnable() { public void run() { receive(); } });
    out = addOutput(1, "out");
  }
  void receive() {
    if (in_m.getLastPacket() != null && in_b.getLastPacket() != null && in_b.getLastPacket().isBool() && 
        in_b.getLastPacket().asBool()) {
      out.send(in_m.getLastPacket());
    }
  }
  MGate clear() {
    super.clear(); return this; }
}

class MTrig extends Macro_Bloc {
  Macro_Connexion out_t;
  nCtrlWidget trig; 
  MTrig(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "trig", "trig", _bloc); 
    
    trig = addEmptyS(0).addCtrlModel("MC_Element_SButton").setRunnable(new Runnable() { public void run() {
      out_t.send(newPacketBang());
    } });
    out_t = addOutput(1, "trig")
      .setDefBang();
  }
  MTrig clear() {
    super.clear(); return this; }
}
class MSwitch extends Macro_Bloc {
  Macro_Connexion out_t;
  nLinkedWidget swtch; 
  sBoo state;
  MSwitch(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "switch", "switch", _bloc); 
    
    state = ((sBoo)(value_bloc.getValue("state"))); 
    if (_bloc == null) state = value_bloc.newBoo("state", "state", false);
    else state = (sBoo)(value_bloc.getValue("state"));
    
    swtch = addEmptyS(0).addLinkedModel("MC_Element_SButton").setLinkedValue(state);
    
    state.addEventChange(new Runnable() { public void run() {
      out_t.send(newPacketBool(state.get()));
    } });
    
    out_t = addOutput(1, "out")
      .setDefBool();
    
    mmain().inter.addEventNextFrame(new Runnable() { public void run() {
      out_t.send(newPacketBool(state.get()));
    } });
    
  }
  MSwitch clear() {
    super.clear(); return this; }
}

class MKeyboard extends Macro_Bloc {
  Macro_Connexion out_t;
  nLinkedWidget key_field; 
  sStr val_cible; 
  MKeyboard(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "keyb", "keyb", _bloc); 
    val_cible = ((sStr)(value_bloc.getValue("cible"))); 
    if (_bloc == null) val_cible = value_bloc.newStr("cible", "cible", "");
    else val_cible = (sStr)(value_bloc.getValue("cible"));
    init();
  }
  void init() {
    key_field = addEmptyS(0).addLinkedModel("MC_Element_SField").setLinkedValue(val_cible);
    out_t = addOutput(1, "trig")
      .setDefBang();
    key_field.addEventFrame(new Runnable() { public void run() {
      if (mmain().inter.input.keyAll.state && key_field.getText().length() > 0 && 
          key_field.getText().charAt(0) == mmain().inter.input.getLastKey()) 
        out_t.send(newPacketBang());
    } } );
  }
  MKeyboard clear() {
    super.clear(); return this; }
  
}class MData extends Macro_Bloc {
  void setValue(sValue v) {
    val_cible.set(v.ref);
    cible = v; val_field.setLinkedValue(cible);
    if (cible.type.equals("flt")) setValue((sFlt)cible);
    if (cible.type.equals("int")) setValue((sInt)cible);
    if (cible.type.equals("boo")) setValue((sBoo)cible);
    if (cible.type.equals("str")) setValue((sStr)cible);
    if (cible.type.equals("run")) setValue((sRun)cible);
    if (cible.type.equals("vec")) setValue((sVec)cible);
  }
  void setValue(sFlt v) {
    
  }
  void setValue(sInt v) {
    
  }
  void setValue(sBoo v) {
    
  }
  void setValue(sStr v) {
    
  }
  void setValue(sRun v) {
    rval = v;
    v.addEventChange(new Runnable() { public void run() { out.send(newPacketBang()); }});
    in.addEventReceive(new Runnable() { public void run() { 
      if (in.getLastPacket() != null && in.getLastPacket().isBang()) { 
        rval.doEvent(false); rval.run(); rval.doEvent(true); }
    } });
  }
  void setValue(sVec v) {
    
  }
  sRun rval;
  Macro_Connexion in, out;
  sStr val_cible; 
  sValue cible;
  nLinkedWidget ref_field; 
  nWatcherWidget val_field;
  MData(Macro_Sheet _sheet, sValueBloc _bloc, sValue v) { 
    super(_sheet, "data", "data", _bloc); 
    val_cible = ((sStr)(value_bloc.getValue("cible"))); 
    if (_bloc == null) val_cible = value_bloc.newStr("cible", "cible", "");
    else val_cible = (sStr)(value_bloc.getValue("cible"));
    init();
    if (v != null) setValue(v);
  }
  void init() {
    ref_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_cible);
    val_field = addEmptyL(0).addWatcherModel("MC_Element_Text");
    val_cible.addEventChange(new Runnable(this) { public void run() { get_cible(); } } );
    addEmpty(1); addEmpty(1);
    in = addInput(0, "in");
    out = addOutput(1, "out");
    in.addEventReceive(new Runnable(this) { public void run() { get_cible(); } } );
    get_cible();
  }
  void get_cible() {
    cible = sheet.value_bloc.getValue(val_cible.get());
    if (cible != null) setValue(cible);
  }
  MData clear() {
    super.clear(); return this; }
}




class MSheetIn extends Macro_Bloc {
  Macro_Element elem;
  MSheetIn(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "sheet_in", "in", _bloc); 
    init();
  }
  void init() {
    elem = addSheetInput(0, "in");
    val_title.addEventChange(new Runnable() { public void run() { 
      elem.sheet_connect.lens.setInfo(val_title.get()); } });
  }
  MSheetIn clear() {
    super.clear(); return this; }
}

class MSheetOut extends Macro_Bloc {
  Macro_Element elem;
  MSheetOut(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "sheet_out", "out", _bloc); 
    init();
  }
  void init() {
    elem = addSheetOutput(0, "out");
    val_title.addEventChange(new Runnable() { public void run() { 
      elem.sheet_connect.lens.setInfo(val_title.get()); } });
  }
  MSheetOut clear() {
    super.clear(); return this; }
}


/*

 bloc extend abstract
 shelfpanel of element
 methods to add and manipulate element for easy macro building
 
 */
class Macro_Bloc extends Macro_Abstract {
  ArrayList<Macro_Element> elements = new ArrayList<Macro_Element>();
  Macro_Bloc toLayerTop() { 
    super.toLayerTop(); 
    for (Macro_Element e : elements) e.toLayerTop(); 
    grabber.toLayerTop(); 
    return this;
  }

  Macro_Bloc(Macro_Sheet _sheet, String t, String n, sValueBloc _bloc) {
    super(_sheet, t, n, _bloc);
    addShelf(); 
    addShelf();
  }

  Macro_Element addEmptyS(int c) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Single", null, NO_CO, NO_CO, true);
    addElement(c, m); 
    return m;
  }
  Macro_Element addEmptyL(int c) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Double", null, NO_CO, NO_CO, false);
    addElement(c, m); 
    return m;
  }
  nWidget addEmpty(int c) { 
    Macro_Element m = new Macro_Element(this, "", "mc_ref", null, NO_CO, NO_CO, false);
    addElement(c, m); 
    return m.back;
  }

  nWidget addFillR(int c) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Fillright", null, NO_CO, NO_CO, false);
    addElement(c, m); 
    return m.back;
  }
  nWidget addFillL(int c) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Fillleft", null, NO_CO, NO_CO, false);
    addElement(c, m); 
    return m.back;
  }

  nWidget addLabelS(int c, String t) { 
    Macro_Element m = new Macro_Element(this, t, "MC_Element_Single", null, NO_CO, NO_CO, true);
    addElement(c, m); 
    return m.back;
  }
  nWidget addLabelL(int c, String t) { 
    Macro_Element m = new Macro_Element(this, t, "MC_Element_Double", null, NO_CO, NO_CO, false);
    addElement(c, m); 
    return m.back;
  }

  Macro_Connexion addInput(int c, String t) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Single", t, INPUT, INPUT, true);
    if (m.sheet_connect != null) m.sheet_connect.direct_connect(m.connect);
    addElement(c, m); 
    return m.connect;
  }
  Macro_Connexion addOutput(int c, String t) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Single", t, OUTPUT, OUTPUT, true);
    if (m.sheet_connect != null) m.connect.direct_connect(m.sheet_connect);
    addElement(c, m); 
    return m.connect;
  }
  Macro_Element addSheetInput(int c, String t) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Single", t, OUTPUT, INPUT, true);
    if (m.sheet_connect != null) m.sheet_connect.direct_connect(m.connect);
    addElement(c, m); 
    return m;
  }
  Macro_Element addSheetOutput(int c, String t) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Single", t, INPUT, OUTPUT, true);
    if (m.sheet_connect != null) m.connect.direct_connect(m.sheet_connect);
    addElement(c, m); 
    return m;
  }


  Macro_Element addElement(int c, Macro_Element m) {
    if (c >= 0 && c < 3) {
      if (c == 2) addShelf();
      elements.add(m);
      getShelf(c).insertDrawer(m);
      if (c == 0 && getShelf(c).drawers.size() == 1) getShelf(c).getDrawer(0).ref.setPX(-ref_size*0.0);
      if (c == 1 && getShelf(c).drawers.size() == 1) getShelf(c).getDrawer(0).ref.setPX(ref_size*0.5);
      if (c == 2 && getShelf(c).drawers.size() == 1) getShelf(c).getDrawer(0).ref.setPX(ref_size);
      return m;
    } else return null;
  }
  
  Macro_Bloc open() {
    super.open();
    for (Macro_Element m : elements) m.show();
    return this;
  }
  Macro_Bloc reduc() {
    super.reduc();
    for (Macro_Element m : elements) m.reduc();
    return this;
  }
  Macro_Bloc show() {
    super.show();
    for (Macro_Element m : elements) m.show();
    return this;
  }
  Macro_Bloc hide() {
    super.hide(); 
    for (Macro_Element m : elements) m.hide();
    return this;
  }
}
