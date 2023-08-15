
class Base {
  
  int id;
  boolean exist;
  
  Base() {
    exist = false;
    id = 0;
  }
  
  // PERSO    ----------------
  PVector pos;
  PVector grows;
  PVector dir;
  
  // data
  //int root_id = 0;
  //int this_sprout_index = 0;
  //int sprouts_nb = 0;
  //int[] sprouts = new int[0];
  //int rang = 1;
  
  // condition de croissance
  boolean end = false;
  int sprouts = 0;
  float age = 0.0;
  
  // PERSO    ----------------
  
  void init(PVector _p, PVector _d, int _root_id) {    //argument are passed through createBase
    exist = true;
    // PERSO    ----------------
    //root_id = _root_id;
    //rang = BaseList[root_id].rang + 1;
    
    end = false;
    sprouts = 0;
    age = 0;
    
    pos = _p;
    grows = new PVector(L_MIN + random(L_MAX - L_MIN), 0);
    grows.rotate(_d.heading());
    grows.rotate(random(DEVIATION) - (DEVIATION / 2));
    dir = new PVector();
    dir = grows;
    grows = PVector.add(pos, grows);
    
     // PERSO    ----------------
  }
  
  void destroy() {
    if (exist) {
      exist = false;
      // PERSO    ----------------
      //if (id != 0 && BaseList.length > 1) {
      //  for (int i = 0 ; i < sprouts.length ; i++) 
      //    if (sprouts[i] < BaseList.length) {
      //      //BaseList[sprouts[i]].destroy();
      //  }
      //  if (root_id < BaseList.length) {
      //    //BaseList[root_id].bourgeon = 
      //    //  int(constrain(BaseList[root_id].bourgeon - 1, 1, MAX_BOURGONS + 1 ));
      //    //BaseList[root_id].sprouts = 
      //    //  subset(BaseList[root_id].sprouts, this_sprout_index);
      //  } else { exist = true; }
      //}
      // PERSO    ----------------
    }
  }
  
  void run() {
    // PERSO    ----------------
    
    age++;
    
    // grow
    if (!end && sprouts == 0 && crandom(GROW_DIFFICULTY) > 0.5) {
      createBase(grows, dir, id);
      sprouts++;
    }
    
    // sprout
    if (!end && crandom(SPROUT_DIFFICULTY) > 0.5) {
      createBase(grows, dir, id);
      sprouts++;
      //sprouts = (int[]) expand(sprouts, sprouts.length + 1);
      //sprouts[sprouts.length - 1] = temp_b.id;
      //temp_b.this_sprout_index = sprouts.length - 1;
      //sprouts_nb++;
    }
    
    // stop growing
    if (!end && sprouts == 0 && crandom(STOP_DIFFICULTY) > 0.5) {
      end = true;
    }
    
    // die
    float rng = crandom(DIE_DIFFICULTY);
    if (//rng > 1.0 - (age / MAX_AGE) ||
        rng < baseNb() / MAX_LIST_SIZE //||
        //age >= MAX_AGE
        ) {
      this.destroy();
    }
    
    // PERSO    ----------------
  }
  
  void drawing() {
    // PERSO    ----------------
    
    
    if (!end && sprouts == 0) { stroke(255, 0, 0); strokeWeight(3 / cam_scale); }
    else if (end) { stroke(0, 255, 0); strokeWeight(1 / cam_scale); }
    else { stroke(255); strokeWeight(1 / cam_scale); }
    //fill(255);
    //ellipseMode(CENTER);
    //ellipse(pos.x, pos.y, 2, 2);
    
    line(pos.x,pos.y,grows.x,grows.y);
    
    // PERSO    ----------------
  }

}

Base createFirstBase() { return createBase(new PVector(DEF_POS.x, DEF_POS.y), new PVector(1, 0).rotate(DEF_DIR), 0); }
Base createFirstBase(PVector p) { return createBase(p, new PVector(1, 0).rotate(DEF_DIR), 0); }
Base createFirstBase(float r) { return createBase(new PVector(DEF_POS.x, DEF_POS.y), new PVector(1, 0).rotate(r), 0); }
Base createFirstBase(PVector p, float r) { return createBase(p, new PVector(1, 0).rotate(r), 0); }

Base createBase(PVector p, PVector d, int id) {
  for (int i = BaseList.length-1; i >= 0; i--) {
    if (!BaseList[i].exist) {
      BaseList[i].init(p, d, id);
      return BaseList[i];
    }
  }
  
  if (BaseList.length < MAX_LIST_SIZE) {
    BaseList = (Base[]) expand(BaseList, BaseList.length + 1);
    BaseList[BaseList.length - 1] = new Base();
    BaseList[BaseList.length - 1].id = BaseList.length - 1;
    BaseList[BaseList.length - 1].init(p, d, id);
  }
  
  return BaseList[BaseList.length - 1];
}

void runAll() {
  for (int i = BaseList.length-1; i >= 0; i--) {
    if (BaseList[i].exist ) {
      BaseList[i].run();
    }
  }
}

void drawAll() {
  for (int i = BaseList.length-1; i >= 0; i--) {
    if (BaseList[i].exist ) {
      BaseList[i].drawing();
    }
  }
}

void deleteAll() {
  for (int i = BaseList.length-1; i >= 0; i--) {
    if (BaseList[i].exist) {
      BaseList[i].destroy();
    }
  }
}

int baseNb() {
  int n = 0;
  for (int i = BaseList.length-1; i >= 0; i--) {
    if (BaseList[i].exist ) {
      n++;
    }
  }
  return n;
}
