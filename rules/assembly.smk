if("metaMDBG" in config["assemblers"]) :
    rule metaMDBG_assembly :
        params : 
            expand("{name}", name=get_samples("name")),
            tmp_directory="outputs/{sample}/metaMDBG/tmp/"
        conda : "../envs/metaMDBG.yaml"
        threads : config["rule_metaMDBG_assembly"]["threads"]
        resources :
            cpus_per_task = config["rule_metaMDBG_assembly"]["threads"],
            mem_mb=config["rule_metaMDBG_assembly"]["memory"],
            runtime=eval(config["rule_metaMDBG_assembly"]["time"]),
        input : lambda wildcards: get_sample("read_path", wildcards),
        output : "outputs/{sample}/metaMDBG/assembly.fasta"
        shell : "./sources/assembly/metaMDBG_wraper.sh {input} {params.tmp_directory} {output}"

if("metaflye" in config["assemblers"]) :
    rule metaflye_assembly :
        params : 
            expand("{name}", name=get_samples("name")),
            output_directory="outputs/{sample}/metaflye/"
        conda : "../envs/flye.yaml"
        threads : config["rule_metaflye_assembly"]["threads"]
        resources :
            cpus_per_task = config["rule_metaflye_assembly"]["threads"],
            mem_mb=config["rule_metaflye_assembly"]["memory"],
            runtime=eval(config["rule_metaflye_assembly"]["time"]),
        input : lambda wildcards: get_sample("read_path", wildcards),
        output : "outputs/{sample}/metaflye/assembly.fasta",
        shell : "./sources/assembly/metaflye_wraper.sh {input} {params.output_directory}"

if("hifiasm_meta" in config["assemblers"]) :
    rule hifiasm_meta_assembly :
        params : 
            expand("{name}", name=get_samples("name")),
            output_directory="outputs/{sample}/hifiasm_meta/"
        conda : "../envs/hifiasm_meta.yaml"
        threads : config["rule_hifiasm_meta_assembly"]["threads"]
        resources :
            cpus_per_task = config["rule_hifiasm_meta_assembly"]["threads"],
            mem_mb=config["rule_hifiasm_meta_assembly"]["memory"],
            runtime=eval(config["rule_hifiasm_meta_assembly"]["time"]),
        input : lambda wildcards: get_sample("read_path", wildcards),
        output : "outputs/{sample}/hifiasm_meta/assembly.fasta",
        shell : "./sources/assembly/hifiasm_meta_wraper.sh {input} {params.output_directory}"


if("operaMS" in config["assemblers"]) :
    rule operaMS_assembly :
        params : 
            expand("{name}", name=get_samples("name")),
            tmp_directory="outputs/{sample}/operaMS/tmp/",
            operaMS_path=config["operaMS_path"],
        conda : "../envs/operaMS.yaml"
        threads : config["rule_operaMS_assembly"]["threads"]
        resources :
            cpus_per_task = config["rule_operaMS_assembly"]["threads"],
            mem_mb=config["rule_operaMS_assembly"]["memory"],
            runtime=eval(config["rule_operaMS_assembly"]["time"]),
        input : 
            long_reads = lambda wildcards: get_sample("read_path", wildcards),
            short_read_1 = config["short_reads_1"],
            short_read_2 = config["short_reads_2"],
            short_read_assembly=config["short_read_assembly"],
        output : "outputs/{sample}/operaMS/assembly.fasta"
        shell : "./sources/assembly/operaMS_wraper.sh {params.operaMS_path} {input.long_reads} {input.short_read_1} {input.short_read_2} {input.short_read_assembly} {params.tmp_directory} {output}"

if("custom_assembly" in config["assemblers"]) :
    rule copy_assembly : 
        input : config["custom_assembly_path"],
        output : "outputs/{sample}/custom_assembly/assembly.fasta"
        shell : "cp {input} {output}"