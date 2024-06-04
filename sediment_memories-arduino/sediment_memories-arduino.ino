#define STEP_PIN_X 2
#define DIR_PIN_X 5

#define STEP_PIN_Y 3
#define DIR_PIN_Y 6

#define ENA_PIN 8

#define microX1 1
#define microX2 3
#define microX3 4

#define microY1 1
#define microY2 3
#define microY3 4

#include <GCodeParser.h>

GCodeParser GCode = GCodeParser();

int minDelay = 2;
int maxDelayDefault = 200;

char c;

char buffer[14];

// current position

long curX = 0L;
long curY = 0L;

long steps_per_pixel = 65; 

void setup() {
  Serial.begin(115200);
  
  pinMode(STEP_PIN_X,OUTPUT);
  pinMode(DIR_PIN_X,OUTPUT);
  pinMode(STEP_PIN_Y,OUTPUT);
  pinMode(DIR_PIN_Y,OUTPUT);
  pinMode(ENA_PIN,OUTPUT);
 
  start();
  
}
void loop() {
  listenToPort();
}\

void listenToPort() {
  while (Serial.available() > 0)
  {
    if (GCode.AddCharToLine(Serial.read()))
    {
      GCode.ParseLine();

      if (GCode.HasWord('G'))
      {
        // get value of X and Y 
        if (GCode.HasWord('X'))
        {
          long posX = GCode.GetWordValue('X');
          long posY = GCode.GetWordValue('Y');
          int microdelay = GCode.GetWordValue('F');
          int index = GCode.GetWordValue('I');
          // index to string end_{index}
          // buffer
          char buffer[14];
          int out = sprintf(buffer, "end_%d", index);
          
          move(posX, posY, microdelay);
          // repond to the sender the current position
          Serial.println(buffer);
        }
      }
    }
  }
}


void start () {
  Serial.println("r");
  delay(100);

  digitalWrite(ENA_PIN,LOW); // enable motor HIGH -> DISABLE
  digitalWrite(ENA_PIN,LOW); // enable motor HIGH -> DISABLE
  // initial movement 
  moveX(500, 1, 500);
  moveY(500, 1, 500);
  moveX(500, -1, 500);
  moveY(500, -1, 500);
}

// Cubic interpolation function
float cubicInterpolate(float t) {
    return 3 * t * t - 2 * t * t * t;
}

// Custom cubic interpolation function for faster acceleration/deceleration
float customCubicInterpolate(float t) {
    // Custom cubic function to emphasize faster changes
    if (t < 0.5) {
        return 4 * t * t * t; // Faster acceleration
    } else {
        float p = (t - 1);
        return 1 + 4 * p * p * p; // Faster deceleration
    }
}

void move(long diffX, long diffY, int maxDelay) {
  // Serial.println("diff");
  // Serial.println(diffX);
  // Serial.println(diffY);
  Serial.print("diff: X ");
  Serial.print(diffX);
  Serial.print(" Y ");
  Serial.println(diffY);

  // if maxDelay is not set, use default
  if (maxDelay == 0) {
    maxDelay = maxDelayDefault;
  }

  // Determine the direction for each axis
  int dirX = (diffX > 0) ? 1 : -1;
  int dirY = (diffY > 0) ? 1 : -1;

  // Calculate the total steps for each axis
  long totalStepsX = labs(diffX * steps_per_pixel);
  long totalStepsY = labs(diffY * steps_per_pixel);

  if (totalStepsX > 0 && totalStepsY == 0) {
    moveX(totalStepsX, dirX, maxDelay);
    return;
  }
  
  if (totalStepsX == 0 && totalStepsY > 0) {
    moveY(totalStepsY, dirY, maxDelay);
    return;
  }

  if (totalStepsX == 0 && totalStepsY == 0) {
    return;
  }


  // Determine the larger number of steps
  long maxSteps = max(totalStepsX, totalStepsY);

  // Calculate step size for each axis
  float stepSizeX = (float)totalStepsX / maxSteps;
  float stepSizeY = (float)totalStepsY / maxSteps;

  /* debug
  Serial.print("debug -");
  Serial.print("stepSizeX: ");
  Serial.print(stepSizeX);
  Serial.print("stepSizeY: ");
  Serial.print(stepSizeY);
  Serial.print("maxSteps: ");
  Serial.print(maxSteps);
  Serial.print("totalStepsX: ");
  Serial.print(totalStepsX);
  Serial.print("totalStepsY: ");
  Serial.print(totalStepsY);
  Serial.println(".");
  */

  // Variables to keep track of accumulated error
  float errorX = 0;
  float errorY = 0;

  float stepX = 0;
  float stepY = 0;
  
  int curDelay = maxDelay;
  int half = maxSteps / 2;
  int diffDelay = maxDelay - minDelay;
  // Move both axes simultaneously, adjusting step size if needed
  for (int i = 0; i < maxSteps; i++) {
    /*
    float ratio = (float)i / maxSteps;
    if (i < half) {
      float _ratio =  ratio * 2;
      float cubicRatio = customCubicInterpolate(_ratio);
      curDelay = maxDelay - (diffDelay * cubicRatio); 
    } else {
      float _ratio =  (ratio - 0.5) * 2;
      float cubicRatio = customCubicInterpolate(_ratio);
      curDelay = minDelay + (diffDelay * cubicRatio); 
    }
    // printf(" %d %.6f \n", curDelay, ratio);
    */

    stepX += stepSizeX;
    stepY += stepSizeY;

    if (stepX >= 1.0) {
      moveX(1, dirX, curDelay);
      curX += 1*dirX;
      stepX -= 1.0;
    }

    if (stepY >= 1.0) {
      moveY(1, dirY, curDelay);
      curY += 1*dirY;
      stepY -= 1.0;
    }
  }
}

void moveX (int steps, int dir, int microdelay) {
  if (dir > 0) {
      digitalWrite(DIR_PIN_X,LOW); // enable motor HIGH -> DISABLE
  } else {
      digitalWrite(DIR_PIN_X,HIGH); // enable motor HIGH -> DISABLE
  }
  for (int i = 0; i < steps; i++) {
    digitalWrite(STEP_PIN_X,HIGH);
    delayMicroseconds(1);
    digitalWrite(STEP_PIN_X,LOW);
    delayMicroseconds(microdelay);
  }
}

void moveY (int steps, int dir, int microdelay) {
  if (dir > 0) {
      digitalWrite(DIR_PIN_Y,LOW); // enable motor HIGH -> DISABLE
  } else {
      digitalWrite(DIR_PIN_Y,HIGH); // enable motor HIGH -> DISABLE
  }
  for (int i = 0; i < steps; i++) {
    digitalWrite(STEP_PIN_Y,HIGH);
    delayMicroseconds(1);
    digitalWrite(STEP_PIN_Y,LOW);
    delayMicroseconds(microdelay);
  }
}
