#!/bin/bash

# This script takes reference sequence and generates simulated data based on this sequence for testing the assembler

cd "$(dirname "$0")" # change to dir of this script

ref_file=ref.fa # FASTA/FASTQ file containing reference sequence
out_dir=out_dir
seq_system=${1:-HS25}
read_len=${2:-150} # length of a read
mean_fragsize=${3:-250}
std_fragsize=${4:-10}
fold_cov=${5:-20}

ref_id=$(cat ${ref_file} | head -n 1) # id of reference sequence
ref_seq=$(cat ${ref_file} | head -n 2 | tail -n 1) # reference sequence
ref_seq_len=${#ref_seq}
log_file=log.txt
err_file=err.txt
# gap_len is length of gap in sequence which is going to be filled by assembler
rm $log_file $err_file
for gap_len in `seq 200 100 1000`; do
  target_seq_len=$(($read_len*2 + $gap_len)) # length of resulting (target) sequence (two contigs and filled gap between them)
  max_pos=$(($ref_seq_len-$target_seq_len)) # maximum starting position of target sequence
  pos="$(shuf -i 0-"$max_pos" -n 1)" # random starting position of target sequence
  target_seq=${ref_seq:pos:target_seq_len}
  target_dir=${out_dir}/sim_${read_len}_${gap_len}
  mkdir -p $target_dir
  target_file=${target_dir}/target.fa # file containing target sequence
  echo ${ref_id}_${gap_len}_${pos} > $target_file
  echo $target_seq >> $target_file

  # Making contig files
  echo ">left_contig" > ${target_dir}/cont1.fa
  echo ${target_seq:0:read_len} >> ${target_dir}/cont1.fa # append left contig
  right_contig_pos="$((${#target_seq}-$read_len))"
  echo ">right_contig" > ${target_dir}/cont2.fa
  echo ${target_seq:right_contig_pos:read_len} >> ${target_dir}/cont2.fa # append right contig

  art_illumina -ss ${seq_system} -sam -i ${target_file} -p -l ${read_len} -f ${fold_cov} -m ${mean_fragsize} -s ${std_fragsize} -o ${target_dir}/dat >> log.txt 2>>err.txt
done
