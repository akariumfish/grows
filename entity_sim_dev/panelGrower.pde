
Group group_grow; // la grande tab 
Textlabel info3; // les texte d'info, declarer pour pouvoir les modif

void init_panel_grower() {
  group_grow = cp5.addGroup("group_grow")
             .setPosition(width - PANEL_WIDTH, 10)
             .setSize(PANEL_WIDTH, 10)
             .setBackgroundHeight(700)
             .setBackgroundColor(color(60, 200))
             .disableCollapse()
             .moveTo("Menu")
             ;
  group_grow.getCaptionLabel().setText("");
  
  addText(group_grow, "title1", "GROWING STRUCTURES", 15, 0, 30).setFont(createFont("Arial Bold",30));
  
  addText(group_grow, "title2", "Behavior", 150, 40, 24);
  //build_line_factor(group_grow, "DIF", " * r^", DIFICULTY, 10, 70, 0);
  
  Button b; //pointer
  
  //b = addButton(group_grow, "ON", "", 110+5, 70+5, BTN_SIZE-10, BTN_SIZE-10, utilctrlid + 4, TEXT_SIZE)
  //  .setSwitch(true);
  //if (ON) b.setOn();
  
  
  
  addText(group_grow, "title4", "Utilitaires", 140, 545, 24);
  info3 = addText(group_grow, "info3", " ", 50, 580);
  
  b = addButton(group_grow, "GRAPH", "graphic", 150, 660, 100, 30, utilctrlid + 8, TEXT_SIZE)
    .setSwitch(true);
  if (SHOW_GRAPH) b.setOn();
  
  //build_line_incr(group_grow, "INIT", " ", INIT_BASE, 10, 610, 6);
  
  addButton(group_grow, "HIDE_GROW", "H", 370, 670, 20, 20, utilctrlid + 12, 16);
  
}

void event_panel_grower(int id, int line, float modifier) {
  if (id == utilctrlid + 8) { //button graph
    SHOW_GRAPH = ((Button)cp5.getController("GRAPH")).isOn(); }
  if (id == utilctrlid + 12) { group_grow.hide(); } // boutton hide
  
  //activation
  //if (id == utilctrlid + 4) {
  //  ON = ((Button)cp5.getController("ON")).isOn(); }
  
  // apply modifier
  //if (line == 0) { DIFICULTY *= modifier; update_textlabel("DIF", " * r^", DIFICULTY); }
  
}

void update_panel_grower() {
  //mise a jour des text du menu
  //info3.setText("object nb: " + baseNb());
  //moving control panel
  if (group_grow.isMouseOver() && mouseClick[0]) {
    mx = group_grow.getPosition()[0] - mouseX;
    my = group_grow.getPosition()[1] - mouseY;
    GRAB = false;//deactive le deplacement camera
  }
  if (group_grow.isMouseOver() && mouseUClick[0]) {
    GRAB = true;
  }
  if (group_grow.isMouseOver() && mouseButtons[0]) {
    group_grow.setPosition(mouseX + mx,mouseY + my);
  }
}

void update_textlabel(String name, String comp, float val) {
  Textlabel t = (Textlabel)cp5.getController(name + "-label");
  t.setText(name + comp + val);
}
