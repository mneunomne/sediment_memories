public class Data {
  // read csv data
  Table table;

  PGraphics pg;

  ArrayList <ArrayList <PVector>> lines = new ArrayList <ArrayList <PVector>> ();

  // ArrayList of loaded audio to be played
  ArrayList <SoundFile> audios = new ArrayList <SoundFile> ();  

  String filename = "data/frases.csv";

  PApplet parent;
  
  Data (PApplet _parent) {
    pg = createGraphics(1000, 1000);
    parent = _parent;
    loadData();
    loadCurData();
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
      String audio_file = row.getString("audio");
      loadAudio(audio_file);
      // println(id + "\t" + idx + "\t" + text);
    }
  }

  void loadCurData () {
    lines.clear();
    String linesString = table.getString(currentDataIndex, "lines");
    //check length of line 
    if (linesString.length() > 0) {
      loadLines(linesString);
    }
    // play cur audio 
    SoundFile audio = audios.get(currentDataIndex);
    audio.play();
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

  void save() {
    saveTable(table, filename);
  }

  void saveCurrentLines () {
    String linesString = "";
    for (ArrayList <PVector> line : lines) {
      for (PVector point : line) {
        linesString += point.x + "," + point.y + ";";
      }
      // linesString += "\n";
      println("linesString", linesString);
    }
    updateCell(currentDataIndex, "lines", linesString);
    saveTable(table, filename);
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

  void loadAudio (String filepath) {
    SoundFile audio = new SoundFile(parent, "data/audios/" + filepath);
    audios.add(audio);
  }


  void display () {
    displayText();
    displayLines();
  }

  // Data debug
  void displayText () {
    textAlign(LEFT, TOP);
    textSize(16);
    int y = 20;
    TableRow currentRow = table.getRow(currentDataIndex);
    String id = currentRow.getString("id");
    int idx = currentRow.getInt("index");
    String text = currentRow.getString("text");
    text(id + ": " + idx, 20, y);
    y += 30;
  }

  void displayLines () {
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

  }
}