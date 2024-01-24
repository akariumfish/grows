/*


  

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
    (cad show that an in will directly send through an out of his bloc when receiving)
    use 2 axis aligned lines following elements outlines from connexions to connexions
  
sheet extend abstract
  extended to make Simulation and communitys
  methods for creating blocs inside
    create in grid around center
  can build a menu with all value manipulable with easy drawer
    can choose drawer type when creating value
    can set value limits
  has spot for blocs to display when reducted

main
  is a sheet without grabber and with panel snapped to camera all time
  is extended to interface ? so work standalone with UI
  dont show soft back
  sheet on the main sheet can be snapped to camera, 
    they will keep their place and size and show panel content
    only work when not deployed
  dedicted toolpanel on top left of screen



Template :
  -save to template sValueBloc
    popup for name with field and ok button ?
  -paste last template (or one selected in menu) in selected sheet, 
    if no macro group was selected when created it will copy sheet selected at creation, 
    otherwise it will copy the group of blocs and sheets who was selected
  bloc for auto saving/loading template by name?
    macro can create macro !!!! > basic bloc create

preset :
  -save to preset sValueBloc
    popup for name with field and ok button ?
  bloc for auto saving/loading preset by name?
  saving partial preset, some value marqued as unsavable
    some value choosen to be ignored

basic bloc :
  data, var, random,
  calc, comp, bool, not, bin,
  trigg, switch, keyboard, gate, delay/pulse

complexe bloc : ( in another menu ? )
  template management
    template choosen by name added to selected sheet on bang
  preset save / load
  sheet selector : select sheet choosen by name on bang
  pack / unpack > build complex packet
  setreset, counter, sequance, multigate 
  
MData : sValue access : only hold a string ref, search for corresponding svalue inside current sheet at creation
  ?? if no value is found create one ??
  has in and out
  out can send on change or when receiving bang
  if it cible a vec, the bloc can follow the corresponding position 

MDataCtrl : sValue ctrl : only in + value view
  in can change value multiple way
    bool : set / switch
    num : set / mult / add
    vec : set / mult / add for values rotation and magnitude
    tmpl : in bang > build in same sheet / parent sheet
  
MVar : when a packet is received, display and store it, send it when a bang is received
  can as disable bool input
  
*/
/*

 
             DESIGN
     !! MACRO ARE CRYSTALS !!
 
   hide labels! 
   forme carre > plus petit possible
   overlapp rectangles with those under them to show solidarity
 
 
   GUI to build
     widget jauge / graph
 
     text asking popup
       build it
       call it.popup
       will respond with a runnable
       
 */



void myTheme_MACRO(nTheme theme, float ref_size) {
  theme.addModel("mc_ref", new nWidget()
    .setPassif()
    .setLabelColor(color(200, 200, 220))
    .setFont(int(ref_size/1.6))
    .setOutlineWeight(0)
    .setOutlineColor(color(255, 0))
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
    .setOutlineSelectedColor(color(160))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    .setFont(int(ref_size/1.6))
    .setText("--")
    .setSize(ref_size*2, ref_size*0.75).setPosition(ref_size*1.0, ref_size*0.5)
    );
  theme.addModel("MC_Front", theme.newWidget("mc_ref")
    .setStandbyColor(color(50, 0))
    .setOutlineColor(color(200))
    .setOutlineWeight(ref_size * 1.0 / 16.0)
    .setPassif()
    );
  theme.addModel("MC_Front_Sheet", theme.newWidget("MC_Front")
    .setOutlineColor(color(200, 200, 0))
    .setOutlineWeight(ref_size * 2.0 / 16.0)
    );
  theme.addModel("MC_Panel_Spot_Back", theme.newWidget("mc_ref")
    .setStandbyColor(color(60))
    .setOutlineColor(color(105, 105, 80))
    .setOutlineWeight(ref_size * 1.0 / 16.0)
    .setSize(ref_size*2, ref_size)
    .setFont(int(ref_size/2))
    .setOutline(true)
    );
  theme.addModel("MC_Add_Spot_Actif", theme.newWidget("mc_ref")
    .setStandbyColor(color(120, 70, 0))
    .setHoveredColor(color(180, 90, 10))
    .setSize(ref_size*2, ref_size*0.5)
    );
  theme.addModel("MC_Add_Spot_Passif", theme.newWidget("MC_Add_Spot_Actif")
    .setStandbyColor(color(50))
    );
  theme.addModel("MC_Sheet_Soft_Back", theme.newWidget("mc_ref")
    .setStandbyColor(color(180, 60))
    .setOutlineColor(color(140))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    );
  theme.addModel("MC_Sheet_Hard_Back", theme.newWidget("mc_ref")
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
  theme.addModel("MC_Element_For_Spot", theme.newWidget("MC_Element")
    .setStandbyColor(color(120, 70, 0))
    .setOutlineColor(color(150, 150, 0))
    .setOutlineWeight(ref_size / 8)
    .setOutline(true)
    );
  theme.addModel("MC_Element_At_Spot", theme.newWidget("MC_Element")
    .setOutlineColor(color(120, 70, 0))
    .setOutlineWeight(ref_size / 16)
    .setOutline(true)
    );
  theme.addModel("MC_Element_Single", theme.newWidget("MC_Element")
    .setSize(ref_size*2, ref_size)
    );
  theme.addModel("MC_Element_Double", theme.newWidget("MC_Element")
    .setSize(ref_size*4.125, ref_size)
    );
  theme.addModel("MC_Element_Triple", theme.newWidget("MC_Element")
    .setSize(ref_size*6.25, ref_size)
    );
  theme.addModel("MC_Element_Big", theme.newWidget("MC_Element")
    .setSize(ref_size*4.125, ref_size*4.125)
    );
  theme.addModel("MC_Element_Bigger", theme.newWidget("MC_Element")
    .setSize(ref_size*6.25, ref_size*6.25)
    );
  theme.addModel("MC_Element_Fillright", theme.newWidget("MC_Element")
    .setSize(ref_size*0.5, ref_size*1.625)
    .setPosition(ref_size*1.25, -ref_size*0.25)
    );
  theme.addModel("MC_Element_Fillleft", theme.newWidget("MC_Element")
    .setSize(ref_size*0.5, ref_size*1.625)
    .setPosition(-ref_size*2.875, -ref_size*0.25)
    );
  theme.addModel("MC_Element_Field", theme.newWidget("mc_ref")
    .setStandbyColor(color(10, 40, 80))
    .setOutlineColor(color(10, 110, 220))
    .setOutlineSelectedColor(color(130, 230, 240))
    .setOutlineWeight(ref_size / 16)
    .setFont(int(ref_size/2))
    .setPosition(ref_size*3 / 16, ref_size * 1 / 16)
    .setSize(ref_size*3.125, ref_size*0.875)
    );
  theme.addModel("MC_Element_SField", theme.newWidget("MC_Element_Field")
    .setPosition(ref_size*3 / 16, ref_size * 1 / 16)
    .setSize(ref_size*1.375, ref_size*0.875)
    );
  theme.addModel("MC_Element_LField", theme.newWidget("MC_Element_Field")
    .setPosition(ref_size*3 / 16, ref_size * 1 / 16)
    .setSize(ref_size*5.25, ref_size*0.875)
    );
  theme.addModel("MC_Element_Text", theme.newWidget("mc_ref")
    .setStandbyColor(color(40))
    .setOutlineColor(color(140))
    .setOutlineSelectedColor(color(200))
    .setOutlineWeight(ref_size / 16)
    .setFont(int(ref_size/2))
    .setPosition(ref_size*3 / 16, ref_size * 2 / 16)
    .setSize(ref_size*3.125, ref_size*0.75)
    );
  theme.addModel("MC_Element_SText", theme.newWidget("MC_Element_Text")
    .setPosition(ref_size*3 / 16, ref_size * 2 / 16)
    .setSize(ref_size*1.375, ref_size*0.75)
    );
  theme.addModel("MC_Element_LText", theme.newWidget("MC_Element_Text")
    .setPosition(ref_size*3 / 16, ref_size * 2 / 16)
    .setSize(ref_size*5.25, ref_size*0.75)
    );
  theme.addModel("MC_Element_Button", theme.newWidget("mc_ref")
    .setStandbyColor(color(10, 40, 80))
    .setHoveredColor(color(10, 110, 220))
    .setClickedColor(color(10, 90, 180))
    .setOutlineColor(color(10, 50, 100))
    .setOutlineWeight(ref_size / 16)
    .setOutline(true)
    .setFont(int(ref_size/2))
    .setPosition(ref_size*3 / 16, ref_size * 2 / 16)
    .setSize(ref_size*3.125, ref_size*0.75)
    );
  theme.addModel("MC_Element_SButton", theme.newWidget("MC_Element_Button")
    //.setPX(-ref_size*0.25)
    .setSize(ref_size*1.375, ref_size*0.75)
    );
  theme.addModel("MC_Element_MiniButton", theme.newWidget("MC_Element_Button")
    .setPosition(ref_size*1 / 16, ref_size * 4 / 16)
    .setSize(ref_size*6 / 16, ref_size*0.5)
    .setFont(int(ref_size/3))
    );
  theme.addModel("MC_Element_Button_Selector_1", theme.newWidget("MC_Element_Button")
    .setPX(ref_size * 1 / 16)
    .setSize(ref_size*0.875, ref_size*0.75)
    );
  theme.addModel("MC_Element_Button_Selector_2", theme.newWidget("MC_Element_Button")
    .setPX(ref_size * 17 / 16)
    .setSize(ref_size*0.875, ref_size*0.75)
    );
  theme.addModel("MC_Element_Button_Selector_3", theme.newWidget("MC_Element_Button")
    .setPX(ref_size * 35 / 16)
    .setSize(ref_size*0.875, ref_size*0.75)
    );
  theme.addModel("MC_Element_Button_Selector_4", theme.newWidget("MC_Element_Button")
    .setPX(ref_size * 51 / 16)
    .setSize(ref_size*0.875, ref_size*0.75)
    );
  theme.addModel("MC_Grabber", theme.newWidget("mc_ref")
    .setStandbyColor(color(70))
    .setHoveredColor(color(100))
    .setClickedColor(color(130))
    .setOutlineWeight(ref_size / 9)
    .setOutline(true)
    .setOutlineColor(color(150))
    .setLosange(true)
    .setSize(ref_size*1, ref_size*0.75)
    );
  theme.addModel("MC_Grabber_Deployed", theme.newWidget("MC_Grabber")
    .setStandbyColor(color(70, 70, 0))
    .setOutlineColor(color(150, 150, 0))
    );
  theme.addModel("MC_Grabber_Selected", theme.newWidget("MC_Grabber")
    .setStandbyColor(color(220, 220, 0))
    .setOutlineColor(color(150, 150, 0))
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
    .setHoveredColor(color(120))
    .setClickedColor(color(160))
    .setOutlineWeight(ref_size / 12)
    .setSX(ref_size*0.5).setPosition(-ref_size*1.0, ref_size*0.375)
    );
  theme.addModel("MC_Deploy", theme.newWidget("MC_Reduc")
    .setSize(ref_size*0.75, ref_size*0.5).setPosition(-ref_size*0.375, -ref_size*0.25)
    );
  theme.addModel("MC_Prio", theme.newWidget("MC_Reduc")
    .setSize(ref_size*0.75, ref_size*0.5)
    );
  theme.addModel("MC_Prio_View", theme.newWidget("MC_Prio")
    .setPosition(ref_size*0.125, ref_size*0.125).setBackground()
    );
  theme.addModel("MC_Prio_Sub", theme.newWidget("MC_Prio")
    .setPosition(-ref_size*0.25, ref_size*0.125)
    );
  theme.addModel("MC_Prio_Add", theme.newWidget("MC_Prio")
    .setPosition(ref_size*0.5, ref_size*0.125)
    );
  theme.addModel("MC_Connect_Default", theme.newWidget("mc_ref")
    .setStandbyColor(color(140, 140))
    .setHoveredColor(color(180, 180))
    .setClickedColor(color(180, 220))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    .setOutlineColor(color(100))
    .setRound(true)
    .setTrigger()
    );
  theme.addModel("MC_Connect_Out_Actif", theme.newWidget("mc_ref")
    .setStandbyColor(color(140, 140))
    .setHoveredColor(color(180, 180))
    .setClickedColor(color(180, 220))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    .setOutlineColor(color(220, 170, 25))
    .setRound(true)
    );
  theme.addModel("MC_Connect_Out_Passif", theme.newWidget("mc_ref")
    .setStandbyColor(color(140, 0))
    .setHoveredColor(color(180, 180))
    .setClickedColor(color(180, 220))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    .setOutlineColor(color(60))
    .setRound(true)
    );
  theme.addModel("MC_Connect_In_Actif", theme.newWidget("mc_ref")
    .setStandbyColor(color(140, 140))
    .setHoveredColor(color(180, 180))
    .setClickedColor(color(180, 220))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    .setOutlineColor(color(220, 170, 25))
    .setRound(true)
    );
  theme.addModel("MC_Connect_In_Passif", theme.newWidget("mc_ref")
    .setStandbyColor(color(140, 0))
    .setHoveredColor(color(180, 180))
    .setClickedColor(color(180, 220))
    .setOutlineWeight(ref_size / 12)
    .setOutline(true)
    .setOutlineColor(color(60))
    .setRound(true)
    );
  theme.addModel("MC_Connect_Link", theme.newWidget("mc_ref")
    .setStandbyColor(color(200))
    .setHoveredColor(color(205, 205, 200))
    .setClickedColor(color(220, 220, 200))
    .setOutlineColor(color(200, 100, 100))
    .setOutlineSelectedColor(color(200, 200, 0))
    .setOutlineWeight(ref_size / 10)
    .setOutline(true)
    .setRound(true)
    );
  theme.addModel("MC_Connect_View", theme.newWidget("mc_ref")
    .setFont(int(ref_size/2))
    .setStandbyColor(color(40))
    .setOutline(false)
    .setPosition(0, -ref_size*4/16)
    .setSize(ref_size*1.5, ref_size*0.75)
    );
}

import java.util.Map;

/*
abstract extend shelfpanel
 can be selected and group dragged copy/pasted > template or deleted
 
 */
class Macro_Abstract extends nShelfPanel implements Macro_Interf {
  
  Macro_Abstract deploy() { open(); return this; }
  Macro_Abstract open() {
    if (openning.get() != OPEN) {
      openning.set(OPEN);
      grabber.show(); grab_front.show(); panel.show(); back.hide(); 
      front.show(); title.show(); reduc.show(); 
      reduc.setPosition(-ref_size, ref_size*0.375);
      moving();
    }
    toLayerTop();
    return this;
  }
  Macro_Abstract reduc() {
    if (openning.get() != REDUC) {
      openning.set(REDUC);
      grabber.show(); grab_front.show(); panel.hide(); back.hide(); 
      front.hide(); title.hide(); reduc.show(); 
      reduc.show().setPosition(ref_size * 0.75, ref_size*0.75);
      moving();
    }
    return this;
  }
  Macro_Abstract show() {
    if (openning.get() == HIDE) { 
      if (openning_pre_hide.get() == REDUC) reduc();
      else if (openning_pre_hide.get() == OPEN) open();
      else if (openning_pre_hide.get() == DEPLOY) deploy();
      //else reduc();
    }
    return this;
  }
  Macro_Abstract hide() {
    if (openning.get() != HIDE) {
      openning_pre_hide.set(openning.get());
      openning.set(HIDE);
    }
    grabber.hide(); grab_front.hide(); panel.hide(); back.hide(); 
    front.hide(); title.hide(); reduc.hide(); 
    return this;
  }
  Macro_Abstract changeOpenning() {
    if (openning.get() == OPEN) { reduc(); }
    else if (openning.get() == REDUC) { open(); }
    else if (openning.get() == DEPLOY) { open(); }
    return this; }
  
  void szone_select() {
    mmain().selected_macro.add(this);
    szone_selected = true;
    if (openning.get() == REDUC) grab_front.setOutline(true);
    else front.setOutline(true);
    toLayerTop();
  }
  void szone_unselect() {
    szone_selected = false;
    front.setOutline(false);
    grab_front.setOutline(false);
  }
  
  void moving() { sheet.movingChild(this); }
  void group_move(float x, float y) { 
    grabber.setPY(grabber.getLocalY() + y); grabber.setPX(grabber.getLocalX() + x); }
  Macro_Abstract setPosition(float x, float y) { 
    grab_pos.doEvent(false);
    grabber.setPosition(x, y); grab_pos.set(x, y);
    grab_pos.doEvent(true);
    return this; }
  Macro_Abstract setParent(Macro_Sheet s) { grabber.clearParent(); grabber.setParent(s.grabber); return this; }
  Macro_Abstract toLayerTop() { 
    super.toLayerTop(); panel.toLayerTop(); title.toLayerTop(); grabber.toLayerTop(); 
    reduc.toLayerTop(); prio_sub.toLayerTop(); prio_add.toLayerTop(); prio_view.toLayerTop(); 
    front.toLayerTop(); grab_front.toLayerTop(); return this; }

  Macro_Main mmain() { if (sheet == this) return (Macro_Main)this; return sheet.mmain(); }
  
  nGUI gui;
  Macro_Sheet sheet;    int sheet_depth = 0;
  boolean szone_selected = false, title_fixe = false, unclearable = false, pos_given = false;
  float ref_size = 40;
  sVec grab_pos; sStr val_type, val_descr, val_title;
  sInt priority, openning, openning_pre_hide; sObj val_self;
  float prev_x, prev_y; //for group dragging
  nLinkedWidget grabber, title; nCtrlWidget prio_sub, prio_add; nWatcherWidget prio_view;
  nWidget reduc, front, grab_front, back;
  sValueBloc value_bloc = null, setting_bloc;
  Runnable szone_st, szone_en;
  
Macro_Abstract(Macro_Sheet _sheet, String ty, String n, sValueBloc _bloc) {
    super(_sheet.gui, _sheet.ref_size, 0.25);
    gui = _sheet.gui; ref_size = _sheet.ref_size; sheet = _sheet; 
    sheet_depth = sheet.sheet_depth + 1;
    
    if (_bloc == null) {
      String n_suff = "";
      if (n == null) n_suff = ty;
      else n_suff = n;
      int cn = 0;
      String n_ref = cn + "_" + n_suff;
      
      boolean is_in_other_sheet = false;
      if (sheet != this) for (Macro_Sheet m : sheet.child_sheet) if (m != this)
        is_in_other_sheet = m.value_bloc.getBloc(n_ref) != null || is_in_other_sheet;
      
      while (sheet.value_bloc.getBloc(n_ref) != null ||
             (sheet != this && sheet.sheet.value_bloc.getBloc(n_ref) != null) || 
             is_in_other_sheet) {
        cn++;
        n_ref = cn + "_" + n_suff;
        
        is_in_other_sheet = false;
        if (sheet != this) for (Macro_Sheet m : sheet.child_sheet) if (m != this)
          is_in_other_sheet = m.value_bloc.getBloc(n_ref) != null || is_in_other_sheet;
        
      }
      value_bloc = sheet.value_bloc.newBloc(n_ref);
      
    } else value_bloc = _bloc;
    
    setting_bloc = value_bloc.getBloc("settings");
    if (setting_bloc == null) setting_bloc = value_bloc.newBloc("settings");
    
    val_type = ((sStr)(setting_bloc.getValue("type"))); 
    val_descr = ((sStr)(setting_bloc.getValue("description"))); 
    val_title = ((sStr)(setting_bloc.getValue("title"))); 
    grab_pos = ((sVec)(setting_bloc.getValue("position"))); 
    openning = ((sInt)(setting_bloc.getValue("open"))); 
    openning_pre_hide = ((sInt)(setting_bloc.getValue("pre_open"))); 
    val_self = ((sObj)(setting_bloc.getValue("self"))); 
    priority = ((sInt)(setting_bloc.getValue("priority"))); 
    
    if (val_type == null) val_type = setting_bloc.newStr("type", "type", ty);
    if (val_descr == null) val_descr = setting_bloc.newStr("description", "descr", "macro");
    //if (val_title == null) val_title = setting_bloc.newStr("title", "ttl", n);
    if (val_title == null) val_title = setting_bloc.newStr("title", "ttl", value_bloc.ref);
    else val_title.set(value_bloc.ref);
    if (grab_pos == null) grab_pos = setting_bloc.newVec("position", "pos");
    else pos_given = true;
    
    if (!pos_given && sheet != this) {
      PVector sc_pos = new PVector(mmain().screen_gui.view.pos.x + mmain().screen_gui.view.size.x / 3, 
                                   mmain().screen_gui.view.pos.y + mmain().screen_gui.view.size.y / 3);
      sc_pos = mmain().inter.cam.screen_to_cam(sc_pos);
      grab_pos.set(sc_pos.x - sheet.grabber.getX(), sc_pos.y - sheet.grabber.getY());
    }
    
    if (openning == null) openning = setting_bloc.newInt("open", "op", OPEN);
    if (openning_pre_hide == null) openning_pre_hide = setting_bloc.newInt("pre_open", "pop", OPEN);
    if (val_self == null) val_self = setting_bloc.newObj("self", this);
    else val_self.set(this);
    if (priority == null) priority = setting_bloc.newInt("priority", "prio", 0);
    build_ui();
  }
  Macro_Abstract(sInterface _int) { // FOR MACRO_MAIN ONLY
    super(_int.cam_gui, _int.ref_size, 0.125);
    gui = _int.cam_gui; 
    ref_size = _int.ref_size; 
    sheet = (Macro_Main)this;
    myTheme_MACRO(gui.theme, ref_size); 
    panel.copy(gui.theme.getModel("mc_ref"));
    grabber = addLinkedModel("mc_ref");
    grabber.clearParent();
    reduc = addModel("mc_ref");
    panel.hide(); 
    grabber.setSize(0, 0).setPassif().setOutline(false);
    front = addModel("mc_ref");
    title = addLinkedModel("mc_ref");
    back = addModel("mc_ref");
    grab_front = addModel("mc_ref");
    prio_view = addWatcherModel("mc_ref");
    prio_sub = addCtrlModel("mc_ref");
    prio_add = addCtrlModel("mc_ref");
    
    value_bloc = _int.interface_bloc.newBloc("Main_Sheet");
    setting_bloc = value_bloc.newBloc("settings");
    val_type = setting_bloc.newStr("type", "type", "main");
    val_descr = setting_bloc.newStr("description", "descr", "macro main");
    val_title = setting_bloc.newStr("title", "ttl", "macro main");
    grab_pos = setting_bloc.newVec("position", "pos");
    openning = setting_bloc.newInt("open", "op", DEPLOY);
    openning_pre_hide = setting_bloc.newInt("pre_open", "pop", DEPLOY);
    val_self = setting_bloc.newObj("self", this);
    priority = setting_bloc.newInt("priority", "prio", 0);
    
    //_int.addEventNextFrame(new Runnable() { public void run() { 
    //  openning.set(OPEN); 
    //  deploy();
    //  //if (!mmain().show_macro.get()) hide();
    //  toLayerTop(); 
    //} } );
  }
  void build_ui() {
    grabber = addLinkedModel("MC_Grabber")
      .setLinkedValue(grab_pos);
      
    grabber.clearParent().addEventDrag(new Runnable(this) { public void run() { 
      grabber.setPY(grabber.getLocalY() - grabber.getLocalY()%(ref_size * 0.5));
      grabber.setPX(grabber.getLocalX() - grabber.getLocalX()%(ref_size * 0.5));
      
      if (mmain().selected_macro.contains(((Macro_Abstract)builder)))
        for (Macro_Abstract m : mmain().selected_macro) if (m != ((Macro_Abstract)builder))
          m.group_move(grabber.getLocalX() - prev_x, grabber.getLocalY() - prev_y);
      prev_x = grabber.getLocalX(); prev_y = grabber.getLocalY();
      moving(); } });
    grabber.addEventGrab(new Runnable() { public void run() { 
      prev_x = grabber.getLocalX(); prev_y = grabber.getLocalY(); toLayerTop(); } });
    
    panel.copy(gui.theme.getModel("MC_Panel"));
    panel.setParent(grabber).setPassif();
    panel.setPosition(-grabber.getLocalSX()/4, grabber.getLocalSY()/2 + ref_size * 1 / 8)
      .addEventShapeChange(new Runnable() { public void run() {
        front.setSize(panel.getLocalSX(), panel.getLocalSY()); } } )
      .addEventVisibilityChange(new Runnable() { public void run() {
      if (panel.isHided()) front.setSize(0, 0);
      else front.setSize(panel.getLocalSX(), panel.getLocalSY()); } } );
    
    back = addModel("MC_Sheet_Soft_Back");
    back.clearParent().setPassif();
    back.setParent(grabber).hide();
    
    reduc = addModel("MC_Reduc").clearParent();
    reduc.setParent(panel);
    reduc.alignDown().stackRight().addEventTrigger(new Runnable() { public void run() { changeOpenning(); } });
    
    
    prio_sub = addCtrlModel("MC_Prio_Sub")
      .setRunnable(new Runnable() { public void run() { if (priority.get() > 0) priority.add(-1); } });
    prio_sub.setParent(panel);
    prio_sub.stackUp().alignRight();
    prio_add = addCtrlModel("MC_Prio_Add")
      .setRunnable(new Runnable() { public void run() { if (priority.get() < 9) priority.add(1); } });
    prio_add.setParent(panel);
    prio_add.stackUp().alignRight();
    
    prio_view = addWatcherModel("MC_Prio_View")
      .setLinkedValue(priority);
    prio_view.setParent(panel);
    prio_view.stackUp().alignRight().setInfo("priority");
    
    title = addLinkedModel("MC_Title").setLinkedValue(val_title);
    title.addEventFieldChange(new Runnable() { public void run() { title.setOutline(true); } });
    title.clearParent().setParent(panel);
    title.alignDown().stackLeft();
    grabber.addEventMouseEnter(new Runnable() { public void run() { 
      if (openning.get() == REDUC) title.show(); } });
    grabber.addEventMouseLeave(new Runnable() { public void run() { 
      if (openning.get() == REDUC && !title_fixe) title.hide(); } });
    
    front = addModel("MC_Front")
      .setParent(panel).setPassif()
      .addEventFrame(new Runnable() { public void run() { 
        if (openning.get() != REDUC && mmain().szone.isSelecting() && mmain().selected_sheet == sheet ) {
          if (mmain().szone.isUnder(front)) front.setOutline(true);
          else front.setOutline(false); } } } )
      ;
    grab_front = addModel("MC_Front")
      .setParent(grabber).setPassif()
      .setSize(grabber.getLocalSX(), grabber.getLocalSY())
      .addEventFrame(new Runnable() { public void run() { 
        if (openning.get() == REDUC && mmain().szone.isSelecting() && mmain().selected_sheet == sheet ) {
          if (mmain().szone.isUnder(grab_front)) grab_front.setOutline(true);
          else grab_front.setOutline(false); } } } )
      ;
    szone_st = new Runnable() { public void run() { 
      szone_unselect(); } } ;
    szone_en = new Runnable(this) { public void run() { 
      if (mmain().selected_sheet == sheet && 
          ((openning.get() != REDUC && mmain().szone.isUnder(front) ) || 
           (openning.get() == REDUC && mmain().szone.isUnder(grab_front) )) )  {
        szone_select(); } } } ;
    if (mmain() != this) {
      mmain().szone.addEventStartSelect(szone_st);
      mmain().szone.addEventEndSelect(szone_en);
    }
    
    setParent(sheet); 
    sheet.child_macro.add(this); 
    
    mmain().inter.addEventNextFrame(new Runnable() { public void run() { 
      if (openning.get() == REDUC) { openning.set(OPEN); reduc(); }
      else if (openning.get() == OPEN) { openning.set(REDUC); open(); }
      else if (openning.get() == HIDE) { openning.set(openning_pre_hide.get()); hide(); }
      else if (openning.get() == DEPLOY) { openning.set(OPEN); deploy(); }
      if (!mmain().show_macro.get()) hide();
      if (mmain().sheet_explorer != null) mmain().sheet_explorer.update(); 
      if (!pos_given) find_place(); 
      //if (mmain().show_macro.get()) sheet.updateBack(); 
      runEvents(eventsSetupLoad); 
      toLayerTop(); 
    } } );
  }
  void find_place() {
    
    grabber.setPY(grabber.getLocalY() - grabber.getLocalY()%(ref_size * 0.5));
    grabber.setPX(grabber.getLocalX() - grabber.getLocalX()%(ref_size * 0.5));
    
    int adding_v = 0;
    boolean found = false;
    while (!found) {
      if (adding_v > 0) setPosition(grabber.getLocalX() + ref_size * 3, grabber.getLocalY());
      adding_v++; 
      if (adding_v == 6) { 
        adding_v = 0; setPosition(grabber.getLocalX() - ref_size * 15, grabber.getLocalY() + ref_size * 3); }
      boolean col = false;
      float phf = 0.5;
      for (Macro_Abstract c : sheet.child_macro) 
        if (c != this && c.openning.get() == DEPLOY 
            && rectCollide(panel.getRect(), c.back.getRect(), ref_size * phf)) col = true;
        else if (c != this && c.openning.get() == REDUC 
                 && rectCollide(panel.getRect(), c.grabber.getRect(), ref_size * phf)) col = true;
        else if (c != this && c.openning.get() == OPEN 
                 && rectCollide(panel.getRect(), c.panel.getRect(), ref_size * phf)) col = true;
        else if (c != this && c.openning.get() == HIDE && c.openning_pre_hide.get() == DEPLOY
                 && rectCollide(panel.getPhantomRect(), c.back.getPhantomRect(), ref_size * phf)) col = true;
        else if (c != this && c.openning.get() == HIDE && c.openning_pre_hide.get() == REDUC
                 && rectCollide(panel.getPhantomRect(), c.grabber.getPhantomRect(), ref_size * phf)) col = true;
        else if (c != this && c.openning.get() == HIDE && c.openning_pre_hide.get() == OPEN
                 && rectCollide(panel.getPhantomRect(), c.panel.getPhantomRect(), ref_size * phf)) col = true;
      if (sheet != mmain() && openning.get() == HIDE 
          && rectCollide(panel.getPhantomRect(), sheet.panel.getPhantomRect(), ref_size * phf)) col = true;
      if (sheet != mmain() && openning.get() != HIDE 
          && rectCollide(panel.getRect(), sheet.panel.getRect(), ref_size * phf)) col = true;
      if (!col) found = true;
    }
    sheet.updateBack();
  }
  Macro_Abstract clear() {
    if (!unclearable) {
      super.clear();
      val_type.clear(); val_descr.clear(); val_title.clear(); grab_pos.clear();
      openning.clear(); openning_pre_hide.clear(); val_self.clear();
      priority.clear();
      value_bloc.clear(); 
      sheet.child_macro.remove(this);
      sheet.redo_link();
      sheet.redo_spot();
      sheet.updateBack();
      if (mmain() != this) {
        mmain().szone.removeEventStartSelect(szone_st);
        mmain().szone.removeEventEndSelect(szone_en);
      }
    }
    return this;
  }
  
  String resum_link() { return ""; }
  
  
  sBoo newBoo(boolean d, String r, String s) { return newBoo(r, s, d); }
  sBoo newBoo(boolean d, String r) { return newBoo(r, r, d); }
  sBoo newBoo(String r, boolean d) { return newBoo(r, r, d); }
  sInt newInt(int d, String r, String s) { return newInt(r, s, d); }
  sFlt newFlt(float d, String r, String s) { return newFlt(r, s, d); }
  sRun newRun(Runnable d, String r, String s) { return newRun(r, s, d); }
  
  sBoo newBoo(String r, String s, boolean d) {
    sBoo v = ((sBoo)(value_bloc.getValue(r))); 
    if (v == null) v = value_bloc.newBoo(r, s, d);
    return v; }
  sInt newInt(String r, String s, int d) {
    sInt v = ((sInt)(value_bloc.getValue(r))); 
    if (v == null) v = value_bloc.newInt(r, s, d);
    return v; }
  sFlt newFlt(String r, String s, float d) {
    sFlt v = ((sFlt)(value_bloc.getValue(r))); 
    if (v == null) v = value_bloc.newFlt(r, s, d);
    return v; }
  sStr newStr(String r, String s, String d) {
    sStr v = ((sStr)(value_bloc.getValue(r))); 
    if (v == null) v = value_bloc.newStr(r, s, d);
    return v; }
  sVec newVec(String r, String s) {
    sVec v = ((sVec)(value_bloc.getValue(r))); 
    if (v == null) v = value_bloc.newVec(r, s);
    return v; }
  sCol newCol(String r, String s, color d) {
    sCol v = ((sCol)(value_bloc.getValue(r))); 
    if (v == null) v = value_bloc.newCol(r, s, d);
    return v; }
  sRun newRun(String r, String s, Runnable d) {
    sRun v = ((sRun)(value_bloc.getValue(r))); 
    if (v == null) v = value_bloc.newRun(r, s, d);
    else v.set(d);
    return v; }
    
  
  Macro_Abstract addEventSetupLoad(Runnable r) { eventsSetupLoad.add(r); return this; }
  ArrayList<Runnable> eventsSetupLoad = new ArrayList<Runnable>();
  
  boolean canSetupFrom(sValueBloc bloc) {
    boolean b = (bloc != null && bloc.getBloc("settings") != null && 
    //        values_found(setting_bloc, bloc.getBloc("settings")) && 
    //        values_found(value_bloc, bloc) && 
            ((sStr)bloc.getBloc("settings").getValue("type")).get().equals(val_type.get()));
    //if (b) log("t"); else log("f");
    return b;
    //return true;
  }
  
  void setupFromBloc(sValueBloc bloc) {
    if (canSetupFrom(bloc)) {
      
      transfer_bloc_values(bloc, value_bloc);
      transfer_bloc_values(bloc.getBloc("settings"), setting_bloc);
      runEvents(eventsSetupLoad);
    }
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
  //nFrontPanel macro_front;  
  nToolPanel macro_tool, build_tool, sheet_tool;
  nExplorer template_explorer, sheet_explorer;
  sValueBloc pastebin = null;
  
  ArrayList<nExplorer> presets_explorers = new ArrayList<nExplorer>();
  
  void new_tmpl() {
    if (selected_macro.size() > 0) {
      if (pastebin != null) pastebin.clear();
      String nn = new_temp_name.get();
      int t = 0;
      while (saved_template.getBloc(nn) != null) { nn = new_temp_name.get() + "_" + t; t++; }
      sValueBloc bloc = saved_template.newBloc(nn);
      for (Macro_Abstract m : selected_macro) copy_bloc(m.value_bloc, bloc);
      sStr tmp_link = new sStr(bloc, "", "links", "links");
      for (Macro_Abstract m : selected_macro) {
        tmp_link.set(tmp_link.get() + m.resum_link());
      }
      
      //positionning
      //for (Map.Entry me : bloc.blocs.entrySet()) {
      //  sValueBloc vb = ((sValueBloc)me.getValue());
      //  if (vb.getBloc("settings") != null && vb.getBloc("settings").getValue("position") != null) {
      //    sVec v = (sVec)(vb.getBloc("settings").getValue("position"));
      //    v.setx(v.x() + ref_size * 2); v.sety(v.y() + ref_size * 3);
      //  }
      //}
      
      if (template_explorer != null) { 
        template_explorer.update();
        template_explorer.selectEntry(bloc.base_ref); }
    } else if (selected_sheet != this) {
      String nn = new_temp_name.get(); int t = 0;
      while (saved_template.getBloc(nn) != null) { nn = new_temp_name.get() + "_" + t; t++; }
      
      sValueBloc bloc = saved_template.newBloc(nn);
      sValueBloc vb = copy_bloc(selected_sheet.value_bloc, bloc);
      
      //positionning
      if (vb.getBloc("settings") != null && vb.getBloc("settings").getValue("position") != null) {
        sVec v = (sVec)(vb.getBloc("settings").getValue("position"));
        v.setx(0); v.sety(0);
      }
      
      if (template_explorer != null) { 
        template_explorer.update();
        template_explorer.selectEntry(selected_sheet.value_bloc.base_ref); }
    }
  }
  void add_tmpl() {
    if (template_explorer != null && template_explorer.selected_bloc != null) {
      paste_tmpl(template_explorer.selected_bloc);
    }
  }
  void paste_tmpl(sValueBloc bloc) {
    selected_sheet.addCopyofBlocContent(bloc);
    if (sheet_explorer != null) sheet_explorer.update();
  }
  void paste_tmpl() {
    if (pastebin != null) {
      paste_tmpl(pastebin);
    }
  }
  
  void copy_to_tmpl() {
    if (selected_macro.size() > 0) {
      if (pastebin != null) pastebin.clear();
      if (saved_template.getBloc("copy") != null) saved_template.getBloc("copy").clear();
      
      sValueBloc bloc = saved_template.newBloc("copy");
      pastebin = bloc;
      
      for (Macro_Abstract m : selected_macro) copy_bloc(m.value_bloc, bloc);
      sStr tmp_link = new sStr(pastebin, "", "links", "links");
      for (Macro_Abstract m : selected_macro) {
        tmp_link.set(tmp_link.get() + m.resum_link());
      }
      
      //positionning
      for (Map.Entry me : pastebin.blocs.entrySet()) {
        sValueBloc vb = ((sValueBloc)me.getValue());
        if (vb.getBloc("settings") != null && vb.getBloc("settings").getValue("position") != null) {
          sVec v = (sVec)(vb.getBloc("settings").getValue("position"));
          v.setx(v.x() + ref_size * 2); v.sety(v.y() + ref_size * 3);
        }
      }
      
      if (template_explorer != null) { 
        template_explorer.update();
        template_explorer.selectEntry(pastebin.base_ref); }
    } 
  }
  //boolean del_order = false;
  void del_selected() {
    //del_order = true;
    inter.addEventNextFrame(new Runnable() { public void run() { 
      for (Macro_Abstract m : selected_macro) m.clear(); 
      if (sheet_explorer != null) sheet_explorer.update(); 
    } } );
  }
  void build_macro_menus() {
    if (macro_tool != null) macro_tool.clear();
    macro_tool = new nToolPanel(screen_gui, ref_size, 0.125, true, true);
    macro_tool.addShelf().addDrawer(1, 1)
        .addLinkedModel("Menu_Button_Small_Outline-S1-P1", "P")
          .setLinkedValue(do_packet)
          .setInfo("do packet processing").setFont(int(ref_size/1.9)).getDrawer()
        //.addCtrlModel("Menu_Button_Small_Outline-S1-P2", "")
        //  .setRunnable(new Runnable() { public void run() { 
        //    if (selected_sheet != null) 
        //      new nTextView(inter.screen_gui, inter.taskpanel, selected_sheet.spots);
        //  }}).setInfo("formated view of selected sheet links value")
        //  .setFont(int(ref_size/1.9))
          .getShelfPanel()
      .addShelf().addDrawer(4.375, 1)
        .addLinkedModel("Menu_Button_Small_Outline-S1-P1", "S")
          .setLinkedValue(show_macro)
          .setInfo("show/hide macros").setFont(int(ref_size/1.9)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P2", "X")
          .setRunnable(new Runnable() { public void run() { del_selected(); }})
          .setInfo("Delete selected bloc").setFont(int(ref_size/1.9)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P3", "E")
          .setRunnable(new Runnable() { public void run() { 
            selected_sheet.empty(); if (sheet_explorer != null) sheet_explorer.update(); }})
          .setInfo("Empty selected sheet").setFont(int(ref_size/1.9)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P4", "C")
          .setRunnable(new Runnable() { public void run() { copy_to_tmpl(); }})
          .setInfo("Copy selected blocs").setFont(int(ref_size/1.9)).getShelfPanel()
      .addShelf().addDrawer(3.25, 1)
        .addCtrlModel("Menu_Button_Small_Outline-S1-P1", "P")
          .setRunnable(new Runnable() { public void run() { paste_tmpl(); }})
          .setInfo("Paste").setFont(int(ref_size/1.9)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P2", "MM")
          .setRunnable(new Runnable() { public void run() { build_sheet_menu(); }})
          .setInfo("Open main sheet menu").setFont(int(ref_size/1.9)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P3", "FM")
          .setRunnable(new Runnable() { public void run() { inter.filesManagement(); }})
          .setInfo("File management").setFont(int(ref_size/1.9)).getShelfPanel()
      .addShelf().addDrawer(5.5, 1)
        .addCtrlModel("Menu_Button_Small_Outline-S1-P1", "QS")
          .setRunnable(new Runnable() { public void run() { inter.full_data_save(); }})
          .setInfo("Quick Save").setFont(int(ref_size/1.9)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P2", "QL")
          .setRunnable(new Runnable() { public void run() { inter.setup_load(); }})
          .setInfo("Quick Load").setFont(int(ref_size/1.9)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P3", "SA")
          .setRunnable(new Runnable() { public void run() { inter.save_as(); }})
          .setInfo("Save As").setFont(int(ref_size/1.9)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P4", "OP")
          .setRunnable(new Runnable() { public void run() { inter.quick_open(); }})
          .setInfo("Open").setFont(int(ref_size/1.9)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P5", "FS")
          .setRunnable(new Runnable() { public void run() { inter.full_screen_run.run(); }})
          .setInfo("Switch Fullscreen").setFont(int(ref_size/1.9));
    if (!show_macro_tool.get()) macro_tool.reduc();
    macro_tool.setPos(window_head);
    macro_tool.addEventReduc(new Runnable() { public void run() { 
      show_macro_tool.set(!macro_tool.hide); }});
    
    if (build_tool != null) build_tool.clear();
    build_tool = new nToolPanel(screen_gui, ref_size, 0.125, true, true);
    build_tool.addShelf();
    int c = 0;
    for (String t : bloc_types3) { build_tool.getShelf(0).addDrawer(2.5, 0.75)
      .addCtrlModel("Menu_Button_Small_Outline-S2.5/0.75", t)
        .setRunnable(new Runnable(t) { public void run() { selected_sheet.addByType(((String)builder)); }})
        .setFont(int(ref_size/2)).setTextAlignment(LEFT, CENTER)
        .setInfo(bloc_info3[c])
        ;
      c++;
    }
    build_tool.addShelf();
    c = 0;
    for (String t : bloc_types2) { build_tool.getShelf(1).addDrawer(2.5, 0.75)
      .addCtrlModel("Menu_Button_Small_Outline-S2.5/0.75", t)
        .setRunnable(new Runnable(t) { public void run() { selected_sheet.addByType(((String)builder)); }})
        .setFont(int(ref_size/2)).setTextAlignment(LEFT, CENTER)
        .setInfo(bloc_info2[c])
        ;
      c++;
    }
    build_tool.addShelf();
    c = 0;
    for (String t : bloc_types1) { build_tool.getShelf(2).addDrawer(2.5, 0.75)
      .addCtrlModel("Menu_Button_Small_Outline-S2.5/0.75", t)
        .setRunnable(new Runnable(t) { public void run() { selected_sheet.addByType(((String)builder)); }})
        .setFont(int(ref_size/2)).setTextAlignment(LEFT, CENTER)
        .setInfo(bloc_info1[c])
        ;
      c++;
    }
    if (!show_build_tool.get()) build_tool.reduc();
    build_tool.addEventReduc(new Runnable() { public void run() { 
      show_build_tool.set(!build_tool.hide); }});
    build_tool.setPos(window_head + ref_size*1.25);
    
    if (sheet_tool != null) sheet_tool.clear();
    sheet_tool = new nToolPanel(screen_gui, ref_size, 0.125, true, true);
    sheet_tool.addShelf();
    
    for (Sheet_Specialize t : Sheet_Specialize.prints) if (!t.unique) sheet_tool.getShelf(0).addDrawer(3, 0.75)
      .addCtrlModel("Menu_Button_Small_Outline-S3/0.75", t.name)
        .setRunnable(new Runnable(t) { public void run() { 
          ((Sheet_Specialize)builder).add_new(selected_sheet, null, null); }})
        .setFont(int(ref_size/2));
        ;
    
    if (!show_sheet_tool.get()) sheet_tool.reduc();
    sheet_tool.addEventReduc(new Runnable() { public void run() { 
      show_sheet_tool.set(!sheet_tool.hide); }});
    sheet_tool.setPos(window_head + ref_size*16);
  }
  void build_custom_menu(nFrontPanel sheet_front) {
    nFrontTab tab = sheet_front.getTab(2);
    tab.getShelf()
      .addDrawerDoubleButton(inter.auto_load, inter.filesm_run, 10.25, 1)
      .addSeparator(0.125)
      .addDrawerDoubleButton(inter.quickload_run, inter.quicksave_run, 10, 1)
      .addSeparator(0.25)
      ;
    
    tab = sheet_front.addTab("Explorer");
    tab.getShelf()
      .addSeparator(0.125)
      .addDrawer(10.25, 1).addModel("Label-S3", "sheets explorer :").setTextAlignment(LEFT, CENTER).getShelf()
      .addSeparator()
      ;
    sheet_explorer = tab.getShelf()
      .addSeparator()
      .addExplorer()
        .setStrtBloc(value_bloc)
        .addValuesModifier(mmain().inter.taskpanel)
        .addEventChange(new Runnable() { public void run() { 
            if (value_bloc != sheet_explorer.selected_bloc && 
                sheet_explorer.selected_bloc != null && 
                sheet_explorer.selected_bloc.getBloc("settings") != null &&
                sheet_explorer.selected_bloc.getBloc("settings").getValue("self") != null && 
                sheet_explorer.selected_bloc.getBloc("settings").getValue("type") != null && 
                ((sStr)sheet_explorer.selected_bloc.getBloc("settings").getValue("type")).get().equals("sheet")) {
              Macro_Sheet s = ((Macro_Sheet)((sObj)(sheet_explorer.selected_bloc
                .getBloc("settings").getValue("self"))).get());
              selected_sheet.open();
              if (s != null) s.select();
            } else if (value_bloc == sheet_explorer.explored_bloc) {
              selected_sheet.open();
              select();
            }
        } } )
        ;
        
    tab = sheet_front.addTab("Template");
    tab.getShelf()
      .addSeparator(0.125)
      .addDrawer(10.25, 1).addModel("Label-S3", "Templates :").setTextAlignment(LEFT, CENTER).getDrawer()
      .addCtrlModel("Button-S2-P3", "Delete").setRunnable(new Runnable() { public void run() { 
        template_explorer.selected_bloc.clear(); template_explorer.update(); } } ).setInfo("delete selected template").getShelf()
      .addSeparator()
      ;
    template_explorer = tab.getShelf()
      .addSeparator()
      .addExplorer()
        .setStrtBloc(saved_template)
        .hideValueView()
        .hideGoBack()
        .addEventChange(new Runnable() { public void run() { 
          if (saved_template != template_explorer.explored_bloc) {
            template_explorer.setStrtBloc(saved_template);
            template_explorer.update(); 
          }
        } } )
        ;
    tab.getShelf()
      .addSeparator()
      .addDrawer(10, 1)
      .addModel("Label-S3", "New template :").setTextAlignment(LEFT, CENTER).getDrawer()
      .addLinkedModel("Field-S3-P2").setLinkedValue(new_temp_name).getShelf()
      .addSeparator(0.125)
      .addDrawer(10, 1)
      .addCtrlModel("Button-S3-P1", "New").setRunnable(new Runnable() { public void run() { 
        new_tmpl(); template_explorer.update(); } } )
      .setInfo("save selected as new template").getDrawer()
      .addCtrlModel("Button-S3-P2", "Add").setRunnable(new Runnable() { public void run() { 
        add_tmpl(); } } )
      .setInfo("add selected template to selected sheet").getShelf()
      .addSeparator()
      ;
    if (pastebin != null) template_explorer.selectEntry(pastebin.ref);
    template_explorer.getShelf()
      .addSeparator(0.25)
        ;
    
  }
  /*
  setup loading : 
    clear everything
      macro, template, presets, clear call to simulation
    search setup file:
      interface data : transfer values
      template, preset : copy blocs
      for blocs inside main sheet :
        sheet bloc : (has all settings)
          allready same name n spe sheet : transfer value, copy inside blocs and values
          no same name sheet : copy full bloc, build sheet with 
          same name but diff spe : delete it then do as if no same name sheet
        not a sheet bloc : delete it
    load corresponding gui property
  
  */
  void setup_load(sValueBloc b) { 
    is_setup_loading = true;
    saved_template.empty();
    saved_preset.empty();
    
    Save_Bloc sb = new Save_Bloc("");
    sb.load_from(database_path.get());
    
    if (database_setup_bloc != null) database_setup_bloc.clear();
    database_setup_bloc = inter.data.newBloc(sb, "db_setup");
    
    if (database_setup_bloc.getBloc("Template") != null) {
      database_setup_bloc.getBloc("Template").runBlocIterator(new Iterator<sValueBloc>() { public void run(sValueBloc bloc) { 
        Save_Bloc b = new Save_Bloc("");
        bloc.preset_to_save_bloc(b);
        if (!bloc.base_ref.equals("copy")) saved_template.newBloc(b, bloc.ref);
      }});
    }if (database_setup_bloc.getBloc("Preset") != null) {
      database_setup_bloc.getBloc("Preset").runBlocIterator(new Iterator<sValueBloc>() { public void run(sValueBloc bloc) { 
        Save_Bloc b = new Save_Bloc("");
        bloc.preset_to_save_bloc(b);
        saved_preset.newBloc(b, bloc.ref);
      }});
    }
    
    if (b.getBloc("Template") != null) {
      b.getBloc("Template").runBlocIterator(new Iterator<sValueBloc>() { public void run(sValueBloc bloc) { 
        Save_Bloc b = new Save_Bloc("");
        bloc.preset_to_save_bloc(b);
        if (saved_template.getBloc(bloc.base_ref) == null && !bloc.base_ref.equals("copy")) saved_template.newBloc(b, bloc.base_ref);
      }});
    }if (b.getBloc("Preset") != null) {
      b.getBloc("Preset").runBlocIterator(new Iterator<sValueBloc>() { public void run(sValueBloc bloc) { 
        Save_Bloc b = new Save_Bloc("");
        bloc.preset_to_save_bloc(b);
        if (saved_preset.getBloc(bloc.base_ref) == null) saved_preset.newBloc(b, bloc.base_ref);
      }});//
    }
    
    setupFromBloc(b.getBloc(value_bloc.base_ref));

    if (b.getValue("show_macro") != null) 
      show_macro.set(((sBoo)b.getValue("show_macro")).get());
    if (b.getValue("show_build_tool") != null) 
      show_build_tool.set(((sBoo)b.getValue("show_build_tool")).get());
    if (b.getValue("show_sheet_tool") != null) 
      show_sheet_tool.set(((sBoo)b.getValue("show_sheet_tool")).get());
    if (b.getValue("show_macro_tool") != null) 
      show_macro_tool.set(((sBoo)b.getValue("show_macro_tool")).get());
    
    if (sheet_explorer != null) sheet_explorer.update();
    inter.addEventNextFrame(new Runnable() { public void run() { 
      inter.addEventNextFrame(new Runnable() { public void run() { select(); } } ); } } );
      
    szone_clear_select();
    is_setup_loading = false;
  }
  
  void saving_database() {
    sValueBloc vb = inter.getTempBloc();
    sValueBloc tb = copy_bloc(saved_template, vb);
    sValueBloc pb = copy_bloc(saved_preset, vb);
    
    Save_Bloc sb = new Save_Bloc("");
    sb.load_from(database_path.get());
    
    if (database_setup_bloc != null) database_setup_bloc.clear();
    database_setup_bloc = inter.data.newBloc(sb, "db_setup");
    
    if (database_setup_bloc.getBloc("Template") != null) {
      database_setup_bloc.getBloc("Template").runBlocIterator(new Iterator<sValueBloc>(tb) { public void run(sValueBloc bloc) { 
        Save_Bloc b = new Save_Bloc("");
        bloc.preset_to_save_bloc(b);
        if (((sValueBloc)builder).getBloc(bloc.ref) == null && !bloc.base_ref.equals("copy")) ((sValueBloc)builder).newBloc(b, bloc.ref);
      }});
    }
    if (database_setup_bloc.getBloc("Preset") != null) {
      database_setup_bloc.getBloc("Preset").runBlocIterator(new Iterator<sValueBloc>(pb) { public void run(sValueBloc bloc) { 
        Save_Bloc b = new Save_Bloc("");
        bloc.preset_to_save_bloc(b);
        if (((sValueBloc)builder).getBloc(bloc.ref) == null) ((sValueBloc)builder).newBloc(b, bloc.ref);
      }});//
    }
    
    vb.preset_to_save_bloc(sb); 
    sb.save_to(database_path.get());
  }
  
  boolean packet_process_asked = false;
  LinkedBlockingQueue<Macro_Sheet> sheet_to_process = new LinkedBlockingQueue<Macro_Sheet>();
  Macro_Sheet proccessed_sheet = null;
  
  void ask_packet_process(Macro_Sheet sh) {
    //logln(sh.value_bloc.ref+" ask_packet_process");
    if (!do_packet.get()) {
      sheet_to_process.clear();
    } else {
      //if (!sheet_to_process.contains(sh)) { 
        sheet_to_process.add(sh);
        if (!packet_process_asked) {
          packet_process_asked = true;
          inter.addEventNextFrameEnd(new Runnable() { public void run() { 
            //logln("Main start process sheet");
            while(sheet_to_process.size() > 0) {
              proccessed_sheet = sheet_to_process.remove();
              proccessed_sheet.process_packets();
            }
            packet_process_asked = false;
          } });
        }
      //}
    }
  }
  
  sBoo show_gui, show_macro, show_build_tool, show_sheet_tool, show_macro_tool, do_packet;
  sStr new_temp_name, database_path; sRun del_select_run, copy_run, paste_run;
  //sInt val_scale;
  sInterface inter;
  sValueBloc saved_template, saved_preset, database_setup_bloc;
  nGUI cam_gui, screen_gui;
  nInfo info;
  nSelectZone szone;
  Macro_Sheet selected_sheet = this, search_sheet = this;
  ArrayList<Macro_Abstract> selected_macro = new ArrayList<Macro_Abstract>();
  boolean buildingLine = false, is_setup_loading = false;
  String access;
  boolean canAccess(String a) { return inter.canAccess(a); }
  String last_created_link = "";
  ArrayList<MChan> chan_macros = new ArrayList<MChan>();
  ArrayList<MMIDI> midi_macros = new ArrayList<MMIDI>();
  ArrayList<MPanel> pan_macros = new ArrayList<MPanel>();
  ArrayList<MTool> tool_macros = new ArrayList<MTool>();
  int pan_nb = 0, tool_nb = 0;
  Macro_Sheet last_link_sheet = null;
  
  void updateBack() {}
  
  void szone_clear_select() {
    for (Macro_Abstract m : selected_macro) m.szone_unselect();
    selected_macro.clear();
  }
  
Macro_Main(sInterface _int) {
    super(_int);
    inter = _int; 
    access = inter.getAccess();
    cam_gui = inter.cam_gui; 
    screen_gui = inter.screen_gui;
    info = new nInfo(cam_gui, ref_size);
    saved_template = inter.interface_bloc.newBloc("Template");
    saved_preset = inter.interface_bloc.newBloc("Preset");
    new_temp_name = setting_bloc.newStr("new_temp_name", "new_temp_name", "template");
    database_path = setting_bloc.newStr("database_path", "database_path", "database.sdata");
    
    show_macro = setting_bloc.newBoo("show_macro", "show", true);
    show_macro.addEventChange(new Runnable(this) { public void run() { 
      if (show_macro.get()) for (Macro_Abstract m : child_macro) m.show();
      else for (Macro_Abstract m : child_macro) m.hide();
    }});
    
    show_build_tool = setting_bloc.newBoo("show_build_tool", "build tool", true);
    show_build_tool.addEventChange(new Runnable(this) { public void run() { 
      if (build_tool != null && build_tool.hide == show_build_tool.get()) build_tool.reduc();
    }});
    show_sheet_tool = setting_bloc.newBoo("show_sheet_tool", "sheet tool", true);
    show_sheet_tool.addEventChange(new Runnable(this) { public void run() { 
      if (sheet_tool != null && sheet_tool.hide == show_sheet_tool.get()) sheet_tool.reduc();
    }});
    show_macro_tool = setting_bloc.newBoo("show_macro_tool", "macro tool", true);
    show_macro_tool.addEventChange(new Runnable(this) { public void run() { 
      if (macro_tool != null && macro_tool.hide == show_macro_tool.get()) macro_tool.reduc();
    }});
    show_gui = newBoo("show_gui", "show gui", true);
    show_gui.addEventChange(new Runnable(this) { public void run() { 
      screen_gui.isShown = show_gui.get();
      inter.show_info = show_gui.get();
    }});
    
    do_packet = newBoo(false, "do_packet", "do_packet");
    //do_packet.set(false);
    
    szone = new nSelectZone(gui);
    szone.addEventStartSelect(new Runnable(this) { public void run() { 
      selected_macro.clear();
    }}).addEventEndSelect(new Runnable(this) { public void run() {
      search_sheet.select();
      search_sheet = ((Macro_Sheet)builder);
    }});
    
    del_select_run = newRun("del_select_run", "del", new Runnable() { public void run() { del_selected(); }});
    
    copy_run = newRun("copy_run", "copy", new Runnable() { public void run() { copy_to_tmpl(); }});
    
    paste_run = newRun("paste_run", "paste", new Runnable() { public void run() { paste_tmpl(); }});
    
    addSpecializedSheet(new SheetPrint());
    
    //val_scale = menuIntSlide(int(ref_size), 1, 100, "val_scale");
    //val_scale.addEventChange(new Runnable(this) { public void run() {
    //  boolean b = int(ref_size) == val_scale.get();
    //  ref_size = val_scale.get();
    //  if (b) inter.quicksave_run.run();
    //  //if (b) inter.quickload_run.run();
    //}});

    inter.addEventSetupLoad(new Runnable() { public void run() { 
      //ref_size = val_scale.get();
      //inter.addEventNextFrame(new Runnable() { public void run() { build_sheet_menu(); } } );
    } } );
    
    
    _int.addEventNextFrame(new Runnable() { public void run() { 
      //openning.set(OPEN); 
      //deploy();
      //logln("main sheet "+openning.get());
      //if (!mmain().show_macro.get()) hide();
      //toLayerTop(); 
      //inter.addEventNextFrame(new Runnable() { public void run() { 
      //  logln("main sheet "+openning.get());
      //  inter.addEventNextFrame(new Runnable() { public void run() { 
      //    logln("1main sheet "+openning.get());
      //    //openning.set(OPEN); 
      //    //deploy();
      //    //logln("2main sheet "+openning.get());
      //  } } );
      //} } );
    } } );
  }
  
  void addSpecializedSheet(Sheet_Specialize s) {
    s.mmain = this;
    build_macro_menus();
  }
  Macro_Sheet addUniqueSheet(Sheet_Specialize s) {
    s.mmain = this;
    s.unique = true;
    build_macro_menus();
    return s.add_new(this, null, null);
  }
  
  void noteOn(int channel, int pitch, int velocity) {
    for (MMIDI m : midi_macros) m.noteOn(channel, pitch, velocity);
  }
  
  void noteOff(int channel, int pitch, int velocity) {
    for (MMIDI m : midi_macros) m.noteOff(channel, pitch, velocity);
  }
  
  void controllerChange(int channel, int number, int value) {
    for (MMIDI m : midi_macros) m.controllerChange(channel, number, value);
  }
}


import java.util.concurrent.LinkedBlockingQueue; 
























      
