###### Utility function ###### 

# Return a list containing the attribute "attribute" of each sample
def get_samples(attribute) : 
    # attribute = {name, read_path}
    return [sample[attribute] for sample in config["samples"]]

# Return the attribute "attribute" of an assembly with the name "sample"
def get_sample(attribute, wildcards):
    index = get_samples("name").index(wildcards.sample)
    return get_samples(attribute)[index]

# Return the path to the reads of a fraction of an assembly 
def get_read_path(wildcards) : 
    if(wildcards.fraction == "full") : 
        return get_sample("read_path", wildcards)
    return "outputs/" + wildcards.sample + "/" + wildcards.assembler + "/" + wildcards.fraction + "_reads.fastq"

# Return the path to the reads of all fractions of an assembly 
def get_all_read_path(wildcards) :
    out = []
    for f in config["fractions"] :
        wildcards.fraction = f
        out.append(get_read_path(wildcards))
    return out

def get_reference_names() : 
    return [os.path.splitext(os.path.basename(r))[0] for r in config["reference_genomes"]]

def get_reference(reference_name) : 
    for ref in config["reference_genomes"] : 
        if reference_name in ref : 
            return ref
    return None
    
##### Additional rules #####  
include : "rules/assembly.smk"
include : "rules/mapping.smk"
include : "rules/binning.smk"
include : "rules/bin_quality_analysis.smk"
include : "rules/read_quality_analysis.smk"
include : "rules/contig_quality_analysis.smk"

##### Improvements #####
"""
replace minimap2 by mapquick for hifi long reads mapping ?
replace kraken2 by sourmash for taxonomic assignation ?
"""


binnings = []
if(config["binning"] == True) : 
    binnings += expand("{binner}_bins_reads_alignement", binner = config["binners"])
if(config["short_read_binning"] == True) :
    binnings += expand("{binner}_bins_short_reads_alignement", binner = config["binners"])
if(config["short_read_cobinning"] == True) :
    binnings += expand("{binner}_bins_cobinning_alignement", binner = config["binners"])
if(config["additional_reads_cobinning"] == True) :
    binnings += expand("{binner}_bins_additional_reads_cobinning_alignement", binner = config["binners"])



rule all :
    input :
        expand("outputs/{sample}/{assembler}/assembly.fasta", sample=get_samples("name"), assembler = config["assemblers"]),

        # Read quality analysis (fastqc, kraken2, kat)
        expand("outputs/{sample}/{assembler}/fastqc/{fraction}/fastqc_report.html", sample=get_samples("name"), assembler = config["assemblers"], fraction=config["fractions"])
            if(config["fastqc"] == True) else "Snakefile",
        expand("outputs/{sample}/{assembler}/kraken2/{fraction}/krona.html", sample=get_samples("name"), assembler = config["assemblers"], fraction=config["fractions"])
            if(config["kraken2"] == True) else "Snakefile",
        expand("outputs/{sample}/{assembler}/kat/{fraction}-stats.tsv", sample=get_samples("name"), assembler = config["assemblers"], fraction=config["fractions"])
            if(config["kat"] == True) else "Snakefile",
        expand("outputs/{sample}/{assembler}/kat/kat-plot.png", sample=get_samples("name"), assembler = config["assemblers"])
            if(config["kat"] == True and "mapped" in config["fractions"] and "unmapped" in config["fractions"]) else "Snakefile",

        # Contig quality analysis (read mapping, short read mapping, metaquast, reference mapping)
        expand("outputs/{sample}/{assembler}/reads_on_contigs_mapping_evaluation/report.txt", sample=get_samples("name"), assembler = config["assemblers"])
            if(config["read_mapping_evaluation"] == True) else "Snakefile",
        expand("outputs/{sample}/{assembler}/metaquast/report.txt", sample=get_samples("name"), assembler = config["assemblers"])
            if(config["metaquast"] == True) else "Snakefile",
        expand("outputs/{sample}/reads_on_reference.{reference}.bam", sample=get_samples("name"), assembler = config["assemblers"], reference=get_reference_names())
            if(config["reference_mapping_evaluation"] == True) else "Snakefile",
        expand("outputs/{sample}/{assembler}/contigs_on_reference.{reference}.bam", sample=get_samples("name"), assembler = config["assemblers"], reference=get_reference_names())
            if(config["reference_mapping_evaluation"] == True) else "Snakefile", 
        
        # Bins quality analysis (checkm, separate read and contig quality analysis by bin quality)
        expand("outputs/{sample}/{assembler}/{binning}/bins/bin.1.fa", sample=get_samples("name"), assembler = config["assemblers"], binning=binnings)
            if(config["binning"] == True) else "Snakefile",
        expand("outputs/{sample}/{assembler}/{binning}/checkm/checkm_report.txt", sample=get_samples("name"), assembler = config["assemblers"], binning=binnings)
            if(config["checkm"] == True) else "Snakefile",
        expand("outputs/{sample}/{assembler}/{binning}/checkm/checkm-plot.png", sample=get_samples("name"), assembler = config["assemblers"], binning=binnings)
            if(config["checkm"] == True) else "Snakefile",
        expand("outputs/{sample}/{assembler}/{binning}/gtdbtk/results/gtdbtk.bac120.summary.tsv", sample=get_samples("name"), assembler = config["assemblers"], binning=binnings)
            if(config["gtdbtk"] == True) else "Snakefile",
        expand("outputs/{sample}/{assembler}/{binning}/kraken2/bin.{target_bin}/krona.html", sample=get_samples("name"), assembler = config["assemblers"], binning=binnings, target_bin=config["target_bins"])
            if(config["kraken2_on_bins"] == True) else "Snakefile",
        expand("outputs/{sample}/{assembler}/{binning}/read_contig_mapping_plot.png", sample=get_samples("name"), assembler = config["assemblers"], binning=binnings)
            if(config["checkm"] == True and config["read_mapping_evaluation"] == True) else "Snakefile",
