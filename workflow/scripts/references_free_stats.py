import sys
import seaborn as sb
import pandas as pd

#path_to_csv = str(sys.argv[1])
path_to_csv = str(sys.argv[1])
output_folder = str(sys.argv[2])
############### FUNCTIONS ###############

############### MAIN ###############
# Import data
table = pd.read_csv(path_to_csv)
#print(table.columns)
# contig_name,contig_length,GC_content,mean_depth"
# Build GC/abundance plot
scatterplot = sb.scatterplot(x=table["GC_content"],y=table["mean_depth"],size=table["contig_length"])
scatterplot.set_xlabel("GC content")
scatterplot.set_ylabel("Mean depth")
scatterplot.legend(title="Contig size")
scatterplot.get_figure().savefig(output_folder+"GC_abundance_scatterplot.png")
scatterplot.get_figure().clf()

# Build contigs size boxplot
violinplot = sb.violinplot(y=table["contig_length"],inner="point",cut=0)
violinplot.set(yscale="log")
violinplot.set_ylabel("Contig size")
violinplot.get_figure().savefig(output_folder+"contig_size_violinplot.png") 




