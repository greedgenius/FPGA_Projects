# File: makefile
# Author: Aaron Odell
# Company: Digilent Inc.
# Date: 8/16/2010
# Description: makefile for Adept SDK EnumDemo

CC = gcc
INC = /usr/local/include/digilent/adept
LIBDIR = /usr/local/lib/digilent/adept
TARGETS = EnumDemo
CFLAGS = -I $(INC) -L $(LIBDIR) 

all: $(TARGETS)

EnumDemo:
	$(CC) $(CFLAGS) -o EnumDemo EnumDemo.cpp -ldmgr
	

.PHONY: vclean

vclean:
	rm -f $(TARGETS)

