 


rule reads_on_contigs_mapping : 
    params : 
        expand("{sample}", sample=get_samples("name")),
    input :
        assembly = "outputs/{sample}/{assembler}/assembly.fasta",
        reads = lambda wildcards: get_sample( "read_path", wildcards), 
    output : "outputs/{sample}/{assembler}/reads_on_contigs.bam"
    conda : "../envs/mapping.yaml"
    threads : config["rules_mapping"]["threads"]
    resources :
        cpus_per_task = config["rules_mapping"]["threads"],
        mem_mb=config["rules_mapping"]["memory"],
        runtime=eval(config["rules_mapping"]["time"]),
    shell : "./sources/mapping.sh {output} {input.reads} {input.assembly} map-hifi "

if(config["short_read_binning"] or config["short_read_cobinning"] or config["short_read_mapping_evaluation"]) :
    rule short_reads_on_contigs_mapping : 
        params : 
            expand("{sample}", sample=get_samples("name")),
        input :
            assembly = "outputs/{sample}/{assembler}/assembly.fasta",
            R1 = config["short_reads_1"], 
            R2 = config["short_reads_2"], 
        output : "outputs/{sample}/{assembler}/short_reads_on_contigs.bam"
        conda : "../envs/mapping.yaml"
        threads : config["rules_mapping"]["threads"]
        resources :
            cpus_per_task = config["rules_mapping"]["threads"],
            mem_mb=config["rules_mapping"]["memory"],
            runtime=eval(config["rules_mapping"]["time"]),
        shell : "./sources/mapping.sh {output} {input.R1} {input.assembly} sr {input.R2}"



def get_additional_read_path(wildcards):
    name = wildcards.additional_read_name
    path = [p["path"] for p in config["additional_reads"] if p["name"] == name]
    print(name, path)
    if(len(path) == 1) : 
        return path

if(config["additional_reads_cobinning"]) :
    rule additional_reads_on_contigs_mapping : 
        params : 
            additional_reads = config["additional_reads"],
        input :
            assembly = "outputs/{sample}/{assembler}/assembly.fasta",
            reads = get_additional_read_path
        output : "outputs/{sample}/{assembler}/{additional_read_name}_reads_on_contigs.bam",
        conda : "../envs/mapping.yaml"
        threads : config["rules_mapping"]["threads"]
        resources :
            cpus_per_task = config["rules_mapping"]["threads"],
            mem_mb=config["rules_mapping"]["memory"],
            runtime=eval(config["rules_mapping"]["time"]),
        shell : "./sources/mapping.sh {output} {input.reads} {input.assembly} map-hifi "

if(config['reference_mapping_evaluation']) :
    rule reads_on_reference_mapping : 
        input :
            reads = lambda wildcards: get_sample( "read_path", wildcards), 
            reference = lambda wildcards: get_reference(wildcards.reference_name)
        output : "outputs/{sample}/reads_on_reference.{reference_name}.bam"
        conda : "../envs/mapping.yaml"
        threads : config["rules_mapping"]["threads"]
        resources :
            cpus_per_task = config["rules_mapping"]["threads"],
            mem_mb=config["rules_mapping"]["memory"],
            runtime=eval(config["rules_mapping"]["time"]),
        shell : "./sources/mapping.sh {output} {input.reads} {input.reference} map-hifi"


    rule contigs_on_reference_mapping : 
        input :
            assembly = "outputs/{sample}/{assembler}/assembly.fasta",
            reference = lambda wildcards: get_reference(wildcards.reference_name)
        output : "outputs/{sample}/{assembler}/contigs_on_reference.{reference_name}.bam"
        conda : "../envs/mapping.yaml"
        threads : config["rules_mapping"]["threads"]
        resources :
            cpus_per_task = config["rules_mapping"]["threads"],
            mem_mb=config["rules_mapping"]["memory"],
            runtime=eval(config["rules_mapping"]["time"]),
        shell : "./sources/mapping.sh {output} {input.assembly} {input.reference} asm20"
