

abstract class ParametersA {//agregateur de parametre,
//pourras etre passer au menu pour un automenu

}

class CommunityParam extends ParametersA {
  int MAX_ENT = 1000; //longueur max de l'array d'objet
  int INIT_ENT = 2;
  int SEED = 420;
  CommunityParam() {}
  CommunityParam(int m, int i, int s) { MAX_ENT = m; INIT_ENT = i; SEED = s; }
}

class RandomTryParam extends ParametersA {
  //constructeur avec param values
  float DIFFICULTY = 4;
  boolean ON = true;
  RandomTryParam() {}
  RandomTryParam(float d, boolean b) {DIFFICULTY = d; ON = b;}
}
