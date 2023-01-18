configfile: "config.yaml"


reads = {
    "pacbio1" : "SRR8073714",
    "pacbio2" : "SRR8073715"
}

rule reads_download:
    input:
        "config.yaml"
    output:
        expand("data/raw_reads/{read}.fastq.gz", read = reads.keys())
    shell:
        "reads_downloader.sh"
