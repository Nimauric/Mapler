configfile : "config.yaml"

rule all :
    input :
        "data/reads_QC/SRR8073714/SRR8073714_fastqc.html",
        "data/assemblies/metaflye_SRR8073714/",
        "data/assemblies/canu_SRR8073714/",
        "data/assemblies_QC/metaflye_SRR8073714/",
        "data/assemblies_QC/canu_SRR8073714/",
        "data/stats_reports/canu_SRR8073714/canu_SRR8073714_report.txt",
        "data/stats_reports/metaflye_SRR8073714/metaflye_SRR8073714_report.txt"


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
        protected(directory("data/assemblies/metaflye_{read}")),
        protected("data/assemblies/metaflye_{read}/assembly.fasta")
    shell : 
        "./metaflye_assembler.sh data/raw_reads/{wildcards.read}.fastq.gz"

rule canu_assembly :
    input : 
        "data/raw_reads/{read}.fastq.gz",
        "canu_assembler.sh",
        "sequencer_fetcher.sh"
    output :
        protected(directory("data/assemblies/canu_{read}")),
        protected("data/assemblies/canu_{read}/{read}.unassembled.fasta"),
        protected("data/assemblies/canu_{read}/{read}.contigs.fasta")

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

rule assembly_stats :
    input : 
        "data/assemblies_QC/{assembly}/summary/TSV",
        "stats.py"
    output : 
        "data/stats_reports/{assembly}/{assembly}_report.txt"
    shell : 
        "python3 stats.py data/assemblies_QC/{wildcards.assembly}/summary/TSV > data/stats_reports/{wildcards.assembly}/{wildcards.assembly}_report.txt"
