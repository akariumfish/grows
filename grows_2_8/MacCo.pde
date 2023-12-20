
/*
connexion 
 circle, hard outline, transparent, mode in or out, exist in a sheet, has an unique number
 has a label with no back for a short description and a field acsessible or not for displaying values
 the label and values are aligned, either of them can be on the left or right
 the connexion circle is on the left right top or down side center of
 the rectangle formed by the label and values
 priority button
 2 round button on top of eachother on left top corner of the connect
 1 round widget covering half of each button with the priority layer
 highlight connectable in when creating link
 package info on top of connections
 
 */
class Macro_Connexion extends nBuilder {
  Macro_Element getElement() { return elem; }

  Macro_Connexion toLayerTop() { 
    super.toLayerTop(); 
    lens.toLayerTop(); 
    ref.toLayerTop(); 
    return this;
  }

  nWidget ref, lens;
  Macro_Element elem;
  Macro_Connexion(Macro_Element _elem, int _side) {
    super(_elem.gui, _elem.ref_size); 
    elem = _elem;
    lens = addModel("MC_Connect")
      .setSize(ref_size*14/16, ref_size*14/16)
      .setPosition(-ref_size*5/16, -ref_size*5/16)
      ;
    ref = addModel("MC_Connect_Link")
      .setSize(ref_size*4/16, ref_size*4/16)
      .setPosition(-ref_size*6/16, ref_size*5/16)
      .setDrawable(new Drawable(gui.drawing_pile, 0) { 
      public void drawing() {
        if (lens.isClicked) { 
          fill(ref.look.pressColor);
        } else if (lens.isHovered) { 
          fill(ref.look.hoveredColor);
        } else { 
          fill(ref.look.standbyColor);
        }
        noStroke();
        ellipseMode(CORNER);
        ellipse(ref.getX(), ref.getY(), ref.getSX(), ref.getSY());

        noFill();
        if (lens.isClicked) { 
          stroke(ref.look.pressColor);
        } else if (lens.isHovered) { 
          stroke(ref.look.hoveredColor);
        } else noStroke();
        strokeWeight(ref.look.outlineWeight);
        ellipse(ref.getX() - ref.look.outlineWeight, ref.getY() - ref.look.outlineWeight, 
          ref.getSX() + ref.look.outlineWeight * 2, ref.getSY() + ref.look.outlineWeight * 2);
          
        
      }
    } 
    );
    ref.setParent(elem.back);
    if (_side == RIGHT) ref.alignRight().setPX(-ref.getLocalX());
    lens.setParent(ref);
  }
  void to_save(Save_Bloc sbloc) {
    
  }
  void from_save(Save_Bloc sbloc) {
    
  }
}

/*

 element > drawer
 has a text pour l'info bulle
 is a rectangle without back who can hold different function :
 button trigger / switch > runnable
 label for info or values > element has method to set
 selector : multi switch exclusives or not > runnable
 slide?
 jauge and graph? 
 connexions 4 places possible
 
 */
class Macro_Element extends nDrawer {
  Macro_Element addB(String r) { 
    back.copy(gui.theme.getModel(r)); 
    return this;
  }
  Macro_Element addS() {  return addB("MC_Element_Single"); }
  Macro_Element addD() {  return addB("MC_Element_Double"); }
  Macro_Element addFL() {  return addB("MC_Element_Fillleft"); }
  Macro_Element addFR() {  return addB("MC_Element_Fillright"); }

  Macro_Connexion addConnection(int side) { 
    if (back != null) connect = new Macro_Connexion(this, side); 
    return connect;
  }

  Macro_Bloc getBloc() { return bloc; }

  nWidget back = null;
  Macro_Connexion connect = null;
  Macro_Bloc bloc;
  Macro_Element(Macro_Bloc _bloc) {
    super(_bloc.getShelf(), _bloc.ref_size*1.375, _bloc.ref_size);
    bloc = _bloc;
    back = addModel("mc_ref");
    //bloc.toLayerTop();
  }
  Macro_Element toLayerTop() { 
    super.toLayerTop(); 
    if (connect != null) connect.toLayerTop(); 
    return this;
  }
  void to_save(Save_Bloc sbloc) {
    connect.to_save(sbloc);
  }
  void from_save(Save_Bloc sbloc) {
    connect.from_save(sbloc);
  }
}
