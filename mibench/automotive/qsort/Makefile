FILE1 = qsort_small.c
FILE2 = qsort_large.c

all: qsort_small qsort_large qsort_small_alpha qsort_large_alpha

qsort_small: qsort_small.c Makefile
	gcc -static qsort_small.c -O3 -o qsort_small -lm
qsort_large: qsort_large.c Makefile
	gcc -static qsort_large.c -O3 -o qsort_large -lm

qsort_small_alpha: qsort_small.c Makefile
	alpha-unknown-linux-gnu-gcc-3.4.3 -static -O3 qsort_small.c -o qsort_small_alpha -lm -L./../../../gemfi-dsn2015/util/fi -I./../../../gemfi-dsn2015/util/fi ./../../../gemfi-dsn2015/util/fi/m5op_alpha_modified.S

qsort_large_alpha: qsort_large.c Makefile
	alpha-unknown-linux-gnu-gcc-3.4.3 -static -O3 qsort_large.c -o qsort_large_alpha -lm -L./../../../gemfi-dsn2015/util/fi -I./../../../gemfi-dsn2015/util/fi ./../../../gemfi-dsn2015/util/fi/m5op_alpha_modified.S

clean:
	rm -rf qsort_small qsort_large qsort_small_alpha qsort_large_alpha
