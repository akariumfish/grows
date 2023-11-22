

//ArrayList<Test> builderlist = new ArrayList<Test>();

//void mysetup() {
  
//}

//class Test {
//  Test() {
//  }
//  void to_string(String[] s, int id) {}
//  void from_string(String[] s, int id) {}
//  void clear() {}
//  int size() { return 0; }
//}


//void save(String file, ArrayList<Test> tl) {
//  String[] sl = new String[tl.size()];
//  int id = 0;
//  sl[0] = str(tl.size());
//  id++;
//  for (Test v : tl) {
//    v.to_string(sl, id);
//    id += v.size();
//  }
//  saveStrings(file, sl);
//}

//void load(String file, ArrayList<Test> tl) {
//  for (Test t : tl) t.clear();
//  tl.clear();
//  String[] sl = loadStrings(file);
//  int id = 1;
//  for (int i = 1; i < int(sl[0]) ; i++) {
//    Test t = new Test();
//    tl.add(t);
//    t.from_string(sl, id);
//    id += t.size();
//  }
//}




//class Save extends sObject {
//  ArrayList<Builder> builderlist = new ArrayList<Builder>();
//  Save save;
  
//  Save() { 
//    super(null);
//    save = this;
//    new Builder("OBJ") { sValue build() { return new sObject(save); } };
//    new Builder("INT") { sValue build() { return new Int(); } };
//  }
//  void to_string(String[] s, int id) {}
//  void from_string(String[] s, int id) {}
//  void clear() {}
  
//  class Builder { 
//    String type; 
//    Builder(String t) { type = t; builderlist.add(this); } 
//    sValue build() { return null; }
//  }
  
//  ArrayList<sValue> list = new ArrayList<sValue>();
//  int size() {
//    int vnb = 2;
//    for (sValue v : list) vnb += v.size();
//    return vnb;
//  }
//  sValue builder(String s) {
//    for (Builder b : builderlist) if (b.type.equals(s)) return b.build();
//    return null;
//  }
//  void save(String file) {
//    String[] sl = new String[size()];
//    int id = 0;
//    sl[0] = str(size());
//    id++;
//    for (sValue v : list) {
//      v.to_string(sl, id);
//      id += v.size();
//    }
//    saveStrings(file, sl);
//  }
  
//  void load(String file) {
//    for (sValue v : list) v.clear();
//    String[] sl = loadStrings(file);
//    int idend = int(sl[0]);
//    int id = 1;
//    for (sValue v : list) v.clear();
//    list.clear();
//    while (id < idend) {
//      sValue o = builder(sl[id]);
//      if (o != null) {
//        list.add(o);
//        o.from_string(sl, id);
//        id += o.size();
//      }
//    }
//  }
//}


//class Int extends sValue {
//  int val = 0;
//  Int(sObject s) { super(s, "INT"); }
//  void to_string(String[] s, int id) { s[id] = "INT"; s[id+1] = str(val); }
//  void from_string(String[] s, int id) { if (s[id].equals("INT")) val = int(s[id+1]); }
//  void clear() { val = 0; }
//  int size() { return 2; }
//}

//abstract class sValue { //one line data
//  String type;
//  sObject parent;
//  sValue(sObject s, String t) { parent = s; type = t; }
//  abstract void to_string(String[] s, int id); // I put myself in s at id
//  abstract void from_string(String[] s, int id);
//  abstract void clear();
//  abstract int size();
//  sValue builder(String s) { return parent.builder(s); }
//}


//class sObject extends sValue {
//  ArrayList<sValue> list = new ArrayList<sValue>();
  
//  sObject(sObject s) { super(s, "OBJ");  }
//  int size() {
//    int vnb = 2;
//    for (sValue v : list) vnb += v.size();
//    return vnb;
//  }
//  void to_string(String[] s, int id) {
//    s[id] = "OBJ";
//    id++;
//    s[id] = str(size());
//    id++;
//    for (sValue v : list) {
//      v.to_string(s, id);
//      id += v.size();
//    }
//  }
//  void from_string(String[] s, int id) {
//    if (s[id].equals("OBJ")) {
//      id++;
//      int idend = id + int(s[id]); // nb d'objet
//      id++;
//      clear();
//      while (id < idend) {
//        sValue o = builder(s[id]);
//        if (o != null) {
//          list.add(o);
//          o.from_string(s, id);
//          id += o.size();
//        }
//      }
//    }
//  }
//  void clear() {
//    for (sValue v : list) v.clear();
//    list.clear();
//  }
//}




//class sInt {
//  boolean has_changed = false;
//  SpecialValue save;
//  int val = 0;
//  int id = 0;
//  String name = "int";
//  sInt(SpecialValue s, int v) { save = s; val = v; id = save.sintlist.size(); save.sintlist.add(this); }
//  sInt(SpecialValue s, int v, String n) { name = n; save = s; val = v; id = save.sintlist.size(); save.sintlist.add(this); }
//  int get() { return val; }
//  void set(int v) { if (v != val) has_changed = true; val = v; }
//}

//class sFlt {
//  boolean has_changed = false;
//  SpecialValue save;
//  float val = 0;
//  int id = 0;
//  String name = "flt";
//  sFlt(SpecialValue s, float v) { save = s; val = v; id = save.sfltlist.size(); save.sfltlist.add(this); }
//  sFlt(SpecialValue s, float v, String n) { name = n; save = s; val = v; id = save.sfltlist.size(); save.sfltlist.add(this); }
//  float get() { return val; }
//  void set(float v) { if (v != val) has_changed = true; val = v; }
//}

//class sBoo {
//  boolean has_changed = false;
//  SpecialValue save;
//  boolean val = false;
//  int id = 0;
//  String name = "boo";
//  sBoo(SpecialValue s, boolean v) { save = s; val = v; id = save.sboolist.size(); save.sboolist.add(this); }
//  sBoo(SpecialValue s, boolean v, String n) { name = n; save = s; val = v; id = save.sboolist.size(); save.sboolist.add(this); }
//  boolean get() { return val; }
//  void set(boolean v) { if (v != val) { has_changed = true; val = v; } }
//}

//class sVec {
//  boolean has_changed = false;
//  SpecialValue save;
//  PVector val = new PVector();
//  int id = 0;
//  String name = "vec";
//  sVec(SpecialValue s, PVector v) { save = s; val = v; id = save.sveclist.size(); save.sveclist.add(this); }
//  sVec(SpecialValue s, PVector v, String n) { name = n; save = s; val = v; id = save.sveclist.size(); save.sveclist.add(this); }
//  PVector get() { return new PVector(val.x, val.y); }
//  void set(PVector v) { if (v.x != val.x || v.y != val.y) { has_changed = true; val.x = v.x; val.y = v.y; } }
//}

//class sStr {
//  boolean has_changed = false;
//  SpecialValue save;
//  String val = new String();
//  int id = 0;
//  String name = "str";
//  sStr(SpecialValue s, String v) { save = s; val = v; id = save.sstrlist.size(); save.sstrlist.add(this); }
//  sStr(SpecialValue s, String v, String n) { name = n; save = s; val = v; id = save.sstrlist.size(); save.sstrlist.add(this); }
//  String get() { return new String(val); }
//  void set(String v) { if (!v.equals(val)) { has_changed = true; val = v; } }
//}



//#######################################################################
//##                        SAVING N LOADING                           ##
//#######################################################################


//int SV_start_bloc = 3;

//void saving(SpecialValue sv, String file) {
//  String[] sl = new String[SV_start_bloc + sv.sintlist.size() + sv.sfltlist.size() + sv.sboolist.size()];
//  sl[0] = str(sv.sintlist.size());
//  sl[1] = str(sv.sfltlist.size());
//  sl[2] = str(sv.sboolist.size());
//  for (sInt i : sv.sintlist) {
//    sl[SV_start_bloc + i.id] = str(i.get());
//  }
//  for (sFlt i : sv.sfltlist) {
//    sl[SV_start_bloc + sv.sintlist.size() + i.id] = str(i.get());
//  }
//  for (sBoo i : sv.sboolist) {
//    sl[SV_start_bloc + sv.sintlist.size() + sv.sfltlist.size() + i.id] = str(i.get());
//  }
//  saveStrings(file, sl);
//}
//void loading(SpecialValue s, String file) {
  
//  String[] sl = loadStrings(file);
  
//  int intlsize = int(sl[0]);
//  int fltlsize = int(sl[1]);
//  int boolsize = int(sl[2]);
  
//  if (intlsize != s.sintlist.size()) return;
//  if (fltlsize != s.sfltlist.size()) return;
//  if (boolsize != s.sboolist.size()) return;
//  if (sl.length < SV_start_bloc + intlsize + fltlsize + boolsize) return;
  
//  for (sInt i : s.sintlist) {
//    i.set(int(sl[SV_start_bloc + i.id]));
//  }
//  for (sFlt i : s.sfltlist) {
//    i.set(float(sl[SV_start_bloc + s.sintlist.size() + i.id]));
//  }
//  for (sBoo i : s.sboolist) {
//    i.set(boolean(sl[SV_start_bloc + s.sintlist.size() + s.sfltlist.size() + i.id]));
//  }
//}
