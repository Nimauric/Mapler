import sys
import seaborn as sb
import pandas as pd


"""
path_to_contigs_info_csv = str(sys.argv[1])
path_to_filtered_stats_csv = str(sys.argv[2])
output_folder = str(sys.argv[2])
"""

path_to_contigs_info_csv = "contigs_info.csv"
path_to_filtered_stats_csv = "filtered_stats.csv"
output_folder = "./"

############### FUNCTIONS ###############

############### MAIN ###############

##### Contigs info #####

# Import data
table = pd.read_csv(path_to_contigs_info_csv)
#print(table.columns) # contig_name,contig_length,GC_content,mean_depth

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
violinplot.get_figure().clf()


##### Contigs info #####
# Import data
table = pd.read_csv(path_to_filtered_stats_csv)
#print(table.columns) #'shortest contig', 'assembly length', 'number of contigs', 'gc content','mean depth', 'N50', 'L50'

scatterplot = sb.scatterplot(x=table["shortest contig"],y=table["gc content"])
scatterplot.set_xlabel("Filter size")
scatterplot.set(xscale="log")
scatterplot.set_ylabel("GC content")
scatterplot.get_figure().savefig(output_folder+"GC_content_depending_on_filter_size.png")
scatterplot.get_figure().clf()

scatterplot = sb.scatterplot(x=table["shortest contig"],y=table["mean depth"])
scatterplot.set_xlabel("Filter size")
scatterplot.set(xscale="log")
scatterplot.set_ylabel("Mean sequencing depth")
scatterplot.get_figure().savefig(output_folder+"sequencing_depth_depending_on_filter_size.png")
scatterplot.get_figure().clf()

