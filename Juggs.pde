import processing.opengl.*;
import processing.sound.*;

PImage bg, HandsCursor, HandsCatch, ball, sun;

int state = 0;
int globalCounter = 0;
int drops;

float y, x;
float auxY, auxX;
float angle = 0;
float zoom = 0.15;
float speed = 1;
float timer = 0;
float maxTime = 90;
float equis, ye;

boolean display = true;
boolean complete = false;

PShape b, c;

Table columnTable; // Table used to store values from .csv to display scoreboard graph

SoundFile crowd;

// Creates new coordinates for new ball
void newCords() {
  equis = random(width/2-100, width/2+100);
  ye = random(height/2-50, height/2+50);
}

void setup() {
  size(804, 501, OPENGL);
  frameRate(100);  // Screen frame rate for appropiate animation screen feeling
  textAlign(CENTER); 
  smooth(); // Used for smooth animated motion
  
  bg = loadImage("JUGGS_BG.jpg");
  ellipseMode(CENTER);

  // Used for cursor
  HandsCursor = loadImage("HANDS_OPEN.png");
  HandsCatch = loadImage("HANDS-CLOSED.png");
  cursor(HandsCursor);
  
  sun = loadImage("sun.png"); // Used for texture
  
  newCords();
  
  b = createShape();
  c = createShape();
  b.setVisible(true);
  c.setVisible(true);
  
  // Used for crowd noise
  crowd = new SoundFile(this, "cr.mp3");
  crowd.loop();
}

void draw() {
  /* MENU */
  if (state == 0) { // State = 0 is the menu page
    drops = 0;
    globalCounter = 0;
    background(0, 164, 51);

    fill(34, 116, 165);
    stroke(2);
    textSize(40); // Menu Page Tittle 
    text("JUGGS MACHINE", width/2, 90);

    fill(255);

    textSize(17); // GAME RULES
    text("Catch as many balls as possible", width/2, 140);
    text("If you have 5 drops you lose", width/2, 170);
    text("", width/2, 240);

    
     // Game instructions
    textSize(20);
    text("CLICK TO CATCH THE BALL", width/2, 280);
    text("Move mouse to move player's hands", width/2, 250);
    text("Press 0 key to exit game", width/2, 310);
    text("Press P to pasue game", width/2, 340);

    fill(34, 116, 165);
    textSize(30); // Call to action
    text("Click anywhere to play!", width/2, 430);

    if (mousePressed) { // Change to gaming status if clicked
      state = 1;
    }
  }

  /* GAMEPLAY */
  if (state == 1) { // State = 1 is the game
    loop(); // Lets function Game be called every time draw is called and state == 1
    gamePlay(); // Calls gameplay
  }

  /* PAUSE MENU */
  if (state == 2) { // State = 2 is the Pause
    background(255);
    textSize(50);
    fill(0, 164, 51);
    text("PAUSE", width/2, height/2);
    textSize(25);
    text("Click to continue", width/2, height-30);

    if (mousePressed) { // Go back to gaming status if clicked
      state = 1;
    }
  }

  /* SCOREBOARD */
  if (state == 3) { // State = 3 is the scoreboard
    background(255);
    
    textSize(20);
    columnGraph(); // Calls scoreboard as a graph display
    noLoop(); // Stops the loop calling of function draw so scoreboard graph is just called once
    
    fill(255);
    textSize(35);
    text("YOUR SCORE: " + globalCounter,width/2, 50);
    textSize(20);
    text("Press ESC to EXIT!",width/2, 430); // EXIT
    
    if (mousePressed) { // Change to gaming status if clicked
      // Reset to stock values for new game
      loop();
      globalCounter = 0;
      drops = 0;
      speed = 1;
      timer = 0;
      
      state = 1;
      //loop();
    }
  }
}


void columnGraph() {
  columnTable = loadTable("columnas.csv", "header"); // Load data from .csv
  rectMode(CENTER);
  
  pushMatrix();
  
  translate(300,325);
  
  // Base line Y = 0
  strokeWeight(3);
  strokeCap(SQUARE);
  stroke(200);
  line(0,0,200,0); // Translate to desired position
  
  
  // Y-axis landmarks
  float pos5 = map(5,0,20,0,200);
  float pos10 = map(10,0,20,0,200);
  float pos15 = map(15,0,20,0,200);
  float pos20 = map(20,0,20,0,200);
  
  // Y-axis Labels
  strokeWeight(1);
  fill(255);
  line(0,-pos5,200,-pos5); text("0",-20,0);
  line(0,-pos5,200,-pos5); text("5",-20,-pos5+3);
  line(0,-pos10,200,-pos10); text("10",-20,-pos10+3);
  line(0,-pos15,200,-pos15); text("15",-20,-pos15+3);
  line(0,-pos20,200,-pos20); text("20",-20,-pos20+3);
  
  // X-axis labels
  text("Highest Score", 100, 30);
  
  // Data allocation
  float val = 0;
  float real = 0;
  
  for (TableRow row : columnTable.rows()) {
    real = row.getFloat("Max"); // Get value from column Max to N row
    val = map(real,0,20,0,200);
    float newV = map(globalCounter,0,20,0,200);
    
    if (globalCounter > real) {  
      strokeWeight(0);
      fill(255, 34, 0); // Max Score Graph Bar
      rect(100,-newV/2,40,newV);
    } else {
      strokeWeight(0);
      fill(255, 34, 0); // Max Score Graph Bar
      rect(100,-val/2,40,val);
    } 
    
  }
  println("Current Highest Score: " + real); // Debug tool
  
  if (globalCounter > real) {
    println("New Highest Score: " + globalCounter); // Debug tool
    
    columnTable.removeRow(0);  // Delete current first row
      
    TableRow newRow1 = columnTable.addRow(); // Create new row to set updated Player1 values
    newRow1.setInt("Max", globalCounter);  // Set row updated value
    
    saveTable(columnTable, "columnas.csv"); // Load table with updated rows into .csv file
  }
  
  popMatrix();
}

void mousePressed() {
  cursor(HandsCatch); // Animates hands on catch
  
  /* You can only cacth between this coordinates and ball size parameter to simulate proximity */
  if(equis - 25 <= mouseX && mouseX <= equis + 25 ) {
    if(ye - 25 <= mouseY && mouseY <= ye + 25 ) {
      if(zoom >= 0.4 && timer < 100) {
        display = false; // Ball disappears after catch
        globalCounter += 1; // Add completion
        complete = true;
      }
    }
  }
  
}

void mouseReleased() {
  cursor(HandsCursor); // Animates hands on catch 
}


void keyPressed() {
  if (key == 'p') {
    state = 2;  // PAUSE
  }
}

/*********************************
This method draws ball on field,
it scales and simulates proximity
as in a real life throw.
*********************************/ 
void ball(boolean d) {
  if (d) {
    noStroke();
    pushMatrix();
  
    translate(equis, ye);
    
    rotate(angle);
    scale(zoom);
    
    b.beginShape();
    
    b.fill(#603C26);
    
    b.vertex(0,-45);
    b.vertex(30,-30);
    b.vertex(45,0);
    b.vertex(30,30);
    b.vertex(0,45);
    b.vertex(-30,30);
    b.vertex(-45,0);
    b.vertex(-30,-30);
    
    b.endShape(CLOSE);
    
    c.beginShape();
    
    c.stroke(#FFFFFF);
    c.strokeWeight(2);
    c.vertex(15,-15);
    c.vertex(30,-30);
    
    c.endShape();
    
    shape(b, 0, 0);
    shape(c, 0, 0);
    
    point(0,0);
    
    popMatrix();
  }
  
  
  angle += 0.3; // Rotate ball to simulates throw's torque
  if (zoom <= 0.8) {
    zoom += 0.005 * speed; // Controls ball growth and proximity
  }
}


// PLAYER SCOREBOARD ON TOP OF STADIUM
void scoreboard() {
  pushMatrix();
  translate(width/2,100);
  
  fill(0);
  stroke(200);
  strokeWeight(2);
  rotateX(-PI/8);
  box(150, 100, 20);
  
  fill(255);
  textSize(9);
  text("Scoreboard", 0, -27, 200);
  
  fill(255,0,0);
  textSize(20);
  text(globalCounter, 0, 0, 200);
  
  popMatrix();
}


// PLAYER DROPS ON STADIUM LATERAL MONITORS
void dropsScore(int x, int y, float rot) {
  pushMatrix();
  translate(x,y);
  
  fill(0);
  stroke(200);
  strokeWeight(2);
  rotateY(rot);
  box(50,70,10);
  
  if (rot > 0) {
    fill(255,0,0);
    textSize(10); 
    text("Drops", 20, -22, 100);
    
    fill(255,0,0);
    textSize(21); 
    text(drops, 20, 0, 100);
  } else {
    fill(255,0,0);
    textSize(10);  
    text("Drops", -20, -22, 100);
    
    fill(255,0,0);
    textSize(21); 
    text(drops, -20, 0, 100);
  }
  
  popMatrix();
}


// Simulates sun with a texture, it turns fully yellow when a catch is performed
void sun() {
  PShape s;
  
  pushMatrix();
  translate(width/2,20);
  
  s = createShape(SPHERE, 30);
  s.setTexture(sun);
  shape(s, 0, 0);
  
  popMatrix();
}


// GAME MIND
void gamePlay() { 
  background(bg);

  fill(#FFFF00);
  strokeWeight(0);
  ellipse(auxX, auxY, 6, 6);

  // Used for crowd flashes
  y = random(140, 250);
  x = random(800);
  auxY = y;
  auxX = x;

  if (timer <= maxTime) {
    ball(display);
    timer += speed;
      
    if (timer > maxTime) {
      b.setVisible(false);
      c.setVisible(false);
      
      // Required values for new ball  
      display = true;
      newCords();
      timer = 0;
      zoom = 0.1;
      
      if (complete != true) {
        drops += 1; // INCOMPLETE PASS
        
        if (drops == 5) { // GAME OVER
         state = 3;
        }
      }
      
      complete = false;
        
      b.setVisible(true);
      c.setVisible(true);
    }
  }
  
  sun(); // Display sun
  scoreboard(); // Display Scoreboard
  
  dropsScore(width/8,300, PI/8); // Display Drops Scoreboard
  dropsScore(width - width/8,300, -PI/8); // Display Drops Scoreboard
  
  if(globalCounter % 4 == 0 && globalCounter != 0) {
    speed += 0.025;  // Increase difficulty with more game speed
  }
  
  fill(255);
  stroke(#FFFF00);
  strokeWeight(2);
  lightFalloff(1.0, 0.001, 0.0); // Lights of flashes from crowd
  pointLight(255, 255, 0, 35, 40, 36);
  ellipse(x, y, 12, 12);
}
