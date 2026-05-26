import processing.serial.*;
import ddf.minim.*;
import ddf.minim.ugens.*;

Serial myPort;
Minim minim;
AudioOutput out;
Oscil wave;



//音階
//C5, D5, C5, D5, C5, A4, A4, B4♭, A4, B4♭, A4, F4, 
//A4, F4, G4, A4, F4, G4, A4, B4♭, C5, C5, G4, A4, G4,
//C5, D5, C5, D5, C5, C5, A4, A4, A4, B4♭, A4, B4♭, C4, C4, F4,
//D5, C5, A4, C5, C5, A4, F4, C4, C4, G4, G4, E4

//時間
//beat受信がBのみなら
//１拍の長さが正確に取れない
//最低限bpmのデータは必要
//拍数は各楽器ごとに処理
//60(s)/beat内のbpm * 拍数 (秒分)
