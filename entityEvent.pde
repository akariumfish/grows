
//class eventlist

abstract class EventA {//modificateur d'entité
  
}

class GrowingEvent extends EventA {
  GrowingEventParam p = new GrowingEventParam();
  void tryAction(Grower e) {
    //grow
    Grower n = e.growCom.new_Grower();
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

abstract class TryA { //test de reussite, régulé par un/des parametre, pas de valeur fixe!
  abstract boolean trying();
}

class RandomTry extends TryA { // en faire juste des methodes?
  RandomTryParam p = new RandomTryParam();
  //constructeur avec param values or object param
  boolean trying() {
    return p.ON && random(p.DIFFICULTY) > 0.5;
  }
}

//class parametersList

class ParametersA {//agregateur de parametre,
//pourras etre passer au menu pour un automenu
}

class RandomTryParam extends ParametersA {
  //constructeur avec param values
  float DIFFICULTY = 4;
  boolean ON = true;
}

class GrowingEventParam extends ParametersA {
  //constructeur avec param values
  float LENGTH = 40;
  float DEVIATION = 2;
}

class CommunityParam extends ParametersA {
  //constructeur avec param values
  int MAX_ENT = 1000; //longueur max de l'array d'objet
  int INIT_ENT = 2;
}
