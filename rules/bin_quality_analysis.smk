
rule checkm : 
    params : 
        output_directory = "outputs/{sample}/{assembler}/metabat2_bins_{reference_reads}_alignement/checkm/",
        bins_extension = "fa",
    input :
        bins = "outputs/{sample}/{assembler}/metabat2_bins_{reference_reads}_alignement/bins",
    conda : "../envs/checkm.yaml",
    threads : 16
    resources :
        cpus_per_task = 16, #
        mem_mb=100*1000,
        runtime=24*60 #on mmdbg irg salad, TIMEOUT => multithreading 16 CPUs
    output :"outputs/{sample}/{assembler}/metabat2_bins_{reference_reads}_alignement/checkm/bins_quality_check.tsv"
    shell : "./sources/bin_quality_analysis/checkm_wraper.sh {params.bins_extension} {input.bins} {params.output_directory} {output}"

rule checkm_report_writer : 
    input :
        bins = "outputs/{sample}/{assembler}/metabat2_bins_{reference_reads}_alignement/bins",
        checkm_results = "outputs/{sample}/{assembler}/metabat2_bins_{reference_reads}_alignement/checkm/bins_quality_check.tsv",
    conda : "../envs/python.yaml",
    resources :
        mem_mb=100*1000,
        runtime=1*60,
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
    threads : 12
    resources :
        cpus_per_task = 6, 
        mem_mb= 100*1000 ,
        runtime=1*4*60,
    shell : "./sources/read_quality_analysis/kraken2.sh {params.kraken2_directory} {params.database} {params.krona_directory} {input} {params.output_directory}"
