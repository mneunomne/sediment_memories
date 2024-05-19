

// read csv data
Table table;

// controlP5 library
import controlP5.*;
// Serial library
import processing.serial.*;

int currentDataIndex = 0;

Gui gui;

MachineController machineController;

ArrayList <ArrayList <PVector>> lines = new ArrayList <ArrayList <PVector>> ();

String filename = "data/frases.csv";

boolean enableDraw = false; 
boolean enableSendLines = false;

boolean noMachine = true;

static final int IDLE         = 0;
static final int DRAW_MODE    = 1; 
static final int SEND_LINES   = 2;
String [] states = {
  "IDLE",
  "DRAW_MODE",
  "SEND_LINES"
};
int state = 0; 

PGraphics pg;

int canvas_margin = 100;

void setup() {
  size(800, 800);
  background(180);

  pg = createGraphics(1000, 1000);

  loadData();
  loadCurData();

  ControlP5 cp5 = new ControlP5(this);
  gui = new Gui(cp5);
  gui.init();

  machineController = new MachineController(this, noMachine);
}

void loadData () {
  // Load the CSV file from the 'data' folder
  table = loadTable(filename, "header");

  // Print the total number of rows in the table
  println("Total rows: " + table.getRowCount());

  // Print the column names
  for (String columnName : table.getColumnTitles()) {
    print(columnName + "\t");
  }

  // Loop through all the rows and print the data
  for (TableRow row : table.rows()) {
    String id = row.getString("id");
    int idx = row.getInt("index");
    String text = row.getString("text");
    // println(id + "\t" + idx + "\t" + text);
  }
}

void draw() {

  background(0);

  pg.beginDraw();
  pg.background(180); 
  pg.noFill();
  // draw all the lines
  int index = lines.size() - 1;
  pg.strokeWeight(2);

  switch (state) {
  case IDLE:
    pg.stroke(0);
    break;
  case DRAW_MODE:
    pg.stroke(255, 0, 0);
    break;
  case SEND_LINES:
    pg.stroke(0, 255, 0);
    break;
  }
  if (lines.size() > 0) {
    pg.beginShape();
    for (ArrayList <PVector> line : lines) {
      for (PVector point : line) {
        int x = int((float)point.x / 1000 * pg.width);
        int y = int((float)point.y / 1000 * pg.height);
        pg.vertex(x, y);
      }
      index--;
    }
    pg.endShape();
  }
  pg.endDraw();

  image(pg, canvas_margin, canvas_margin, width-(canvas_margin*2), height-(canvas_margin*2));

  // Example: Display the data on the screen
  textAlign(LEFT, TOP);
  textSize(16);
  int y = 20;
  TableRow currentRow = table.getRow(currentDataIndex);
  String id = currentRow.getString("id");
  int idx = currentRow.getInt("index");
  String text = currentRow.getString("text");

  text(id + ", " + idx + ", " + text, 20, y);
  y += 30;
}

void saveCurrentLines () {
  String linesString = "";
  for (ArrayList <PVector> line : lines) {
    for (PVector point : line) {
      linesString += point.x + "," + point.y + ";";
    }
    linesString += "\n";
  }
  updateCell(currentDataIndex, "lines", linesString);
  saveTable(table, filename);
}

void loadCurData () {
  lines.clear();
  String linesString = table.getString(currentDataIndex, "lines");
  //check length of line 
  if (linesString.length() > 0) {
    loadLines(linesString);
  }
}

void loadLines(String linesString) {
  String[] linesArray = split(linesString, "\n");
  for (String lineString : linesArray) {
    ArrayList <PVector> line = new ArrayList <PVector> ();
    String[] pointsArray = split(lineString, ";");
    for (String pointString : pointsArray) {
      String[] pointArray = split(pointString, ",");
      if (pointArray.length == 2) {
        float x = float(pointArray[0]);
        float y = float(pointArray[1]);
        line.add(new PVector(x, y));
      }
    }
    lines.add(line);
  }
}

// Function to update a specific cell
void updateCell(int targetIndex, String targetColumn, String newValue) {
  int index = 0;
  for (TableRow row : table.rows()) {
    if (index == targetIndex) {
      row.setString(targetColumn, newValue);
      break;
    }
    index++;
  }
}


// on mouse press, create a new line
void mousePressed() {
  if (state == DRAW_MODE) {
    lines.add(new ArrayList <PVector> ());
  }
}

// on mouse drag, add a point to the last line
void mouseDragged() {
  if (state == DRAW_MODE) {
    if (lines.size() > 0) {

      int canvasMouseX = max(canvas_margin, min(mouseX, width-canvas_margin));
      int canvasMouseY = max(canvas_margin, min(mouseY, width-canvas_margin));

      int x = int((float)(canvasMouseX-canvas_margin) / (width-canvas_margin*2) * 1000);
      int y = int((float)(canvasMouseY-canvas_margin) / (height-canvas_margin*2) * 1000);




      lines.get(lines.size()-1).add(new PVector(x, y));
    }
  }
}

// on mouse release, send the line to the machine
void mouseReleased() {
  
}

void keyPressed() {
  // arrow right
  if (keyCode == 39) {
    saveCurrentLines();
    currentDataIndex = (currentDataIndex + 1) % table.getRowCount();
    loadCurData();
  }
  // arrow left
  if (keyCode == 37) {
    saveCurrentLines();
    currentDataIndex = (currentDataIndex - 1 + table.getRowCount()) % table.getRowCount();
    loadCurData();
  } 

  // clear
  if (state == DRAW_MODE) {
    if (key == 'c') {
      lines.clear();
      updateCell(currentDataIndex, "lines", "");
      saveTable(table, filename);
    }

    // delete last line in the array
    if (key == 'r') {
      if (lines.size() > 0) {
        lines.remove(lines.size()-1);
      }
    }
  }

  // save
  if (key == 's') {
    saveCurrentLines();
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
    disableGuiState();
  }
}

void disableGuiState () {
  for (int i = 0; i < states.length; i++) {
    String name = "set_" + states[i].toLowerCase();
    println("state", state);
    if (i == state) {
      println("cur state: " + states[i]);
      gui.cp5.getController(name).setMouseOver(false);
      gui.cp5.getController(name).setLock(true);
    } else {
      gui.cp5.getController(name).setValue(0);
      gui.cp5.getController(name).setMouseOver(false);
      gui.cp5.getController(name).setLock(false);
    }
  }
}