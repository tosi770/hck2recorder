import processing.serial.*;
import ddf.minim.*;
import ddf.minim.ugens.*;

Serial myPort;
Minim minim;
AudioOutput out;
Oscil wave;

float[] notes = {523.3, 587.3, 523.3, 587.3, 523.3, 440.0, 440.0, 466.2, 440.0, 466.2, 440.0, 349.2, 440.0, 349.2, 392.0, 440.0, 349.2, 392.0, 440.0, 466.2, 523.3, 523.3, 392.0, 440.0, 392.0, 523.3, 587.3, 523.3, 587.3, 523.3, 523.3, 440.0, 440.0, 440.0, 466.2, 440.0, 466.2, 261.6, 261.6, 349.2, 587.3, 523.3, 440.0, 523.3, 523.3, 440.0, 349.2, 440.0, 440.0, 392.0, 392.0, 349.2};
float[] beat = {0.75,0.25,0.75,0.25,1.0,0.5,0.75,0.25,0.75,0.25,1.0,0.5,1.0,0.5,0.5,1.0,0.5,0.5,0.75,0.25,0.5,0.5,0.75,0.25,0.5,0.75,0.25,0.75,0.25,0.5,0.5,0.5,0.5,0.75,0.25,0.75,0.25,0.5,0.5,0.5,1.0,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.75,0.25,1.0};
int index = 0;

void setup() {
  size(400, 200);
  pixelDensity(1);
  println(Serial.list());   // ポート確認用
  myPort = new Serial(this, Serial.list()[3], 9600);

  minim = new Minim(this);
  out = minim.getLineOut();

  wave = new Oscil(notes[0], 0.5, Waves.TRIANGLE);
  wave.patch(out);
}

void draw() {
  background(0);
  
  if (myPort.available() > 0) {
    String data = myPort.readStringUntil('\n');

    if (data != null) {
      data = trim(data);

      if (data.equals("B")) {
        playNextNote();
      }
    }
  }
}

void playNextNote() {
  wave.setFrequency(notes[index]);

  index++;
  if (index >= notes.length) {
    index = 0;
  }
}



//音階　
//C5, D5, C5, D5,| C5, A4,| A4, B4♭, A4, B4♭,| A4, F4, 
//A4, F4, G4,| A4, F4, G4,| A4, B4♭, C5, C5,| G4, A4, G4,
//C5, D5, C5, D5,| C5, C5, A4, A4,| A4, B4♭, A4, B4♭,| C4, C4, F4,
//D5, C5, A4,| C5, C5, A4, F4,| C4, C4, G4, G4,| F4

//拍
//0.75,0.25,0.75,0.25,1.0,0.5,0.75,0.25,0.75,0.25,1.0,0.5,
//1.0,0.5,0.5,1.0,0.5,0.5,0.75,0.25,0.5,0.5,0.75,0.25,0.5,
//0.75,0.25,0.75,0.25,0.5,0.5,0.5,0.5,0.75,0.25,0.75,0.25,0.5,0.5,0.5,
//1.0,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.75,0.25,1.0


//時間
//beat受信がBのみなら
//１拍の長さが正確に取れない
//最低限bpmのデータは必要
//拍数は各楽器ごとに処理
//60(s)/beat内のbpm * 拍数 (秒分)
