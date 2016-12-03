FILE = src/hello_fi.c 

all: hello_fi_alpha 

hello_fi_alpha: ${FILE1} Makefile
	alpha-unknown-linux-gnu-gcc-3.4.3 -static -O3 ${FILE} -o hello_fi_alpha -lm -L./../../../util/fi -I./../../../util/fi ./../../../util/fi/m5op_alpha_modified.S

clean:
	rm -rf hello_fi_alpha 
