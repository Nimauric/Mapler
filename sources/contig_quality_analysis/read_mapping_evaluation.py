import sys
import pysam
from Bio import SeqIO
from xopen import xopen

reads_path = str(sys.argv[1])
alignement_path = str(sys.argv[2])
threshold= float(sys.argv[3])

#I) : get length of the alignments
reads_alignment = {}
with pysam.AlignmentFile(alignement_path, "rb") as bamfile:
    for alignment in bamfile.fetch():
        read_name = alignment.query_name
        contig_name = alignment.reference_name

        start_pos = alignment.query_alignment_start
        end_pos = alignment.query_alignment_end
        alignment = (start_pos, end_pos, alignment.query_alignment_length)
        if read_name in reads_alignment : 
            reads_alignment[read_name].append(alignment)
        else : 
            reads_alignment[read_name] = [alignment]

#II) : get the length of each read
reads_to_length = {}
with xopen(reads_path, "r") as reads_file :
    i=0
    for line in reads_file:
        line = line.strip()
        if i == 0:
            name= line[1:].split(" ")[0]
        elif i == 1:
            length = len(line)
        elif i == 3:
            i= -1
            reads_to_length[name] = length
        i+=1

#III) : Aggregate the results
alignment_lengths = {"mapped" : 0, "unmapped" : 0}
aligned_reads_count = {"mapped" : 0, "unmapped" : 0}

for read_name, alignments in reads_alignment.items():
    length = 0
    alignments = sorted(alignments, key=lambda x: x[0])
    trimmed_alignments = []
    
    # Remove overlaps and store the alignment lengths
    for alignment in alignments :
        start_pos = alignment[0]
        end_pos = alignment[1]

        for potential_overlap in trimmed_alignments :
            overlap_start_pos = potential_overlap[0]
            overlap_end_pos = potential_overlap[1]

            # Trim the start of the alignment
            if(start_pos <= overlap_end_pos and start_pos >= overlap_start_pos) :
                start_pos = overlap_end_pos 
            # Trim the end of the alignment
            if(end_pos >= overlap_start_pos and end_pos <= overlap_end_pos) : 
                end_pos = overlap_start_pos
        
            # Split the alignment in two
            if(start_pos < overlap_start_pos and end_pos > overlap_end_pos) : 
                alignments.append((start_pos, overlap_start_pos))
                alignments.append((overlap_end_pos, end_pos))
                start_pos = 0
                end_pos = 0
                break
              
        # If not empty, add the new alignement
        if start_pos < end_pos : 
           length += end_pos-start_pos
           trimmed_alignments.append((start_pos, end_pos))

    alignment_lengths["unmapped"] += reads_to_length[read_name] - length
    alignment_lengths["mapped"] += length

    if (threshold > 0 and threshold < 1) : 
        if (length/reads_to_length[read_name] > threshold) :
            aligned_reads_count["mapped"] += 1
    elif (length > threshold) :
        aligned_reads_count["mapped"] += 1

# Add the information from unaligned reads
for r in reads_to_length.keys() :
    if r not in reads_alignment.keys() :
        aligned_reads_count["unmapped"] += 1
        alignment_lengths["unmapped"] += reads_to_length[r]


### Calculate and display the ratios

print("aligned reads count ratio : {:.2f}% ({}/{})".format(aligned_reads_count["mapped"] / (aligned_reads_count["mapped"] + aligned_reads_count["unmapped"]) * 100, aligned_reads_count["mapped"], aligned_reads_count["mapped"] + aligned_reads_count["unmapped"]))
print("aligned read bases ratio : {:.2f}% ({}/{})".format(alignment_lengths["mapped"] / (alignment_lengths["mapped"] + alignment_lengths["unmapped"]) * 100, alignment_lengths["mapped"], alignment_lengths["mapped"] + alignment_lengths["unmapped"]))

