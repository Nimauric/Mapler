

rule extract_unmapped_reads : 
    params : 
        expand("{sample}", sample=get_samples("name")),
        output_directory="outputs/{sample}/{assembler}/"
    input :
        mapping = "outputs/{sample}/{assembler}/reads_on_contigs.bam",    
    output :
        mapped_reads = "outputs/{sample}/{assembler}/mapped_reads.fastq",
        unmapped_reads = "outputs/{sample}/{assembler}/unmapped_reads.fastq",
    conda : "../envs/mapping.yaml"
    threads : config["rule_extract_unmapped_reads"]["threads"]
    resources :
        cpus_per_task = config["rule_extract_unmapped_reads"]["threads"],
        mem_mb=config["rule_extract_unmapped_reads"]["memory"],
        runtime=eval(config["rule_extract_unmapped_reads"]["time"]),
    shell : "./sources/read_quality_analysis/extract_unmapped_reads.sh {input.mapping} {params.output_directory}"

rule fastqc : 
    params : 
        expand("{sample}", sample=get_samples("name")),
        expand("{fraction}", fraction=config["fractions"]),
        output_directory = "outputs/{sample}/{assembler}/fastqc/{fraction}"
    input : get_read_path
    output : "outputs/{sample}/{assembler}/fastqc/{fraction}/fastqc_report.html"
    conda : "../envs/fastqc.yaml"
    shell : "./sources/read_quality_analysis/fastqc.sh {input} {params.output_directory}"

rule kraken2 :
    params : 
        expand("{sample}", sample=get_samples("name")),
        expand("{fraction}", fraction=config["fractions"]),
        database = config["kraken2db"],
        output_directory = "outputs/{sample}/{assembler}/kraken2/{fraction}"
    input : get_read_path
    conda : "../envs/kraken2.yaml"
    output : "outputs/{sample}/{assembler}/kraken2/{fraction}/krona.html",
    threads : config["rule_kraken2"]["threads"]
    resources :
        cpus_per_task = config["rule_kraken2"]["threads"],
        mem_mb=config["rule_kraken2"]["memory"],
        runtime=eval(config["rule_kraken2"]["time"]),
    shell : "./sources/read_quality_analysis/kraken2.sh {params.database} {input} {params.output_directory}"

rule kat_sect : 
    params : 
        expand("{sample}", sample=get_samples("name")),
        expand("{fraction}", fraction=config["fractions"]),
        output_prefix="outputs/{sample}/{assembler}/kat/{fraction}",
    input : 
        reads = get_read_path, # The reads in witch we wish to evaluate the read abundance
        full_reads = lambda wildcards: get_sample( "read_path", wildcards), #The full set, used to evaluate the frequency
    output : "outputs/{sample}/{assembler}/kat/{fraction}-stats.tsv"
    conda : "../envs/kat.yaml"
    threads : config["rule_kat_sect"]["threads"]
    resources :
        cpus_per_task = config["rule_kat_sect"]["threads"],
        mem_mb=config["rule_kat_sect"]["memory"],
        runtime=eval(config["rule_kat_sect"]["time"]),
    shell : "./sources/read_quality_analysis/kat.sh {input.reads} {input.full_reads} {params.output_prefix}" 

rule kat_plot:
    input : 
        mapped = "outputs/{sample}/{assembler}/kat/mapped-stats.tsv",
        unmapped = "outputs/{sample}/{assembler}/kat/unmapped-stats.tsv",
    output : "outputs/{sample}/{assembler}/kat/kat-plot.pdf"
    conda : "../envs/python.yaml"
    shell : "python3 sources/read_quality_analysis/kat.py {input.mapped} {input.unmapped} {output}"