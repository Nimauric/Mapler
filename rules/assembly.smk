rule metaMDBG_assembly :
    params : 
        expand("{name}", name=get_samples("name")),
        tmp_directory="outputs/{sample}/metaMDBG/tmp/"
    conda : "../envs/metaMDBG.yaml"
    threads : 48
    resources :
        cpus_per_task = 48, #on mmdbg irg salad, 38% efficiency (Maybe I should reduce number of threads, but 7h is slow enough)
        mem_mb=35*1000, #on mmdbg irg salad, 48% efficiency : 50GB => 35GB
        runtime=3*24*60, #on mmdbg irg salad, 7h30
    input : lambda wildcards: get_sample("read_path", wildcards),
    output : "outputs/{sample}/metaMDBG/assembly.fasta"
    shell : "./sources/assembly/metaMDBG_wraper.sh {input} {params.tmp_directory} {output}"


rule operaMS_assembly :
    params : 
        expand("{name}", name=get_samples("name")),
        tmp_directory="outputs/{sample}/operaMS/tmp/",
        operaMS_path=config["operaMS_path"],
    conda : "../envs/operaMS.yaml"
    threads : 48
    resources :
        cpus_per_task = 48, 
        mem_mb=200*1000, #OUT OF MEMORY : 100 => 200 G
        runtime=3*24*60,
    input : 
        long_reads = lambda wildcards: get_sample("read_path", wildcards),
        short_read_1 = config["short_reads_1"],
        short_read_2 = config["short_reads_2"],
        short_read_assembly=config["short_read_assembly"],
    output : "outputs/{sample}/operaMS/assembly.fasta"
    shell : "./sources/assembly/operaMS_wraper.sh {params.operaMS_path} {input.long_reads} {input.short_read_1} {input.short_read_2} {input.short_read_assembly} {params.tmp_directory} {output}"
