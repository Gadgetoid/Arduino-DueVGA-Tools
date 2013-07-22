#include <crntsc.h>
#include <crpal.h>
#include <VGA.h>
#include "sprites.h"

// Max resolution for 256 colour mode
#define RESX 320
#define RESY 240

int current_frame  = 0;
int character_left = 0;
int character_top  = RESY - sonic[1] - 10;

int get_frame_count(unsigned char sprite[])
{
  return sprite[2];
}

int get_width(unsigned char sprite[])
{
  return sprite[0];
}

void draw_sprite_at_frame(unsigned char sprite[],unsigned char blend[],int current_frame,int o_left,int o_top){
  
  int w = sprite[0];
  int h = sprite[1];
  int count = sprite[2];
  
  int frame_offset = (w*h) * current_frame;

  for(int x = 0;x<w;x++){
   
     for(int y = 0;y<h;y++){
       
       int pixel_offset = (w * y) + x;
       int unpacked_pixel = 0;
       int packed_pixel = 0;
       int offset = frame_offset + pixel_offset;
       
       packed_pixel = sprite[3+(int)floor(offset/2)];
       
       if(offset % 2){
          unpacked_pixel = packed_pixel & 0xf;
       }
       else
       {
          unpacked_pixel = (packed_pixel >> 4) & 0xf;
       }

       if( unpacked_pixel != 0 ){
         VGA.putCPixelFast(o_left+x,o_top+y,sonic_palette[unpacked_pixel-1]);
       }
       else
       {
         //int i = x+o_left;
         //int j = y+o_top;
         //VGA.putCPixelFast(i,j,backdrop[(j*320) + i]);
        VGA.putCPixelFast(x+o_left,y+o_top, blend[(y*w) + x]);
       }
       
     } 
    
  }
}

void draw_image(int width,int height,int left,int top){
  for(int x = 0;x<width;x++){
   for(int y = 0;y<height;y++){
    VGA.putCPixelFast(left+x,top+y,backdrop[y*width + x]);
   } 
  }
}

unsigned char *get_image_sample(int src_width,int width,int height,int left,int top){
  unsigned char buf[width*height];
  for(int x = 0;x<width;x++){
   for(int y = 0;y<height;y++){
     int i = x+left;
     int j = y+top;
     buf[y*width + x] = backdrop[(j*src_width) + i];
     //VGA.putCPixelFast(pos_left+x,pos_top+y, backdrop[(j*src_width) + i]);
   }
  }
  return buf;
}

/*
  Draws the 256 colour table, for colour reproduction debugging
*/
void draw_colour_table(int left,int top){
    // Horizontal block of 4*8 pixels
  for(int c = 0;c < 8;c++){
    // 8 down
    for(int d = 0;d < 8;d++){
      // 4 across
      for(int a = 0;a < 4;a++){
         int x = (c*4) + a;
         int y = d;
         
         int offset = c*32;
        
         VGA.putCPixelFast(left+x,top+y,offset + (4*d) + a);
      }
    }
  }
}

void setup() {
  VGA.begin(RESX,RESY,VGA_COLOUR);
  draw_image(RESX,RESY,0,0);
  draw_colour_table(10,10);
}

void loop() {
   
    //draw_image_sample(320,32,32,character_left,character_top,character_left,character_top);

    character_left++;
    if(character_left % 10 == 0){
      current_frame++;
    }  
    
    if( character_left > RESX+get_width(sonic) )
    {
      character_left = get_width(sonic);
    }
    if(current_frame >= get_frame_count(sonic)){
      current_frame = 0; 
    }
    
    draw_sprite_at_frame(sonic,
        get_image_sample(320,34,34,character_left,character_top),
        current_frame,character_left,character_top);
    
    //delay(10);
  
}
