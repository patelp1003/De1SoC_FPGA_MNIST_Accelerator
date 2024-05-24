
#ifndef _VGA_BALL_H
#define _VGA_BALL_H

#include <linux/ioctl.h>

typedef struct{
	unsigned short val;
} vga_ball_read_t;

typedef struct{
        unsigned char pixel_val;
} vga_ball_read_pixel_t;

typedef struct{
        unsigned char  pixel_addr_lower;
	//unsigned char  pixel_addr_upper;
} vga_ball_write_pixel_t;

typedef struct{
        unsigned char  pixel_addr_upper;
        //unsigned char  pixel_addr_upper;
} vga_ball_write_pixel_2_t;

typedef struct {
	unsigned char red, green, blue;
} vga_ball_color_t;
  
typedef struct {
        unsigned short h, v;
} vga_ball_hv_t;

typedef struct {
  vga_ball_color_t background;
  vga_ball_hv_t hv;
  vga_ball_read_t read_val;
  vga_ball_read_pixel_t read_pixel;
  vga_ball_write_pixel_t write_pixel;
  vga_ball_write_pixel_2_t write_pixel_2;
} vga_ball_arg_t;




#define VGA_BALL_MAGIC 'q'

/* ioctls and their arguments */
#define VGA_BALL_WRITE_BACKGROUND _IOW(VGA_BALL_MAGIC, 1, vga_ball_arg_t *)
#define VGA_BALL_READ_BACKGROUND  _IOR(VGA_BALL_MAGIC, 2, vga_ball_arg_t *)
#define VGA_BALL_WRITE_HV _IOW(VGA_BALL_MAGIC, 3, vga_ball_arg_t *)
#define VGA_BALL_READ_HV _IOR(VGA_BALL_MAGIC, 4, vga_ball_arg_t *)
#define VGA_BALL_READ_VAL _IOR(VGA_BALL_MAGIC, 5,vga_ball_arg_t *) 
#define VGA_BALL_READ_PIXEL _IOR(VGA_BALL_MAGIC, 6,vga_ball_arg_t *) 
#define VGA_BALL_WRITE_PIXEL _IOW(VGA_BALL_MAGIC, 7,vga_ball_arg_t *) 
#define VGA_BALL_WRITE_PIXEL_2 _IOW(VGA_BALL_MAGIC, 8,vga_ball_arg_t *) 
#endif
