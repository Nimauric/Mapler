 


rule reads_on_contigs_mapping : 
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

rule short_reads_on_contigs_mapping : 
    params : 
        expand("{sample}", sample=get_samples("name")),
    input :
        assembly = "outputs/{sample}/{assembler}/assembly.fasta",
        R1 = config["short_reads_1"], 
        R2 = config["short_reads_2"], 
    output : "outputs/{sample}/{assembler}/short_reads_on_contigs.bam"
    conda : "../envs/mapping.yaml"
    threads : 24
    resources :
        cpus_per_task = 24, 
        mem_mb= 100*1000 , 
        runtime=1*24*60, 
    shell : "./sources/mapping.sh {output} {input.R1} {input.assembly} sr {input.R2}"



def get_additional_read_path(wildcards):
    name = wildcards.additional_read_name
    path = [p["path"] for p in config["additional_reads"] if p["name"] == name]
    if(len(path) == 1) : 
        return path

rule additional_reads_on_contigs_mapping : 
    params : 
        additional_reads = config["additional_reads"],
    input :
        assembly = "outputs/{sample}/{assembler}/assembly.fasta",
        reads = get_additional_read_path
    output : "outputs/{sample}/{assembler}/{additional_read_name}_reads_on_contigs.bam",
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