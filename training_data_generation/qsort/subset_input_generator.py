#!/usr/bin/env python
import random
import subprocess
import sys

if __name__ == "__main__":	
	seg_num = 10
	seg_len = 100

	# Read Input 
	with open("../../mibench/automotive/qsort/input_small.dat", "r") as f:
		lines = f.readlines()
		total_len = len(lines) 
		for i in range(1, seg_num + 1): 
			rnd_idx = random.sample(range(1,total_len), seg_len)	
			print rnd_idx

			input_name = "input_small" + str(i) + ".dat"
			
			with open(input_name, "wb") as input_w:
				for ind in rnd_idx:
					input_w.write(lines[ind])


	# Copy data into image 
	subprocess.call("./copy_dat_to_img.sh", shell=True)
