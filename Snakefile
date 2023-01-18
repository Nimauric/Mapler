configfile: "config.yaml"

rule reads_download:
    input:
        "config.yaml"
    output:
        expand("data/raw_reads/{read}.fastq.gz",read=config["reads"])
    shell:
        expand("reads_downloader.sh {read}",read=config["reads"])
