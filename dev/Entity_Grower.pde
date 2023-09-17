// ici on definie les structure de type grower



class RandomTryParam {
  //constructeur avec param values
  float DIFFICULTY = 4;
  boolean ON = true;
  RandomTryParam() {}
  RandomTryParam(float d, boolean b) {DIFFICULTY = d; ON = b;}
  
  void save_to(SavableValueTree t, String name, String nodeName) {
    t.add("randomtryparam\t" + name, nodeName);
    t.add(name + "difficulty\t", DIFFICULTY, "randomtryparam\t" + name);
    t.add(name + "on\t", ON, "randomtryparam\t" + name);
  }
}

class GrowerParam {
  //constructeur avec param values
  float DEVIATION = 8; //drifting (rotation posible en portion de pi (PI/drift))
  float L_MIN = 2; //longeur minimum de chaque section
  float L_MAX = 35; //longeur max de chaque section MODIFIABLE PAR MENU MOVE minimum 1 , limité dans l'update de sont bp
  float L_DIFFICULTY = 180;
  int OLD_AGE = 666;
  int TEEN_AGE = OLD_AGE / 20;
  RandomTryParam growP = new RandomTryParam(0.5, true);
  RandomTryParam sproutP = new RandomTryParam(2080, true);
  RandomTryParam stopP = new RandomTryParam(1.25, true);
  RandomTryParam dieP = new RandomTryParam(3.6, true);
  float MAX_LINE_WIDTH = 1.5; //epaisseur max des ligne, diminuer par l'age, un peut, se vois pas
  float MIN_LINE_WIDTH = 0.2; //epaisseur min des ligne
  void save_to(SavableValueTree t, String name) {
    t.add("growerparam\t" + name);
    growP.save_to(t, name + "grow", "growerparam\t" + name);
    sproutP.save_to(t, name + "sprout", "growerparam\t" + name);
    stopP.save_to(t, name + "stop", "growerparam\t" + name);
    dieP.save_to(t, name + "die", "growerparam\t" + name);
    t.add(name + "DEVIATION\t", DEVIATION, "growerparam\t" + name);
    t.add(name + "L_MIN\t", L_MIN, "growerparam\t" + name);
    t.add(name + "L_MAX\t", L_MAX, "growerparam\t" + name);
    t.add(name + "L_DIFFICULTY\t", L_DIFFICULTY, "growerparam\t" + name);
    t.add(name + "OLD_AGE\t", OLD_AGE, "growerparam\t" + name);
  }
}

class Grower extends Entity {
  PVector pos = new PVector();
  PVector grows = new PVector();
  PVector dir = new PVector();
  
  GrowerParam param;
  
  // condition de croissance
  boolean end = false;
  int sprouts = 0;
  float age = 0.0;
  float start = 0.0;
  
  Grower(GrowerComu c) { super(c); param = c.param;
    
  }
  
  Grower define(PVector _p, PVector _d) {
    pos = _p;
    grows = new PVector(param.L_MIN + crandom(param.L_DIFFICULTY)*(param.L_MAX - param.L_MIN), 0);
    grows.rotate(_d.heading());
    grows.rotate(random(PI / param.DEVIATION) - ((PI / param.DEVIATION) / 2));
    dir = new PVector();
    dir = grows;
    grows = PVector.add(pos, grows);
    return this;
  }
  
  Grower run() {
    age++;
    if (age < param.TEEN_AGE) {
      start = (float)age / (float)param.TEEN_AGE;
    } else start = 1;
    
    //grow
    if (param.growP.ON && start == 1 && !end && sprouts == 0 && crandom(param.growP.DIFFICULTY) > 0.5) {
      Grower n = (Grower)com.new_Entity();
      if (n != null) {
        n.define(grows, dir);
        sprouts++;
      }
    }
    
    // sprout
    if (param.sproutP.ON && start == 1 && !end && crandom(param.sproutP.DIFFICULTY) > 0.5) {
      Grower n = (Grower)com.new_Entity();
      if (n != null) {
        PVector _p = new PVector(0, 0);
        PVector _d = new PVector(0, 0);
        _d.add(grows).sub(pos);
        _d.setMag(random(1.0) * _d.mag());
        _p.add(pos).add(_d);
        n.define(_p, _d);
        sprouts++;
      }
      //sprouts = (int[]) expand(sprouts, sprouts.length + 1);
      //sprouts[sprouts.length - 1] = temp_b.id;
      //temp_b.this_sprout_index = sprouts.length - 1;
      //sprouts_nb++;
    }
    
    // stop growing
    if (param.stopP.ON && start == 1 && !end && sprouts == 0 && crandom(param.stopP.DIFFICULTY) > 0.5) {
      end = true;
    }
    
    // die
    float rng = crandom(param.dieP.DIFFICULTY);
    if (param.dieP.ON && start == 1 && !(!end && sprouts == 0) &&
         (rng > ( (float)param.OLD_AGE / (float)age ) //||
          //rng / DIE_DIFFICULTY_DIVIDER > ((float)MAX_LIST_SIZE - (float)baseNb()) / (float)MAX_LIST_SIZE
       )) {
      this.destroy();
    }
    
    return this;
  }
  Grower drawing() {
    // aging color
    int ca = 255;
    if (age > param.OLD_AGE / 2) ca = (int)constrain(255 + int(param.OLD_AGE/2) - int(age/1.2), 90, 255);
    //if (!end && sprouts == 0) { stroke(255, 0, 0); strokeWeight(param.MAX_LINE_WIDTH+1 / cam_scale); } //BIG red head
    if (!end && sprouts == 0) { stroke(255); strokeWeight((param.MAX_LINE_WIDTH+1) / cam_scale); }
    else if (end) { stroke(0, ca, 0); strokeWeight((param.MAX_LINE_WIDTH+1) / cam_scale); }
    else { stroke(ca, ca, ca); strokeWeight(((float)param.MIN_LINE_WIDTH + ((float)param.MAX_LINE_WIDTH * (float)ca / 255.0)) / cam_scale); }              
    
    PVector e = new PVector(dir.x, dir.y);
    if (start < 1) e = e.setMag(e.mag() * start);
    e = e.add(pos);
    line(pos.x,pos.y,e.x,e.y);
    
    //line(pos.x,pos.y,grows.x,grows.y);
    
    //DEBUG
    //fill(255); ellipseMode(CENTER);
    //ellipse(pos.x, pos.y, 2, 2);
    //strokeWeight(MAX_LINE_WIDTH+1 / cam_scale);
    //point(grows.x,grows.y);
    return this;
  }
  Grower init() {
    end = false;
    sprouts = 0;
    age = 0;
    start = 0.0;
    return this;
  }
  Grower clear() { return this; }
  Grower randomize() { define( new PVector(0, 0), new PVector(1, 0).rotate(random(PI * 2)) ); return this; }
  
  //void to_strings() {
  //  file.append("base:");
  //  file.append(str(id));
  //  file.append(str(exist));
  //  file.append(str(pos.x));
  //  file.append(str(pos.y));
  //  file.append(str(grows.x));
  //  file.append(str(grows.y));
  //  file.append(str(dir.x));
  //  file.append(str(dir.y));
  //  file.append(str(end));
  //  file.append(str(sprouts));
  //  file.append(str(age));
  //}
}

class GrowerComu extends Community {
  
  GrowerParam param;
  
  GrowerComu(ComunityList _c) {
    super(_c);
    param = new GrowerParam();
    init();
    //SavableValueTree t = new SavableValueTree("test");
    //param.save_to(t, "param");
    //t.save_to_file("text.txt");
  }
  
  Grower build() { return new Grower(this); }
}
