PImage cielTexture;
PShape cielBoite;
PImage desertTexture;
PImage solTexture;
PShape desertBoite;
PShape voiture;
PShape voiture2;
ArrayList<PVector> pointsControle; 
PImage goudron;

//animations de voiture
PVector posVoiture1 = new PVector(0.,0.); 
float vitesseVoiture1 = 0.005; //valeur arbitraire
boolean etatJeu = false; //si false le jeu n'est pas en cours, true sinon
float car1X, car1Z;
float car2X, car2Z;

//booleéns pour stocker quand la touche est appuyée puis relachée 
boolean toucheZ;
boolean toucheQ;
boolean toucheS;
boolean toucheD;
boolean modeNuit = false;

PVector posVoiture2 = new PVector(2.,0.5);
float vitesseVoiture2 = 0.004;

PVector calculerPointSurCourbe(float px){
  float posMod = px % 4.;
  if (posMod < 0){ posMod += 4.;}
  
  int segment = floor(posMod);
  float t = posMod - segment;
  
  int i = segment*3;
  PVector p0 = pointsControle.get(i);
  PVector p1 = pointsControle.get((i+1)%12);
  PVector p2 = pointsControle.get((i+2)%12);
  PVector p3 = pointsControle.get((i+3)%12);
  
  float x = bezierPoint(p0.x, p1.x, p2.x, p3.x, t);
  float z = bezierPoint(p0.z, p1.z, p2.z, p3.z, t);

  return new PVector(x,200,z); //y=200 => sol de la route
 
}

void setup(){
  size(1920,1080,P3D);
  
  cielTexture = loadImage("ressources/desert.png"); //pour charger le desert, remplacer cube.jpeg par desert.png
  voiture = loadShape("ressources/Car.obj");
  voiture2 = loadShape("ressources/Car.obj");
  creerCircuit();
  
  //code pour l'effet de texture
  goudron = createImage(256,256,RGB); //creation d'une image vide
  goudron.loadPixels();
  int n = goudron.pixels.length;
  
  for(int i = 0; i < n; i++){
    int x = i % 256;
    int y = i / 256;
    float texture = random(0,100);
    boolean rouge = (y/32)%2 == 0;
    boolean ligneBlanche = (y/32)%2 == 0;
    color couleurBord;
    if (rouge){
      couleurBord = color(255,0,0);
    } else {
      couleurBord = color(255); //couleur blanc
    }
    
    if (x < 20 || x > 235){
      goudron.pixels[i] = couleurBord;
    } else if (x > 125 && x < 131){
      if (ligneBlanche){
        goudron.pixels[i] = color(255);
      } else {
        goudron.pixels[i] = color(texture);
      }
    } else {
      goudron.pixels[i] = color(texture);
    }
  }
  goudron.updatePixels();
  
  solTexture = loadImage("ressources/desert.png");
  creerCircuit();
  
  
}

//ajout des points pour créer les courbes de bézier
void creerCircuit(){
  pointsControle = new ArrayList<>();
  
  pointsControle.add(new PVector(-1200,200,0));
  pointsControle.add(new PVector(-1200,200,-1200));
  pointsControle.add(new PVector(-300,200,-300));
  pointsControle.add(new PVector(0,200,-300));
  
  pointsControle.add(new PVector(300,200,-300));
  pointsControle.add(new PVector(1200,200,-1200));
  pointsControle.add(new PVector(1200,200,0));
  
  pointsControle.add(new PVector(1200,200,1200));
  pointsControle.add(new PVector(300,200,300));
  pointsControle.add(new PVector(0,200,300));
  
  pointsControle.add(new PVector(-300,200,300));
  pointsControle.add(new PVector(-1200,200,1200));
}

//tracage du circuit 
void trace(){
  noFill();
  stroke(255);
  strokeWeight(5);
  bezierDetail(50);
  
  beginShape();
  PVector p0 = pointsControle.get(0);
  vertex(p0.x,p0.y,p0.z);

  //segment 1
  bezierVertex(pointsControle.get(1).x, pointsControle.get(1).y, pointsControle.get(1).z, 
               pointsControle.get(2).x, pointsControle.get(2).y, pointsControle.get(2).z, 
               pointsControle.get(3).x, pointsControle.get(3).y, pointsControle.get(3).z);
               
  //segment 2
  bezierVertex(pointsControle.get(4).x, pointsControle.get(4).y, pointsControle.get(4).z, 
               pointsControle.get(5).x, pointsControle.get(5).y, pointsControle.get(5).z, 
               pointsControle.get(6).x, pointsControle.get(6).y, pointsControle.get(6).z);
               
  //segment 3
  bezierVertex(pointsControle.get(7).x, pointsControle.get(7).y, pointsControle.get(7).z, 
               pointsControle.get(8).x, pointsControle.get(8).y, pointsControle.get(8).z, 
               pointsControle.get(9).x, pointsControle.get(9).y, pointsControle.get(9).z);
               
  //segment 4
  bezierVertex(pointsControle.get(10).x, pointsControle.get(10).y, pointsControle.get(10).z, 
               pointsControle.get(11).x, pointsControle.get(11).y, pointsControle.get(11).z, 
               p0.x, p0.y, p0.z);

  endShape();
}
 
void route(){
  float largeurRoute = 130; //valeur arbitraire
  int detail = 150; //nombre de carrés pour dessiner le virage
  
  fill(80); //couleurs gris
  noStroke();
  
  //chargement de la texture
  textureMode(NORMAL);
  textureWrap(REPEAT); //on autorise la texture a se répéter 
  
  beginShape(QUADS);
  texture(goudron);
  for (int i = 0; i < 12; i+= 3){
    PVector p0 = pointsControle.get(i);
    PVector p1 = pointsControle.get((i+1)%12);
    PVector p2 = pointsControle.get((i+2)%12);
    PVector p3 = pointsControle.get((i+3)%12);
    
    for (int j = 0; j < detail; j++) {
      float t1 = j / (float)detail;
      float t2 = (j + 1) / (float)detail;
      
      float x1 = bezierPoint(p0.x, p1.x, p2.x, p3.x, t1);
      float z1 = bezierPoint(p0.z, p1.z, p2.z, p3.z, t1);
      
      float x2 = bezierPoint(p0.x, p1.x, p2.x, p3.x, t2);
      float z2 = bezierPoint(p0.z, p1.z, p2.z, p3.z, t2);
      
      float tx1 = bezierTangent(p0.x, p1.x, p2.x, p3.x, t1);
      float tz1 = bezierTangent(p0.z, p1.z, p2.z, p3.z, t1);
      
      float tx2 = bezierTangent(p0.x, p1.x, p2.x, p3.x, t2);
      float tz2 = bezierTangent(p0.z, p1.z, p2.z, p3.z, t2);
      
      float mag1 = sqrt(tx1*tx1 + tz1*tz1);
      float nx1 = -tz1 / mag1;
      float nz1 = tx1 / mag1;
      
      float mag2 = sqrt(tx2*tx2 + tz2*tz2);
      float nx2 = -tz2 / mag2;
      float nz2 = tx2 / mag2;
      
      float demi = largeurRoute / 2;
      
      float g1x = x1 + nx1 * demi; float g1z = z1 + nz1 * demi;
      float d1x = x1 - nx1 * demi; float d1z = z1 - nz1 * demi;
      
      float g2x = x2 + nx2 * demi; float g2z = z2 + nz2 * demi;
      float d2x = x2 - nx2 * demi; float d2z = z2 - nz2 * demi;
      
      float repetitions = 10.;
      float v1 = t1*repetitions;
      float v2 = t2*repetitions;
      
      vertex(g1x, 199, g1z, 0, v1); 
      vertex(d1x, 199, d1z, 1, v1); 
      vertex(d2x, 199, d2z, 1, v2); 
      vertex(g2x, 199, g2z, 0, v2); 
    }
  }
  endShape();
}

void drawMap(float sideSize){
  float size = sideSize/2;
  fill(255);
  noStroke();
  textureMode(NORMAL);
  
  beginShape(QUADS);
  texture(cielTexture);

  //face avant 
  vertex(-size, -size, -size, 1/4., 1/3.);
  vertex(size, -size, -size, 2/4., 1/3.);
  vertex(size, size, -size, 2/4., 2/3.);
  vertex(-size, size, -size, 1/4., 2/3.);
  
  //face arriere 
  vertex(size, -size, size, 3/4., 1/3.);
  vertex(-size, -size, size, 1., 1/3.);
  vertex(-size, size, size, 1., 2/3.);
  vertex(size, size, size, 3/4., 2/3.);
  
  //face gauche
  vertex(-size, -size, size, 0., 1/3.);
  vertex(-size, -size, -size, 1/4., 1/3.);
  vertex(-size, size, -size, 1/4.,2/3.);
  vertex(-size, size, size, 0., 2/3.);
  
  //face droite
  vertex(size, -size, -size, 2/4., 1/3.);
  vertex(size, -size, size, 3/4., 1/3.);
  vertex(size, size, size, 3/4., 2/3.);
  vertex(size, size, -size, 2/4., 2/3.);

  //face haut   
  vertex(-size, -size, size, 1/4., 0.);
  vertex(size, -size, size, 2/4., 0.);
  vertex(size, -size, -size, 2/4., 1/3.);
  vertex(-size, -size, -size, 1/4., 1/3.);
  
  //face bas 
  vertex(-size, size, -size, 1/4., 2/3.);
  vertex(size, size, -size, 2/4., 2/3.);
  vertex(size, size, size, 2/4., 1.);
  vertex(-size, size, size, 1/4., 1.);
  
  endShape();
}

void draw(){
  
  posVoiture2.x += 0.005;

  if (!etatJeu){ //mode menu
    posVoiture1.x += 0.005;
  } else { //mode jeu
    if (toucheZ){
      vitesseVoiture1 += 0.0001; //0.003 va trop vite
      
      //limitation de vitesse 
      if (vitesseVoiture1 > 0.016){
          vitesseVoiture1 = 0.016;
      }
    }
    if (toucheQ){
      posVoiture1.y -= 0.03;
      if (posVoiture1.y < -1.){posVoiture1.y = -1.;}
    }
      
    if (toucheS){
      vitesseVoiture1 -= 0.0003;
      if (vitesseVoiture1 < 0){ vitesseVoiture1 = 0;}
    }
    if (toucheD){
      posVoiture1.y += 0.03;
      if (posVoiture1.y > 1.){ posVoiture1.y = 1.;}
    }
    
    posVoiture1.x += vitesseVoiture1;
    
    if (!toucheZ){ //on reduit la vitesse lorsqu'on appuie pas sur Z pour donner un effet de friction
      vitesseVoiture1 *= 0.96;
    }
    
 }
  
  //creation de la voiture 1
  PVector centreV1 = calculerPointSurCourbe(posVoiture1.x);
  PVector devantV1 = calculerPointSurCourbe(posVoiture1.x + 0.1);
  
  float dirX1 = devantV1.x - centreV1.x;
  float dirZ1 = devantV1.z - centreV1.z;
  
  float mag1 = sqrt(dirX1*dirX1 + dirZ1*dirZ1);
  dirX1 = dirX1/mag1;
  dirZ1 = dirZ1/mag1;
  
  //calcul du vecteur orthogonal 
  float orthoX1 = -dirZ1;
  float orthoZ1 = dirX1;
  
  car1X = centreV1.x + orthoX1 * 60 * posVoiture1.y;
  car1Z = centreV1.z + orthoZ1 * 60 * posVoiture1.y;
  
  float angleV1 = atan2(dirX1, dirZ1);
 
  //creation de la voiture 2
  PVector centreV2 = calculerPointSurCourbe(posVoiture2.x);
  PVector devantV2 = calculerPointSurCourbe(posVoiture2.x + 0.1);
  
  float dirX2 = devantV2.x - centreV2.x;
  float dirZ2 = devantV2.z - centreV2.z;
  
  float mag2 = sqrt(dirX2*dirX2 + dirZ2*dirZ2);
  dirX2 = dirX2/mag2;
  dirZ2 = dirZ2/mag2;
  
  //calcul du vecteur orthogonal 
  float orthoX2 = -dirZ2;
  float orthoZ2 = dirX2;
  
  //calcul de la position finale 
  car2X = centreV2.x + orthoX2 * 60 * posVoiture2.y;
  car2Z = centreV2.z + orthoZ2 * 60 * posVoiture2.y;
  
  float angleV2 = atan2(dirX2, dirZ2);
  
  background(105,207,255);
  //lights();
  
  if (modeNuit){
    background(0,10,25);
    ambientLight(30, 30, 50);
   } 

  if (!etatJeu){
    //on utilise les fonctions cos et sin pour créer un effet de 
    //rotation pendant le mode menu
    float angleRot = -frameCount * 0.003;
    float rayonRot = 2000;
    camera(cos(angleRot)*rayonRot,-800,sin(angleRot)*rayonRot,0,200,0,0,1,0); //on se place en vue du dessus 
  } else {
    float camX = car1X - dirX1 * 300;
    float camY = 50;
    float camZ = car1Z - dirZ1 * 300;
    camera(camX, camY, camZ, car1X, 150, car1Z, 0,1,0);
  }
  
  //creation du ciel 
  pushMatrix();
  drawMap(4000);
  popMatrix();
  
    //creation du sol
  pushMatrix();
  translate(0, 200, 0);
  rotateX(PI/2);
  noStroke();
  
  textureMode(NORMAL);
  textureWrap(REPEAT);
  
  beginShape(QUADS);
  texture(solTexture);
  vertex(-2020,-2020,0,1/4.,2/3.);
  vertex(2020,-2020,0,2/4.,2/3.);
  vertex(2020,2020,0,2/4.,1.);
  vertex(-2020,2020,0,1/4.,1.);
  endShape();
  
  popMatrix();
  
  route();
/*
  //ecouteur souris (utilisé pour les tests)
  float angleY = map(mouseX, 0, width, -PI, PI);
  float angleX = map(mouseY, 0, height, PI/2, -PI/2);
  rotateX(angleX);
  rotateY(angleY);
*/

  pushMatrix();
  translate(car2X,199,car2Z);
  rotateZ(PI);
  rotateY(-angleV2);
  scale(15);
  shape(voiture2);
  popMatrix();
  
  pushMatrix();
  translate(car1X,200,car1Z);
  rotateZ(PI);
  rotateY(-angleV1);
  scale(15);
  shape(voiture);
  popMatrix();
  
  dessinerMinimap();

  }
  
void dessinerMinimap(){
  hint(DISABLE_DEPTH_TEST);
  pushMatrix();
  pushStyle();
  camera();
  
  fill(20,150);
  noStroke();
  rect(20,20,250,250,10);
  
  translate(145,145);
  scale(0.08); //on reduit le circuit pour le faire tenir dans le rectangle
  
  stroke(255,220);
  strokeWeight(30);
  noFill();
  
  beginShape();
  for (int i = 0; i < 12; i+=3){
    PVector p0 = pointsControle.get(i);
    PVector p1 = pointsControle.get((i+1)%12);
    PVector p2 = pointsControle.get((i+2)%12);
    PVector p3 = pointsControle.get((i+3)%12);
    for (float t = 0; t <= 1; t+=0.05){
      float x = bezierPoint(p0.x, p1.x, p2.x, p3.x, t);
      float z = bezierPoint(p0.z, p1.z, p2.z, p3.z, t);
      vertex(x,z);
    }
  }
  endShape(CLOSE);
  
  strokeWeight(20);
  stroke(255, 0, 0);
  fill(255,0,0); //joueur en point rouge
  ellipse(car1X, car1Z, 120, 120);
  
  stroke(0,0,255);
  fill(0,0,255); //ordi en bleu
  ellipse(car2X, car2Z, 120, 120);
  
  popStyle();
  popMatrix();
  hint(ENABLE_DEPTH_TEST);
}


void keyPressed(){
  
  if (key == ' '){
    etatJeu = !etatJeu;
    if(etatJeu){ vitesseVoiture1 = 0;}
  }
  
  if (key == 'n'){
    modeNuit = !modeNuit;
  }

  //haut (acceleration)
  if (key == 'z'){ toucheZ = true;}
  
  //bas (frein)
  if (key == 's'){toucheS = true;}
  
  //gauche 
  if (key == 'q'){toucheQ = true;}
  
  //droite 
  if (key == 'd'){toucheD = true;}
  
}

void keyReleased(){
    if (key == 'z'){ toucheZ = false;}
    if (key == 'q'){ toucheQ = false;}
    if (key == 's'){ toucheS = false;}
    if (key == 'd'){ toucheD = false;}
}
