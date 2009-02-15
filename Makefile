CC = gcc
CFLAGS = -O3 -march=nocona -ffast-math -fomit-frame-pointer 
#OMPFLAGS = -fopenmp

#CC=icc
#CFLAGS = -xP -fast
#OMPFLAGS = -openmp

MATLABDIR=/agbs/share/sw/matlab
INCLUDES=-I$(MATLABDIR)/extern/include
LDIRS= -L$(MATLABDIR)/bin/glnx86

EXE_TARGETS = chi2float chi2double chi2_mex.mexglx
LIB_TARGETS = libchi2.so
all:	$(EXE_TARGETS) $(LIB_TARGETS)

chi2float:	chi2float.c chi2float.h Makefile
	$(CC) -D__MAIN__  $(CFLAGS) $(OMPFLAGS) -o chi2float chi2float.c

chi2double: chi2double.c chi2double.h Makefile
	$(CC) -D__MAIN__  $(CFLAGS)  $(OMPFLAGS) -o chi2double chi2double.c

libchi2.so:	chi2double.c chi2double.h chi2float.c chi2float.h Makefile
	$(CC) $(CFLAGS) -shared -Wl,-soname=libchi2.so -fPIC chi2double.c chi2float.c -o libchi2.so

chi2double.o : chi2double.c chi2double.h Makefile
	$(CC) -D__MAIN__  $(CFLAGS) -c $(OMPFLAGS) -o chi2double.o chi2double.c

chi2_mex.o: chi2_mex.c
	$(CC) $(CFLAGS) -c $(INCLUDES) -o chi2_mex.o chi2_mex.c

chi2_mex.mexglx: 	chi2_mex.c chi2_mex.o chi2double.o
	$(CC) chi2_mex.o $(LDIRS) -lmex -shared -o chi2_mex.mexglx chi2double.o

# default installation of libomp cannot be opened using dlopen() as would be required e.g. for Python


clean:
	rm -f *.o $(EXE_TARGETS) $(LIB_TARGETS)

timing:	$(EXE_TARGETS)
	time ./chi2float
	time ./chi2double

