

if(nanoplot_enabled() or config["kraken2"] or config["kat"]) :
    rule extract_unmapped_reads : 
        params : 
            expand("{sample}", sample=get_samples("name")),
            output_directory="outputs/{sample}/{assembler}/"
        input :
            mapping = "outputs/{sample}/{assembler}/reads_on_contigs.bam",    
        output :
            mapped_reads = f"outputs/{{sample}}/{{assembler}}/mapped_reads{READ_FRACTION_SUFFIX}",
            unmapped_reads = f"outputs/{{sample}}/{{assembler}}/unmapped_reads{READ_FRACTION_SUFFIX}",
        conda : "../envs/mapping.yaml"
        threads : config["rule_extract_unmapped_reads"]["threads"]
        resources :
            cpus_per_task = config["rule_extract_unmapped_reads"]["threads"],
            mem_mb=config["rule_extract_unmapped_reads"]["memory"],
            runtime=eval(config["rule_extract_unmapped_reads"]["time"]),
        shell : "./sources/read_quality_analysis/extract_unmapped_reads.sh {input.mapping} {output.mapped_reads} {output.unmapped_reads}"

if(fastqc_enabled()) :
    rule fastqc : 
        params : 
            output_directory = "outputs/{sample}/{assembler}/fastqc/{fraction}"
        input :
            R1 = get_fastqc_R1,
            R2 = get_fastqc_R2
        output :
            R1_html = "outputs/{sample}/{assembler}/fastqc/{fraction}/R1_fastqc.html",
            R2_html = "outputs/{sample}/{assembler}/fastqc/{fraction}/R2_fastqc.html"
        conda : "../envs/fastqc.yaml"
        threads : config["rule_fastqc"]["threads"]
        resources :
            cpus_per_task = config["rule_fastqc"]["threads"],
            mem_mb=config["rule_fastqc"]["memory"],
            runtime=eval(config["rule_fastqc"]["time"]),
        shell : "bash ./sources/read_quality_analysis/fastqc.sh {input.R1} {input.R2} {params.output_directory} {output.R1_html} {output.R2_html} {threads}"

if(fastqc_enabled()) :
    rule extract_short_read_fractions :
        input :
            bam = "outputs/{sample}/{assembler}/short_reads_on_contigs.bam"
        output :
            mapped_R1 = f"outputs/{{sample}}/{{assembler}}/fastqc/mapped/R1{READ_FRACTION_SUFFIX}",
            mapped_R2 = f"outputs/{{sample}}/{{assembler}}/fastqc/mapped/R2{READ_FRACTION_SUFFIX}",
            unmapped_R1 = f"outputs/{{sample}}/{{assembler}}/fastqc/unmapped/R1{READ_FRACTION_SUFFIX}",
            unmapped_R2 = f"outputs/{{sample}}/{{assembler}}/fastqc/unmapped/R2{READ_FRACTION_SUFFIX}"
        conda : "../envs/mapping.yaml"
        threads : config["rule_extract_unmapped_reads"]["threads"]
        resources :
            cpus_per_task = config["rule_extract_unmapped_reads"]["threads"],
            mem_mb = config["rule_extract_unmapped_reads"]["memory"],
            runtime = eval(config["rule_extract_unmapped_reads"]["time"])
        shell :
            "bash ./sources/read_quality_analysis/extract_short_read_fractions.sh {input.bam} outputs/{wildcards.sample}/{wildcards.assembler}/fastqc"

if(nanoplot_enabled()) :
    rule nanoplot : 
        params : 
            expand("{sample}", sample=get_samples("name")),
            expand("{fraction}", fraction=get_fractions()),
            output_directory = "outputs/{sample}/{assembler}/nanoplot/{fraction}"
        input : 
            get_read_path
        output : 
            "outputs/{sample}/{assembler}/nanoplot/{fraction}/NanoPlot-report.html"
        conda : 
            "../envs/nanoplot.yaml"
        threads : 
            config["rule_nanoplot"]["threads"]
        resources :
            cpus_per_task = config["rule_nanoplot"]["threads"],
            mem_mb=config["rule_nanoplot"]["memory"],
            runtime=eval(config["rule_nanoplot"]["time"]),
        shell : 
            "./sources/read_quality_analysis/nanoplot.sh {input} {params.output_directory} {threads}"

if(config["kraken2"]) : 
    rule kraken2 :
        params : 
            expand("{sample}", sample=get_samples("name")),
            expand("{fraction}", fraction=get_fractions()),
            database = config["kraken2db"],
            output_directory = "outputs/{sample}/{assembler}/kraken2/{fraction}"
        input : 
            krona_witness = "outputs/.kronatax",
            read_paths = get_read_path
        conda : "../envs/kraken2.yaml"
        output : "outputs/{sample}/{assembler}/kraken2/{fraction}/krona.html",
        threads : config["rule_kraken2"]["threads"]
        resources :
            cpus_per_task = config["rule_kraken2"]["threads"],
            mem_mb=config["rule_kraken2"]["memory"],
            runtime=eval(config["rule_kraken2"]["time"]),
        shell : "./sources/read_quality_analysis/kraken2.sh {params.database} {input.read_paths} {params.output_directory}"

if(config["kat"]) : 
    rule kat_sect : 
        params : 
            expand("{sample}", sample=get_samples("name")),
            expand("{fraction}", fraction=get_fractions()),
            output_prefix="outputs/{sample}/{assembler}/kat/{fraction}",
        input : 
            reads = get_read_path, # The reads in witch we wish to evaluate the read abundance
            full_reads = get_long_read_path, #The full set, used to evaluate the frequency
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
