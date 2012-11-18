# File: Makefile
# Author: Aaron Odell
# Company: Digilent Inc.
# Date: 8/16/2010
# Description: makefile for Adept SDK DeppDemo

CC = gcc
INC = /usr/local/include/digilent/adept
LIBDIR = /usr/local/lib/digilent/adept
TARGETS = DeppAdder
CFLAGS = -I $(INC) -L $(LIBDIR) 

all: $(TARGETS)

DeppAdder:
	$(CC) $(CFLAGS) -o DeppAdder DeppAdder.cpp -ldepp -ldmgr
	

.PHONY: vclean

vclean:
	rm -f $(TARGETS)

