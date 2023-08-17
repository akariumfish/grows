
Group group_grow; // la grande tab 
Textlabel info3, info4; // les texte d'info, declarer pour pouvoir les modif

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
  build_line_factor(group_grow, "GROW", "= r^", GROW_DIFFICULTY, 10, 70, 0);
  build_line_factor(group_grow, "BLOOM", " = r^", SPROUT_DIFFICULTY, 10, 120, 1);
  build_line_factor(group_grow, "STOP", " = r^", STOP_DIFFICULTY, 10, 170, 2);
  build_line_factor(group_grow, "DIE", " = r^", DIE_DIFFICULTY, 10, 220, 3);
  build_line_factor(group_grow, "AGING", " ", OLD_AGE, 10, 270, 4);
  
  Button b; //pointer
  
  b = addButton(group_grow, "ON_GROW", "", 110+5, 70+5, BTN_SIZE-10, BTN_SIZE-10, utilctrlid + 4, TEXT_SIZE)
    .setSwitch(true);
  if (ON_GROW) b.setOn();
  b = addButton(group_grow, "ON_SPROUT", "", 110+5, 120+5, BTN_SIZE-10, BTN_SIZE-10, utilctrlid + 5, TEXT_SIZE)
    .setSwitch(true);
  if (ON_SPROUT) b.setOn();
  b = addButton(group_grow, "ON_STOP", "", 110+5, 170+5, BTN_SIZE-10, BTN_SIZE-10, utilctrlid + 6, TEXT_SIZE)
    .setSwitch(true);
  if (ON_STOP) b.setOn();
  b = addButton(group_grow, "ON_DIE", "", 110+5, 220+5, BTN_SIZE-10, BTN_SIZE-10, utilctrlid + 7, TEXT_SIZE)
    .setSwitch(true);
  if (ON_DIE) b.setOn();
  
  addText(group_grow, "title3", "Movement", 140, 320, 24);
  build_line_factor(group_grow, "DRIFT", " = PI/", DEVIATION, 10, 350, 7);
  build_line_factor(group_grow, "L", " = r^", L_DIFFICULTY, 10, 400, 8);
  build_line_factor(group_grow, "LMIN", " = ", L_MIN, 10, 450, 9);
  build_line_factor(group_grow, "LMAX", " = ", L_MAX, 10, 500, 10);
  
  addText(group_grow, "title4", "Utilitaires", 140, 545, 24);
  info3 = addText(group_grow, "info3", " ", 50, 580);
  info4 = addText(group_grow, "info4", " ", 200, 580);
  
  b = addButton(group_grow, "GRAPH", "graphic", 150, 660, 100, 30, utilctrlid + 8, TEXT_SIZE)
    .setSwitch(true);
  if (SHOW_GRAPH) b.setOn();
  
  build_line_incr(group_grow, "INIT", " ", INIT_BASE, 10, 610, 6);
  
  addButton(group_grow, "HIDE_GROW", "H", 370, 670, 20, 20, utilctrlid + 12, 16);
  
}

void event_panel_grower(int id, int line, float modifier) {
  if (id == utilctrlid + 8) { //button graph
    SHOW_GRAPH = ((Button)cp5.getController("GRAPH")).isOn(); }
  if (id == utilctrlid + 12) { group_grow.hide(); } // boutton hide
  
  //activation
  if (id == utilctrlid + 4) {
    ON_GROW = ((Button)cp5.getController("ON_GROW")).isOn(); }
  if (id == utilctrlid + 5) {
    ON_SPROUT = ((Button)cp5.getController("ON_SPROUT")).isOn(); }
  if (id == utilctrlid + 6) {
    ON_STOP = ((Button)cp5.getController("ON_STOP")).isOn(); }
  if (id == utilctrlid + 7) {
    ON_DIE = ((Button)cp5.getController("ON_DIE")).isOn(); }
  
  // apply modifier
  if (line == 0) { GROW_DIFFICULTY *= modifier; update_textlabel("GROW", " = r^", GROW_DIFFICULTY); }
  if (line == 1) { SPROUT_DIFFICULTY *= modifier; update_textlabel("BLOOM", " = r^", SPROUT_DIFFICULTY); }
  if (line == 2) { STOP_DIFFICULTY *= modifier; update_textlabel("STOP", " = r^", STOP_DIFFICULTY); }
  if (line == 3) { DIE_DIFFICULTY *= modifier; update_textlabel("DIE", " = r^", DIE_DIFFICULTY); }
  if (line == 4) { OLD_AGE *= modifier; update_textlabel("AGING", " ", OLD_AGE); }
  if (line == 7) { DEVIATION *= modifier; update_textlabel("DRIFT", " = PI/", DEVIATION); }
  if (line == 8) { L_DIFFICULTY *= modifier;  update_textlabel("L", " = r^", L_DIFFICULTY);}
  if (line == 9) { L_MIN *= modifier;  update_textlabel("LMIN", " = ", L_MIN);}
  if (line == 10) { L_MAX *= modifier;  update_textlabel("LMAX", " = ", L_MAX);}
  if (line == 6) { INIT_BASE += modifier; update_textlabel("INIT", " ", INIT_BASE); }
}

void update_panel_grower() {
  //mise a jour des text du menu
  info3.setText("object nb: " + baseNb());
  info4.setText("growing objects: " + growsNb());
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
