import processing.serial.*;
import org.gicentre.utils.stat.*;

Serial port; // Serial port object
PImage backgroundImage;
PImage welcomeScreenImg;
PImage fistImg;
PFont customFont; // Declare a variable to hold your custom font
int screen = 0; // Variable to keep track of current screen
boolean enterPressed = false; // Variable to track if Enter key is pressed

int[] fsrValues = new int[4]; // Array to store FSR sensor values
float accelX, accelY, accelZ; // Variables to store accelerometer values
float heartRate; // Variable to store heart rate value

void setup() {
  size(800, 800); // Set window size
  port = new Serial(this, "/dev/cu.usbmodem123456781", 115200); // Change to your serial port name and baud rate
  port.bufferUntil('\n');
  backgroundImage = loadImage("background.png");
  textAlign(CENTER, CENTER);
  textSize(24);
}

void draw() {
  if (screen == 0) {
    displayWelcomeScreen();
  } else if (screen == 1) {
    displayFSRSensors();
   
  } else if (screen == 2) {
    displayHeartRate();
  } else if (screen == 3) {
    displayAccelerometer();
  }
}


void serialEvent(Serial port){
while (port.available() > 0) {
    String data = port.readStringUntil('\n');
    if (data != null) {
      // Split data into lines
      String[] lines = split(data, '\n');
      
      // Parse and store sensor data
      for (String line : lines) {
        String[] values = split(line, ':');
        if (values.length >= 2) {
          String sensor = trim(values[0]); // Trim to remove leading/trailing spaces
          String val = trim(values[1]);
          if (sensor.equals("FSR 1")) {
            fsrValues[0] = int(val);
          } else if (sensor.equals("FSR 2")) {
            fsrValues[1] = int(val);
          } else if (sensor.equals("FSR 3")) {
            fsrValues[2] = int(val);
          } else if (sensor.equals("FSR 4")) {
            fsrValues[3] = int(val);
          } else if (sensor.equals("X")) {
            accelX = float(val);
            if (accelX < .45){
              accelX = 0;
            }
          } else if (sensor.equals("Y")) {
            accelY = float(val);
            if (accelY < 1.04){
              accelY = 0;
            }
          } else if (sensor.equals("Z")) {
            accelZ = float(val);
            if (accelZ < .15){
              accelZ= 0;
            }
          } else if (sensor.equals("Heartrate")) {
            heartRate = float(val);
          }
        }
      }
    }
  }
}

String punchIdentifier (float accelX, float accelY, float accelZ ){
  
  String punch = "idle";
  float x,y,z;
  x = accelX;
  y = accelY;
  z = accelZ;
  
  if (x !=0 && z!=0 && y == 0){
    punch = "HOOK";
  }
  else if (x == 0 && z!= 0 && y != 0)
  {
   punch = "Cross";
  }
  else if ((x == 0 && z!= 0 && y == 0))
  {
   punch = "Jab";
  }
  return punch;
}

void displayFSRSensors() {
  
  background(100, 200, 255); // Lighter blue background
  fistImg=  loadImage("fist.png");
  imageMode(CENTER); // Set image mode to center
  float imageSize = 500; // Adjust the size of the image
  image(fistImg, width/2, height/2, imageSize, imageSize); // Draw the image in the middle
  
  
  
  int x_coor=0;
  int y_coor=0; 
  
  for (int i = 0; i < 4; i++) {
    if (i==0){
      x_coor = 300;
      y_coor= 350; 
    }
    else if (i==1){
      x_coor = 400;
      y_coor= 350 ; 
    }
    if (i==2){
      x_coor = 500;
      y_coor= 350; 
    }
    if (i==3){
      x_coor = 590;
      y_coor= 350; 
    }
    
    fill(255, 0, 0); // Red color
    if (fsrValues[i] > 800) {
      fill(0, 255, 0); // Green color for hard punch
    } else if (fsrValues[i] > 300) {
      fill(255, 255, 0); // Yellow color for soft punch
    }
    ellipse(x_coor, y_coor, 60, 60); // Circle at the center
  }
  
}

void displayHeartRate() {
  background(255, 200, 200); // Light red background
  
  // Check heart rate against ranges
  if (heartRate >= 60 && heartRate <= 100) {
    fill(0, 100, 0); // Dark green color
    text("Heart Rate: " + heartRate + " (Normal)", 400, 100);
    fill(0, 255, 0); // Default color: green
  } else if (heartRate < 60) {
   fill(150, 100, 0); // Dark yellow color
    text("Heart Rate: " + heartRate + " (Low)", 400, 100);
    fill(255, 230, 0); // Warmer yellow color
  } else {
    fill(150, 0, 0); // Dark red color
    text("Heart Rate: " + heartRate + " (High)", 400, 100);
    fill(255, 0, 0); // Default color: red
  }
  
  // Draw heart shape
  drawHeart(width / 2, height / 2, 400); // Draw heart at the center
}

void drawHeart(float x, float y, float size) {
  beginShape();
  vertex(x, y - size / 4);
  bezierVertex(x + size / 2, y - size, x + size, y - size / 2, x, y + size / 2);
  bezierVertex(x - size, y - size / 2, x - size / 2, y - size, x, y - size / 4);
  endShape(CLOSE);
}


void displayAccelerometer() {
  background(backgroundImage);
  fill(0, 0, 255); // Blue color
  textSize(24);
  text("AccelX: " + accelX, 400, 400);
  text("AccelY: " + accelY, 500, 200);
  text("AccelZ: " + accelZ, 300, 100);
  String punch = punchIdentifier(accelX, accelY, accelZ);
  fill(0); // Black color
  textSize(50);
  text("Punch: " + punch, 400, 725); // Display punch identifier result
}


void displayWelcomeScreen() {
 background(255, 100, 100); // More intense red background
  
  customFont = loadFont("GillSans-UltraBold-48.vlw"); // Replace "YourFont.ttf" with the path to your font file
  
  // Set the custom font for the text
  textFont(customFont);
  
  fill(255); // Black color
  textSize(50);
  text("LETS BOX!", 400, 100);
  textSize(30);
  text("Hit Enter to start", 400, 650);
  welcomeScreenImg=  loadImage("welcomescreenpic.png");
  imageMode(CENTER); // Set image mode to center
  float imageSize = 300; // Adjust the size of the image
  image(welcomeScreenImg, width/2+50, height/2, imageSize, imageSize); // Draw the image in the middle

}

void keyPressed() {
  if (!enterPressed && keyCode == ENTER) {
    enterPressed = true;
    screen = 1; // Move to the sensor data screen when Enter is pressed on the welcome screen
  } else if (enterPressed) {
    if (key == 'f') {
      screen = 1; // Move to the sensor data screen
    } else if (key == 'c') {
      screen = 2; // Move to the heart rate screen
    } else if (key == 'b') {
      screen = 3; // Move to the accelerometer screen
    }
  }
}
