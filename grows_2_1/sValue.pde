


//#######################################################################
//##                         SPECIAL VALUE                             ##
//#######################################################################


class SpecialValue {
  ArrayList<sInt> sintlist = new ArrayList<sInt>();
  ArrayList<sFlt> sfltlist = new ArrayList<sFlt>();
  ArrayList<sBoo> sboolist = new ArrayList<sBoo>();
  void unFlagChange() {
    for (sInt i : sintlist) i.has_changed = false;
    for (sFlt i : sfltlist) i.has_changed = false;
    for (sBoo i : sboolist) i.has_changed = false; }
}


class sInt {
  boolean has_changed = false;
  SpecialValue save;
  int val = 0;
  int id = 0;
  
  //Channel on_change = new Channel();
  //void tick() { if (has_changed) callChannel(on_change, float(val)); has_changed = false; }
  
  sInt(SpecialValue s, int v) { save = s; val = v; id = save.sintlist.size(); save.sintlist.add(this); }
  int get() { return val; }
  void set(int v) { if (v != val) has_changed = true; val = v; }
}

class sFlt {
  boolean has_changed = false;
  SpecialValue save;
  float val = 0;
  int id = 0;
  sFlt(SpecialValue s, float v) { save = s; val = v; id = save.sfltlist.size(); save.sfltlist.add(this); }
  float get() { return val; }
  void set(float v) { if (v != val) has_changed = true; val = v; }
}

class sBoo {
  boolean has_changed = false;
  SpecialValue save;
  boolean val = false;
  int id = 0;
  sBoo(SpecialValue s, boolean v) { save = s; val = v; id = save.sboolist.size(); save.sboolist.add(this); }
  boolean get() { return val; }
  void set(boolean v) { if (v != val) { has_changed = true; val = v; } }
}



//#######################################################################
//##                        SAVING N LOADING                           ##
//#######################################################################


void saving(SpecialValue sv, String file) {
  String[] sl = new String[sv.sintlist.size() + sv.sfltlist.size() + sv.sboolist.size()];
  //for (String s : sl) s = new String(); //??maybe useless?
  for (sInt i : sv.sintlist) {
    sl[i.id] = str(i.get());
  }
  for (sFlt i : sv.sfltlist) {
    sl[sv.sintlist.size() + i.id] = str(i.get());
  }
  for (sBoo i : sv.sboolist) {
    sl[sv.sintlist.size() + sv.sfltlist.size() + i.id] = str(i.get());
  }
  saveStrings(file, sl);
}
void loading(SpecialValue s, String file) {
  String[] sl = loadStrings(file);
  if (sl.length != s.sintlist.size() + s.sfltlist.size() + s.sboolist.size()) return;
  for (sInt i : s.sintlist) {
    i.set(int(sl[i.id]));
  }
  for (sFlt i : s.sfltlist) {
    i.set(float(sl[s.sintlist.size() + i.id]));
  }
  for (sBoo i : s.sboolist) {
    i.set(boolean(sl[s.sintlist.size() + s.sfltlist.size() + i.id]));
  }
}
