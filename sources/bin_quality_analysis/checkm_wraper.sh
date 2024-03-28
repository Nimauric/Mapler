bins_extension="$1"
input_directory="$2"
output_directory="$3"
output_file="$4"

# build directorys
mkdir "$output_directory"

# call checkm tree, lineage_set, analyze and qa
echo""
checkm tree "$input_directory" "$output_directory" -x "$bins_extension" -t $(nproc)

echo ""
checkm lineage_set "$output_directory" "$output_directory"/markers.txt 

echo ""
checkm analyze "$output_directory"/markers.txt "$input_directory" "$output_directory" -x "$bins_extension" -t $(nproc)

echo ""
checkm qa "$output_directory"/markers.txt "$output_directory" --tab_table -f "$output_file" -t $(nproc)


echo "Done !"


#./sources/bin_quality_analysis/checkm_wraper.sh fa outputs/zymo/metaMDBG/metabat2_bins_reads_alignement/bins outputs/zymo/metaMDBG/metabat2_bins_reads_alignement/checkm/ outputs/zymo/metaMDBG/metabat2_bins_reads_alignement/checkm/bins_quality_check.tsv
#conda activate .snakemake/conda/8fb20390cafe4e3edcb011afe802f184_