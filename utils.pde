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

float crandom(float d) {
  return pow(random(1.0), d) ;
}

/*

crandom results :
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
