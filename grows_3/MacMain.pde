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
    .setStandbyColor(color(80))
    .setHoveredColor(color(120))
    .setClickedColor(color(150))
    .setOutlineWeight(ref_size / 9)
    .setOutline(true)
    .setOutlineColor(color(160))
    .setLosange(true)
    .setSize(ref_size*1, ref_size*0.75)
    );
  theme.addModel("MC_Selection_Grabber", theme.newWidget("mc_ref")
    .setStandbyColor(color(220, 220, 0))
    .setHoveredColor(color(100))
    .setClickedColor(color(130))
    .setOutlineWeight(ref_size / 5)
    .setOutline(true)
    .setOutlineColor(color(150, 150, 0))
    .setLosange(true)
    .setSize(ref_size*0.75, ref_size*0.75)
    );
  theme.addModel("MC_Selection_Front", theme.newWidget("mc_ref")
    .setStandbyColor(color(50, 0))
    .setOutlineColor(color(200))
    .setOutlineConstant(true)
    .setOutline(true)
    .setOutlineWeight(ref_size * 2.0 / 40.0)
    .setPassif()
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
    .setSize(ref_size*0.4, ref_size*0.5)
    .setPosition(-ref_size*1.0, ref_size*0.0)
    );
  theme.addModel("MC_Deploy", theme.newWidget("MC_Reduc")
    .setSize(ref_size*0.55, ref_size*0.65).setPosition(-ref_size*0.375, -ref_size*0.1775)
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
          .setRunnable(new Runnable() { public void run() { pastebin_tmpl(); }})
          .setInfo("Paste").setFont(int(ref_size/1.9)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P2", "MM")
          .setRunnable(new Runnable() { public void run() { build_sheet_menu(); }})
          .setInfo("Open main sheet menu").setFont(int(ref_size/1.9)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P3", "FM")
          .setRunnable(new Runnable() { public void run() { inter.filesManagement(); }})
          .setInfo("File management").setFont(int(ref_size/1.9)).getShelfPanel()
      .addShelf().addDrawer(6.625, 1)
        .addCtrlModel("Menu_Button_Small_Outline-S1-P1", "QS")
          .setRunnable(new Runnable() { public void run() { inter.full_data_save(); }})
          .setInfo("Quick Save").setFont(int(ref_size/1.9)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P2", "QL")
          .setRunnable(new Runnable() { public void run() { inter.setup_load(); }})
          .setInfo("Quick Load").setFont(int(ref_size/1.9)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P3", "SA")
          .setRunnable(new Runnable() { public void run() { inter.save_as(); }})
          .setInfo("Save As").setFont(int(ref_size/1.9)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P4", "ST")
          .setRunnable(new Runnable() { public void run() { inter.save_to(); }})
          .setInfo("Save to").setFont(int(ref_size/1.9)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P5", "OP")
          .setRunnable(new Runnable() { public void run() { inter.quick_open(); }})
          .setInfo("Open").setFont(int(ref_size/1.9)).getDrawer()
        .addCtrlModel("Menu_Button_Small_Outline-S1-P6", "FS")
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
        if (template_explorer.selected_bloc != null) template_explorer.selected_bloc.clear(); template_explorer.update(); } } ).setInfo("delete selected template").getShelf()
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
      .addCtrlModel("Button-S3-P1", "New Tmplt").setRunnable(new Runnable() { public void run() { 
        new_tmpl(); template_explorer.update(); } } )
      .setInfo("save selected as new template").getDrawer()
      .addCtrlModel("Button-S3-P2", "Paste").setRunnable(new Runnable() { public void run() { 
        pastedata_tmpl(); } } )
      .setInfo("add selected template to selected sheet").getShelf()
      .addSeparator()
      ;
    if (pastebin != null) template_explorer.selectEntry(pastebin.ref);
    template_explorer.getShelf()
      .addSeparator(0.25)
        ;
    
  }
  
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
      //for (Map.Entry me : pastebin.blocs.entrySet()) {
      //  sValueBloc vb = ((sValueBloc)me.getValue());
      //  if (vb.getBloc("settings") != null && vb.getBloc("settings").getValue("position") != null) {
      //    sVec v = (sVec)(vb.getBloc("settings").getValue("position"));
      //    v.setx(v.x() + ref_size * 2); v.sety(v.y() + ref_size * 3);
      //  }
      //}
      
      if (template_explorer != null) { 
        template_explorer.update();
        template_explorer.selectEntry(pastebin.base_ref); }
    } 
  }
  void pastedata_tmpl() {
    if (template_explorer != null && template_explorer.selected_bloc != null) {
      paste_tmpl(template_explorer.selected_bloc);
    }
  }
  void pastebin_tmpl() {
    if (pastebin != null) {
      paste_tmpl(pastebin);
    }
  }
  void paste_tmpl(sValueBloc bloc) {
    //save adding pos
    PVector prevs_gr_p = new PVector(); //def center
    boolean to_empty_sheet = selected_sheet.child_macro.size() == 0;
    if (selected_macro.size() > 0) { //use last selected med pos
      prevs_gr_p.set(select_grab_widg.getX(), select_grab_widg.getY());
      prevs_gr_p = inter.cam.screen_to_cam(prevs_gr_p);
    } else if (show_macro.get() && !to_empty_sheet) { //use screen point
      //PVector sc_pos = new PVector(mmain().screen_gui.view.pos.x + mmain().screen_gui.view.size.x * 1.0 / 2.0, 
      //                             mmain().screen_gui.view.pos.y + mmain().screen_gui.view.size.y / 3.0);
      //sc_pos = mmain().inter.cam.screen_to_cam(sc_pos);
      //sc_pos.x = (sc_pos.x - sc_pos.x%(ref_size * 0.5));
      //sc_pos.y = (sc_pos.y - sc_pos.y%(ref_size * 0.5));
      //prevs_gr_p.set(sc_pos.x - selected_sheet.grabber.getX(), sc_pos.y - selected_sheet.grabber.getY());
      //prevs_gr_p.x = (prevs_gr_p.x - prevs_gr_p.x%(ref_size * 0.5));
      //prevs_gr_p.y = (prevs_gr_p.y - prevs_gr_p.y%(ref_size * 0.5));
    }
    
    //add macros and select them
    szone_clear_select();
    is_paste_loading = true;
    selected_sheet.addCopyofBlocContent(bloc, true); //true: will select 
    
    if (to_empty_sheet) { 
      szone_clear_select(); 
      //selected_sheet.szone_select(); 
      prevs_gr_p.set(select_grab_widg.getX(), select_grab_widg.getY());
      prevs_gr_p = inter.cam.screen_to_cam(prevs_gr_p);
    }
    
    //move group to adding pos
    PVector s_gr_p = new PVector(select_grab_widg.getX(), select_grab_widg.getY());
    s_gr_p = inter.cam.screen_to_cam(s_gr_p);
    s_gr_p.add(-prevs_gr_p.x, -prevs_gr_p.y);
    s_gr_p.mult(-1);
    for (Macro_Abstract m : selected_macro) 
      m.group_move(s_gr_p.x, s_gr_p.y);
  
    //find place
    int adding_v = 0;
    boolean found = false;
    while (!found) {
      boolean col = false;
      float phf = 0.0;
      selected_sheet.updateBack();
      for (Macro_Abstract c : selected_sheet.child_macro) 
        if (!selected_macro.contains(c) && c.openning.get() == DEPLOY 
            && rectCollide(select_bound_widg.getRect(), c.back.getRect(), ref_size * phf)) col = true;
        else if (!selected_macro.contains(c) && c.openning.get() == REDUC 
                 && rectCollide(select_bound_widg.getRect(), c.grabber.getRect(), ref_size * phf)) col = true;
        else if (!selected_macro.contains(c) && c.openning.get() == OPEN 
                 && rectCollide(select_bound_widg.getRect(), c.panel.getRect(), ref_size * phf)) col = true;
        else if (!selected_macro.contains(c) && c.openning.get() == HIDE && c.openning_pre_hide.get() == DEPLOY
                 && rectCollide(select_bound_widg.getPhantomRect(), c.back.getPhantomRect(), ref_size * phf)) col = true;
        else if (!selected_macro.contains(c) && c.openning.get() == HIDE && c.openning_pre_hide.get() == REDUC
                 && rectCollide(select_bound_widg.getPhantomRect(), c.grabber.getPhantomRect(), ref_size * phf)) col = true;
        else if (!selected_macro.contains(c) && c.openning.get() == HIDE && c.openning_pre_hide.get() == OPEN
                 && rectCollide(select_bound_widg.getPhantomRect(), c.panel.getPhantomRect(), ref_size * phf)) col = true;
      
      if (selected_sheet != mmain() && !show_macro.get()//openning.get() == HIDE 
          && rectCollide(select_bound_widg.getPhantomRect(), sheet.panel.getPhantomRect(), ref_size * 1)) col = true;
      if (selected_sheet != mmain() && show_macro.get()//openning.get() != HIDE 
          && rectCollide(select_bound_widg.getRect(), sheet.panel.getRect(), ref_size * 1)) col = true;
      
      if (!col) found = true;
      else {
        if (adding_v > 0) {
          for (Macro_Abstract m : selected_macro) 
            m.group_move(-ref_size * 3, 0);
        }
        adding_v++; 
        if (adding_v == 6) { 
          adding_v = 0; 
          for (Macro_Abstract m : selected_macro) 
            m.group_move(ref_size * 15, ref_size*3);
        }
      }
    }
    selected_sheet.updateBack();
  
    inter.addEventTwoFrame(new Runnable() { public void run() { is_paste_loading = false; } } );
    if (sheet_explorer != null) sheet_explorer.update();
  }
  //boolean del_order = false;
  void del_selected() {
    //del_order = true;
    inter.addEventNextFrame(new Runnable() { public void run() { 
      for (Macro_Abstract m : selected_macro) m.clear(); 
      if (sheet_explorer != null) sheet_explorer.update(); 
      selected_macro.clear(); 
      update_select_bound();
    } } );
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
      inter.addEventNextFrame(new Runnable() { public void run() { select(); szone_clear_select(); } } ); } } );
      
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
  sStr new_temp_name, database_path; sRun del_select_run, copy_run, paste_run, reduc_run;
  sInterface inter;
  sValueBloc saved_template, saved_preset, database_setup_bloc;
  nGUI cam_gui, screen_gui;
  nInfo info;
  nSelectZone szone;
  nWidget select_bound_widg, select_grab_widg;
  Macro_Sheet selected_sheet = this, search_sheet = this;
  ArrayList<Macro_Abstract> selected_macro = new ArrayList<Macro_Abstract>();
  boolean buildingLine = false, is_setup_loading = false, is_paste_loading = false;
  String access;
  boolean canAccess(String a) { return inter.canAccess(a); }
  String last_created_link = "";
  ArrayList<MChan> chan_macros = new ArrayList<MChan>();
  ArrayList<MMIDI> midi_macros = new ArrayList<MMIDI>();
  ArrayList<MPanel> pan_macros = new ArrayList<MPanel>();
  ArrayList<MTool> tool_macros = new ArrayList<MTool>();
  int pan_nb = 0, tool_nb = 0;
  Macro_Sheet last_link_sheet = null;
  
  void updateBack() { update_select_bound(); }
  
  void szone_clear_select() {
    for (Macro_Abstract m : selected_macro) m.szone_unselect();
    selected_macro.clear();
    update_select_bound();
  }
  void reduc_selected() {
    for (Macro_Abstract m : selected_macro) m.changeOpenning();
  }
  
Macro_Main(sInterface _int) {
    super(_int);
    mlogln("build macro main ");
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
      update_select_bound();
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
    
    del_select_run = newRun("del_select_run", "del", new Runnable() { public void run() { del_selected(); }});
    
    copy_run = newRun("copy_run", "copy", new Runnable() { public void run() { copy_to_tmpl(); }});
    
    paste_run = newRun("paste_run", "paste", new Runnable() { public void run() { pastebin_tmpl(); }});
    
    reduc_run = newRun("switch_reduc_run", "switch_reduc", new Runnable() { public void run() { 
      reduc_selected(); }});
    
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
    
    
    
    
    
    szone = new nSelectZone(gui);
    szone.addEventStartSelect(new Runnable(this) { public void run() { 
      select_bound_widg.hide();
      select_grab_widg.hide();
      selected_macro.clear();
    }}).addEventEndSelect(new Runnable(this) { public void run() {
      if (selected_sheet == search_sheet) 
        inter.addEventNextFrame(new Runnable() { public void run() { update_select_bound(); } } );
      search_sheet.select();
      search_sheet = ((Macro_Sheet)builder);
    }});
    
    select_bound_widg = addModel("MC_Selection_Front")
      .setLayer(1)
      .hide();
    select_bound_widg.clearParent();
    select_grab_widg = screen_gui.theme.newWidget(screen_gui, "MC_Selection_Grabber")
      .setGrabbable()
      .hide();
    
    select_grab_widg
      .addEventGrab(new Runnable() { public void run() {
        sgrab_px = select_grab_widg.getX();
        sgrab_py = select_grab_widg.getY();
      } } )
      .addEventDrag(new Runnable() { public void run() {
        
        select_grab_widg.setPY(select_grab_widg.getLocalY()
                               - select_grab_widg.getLocalY()%(ref_size * (0.5*gui.scale)));
        select_grab_widg.setPX(select_grab_widg.getLocalX() 
                               - select_grab_widg.getLocalX()%(ref_size * (0.5*gui.scale)));
        
        PVector gr_p = new PVector(select_grab_widg.getX(), select_grab_widg.getY());
        

        PVector prev_gr_p = new PVector(sgrab_px, sgrab_py);
        gr_p = inter.cam.screen_to_cam(gr_p);
        prev_gr_p = inter.cam.screen_to_cam(prev_gr_p);
        
        for (Macro_Abstract m : selected_macro) 
          m.group_move(gr_p.x - prev_gr_p.x, gr_p.y - prev_gr_p.y);
        
        sgrab_px = select_grab_widg.getX();
        sgrab_py = select_grab_widg.getY();
        
        selected_sheet.updateBack();
        update_select_bound();
      } } );
    
    _int.addEventNextFrame(new Runnable() { public void run() { 
      inter.cam.addEventZoom(new Runnable() { public void run() { update_select_bound(); } } )
               .addEventMove(new Runnable() { public void run() { update_select_bound(); } } );
    } } );
    
  }
  float sgrab_px = 0, sgrab_py = 0;
  void update_select_bound() {
    if (show_macro.get() && selected_macro.size() > 0) {
      float elem_space = ref_size*0.5;
      float minx = 0, miny = 0, maxx = 0, maxy = 0;
      
      Macro_Abstract f = selected_macro.get(0);
      if (f.openning.get() == DEPLOY) {
          minx = f.grabber.getX() + f.back.getLocalX() - elem_space;
          miny = f.grabber.getY() + f.back.getLocalY() - elem_space;
          maxx = f.grabber.getX() + f.back.getLocalX() + f.back.getLocalSX() + elem_space;
          maxy = f.grabber.getY() + f.back.getLocalY() + f.back.getLocalSY() + elem_space;
      } else if (f.openning.get() == OPEN) {
          minx = f.grabber.getX() + f.panel.getLocalX() - elem_space;
          miny = f.grabber.getY() + f.panel.getLocalY() - elem_space;
          maxx = f.grabber.getX() + f.panel.getLocalX() + f.panel.getLocalSX() + elem_space;
          maxy = f.grabber.getY() + f.panel.getLocalY() + f.panel.getLocalSY() + elem_space;
      } else if (f.openning.get() == REDUC) {
          minx = f.grabber.getX() - elem_space;
          miny = f.grabber.getY() - elem_space;
          maxx = f.grabber.getX() + f.grabber.getLocalSX() + elem_space;
          maxy = f.grabber.getY() + f.grabber.getLocalSY() + elem_space;
      }
      
      for (Macro_Abstract m : selected_macro) if (m.openning.get() == DEPLOY) {
        if (minx > m.grabber.getX() + m.back.getLocalX() - elem_space) 
          minx = m.grabber.getX() + m.back.getLocalX() - elem_space;
        if (miny > m.grabber.getY() + m.back.getLocalY() - elem_space) 
          miny = m.grabber.getY() + m.back.getLocalY() - elem_space;
        if (maxx < m.grabber.getX() + m.back.getLocalX() + m.back.getLocalSX() + elem_space) 
          maxx = m.grabber.getX() + m.back.getLocalX() + m.back.getLocalSX() + elem_space;
        if (maxy < m.grabber.getY() + m.back.getLocalY() + m.back.getLocalSY() + elem_space) 
          maxy = m.grabber.getY() + m.back.getLocalY() + m.back.getLocalSY() + elem_space;
      } else if (m.openning.get() == OPEN) {
        if (minx > m.grabber.getX() + m.panel.getLocalX() - elem_space) 
          minx = m.grabber.getX() + m.panel.getLocalX() - elem_space;
        if (miny > m.grabber.getY() + m.panel.getLocalY() - elem_space) 
          miny = m.grabber.getY() + m.panel.getLocalY() - elem_space;
        if (maxx < m.grabber.getX() + m.panel.getLocalX() + m.panel.getLocalSX() + elem_space) 
          maxx = m.grabber.getX() + m.panel.getLocalX() + m.panel.getLocalSX() + elem_space;
        if (maxy < m.grabber.getY() + m.panel.getLocalY() + m.panel.getLocalSY() + elem_space) 
          maxy = m.grabber.getY() + m.panel.getLocalY() + m.panel.getLocalSY() + elem_space;
      } else if (m.openning.get() == REDUC) {
        if (minx > m.grabber.getX() - elem_space) 
          minx = m.grabber.getX() - elem_space;
        if (miny > m.grabber.getY() - elem_space) 
          miny = m.grabber.getY() - elem_space;
        if (maxx < m.grabber.getX() + m.grabber.getLocalSX() + elem_space) 
          maxx = m.grabber.getX() + m.grabber.getLocalSX() + elem_space;
        if (maxy < m.grabber.getY() + m.grabber.getLocalSY() + elem_space) 
          maxy = m.grabber.getY() + m.grabber.getLocalSY() + elem_space;
      }
      
      select_bound_widg.show();
      select_bound_widg.setPosition(minx, miny);
      select_bound_widg.setSize(maxx - minx, maxy - miny);
      PVector p = new PVector(minx + (maxx - minx) / 2, miny + (maxy - miny) / 2);
      p = inter.cam.cam_to_screen(p);
      p.add(-select_grab_widg.getLocalSX()/2, -select_grab_widg.getLocalSY()/2);
      if (selected_macro.size() > 1 || ref_size * gui.scale < 20) 
        select_grab_widg.show().setPosition(p.x, p.y);
      else select_grab_widg.hide();
    } else {
      select_bound_widg.hide();
      select_grab_widg.hide();
    }
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
























      
