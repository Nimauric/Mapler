mapping=$1
output_directory=$2


mkdir -p $output_directory

echo "extracting unmapped reads..."
samtools fastq -@ $(nproc) -f 4 -0 "$output_directory"/unmapped_reads.fastq $mapping

echo "extracting mapped reads..."
samtools fastq -@ $(nproc) -F 4 -0 "$output_directory"/mapped_reads.fastq $mapping

echo "Done !"

