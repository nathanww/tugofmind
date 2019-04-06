float playerRatio=900; //how much stronger is player 1 ompared to 2? 0= 1 wins, 2=2 wins
float SCALE_FACTOR=2; //how rapidly pulling force translates into difference
PFont theFont;
float fudgeFactor=0;
int fudgeSamples=0;
String player1="1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1";
String player2="1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1";
long startTime=0;
String state="GAME";
PrintWriter output;


float computeAlphaPower(String data) {
  String[] splitup=data.split(",");
  float total=0;
  return float(splitup[1]);
  
}

float computeSWA(String data) { //returns the spectrum-weighted average (brain rate) of the data
  String[] splitup=data.split(",");
  float total=0;
  float allPower=0;
  for (int item=0; item < splitup.length; item++) {
    allPower=allPower+float(splitup[item]);
  }
  for (int item=0; item < splitup.length; item++) {
    total=total+((item+1)*(float(splitup[item])/allPower));
 
  }
  return total;
}



void updateData() { //retrieve power spectra from the server and calculate the player ratio
  while (true) {
     player1=loadStrings("http://biostream-1024.appspot.com/getps?user=player1")[0];
     player2=loadStrings("http://biostream-1024.appspot.com/getps?user=player2")[0];
   
    //simulation for before we have a client to send data
    //player1="0.05,0.025,0.016666668,0.0125,0.01,0.008333334,0.007142857,0.00625,0.0055555557,0.005";
    //player2="0.05,0.025,0.016666668,0.0125,0.01,0.008333334,0.007142857,0.00625,0.0055555557,0.005";
    output.println(player1+","+player2);
    output.flush();
    //println(player1+","+player2);
    try {
      Thread.sleep(100);
    }
    catch (InterruptedException e) {
      
    }
  }
  
}



void setup() {
size(1800,900);
output=createWriter("log.csv");
theFont=loadFont("font.vlw"); //load the font and set the text drawing parameters

thread("updateData"); 
startTime=millis();
}



void draw() {
 
  //compute the position on each frame so movement of the ball is smooth ven though the data updating only happens every 1 second
  if (state == "GAME") {
    println(computeSWA(player1)/computeSWA(player2)); 
  //playerRatio=playerRatio+((1-(computeSWA(player1)/computeSWA(player2)))*SCALE_FACTOR);
  
  
  if (millis() -startTime > 10000) {
 playerRatio=playerRatio+((computeSWA(player2)-computeSWA(player1))*SCALE_FACTOR)-(fudgeFactor/fudgeSamples);
  }
  else if (millis() -startTime > 2000) {
    fudgeFactor=fudgeFactor+(((computeSWA(player2)-computeSWA(player1))*SCALE_FACTOR));
    fudgeSamples++;
  }
  
   println(playerRatio);
  background(0);// draws black over everything, resetting the backround
  fill(0,255,0);
  textFont(theFont,48);
  text("Player 1",50,50);
  text("Player 2",1500,50);
  fill(127,127,0);
  ellipse(playerRatio,450,100,100);
  if (playerRatio < 50) {
    state="POSTGAME";
    textFont(theFont,60);
    text("Player 1 wins!",500,450);
  }
    if (playerRatio > 1750) {
    state="POSTGAME";
    textFont(theFont,60);
    text("Player 2 wins!",500,450);
  }
  }
  
  
  
}
