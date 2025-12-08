# Makefile - build every .cu into an executable with the same base name (no extension)

NVCC ?= nvcc
GCC ?= g++
#NVCCFLAGS ?= -O2 -std=c++14
NVCCFLAGS ?= -g -Werror all-warnings
GCCFLAGS ?= -g -Wall
LDFLAGS ?=

SRCS := $(wildcard *.cu)
EXES := $(SRCS:.cu=.x)
SRCS := $(SRCS) $(wildcard *.cpp)
EXES := $(EXES) $(SRCS:.cpp=.x)
$(info $(SRCS))
$(info $(EXES))

.PHONY: all clean help
all: $(EXES)
ifeq ($(strip $(EXES)),)
	@echo "No .cu files found."
endif

# Pattern rule: build executable (no extension) from .cu source
%.x: %.cpp
	$(GCC) $(GCCFLAGS) $< -o $@ $(LDFLAGS)

# Pattern rule: build executable (no extension) from .cu source
%.x: %.cu
	$(NVCC) $(NVCCFLAGS) $< -o $@ $(LDFLAGS)

clean:
	-@rm -f $(EXES) *.o *~ a.out

help:
	@echo "Usage:"
	@echo "  make        Build all CUDA executables (produces files with no extension)"
	@echo "  make exe    Build specific executable 'exe' from 'exe.cu'"
	@echo "  make -jN    Parallel build"
	@echo "  make clean  Remove built executables"
