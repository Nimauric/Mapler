# Map reads on contigs, used to extract unmapped reads and evaluate contigs
"""
rule read_on_contigs_mapping : 
    params : 
        expand("{sample}", sample=get_samples("name")),
    input :
        assembly = "outputs/{sample}/{assembler}/assembly.fasta",
        reads = lambda wildcards: get_sample( "read_path", wildcards), 
    output : "outputs/{sample}/{assembler}/reads_on_contigs.bam"
    conda : "../envs/mapping.yaml"
    threads : 24
    resources :
        cpus_per_task = 24, 
        mem_mb= 100*1000 , 
        runtime=1*24*60, 
    shell : "./sources/mapping.sh {input.assembly} {input.reads} {output}"
"""
#rule short_reads_on-contigs_mapping : 


rule read_on_contigs_mapping : 
    params : 
        expand("{sample}", sample=get_samples("name")),
    input :
        assembly = "outputs/{sample}/{assembler}/assembly.fasta",
        reads = lambda wildcards: get_sample( "read_path", wildcards), 
    output : "outputs/{sample}/{assembler}/reads_on_contigs.bam"
    conda : "../envs/mapping.yaml"
    threads : 24
    resources :
        cpus_per_task = 24, 
        mem_mb= 100*1000 , 
        runtime=1*24*60, 
    shell : "./sources/mapping.sh {output} {input.reads} {input.assembly} map-hifi "


rule reads_on_reference_mapping : 
    input :
        reads = lambda wildcards: get_sample( "read_path", wildcards), 
        reference = lambda wildcards: get_reference(wildcards.reference_name)
    output : "outputs/{sample}/reads_on_reference.{reference_name}.bam"
    conda : "../envs/mapping.yaml"
    threads : 24
    resources :
        cpus_per_task = 24, 
        mem_mb= 100*1000 , 
        runtime=1*24*60, 
    shell : "./sources/mapping.sh {output} {input.reads} {input.reference} map-hifi"


rule contigs_on_reference_mapping : 
    input :
        assembly = "outputs/{sample}/{assembler}/assembly.fasta",
        reference = lambda wildcards: get_reference(wildcards.reference_name)
    output : "outputs/{sample}/{assembler}/contigs_on_reference.{reference_name}.bam"
    conda : "../envs/mapping.yaml"
    threads : 24
    resources :
        cpus_per_task = 24, 
        mem_mb= 100*1000 , 
        runtime=1*24*60, 
    shell : "./sources/mapping.sh {output} {input.assembly} {input.reference} asm20"

#expand("outputs/{sample}/{assembler}/contigs_on_reference.{reference}.bam", 
#sample=get_samples("name"), assembler = config["assemblers"], reference=get_reference_names()