public class MachineController {
  Serial port;  // Create object from Serial class
  int portIndex = 0;

  PVector currentPos = new PVector(50, 50);

  PGraphics machineCanvas;

  MachineController(PApplet parent, boolean _noMachine) {
     // if no machine, don't connect to serial
    noMachine = _noMachine;
    if (noMachine) return; 
    // Connect to Serial
    print("[MachineController] SerialList: ");
    printArray(Serial.list());
    String portName = Serial.list()[portIndex]; //change the 0 to a 1 or 2 etc. to match your port
    port = new Serial(parent, portName, 9600); 
    // machine canvas   
    machineCanvas = createGraphics(1000, 1000);
  };

  void display () {
    // display current position of machine
    if (noMachine) return;
    // draw ellipse at current position
    
    machineCanvas.beginDraw();
    machineCanvas.background(0, 0);
    machineCanvas.noStroke();
    machineCanvas.fill(0, 255, 0, 50);
    machineCanvas.ellipse(currentPos.x, currentPos.y, 50, 50);
    machineCanvas.stroke(255, 0, 0);
    machineCanvas.line(currentPos.x-10, currentPos.y, currentPos.x+10, currentPos.y);
    machineCanvas.line(currentPos.x, currentPos.y-10, currentPos.x, currentPos.y+10);
    machineCanvas.endDraw();

    image(machineCanvas, canvas_margin, canvas_margin, width-(canvas_margin*2), height-(canvas_margin*2));
  }
}