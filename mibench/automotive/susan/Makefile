all: susan susan_alpha

susan: susan.c Makefile
	gcc -static -O4 -o susan susan.c -lm 

susan_alpha: susan.c Makefile
	alpha-unknown-linux-gnu-gcc-3.4.3 -static -O3 susan.c -o susan_alpha -lm -L./../../../gemfi-dsn2015/util/fi -I./../../../gemfi-dsn2015/util/fi ./../../../gemfi-dsn2015/util/fi/m5op_alpha_modified.S


clean:
	rm -rf susan susan_alpha 
