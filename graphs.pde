//permet l'enregistrement de donné pour le graphique
int larg =             1600;
int[] graph  = new int[1600];
int[] graph2 = new int[1600];
int gc = 0;

boolean SHOW_GRAPH = false;// affichage du graph a un bp

void init_graphs() {
  //initialisation des array des graph
  for (int i = 0; i < larg; i++) { graph[i] = 0; graph2[i] = 0; }
}

void draw_graphs() {
  if (SHOW_GRAPH) {
    strokeWeight(0.5);
    stroke(255);
    for (int i = 1; i < larg; i++) if (i != gc) {
      stroke(255);
      line( (i-1), height - 10 - (graph[(i-1)] * (height-20) / 5000) ,
            i, height - 10 - (graph[i] * (height-20) / 5000) );
      stroke(255, 255, 0);
      line( (i-1), height - 10 - (graph2[(i-1)] * (height-20) / 80) ,
            i, height - 10 - (graph2[i] * (height-20) / 80) );
    }
    stroke(255, 0, 0);
    strokeWeight(7);
    if (gc != 0) {
      point(gc-1, height - 10 - (graph[gc-1] * (height-20) / 5000) );
      point(gc-1, height - 10 - (graph2[gc-1] * (height-20) / 80) );
    }
  }
}

void update_graph() {
  //enregistrement des donner dans les array
  graph[gc] = baseNb();
  graph2[gc] = growsNb();
  if (gc < larg-1) gc++; else gc = 0;
}
