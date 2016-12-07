#!/usr/bin/env python
import subprocess
import sys
import time

def run(num_min, num_max):
	for i in range(int(num_min), int(num_max) + 1):
		print(i)
		cmd = "dmtcp_launch build/ALPHA/gem5.opt -re -d ./fi_output/GeneralFetchInjectedFault/qsort_small{} --debug-flags=FaultInjection configs/example/fs.py --cpu-type=detailed --caches --l2cache -b qsort_small1 --checkpoint-restore 1 --checkpoint-dir ./checkpoints/qsort_small --fi-in generated_faults/qsort_small/input_fault{} --restore-with-cpu detailed --switch-on-fault 0".format(str(i), str(i))
		print(cmd)
			
		start = time.time()
		subprocess.call(cmd, shell=True, timeout=120)
		elapsed = (time.time() - start)
		print("Elapsed time:", elapsed)	

if __name__ == "__main__":
	run(sys.argv[1], sys.argv[2])
