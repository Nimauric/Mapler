import sys
import seaborn as sb
import pandas as pd

path_to_tsv = str(sys.argv[1])
output_folder = str(sys.argv[2])
unmapped_reads= int(sys.argv[3])
############### FUNCTIONS ###############

############### MAIN ###############
# Import data
table = pd.read_csv(path_to_tsv, delim_whitespace=True)
#print(table.columns)

# Build GC/abundance plot
scatterplot = sb.scatterplot(x=table["gccontent"],y=table["meandepth"],size=table["endpos"])
scatterplot.set_xlabel("GC content")
scatterplot.set_ylabel("Mean depth")
scatterplot.legend(title="Contig size")
scatterplot.get_figure().savefig(output_folder+"GC_abundance_scatterplot.png")
scatterplot.get_figure().clf()

# Build contigs size boxplot
violinplot = sb.violinplot(y=table["endpos"],inner="point",cut=0)
violinplot.set(yscale="log")
violinplot.set_ylabel("Contig size")
violinplot.get_figure().savefig(output_folder+"contig_size_violinplot.png") 

# Build text report
#echo "Mapped reads : $mapped_reads" > "$output_folder"references_free_text_report.txt
#echo "Unmapped reads : $unmapped_reads" >>"$output_folder"references_free_text_report.txt
#echo "Mapped ratio : "$mapped_ratio"%" >>"$output_folder"references_free_text_report.txt
print()
print("Without filtering : ")
print()
mapped_reads = table["numreads"].sum()
mapped_ratio = mapped_reads / (mapped_reads + unmapped_reads)
print("Mapped reads : " + str(mapped_reads ))
print("Unmapped reads : " + str(unmapped_reads))
print("Mapped ratio : " + str(mapped_ratio))
print()
mapped_bases = table["covbases"].sum()
unmapped_bases = table["endpos"].sum() - mapped_bases
mapped_ratio = mapped_bases / (mapped_bases + unmapped_bases)
print("Mapped bases : " + str(mapped_bases))
print("Unmapped bases : " + str(unmapped_bases))
print("Mapped ratio : " + str(mapped_ratio))


# Build Mapped reads, unmapped_rterds, contigs, L50, N50, contigs and length plot depending on filter size
# Non functional, to do later ? (or to scrap)
"""
table = table.sort_values("endpos")
print(table)
i = 0 # Index of the current read
j = 0 # Index of the N50 read

cumulative_length = 0
cumulative_half_length = 0 # used to calculate N50 and L50

while(i < len(table)) :
    cumulative_length += table.iloc(i)["endpos"]
    while(cumulative_half_length < 0.5 * cumulative_length) :
        cumulative_half_length += table.iloc(j)["endpos"]
        j+=1
    i+=1

    print(i/j)
"""



