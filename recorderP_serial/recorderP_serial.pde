// =============================================
// Processing プログラム（リコーダー担当）シリアル通信対応版
// Minimライブラリ使用・倍音+ビブラート合成版
// シリアル通信：1=1拍進める, 0=停止
// =============================================

import processing.serial.*;
import ddf.minim.*;
import ddf.minim.ugens.*;
import javax.sound.sampled.*;

Serial myPort;
Minim minim;
AudioOutput out;
Oscil wave;
Oscil wave2;
Oscil volumeVibrato;
ADSR envelope;

// 楽譜データ
float[] notes = {
  523.3, 587.3, 523.3, 587.3, 523.3, 440.0, 440.0, 466.2,
  440.0, 466.2, 440.0, 349.2, 440.0, 349.2, 392.0, 440.0,
  349.2, 392.0, 440.0, 466.2, 523.3, 523.3, 392.0, 440.0,
  392.0, 523.3, 587.3, 523.3, 587.3, 523.3, 523.3, 440.0,
  440.0, 440.0, 466.2, 440.0, 466.2, 440.0, 440.0, 349.2,
  587.3, 523.3, 440.0, 523.3, 523.3, 440.0, 349.2, 440.0,
  440.0, 392.0, 392.0, 349.2
};
float[] beat = {
  0.75, 0.25, 0.75, 0.25, 1.0,  0.5,
  0.75, 0.25, 0.75, 0.25, 1.0,  0.5,
  1.0,  0.5,  0.5,  1.0,  0.5,  0.5,
  0.75, 0.25, 0.5,  0.5,  0.75, 0.25, 0.5,
  0.75, 0.25, 0.75, 0.25, 0.5,  0.5,  0.5,  0.5,
  0.75, 0.25, 0.75, 0.25, 0.5,  0.5,  0.5,
  1.0,  0.5,  0.5,  0.5,  0.5,  0.5,  0.5,  0.5,  0.5,
  0.75, 0.25, 1.0
};

// 再生状態（tick方式）
int     index          = 0;
float   ticksRemaining = 0;
boolean playing        = false;

// =============================================
// setup()
// =============================================
void setup() {
  size(600, 400);
  pixelDensity(1);

  println(Serial.list());
  myPort = new Serial(this, Serial.list()[3], 9600);
  myPort.bufferUntil('\n');

  minim = new Minim(this);
  Mixer.Info[] mixerInfo = AudioSystem.getMixerInfo();
  for (int i = 0; i < mixerInfo.length; i++) {
    println(i + " = " + mixerInfo[i].getName());
  }

  Mixer mixer = AudioSystem.getMixer(mixerInfo[5]);
  minim.setOutputMixer(mixer);

  out = minim.getLineOut(Minim.STEREO, 2048);

  envelope = new ADSR(0.5, 0.05, 0.02, 0.85, 0.08);

  wave  = new Oscil(notes[0],     0.5,  Waves.SINE);
  wave2 = new Oscil(notes[0] * 2, 0.05, Waves.SINE);
  volumeVibrato = new Oscil(5.0, 0.3, Waves.SINE);
  volumeVibrato.offset.setLastValue(0.5);
  volumeVibrato.patch(wave.amplitude);
  wave.patch(envelope).patch(out);
  wave2.patch(envelope).patch(out);

  background(0);
  println("シリアル待機中...");
}

// =============================================
// draw()
// =============================================
void draw() {
  background(30, 30, 50);
  drawWaveform(out);

  fill(255);
  noStroke();
  textSize(16);
  text("ゆきやこんこ - リコーダー倍音合成", 20, 30);

  fill(playing ? color(0, 255, 200) : color(180));
  textSize(13);
  text(playing ? "● 演奏中" : "■ 停止中", 20, 55);

  if (playing && index < notes.length) {
    fill(255);
    text("音符: " + (index + 1) + " / " + notes.length, 20, 80);
    text("周波数: " + nf(notes[index], 0, 1) + " Hz",   20, 100);
    text("拍数: " + beat[index] + " 拍",                 20, 120);
  }
}

// =============================================
// serialEvent()
// 1=1拍進める, 0=停止
// =============================================
void serialEvent(Serial p) {
  String line = p.readStringUntil('\n');
  if (line == null) return;
  line = trim(line);
  if (!line.matches("-?\\d+")) return;
  handleSignal(int(line));
}

void handleSignal(int v) {
  if (v == 0) {
    stopPlaying();
  } else {
    if (!playing) startPlaying();
    onTick();
  }
}

void startPlaying() {
  playing        = true;
  index          = 0;
  ticksRemaining = 0;
  volumeVibrato.patch(wave.amplitude);
  println("演奏開始");
}

void stopPlaying() {
  if (!playing) return;
  playing        = false;
  index          = 0;
  ticksRemaining = 0;
  envelope.noteOff();
  volumeVibrato.unpatch(wave.amplitude);
  wave.amplitude.setLastValue(0);
  wave2.amplitude.setLastValue(0);
  println("演奏停止");
}

// =============================================
// onTick()：0.25拍ぶん進める 
// =============================================
void onTick() {
  if (ticksRemaining > 0.25) {
    ticksRemaining -= 0.25;
    return;
  }
  envelope.noteOff();
  ticksRemaining = beat[index];
  playNextNote();
  index++;
  if (index >= notes.length) index = 0;
}

// =============================================
// playNextNote()
// =============================================
void playNextNote() {
  println("鳴らす: " + notes[index]);
  wave.setFrequency(notes[index]);
  wave2.setFrequency(notes[index] * 2);
  envelope.noteOn();
}

// =============================================
// drawWaveform()
// =============================================
void drawWaveform(AudioOutput output) {
  stroke(100, 200, 255);
  strokeWeight(2);
  noFill();
  beginShape();
  for (int i = 0; i < output.bufferSize() - 1; i++) {
    float x = map(i, 0, output.bufferSize(), 0, width);
    float y = map(output.mix.get(i), -1, 1, 0, height);
    vertex(x, y);
  }
  endShape();
}

void stop() {
  out.close();
  minim.stop();
  super.stop();
}
