


class Event { //modificateur d'entité, conditionné par un objet try
  void tryAction(Entity e, Parameters p) {
    //grow
    if (p.ON && random(p.DIFFICULTY) > 0.5) {
      Entity n = new_Entity(e.list, e.grows, e.dir);
      if (n != null) {
        n.pos = e.grows;
        n.grows = new PVector(p.LENGTH, 0);
        n.grows.rotate(e.grows.heading());
        n.grows.rotate(random(PI / p.DEVIATION) - ((PI / p.DEVIATION) / 2));
        n.dir = new PVector();
        n.dir = n.grows;
        n.grows = PVector.add(n.pos, n.grows);
      }
    }
  }
}

class Try { //test de reussite, régulé par un/des parametre, pas de valeur fixe!
  boolean get() {
    return false;
  }
}

class Parameters {//agregateur de parametre,
//pourras etre passer au menu pour un automenu
  float DIFFICULTY = 4;
  boolean ON = true;
  //-----CUT IT IN TWO OBJECT HERE-------
  float LENGTH = 40;
  float DEVIATION = 1;
}
