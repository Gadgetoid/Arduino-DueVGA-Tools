/*
  This is an example of HSV to 8-bit colour,
  implemented mostly in integer maths for speed
  
  8-bit colour, RRRGGGBB, is suitable for use
  with the DueVGA library.
*/
#include <VGA.h>

#define RESX 320
#define RESY 240

int s = 0;

void setup() {
  VGA.begin(RESX,RESY,VGA_COLOUR); 
  for(int x = 0;x<RESX;x++){
    double h = map(x,0,319,0,360);
    for(int y = 0;y<RESY;y++){
      double v = map(y,0,239,0,100);
      VGA.putCPixelFast(
        x,
        y,
        hsv_to_rgb(h,100,v)
      );
    }
  }
}

void loop() {
}

unsigned char hsv_to_rgb(int H, int S, int V) 
{
  int r, g, b;
  int f, w, q, t, i;
  
  if( S == 0 ) return (round(V*0.07)<<5) + (round(V*0.07)<<2) + round(V * 0.03);

  i = H/60;
  f = (((H * 100) / 60) - (i * 100));
  w = V * (100 - S) / 100;
  q = V * (100 * 100 - (S * f)) / 10000;
  t = V * (100 * 100 - (S * (100 - f))) / 10000;
  switch( i ) {
    case 0: case 6: r = V, g = t, b = w; break;
    case 1: r = q, g = V, b = w; break;
    case 2: r = w, g = V, b = t; break;
    case 3: r = w, g = q, b = V; break;
    case 4: r = t, g = w, b = V; break;
    case 5: r = V, g = w, b = q; break;
  }
  return (round(r*0.07)<<5) + (round(g*0.07)<<2) + round(b * 0.03);
}
