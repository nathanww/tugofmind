int xPos=250;


float p1exp=0;
float p2exp=0;
float maxPower=10;
void setup() {
size(500,100);
rectMode(CENTER);
frameRate(15);
}

void draw() {
  background(0);
  fill(255);
  rect(xPos,50,20,100);
  if (mousePressed) {
    xPos=mouseX;
  }
  p1exp=xPos;
  p2exp=500-xPos;
 // println(p1exp+","+p2exp);
  String p1data="";
  String p2data="";
  for (int i=1; i < 6;i++) { //simulate a 1/f curve
    p1data=p1data+(maxPower/(i*p1exp))+",";
    p2data=p2data+(maxPower/(i*p2exp))+",";
  }
  loadStrings("http://biostream-1024.appspot.com/sendps?user=player3&data="+p1data);
  loadStrings("http://biostream-1024.appspot.com/sendps?user=player4&data="+p2data);
}
