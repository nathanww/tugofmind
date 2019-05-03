float playerRatio=875; //Position of the ball. No longer a ratio, this is now the X position of the ball in pixels. Midpoint is 900, it goes from 0 to 1800 px.
float SCALE_FACTOR=0.5; //how rapidly pulling force translates into difference
float ARTIFACT_THRESH=4; //if the power value is above this, we consider it contaminated with artifact and don't use it to update the player's power
PFont theFont;
float fudgeFactor=0; //fudgeFactor/fudgeSamples represents the average movement rate DURING THE BASELINE PERIOD. We substract this out during the game to implement baseline correction
int fudgeSamples=0;
String player1="1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1"; //initialize variables for data from server
String player2="1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1";
long startTime=0;
String state="GAME"; 
PrintWriter output;

boolean dataGoodPlayer1=false; //indicates if we have valid data from each player, used to control color of the display
boolean dataGoodPlayer2=false;

float computeAlphaPower(String data) { //alpha power 
  String[] splitup=data.split(",");
  float total=0;
  return float(splitup[1]);
  
}

float computeSWA(String data) { //returns the spectrum-weighted average (brain rate) of the data. Not currently used
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
     String temp1=loadStrings("http://biostream-1024.appspot.com/getps?user=player1")[0];
     String temp2=loadStrings("http://biostream-1024.appspot.com/getps?user=player2")[0];
   
     float power1=computeAlphaPower(temp1);
     float power2=computeAlphaPower(temp2);
     if (power1 <= ARTIFACT_THRESH) {
       player1=temp1;
       dataGoodPlayer1=true;
     }
     else {
       dataGoodPlayer1=false;
       if (millis() -startTime > 20000) { //after 20 seconds of baseline data we are in the game period
       player1="0,0";
       }
     }
     
     if (power2 <= ARTIFACT_THRESH) {
       player2=temp2;
       dataGoodPlayer2=true;
     }
     else {
       dataGoodPlayer2=false;
       if (millis() -startTime > 20000) { //after 20 seconds of baseline data we are in the game period
       player2="0,0";
       }
     }
     
    //simulation for before we have a client to send data
    //player1="0.05,0.025,0.016666668,0.0125,0.01,0.008333334,0.007142857,0.00625,0.0055555557,0.005";
    //player2="0.05,0.025,0.016666668,0.0125,0.01,0.008333334,0.007142857,0.00625,0.0055555557,0.005";
    output.println(player1+","+player2); //data logging
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

thread("updateData");  //server communication runs in a different thread to prevent the game from becoming jerky if it is slow
startTime=millis();
}



void draw() {
 
  //compute the position on each frame so movement of the ball is smooth ven though the data updating only happens every 1 second
  if (state == "GAME") {
      background(0);// draws black over everything, resetting the backround
    println(computeAlphaPower(player1)/computeAlphaPower(player2)); 
  
  
  if (millis() -startTime > 20000) { //after 20 seconds of baseline data we are in the game period
    if (millis() - startTime < 25000) {
      fill(255,255,255);
     text("Pull!",750,350);
    }
 playerRatio=playerRatio+((computeAlphaPower(player2)-computeAlphaPower(player1))*SCALE_FACTOR)-(fudgeFactor/fudgeSamples);
  }
  else if (millis() -startTime > 500) {
    fill(255,255,255);
     text("Get ready!",750,350);
    fudgeFactor=fudgeFactor+(((computeAlphaPower(player2)-computeAlphaPower(player1))*SCALE_FACTOR));
    fudgeSamples++;
  }
  
   println(playerRatio);

  
  textFont(theFont,48);
  if (dataGoodPlayer1) {
    fill(0,255,0);
  }
  else {
    fill(127,127,0);
  }
  text("Player 1",50,50);
    if (dataGoodPlayer2) { //change player to yellow if the data is not good.
    fill(0,255,0);
  }
  else {
    fill(127,127,0);
  }
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
