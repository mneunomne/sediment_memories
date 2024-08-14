// controlP5 library
import controlP5.*;
// Serial library
import processing.serial.*;

import processing.sound.*;

int currentDataIndex = 0;

Gui gui;

Data data; 

int waitTime = 2000;
int waitTimeDefault = 2000;

MachineController machineController;

boolean enableDraw = false; 
boolean enableSendLines = false;

boolean noMachine = false;

static final int IDLE               = 0;
static final int DRAW_MODE          = 1;
static final int SEND_LINES         = 2;
static final int WAIT_DRAW_NEXT     = 3;
String [] states = {
  "IDLE",
  "DRAW_MODE",
  "SEND_LINES",
  "WAIT_DRAW_NEXT"
};
int state = 0; 

static final int MACHINE_IDLE       = 0;
static final int MOVING_TO          = 1;
static final int DRAWING            = 2;
static final int MOVING_TO_ENDED    = 3;
static final int DRAWING_TO_ENDED   = 4;
String [] machine_states = {
  "IDLE",
  "MOVING_TO",
  "DRAWING",
  "MOVING_TO_ENDED",
  "DRAWING_TO_ENDED"
};
int machine_state = 0;

PGraphics pg;

int canvas_margin = 100;

int lineIndex = 0;
int segmentIndex = 0;

int default_microdelay = 200;

boolean autoNext = true;
boolean loopOne = false; 

int lastWaitTime = 0;

void setup() {
  size(800, 800);
  background(180);

  // load monospaced font
  PFont font = createFont("Courier New", 16);
  textFont(font);

  data = new Data(this);

  machineController = new MachineController(this, noMachine);

  ControlP5 cp5 = new ControlP5(this);
  gui = new Gui(cp5);
  gui.init();

  state = IDLE;
  gui.cp5.getController("set_idle").setValue(1);
  disableGuiState();
}

void draw() {
  background(0);
  data.display();
  machineController.update();
  machineController.display();

  if (state == WAIT_DRAW_NEXT) {
    int diffTime = millis() - lastWaitTime;
    println("diff time", diffTime , millis(), waitTime);
    if (diffTime > waitTime) {
      state = SEND_LINES;
      goToNextDrawing();
      goToLine();
    }
  }
}

// on mouse press, create a new line
void mousePressed() {
  if (state == DRAW_MODE) {
    data.lines.add(new ArrayList <PVector> ());
  }
}

// on mouse drag, add a point to the last line
void mouseDragged() {
  if (state == DRAW_MODE) {
    if (data.lines.size() > 0) {
      int canvasMouseX = max(canvas_margin, min(mouseX, width-canvas_margin));
      int canvasMouseY = max(canvas_margin, min(mouseY, width-canvas_margin));

      int x = int((float)(canvasMouseX-canvas_margin) / (width-canvas_margin*2) * 1000);
      int y = int((float)(canvasMouseY-canvas_margin) / (height-canvas_margin*2) * 1000);

      data.lines.get(data.lines.size()-1).add(new PVector(x, y));
    }
  }
}

void keyPressed() {
  // arrow right
  if (keyCode == 39) {
    data.saveCurrentLines();
    currentDataIndex = (currentDataIndex + 1) % data.table.getRowCount();
    goToNextDrawing();
  }
  // arrow left
  if (keyCode == 37) {
    data.saveCurrentLines();
    currentDataIndex = (currentDataIndex - 1 + data.table.getRowCount()) % data.table.getRowCount();
    goToNextDrawing();
  } 

  // clear
  if (state == DRAW_MODE) {
    if (key == 'c') {
      data.lines.clear();
      data.updateCell(currentDataIndex, "lines", "");
      data.save();
    }

    // delete last line in the array
    if (key == 'r') {
      if (data.lines.size() > 0) {
        data.lines.remove(data.lines.size()-1);
        data.saveCurrentLines();
      }
    }
  }

  // save
  if (key == 's') {
    data.saveCurrentLines();
  }

  // move machine WASD
  if (key == 'w') {
    machineController.move(0, -1); // up
    machineController.currentPos.y -= 1;
  }
  if (key == 's') {
    machineController.move(0, 1); // down
    machineController.currentPos.y += 1;
  }
  if (key == 'a') {
    machineController.move(1, 0); // left
    machineController.currentPos.x -= 1;
  }
  if (key == 'd') {
    machineController.move(-1, 0); // right
    machineController.currentPos.x += 1;
  }

  // with uppercase

  if (machine_state != MOVING_TO) {

    if (key == 'W') {
      machineController.move(0, -10); // up
      machineController.currentPos.y -= 10;
    }
    if (key == 'S') {
      machineController.move(0, 10); // down
      machineController.currentPos.y += 10;
    }
    if (key == 'A') {
      machineController.move(10, 0); // left
      machineController.currentPos.x -= 10;
    }
    if (key == 'D') {
      machineController.move(-10, 0); // right
      machineController.currentPos.x += 10;
    }

  }

}

void startSendLines() {
  lineIndex = 0;
  segmentIndex = 0;
  goToLine();
}

void goToLine () {
  if (data.lines.get(lineIndex).size() == 0) {
    return;
  }
  // move to the first position of first line
  int x = int(data.lines.get(lineIndex).get(segmentIndex).x);
  int y = int(data.lines.get(lineIndex).get(segmentIndex).y);
  machineController.moveTo(x, y); // move to the first point of the first line
}

void goToNextDrawing () {
  lineIndex = 0;
  segmentIndex = 0;
  data.loadCurData();
}

void sendDrawLine() {
  if (segmentIndex < data.lines.get(lineIndex).size()-1) {
    segmentIndex++;
    int x = int(data.lines.get(lineIndex).get(segmentIndex).x);
    int y = int(data.lines.get(lineIndex).get(segmentIndex).y);
    boolean valid = machineController.sendLine(x, y, segmentIndex);
    if (!valid) sendDrawLine();
  } else {
    lineIndex++;
    segmentIndex = 0;
    if (lineIndex >= data.lines.size() - 1) {
      // machine_state = MACHINE_IDLE;
      // go to next drawing
      if (autoNext) {
        currentDataIndex = (currentDataIndex + 1) % data.table.getRowCount();
        // goToNextDrawing();
        lineIndex = 0;
        state = WAIT_DRAW_NEXT;
        lastWaitTime = millis();
        return; 
      }

      if (loopOne) {
        // goToNextDrawing();
        state = WAIT_DRAW_NEXT;
        lastWaitTime = millis();
        return; 
      }
      
      println("END CUR DRAWING");
      return; 
    }
    goToLine();
  }
}

void drawMode(boolean mode) {
  enableDraw = mode; 
  enableSendLines = false;
}

void sendLines(boolean mode) {
  enableSendLines = mode;
  enableDraw = false;
  // change value in the cp5
  gui.cp5.getController("drawMode").setValue(0);
}

/* STATES GUI SETTERS */

void set_idle (boolean value) {
  if (value) {
    state = IDLE;
    disableGuiState();
  }
}

void set_draw_mode (boolean value) {
  if (value) {
    state = DRAW_MODE;
    disableGuiState();
  }
}

void set_send_lines (boolean value) {
  if (value) {
    state = SEND_LINES;
    startSendLines();
    disableGuiState();
  }
}

void disableGuiState () {
  for (int i = 0; i < states.length; i++) {
    String name = "set_" + states[i].toLowerCase();
    if (i == state) {
      gui.cp5.getController(name).setMouseOver(false);
      gui.cp5.getController(name).setLock(true);
    } else {
      gui.cp5.getController(name).setValue(0);
      gui.cp5.getController(name).setMouseOver(false);
      gui.cp5.getController(name).setLock(false);
    }
  }
}

void microdelaySlider (int value) {
  machineController.microdelay = value;
}

void waitSlider (int value) {
  waitTime = value;
}

void set_autoNext (boolean value) {
  autoNext = value;
}
void set_loopOne (boolean value) {
  loopOne = value;
}

void findHomeX() {
  machineController.moveHomeX();
}
void findHomeY() {
  machineController.moveHomeY();
}
