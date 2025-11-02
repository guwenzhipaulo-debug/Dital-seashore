# Digital Seashore

A Processing sketch that creates a calm, breathing seashore. The wave, subtitles, and breathing prompt all follow the same **5.5 s inhale / 5.5 s exhale** cycle, based on HRV-style slow breathing (Lehrer et al., 2000; Pandekar & Thangavelu, 2019). Users can switch day/night, show/hide subtitles, and change the base scroll speed.

## Features
- Gradient sky + sine-wave sea
- Breathing system with cosine easing (`updatePrompt()` + `breathingProgress()`)
- Subtitles with public-domain literary quotes, speed synced to breathing
- Day/Night toggle (**A**)
- Subtitle toggle (**S**)
- **Left/Right** arrows to fine-tune base scroll speed
- Looping ocean sound (`waves.mp3`) via Processing Sound library

## Requirements
- Processing 4.x
- Sound library (built-in):  
  `Sketch → Import Library… → Add Library… → search "Sound" → Install`
- A file named **`waves.mp3`** placed in the sketch’s `data/` folder

## How to run
1. Open the `.pde` file in Processing.
2. Make sure the project has this structure:

   ```text
   DigitalSeashore/
   ├── DigitalSeashore.pde
   └── data/
       └── waves.


   Click Run.

If you see Sound library error: unable to find file waves.mp3, check:

the folder name is exactly data

the file name is exactly waves.mp3

the file is not inside another subfolder

Controls

A – toggle Day / Night

S – show / hide subtitles

← / → – decrease / increase base subtitle speed

Scene breathes automatically every 5.5 s + 5.5 s
