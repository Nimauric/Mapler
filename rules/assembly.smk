if("metaMDBG" in config["assemblers"]) :
    rule metaMDBG_assembly :
        params : 
            expand("{name}", name=get_samples("name")),
            tmp_directory="outputs/{sample}/metaMDBG/tmp/",
            technology=get_sample_technology,
            cleanup=get_cleanup_tmp()
        conda : "../envs/metaMDBG.yaml"
        threads : config["rule_metaMDBG_assembly"]["threads"]
        resources :
            cpus_per_task = config["rule_metaMDBG_assembly"]["threads"],
            mem_mb=config["rule_metaMDBG_assembly"]["memory"],
            runtime=eval(config["rule_metaMDBG_assembly"]["time"]),
        input : get_long_read_path,
        output : f"outputs/{{sample}}/metaMDBG/{ASSEMBLY_FILENAME}"
        shell : "./sources/assembly/metaMDBG_wraper.sh {input} {params.tmp_directory} {output} {params.technology} {params.cleanup}"

if("myloasm" in config["assemblers"]) :
    rule myloasm_assembly :
        params : 
            expand("{name}", name=get_samples("name")),
            tmp_directory="outputs/{sample}/myloasm/tmp/",
            technology=get_sample_technology,
            cleanup=get_cleanup_tmp()
        conda : "../envs/myloasm.yaml"
        threads : config["rule_myloasm_assembly"]["threads"]
        resources :
            cpus_per_task = config["rule_myloasm_assembly"]["threads"],
            mem_mb=config["rule_myloasm_assembly"]["memory"],
            runtime=eval(config["rule_myloasm_assembly"]["time"]),
        input : get_long_read_path,
        output : f"outputs/{{sample}}/myloasm/{ASSEMBLY_FILENAME}"
        shell : "./sources/assembly/myloasm_wraper.sh {input} {params.tmp_directory} {output} {params.technology} {params.cleanup} {threads}"


if("metaflye" in config["assemblers"]) :
    rule metaflye_assembly :
        params : 
            expand("{name}", name=get_samples("name")),
            output_directory="outputs/{sample}/metaflye/",
            technology=get_sample_technology,
            cleanup=get_cleanup_tmp()
        conda : "../envs/flye.yaml"
        threads : config["rule_metaflye_assembly"]["threads"]
        resources :
            cpus_per_task = config["rule_metaflye_assembly"]["threads"],
            mem_mb=config["rule_metaflye_assembly"]["memory"],
            runtime=eval(config["rule_metaflye_assembly"]["time"]),
        input : get_long_read_path,
        output : f"outputs/{{sample}}/metaflye/{ASSEMBLY_FILENAME}",
        shell : "./sources/assembly/metaflye_wraper.sh {input} {params.output_directory} {output} {params.technology} {params.cleanup}"

if("hifiasm_meta" in config["assemblers"]) :
    rule hifiasm_meta_assembly :
        params : 
            expand("{name}", name=get_samples("name")),
            output_directory="outputs/{sample}/hifiasm_meta/",
            cleanup=get_cleanup_tmp()
        conda : "../envs/hifiasm_meta.yaml"
        threads : config["rule_hifiasm_meta_assembly"]["threads"]
        resources :
            cpus_per_task = config["rule_hifiasm_meta_assembly"]["threads"],
            mem_mb=config["rule_hifiasm_meta_assembly"]["memory"],
            runtime=eval(config["rule_hifiasm_meta_assembly"]["time"]),
        input : get_long_read_path,
        output : f"outputs/{{sample}}/hifiasm_meta/{ASSEMBLY_FILENAME}",
        shell : "./sources/assembly/hifiasm_meta_wraper.sh {input} {params.output_directory} {output} {params.cleanup}"


if("operaMS" in config["assemblers"]) :
    rule operaMS_assembly :
        params : 
            expand("{name}", name=get_samples("name")),
            tmp_directory="outputs/{sample}/operaMS/tmp/",
            operaMS_path=config.get("operaMS_path", "outputs/tools/OPERA-MS"),
            short_read_assembly=config.get("short_read_assembly", "none"),
            cleanup=get_cleanup_tmp()
        conda : "../envs/operaMS.yaml"
        threads : config["rule_operaMS_assembly"]["threads"]
        resources :
            cpus_per_task = config["rule_operaMS_assembly"]["threads"],
            mem_mb=config["rule_operaMS_assembly"]["memory"],
            runtime=eval(config["rule_operaMS_assembly"]["time"]),
        input : 
            long_reads = get_long_read_path,
            auxiliary_short_read_1 = lambda wildcards: get_auxiliary_short_read("auxiliary_short_reads_1", wildcards),
            auxiliary_short_read_2 = lambda wildcards: get_auxiliary_short_read("auxiliary_short_reads_2", wildcards),
        output : f"outputs/{{sample}}/operaMS/{ASSEMBLY_FILENAME}"
        shell : "./sources/assembly/operaMS_wraper.sh {params.operaMS_path} {input.long_reads} {input.auxiliary_short_read_1} {input.auxiliary_short_read_2} {params.short_read_assembly} {params.tmp_directory} {output} {params.cleanup} {threads}"


if("hylight" in config["assemblers"]) :
    rule hylight_assembly :
        params :
            expand("{name}", name=get_samples("name")),
            tmp_directory="outputs/{sample}/hylight/tmp/",
            cleanup=get_cleanup_tmp()
        conda : "../envs/hylight.yaml"
        threads : config["rule_hylight_assembly"]["threads"]
        resources :
            cpus_per_task = config["rule_hylight_assembly"]["threads"],
            mem_mb = config["rule_hylight_assembly"]["memory"],
            runtime = eval(config["rule_hylight_assembly"]["time"]),
        input :
            long_reads = get_long_read_path,
            auxiliary_short_read_1 = lambda wildcards: get_auxiliary_short_read("auxiliary_short_reads_1", wildcards),
            auxiliary_short_read_2 = lambda wildcards: get_auxiliary_short_read("auxiliary_short_reads_2", wildcards),
        output : f"outputs/{{sample}}/hylight/{ASSEMBLY_FILENAME}"
        shell : "./sources/assembly/hylight_wraper.sh {input.long_reads} {input.auxiliary_short_read_1} {input.auxiliary_short_read_2} {params.tmp_directory} {output} {params.cleanup} {threads}"


if("metaspades" in config["assemblers"]) :
    rule metaspades_assembly :
        params :
            expand("{name}", name=get_samples("name")),
            output_directory="outputs/{sample}/metaspades/",
            long_reads=get_optional_long_read_path,
            technology=get_metaspades_long_read_technology,
            cleanup=get_cleanup_tmp()
        conda : "../envs/spades.yaml"
        threads : config["rule_metaspades_assembly"]["threads"]
        resources :
            cpus_per_task = config["rule_metaspades_assembly"]["threads"],
            mem_mb = config["rule_metaspades_assembly"]["memory"],
            runtime = eval(config["rule_metaspades_assembly"]["time"]),
        input :
            reads_1 = lambda wildcards: get_short_read("short_reads_1", wildcards),
            reads_2 = lambda wildcards: get_short_read("short_reads_2", wildcards)
        output : f"outputs/{{sample}}/metaspades/{ASSEMBLY_FILENAME}",
        shell : "./sources/assembly/metaspades_wraper.sh {input.reads_1} {input.reads_2} {params.output_directory} {output} {params.long_reads} {params.technology} {params.cleanup} {threads} {resources.mem_mb}"


if("custom_assembly" in config["assemblers"]) :
    rule link_assembly : 
        input : config["custom_assembly_path"],
        output : f"outputs/{{sample}}/custom_assembly/{ASSEMBLY_FILENAME}"
        shell : "./sources/assembly/finalize_assembly_output.sh {input} {output}"
