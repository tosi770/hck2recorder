float beat[] = {0.75,0.25,0.75,0.25,1.0,0.5,0.75,0.25,0.75,0.25,1.0,0.5,1.0,0.5,0.5,1.0,0.5,0.5,0.75,0.25,0.5,0.5,0.75,0.25,0.5,0.75,0.25,0.75,0.25,0.5,0.5,0.5,0.5,0.75,0.25,0.75,0.25,0.5,0.5,0.5,1.0,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.75,0.25,1.0};
const int beatlength = sizeof(beat) / sizeof(beat[0]);
int index = 0;

void setup() {
  Serial.begin(9600);
  int index = 0;
}

void loop() {
  Serial.println("B");
  delay(beat[index]*1000);   //  BPM
  index++;
  if (index >= beatlength) {
    index = 0;
  }
  
}