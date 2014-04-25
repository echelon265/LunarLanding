//Constants
final static int SHIP_SIZE = 8;
final static int SHIP_HEIGHT = 598;
final static int SHIP_WIDTH = 342;

final static int WINDOW_WIDTH = 1280;
final static int WINDOW_HEIGHT = 720;

final static int BASE_WIDTH = 150;
final static int BASE_HEIGHT = 25;
final static int MOVE_LEFT = 0;
final static int MOVE_RIGHT = 1;
final static int MOVE_UP = 2;

//Global Variables
static float GRAVITY = 0.3f;
static float PROPULSION = 0.5f;

int basePosition;

float shipSpeed;
float shipAccel;
int shipY;
int shipX;

int fuel;
int times;

boolean isFuelActive;
boolean isSuccess;
boolean deadLine;
boolean playing;

PFont font;
PImage bg;
PImage ship;

void setup() {
  //frameRate(30);
  size(WINDOW_WIDTH, WINDOW_HEIGHT);
  noStroke();
  loadBG();
  initializeGame();
}

void initializeGame() {
  isFuelActive = false;
  isSuccess = false;
  deadLine = false;
  playing = true;
  shipSpeed = 0f;
  shipAccel = 0f;
  fuel = 100;
  times = 0;
  background(bg);
  //Initialize variables
  shipY=50;
  shipX= (int) random(SHIP_SIZE, (WINDOW_WIDTH-SHIP_SIZE)/2);
  basePosition = (int) random(0, WINDOW_WIDTH-BASE_WIDTH);
  drawLabelsBars();
  drawBase(basePosition);
  buildSpaceShip();
}

void loadBG() {
  bg = loadImage("bg.jpg");
  bg.resize(WINDOW_WIDTH, WINDOW_HEIGHT);
  background(bg);
}

void drawLabelsBars() {
  //Creates a fuel progress bar on the upper-left corner
  font = createFont("Arial", 16, true); // defines the font
  //bar length, bar height, x,y
  textFont(font, 25);   //specify font and size
  textAlign(LEFT);  // STEP 4 Specify font to be used
  text("SPEED "+ (int)shipSpeed, 20, 50);  // STEP 6 Display Text
  text("FUEL "+ (int)fuel, 20, 100);
  text("TIMES: "+ (int)times, 20, 150);
}

void drawBase(int x) {
  //draw a random positioned box as landing area at the bottom of the window
  fill(255);
  noStroke();
  rect(x, WINDOW_HEIGHT-BASE_HEIGHT, BASE_WIDTH, BASE_HEIGHT);
}

void buildSpaceShip() { 
  ship = loadImage("ship.png");
  /*Syntax  
   image(img, a, b)
   image(img, a, b, c, d)
   img   PImage: the image to display
   a   float: x-coordinate of the image
   b   float: y-coordinate of the image
   c   float: width to display the image
   d   float: height to display the image*/

  ship.resize(SHIP_WIDTH/SHIP_SIZE, SHIP_HEIGHT/SHIP_SIZE);  //0 value makes resizing proportional
  image(ship, shipX, shipY);
}

void draw() {
  background(bg);
  println(checkSpeed()+" "+isSuccess);
  if (playing) {
    drawBase(basePosition);
    drawLabelsBars();
    buildSpaceShip();
    calcGravity();
    if (checkFuel()) {
      drawBadMessage("CHECK YOUR FUEL", "You die alone in the space.");
    }
    else {
      evaluateLanding();
    }
  }
  else {
    if (!isSuccess) {
      drawBadMessage(" GAME OVER ", "Press space to try again");
    }
    else if (isSuccess) {
      if (checkSpeed())
        drawBadMessage("TOO FAST", "In real life, you would be crashed.");
      else
        drawSuccessMessage();
    }
  }
}

boolean checkFuel() {
  boolean b = fuel<=0;
  if (b) {
    isSuccess=false;
  }
  return b;
}

boolean checkSpeed() {
  return shipSpeed>5;
}

void evaluateLanding() {
  //this functions detects whether the spaceship landed within the borders of the base area or not
  int base_left_border = basePosition;
  int base_right_border = basePosition+BASE_WIDTH;
  int ship_left_border = shipX;
  int ship_right_border = shipX+(SHIP_WIDTH/SHIP_SIZE);

  int base_horizontal  = WINDOW_HEIGHT-BASE_HEIGHT;
  int ship_horizontal = shipY+(SHIP_HEIGHT/SHIP_SIZE);
  if (ship_horizontal>=base_horizontal && !deadLine) {
    deadLine = true;
    if (ship_left_border >= base_left_border && ship_right_border <= base_right_border) {
      isSuccess = true;
      if (checkSpeed()) {
        times++;
      }
      else {
        times = 0;
      }
      playing = false;
    }
  }
  if (ship_horizontal>=WINDOW_HEIGHT) {
    //this is game over zone
    playing=false;
    times++;
    isSuccess=false;
  }
}

void drawSuccessMessage() {
  fill(17, 32, 91);
  background(70, 160, 251);
  drawMessage(" WELL DONE!! ", "Press space to try it harder!");
}

void drawBadMessage(String bigText, String smallText) {
  fill(255, 80, 21);
  background(102, 28, 6);
  drawMessage(bigText, smallText);
}

void drawMessage(String bigText, String smallText) {
  textFont(font, 100);   //specify font and size
  textAlign(CENTER);  // STEP 4 Specify font to be used
  text(bigText, width/2, height/2);  // STEP 6 Display Text
  textFont(font, 25);  //specify font and size (again)
  int offset = 40;  //avoid text overlapping
  text(smallText, width/2, height/2+offset);  // STEP 7 Display Text
}

void calcGravity() {
  // Add speed to location.
  shipY += shipSpeed;
  // Add gravity to speed.
  shipSpeed += GRAVITY;
}

void move(int type) {
  if (type == MOVE_UP) {
    shipSpeed *= -PROPULSION;
    image(ship, shipX, shipY);
  }
  if (type == MOVE_LEFT) {
    //location = location - velocity
    shipX-=shipSpeed;
  }
  if (type == MOVE_RIGHT) {
    ////location = location + velocity
    shipX+=shipSpeed;
  }
}

void keyPressed() {
  if (key == CODED && playing) {
    switch (keyCode) {
    case LEFT:
      move(MOVE_LEFT);
      isFuelActive=false;
      break;
    case UP:
      fuel -= 1;
      move(MOVE_UP);
      isFuelActive=true;
      break;
    case RIGHT:
      isFuelActive=false;
      move(MOVE_RIGHT);
      break;
    }
  }
  else if (key==' ') {
    if (isSuccess) {
      initializeGame();
      times = 0;
      //change values to make it more difficult
      GRAVITY +=0.1f;
      PROPULSION -=0.05f;
      fuel -= (int) random (1, 2);
    }
    else if (!playing) {
      //you lose
      int t = times;
      initializeGame();
      times = t;
    }
    else if (checkSpeed()) {
      playing=false;
    }
    else if (checkFuel()) {
      playing=false;
    }
  }
}

void keyReleased() {
  isFuelActive=false;
}

