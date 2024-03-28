import sys
import pysam
from Bio import SeqIO


reads_path = str(sys.argv[1])
alignement_path = str(sys.argv[2])
threshold= int(sys.argv[3])

##### Fetch the total read length and number from the fastq file
reads_length = 0
reads_count = 0

with open(reads_path, "r") as fastq :
    for record in SeqIO.parse(fastq, "fastq") :
        reads_length += len(record.seq)
        reads_count += 1


### Fetch the range of covered position for each read
covered_positions = {}
with pysam.AlignmentFile(alignement_path, "rb") as bam:
    for alignment in bam.fetch() :
        read_name = alignment.query_name
        start_pos = alignment.reference_start
        end_pos = alignment.reference_end

        if read_name in covered_positions :
            # In case of multiple alignements, trim the new alignement
            for pos_range in covered_positions[read_name]:
                # Trim the begining
                if start_pos >= pos_range[0] and start_pos < pos_range[1] :
                    start_pos = pos_range[1]
                # Trim the end
                if end_pos > pos_range[0] and end_pos <= pos_range[1] :
                    end_pos = pos_range[0]
            # If not empty, add the new alignement
            if start_pos > end_pos : 
                covered_positions[read_name].append((start_pos, end_pos))
        else:
            covered_positions[read_name] = [(start_pos, end_pos)]

### From those fetched position, calculate the number of aligned read and the toal length of the alignements
alignements_length = 0
aligned_reads_count = 0

for p in covered_positions.values() : 
    tmp_length = 0
    for a in p : 
        tmp_length += a[1] - a[0]
    
    alignements_length += tmp_length
    if(tmp_length > threshold) : 
        aligned_reads_count +=1


### Calculate and display the ratios
print("aligned reads over total reads count ratio : {:.2f}% ({}/{})".format(aligned_reads_count / reads_count * 100,aligned_reads_count, reads_count ))
print("alignement length over total reads length ratio : {:.2f}% ({}/{})".format(alignements_length / reads_length * 100, alignements_length, reads_length))

