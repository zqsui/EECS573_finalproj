#!/usr/bin/env python
import random
import subprocess
import sys

def generate_input(seg_num, seg_len):
	# Read Input 
	with open("../../mibench/automotive/qsort/input_small.dat", "r") as f:
		lines = f.readlines()
		total_len = len(lines) 
		for i in range(1, seg_num + 1): 
			rnd_idx = random.sample(range(1,total_len), seg_len)	
			print rnd_idx

			# Generate test input	
			input_name = "input_small" + str(i) + ".dat"	
			with open(input_name, "wb") as input_w:
				for ind in rnd_idx:
					input_w.write(lines[ind])

			# Generate test bench
			test_bench_name = "qsort_small" + str(i) + ".rcS"
			with open(test_bench_name, "wb") as test_bench_w:
				test_bench_w.write("/sbin/m5 checkpoint 1 500000\n/sbin/m5 dumpresetstats 1 100000\necho \">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\"\necho \"Running qsort_small{} now ...\"\n./mibench/qsort/qsort_small_alpha ./mibench/qsort/input/input_small{}.dat\necho \"Finish test :D\"\necho \">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\"\n/sbin/m5 exit".format(i, i))	

		# Modify Benmarks.py
		content = []
		with open("../../gemfi-dsn2015/configs/common/Benchmarks.py", "r") as bc:
			content = bc.readlines()
			l = content.index("\t'test':  [SysConfig('test.rcS', '512MB')],\n")
			
			for i in range(1, seg_num + 1):
				content.insert(l+1, "\t'qsort_small{}':  [SysConfig('qsort_small{}.rcS')],\n".format(i, i))
			
			
		with open("../../gemfi-dsn2015/configs/common/Benchmarks.py", "w") as bc:
			bc.writelines(content)
			


	# Copy data into image 
	subprocess.call("./copy_dat_to_img.sh", shell=True)

	# Copy test bench to gemfi
	cmd = "cp *.rcS ./../../gemfi-dsn2015/configs/boot/"
	subprocess.call(cmd, shell=True)

if __name__ == "__main__":	
	#generate_input(10, 100)	

	
	
