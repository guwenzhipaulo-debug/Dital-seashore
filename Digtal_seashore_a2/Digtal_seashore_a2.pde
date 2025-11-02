import processing.sound.*;

// Digital Seashore — Breathing Wave + Calm Scrolling Subtitles (synced & slower)
int W = 800;
int H = 600;
float t = 0;

boolean nightMode = false;  // start with Day mode

// ---- breathing prompt state ----
String prompt = "Inhale...";
boolean inhalePhase = true;
float phaseTimer = 0;
float inhaleDur = 4.0f;   // slower breathing (seconds)
float exhaleDur = 7.5f;   // slower breathing (seconds)
int prevMillis = 0;

// ---- scrolling subtitles (public domain / safely usable lines) ----
String[] quotes = {
  "\"The sea is calm tonight.\" - Matthew Arnold, Dover Beach (1867)",
  "\"Come forth into the light of things; let Nature be your teacher.\" - William Wordsworth (1798)",
  "\"Peace comes dropping slow.\" - W. B. Yeats, The Lake Isle of Innisfree (1890)",
  "\"Rest, and be thankful.\" - Robert Louis Stevenson (1881)",
  "\"And I shall have some peace there.\" - W. B. Yeats, The Lake Isle of Innisfree (1890)",
  "\"The world is but a canvas to our imagination.\" - Henry David Thoreau (1857)",
};

boolean showSubtitles = true;
int quoteIndex = 0;
float subtitleX;                   // current x position
// pixels-per-second range; can tweak with arrow keys, but still modulated by breathing
float minPps = 18.0f;             // slowest (at deepest inhale)
float maxPps = 32.0f;             // fastest (at deepest exhale)
float subtitlePadding = 48;       // space after each line before next appears

SoundFile wavesSound;

void settings() {
  size(W, H);
}

void setup() {
  frameRate(60);
  textAlign(CENTER, CENTER);
  prevMillis = millis();
  subtitleX = width + 20;         // start just outside right edge

  wavesSound = new SoundFile(this, "waves.mp3");
  wavesSound.loop();
}

void draw() {
  // --- real dt in seconds ---
  int now = millis();
  float dt = (now - prevMillis) / 1000.0f;
  prevMillis = now;
  updatePrompt(dt);

  // ---- choose colors based on Day/Night ----
  color skyTop, skyBottom, sea;
  if (!nightMode) {
    skyTop    = color(135, 206, 250);
    skyBottom = color(255, 218, 185);
    sea       = color(64, 128, 255, 200);
  } else {
    skyTop    = color(11, 29, 59);
    skyBottom = color(30, 39, 71);
    sea       = color(50, 90, 150, 200);
  }

  // ---- gradient background ----
  for (int y = 0; y < H; y++) {
    float k = map(y, 0, H, 0, 1);
    stroke(lerpColor(skyTop, skyBottom, k));
    line(0, y, W, y);
  }
  noStroke();

  // ---- breathing envelope (0..1 smooth) ----
  float p = breathingProgress();               // 0..1 (smooth; inhale->1, exhale->0)
  float waveBaseAmp = 12;
  float waveExtraAmp = 14;
  float waveAmp = waveBaseAmp + waveExtraAmp * p;   // inhale bigger waves
  float seaLevel = H * 0.60f - 6 * (p - 0.5f);      // gentle vertical sway

  // ---- draw wave ----
  fill(sea);
  beginShape();
  vertex(0, H);
  for (int x = 0; x <= W; x += 5) {
    float yy = seaLevel + sin(x * 0.02f + t) * waveAmp;
    vertex(x, yy);
  }
  vertex(W, H);
  endShape(CLOSE);

  // ---- labels ----
  fill(255);
  textSize(36);
  text("Digital Seashore", width/2, 50);

  textSize(16);
  text("A: Day/Night  |  S: Subtitles  |  Left/Right: base speed", width/2, H - 40);

  // ---- breathing prompt ----
  textSize(24);
  text(prompt, width/2, H - 80);

  // ---- scrolling subtitles synced to breathing ----
  if (showSubtitles) {
    drawScrollingSubtitle(dt, p);
  }

  t += 0.05f;
}

// ---- keys ----
void keyPressed() {
  if (key == 'a' || key == 'A') {
    nightMode = !nightMode;
  } else if (key == 's' || key == 'S') {
    showSubtitles = !showSubtitles;
  } else if (keyCode == LEFT) {
    minPps = max(8.0f, minPps - 2.0f);
    maxPps = max(minPps + 6.0f, maxPps - 2.0f);
  } else if (keyCode == RIGHT) {
    maxPps = min(60.0f, maxPps + 2.0f);
    minPps = min(maxPps - 6.0f, minPps + 2.0f);
  }
}

// ---- breathing state update ----
void updatePrompt(float dt) {
  float dur = inhalePhase ? inhaleDur : exhaleDur;
  phaseTimer += dt;
  if (phaseTimer >= dur) {
    inhalePhase = !inhalePhase;
    prompt = inhalePhase ? "Inhale..." : "Exhale...";
    phaseTimer = 0;
  }
}

// ---- smooth breathing progress (0->1->0) ----
float breathingProgress() {
  float dur = inhalePhase ? inhaleDur : exhaleDur;
  float progress = constrain(phaseTimer / dur, 0, 1);
  // cosine easing for softness
  if (inhalePhase) {
    return (1 - cos(progress * PI)) * 0.5f;  // 0 -> 1
  } else {
    return (1 + cos(progress * PI)) * 0.5f;  // 1 -> 0
  }
}

// ---- draw and advance the scrolling subtitle, speed synced to breathing ----
void drawScrollingSubtitle(float dt, float p) {
  String q = quotes[quoteIndex];

  // translucent backdrop for legibility
  noStroke();
  fill(0, 0, 0, 60);
  rect(0, H - 28, width, 28);

  // text settings
  fill(255);
  textAlign(LEFT, CENTER);
  textSize(14);

  float y = H - 14;

  // breathing-synced speed (pixels per second):
  // at inhale peak (p->1), use minPps; at exhale base (p->0), use maxPps
  float pps = lerp(maxPps, minPps, p);

  // draw current quote
  text(q, subtitleX, y);

  // per-second motion
  float tw = textWidth(q);
  subtitleX -= pps * dt;

  // when fully off-screen at left, advance
  if (subtitleX < -tw - subtitlePadding) {
    quoteIndex = (quoteIndex + 1) % quotes.length;
    subtitleX = width + subtitlePadding;
  }

  // restore center align
  textAlign(CENTER, CENTER);
}
