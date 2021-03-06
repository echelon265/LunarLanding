//Constants
final static int SHIP_SIZE = 8; // 1 means real size image
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
float gravity;
float propulsion;

int basePosition;

float shipSpeed;
int shipY;
int shipX;

int fuel;
int times;

boolean isSuccess;
boolean deadLine;
boolean playing;
boolean rightPosition;

PFont font;
PImage bg;
PImage ship;

void setup() {
  //frameRate(30);
  size(WINDOW_WIDTH, WINDOW_HEIGHT);
  noStroke();
  //creates the objects of the game
  loadBG();
  initializeGame();
}

void initializeGame() {
  isSuccess = false;
  deadLine = false;
  rightPosition = false;
  playing = true;
  shipSpeed = 0f;
  gravity = 0.3f;
  propulsion = 0.5f;
  fuel = 100;
  times = 0;
  background(bg);
  //Initialize variables
  shipY=50;
  shipX= (int) random(SHIP_SIZE, (WINDOW_WIDTH-SHIP_SIZE)/2);
  basePosition = (int) random(0, WINDOW_WIDTH-BASE_WIDTH);
  //draw main objects in the screen
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
  text("ATTEMPT "+ (int)times, 20, 150);
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
  if (playing) {
    drawBase(basePosition);
    drawLabelsBars();
    buildSpaceShip();
    calcgravity();
    checkDeadLine();
    println(shipX+" "+shipY+" "+shipSpeed);
    if (!isFuelAvailable()) {
      //fuel tank is empty: game over
      playing=false;
      isSuccess=false;
    }
    else {
      evaluateLanding();
    }
  }
  else {
    if (!isSuccess) {
      if (!isFuelAvailable()) {
        drawBadMessage(" FUEL TANK EMPTY ", "Press space to try again");
      }
      else if (hasHighSpeed() && rightPosition) {
        drawBadMessage(" TOO FAST ", "Press space to try again");
      }
      else {
        drawBadMessage(" GAME OVER ", "Press space to try again");
      }
    }
    else if (isSuccess) {
      drawSuccessMessage();
    }
  }
}

void checkDeadLine() {
  int base_horizontal  = WINDOW_HEIGHT-BASE_HEIGHT;
  int ship_horizontal = shipY+(SHIP_HEIGHT/SHIP_SIZE);
  deadLine = ship_horizontal>=base_horizontal;

  //this functions detects whether the spaceship landed within the borders of the base area or not
  int base_left_border = basePosition;
  int base_right_border = basePosition+BASE_WIDTH;
  int ship_left_border = shipX;
  int ship_right_border = shipX+(SHIP_WIDTH/SHIP_SIZE);
  rightPosition = ship_left_border >= base_left_border && ship_right_border <= base_right_border;
  if (deadLine && rightPosition && !hasHighSpeed())
    isSuccess=true;
}

boolean isFuelAvailable() {
  boolean b = fuel>0;
  if (!b) {
    isSuccess = false;
  }
  return b;
}

boolean hasHighSpeed() {
  return shipSpeed>5;
}

void evaluateLanding() {
  if (deadLine) {
    if (rightPosition) {
      if (!hasHighSpeed()) {
        //this is well done zone
        isSuccess = true;
      }
      else {
        //you landed too fast
        isSuccess = false;
      }
      playing = false;
    }
  }
  if (shipY+(SHIP_HEIGHT/SHIP_SIZE)>=WINDOW_HEIGHT) {
    //this is game over zone
    playing=false;
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

void calcgravity() {
  // Add speed to location.
  shipY += shipSpeed;
  // Add gravity to speed.
  shipSpeed += gravity;
}

void move(int type) {
  if (type == MOVE_UP) {
    shipY-= shipSpeed;
    shipSpeed *= propulsion;
   /* shipY -= shipSpeed;
    shipSpeed = -shipSpeed;
    shipSpeed *= -propulsion;*/
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
      break;
    case UP:
      fuel -= 1;
      move(MOVE_UP);
      break;
    case RIGHT:
      move(MOVE_RIGHT);
      break;
    }
  }
  else if (key==' ' && !playing) {
    if (isSuccess) {
      int previousFuel = fuel;
      initializeGame();
      //change values to make it more difficult
      gravity +=0.1f;
      propulsion -=0.05f;
      fuel = previousFuel;
      fuel -= (int) random (1, 5);
      //If resultant fuel value is less than zero. generate a random fuel value betwwen 50 and 70
      if (fuel<=10)
        fuel = (int) random(50, 70);
      }
    else {
      //you lose
      int t = times;
      initializeGame();
      times = t+1;
    }
  }
}
