FILE1 = basicmath_small.c   rad2deg.c  cubic.c   isqrt.c
FILE2 = basicmath_large.c   rad2deg.c  cubic.c   isqrt.c

all: basicmath_small basicmath_large basicmath_small_alpha basicmath_large_alpha

basicmath_small: ${FILE1} Makefile
	gcc -static -O3 ${FILE1} -o basicmath_small -lm
basicmath_small_alpha: ${FILE1} Makefile
	alpha-unknown-linux-gnu-gcc-3.4.3 -static -O3 ${FILE1} -o basicmath_small_alpha -lm -L./../../../gemfi-dsn2015/util/fi -I./../../../gemfi-dsn2015/util/fi ./../../../gemfi-dsn2015/util/fi/m5op_alpha_modified.S

basicmath_large: ${FILE2} Makefile
	gcc -static -O3 ${FILE2} -o basicmath_large -lm
basicmath_large_alpha: ${FILE2} Makefile
	alpha-unknown-linux-gnu-gcc-3.4.3 -static -O3 ${FILE2} -o basicmath_large_alpha -lm -L./../../../gemfi-dsn2015/util/fi -I./../../../gemfi-dsn2015/util/fi ./../../../gemfi-dsn2015/util/fi/m5op_alpha_modified.S

clean:
	rm -rf basicmath_small basicmath_small_alpha basicmath_large basicmath_large_alpha output*
