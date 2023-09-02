

class GrowerParam extends ParametersA {
  //constructeur avec param values
  float DEVIATION = 4; //drifting (rotation posible en portion de pi (PI/drift))
  float L_MIN = 1; //longeur minimum de chaque section
  float L_MAX = 100; //longeur max de chaque section MODIFIABLE PAR MENU MOVE minimum 1 , limité dans l'update de sont bp
  float L_DIFFICULTY = 4;
  int OLD_AGE = 333;
  RandomTryParam growP = new RandomTryParam(0.833, true);
  RandomTryParam sproutP = new RandomTryParam(2500, true);
  RandomTryParam stopP = new RandomTryParam(5, true);
  RandomTryParam dieP = new RandomTryParam(1.8, true);
  float MAX_LINE_WIDTH = 1.5; //epaisseur max des ligne, diminuer par l'age, un peut, se vois pas
  float MIN_LINE_WIDTH = 0.2; //epaisseur min des ligne
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
  
  Grower(GrowerComu c) { super(c); param = c.param; }
  
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
    
    //grow
    if (param.growP.ON && !end && sprouts == 0 && crandom(param.growP.DIFFICULTY) > 0.5) {
      Grower n = (Grower)com.new_Entity();
      if (n != null) {
        n.define(grows, dir);
        sprouts++;
      }
    }
    
    // sprout
    if (param.sproutP.ON && !end && crandom(param.sproutP.DIFFICULTY) > 0.5) {
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
    if (param.stopP.ON && !end && sprouts == 0 && crandom(param.stopP.DIFFICULTY) > 0.5) {
      end = true;
    }
    
    // die
    float rng = crandom(param.dieP.DIFFICULTY);
    if (param.dieP.ON && !(!end && sprouts == 0) &&
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
    if (!end && sprouts == 0) { stroke(255, 0, 0); strokeWeight(param.MAX_LINE_WIDTH+1 / cam_scale); }
    else if (end) { stroke(0, ca, 0); strokeWeight((param.MAX_LINE_WIDTH+1) / cam_scale); }
    else { stroke(ca, ca, ca); strokeWeight(((float)param.MIN_LINE_WIDTH + ((float)param.MAX_LINE_WIDTH * (float)ca / 255.0)) / cam_scale); }              
    
    line(pos.x,pos.y,grows.x,grows.y);
    
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
  }
  
  Grower build() { return new Grower(this); }
}
