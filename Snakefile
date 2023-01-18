configfile : "config.yaml"

rule all :
    input :
        "data/reads_QC/SRR8073714/SRR8073714_fastqc.html",
        "data/assemblies/metaflye_SRR8073714/"

# Untested
rule reads_quality_check:
    input :
        "data/raw_reads/{read}.fastq.gz"
    output :
        "data/reads_QC/{read}/{read}_fastqc.html",
        "data/reads_QC/{read}/{read}_fastqc.zip"
    shell :
        "./reads_quality_checker.sh {input}"

# Untested
rule metaflye_assembly :
    input : 
        "data/raw_reads/{read}.fastq.gz"
    output :
        "data/assemblies/metaflye_{read}/"
    shell : 
        "./metaflye_assembler.sh {input}"

# Untested
rule assembly_quality_checker :
    input : 
        "data/assemblies/{assembly}"
    output :
        "data/assemblies_quality/{assembly}/"
    shell : 
        "metaflye_assembler {input}"
