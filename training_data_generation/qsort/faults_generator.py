#!/usr/bin/env python
import random
import subprocess

def generate_fault(num_input, num_fault):

	inst = random.sample(range(1, 8000), 10)
	bits = random.sample(range(1, 64), 10)

	print inst
	print bits
	cmd = "mkdir -p ./../../gemfi-dsn2015/generated_faults/qsort_small"	
	subprocess.call(cmd, shell=True)

	for i in range(1, num_input + 1):			
		input_file_name = "input_fault" + str(i)
		print input_file_name	
		with open(input_file_name, "w") as f:
			f.write("GeneralFetchInjectedFault Inst:{} Flip:{} all all 1\n".format(inst[i-1], bits[i-1]))

		cmd = "cp {} ./../../gemfi-dsn2015/generated_faults/qsort_small/".format(input_file_name)
		subprocess.call(cmd, shell=True)
		
	

if __name__ == "__main__":
    generate_fault(10, 10)
