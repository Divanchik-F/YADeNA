"""
This module contains functions that are not quite related to the main
logic, e.g. functions for parsing files generated by certain software.
"""


def parse_art_orientation(aln_files):
    """
    Receives path to *.aln file generated by art_illumina.
    Returns dictionary that maps ids of reads to their orientation which is
    either '+' or '-'. '-' means that the read is reverse complement of
    original sequence.
    """
    orientation = {}
    for aln_file in aln_files:
        with open(aln_file, 'r', encoding='utf-8') as f:
            for line in f.readlines():
                if line[0] != '>':
                    continue
                read_info = line[:-1].split('\t')
                # ART adds a redundant '-1' at the end of ids in the first .aln
                # file, so we remove it
                read_id = '-'.join(read_info[1].split('-')[0:2])
                orientation[read_id] = read_info[-1]
    return orientation


def compute_identity(aligner, seq1, seq2):
    """
    Receives Bio.Align.PairwiseAligner and two sequences.
    Returns the identity of these sequences — measure of their similarity.
    """
    s1, s2 = next(aligner.align(seq1, seq2))
    alignment_len = len(s1)
    match_count = 0
    for i in range(alignment_len):
        if s1[i] == s2[i]:
            match_count += 1
    return match_count / alignment_len
