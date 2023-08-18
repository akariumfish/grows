abstract class Controller {
  World world;
  //Body parent;
  int id = 0;
  int x,y;
  float mx = 0;
  float my = 0;
  Group g;
  int inCount = 0;
  int outCount = 0;
  
  //Controller(World w_, Body p_, int i_, int x_, int y_) {
  Controller(World w_, int i_, int x_, int y_) {
    world = w_;
    //parent = p_;
    
    x = x_; y = y_;
    id = i_;
    g = cp5.addGroup("Controller" + str(id))
                  .activateEvent(true)
                  .setPosition(x,y)
                  .setSize(320,22)
                  .setHeight(22)
                  .setBackgroundColor(color(60, 200))
                  .disableCollapse()
                  .moveTo("Macros")
                  ;
    g.getCaptionLabel().setFont(createFont("Arial",16));
  }

  InputB createInputB(String text) {
    InputB in = world.macroList.createInputB(g, id, text, inCount);
    if (inCount >= outCount) {
      g.setSize(g.getWidth(), 26 + (inCount*26));
    }
    inCount +=1;
    return in;
  }

  InputF createInputF(String text, float d_) {
    InputF in = world.macroList.createInputF(g, id, text, inCount, d_);
    if (inCount >= outCount) {
      g.setSize(g.getWidth(), 26 + (inCount*26));
    }
    inCount +=1;
    return in;
  }
  
  OutputB createOutputB(String text) {
    OutputB out = world.macroList.createOutputB(g, id, text, outCount);
    if (outCount >= inCount) {
      g.setSize(g.getWidth(), 26 + (outCount*26));
    }
    outCount +=1;
    return out;
  }

  OutputF createOutputF(String text, float d_) {
    OutputF out = world.macroList.createOutputF(g, id, text, outCount, d_);
    if (outCount >= inCount) {
      g.setSize(g.getWidth(), 26 + (outCount*26));
    }
    outCount +=1;
    return out;
  }
  
  void update() {
    if (cp5.getTab("Macros").isActive()) {
      if (g.isMouseOver() && mouseClick[0]) {
        mx = g.getPosition()[0] - mouseX;
        my = g.getPosition()[1] - mouseY;
        GRAB = false; //deactive le deplacement camera
      }
      if (g.isMouseOver() && mouseUClick[0]) {
        GRAB = true;
      }
      if (g.isMouseOver() && mouseButtons[0]) {
        x = int(mouseX + mx); y = int(mouseY + my);
        g.setPosition(mouseX + mx,mouseY + my);
      }
    }
  }
  abstract void drawing(float x, float y);
  abstract boolean checkOrders();
}

class GrowingControl extends Controller {
  InputF growI,sproutI,stopI,dieI;
  float grow,sprout,stop,die;
  
  GrowingControl(World w_, int i_, int x_, int y_) {
    super(w_, i_, x_, y_);
    g.setLabel("GROW");
    g.setWidth(200);
    growI = createInputF("GROW", GROW_DIFFICULTY);
    grow = GROW_DIFFICULTY;
    sproutI = createInputF("SPROUT", SPROUT_DIFFICULTY);
    sprout = SPROUT_DIFFICULTY;
    stopI = createInputF("STOP", STOP_DIFFICULTY);
    stop = STOP_DIFFICULTY;
    dieI = createInputF("DIE", DIE_DIFFICULTY);
    die = DIE_DIFFICULTY;
  }
  
  void drawing(float x, float y) {}
  
  void update() {
    float g = growI.get();
    float sp = sproutI.get();
    float st = stopI.get();
    float d = dieI.get();
    
    if (g != grow) {
      grow = g; GROW_DIFFICULTY = grow;
      update_textlabel("GROW", " = r^", GROW_DIFFICULTY); }
    else if (g != GROW_DIFFICULTY) {
      grow = GROW_DIFFICULTY; growI.set(grow); }
    
    if (sp != sprout) {
      sprout = sp; SPROUT_DIFFICULTY = sprout;
      update_textlabel("BLOOM", " = r^", SPROUT_DIFFICULTY); }
    else if (sp != SPROUT_DIFFICULTY) {
      sprout = SPROUT_DIFFICULTY; sproutI.set(sprout); }
    
    if (st != stop) {
      stop = st; STOP_DIFFICULTY = stop;
      update_textlabel("STOP", " = r^", STOP_DIFFICULTY); }
    else if (st != STOP_DIFFICULTY) {
      stop = STOP_DIFFICULTY; stopI.set(stop); }
    
    if (d != die) {
      die = d; DIE_DIFFICULTY = die;
      update_textlabel("DIE", " = r^", DIE_DIFFICULTY); }
    else if (d != DIE_DIFFICULTY) {
      die = DIE_DIFFICULTY; dieI.set(die); }
    
    super.update();
  }
  
  boolean checkOrders() {return false;}
}

class GrowingWatcher extends Controller {
  OutputF popO,growO;
  float pop,grow;
  
  GrowingWatcher(World w_, int i_, int x_, int y_) {
    super(w_, i_, x_, y_);
    g.setLabel("Watcher");
    g.setWidth(150);
    popO = createOutputF("      POP", 0);
    growO = createOutputF("  GROW", 0);
  }
  
  void drawing(float x, float y) {}
  
  void update() {
    popO.setBang(pop);
    growO.setBang(grow);
    super.update();
  }
  
  boolean checkOrders() { pop = baseNb(); grow = growsNb(); return false; }
}

class Keyboard extends Controller {
  boolean w,c,a,p;
  OutputB wO,cO,aO,pO;
  
  //Keyboard(World w_, Body p_f, int i_, int x_, int y_) {
  Keyboard(World w_, int i_, int x_, int y_) {
    super(w_, i_, x_, y_);
    w = false; c = false; a = false; p = false;
    g.setLabel("Key");
    g.setWidth(150);
    aO = createOutputB("          A");
    wO = createOutputB("          W");
    pO = createOutputB("          P");
    cO = createOutputB("          C");
  }
  
  void update() {
    wO.set(w);
    cO.set(c);
    aO.set(a);
    pO.set(p);
    super.update();
  }
  
  void drawing(float x, float y) {}
  
  boolean checkOrders() {
    w = false; c = false; a = false; p = false;
    if (keysClick[4]) {w = true;}
    if (keysClick[5]) {c = true;}
    if (keysClick[7]) {a = true;}
    if (keysClick[8]) {p = true;}
    return false;
  }
}

//class Rotator extends Controller {
//  float step,aC,aA;
//  OutputB egalO;
//  OutputF ecartO;
//  InputF stepI,aCI;
  
//  Rotator(World w_, Body p_, float s_, int i_, int x_, int y_) {
//    super(w_, p_, i_, x_, y_);
//    step = s_; aC = p_.a; aA = p_.a;
//    g.setLabel("Rotator");
//    egalO = createOutputB("egality");
//    ecartO = createOutputF("ecart", 0);
//    stepI = createInputF("step", step);
//    aCI = createInputF("cible", 0);
//  }
  
//  void drawing(float x, float y) {
//    text("step " + step,x,y);
//    text("aC " + aC,x+80,y);
//    text("aA " + aA,x+160,y);
//  }
  
//  void update() {
//    step = stepI.get();
//    aC = aCI.get();
//    egalO.set(aA == aC);
//    ecartO.setBang(abs(aA - aC));
//    parent.a = aA;
//    super.update();
//  }
  
//  boolean checkOrders() {return false;}
  
//  void applyStep() {
//    if (aC != aA) {
//      if (abs(aC - aA) < step) {aA = aC;}
//      else if (aC < aA) {aA -= step;}
//      else if (aC > aA) {aA += step;}
//    }
//  }
  
//}
