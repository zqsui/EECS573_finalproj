#cd basicmath
#make basicmath_small_alpha

#cd ../bitcount
#make

cd qsort
make qsort_small_alpha qsort_large_alpha

#cd ../susan
#make

cd ../
sudo mount -o,loop,offset=32256 ../../gemfi-dsn2015/dist/disks/linux-parsec-2-1-m5-with-test-inputs.img /mnt
#if [ ! -d /mnt/mibench/basicmath ]; then
#	sudo mkdir -p /mnt/mibench/basicmath
#fi
#sudo cp basicmath/basicmath_large_alpha /mnt/mibench/basicmath
#sudo cp basicmath/basicmath_small_alpha /mnt/mibench/basicmath
#
#if [ ! -d /mnt/mibench/bitcount ]; then
#	sudo mkdir -p /mnt/mibench/bitcount
#fi
#sudo cp bitcount/bitcnts_alpha /mnt/mibench/bitcount

if [ ! -d /mnt/mibench/qsort ]; then
	sudo mkdir -p /mnt/mibench/qsort
fi
sudo cp qsort/qsort_small_alpha /mnt/mibench/qsort
sudo cp qsort/qsort_large_alpha /mnt/mibench/qsort
sudo cp qsort/input_small.dat /mnt/mibench/qsort
sudo cp qsort/input_large.dat /mnt/mibench/qsort

#if [ ! -d /mnt/mibench/susan ]; then
#	sudo mkdir -p /mnt/mibench/susan
#fi
#sudo cp susan/susan_alpha /mnt/mibench/susan
#sudo cp susan/input_small.pgm /mnt/mibench/susan
#sudo cp susan/input_large.pgm /mnt/mibench/susan
