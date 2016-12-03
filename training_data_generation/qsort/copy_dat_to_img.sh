volume="linux-parsec-2-1-m5-with-test-inputs.img"
if mount | grep $volume; then
echo "linux-parsec-2-1-m5-with-test-inputs.img alread mounted!"
else
echo "linux-parsec-2-1-m5-with-test-inputs.img not mounted. So we will mount the image."
sudo mount -o,loop,offset=32256 ../../gemfi-dsn2015/dist/disks/linux-parsec-2-1-m5-with-test-inputs.img /mnt
fi

# Copy input data into image
if [ -d /mnt/mibench/qsort/input ]; then
	sudo rm -r /mnt/mibench/qsort/input
fi

sudo mkdir -p /mnt/mibench/qsort/input

sudo cp input_small*.dat /mnt/mibench/qsort/input
