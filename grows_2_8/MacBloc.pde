
/*

 bloc extend abstract
 shelfpanel of element
 methods to add and manipulate element for easy macro building
 
 */
class MData extends Macro_Bloc {

  MData(Macro_Sheet _sheet) {
    super(_sheet, "data");
    addElement(0).addS().addConnection(LEFT).getElement().getBloc();
    addElement(0).addS().addConnection(RIGHT).getElement().getBloc();
  }
  void to_save(Save_Bloc sbloc) {
    super.to_save(sbloc);
  }
  void from_save(Save_Bloc sbloc) {
    super.from_save(sbloc);
  }
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

  Macro_Bloc(Macro_Sheet _sheet, String t) {
    super(_sheet, t);
    addShelf(); 
    addShelf();
  }
  Macro_Element addElement(int c) {
    if (c >= 0 && c < 3) {
      if (c == 2) addShelf();
      Macro_Element m = new Macro_Element(this);
      elements.add(m);
      getShelf(c).insertDrawer(m);
      if (c == 0 && getShelf(c).drawers.size() == 1) getShelf(c).getDrawer(0).ref.setPX(-ref_size*0.0);
      if (c == 1 && getShelf(c).drawers.size() == 1) getShelf(c).getDrawer(0).ref.setPX(ref_size*0.5);
      if (c == 2 && getShelf(c).drawers.size() == 1) getShelf(c).getDrawer(0).ref.setPX(ref_size);
      updatePanel();
      return m;
    } else return null;
  }
  
  void to_save(Save_Bloc sbloc) {
    super.to_save(sbloc);
  }
  void from_save(Save_Bloc sbloc) {
    super.from_save(sbloc);
  }
}
