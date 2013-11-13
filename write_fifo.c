/* $Id: write_fifo.c,v 1.2 2005/09/26 20:02:27 gary Exp $
 *
 * write_fifo.c -- write a string to FIFO
 *
 * Copyright (C) Gary Wall & Fredrik Löhr 2005
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#include <stdio.h>
#include <fcntl.h>
#include <getopt.h>
#include <string.h>
#include <unistd.h>

char *fifo = NULL;
char *str = NULL;

int parse_args(int argc, char **argv)
{     
  int c;
  opterr = 0;
    
  while ((c = getopt(argc, argv, ":p:s:")) != -1) {
    switch (c) {
      case 'p':
        fifo = optarg;
        break;
      case 's':
        str = optarg;
        break;
      case '?':
        printf("Usage: ./write_fifo -p <pipe> -s <string>\n");
        exit(1);
    }
  }
  
  if (pipe != NULL && str != NULL)
    return 1;

  return 0;
}

int main(int argc, char **argv)
{
  int fd;

  if (!parse_args(argc, argv)) {
    printf("Usage: ./write_fifo -p <pipe> -s <string>\n");
    exit(1);
  }

  if (!(fd = open(fifo, O_WRONLY|O_NONBLOCK))) {
    printf("Could'nt open FIFO for writing\n");
    exit(1);
  }

  write(fd, str, strlen(str));
  close(fd);

  return 0;
}
