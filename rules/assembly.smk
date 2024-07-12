rule metaMDBG_assembly :
    params : 
        expand("{name}", name=get_samples("name")),
        tmp_directory="outputs/{sample}/metaMDBG/tmp/"
    conda : "../envs/metaMDBG.yaml"
    threads : 48
    resources :
        cpus_per_task = 48, #on irg salad, 38% efficiency (Maybe I should reduce number of threads, but 7h is slow enough)
        mem_mb=35*1000, #on irg salad, 48% efficiency : 50GB => 35GB
        runtime=2*24*60, #on irg salad, 7h30
    input : lambda wildcards: get_sample("read_path", wildcards),
    output : "outputs/{sample}/metaMDBG/assembly.fasta"
    shell : "./sources/assembly/metaMDBG_wraper.sh {input} {params.tmp_directory} {output}"

rule metaflye_assembly :
    params : 
        expand("{name}", name=get_samples("name")),
        output_directory="outputs/{sample}/metaflye/"
    conda : "../envs/flye.yaml"
    threads : 48
    resources :
        cpus_per_task = 48, #on irg salad, 60% efficiency
        mem_mb=60*1000, #on irg salad, 33.43% efficiency : 160GB => 60 GB
        runtime=1*24*60, #on irg salad, 4 hours
    input : lambda wildcards: get_sample("read_path", wildcards),
    output : "outputs/{sample}/metaflye/assembly.fasta",
    shell : "./sources/assembly/metaflye_wraper.sh {input} {params.output_directory}"

rule hifiasm_meta_assembly :
    params : 
        expand("{name}", name=get_samples("name")),
        output_directory="outputs/{sample}/hifiasm_meta/"
    conda : "../envs/hifiasm_meta.yaml"
    threads : 48
    resources :
        cpus_per_task = 48, #on irg salad, 12% efficiency  (Maybe I should reduce number of threads, but 17h is slow enough)
        mem_mb=80*1000, #on irg salad, 63% efficiency 
        runtime=2*24*60, #on irg salad, 17 hours
    input : lambda wildcards: get_sample("read_path", wildcards),
    output : "outputs/{sample}/hifiasm_meta/assembly.fasta",
    shell : "./sources/assembly/hifiasm_meta_wraper.sh {input} {params.output_directory}"


rule operaMS_assembly :
    params : 
        expand("{name}", name=get_samples("name")),
        tmp_directory="outputs/{sample}/operaMS/tmp/",
        operaMS_path=config["operaMS_path"],
    conda : "../envs/operaMS.yaml"
    threads : 48
    resources :
        cpus_per_task = 48, # ~25% efficiency 
        mem_mb=200*1000, #OUT OF MEMORY : 100 => 200 G
        runtime=5*24*60,
    input : 
        long_reads = lambda wildcards: get_sample("read_path", wildcards),
        short_read_1 = config["short_reads_1"],
        short_read_2 = config["short_reads_2"],
        short_read_assembly=config["short_read_assembly"],
    output : "outputs/{sample}/operaMS/assembly.fasta"
    shell : "./sources/assembly/operaMS_wraper.sh {params.operaMS_path} {input.long_reads} {input.short_read_1} {input.short_read_2} {input.short_read_assembly} {params.tmp_directory} {output}"
