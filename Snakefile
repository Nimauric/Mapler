configfile : "config.yaml"

rule all :
    input :
        "data/reads_QC/SRR8073714/SRR8073714_fastqc.html",
        "data/assemblies/metaflye_SRR8073714/",
        "data/assemblies_QC/metaflye_SRR8073714/",
        "data/assemblies_QC/canu_SRR8073714/"

rule reads_quality_check:
    input :
        "data/raw_reads/{read}.fastq.gz",
        "reads_quality_checker.sh"
    output :
        directory("data/reads_QC/{read}"),
        "data/reads_QC/{read}/{read}_fastqc.html",
        "data/reads_QC/{read}/{read}_fastqc.zip"
    shell :
        "./reads_quality_checker.sh data/raw_reads/{wildcards.read}.fastq.gz"

rule metaflye_assembly :
    input : 
        "data/raw_reads/{read}.fastq.gz",
        "metaflye_assembler.sh",
        "sequencer_fetcher.sh"
    output :
        directory("data/assemblies/metaflye_{read}")
    shell : 
        "./metaflye_assembler.sh data/raw_reads/{wildcards.read}.fastq.gz"

rule canu_assembly :
    input : 
        "data/raw_reads/{read}.fastq.gz",
        "canu_assembler.sh",
        "sequencer_fetcher.sh"
    output :
        directory("data/assemblies/canu_{read}")
    shell : 
        "./canu_assembler.sh data/raw_reads/{wildcards.read}.fastq.gz"
  
rule assembly_quality_check :
    input : 
        "data/assemblies/{assembly}",
        "assembly_quality_checker.sh"
    output :
        directory("data/assemblies_QC/{assembly}")
    shell : 
        "./assembly_quality_checker.sh data/assemblies/{wildcards.assembly}"
