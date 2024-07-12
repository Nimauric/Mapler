mapping=$1
output_directory=$2


mkdir -p $output_directory

echo "extracting unmapped reads..."
samtools view -@ $(nproc) -f 4 -h -b $mapping \
    | samtools fastq -@ $(nproc) -0 "$output_directory"/unmapped_reads.fastq 

echo "extracting mapped reads..."
samtools view -@ $(nproc) -F 4 -h $mapping \
    | samtools fastq -@ $(nproc) -0 "$output_directory"/mapped_reads.fastq

echo "Done !"

