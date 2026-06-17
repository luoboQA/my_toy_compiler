CXX = g++
CXXFLAGS = -g -O0 -Wall -Wextra

LLVMCONFIG = llvm-config
LLVM_AVAILABLE := $(shell command -v $(LLVMCONFIG) 2> /dev/null)

ifneq ($(LLVM_AVAILABLE),)
    CPPFLAGS = `$(LLVMCONFIG) --cppflags` -std=c++14
    LDFLAGS = `$(LLVMCONFIG) --ldflags` -lpthread -ldl -lz -lncurses -rdynamic
    LIBS = `$(LLVMCONFIG) --libs`
else
    CPPFLAGS = -std=c++14
    LDFLAGS = -lpthread
    LIBS = 
endif

OBJS = parser.o codegen.o main.o tokens.o corefn.o native.o

all: parser

parser.cpp: parser.y
	bison -d -o $@ $^

parser.hpp: parser.cpp

tokens.cpp: tokens.l parser.hpp
	flex -o $@ $^

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $(CPPFLAGS) -o $@ $<

parser: $(OBJS)
	$(CXX) $(CXXFLAGS) -o $@ $(OBJS) $(LIBS) $(LDFLAGS)

test: parser example.txt
	./parser < example.txt

clean:
	$(RM) -rf parser.cpp parser.hpp tokens.cpp $(OBJS) parser

.PHONY: all clean test
