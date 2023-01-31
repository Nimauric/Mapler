configfile : "config.yaml"

rule all :
    input :
        # Operations on reads
        expand("data/reads_QC/{read}/{read}_fastqc.html", read=config["long_reads"]),
        expand("data/reference_genomes/coverage_information_{read}.tsv", read=config["long_reads"]),

        # Operations on reads-assembler pairs
        expand("data/assemblies/{assembler}_{read}/", read=config["long_reads"], assembler = config["long_reads_assemblers"]),
        expand("data/assemblies_QC/{assembler}_{read}/summary/TSV", read=config["long_reads"], assembler = config["long_reads_assemblers"]),
        expand( "data/stats_reports/{assembler}_{read}/{assembler}_{read}_report.txt", read=config["long_reads"], assembler = config["long_reads_assemblers"]),
     

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
        "data/reference_genomes/individual_genomes/",
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
        directory("data/assemblies/metaflye_{read}"),
        protected("data/assemblies/metaflye_{read}/assembly.fasta")
    shell : 
        "./metaflye_assembler.sh data/raw_reads/{wildcards.read}.fastq.gz"

rule canu_assembly :
    input : 
        "data/raw_reads/{read}.fastq.gz",
        "canu_assembler.sh",
        "sequencer_fetcher.sh"
    output :
        directory("data/assemblies/canu_{read}"),
        protected("data/assemblies/canu_{read}/{read}.unassembled.fasta"),
        protected("data/assemblies/canu_{read}/assembly.fasta")

    shell : 
        "./canu_assembler.sh data/raw_reads/{wildcards.read}.fastq.gz"

rule miniasm_assembly :
    input : 
        "data/raw_reads/{read}.fastq.gz",
        "miniasm_assembler.sh",
        "sequencer_fetcher.sh"
    output :
        directory("data/assemblies/miniasm_{read}"),
        protected("data/assemblies/miniasm_{read}/assembly.fasta")
    shell : 
        "./miniasm_assembler.sh data/raw_reads/{wildcards.read}.fastq.gz"

rule polishing : 
    input :
        "data/assemblies/{assembler_to_polish}_{read}",
        "data/assemblies/{assembler_to_polish}_{read}/assembly.fasta"
    output : 
        directory("data/assemblies/flye_polish_{assembler_to_polish}_{read}"),
        "data/assemblies/flye_polish_{assembler_to_polish}_{read}/polished_1.fasta"
    shell : 
        "./flye_polisher.sh {wildcards.assembler_to_polish} {wildcards.read}"

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


