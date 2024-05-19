public class MachineController {
  Serial port;  // Create object from Serial class
  int portIndex = 1;

  MachineController(PApplet parent, boolean _noMachine) {
     // if no machine, don't connect to serial
    noMachine = _noMachine;
    if (noMachine) return; 
    // Connect to Serial
    print("[MachineController] SerialList: ");
    printArray(Serial.list());
    String portName = Serial.list()[portIndex]; //change the 0 to a 1 or 2 etc. to match your port
    port = new Serial(parent, portName, 9600);    
  };
}