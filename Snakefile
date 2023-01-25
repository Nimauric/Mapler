configfile : "config.yaml"

rule all :
    input :
        "data/reads_QC/SRR8073714/SRR8073714_fastqc.html",
        "data/reference_genomes/coverage_information_SRR8073714.tsv",
        "data/stats_reports/canu_SRR8073714/canu_SRR8073714_report.txt",
        "data/stats_reports/metaflye_SRR8073714/metaflye_SRR8073714_report.txt"
    

rule reads_quality_check :
    input :
        "data/raw_reads/{read}.fastq.gz",
        "reads_quality_checker.sh"
    output :
        "data/reads_QC/{read}/{read}_fastqc.html",
        "data/reads_QC/{read}/{read}_fastqc.zip"
    shell :
        "./reads_quality_checker.sh data/raw_reads/{wildcards.read}.fastq.gz"

rule sequencing_debth_calculation :
    input :
        "data/reference_genomes/*.fasta",
        "data/raw_reads/{read}.fastq.gz",
        "reads_multi_mapper.sh"
    output : 
        "data/reference_genomes/coverage_information_{read}.tsv"
    shell : 
        "./reads_multi_mapper.sh data/raw_reads/{wildcards.read}.fastq.gz"

rule metaflye_assembly :
    input : 
        "data/raw_reads/{read}.fastq.gz",
        "metaflye_assembler.sh",
        "sequencer_fetcher.sh"
    output :
        protected("data/assemblies/metaflye_{read}/assembly.fasta")
    shell : 
        "./metaflye_assembler.sh data/raw_reads/{wildcards.read}.fastq.gz"

rule canu_assembly :
    input : 
        "data/raw_reads/{read}.fastq.gz",
        "canu_assembler.sh",
        "sequencer_fetcher.sh"
    output :
        protected("data/assemblies/canu_{read}/{read}.unassembled.fasta"),
        protected("data/assemblies/canu_{read}/{read}.contigs.fasta")

    shell : 
        "./canu_assembler.sh data/raw_reads/{wildcards.read}.fastq.gz"
  
rule assembly_quality_check :
    input : 
        "data/assemblies/{assembly}",
        "assembly_quality_checker.sh"
    output :
        directory("data/assemblies_QC/{assembly}/summary/TSV")
    shell : 
        "./assembly_quality_checker.sh data/assemblies/{wildcards.assembly}"

rule assembly_stats :
    input : 
        "data/assemblies_QC/{assembly}_{read}/summary/TSV",
        "data/reference_genomes/coverage_information_{read}.tsv",
        "stats.py"
    output : 
        "data/stats_reports/{assembly}_{read}/{assembly}_{read}_report.txt"
    shell : 
        "python3 stats.py data/assemblies_QC/{wildcards.assembly}_{wildcards.read}/summary/TSV data/reference_genomes/coverage_information_{wildcards.read}.tsv  > data/stats_reports/{wildcards.assembly}_{wildcards.read}/{wildcards.assembly}_{wildcards.read}_report.txt" 

