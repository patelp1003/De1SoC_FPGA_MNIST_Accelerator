/*
 * Userspace program that communicates with the vga_ball device driver
 * through ioctls
 *
 * Stephen A. Edwards
 * Columbia University
 */

#include <stdio.h>
#include "vga_ball.h"
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>
#include <stdbool.h>
#include <stdint.h>
int vga_ball_fd;

/* Read and print the background color */
void print_background_color() {
  vga_ball_arg_t vla;
  
  if (ioctl(vga_ball_fd, VGA_BALL_READ_BACKGROUND, &vla)) {
      perror("ioctl(VGA_BALL_READ_BACKGROUND) failed");
      return;
  }
  printf("%02x %02x %02x\n",
	 vla.background.red, vla.background.green, vla.background.blue);
}

/* Set the background color */
void set_background_color(const vga_ball_color_t *c)
{
  vga_ball_arg_t vla;
  vla.background = *c;
      if (ioctl(vga_ball_fd, VGA_BALL_WRITE_BACKGROUND, &vla)) {
      perror("ioctl(VGA_BALL_SET_BACKGROUND) failed");
      return;
  }
}

void set_hv(const vga_ball_hv_t *c)
{
  vga_ball_arg_t vla;
  vla.hv = *c;
  if (ioctl(vga_ball_fd, VGA_BALL_WRITE_HV, &vla)) {
      perror("ioctl(VGA_BALL_SET_HV) failed");
      return;
  }
}

static unsigned char read_val()
{
 vga_ball_arg_t vla;
 
 if (ioctl(vga_ball_fd, VGA_BALL_READ_VAL, &vla)) {
      perror("ioctl(VGA_BALL_READ) failed");
      return;
  }
 //printf("%c\n", vla.read_val.val);
 return vla.read_val.val; 
}

static unsigned char read_pixel()
{
 vga_ball_arg_t vla;
 
 if (ioctl(vga_ball_fd, VGA_BALL_READ_PIXEL, &vla)) {
      perror("ioctl(VGA_BALL_READ) failed");
      return;
  }
 //printf("%c\n", vla.read_val.val);
 return vla.read_pixel.pixel_val; 
}

static unsigned char write_pixel(const vga_ball_write_pixel_t *c)
{
  vga_ball_arg_t vla;
  vla.write_pixel = *c;
      if (ioctl(vga_ball_fd, VGA_BALL_WRITE_PIXEL, &vla)) {
      perror("ioctl(VGA_BALL_SET_PIXEL_ADDR) failed");
      return;
  }
}

static unsigned char write_pixel_2(const vga_ball_write_pixel_2_t *c)
{
  vga_ball_arg_t vla;
  vla.write_pixel_2 = *c;
      if (ioctl(vga_ball_fd, VGA_BALL_WRITE_PIXEL_2, &vla)) {
      perror("ioctl(VGA_BALL_SET_PIXEL_ADDR) failed");
      return;
  }
}


int main()
{
  vga_ball_arg_t vla;
  int i;
  static const char filename[] = "/dev/vga_ball";

  static const vga_ball_color_t colors[] = {
    { 0xff, 0x00, 0x00 }, /* Red */
    { 0x00, 0xff, 0x00 }, /* Green */
    { 0x00, 0x00, 0xff }, /* Blue */
    { 0xff, 0xff, 0x00 }, /* Yellow */
    { 0x00, 0xff, 0xff }, /* Cyan */
    { 0xff, 0x00, 0xff }, /* Magenta */
    { 0x80, 0x80, 0x80 }, /* Gray */
    { 0x00, 0x00, 0x00 }, /* Black */
    { 0xff, 0xff, 0xff }  /* White */
  };

  vga_ball_hv_t hv_val = {0, 0};

# define COLORS 9

  printf("VGA ball Userspace program started\n");

  if ( (vga_ball_fd = open(filename, O_RDWR)) == -1) {
    fprintf(stderr, "could not open %s\n", filename);
    return -1;
  }

  printf("initial state: ");
  //print_background_color();
 
  unsigned char incoming;
  unsigned char incoming_old = -1;
  unsigned char incoming_pixel;
  unsigned char addr_lower=0;
  unsigned char addr_upper=0;
  vga_ball_write_pixel_t write_val; 
  vga_ball_write_pixel_2_t write_val_2;
  uint16_t 	counter;
  int           old_done=0;
  int done;
  int8_t results[10];
        //FILE *fptr;

        // Open a file in writing mode
        //fptr = fopen("image.txt", "w");
        //fprintf(fptr, "float image[] = {");



  while(1) {
	incoming = read_val();
  	//printf("incoming old: %d\n", incoming_old);
	//printf("incoming: %d\n", incoming);
	//FILE *fptr;

	// Open a file in writing mode
	//fptr = fopen("image.txt", "w");
	//fprintf(fptr, "float image[] = {");

	// Write some text to the file
	//fprintf(fptr, "Some text");
	if(incoming != incoming_old){
		//fptr = fopen("image.txt", "w");
        	//fprintf(fptr, "float image[] = {");

		printf("Button press: %d\n", incoming);
		incoming_old = incoming;
		//write_val.pixel_addr_lower = 2;
		write_val_2.pixel_addr_upper = 0;
                write_pixel_2(&write_val_2);
		
		for (int i = 0; i < 5; i++) {	

			write_val.pixel_addr_lower = 0x08 | i;
			write_pixel(&write_val);
			printf("Layer %d Go\n", i);
			printf("Value given: %d\n", 0x08 | i);
                	write_val.pixel_addr_lower = 0;
                	write_pixel(&write_val);
                	printf("Go deasserted\n");

			while((done = read_pixel())==old_done);
			old_done = done;
			printf("Layer %d Done\n", i);
			
			//incoming_pixel=read_pixel();
			//printf("counter %d \n ", counter);
                        //printf("Pixel address: %u, Pixel val: %u\n", write_val.pixel_addr_lower + (write_val.pixel_addr_upper*256), incoming_pixel);
			//fprintf(fptr, "%u\n", incoming_pixel);

		}

		printf("Accelerator completed\n");
		write_val_2.pixel_addr_upper = 0x80;

                for(int i = 0; i < 10; i++){
		write_pixel_2(&write_val_2);
		write_val_2.pixel_addr_upper++;
	        results[i] = read_pixel();
		printf("Digit %d: %d\n", i, results[i]); 
		}
		//fprintf(fptr, "};");
		//fclose(fptr);
	}
  }

  printf("VGA BALL Userspace program terminating\n");
  return 0;
}

