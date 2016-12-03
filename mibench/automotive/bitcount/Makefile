FILE = bitcnt_1.c bitcnt_2.c bitcnt_3.c bitcnt_4.c bitcnts.c bitfiles.c bitstrng.c bstr_i.c 

all: bitcnts bitcnts_alpha

bitcnts: ${FILE} Makefile
	gcc -static ${FILE} -O3 -o bitcnts

bitcnts_alpha: ${FILE} Makefile
	alpha-unknown-linux-gnu-gcc-3.4.3 -static -O3 ${FILE} -o bitcnts_alpha -lm -L./../../../gemfi-dsn2015/util/fi -I./../../../gemfi-dsn2015/util/fi ./../../../gemfi-dsn2015/util/fi/m5op_alpha_modified.S

clean:
	rm -rf bitcnts bitcnts_alpha 
