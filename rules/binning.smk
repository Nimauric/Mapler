if(is_binning_enabled() and "metabat2" in get_configured_binners()) :
    rule metabat2_binning: 
        input: 
            contigs =  f"outputs/{{sample}}/{{assembler}}/{ASSEMBLY_FILENAME}",
            alignement =  "outputs/{sample}/{assembler}/{reference_reads}_on_contigs.bam"
        conda: "../envs/metabat2.yaml",
        threads: config["rules_metabat2_binnings"]["threads"]
        resources:
            cpus_per_task = config["rules_metabat2_binnings"]["threads"],
            mem_mb=config["rules_metabat2_binnings"]["memory"],
            runtime=eval(config["rules_metabat2_binnings"]["time"]),
        output: 
            directory = directory("outputs/{sample}/{assembler}/metabat2_bins_{reference_reads}_alignement/bins"),
            at_least_one_bin = "outputs/{sample}/{assembler}/metabat2_bins_{reference_reads}_alignement/bins/bin.1.fa"
        shell: "./sources/binning/metabat2_wraper.sh  {input.contigs} {input.alignement} {output.directory}"

if(is_binning_enabled() and short_read_cobinning_enabled() and "metabat2" in get_configured_binners()) :
    rule metabat2_cobinning_short_reads: 
        input: 
            contigs =  f"outputs/{{sample}}/{{assembler}}/{ASSEMBLY_FILENAME}",
            alignement1 =  "outputs/{sample}/{assembler}/reads_on_contigs.bam",
            alignement2 =  "outputs/{sample}/{assembler}/auxiliary_short_reads_on_contigs.bam",
        conda: "../envs/metabat2.yaml",
        threads: config["rules_metabat2_binnings"]["threads"]
        resources:
            cpus_per_task = config["rules_metabat2_binnings"]["threads"],
            mem_mb=config["rules_metabat2_binnings"]["memory"],
            runtime=eval(config["rules_metabat2_binnings"]["time"]),
        output: 
            directory = directory("outputs/{sample}/{assembler}/metabat2_bins_cobinning_alignement/bins"),
            at_least_one_bin = "outputs/{sample}/{assembler}/metabat2_bins_cobinning_alignement/bins/bin.1.fa"
        shell: "./sources/binning/metabat2_wraper.sh  {input.contigs} {input.alignement1} {output.directory} {input.alignement2}"

if(is_binning_enabled() and additional_reads_cobinning_enabled() and "metabat2" in get_configured_binners()) :
    rule metabat2_cobinning_additional_reads: 
        input: 
            contigs =  f"outputs/{{sample}}/{{assembler}}/{ASSEMBLY_FILENAME}",
            alignement =  "outputs/{sample}/{assembler}/reads_on_contigs.bam",
            additional_alignements =  expand("outputs/{{sample}}/{{assembler}}/{additional_reads_name}_reads_on_contigs.bam", additional_reads_name = [ar["name"] for ar in config["additional_reads"]]),
        conda: "../envs/metabat2.yaml",
        threads: config["rules_metabat2_binnings"]["threads"]
        resources:
            cpus_per_task = config["rules_metabat2_binnings"]["threads"],
            mem_mb=config["rules_metabat2_binnings"]["memory"],
            runtime=eval(config["rules_metabat2_binnings"]["time"]),
        output: 
            directory = directory("outputs/{sample}/{assembler}/metabat2_bins_additional_reads_cobinning_alignement/bins"),
            at_least_one_bin = "outputs/{sample}/{assembler}/metabat2_bins_additional_reads_cobinning_alignement/bins/bin.1.fa"
        shell: "./sources/binning/metabat2_wraper.sh  {input.contigs} {input.alignement} {output.directory} {input.additional_alignements}"

if(is_binning_enabled() and "custom" in get_configured_binners()) :
    rule copy_bins:
        input: config["custom_bins_path"]
        output:
            directory = directory("outputs/{sample}/{assembler}/custom_bins_reads_alignement/bins"),
        shell: "cp -r {input} {output.directory} "
