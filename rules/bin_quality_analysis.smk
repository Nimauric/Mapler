
rule checkm : 
    params : 
        output_directory = "outputs/{sample}/{assembler}/metabat2_bins_{reference_reads}_alignement/checkm/",
        bins_extension = "fa",
    input :
        bins = "outputs/{sample}/{assembler}/metabat2_bins_{reference_reads}_alignement/bins",
    conda : "../envs/checkm.yaml",
    threads : config["rule_checkm"]["threads"]
    resources :
        cpus_per_task = config["rule_checkm"]["threads"],
        mem_mb=config["rule_checkm"]["memory"],
        runtime=eval(config["rule_checkm"]["time"]),
    output :"outputs/{sample}/{assembler}/metabat2_bins_{reference_reads}_alignement/checkm/bins_quality_check.tsv"
    shell : "./sources/bin_quality_analysis/checkm_wraper.sh {params.bins_extension} {input.bins} {params.output_directory} {output}"

rule checkm_report_writer : 
    input :
        bins = "outputs/{sample}/{assembler}/metabat2_bins_{reference_reads}_alignement/bins",
        checkm_results = "outputs/{sample}/{assembler}/metabat2_bins_{reference_reads}_alignement/checkm/bins_quality_check.tsv",
    conda : "../envs/python.yaml",
    threads : config["rule_checkm_report_writer"]["threads"]
    resources :
        cpus_per_task = config["rule_checkm_report_writer"]["threads"],
        mem_mb=config["rule_checkm_report_writer"]["memory"],
        runtime=eval(config["rule_checkm_report_writer"]["time"]),
    output : "outputs/{sample}/{assembler}/metabat2_bins_{reference_reads}_alignement/checkm_report.txt"
    shell : 
        "python3 sources/bin_quality_analysis/checkm_report_writer.py {input.checkm_results} {input.bins} > {output}"


rule kraken2_on_bins :
    params : 
        database = config["kraken2db"],
        kraken2_directory = config["kraken2bin"],
        krona_directory = config["kronabin"],
        output_directory ="outputs/{sample}/{assembler}/metabat2_bins_{reference_reads}_alignement/kraken2/bin.{target_bin}"
    input : "outputs/{sample}/{assembler}/metabat2_bins_{reference_reads}_alignement/bins/bin.{target_bin}.fa"
    output : "outputs/{sample}/{assembler}/metabat2_bins_{reference_reads}_alignement/kraken2/bin.{target_bin}/krona.html",
    threads : config["rule_kraken2_on_bins"]["threads"]
    resources :
        cpus_per_task = config["rule_kraken2_on_bins"]["threads"],
        mem_mb=config["rule_kraken2_on_bins"]["memory"],
        runtime=eval(config["rule_kraken2_on_bins"]["time"]),
    shell : "./sources/read_quality_analysis/kraken2.sh {params.kraken2_directory} {params.database} {params.krona_directory} {input} {params.output_directory}"
