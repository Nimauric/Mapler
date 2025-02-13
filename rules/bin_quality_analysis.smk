
rule checkm: 
    params: 
        output_directory = "outputs/{sample}/{assembler}/{binning}/checkm/",
        bins_extension = "fa",
        database_directory = config["checkm_database"]
    input:
        bins = "outputs/{sample}/{assembler}/{binning}/bins",
    conda: "../envs/checkm.yaml",
    threads: config["rule_checkm"]["threads"]
    resources:
        cpus_per_task = config["rule_checkm"]["threads"],
        mem_mb=config["rule_checkm"]["memory"],
        runtime=eval(config["rule_checkm"]["time"]),
    output:"outputs/{sample}/{assembler}/{binning}/checkm/quality_report.tsv"
    shell: "./sources/bin_quality_analysis/checkm_wraper.sh {params.bins_extension} {input.bins} {params.output_directory} {output} {params.database_directory}"

rule checkm_report_writer: 
    input:
        bins = "outputs/{sample}/{assembler}/{binning}/bins",
        checkm_results = "outputs/{sample}/{assembler}/{binning}/checkm/quality_report.tsv",
    conda: "../envs/python.yaml",
    threads: config["rule_checkm_report_writer"]["threads"]
    resources:
        cpus_per_task = config["rule_checkm_report_writer"]["threads"],
        mem_mb=config["rule_checkm_report_writer"]["memory"],
        runtime=eval(config["rule_checkm_report_writer"]["time"]),
    output: "outputs/{sample}/{assembler}/{binning}/checkm/checkm_report.txt"
    shell: 
        "python3 sources/bin_quality_analysis/checkm_report_writer.py {input.checkm_results} {input.bins} > {output}"

rule checkm_plot:
    input : "outputs/{sample}/{assembler}/{binning}/checkm/checkm_report.txt"
    output : "outputs/{sample}/{assembler}/{binning}/checkm/checkm-plot.pdf"
    conda : "../envs/python.yaml"
    shell : "python3 sources/bin_quality_analysis/checkm_plot.py {input} {output}"


rule kraken2_on_bins:
    params: 
        database = config["kraken2db"],
        output_directory ="outputs/{sample}/{assembler}/{binning}/kraken2/bin.{target_bin}"
    input: "outputs/{sample}/{assembler}/{binning}/bins/bin.{target_bin}.fa"
    output: "outputs/{sample}/{assembler}/{binning}/kraken2/bin.{target_bin}/krona.html",
    threads: config["rule_kraken2_on_bins"]["threads"]
    resources:
        cpus_per_task = config["rule_kraken2_on_bins"]["threads"],
        mem_mb=config["rule_kraken2_on_bins"]["memory"],
        runtime=eval(config["rule_kraken2_on_bins"]["time"]),
    shell: "./sources/read_quality_analysis/kraken2.sh {params.database} {input} {params.output_directory}"

# GTDBTK
rule gtdbtk_on_bins:
    params: 
        output_directory="outputs/{sample}/{assembler}/{binning}/gtdbtk/",
        gtdbtk_database = config["gtdbtk_database"],
        mash_database = config["mash_database"]
    conda: "../envs/gtdbtk.yaml"
    threads: config["rule_gtdbtk_on_bins"]["threads"]
    resources:
        cpus_per_task = config["rule_gtdbtk_on_bins"]["threads"],
        mem_mb=config["rule_gtdbtk_on_bins"]["memory"],
        runtime=eval(config["rule_gtdbtk_on_bins"]["time"]),
    input: "outputs/{sample}/{assembler}/{binning}/bins",
    output: "outputs/{sample}/{assembler}/{binning}/gtdbtk/results/gtdbtk.bac120.summary.tsv"
    shell: "./sources/bin_quality_analysis/gtdbtk_wraper.sh {params.output_directory} {params.gtdbtk_database} {params.mash_database} {input}"


rule read_contig_mapping_plot: 
    input:
        checkm_report = "outputs/{sample}/{assembler}/{binning}/checkm/quality_report.tsv",
        bins_directory = "outputs/{sample}/{assembler}/{binning}/bins",
        reads_on_contigs_alignment = "outputs/{sample}/{assembler}/reads_on_contigs.bam",
        reads = lambda wildcards: get_sample("read_path", wildcards)
    threads: config["rule_read_contig_mapping_plot"]["threads"]
    resources:
        cpus_per_task = config["rule_read_contig_mapping_plot"]["threads"],
        mem_mb=config["rule_read_contig_mapping_plot"]["memory"],
        runtime=eval(config["rule_read_contig_mapping_plot"]["time"]),
    conda: "../envs/python.yaml"
    output: 
        plot="outputs/{sample}/{assembler}/{binning}/read_contig_mapping_plot.pdf",
        text="outputs/{sample}/{assembler}/{binning}/read_contig_mapping.txt"
    shell: "python3 sources/bin_quality_analysis/reads_on_contigs_mapping_plot.py {input.checkm_report} {input.bins_directory} {input.reads_on_contigs_alignment} {input.reads} {output.plot} {output.text}"
