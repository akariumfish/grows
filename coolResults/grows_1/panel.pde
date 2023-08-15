
//ici on gere le menu


int TEXT_SIZE = 18;
int BTN_SIZE = 40;

int maxctrlerByLine = 10;
int utilctrlid = 1000;

// modify by a factor
void build_line_factor(String name, float val, float x, float y, int id) {
  id *= maxctrlerByLine;
  addButton(name + "-x2", "x2", x + 340, y + 0, BTN_SIZE, BTN_SIZE, id+1, TEXT_SIZE);
  addButton(name + "-x1", "x1.2", x + 290, y + 0, BTN_SIZE, BTN_SIZE, id+2, TEXT_SIZE);
  addButton(name + "-/1", "/1.2", x + 50, y + 0, BTN_SIZE, BTN_SIZE, id+3, TEXT_SIZE);
  addButton(name + "-/2", "/2", x + 0, y + 0, BTN_SIZE, BTN_SIZE, id+4, TEXT_SIZE);
  addText(name + "-label", name + ": " + val, x + 140, y + 10).setId(id);
}

// modify by increment
void build_line_incr(String name, float val, float x, float y, int id) {
  id *= maxctrlerByLine;
  addButton(name + "-min10", "-10", x + 0, y + 0, BTN_SIZE, BTN_SIZE, id+5, TEXT_SIZE);
  addButton(name + "-min1", "-1", x + 50, y + 0, BTN_SIZE, BTN_SIZE, id+6, TEXT_SIZE);
  addButton(name + "-maj1", "+1", x + 290, y + 0, BTN_SIZE, BTN_SIZE, id+7, TEXT_SIZE);
  addButton(name + "-maj10", "+10", x + 340, y + 0, BTN_SIZE, BTN_SIZE, id+8, TEXT_SIZE);
  addText(name + "-label", name + ": " + val, x + 140, y + 15).setId(id);
}

void init_panel() {
  cp5 = new ControlP5(this);
  
  cp5_g = cp5.addGroup("g1")
             .setPosition(width - PANEL_WIDTH, 10)
             .setSize(PANEL_WIDTH, 10)
             .setBackgroundHeight(height)
             .setBackgroundColor(color(255,50))
             ;
             
  addText("title1", "GROWING STRUCTURES", 15, 0, 30).setFont(createFont("Arial Bold",30));
  
  addText("title2", "Difficulty", 140, 40, 24);
  build_line_factor("GROW", GROW_DIFFICULTY, 10, 70, 0);
  build_line_factor("SPROUT", SPROUT_DIFFICULTY, 10, 120, 1);
  build_line_factor("STOP", STOP_DIFFICULTY, 10, 170, 2);
  build_line_factor("DIE", DIE_DIFFICULTY, 10, 220, 3);
  build_line_factor("AGING", OLD_AGE, 10, 270, 4);
  
  Button b; //pointer
  
  b = addButton("ON_GROW", "", 110+5, 70+5, BTN_SIZE-10, BTN_SIZE-10, utilctrlid + 4, TEXT_SIZE)
    .setSwitch(true);
  if (ON_GROW) b.setOn();
  b = addButton("ON_SPROUT", "", 110+5, 120+5, BTN_SIZE-10, BTN_SIZE-10, utilctrlid + 5, TEXT_SIZE)
    .setSwitch(true);
  if (ON_SPROUT) b.setOn();
  b = addButton("ON_STOP", "", 110+5, 170+5, BTN_SIZE-10, BTN_SIZE-10, utilctrlid + 6, TEXT_SIZE)
    .setSwitch(true);
  if (ON_STOP) b.setOn();
  b = addButton("ON_DIE", "", 110+5, 220+5, BTN_SIZE-10, BTN_SIZE-10, utilctrlid + 7, TEXT_SIZE)
    .setSwitch(true);
  if (ON_DIE) b.setOn();
  
  addText("title3", "Movement", 140, 400, 24);
  build_line_factor("DRIFT", DEVIATION, 10, 430, 7);
  build_line_factor("MOVE", L_MAX, 10, 480, 8);
  
  addText("title4", "Utilitaires", 140, 550, 24);
  
  info1 = addText("info1", " ", 50, 590);
  info2 = addText("info2", " ", 50, 620);
  info3 = addText("info3", " ", 200, 590);
  info4 = addText("info4", " ", 200, 620);
  
  b = addButton("GRAPH", "graphic", 150, 660, 100, 30, utilctrlid + 8, TEXT_SIZE)
    .setSwitch(true);
  if (SHOW_GRAPH) b.setOn();
  
  build_line_factor("SPEED", repeat_runAll, 10, 720, 5);
  build_line_incr("INIT", INIT_BASE, 10, 770, 6);
  
  b = addButton("running", "p", 25, 830, 50, 50, utilctrlid + 3, TEXT_SIZE * 1.5)
    .setSwitch(true);
  if (pause) b.setOn();
  addButton("reset", "RESET", 100, 830, 200, 50, utilctrlid + 1, TEXT_SIZE * 1.5);
  addButton("print", "I", 325, 830, 50, 50, utilctrlid + 2, TEXT_SIZE * 1.5);
}



public void controlEvent(ControlEvent theEvent) {
  int id = theEvent.getId();
  
  // boutton reset
  if (id == utilctrlid + 1) {
    deleteAll();
    randomSeed(SEED);
    for (int i = 0; i < INIT_BASE; i++) {
      createFirstBase(random( 2 * PI));
    }
    //reset le graph
    for (int i = 0; i < larg; i++) { graph[i] = 0; graph2[i] = 0; }
    gc = 0;
    //reset le conter de tour
    counter = 0;
    return;
  }
  
  // boutton print
  if (id == utilctrlid + 2) {
    println();
    println("GROW: " + ON_GROW + " " + GROW_DIFFICULTY);
    println("SPROUT: " + ON_SPROUT + " " + SPROUT_DIFFICULTY);
    println("STOP: " + ON_STOP + " " + STOP_DIFFICULTY);
    println("DIE: " + ON_DIE + " " + DIE_DIFFICULTY);
    println("OLD AGE: " + OLD_AGE);
    println();
    screenshot = true;
    return;
  }
  
  //button pause
  if (id == utilctrlid + 3) {
    Button b = (Button)cp5.getController("running");
    pause = b.isOn();
  }
  //button graph
  if (id == utilctrlid + 8) {
    Button b = (Button)cp5.getController("GRAPH");
    SHOW_GRAPH = b.isOn();
  }
  //activation
  if (id == utilctrlid + 4) {
    Button b = (Button)cp5.getController("ON_GROW");
    ON_GROW = b.isOn();
  }
  if (id == utilctrlid + 5) {
    Button b = (Button)cp5.getController("ON_SPROUT");
    ON_SPROUT = b.isOn();
  }
  if (id == utilctrlid + 6) {
    Button b = (Button)cp5.getController("ON_STOP");
    ON_STOP = b.isOn();
  }
  if (id == utilctrlid + 7) {
    Button b = (Button)cp5.getController("ON_DIE");
    ON_DIE = b.isOn();
  }
  
  //find the right ctrl
  int line = int((float)id / (float)maxctrlerByLine);
  int ctrl = id - (line * maxctrlerByLine);
  float modifier = 1.0;
  if (ctrl == 1) modifier = 2.0;
  if (ctrl == 2) modifier = 1.2;
  if (ctrl == 3) modifier = 0.833;
  if (ctrl == 4) modifier = 0.5;
  if (ctrl == 5) modifier = -10;
  if (ctrl == 6) modifier = -1;
  if (ctrl == 7) modifier = 1;
  if (ctrl == 8) modifier = 10;
  
  // apply modifier
  if (line == 0) { GROW_DIFFICULTY *= modifier; update_textlabel("GROW", GROW_DIFFICULTY); }
  if (line == 1) { SPROUT_DIFFICULTY *= modifier; update_textlabel("SPROUT", SPROUT_DIFFICULTY); }
  if (line == 2) { STOP_DIFFICULTY *= modifier; update_textlabel("STOP", STOP_DIFFICULTY); }
  if (line == 3) { DIE_DIFFICULTY *= modifier; update_textlabel("DIE", DIE_DIFFICULTY); }
  if (line == 4) { OLD_AGE *= modifier; update_textlabel("AGING", OLD_AGE); }
  
  if (line == 7) { DEVIATION *= modifier; update_textlabel("DRIFT", DEVIATION); }
  if (line == 8) { L_MAX *= modifier; L_MAX = max(L_MAX, 1); update_textlabel("MOVE", L_MAX);}
  
  if (line == 5) { repeat_runAll *= modifier; update_textlabel("SPEED", repeat_runAll); }
  if (line == 6) { INIT_BASE += modifier; update_textlabel("INIT", INIT_BASE); }
  
  
}

void update_textlabel(String name, float val) {
  Textlabel t = (Textlabel)cp5.getController(name + "-label");
  t.setText(name + ": " + val);
}


//easy building

Textlabel addText(String name, String label, float x, float y, int st) {
  return cp5.addTextlabel(name)
     .setText(label)
     .setPosition(x, y)
     .setColorValue(0xffffffff)
     .setFont(createFont("Arial",st))
     .setGroup(cp5_g)
     ;
}

Textlabel addText(String name, String label, float x, float y) {
  return addText(name, label, x, y, TEXT_SIZE);
}

Button addButton(String name, String label, float x, float y, int sx, int sy, int id, float st) {
  Button b = cp5.addButton(name)
     .setPosition(x, y)
     .setSize(sx,sy)
     .setGroup(cp5_g)
     .setId(id)
     ;
  b.getCaptionLabel().setText(label).setFont(createFont("Arial",st));
  return b;
}
