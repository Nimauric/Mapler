

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
    threads : 24
    resources :
        cpus_per_task = 24, 
        mem_mb= 100*1000 , 
        runtime=1*24*60, 
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
        kraken2_directory = config["kraken2bin"],
        krona_directory = config["kronabin"],
        output_directory = "outputs/{sample}/{assembler}/kraken2/{fraction}"
    input : get_read_path
    output : "outputs/{sample}/{assembler}/kraken2/{fraction}/krona.html",
    threads : 12
    resources :
        cpus_per_task = 6, #on mmdbg irg salad full, 35% efficiency with 12 cpus => 6
        mem_mb= 100*1000 , #on mmdbg irg salad full, 72% efficiency
        runtime=1*4*60, #on mmdbg irg salad full, 17 minutes
    shell : "./sources/read_quality_analysis/kraken2.sh {params.kraken2_directory} {params.database} {params.krona_directory} {input} {params.output_directory}"

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
    threads : 12
    resources :
        cpus_per_task = 12, #on mmdbg irg salad full, 91% efficiency 12
        mem_mb= 200*1000 , #on mmdbg irg salad full, 71% efficiency
        runtime=1*4*60, #on mmdbg irg salad full, 1h
    shell : "./sources/read_quality_analysis/kat.sh {input.reads} {input.full_reads} {params.output_prefix}" 
