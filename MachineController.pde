public class MachineController {
  Serial port;  // Create object from Serial class
  int portIndex = 1;

  PVector currentPos = new PVector(0, 0);

  PVector nextPos = new PVector(0, 0);

  PGraphics machineCanvas;

  boolean noMachine = false;

  int microdelay = default_microdelay;

  MachineController(PApplet parent, boolean _noMachine) {
     // if no machine, don't connect to serial
    noMachine = _noMachine;
    machineCanvas = createGraphics(1000, 1000);
    if (noMachine) return; 
    // Connect to Serial
    print("[MachineController] SerialList: ");
    printArray(Serial.list());
    String portName = Serial.list()[portIndex]; //change the 0 to a 1 or 2 etc. to match your port
    port = new Serial(parent, portName, 115200); 
    // machine canvas   
  };

  void update() {
    if (!noMachine) {
      listenToPort();
    }

    switch (machine_state) {
      case MOVING_TO:
        // if machine is moving to a point, display it
        // display();
        if (noMachine) {
          currentPos = nextPos;
          machine_state = MOVING_TO_ENDED;
        }
        break;
      case MOVING_TO_ENDED:
        // if machine has finished moving to a point, display it
        sendDrawLine();
        //display();
        break;
      case DRAWING:
        // if machine is drawing a segment, display it
        if (noMachine) {
          currentPos = nextPos;
          machine_state = DRAWING_TO_ENDED;
        }
        break;
      case DRAWING_TO_ENDED:
        sendDrawLine();
        // if machine has finished drawing a segment, display it
        
        break;
      default:
        break;
    }
  }

  void display () {
    // display current position of machine
    // draw ellipse at current position
    
    machineCanvas.beginDraw();
    machineCanvas.background(0, 0);
    machineCanvas.noStroke();
    machineCanvas.fill(0, 255, 0, 50);
    machineCanvas.ellipse(nextPos.x, nextPos.y, 50, 50);
    machineCanvas.stroke(255, 0, 0);
    machineCanvas.line(currentPos.x-10, currentPos.y, currentPos.x+10, currentPos.y);
    machineCanvas.line(currentPos.x, currentPos.y-10, currentPos.x, currentPos.y+10);
    machineCanvas.endDraw();

    image(machineCanvas, canvas_margin, canvas_margin, width-(canvas_margin*2), height-(canvas_margin*2));
  }

  void listenToPort () {
    if (noMachine) return;
    // read from serial port
    if (port.available() > 0) {
      String inBuffer = port.readStringUntil('\n');
      if (inBuffer != null) {
        println("[MachineController] Received: " + inBuffer);

        // if message is 'e' means the movement is over
        if (inBuffer.contains("end")) {
          currentPos = nextPos;
          if (machine_state == MOVING_TO) {
            machine_state = MOVING_TO_ENDED;
          } else if (machine_state == DRAWING) {
            machine_state = DRAWING_TO_ENDED;
          }
        }

        /*
        // parse incoming message
        String[] parts = split(inBuffer, 'X');
        if (parts.length == 2) {
          int x = int(parts[1]);
          int y = int(parts[2]);
          currentPos = new PVector(x, y);
        }
        */
      }
    }
  }

  void moveHome () {
    if (noMachine) return;
    // move to home position
    // currentPos = new PVector(50, 50);
    // sendMovement(currentPos.x, currentPos.y);
  }

  void moveTo(int x, int y) {
    machine_state = MOVING_TO;
    nextPos = new PVector(x, y);
    println("pos: " + x + " " + currentPos.x + " " + y + " " + currentPos.y);
    int diff_x = int(x - currentPos.x);
    int diff_y = int(y - currentPos.y);
    // send movement data
    sendMovement(diff_x, diff_y, 1, microdelay);
  }

  void sendLine(int x, int y) {
    machine_state = DRAWING;
    nextPos = new PVector(x, y);
    println("pos: " + x + " " + currentPos.x + " " + y + " " + currentPos.y);
    int diff_x = int(x - currentPos.x);
    int diff_y = int(y - currentPos.y);
    // send movement data
    sendMovement(diff_x, diff_y, 2, microdelay);
  }

  void sendMovement (int x, int y, int type, int microdelay) {
    if (noMachine) return;
    // encode movement
    // String message = "[" + x + "," + y + "]";
    String message = "G" + type +  " X" + x + " Y" + y + " F" + microdelay + '\n';
    port.write(message);
    println("[MachineController] Sent: " + message);
  }
}