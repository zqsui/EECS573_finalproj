#!/usr/bin/env python
import copy
import csv
import hashlib
import os
import random

skip_features = ['host_inst_rate', 'host_op_rate', 'host_tick_rate', 'host_mem_usage', 'host_seconds', 'system.tsunami.ethernet.descDMAReads', 'system.tsunami.ethernet.descDMAWrites', 'system.tsunami.ethernet.descDmaReadBytes', 'system.tsunami.ethernet.descDmaWriteBytes', 'system.tsunami.ethernet.postedSwi', 'system.tsunami.ethernet.coalescedSwi', 'system.tsunami.ethernet.totalSwi', 'system.tsunami.ethernet.postedRxIdle', 'system.tsunami.ethernet.coalescedRxIdle', 'system.tsunami.ethernet.totalRxIdle', 'system.tsunami.ethernet.postedRxOk', 'system.tsunami.ethernet.coalescedRxOk', 'system.tsunami.ethernet.totalRxOk', 'system.tsunami.ethernet.postedRxDesc', 'system.tsunami.ethernet.coalescedRxDesc', 'system.tsunami.ethernet.totalRxDesc', 'system.tsunami.ethernet.postedTxOk', 'system.tsunami.ethernet.coalescedTxOk', 'system.tsunami.ethernet.totalTxOk', 'system.tsunami.ethernet.postedTxIdle', 'system.tsunami.ethernet.coalescedTxIdle', 'system.tsunami.ethernet.totalTxIdle', 'system.tsunami.ethernet.postedTxDesc', 'system.tsunami.ethernet.coalescedTxDesc', 'system.tsunami.ethernet.totalTxDesc', 'system.tsunami.ethernet.postedRxOrn', 'system.tsunami.ethernet.coalescedRxOrn', 'system.tsunami.ethernet.totalRxOrn', 'system.tsunami.ethernet.coalescedTotal', 'system.tsunami.ethernet.postedInterrupts', 'system.tsunami.ethernet.droppedPackets', 'system.cpu.dcache.blocked_cycles::no_targets','system.cpu.iq.FU_type_0::SimdAddAcc','system.cpu.iq.FU_type_0::SimdFloatAlu','system.cpu.iew.lsq.thread0.invAddrLoads','system.mem_ctrls.readPktSize::0','system.mem_ctrls.readPktSize::1','system.mem_ctrls.readPktSize::2','system.mem_ctrls.readPktSize::3','system.mem_ctrls.readPktSize::4','system.mem_ctrls.readPktSize::5','system.cpu.itb.read_misses','system.cpu.iq.fu_full::FloatDiv','system.cpu.dtb.fetch_accesses','system.cpu.iq.fu_full::SimdMisc','system.cpu.iew.iewIdleCycles','system.cpu.numWorkItemsStarted','system.cpu.iq.FU_type_0::FloatMult','system.cpu.iq.fu_full::IntMult','system.cpu.itb.data_misses','system.cpu.commit.committed_per_cycle::overflows','system.cpu.iq.fu_full::SimdFloatMult','system.cpu.iq.fu_full::FloatMult','system.cpu.dcache.cache_copies','system.cpu.icache.no_allocate_misses','system.cpu.icache.cache_copies','system.cpu.iq.FU_type_0::FloatSqrt','system.cpu.iq.FU_type_0::SimdMisc','system.cpu.fetch.rateDist::overflows','system.cpu.dtb.fetch_misses','system.cpu.numWorkItemsCompleted','system.cpu.iq.FU_type_0::SimdFloatSqrt','system.cpu.dcache.fast_writes','system.cpu.dcache.no_allocate_misses','system.l2.fast_writes','system.disk2.dma_read_bytes','system.l2.blocked_cycles::no_targets','system.cpu.iq.fu_full::SimdMult','system.cpu.iq.FU_type_0::SimdCmp','system.cpu.iew.wb_penalized_rate','system.cpu.iq.fu_full::SimdCvt','system.cpu.itb.write_hits','system.cpu.iq.FU_type_0::SimdMultAcc','system.cpu.iq.FU_type_0::SimdShiftAcc','system.disk0.dma_read_txs','system.cpu.itb.read_hits','system.cpu.iq.fu_full::SimdFloatMisc','system.cpu.fetch.rateDist::underflows','system.cpu.iq.fu_full::InstPrefetch','system.cpu.iq.FU_type_0::SimdMult','system.cpu.iq.FU_type_0::SimdShift','system.l2.tags.warmup_cycle','system.cpu.commit.committed_per_cycle::min_value','system.disk2.dma_write_txs','system.cpu.iq.fu_full::FloatAdd','system.mem_ctrls.rdQLenPdf::24','system.cpu.dtb.fetch_hits','system.cpu.iq.fu_full::No_OpClass','system.disk0.dma_read_bytes','system.cpu.iq.fu_full::SimdShift','system.disk2.dma_write_full_pages','system.cpu.iq.FU_type_0::SimdFloatMisc','system.cpu.iew.exec_swp','system.cpu.itb.data_hits','system.mem_ctrls.rdQLenPdf::30','system.mem_ctrls.rdQLenPdf::31','system.cpu.iew.lsq.thread0.invAddrSwpfs','system.cpu.iq.issued_per_cycle::underflows','system.cpu.icache.tags.warmup_cycle','system.mem_ctrls.writePktSize::4','system.mem_ctrls.writePktSize::5','system.mem_ctrls.writePktSize::0','system.cpu.iq.FU_type_0::FloatCvt','system.mem_ctrls.writePktSize::2','system.mem_ctrls.writePktSize::3','system.cpu.branchPred.BTBCorrect','system.cpu.itb.data_acv','system.iocache.blocked::no_targets','system.l2.blocked::no_targets','system.cpu.iq.FU_type_0::FloatCmp','system.iocache.blocked_cycles::no_targets','system.cpu.iq.fu_full::IntDiv','system.cpu.dtb.fetch_acv','system.cpu.iq.fu_full::SimdFloatAlu','system.cpu.itb.write_acv','system.cpu.iq.fu_full::SimdShiftAcc','system.l2.blocked::no_mshrs','system.cpu.iq.FU_type_0::IntDiv','system.cpu.iq.fu_full::SimdAlu','system.cpu.commit.committed_per_cycle::underflows','system.cpu.iq.FU_type_0::InstPrefetch','system.cpu.iq.issued_per_cycle::min_value','system.cpu.iq.FU_type_0::SimdFloatMultAcc','system.cpu.iq.fu_full::FloatSqrt','system.cpu.itb.read_accesses','system.cpu.iq.FU_type_0::SimdCvt','system.l2.no_allocate_misses','system.cpu.commit.bw_limited','system.cpu.iq.FU_type_0::SimdAdd','system.cpu.fetch.rateDist::min_value','system.cpu.iq.fu_full::SimdSqrt','system.cpu.dcache.blocked::no_targets','system.cpu.itb.write_misses','system.cpu.iq.fu_full::SimdFloatMultAcc','system.mem_ctrls.writePktSize::1','system.cpu.iew.wb_penalized','system.cpu.iq.fu_full::SimdCmp','system.disk2.dma_read_full_pages','system.cpu.iq.FU_type_0::SimdSqrt','system.cpu.iq.FU_type_0::SimdFloatAdd','system.mem_ctrls.numRdRetry','system.iocache.no_allocate_misses','system.cpu.iq.FU_type_0::SimdFloatMult','system.cpu.iq.fu_full::FloatCmp','system.cpu.iq.fu_full::SimdFloatDiv','system.cpu.iq.fu_full::SimdAddAcc','system.cpu.iq.fu_full::SimdMultAcc','system.mem_ctrls.rdQLenPdf::23','system.mem_ctrls.rdQLenPdf::25','system.cpu.iew.lsq.thread0.blockedLoads','system.mem_ctrls.rdQLenPdf::27','system.mem_ctrls.rdQLenPdf::26','system.cpu.itb.read_acv','system.mem_ctrls.rdQLenPdf::28','system.cpu.iq.fu_full::IprAccess','system.cpu.dcache.tags.warmup_cycle','system.cpu.iq.FU_type_0::SimdFloatCmp','system.cpu.iq.fu_full::SimdFloatCmp','system.cpu.iq.FU_type_0::SimdFloatCvt','system.cpu.commit.swp_count','system.cpu.iq.FU_type_0::SimdFloatDiv','system.cpu.iq.fu_full::SimdFloatAdd','system.cpu.iq.fu_full::SimdAdd','system.iocache.fast_writes','system.iocache.tags.total_refs','system.mem_ctrls.mergedWrBursts','system.cpu.iq.fu_full::SimdFloatCvt','system.disk2.dma_read_txs','system.cpu.iq.fu_full::FloatCvt','system.mem_ctrls.rdQLenPdf::29','system.cpu.iq.issued_per_cycle::overflows','system.l2.cache_copies','system.cpu.itb.write_accesses','system.l2.blocked_cycles::no_mshrs','system.cpu.icache.fast_writes','system.cpu.kern.inst.arm','system.iocache.cache_copies','system.disk0.dma_read_full_pages','system.cpu.iq.FU_type_0::SimdAlu','system.disk2.dma_write_bytes','system.cpu.iq.fu_full::SimdFloatSqrt','system.cpu.itb.data_accesses']


ground_truth_list = {}

def read_groundtruth():
	gt_files = ['qsort_small1_1', 'qsort_small2_1', 'qsort_small3_1', 'qsort_small4_2', 'qsort_small5_2', 'qsort_small6_1', 'qsort_small7_2', 'qsort_small8_2', 'qsort_small9_2', 'qsort_small10_2']
	gt_file_path_prefix = "../gemfi-dsn2015/fi_output/qsort_small/different_input/GeneralFetchInjectedFault/"

	gt = {}

	for idx, gt_file in enumerate(gt_files):
		gt_file_path = gt_file_path_prefix + gt_file + "/system.terminal"
		with open(gt_file_path, 'rb') as gt_file:
			gt_str = gt_file.read()
			gt[idx + 1] = gt_str

	return gt

# Read Single stats.txt file
def read_stats(file_name, output_file, feature_hash, gt_str, fault):
	print file_name
	data = []
	common_features = set() 
	
	label = 1
	with open(output_file, "r") as f:
		out_str = f.read()
		if out_str == gt_str:
			label = 0
		elif fault == 'GeneralFetchInjectedFault': 
			label = 1
		elif fault == 'LoadStoreInjectedFault':
			label = 2
		elif fault == 'ExecutionInjectedFault':
			label = 3
		elif fault == 'OpCodeInjectedFault':
			label = 4
		print "Label:", label

	with open(file_name, "r") as f:
		contents = f.read()
		lines = contents.split("\n")

		# indicator variable that skips reading the first section because of system warm up 
		skipped_warmup = False
		# indicator variable that checks whether the input should be removed
		remove_this_input = False

		feat = {}

		feature_str = ""	
	
		for line in lines:
			if line == "":
				continue
			elif line.find("Begin Simulation Statistics") != -1:
				feat.clear()	
			elif line.find("End Simulation Statistics") != -1:
				if skipped_warmup and not remove_this_input:
					md5_val = hashlib.md5(feature_str.encode()).hexdigest()
					if not md5_val in feature_hash: 
						data.append(copy.deepcopy(feat))
						data[-1]['multi_label'] = label
						if label > 0:
							data[-1]['label'] = 1
						else:
							data[-1]['label'] = 0 
							
						feature_hash[md5_val] = 1
						features = set()
						for key in feat:
							#print key
							features.add(key)	
						if len(common_features) == 0:
							common_features = common_features.union(features)
						else:
							common_features = common_features.intersection(features)
						#print "common feature length:", len(common_features)
						#print "feature length:", len(feat)

					#else:
					#	print "Already in feature vectors"

					#print "Feature length:", len(feat)
					#print "Data size:", len(data)
				else:
					skipped_warmup = True
					remove_this_iput = False

				feature_str = ""
			else:
				if skipped_warmup:	
					eles = line.split(' ')					
					eles = [ele for ele in eles if ele != '']
					if len(eles) >= 2: 
						if not eles[0] in skip_features:
							key = eles[0]
							# Some features have more than one input, now we will only take the first 
							val = eles[1]
							# val = [ele for ele in eles[1:eles.index('#')]]   # For more than one input 
							if val != "nan" and val != "inf":
								feat[key] = val
								feature_str += key + val
					else:
						remove_this_input = True
	return data, feature_hash, common_features	

def read_faults(gt):
	faults = ["GeneralFetchInjectedFault", "LoadStoreInjectedFault", "ExecutionInjectedFault", "OpCodeInjectedFault"]	
	stats_folder_prefix = "../gemfi-dsn2015/fi_output/qsort_small/different_input/"
	test = "qsort_small"
	all_data = []
	feature_hash = {}
	count = 0
	common_features = set()

	# First read correct ones
	correct_ones = {'GeneralFetchInjectedFault' : ['qsort_small1_1', 'qsort_small2_1', 'qsort_small3_1', 'qsort_small4_2', 'qsort_small5_2', 'qsort_small6_1', 'qsort_small7_2', 'qsort_small8_2', 'qsort_small9_2', 'qsort_small10_2'], 'LoadStoreInjectedFault': ['qsort_small1_1', 'qsort_small2_1', 'qsort_small3_1', 'qsort_small4_1', 'qsort_small5_1', 'qsort_small6_1', 'qsort_small7_1', 'qsort_small8_2', 'qsort_small9_1', 'qsort_small10_1'], 'ExecutionInjectedFault': ['qsort_small1_2', 'qsort_small2_1', 'qsort_small3_1', 'qsort_small4_1', 'qsort_small5_1', 'qsort_small6_2', 'qsort_small7_1', 'qsort_small8_2', 'qsort_small9_1', 'qsort_small10_1'], 'OpCodeInjectedFault': ['qsort_small1_1', 'qsort_small2_1', 'qsort_small3_3', 'qsort_small4_1', 'qsort_small5_1', 'qsort_small6_1', 'qsort_small7_3', 'qsort_small8_1', 'qsort_small9_2', 'qsort_small10_1']} 

	for fault_name in faults:
		dir_list = correct_ones[fault_name]
		for directory in dir_list:
			directory = stats_folder_prefix + fault_name + "/" + directory 
			count += 1
			print count
			stat_file = directory + "/stats.txt"
			output_file = directory + "/system.terminal"
			if os.path.isfile(stat_file) and os.path.isfile(output_file):
				statinfo = os.stat(stat_file)
				if statinfo.st_size > 212876790:
					print statinfo
					print stat_file
					print "file too large"
					continue
				
				# some shity transformation
				program_id = directory.split('/')[-1].split('_')[1][5:]
				gt_str = gt[int(program_id)]

				[data, feature_hash, common_features_one_stat] = read_stats(stat_file, output_file, feature_hash, gt_str, fault_name)	
				#print feature_hash
				all_data += data
				print len(all_data)
			
				if len(common_features) == 0:
					common_features = common_features_one_stat
				else:
					if len(common_features_one_stat) != 0:
						common_features = common_features.intersection(common_features_one_stat)
				print "Common feature length:", len(common_features)
			else:
				print stat_file, "does not exist"

			
	for fault_name in faults:
		stat_dir = stats_folder_prefix + fault_name + "/"
		dir_list = [x[0] for x in os.walk(stat_dir)]
		dir_list = dir_list[1:len(dir_list)]
		for directory in dir_list:
			test_name = directory.split('/')[-1]
			if test_name in correct_ones[fault_name]:
				print "Already read this file"
				continue 
			
			count += 1
			print count
			stat_file = directory + "/stats.txt"
			output_file = directory + "/system.terminal"
			if os.path.isfile(stat_file) and os.path.isfile(output_file):
				statinfo = os.stat(stat_file)
				if statinfo.st_size > 212876790:
					print statinfo
					print stat_file
					print "file too large"
					continue

				# some shity transformation
				program_id = directory.split('/')[-1].split('_')[1][5:]
				gt_str = gt[int(program_id)]

				[data, feature_hash, common_features_one_stat] = read_stats(stat_file, output_file, feature_hash, gt_str, fault_name)	
				#print feature_hash
				all_data += data
				print len(all_data)
			
				if len(common_features) == 0:
					common_features = common_features_one_stat
				else:
					if len(common_features_one_stat) != 0:
						common_features = common_features.intersection(common_features_one_stat)
				print "Common feature length:", len(common_features)
			else:
				print stat_file, "does not exist"

	## Extract common features
	with open('data_different_input.csv', 'wb') as csvfile:
		writer = csv.writer(csvfile)
		heading = list(common_features)
		heading.append('multi_label')
		heading.append('label')
		writer.writerow(heading)
		for data in all_data:
			row = []
			for feat in heading:
				row.append(data[feat])
			#row.append(random.randint(0, 1))
			writer.writerow(row)
			
	

if __name__ == "__main__":
	gt = read_groundtruth()
	read_faults(gt)
