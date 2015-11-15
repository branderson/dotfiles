#compiler
CC=gcc
#compiler options
OPTS=-Wall -g
#source files
SOURCES=$(wildcard *.c SomePath/*.c )
#object files
OBJECTS=$(SOURCES:.c=.o)
#sdl-config or any other library here. 
#``- ensures that the command between them is executed, and the result is put into LIBS
LIBS=m# `sdl-config --cflags --libs`
#executable filename
EXECUTABLE=out
#Special symbols used:
#$^ - is all the dependencies (in this case =$(OBJECTS) )
#$@ - is the result name (in this case =$(EXECUTABLE) )

all: $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(LINK.o) $^ -o $@ $(LIBS)

clean:
	rm $(EXECUTABLE) $(OBJECTS)
