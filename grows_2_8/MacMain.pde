/*


  
  multiple bloc reduction levels :
    close : 
      only grab and connected co circles (arranged in 6 spot around grabber)
      co and bloc name by infobulle
      when hovered show an open button down
      losange / cut corner rect with darker outline
    open : show more
      panel with certain elements (with infobulle for descriptions) no fill grey outline
      name on hard back  with outline overlapp panel outline on down side right
      grabber overlap panel outline on top side left
      buttons to deploy/close opposite to grabber, deploy overlapp 2/3 to the exterior, close 1/3
      this is what is shown when on a sheet spot and the sheet is reducted (only open not deployed)
    deployed : 
      full pareters, inside blocs for sheet (soft back deployed)
  
  things are build around a grid when reducted, so they can be snapped together to form theire sheet panel

  grabber center or one side center
  snap to grid


connexion > element has method to send + runnable for receive
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

element > drawer
  has a text pour l'info bulle
  is a rectangle without back who can hold different function :
    button trigger / switch > runnable
    label for info or values > element has method to set
    selector : multi switch exclusives or not > runnable
    jauge and graph? 
    connexion

abstract extend shelfpanel
  can be selected and group dragged copy/pasted > template or deleted

bloc extend abstract
  shelfpanel of element
  methods to add and manipulate element for easy macro building
  
  show directly connected in/out to detect loop more easily 
    (cad show that an in will diectly send through an out of his bloc when receiving)
    use 2 axis aligned lines following elements outlines from connexions to connexions
  
sheet extend abstract
  shelfpanel of shown bloc
  receive frame call if asked (overwriten method? not for small sheet)
  will be extended to make Simulation and communitys
  methods for creating svalues > create corresponding bloc, but reducted for visibility
    create in grid around center
  methods for adding blocs inside
  
  can build a menu with all value manipulable with easy drawer
    can choose drawer type when creating value
    can set value limits
  
  has spot for blocs to display when reducted
    child bloc au dessus du panel can snap to spot
    
  no sheet co, stick to a free place in the hard back to make a co 
    
  quand une sheet est ouverte sont soft back est trensparent et sont parent est caché
  seulement une top sheet ouverte a la fois
  cant be grabbed when open

main
  is a sheet without grabber and with panel snapped to camera all time
  is extended to interface ? so work standalone with UI
  
  dont show soft back
  
  contain a valuebloc for storing templates
    and a valuebloc for the setup templates who is auto loaded
  
  sheet on the main sheet can be snapped to camera, 
    they will keep their place and size and show panel content
    only work when not deployed
  
  dedicted toolpanel on top left of screen
    has button :
      -delete selected blocs
      -save/paste template
      -drop down for basic macro
      -menu: see and organise template and sheet (goto sheet)



Template :
  -save selected sheet structure to template sValueBloc has sTmp
    popup for name with field and ok button
  -paste last template (or one selected in menu) in selected sheet, 
    if the sheet panel was selected when created it will produce a child sheet, 
    or replace it if the sheet panel is selected when pasting.
    otherwise it will create a group of blocs and sheets inside the selected sheet
  sTemplate : sTmp
    sValue template
    extended from sString
    can be send as packet
    macro can create macro !!!! > basic bloc create
  
basic bloc :
  data, memory, user set value, random,
  calc, comp, bool, not, bin(bang to bool),
  trigg, switch, keyboard, gate, delay, pulse
  pack / unpack > type transform like vec/float 
  setreset, counter, sequance, multigate : as template
  
MData : sValue access : only hold a string ref, search for corresponding svalue inside current sheet at creation
  if no value is found create one
  has in and out
  out can send on change or when receiving bang
  if it cible a vec, the bloc can follow the corresponding position 
  in can change value multiple way
    bool : set / switch
    num : set / mult / add
    vec : set / mult / add for values rotation and magnitude
    tmpl : in bang > build in same sheet / parent sheet
  
memory : when a packet is received, display and store it, send it when a bang is received
  can as disable bool input
  
macro turn:
  no tick anywhere > simulation gives tick
  no frame loop, works only by reacting to gui or input event (for keyboard create a keypress/release event)
    only time bloc have frame loop, delay and pulse need them, get it throug gui
    
  when at a frame an out whant to send :
    all out who want to send do it, input save msg
    if an out have multiple exit packet are send in input priority order
    once no out whant to send all input process msg in function of the corresponding output priority 
    order and mark their out for sending eventually
    once all in have processed their msg we start again if there is an out who want to send
    careful! loop can occur, 1 turn delays will fix them
    
  when in a connexion recursive loop count the depth to detect loop and break them 
    show a popup and desactivate everything somehow

*/
/*

 
             DESIGN
     !! MACRO ARE CRYSTALS !!
 
   hide labels! 
   forme carre > plus petit possible
   overlapp rectangles with those under them to show solidarity
 
 
   GUI to build
     widget jauge / graph
     widget qui englode auto des widget cible avec le mm parent que lui plus eventuellement sont parent
     drawer de losange
 
     grid snap grabber
     group grabbing
     group event call
 
     text asking popup
       build it
       call it.popup
       will respond with a runnable
 
 
 multiple bloc reduction levels :
   close : 
     only grab and connected co circles (arranged in 6 spot around grabber)
     co and bloc name by infobulle
     when hovered show an open button down
     losange / cut corner rect with darker outline
   open : show more
     panel with certain elements (with infobulle for descriptions) no fill grey outline
     name on hard back  with outline overlapp panel outline on down side right
     grabber overlap panel outline on top side left
     buttons to deploy/close opposite to grabber, deploy overlapp 2/3 to the exterior, close 1/3
     this is what is shown when on a sheet spot and the sheet is reducted (only open not deployed)
   deployed : 
     full pareters, inside blocs for sheet (soft back deployed)
 
   things are build around a grid when reducted, so they can be snapped together to form theire sheet panel
 
   snap to grid
 
 
 */



void myTheme_MACRO(nTheme theme, float ref_size) {
  theme.addModel("mc_ref", new nWidget()
    .setPassif()
    .setLabelColor(color(200, 200, 220))
    .setFont(int(ref_size/1.6))
    );
  theme.addModel("MC_Panel", theme.newWidget("mc_ref")
    .setStandbyColor(color(50, 0))
    .setOutlineColor(color(105))
    .setOutlineWeight(ref_size * 2.0 / 16.0)
    .setOutline(true)
    );
  
  theme.addModel("MC_Title", theme.newWidget("mc_ref")
    .setStandbyColor(color(40))
    .setOutlineColor(color(80))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    .setFont(int(ref_size/1.6))
    .setText("--")
    .setSize(ref_size*2, ref_size*0.75).setPosition(ref_size*1.0, ref_size*0.5)
    );
  theme.addModel("MC_Front", theme.newWidget("mc_ref")
    .setStandbyColor(color(50, 0))
    .setOutlineColor(color(200))
    .setOutlineSelectedColor(color(200, 200, 0))
    .setOutlineWeight(ref_size * 3.0 / 16.0)
    .setPassif()
    );
  theme.addModel("MC_Front_Bloc", theme.newWidget("MC_Front")
    .setOutlineSelectedColor(color(200))
    .setOutlineWeight(ref_size * 1.0 / 16.0)
    );
  theme.addModel("MC_Panel_Spot", theme.newWidget("mc_ref")
    .setStandbyColor(color(50))
    .setOutlineColor(color(105, 105, 80))
    .setOutlineWeight(ref_size * 2.0 / 16.0)
    .setSize(ref_size*2, ref_size*2)
    .setOutline(true)
    );
  theme.addModel("MC_Sheet_Back", theme.newWidget("mc_ref")
    .setStandbyColor(color(45))
    .setOutlineColor(color(140))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    );
  theme.addModel("MC_Element", theme.newWidget("mc_ref")
    .setStandbyColor(color(70))
    .setOutlineColor(color(90))
    .setOutlineWeight(ref_size / 16)
    .setOutline(true)
    .setPosition(-ref_size*0.5, 0)
    );
  theme.addModel("MC_Element_Single", theme.newWidget("MC_Element")
    .setSize(ref_size*2, ref_size)
    );
  theme.addModel("MC_Element_Double", theme.newWidget("MC_Element")
    .setSize(ref_size*4.125, ref_size)
    );
  theme.addModel("MC_Element_Fillright", theme.newWidget("MC_Element")
    .setSize(ref_size*0.5, ref_size*1.625)
    .setPosition(ref_size*1.25, -ref_size*0.25)
    );
  theme.addModel("MC_Element_Fillleft", theme.newWidget("MC_Element")
    .setSize(ref_size*0.5, ref_size*1.625)
    .setPosition(-ref_size*2.875, -ref_size*0.25)
    );
  theme.addModel("MC_Grabber", theme.newWidget("mc_ref")
    .setStandbyColor(color(70))
    .setHoveredColor(color(100))
    .setClickedColor(color(130))
    .setOutlineWeight(ref_size / 6)
    .setOutline(true)
    .setOutlineColor(color(150))
    .setLosange(true)
    .setSize(ref_size*1, ref_size*0.75)
    .setGrabbable()
    );
  theme.addModel("MC_Basic", theme.newWidget("mc_ref")
    .setStandbyColor(color(100))
    .setHoveredColor(color(125))
    .setClickedColor(color(150))
    .setOutlineWeight(ref_size / 8)
    .setOutline(true)
    .setOutlineColor(color(150))
    .setLosange(true)
    .setTrigger()
    .setSize(ref_size*0.75, ref_size*0.75)
    .setPosition(-ref_size*0.375, -ref_size*0.375)
    );
  theme.addModel("MC_Reduc", theme.newWidget("MC_Basic")
    .setStandbyColor(color(60))
    .setHoveredColor(color(90))
    .setClickedColor(color(120))
    .setOutlineWeight(ref_size / 12)
    .setSX(ref_size*0.5).setPosition(-ref_size*1.0, ref_size*0.375)
    );
  theme.addModel("MC_Connect", theme.newWidget("mc_ref")
    .setStandbyColor(color(140, 140))
    .setHoveredColor(color(180, 180))
    .setClickedColor(color(180, 220))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    .setOutlineColor(color(90))
    .setRound(true)
    .setTrigger()
    );
  theme.addModel("MC_Connect_Link", theme.newWidget("mc_ref")
    .setStandbyColor(color(200))
    .setHoveredColor(color(205, 205, 200))
    .setClickedColor(color(220, 220, 200))
    .setOutlineWeight(ref_size / 10)
    .setOutline(true)
    .setRound(true)
    );
}

import java.util.Map;



void mySetup_MACRO(sInterface inter) {
  Macro_Main mmain = inter.macro_main;
  
  Macro_Sheet s1 = mmain.addSheet();
  
}



/*
abstract extend shelfpanel
 can be selected and group dragged copy/pasted > template or deleted
 
 */
class Macro_Abstract extends nShelfPanel {
  Macro_Abstract setPosition(float x, float y) { 
    grabber.setPosition(x, y); 
    return this;
  }
  Macro_Abstract setParent(Macro_Sheet s) {
    grabber.clearParent();
    grabber.setParent(s.grabber);
    return this;
  }
  nWidget customBuild(nWidget w) { 
    super.customBuild(w); 
    //if (grabber != null) toLayerTop(); 
    return w;
  }
  Macro_Abstract toLayerTop() { 
    super.toLayerTop(); 
    if (grabber != null) grabber.toLayerTop(); if (front != null) front.toLayerTop(); reduc.toLayerTop();
    return this;
  }

  Macro_Abstract updatePanel() {
    panel.setPosition(-grabber.getLocalSX()/4, grabber.getLocalSY()/2 + ref_size * 1 / 8);
    return this;
  }
  
  Macro_Abstract open() {
    panel.show();
    title.hide();
    reduc.setPosition(-ref_size, ref_size*0.375);
    return this;
  }
  Macro_Abstract reduc() {
    panel.hide();
    reduc.show().setPosition(ref_size * 0.75, ref_size*0.5);
    return this;
  }
  Macro_Abstract changeOpenning() {
    if (openning == OPEN) { reduc(); openning = REDUC; }
    else if (openning == REDUC) { open(); openning = OPEN; }
    return this; }
  
  nGUI gui;
  Macro_Sheet sheet;    int sheet_depth = 0;
  boolean szone_selected = false;
  float ref_size = 40;
  static final int REDUC = 0, OPEN = 1, DEPLOY = 2;
  int openning = OPEN;
  
  String type;
  String description = "macro";

  nWidget grabber, reduc, front, title;
  
  Macro_Main mmain() { if (sheet == this) return (Macro_Main)this; return sheet.mmain(); }

  Macro_Abstract(Macro_Sheet _sheet, String ty) {
    super(_sheet.gui, _sheet.ref_size, 0.25);
    gui = _sheet.gui; 
    ref_size = _sheet.ref_size; 
    sheet = _sheet;
    type = ty;
    if (sheet != null) { sheet_depth = sheet.sheet_depth + 1; }

    grabber = addModel("MC_Grabber")
      .clearParent();
    grabber.addEventDrag(new Runnable(this) { public void run() { 
      title.hide();
      grabber.setPY(grabber.getLocalY() - grabber.getLocalY()%(ref_size * 0.5));
      grabber.setPX(grabber.getLocalX() - grabber.getLocalX()%(ref_size * 0.5));
      
      sheet.movingChild(((Macro_Abstract)builder)); 
      
      // the group of selected update their pos only when grabber stop
      //moving for 10 20 frame
      
    } });
    grabber.addEventRelease(new Runnable() { public void run() {  } });
    panel.copy(gui.theme.getModel("MC_Panel"));
    panel.setParent(grabber);
    updatePanel();
    
    panel.addEventShapeChange(new Runnable() { public void run() {
      front.setSize(panel.getLocalSX(), panel.getLocalSY());
    } } );
    
    reduc = addModel("MC_Reduc").clearParent();
    reduc.setParent(panel);
    reduc.alignDown().stackRight().addEventTrigger(new Runnable() { public void run() { changeOpenning(); } });
    
    grabber.addEventMouseEnter(new Runnable() { public void run() { title.show(); } });
    grabber.addEventMouseLeave(new Runnable() { public void run() { title.hide(); } });
    title = addModel("MC_Title").clearParent();
    title.setParent(panel);
    title.alignDown().stackLeft().hide();
    
    front = addModel("MC_Front_Bloc")
      .setParent(panel)
      .addEventFrame(new Runnable() { public void run() { 
        if (mmain().szone.isSelecting()) {
          if (mmain().viewed_sheet == sheet) {
            if (mmain().szone.isUnder(front)) front.setOutline(true);
            else front.setOutline(false);
          }
        }
      } } )
      ;
    if (mmain() != this) {
      mmain().szone.addEventStartSelect(new Runnable() { public void run() { 
        szone_selected = false;
        front.setOutline(false);
      } } );
      mmain().szone.addEventEndSelect(new Runnable(this) { public void run() { 
        if (mmain().viewed_sheet == sheet && mmain().szone.isUnder(front))  {
          mmain().selected_macro.add(((Macro_Abstract)builder));
          szone_selected = true;
        }
      } } );
    }
    
    
  }
  Macro_Abstract(nGUI g, float rs) { // FOR MACRO_MAIN ONLY
    super(g, rs, 0.125);
    gui = g; 
    ref_size = rs; 
    sheet = (Macro_Sheet)this;
    myTheme_MACRO(gui.theme, ref_size); 
    panel.copy(gui.theme.getModel("mc_ref"));
    grabber = addModel("mc_ref")
      .clearParent();
    panel.hide(); 
    grabber.setSize(0, 0).setPassif().setOutline(false);
    front = addModel("mc_ref");
    title = addModel("mc_ref");
  }
  
  void to_save(Save_Bloc sbloc) {
    sbloc.newData("type", type);
    sbloc.newData("title", title.getText());
    sbloc.newData("x",grabber.getLocalX());
    sbloc.newData("y",grabber.getLocalY());
  }
  
  void from_save(Save_Bloc sbloc) {
    type = sbloc.getData("name");
    title.setText(sbloc.getData("title"));
    grabber.setPX(sbloc.getFloat("x"));
    grabber.setPY(sbloc.getFloat("y"));
  }
  
}


/*

 sheet extend abstract
 shelfpanel of shown bloc
 
 
 methods for adding blocs inside
 
 has spot for blocs to display when reducted
 child bloc au dessus du panel can snap to spot
 
 no sheet co, stick to a free place in the hard back to make a co 
 
 quand une sheet est ouverte sont soft back est trensparent et sont parent est caché
 seulement une top sheet ouverte a la fois
 cant be grabbed when open
 
 */
class Macro_Sheet extends Macro_Abstract {
  
  ArrayList<Macro_Abstract> child_macro = new ArrayList<Macro_Abstract>(0);
  ArrayList<Macro_Sheet> child_sheet = new ArrayList<Macro_Sheet>(0);
  
  void movingChild(Macro_Abstract child) {
    updateSoft();
  }
  void updateSoft() {
    soft.setPosition(panel.getLocalSX()/2 - soft.getLocalSX() / 2, 
                     panel.getLocalSY()/2 - soft.getLocalSY() / 2);
  }
  
  Macro_Sheet open() {
    mmain().closeAll();
    panel.show();
    title.hide();
    reduc.setPosition(-ref_size, ref_size*0.375);
    return this;
  }
  Macro_Sheet reduc() {
    panel.hide();
    if (reduc != null) reduc.show().setPosition(ref_size * 0.75, ref_size*0.5);
    return this;
  }
  void closeAll() {
    for (Macro_Sheet s : child_sheet) { s.reduc(); s.closeAll();  }
    reduc();
  }
  Macro_Sheet toLayerTop() { 
    super.toLayerTop(); 
    grabber.toLayerTop(); 
    if (child_macro != null) for (Macro_Abstract e : child_macro) e.toLayerTop(); 
    return this;
  }
  
  nWidget soft;
  sValueBloc value_bloc = null;
  Macro_Sheet(Macro_Sheet p) {
    super(p, "sheet");
    if (mmain() != p) value_bloc = p.value_bloc.newBloc("new_sheet");
    else mmain().inter.interface_bloc.newBloc("Macro_Main");
    soft = addModel("MC_Sheet_Back");
    soft.clearParent();
    soft.setSize(ref_size*10, ref_size*10);
    soft.setParent(panel);
    addGrid(3, 3, 2, 2);
    for (int i = 0 ; i < 3 ; i++) 
      for (int j = 0 ; j < 3 ; j++) getShelf(i).getDrawer(j).addModel("MC_Panel_Spot"); 
    
    if (mmain() != this) mmain().szone.addEventStartSelect(new Runnable(this) { public void run() { 
      if (mmain().selected_macro.size() == 0 && mmain().szone.isSelecting()) {
        if ((mmain().viewed_sheet == null || mmain().viewed_sheet.sheet_depth < sheet_depth) && 
            mmain().szone.isUnder(front)) {
          
          mmain().viewed_sheet = (Macro_Sheet)builder;
          front.setOutline(true);
        }
        if (!(mmain().viewed_sheet == (Macro_Sheet)builder)) front.setOutline(false);
      } 
    } } );
    updateSoft();
  }
  Macro_Sheet(nGUI g, float rs) {
    super(g, rs);
    soft = addModel("mc_ref");
  }

  int adding_h = 0, adding_v = 0;
  private void addAbstract(Macro_Abstract m) {
    m.setPosition(-16*ref_size + adding_v * ref_size * 8, -3*ref_size + adding_h * ref_size * 6);
    adding_v++; if (adding_v > 4) { adding_v = 0; adding_h++; }
    child_macro.add(m); 
    m.setParent(this); m.toLayerTop(); }
  //Macro_Bloc addBloc() { Macro_Bloc m = new Macro_Bloc(this); addAbstract(m); return m; }

  Macro_Sheet addSheet() { 
    Macro_Sheet m = new Macro_Sheet(this); m.open(); child_sheet.add(m); addAbstract(m); return m; }
  MData addData() { MData m = new MData(this); addAbstract(m); return m; }
  void to_save(Save_Bloc sbloc) {
    super.to_save(sbloc);
  }
  void from_save(Save_Bloc sbloc) {
    super.from_save(sbloc);
  }
}





/*
main
 is a sheet without grabber and with panel snapped to camera all time
 is extended to interface ? so work standalone with UI
 
 dont show soft back
 
 sheet on the main sheet can be snapped to camera, 
 they will keep their place and size and show panel content
 only work when not deployed
 
 dedicated toolpanel on top left of screen
 has button :
 -delete selected blocs
 -save/paste template
 -drop down for basic macro
 -menu: see and organise template and sheet (goto sheet)
 
 
 */
class Macro_Main extends Macro_Sheet {
  nFrontPanel macro_front;  
  nToolPanel macro_tool;
  nDropMenu add_menu;

  void build_macro_menus() {
    
    macro_tool = new nToolPanel(screen_gui, ref_size, 0.125, true, true);
    macro_tool.addShelf().addDrawer(3.25, 1)
        .addCtrlModel("Menu_Button_Small_Outline-S1-P1", "+")
          .setRunnable(new Runnable() { public void run() { add_menu.drop(screen_gui); }})
          .setFont(int(ref_size/1.9)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P2", "M")
          //.setRunnable(new Runnable() { public void run() {  build_macro_frontpanel(); }})
          .setFont(int(ref_size/1.9)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P3", "X")
          //.setRunnable(new Runnable() { public void run() { ; }})
          .setFont(int(ref_size/1.7)).getDrawer();
    //macro_tool.reduc();
    
    add_menu = new nDropMenu(screen_gui, ref_size*1.4, 1, true, false);
    add_menu.addEntry("DATA")
      .setRunnable(new Runnable() { public void run() { adding(M_DATA); }}).setFont(int(ref_size/2.1));
    add_menu.addEntry("SHEET")
      .setRunnable(new Runnable() { public void run() { adding(M_SHEET); }}).setFont(int(ref_size/2.1));
    add_menu.close();
  }
  
  static final int M_DATA = 0, M_SHEET  = 1;
  void adding(int ty) {
    if (ty == M_DATA) viewed_sheet.addData();
    if (ty == M_SHEET) viewed_sheet.addSheet();
  }
  void build_macro_frontpanel() {
    if (macro_front == null) {
      macro_front = new nFrontPanel(screen_gui, inter.taskpanel, "MACRO");
      macro_front.setPosition(screen_gui.view.pos.x + screen_gui.view.size.x - macro_front.grabber.getLocalSX(), 
        screen_gui.view.pos.y + (screen_gui.view.size.y / 15) );
      macro_front.collapse();
    } else macro_front.popUp();
  }

  sInterface inter;
  nGUI cam_gui, screen_gui;
  nInfo info;
  nSelectZone szone;
  Macro_Sheet viewed_sheet = this;
  ArrayList<Macro_Abstract> selected_macro = new ArrayList<Macro_Abstract>();
  
  void updateSoft() {}
  
  void show() { 
    panel.hide();
  }

  Macro_Main(sInterface _int) {
    super(_int.cam_gui, _int.ref_size);
    inter = _int; 
    cam_gui = inter.cam_gui; 
    screen_gui = inter.screen_gui;
    info = new nInfo(cam_gui, ref_size);
    panel.hide();
    
    szone = new nSelectZone(gui);
    szone.addEventStartSelect(new Runnable() { public void run() {
      if (viewed_sheet != null) viewed_sheet.front.setOutline(false);
      viewed_sheet = null;
      selected_macro.clear();
    }}).addEventEndSelect(new Runnable() { public void run() {
      if (viewed_sheet != null) viewed_sheet.front.setOutline(false);
      viewed_sheet = null;
      selected_macro.clear();
    }});

    build_macro_menus();

    inter.screen_gui.addEventSetup(new Runnable() { 
      public void run() { 
        //inter.cam.cam_pos.sety(-height / 3);
      }
    } 
    );
  }
  void to_save(Save_Bloc sbloc) {
    super.to_save(sbloc);
  }
  void from_save(Save_Bloc sbloc) {
    super.from_save(sbloc);
  }
}



























      
