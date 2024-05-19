public class Gui {

  int top_right_x = width - 60;
  int top_right_y = 20;

  ControlP5 cp5;
  Gui(ControlP5 _cp5) {
    cp5 = _cp5;
    println("Gui created");
  }

  void init () {
    cp5.setColorForeground(color(255, 150));
    cp5.setColorBackground(color(255, 55));
    buttons();
    state_checkboxes();
  }

  void state_checkboxes () {
    for(int i = 0; i < states.length; i++) {
      // to lowercase and remove spaces
      String name = "set_" + states[i].toLowerCase();
      cp5.addToggle(name)
        .setPosition(top_right_x, top_right_y)
        .setSize(40, 20)
        .setValue(states[state] == states[i])
        .setLock(states[state] == states[i])
        .setMode(ControlP5.CHECKBOX)
        ;
      top_right_y+=40;
    }
  }

  void buttons () {
  }

}