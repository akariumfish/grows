


class MKeyboard extends Macro_Bloc {
  Macro_Connexion out_t;
  nLinkedWidget key_field; 
  sStr val_cible; 
  MKeyboard(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "keyb", "keyb", _bloc); 
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
  
}



/*
 */
class MData extends Macro_Bloc {
  void setValue(sValue v) {
    val_cible.set(v.ref);
    cible = v; val_field.setLinkedValue(cible);
  }
  Macro_Connexion in, out;
  sStr val_cible; 
  sValue cible;
  nLinkedWidget ref_field; 
  nWatcherWidget val_field;
  MData(Macro_Sheet _sheet, sValueBloc _bloc, sValue v) { 
    super(_sheet, "data", "data", _bloc); 
    if (_bloc == null) val_cible = value_bloc.newStr("cible", "cible", "");
    else val_cible = (sStr)(value_bloc.getValue("cible"));
    init();
    if (v != null) setValue(v);
  }
  void init() {
    ref_field = addEmptyL(0).addLinkedModel("MC_Element_Field").setLinkedValue(val_cible);
    val_field = addEmptyL(0).addWatcherModel("MC_Element_Field");
    val_cible.addEventChange(new Runnable(this) { public void run() { get_cible(); } } );
    addEmpty(1); addEmpty(1);
    in = addInput(0, "in");
    out = addOutput(1, "out");
    in.addEventReceive(new Runnable(this) { public void run() { get_cible(); } } );
    get_cible();
  }
  void get_cible() {
    cible = sheet.value_bloc.getValue(val_cible.get());
    if (cible != null) val_field.setLinkedValue(cible);
  }
  MData clear() {
    super.clear(); return this; }
}




class MSheetCo extends Macro_Bloc {
  Macro_Connexion in, sin, out, sout;
  MSheetCo(Macro_Sheet _sheet, sValueBloc _bloc) { 
    super(_sheet, "sheet_co", "co", _bloc); 
    init();
  }
  void init() {
    addLabelL(0, "sheet connection");
    addEmpty(1);
    addInput(0, "in");
    addOutput(1, "out");
  }
  MSheetCo clear() {
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
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Single", t, INPUT, OUTPUT, true);
    m.connect.direct_connect(m.sheet_connect);
    addElement(c, m); 
    return m.connect;
  }
  Macro_Connexion addOutput(int c, String t) { 
    Macro_Element m = new Macro_Element(this, "", "MC_Element_Single", t, OUTPUT, INPUT, true);
    m.connect.direct_connect(m.sheet_connect);
    addElement(c, m); 
    return m.connect;
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
