public class Gui {

  int top_right_x = width - 60;
  int top_right_y = 20;

  int slider_width = 100;

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
    sliders();
  }

  void state_checkboxes () {
    for(int i = 0; i < states.length; i++) {
      // to lowercase and remove spaces
      String name = "set_" + states[i].toLowerCase();
      cp5.addToggle(name)
        .setPosition(top_right_x, top_right_y)
        .setSize(40, 20)
        .setValue(false) // states[state] == states[i]
        .setMode(ControlP5.CHECKBOX)
        ;
      top_right_y+=40;
    }
  }

  void buttons () {
    cp5.addToggle("set_autoNext")
      .setPosition(top_right_x, top_right_y)
      .setSize(40, 20)
      .setValue(autoNext) // states[state] == states[i]
      .setMode(ControlP5.CHECKBOX)
      ;
    top_right_y+=40;
    
    cp5.addToggle("set_loopOne")
      .setPosition(top_right_x, top_right_y)
      .setSize(40, 20)
      .setValue(loopOne) // states[state] == states[i]
      .setMode(ControlP5.CHECKBOX)
      ;
      
    top_right_y+=40;
    cp5.addButton("findHomeX")
      .setPosition(top_right_x, top_right_y)
      .setSize(40, 20)
      .getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE)
      ;
    top_right_y+=40;
    cp5.addButton("findHomeY")
      .setPosition(top_right_x, top_right_y)
      .setSize(40, 20) 
      .getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE)
      ;
    top_right_y+=40;
  }

  void sliders () {
    // microdelay (speed for steppers)
    cp5.addSlider("microdelaySlider")
      .setPosition(top_right_x - (slider_width/2), top_right_y)
      .setSize(slider_width, 20)
      .setRange(10, 1000)
      .setValue(default_microdelay);
    top_right_y+=40;
    cp5.getController("microdelaySlider")
      .getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE)
      .setPaddingX(0);
    
    // wait time
    cp5.addSlider("waitSlider")
      .setPosition(top_right_x - (slider_width/2), top_right_y)
      .setSize(slider_width, 20)
      .setRange(0, 120 * 1000)
      .setValue(waitTimeDefault);
    top_right_y+=40;
    cp5.getController("waitSlider")
      .getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.BOTTOM_OUTSIDE)
      .setPaddingX(0);
  }
}