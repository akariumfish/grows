class World {
  ArrayList<Controller> control = new ArrayList<Controller>(0);
  //ArrayList<Body> body = new ArrayList<Body>(0);
  MacroList macroList;
  
  World() {
    macroList = new MacroList();
  }
  
  void checkOrders() {
    for (Controller p : control) {
      if (p.checkOrders()) {return;}
    }
    //bodyOrders
  }
  
  void update() {
    for (Controller p : control) {
      p.update();
    }
    macroList.update();
    //bodyPupdate
    //bodyUpdate
  }
  
  //drawing
  void drawing() {
    fill(255);
    textSize(16);
    if (!cp5.getTab("default").isActive()) text(int(frameRate),10,height - 10 );
    if (!cp5.getTab("Macros").isActive()) {
      //for (int i = 0; i < body.size(); i++) {
      //  body.get(i).show(20, 50 + (30 * i));
      //}
      for (int i = 0; i < control.size(); i++) {
        control.get(i).drawing(20, 150 + (30 * i));
      }
    }
    macroList.drawing();
  }

  Controller addController(Controller p) {
    control.add(p);
    return p;
  }
  
  //Keyboard addKeyboard(Body b) {
  Keyboard addKeyboard() {
    int id = control.size();
    //return (Keyboard) addController(new Keyboard(this, b, id, 10 + (3 * id), 40 + (72 * id)));
    return (Keyboard) addController(new Keyboard(this, id, 30, 100 + (110 * id)));
  }
  
  GrowingControl addGrowingControl() {
    int id = control.size();
    return (GrowingControl) addController(
      new GrowingControl(this, id, 800, 100 + (100 * id)) );
  }
  
  GrowingWatcher addGrowingWatcher() {
    int id = control.size();
    return (GrowingWatcher) addController(
      new GrowingWatcher(this, id, 30, 100 + (130 * id)) );
  }
  
  //Rotator addRotator(Body b, float st) {
  //  int id = control.size();
  //  return (Rotator) addController(new Rotator(this, b, st, id, 500 + (3 * id), 40 + (72 * id)));
  //}
  
  void removeControl(Controller p) {
    control.remove(p);
  }
  
  //Body addBody(Body p) {
  //  body.add(p);
  //  return p;
  //}
  
  //void removeBody(Body p) {
  //  body.remove(p);
  //}
  
}

class Player {
  World world;
  //Body b1;
  
  //Rotator mo;
  Keyboard keyb;
  MacroVAL mv1,mv2,mv3,mv4,mv5,mv6;
  MacroDELAY md1,md2;
  GrowingControl gc;
  GrowingWatcher gw;
  
  Player(World w_) {
    world = w_;
    
    //b1 = world.addBody(new Body());
    
    gc = world.addGrowingControl();
    
    keyb = world.addKeyboard();
    mv1 = world.macroList.addMacroVAL(0.16);
    mv2 = world.macroList.addMacroVAL(0.833);
    md1 = world.macroList.addMacroDELAY(1);
    
    mv3 = world.macroList.addMacroVAL(1);
    mv4 = world.macroList.addMacroVAL(1);
    mv5 = world.macroList.addMacroVAL(2500);
    mv6 = world.macroList.addMacroVAL(5);
    md2 = world.macroList.addMacroDELAY(5);
    
    gw = world.addGrowingWatcher();

    keyb.wO.linkTo(mv1.in)
           .linkTo(md1.in);
    md1.out.linkTo(mv2.in);
    mv1.out.linkTo(gc.growI);
    mv2.out.linkTo(gc.growI);
    
    keyb.cO.linkTo(mv3.in)
           .linkTo(mv4.in)
           .linkTo(md2.in);
    md2.out.linkTo(mv5.in)
           .linkTo(mv6.in);
    mv3.out.linkTo(gc.sproutI);
    mv4.out.linkTo(gc.stopI);
    mv5.out.linkTo(gc.sproutI);
    mv6.out.linkTo(gc.stopI);
  }
  
}

//class Body {
//  float a;
//  boolean s;
  
//  Body() {
//    a=0;s=false;
//  }
  
//  void show(float x_, float y_) {
//    text("a " + a,x_,y_);
//    text("s " + s,x_+60,y_);
//  }
//}
