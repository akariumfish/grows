

//#######################################################################
//##                         METHODES UTILES                           ##
//#######################################################################


float distancePointToLine(float x, float y, float x1, float y1, float x2, float y2) {
  float r =  ( ((x-x1)*(x2-x1)) + ((y-y1)*(y2-y1)) ) / pow(distancePointToPoint(x1, y1, x2, y2), 2);
  if (r <= 0) {return distancePointToPoint(x1, y1, x, y);}
  if (r >= 1) {return distancePointToPoint(x, y, x2, y2);}
  float px = x1 + (r * (x2-x1));
  float py = y1 + (r * (y2-y1));
  return distancePointToPoint(x, y, px, py);
}

float distancePointToPoint(float xa, float ya, float xb, float yb) {
  return sqrt( pow((xb-xa), 2) + pow((yb-ya), 2) );
}

float distancePointToPoint(PVector v1, PVector v2) {
  return distancePointToPoint(v1.x, v1.y, v2.x, v2.y);
}

float crandom(float d) {
  return pow(random(1.0), d) ;
}

/* crandom results :
difficulty   nb > 0.5 pour 1000
       0.04 999
       0.08 999
       0.16 986
       0.32 885
       0.64 661
       1.28 418
       2.56 236
       5.12 126
      10.24 65
      20.48 33
      40.96 16
      81.92 8
     163.84 4
     327.68 2
     655.36 1
    1310.72 0
    2621.44 0
*/

// auto indexing
int used_index = 0;
int get_free_id() { used_index++; return used_index - 1; }

// gestion des polices de caractére
ArrayList<myFont> existingFont = new ArrayList<myFont>();
class myFont { PFont f; int st; }
PFont getFont(int st) {
  for (myFont f : existingFont) if (f.st == st) return f.f;
  myFont f = new myFont();
  f.f = createFont("Arial",st); f.st = st;
  return f.f; }
//for (String s : PFont.list()) println(s); // liste toute les police de text qui existe



//#######################################################################
//##                         CALLABLE CLASS                            ##
//#######################################################################

ArrayList<Callable> callables = new ArrayList<Callable>();
void callChannel(Channel chan, float val) {
  for (Callable c : callables) for (Channel i : c.chan) 
    if (i == chan) c.answer(chan, val); }
void callChannel(Channel chan) { callChannel(chan, 0); }
void callChannel(Channel[] chan, float val) {
  for (Channel c : chan) callChannel(c, val); }
class Channel {}
abstract class Callable {
  Channel[] chan = new Channel[0];
  Callable() { callables.add(this); }
  Channel[] getChannel() { return chan; }
  void setChannel(Channel[] c) { chan = c; }
  void addChannel(Channel c) { chan = (Channel[])append(chan, c); }
  void clearChannel() { chan = new Channel[0]; }
  abstract void answer(Channel channel, float value); }



//#######################################################################
//##                         WATCHABLE VALUE                           ##
//#######################################################################

abstract class WatchableValue {
  ArrayList<Channel> watchers = new ArrayList<Channel>();
  void addWatcher(Channel c) { watchers.add(c); }
}

class WatchableFloat extends WatchableValue {
  private float value = 0;
  WatchableFloat() {}
  WatchableFloat(float v) { value = v; }
  void set( float v) {
    if (v != value) for (Channel c : watchers) callChannel(c, v);
    value = v;
  }
  float get() { return value; }
}

class WatchableBool extends WatchableValue {
  private boolean value = false;
  WatchableBool() {}
  WatchableBool(boolean v) { value = v; }
  void set( boolean v) {
    if (v != value) for (Channel c : watchers) if (v) callChannel(c, 1); else callChannel(c, 0);
    value = v;
  }
  boolean get() { return value; }
}



//#######################################################################
//##                         RUNNABLE EXEMPLE                          ##
//#######################################################################

ArrayList<Runnable> runs = new ArrayList<Runnable>();
void new_runnable() {
  runs.add(new Runnable() { public void run() {
    //run
  }});
}
void post() {
  Iterator<Runnable> it = runs.iterator();
  while (it.hasNext ()) {
    it.next().run();
    it.remove();
  }
}
