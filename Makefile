# Makefile for FIFO-RRD
# $Id: Makefile,v 1.1 2005/09/26 20:02:27 gary Exp $

CC=gcc
CFLAGS=-Wall -W -pedantic -ansi
LIBS=
EXTLIBS=
DESTDIR=

modules = write_fifo

all: $(modules)

$(modules): %: %.c
	$(CC) $(CFLAGS) $(LIBS) $(EXTLIBS) -o $@ $<

.PHONY: clean
clean:
	rm -f $(modules)
