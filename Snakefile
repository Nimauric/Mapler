###### Utility function ######

# Return a list containing the attribute "attribute" of each sample
# attribute = {name, read_path, short_reads_1, short_reads_2, auxiliary_short_reads_1, auxiliary_short_reads_2}
def get_samples(attribute) : 
    return [sample[attribute] for sample in config["samples"]]

# Return the attribute "attribute" of an assembly with the name "sample"
def get_sample(attribute, wildcards):
    index = get_samples("name").index(wildcards.sample)
    return get_samples(attribute)[index]

# Return short reads from the sample section only.
def get_short_read(attribute, wildcards):
    sample = get_config_sample(wildcards.sample)

    if attribute in sample:
        return sample[attribute]

    raise ValueError(
        f"{attribute} not found in sample '{wildcards.sample}'. "
        "In the strict sample model, short_reads_1 and short_reads_2 must be "
        "defined inside illumina samples only."
    )
def sample_has_long_reads(wildcards):
    return sample_name_has_long_reads(wildcards.sample)

def sample_has_short_reads(wildcards):
    return sample_name_has_short_reads(wildcards.sample)

def sample_has_auxiliary_short_reads(wildcards):
    return sample_name_has_auxiliary_short_reads(wildcards.sample)

def get_config_sample(sample_name):
    index = get_samples("name").index(sample_name)
    return config["samples"][index]

def sample_name_has_long_reads(sample_name):
    sample = get_config_sample(sample_name)
    return "read_path" in sample and sample["read_path"] != "none"

def sample_name_has_short_reads(sample_name):
    sample = get_config_sample(sample_name)

    return (
        "short_reads_1" in sample
        and "short_reads_2" in sample
        and sample["short_reads_1"] != "none"
        and sample["short_reads_2"] != "none"
    )

def sample_name_has_auxiliary_short_reads(sample_name):
    sample = get_config_sample(sample_name)

    return (
        "auxiliary_short_reads_1" in sample
        and "auxiliary_short_reads_2" in sample
        and sample["auxiliary_short_reads_1"] != "none"
        and sample["auxiliary_short_reads_2"] != "none"
    )

def get_auxiliary_short_read(attribute, wildcards):
    sample = get_config_sample(wildcards.sample)

    if attribute in sample and sample[attribute] != "none":
        return sample[attribute]

    raise ValueError(
        f"{attribute} not found in sample '{wildcards.sample}'. "
        "auxiliary_short_reads_1 and auxiliary_short_reads_2 are required "
        "for hybrid tools such as OPERA-MS and short_read_cobinning."
    )

def get_samples_with_long_reads():
    out = []
    for sample in config["samples"]:
        if "read_path" in sample and sample["read_path"] != "none":
            out.append(sample["name"])
    return out

def get_samples_with_short_reads():
    out = []
    for sample in config["samples"]:
        if sample_name_has_short_reads(sample["name"]):
            out.append(sample["name"])
    return out

##### Sequencing technology and assembler compatibility #####

ASSEMBLER_COMPATIBILITY = {
    "metaMDBG": ["hifi", "ont"],
    "metaflye": ["hifi", "ont"],
    "myloasm": ["hifi", "ont"],
    "hifiasm_meta": ["hifi"],
    "operaMS": ["hifi", "ont"],
    "hylight": ["hifi", "ont"],
    "metaspades": ["illumina"],
    "custom_assembly": ["hifi", "ont", "illumina"],
}

ALLOWED_TECHNOLOGIES = ["hifi", "ont", "illumina"]
SHORT_READ_ASSEMBLERS = ["metaspades"]
HYBRID_ASSEMBLERS = ["operaMS", "hylight"]
ALLOWED_BINNERS = ["metabat2"]
ASSEMBLY_FILENAME = "assembly.fasta.gz"
READ_FRACTION_SUFFIX = ".fastq.gz"
BINNING_MODE_KEYS = [
    "long_read_binning",
    "short_read_binning",
    "short_read_cobinning",
    "additional_reads_cobinning",
]

def get_configured_binners():
    return config.get("binners", [])

def is_binning_enabled():
    return config.get("binning", False)

def long_read_binning_enabled():
    return config.get("long_read_binning", is_binning_enabled())

def short_read_binning_enabled():
    return config.get("short_read_binning", False)

def short_read_cobinning_enabled():
    return config.get("short_read_cobinning", False)

def additional_reads_cobinning_enabled():
    return config.get("additional_reads_cobinning", False)

def any_binning_mode_enabled():
    return (
        long_read_binning_enabled()
        or short_read_binning_enabled()
        or short_read_cobinning_enabled()
        or additional_reads_cobinning_enabled()
    )

def long_read_mapping_plot_enabled():
    return (
        is_binning_enabled()
        and (
            long_read_binning_enabled()
            or short_read_cobinning_enabled()
            or additional_reads_cobinning_enabled()
        )
    )

def get_fractions():
    return config.get("fractions") or []

def get_fraction_evaluation_tools(read_type):
    return (config.get("fraction_evaluation_tools", {}) or {}).get(read_type) or []

def nanoplot_enabled():
    return "nanoplot" in get_fraction_evaluation_tools("long_reads")

def fastqc_enabled():
    return "fastqc" in get_fraction_evaluation_tools("short_reads")

def normalize_cleanup_value(cleanup):
    if cleanup is True:
        return "yes"
    if cleanup is False:
        return "no"
    if isinstance(cleanup, str):
        cleanup = cleanup.strip().lower()
        if cleanup in ["yes", "no"]:
            return cleanup
    raise ValueError(
        "Invalid value for cleanup_tmp. Allowed values are 'yes' or 'no'. "
        "Use cleanup_tmp: no to keep temporary assembly files."
    )

def get_cleanup_tmp():
    return normalize_cleanup_value(config.get("cleanup_tmp", "yes"))

def get_sample_technology(wildcards):
    return get_sample("technology", wildcards)

def get_long_read_path(wildcards):
    tech = get_sample_technology(wildcards)
    read_path = get_config_sample(wildcards.sample).get("read_path", "none")
    if tech == "illumina" or read_path == "none":
        raise ValueError(
            f"Sample '{wildcards.sample}' does not have long reads compatible with "
            "this long-read rule."
        )
    return read_path

def get_optional_long_read_path(wildcards):
    if sample_has_long_reads(wildcards):
        return get_sample("read_path", wildcards)
    return "none"

def get_longread_preset(wildcards):
    tech = get_sample_technology(wildcards)
    if tech == "ont":
        return "lr:hq"
    if tech == "hifi":
        return "map-hifi"
    raise ValueError(f"No long-read minimap2 preset for technology '{tech}'")

def get_metaspades_long_read_technology(wildcards):
    tech = get_sample_technology(wildcards)
    if tech == "hifi":
        return "pacbio"
    if tech == "ont":
        return "ont"
    return "none"

def validate_binning_config():
    if any_binning_mode_enabled() and not is_binning_enabled():
        raise ValueError(
            "At least one binning mode is enabled, but binning is false.\n"
            "Set binning: true or disable all binning modes."
        )

    if is_binning_enabled() and not any_binning_mode_enabled():
        raise ValueError(
            "binning is enabled but no binning mode is enabled.\n"
            f"Enable at least one of: {', '.join(BINNING_MODE_KEYS)}."
        )

    if is_binning_enabled():
        binners = get_configured_binners()
        if len(binners) == 0:
            raise ValueError(
                "binning is enabled but no binner is listed in config['binners']."
            )

        unknown_binners = [
            binner for binner in binners if binner not in ALLOWED_BINNERS
        ]
        if len(unknown_binners) > 0:
            raise ValueError(
                f"Unknown binner(s): {unknown_binners}.\n"
                f"Allowed binners are: {ALLOWED_BINNERS}."
            )

    if is_binning_enabled() and short_read_binning_enabled():
        binners = get_configured_binners()
        if "metabat2" not in binners:
            raise ValueError(
                "short_read_binning is enabled but metabat2 is not listed in "
                "config['binners']."
            )

        configured_short_read_assemblers = [
            assembler
            for assembler in config["assemblers"]
            if assembler in SHORT_READ_ASSEMBLERS
        ]
        if len(configured_short_read_assemblers) == 0:
            raise ValueError(
                "short_read_binning is enabled but no short-read assembler is "
                f"listed in config['assemblers']. Add one of: {SHORT_READ_ASSEMBLERS}."
            )

        illumina_samples = [
            sample for sample in config["samples"]
            if sample.get("technology") == "illumina"
        ]
        if len(illumina_samples) == 0:
            raise ValueError(
                "short_read_binning is enabled but no illumina sample is defined.\n"
                "Add a sample with technology: illumina and "
                "short_reads_1/short_reads_2."
            )

        missing_short_reads = [
            sample.get("name", "<missing name>")
            for sample in illumina_samples
            if "short_reads_1" not in sample or "short_reads_2" not in sample
        ]
        if len(missing_short_reads) > 0:
            raise ValueError(
                "short_read_binning requires short_reads_1 and short_reads_2 "
                "inside each illumina sample. Missing for sample(s): "
                f"{missing_short_reads}."
            )

    if is_binning_enabled() and short_read_cobinning_enabled():
        samples_with_auxiliary_short_reads = [
            sample["name"]
            for sample in config["samples"]
            if sample.get("technology") in ["hifi", "ont"]
            and sample_name_has_auxiliary_short_reads(sample["name"])
        ]
        if len(samples_with_auxiliary_short_reads) == 0:
            raise ValueError(
                "short_read_cobinning is enabled but no long-read sample defines "
                "auxiliary_short_reads_1 and auxiliary_short_reads_2. "
                "short_read_cobinning now uses auxiliary_short_reads, not "
                "illumina sample short_reads_1/short_reads_2."
            )

def validate_reference_config():
    reference_options = [
        "metaquast",
        "reference_mapping_evaluation",
        "contigs_on_reference_mapping",
    ]

    enabled_reference_options = [
        option for option in reference_options
        if config.get(option, False)
    ]

    if len(enabled_reference_options) > 0:
        if not config.get("reference_genomes"):
            raise ValueError(
                "Reference-based evaluation is enabled but "
                "config['reference_genomes'] is missing or empty.\n"
                f"Enabled options: {enabled_reference_options}\n"
                "Please define reference_genomes in the config."
            )

def validate_fraction_evaluation_tools():
    tools = config.get("fraction_evaluation_tools", {}) or {}

    allowed = {
        "long_reads": ["nanoplot"],
        "short_reads": ["fastqc"],
    }

    for read_type, selected_tools in tools.items():
        selected_tools = selected_tools or []

        if read_type not in allowed:
            raise ValueError(
                f"Unknown read type in fraction_evaluation_tools: {read_type}. "
                f"Allowed read types are: {list(allowed.keys())}"
            )

        for tool in selected_tools:
            if tool not in allowed[read_type]:
                raise ValueError(
                    f"Invalid tool '{tool}' for {read_type}. "
                    f"Allowed tools for {read_type}: {allowed[read_type]}"
                )

def validate_cleanup_config():
    get_cleanup_tmp()

def validate_sample_technology_config():
    for sample in config["samples"]:
        sample_name = sample.get("name", "<missing name>")
        if "technology" not in sample:
            raise ValueError(f"Sample '{sample_name}' must define a technology.")

        technology = sample["technology"]
        if technology not in ALLOWED_TECHNOLOGIES:
            raise ValueError(
                f"Sample '{sample_name}' has unknown technology '{technology}'. "
                f"Allowed values are: {ALLOWED_TECHNOLOGIES}."
            )

        if technology in ["hifi", "ont"] and not sample_name_has_long_reads(sample_name):
            raise ValueError(
                f"Sample '{sample_name}' uses technology '{technology}' and must "
                "define a long-read read_path."
            )

        if technology == "illumina" and not sample_name_has_short_reads(sample_name):
            raise ValueError(
                f"Sample '{sample_name}' uses technology 'illumina' and must define "
                "short_reads_1 and short_reads_2."
            )

        if technology in ["hifi", "ont"] and any(
            key in sample for key in ["short_reads_1", "short_reads_2"]
        ):
            raise ValueError(
                f"Sample '{sample_name}' uses technology '{technology}' and must not "
                "define short_reads_1/2. Use auxiliary_short_reads_1/2 for "
                "hybrid tools on long-read samples."
            )

        auxiliary_keys = [
            key for key in ["auxiliary_short_reads_1", "auxiliary_short_reads_2"]
            if key in sample and sample[key] != "none"
        ]
        if len(auxiliary_keys) == 1:
            raise ValueError(
                f"Sample '{sample_name}' defines only one auxiliary short-read file. "
                "Both auxiliary_short_reads_1 and auxiliary_short_reads_2 must be "
                "defined together."
            )

        if technology == "illumina" and any(
            key in sample for key in ["auxiliary_short_reads_1", "auxiliary_short_reads_2"]
        ):
            raise ValueError(
                f"Sample '{sample_name}' uses technology 'illumina' and must not "
                "define auxiliary_short_reads_1/2. Use short_reads_1 and "
                "short_reads_2 for illumina samples."
            )

    for assembler in config["assemblers"]:
        if assembler not in ASSEMBLER_COMPATIBILITY:
            raise ValueError(
                f"Assembler '{assembler}' is not listed in ASSEMBLER_COMPATIBILITY."
            )

    for assembler in SHORT_READ_ASSEMBLERS:
        if assembler not in ASSEMBLER_COMPATIBILITY:
            raise ValueError(
                f"Assembler '{assembler}' is not listed in ASSEMBLER_COMPATIBILITY."
            )

    for assembler in config["assemblers"]:
        compatible_samples = [
            sample["name"]
            for sample in config["samples"]
            if sample["technology"] in ASSEMBLER_COMPATIBILITY[assembler]
            and (
                assembler not in HYBRID_ASSEMBLERS
                or sample_name_has_auxiliary_short_reads(sample["name"])
            )
        ]

        if len(compatible_samples) == 0:
            if assembler in HYBRID_ASSEMBLERS:
                raise ValueError(
                    f"Hybrid assembler '{assembler}' requires at least one "
                    "hifi/ont sample with auxiliary_short_reads_1 and "
                    "auxiliary_short_reads_2."
                )

            sample_tech_summary = [
                f"{sample['name']}={sample['technology']}"
                for sample in config["samples"]
            ]

            raise ValueError(
                f"Assembler '{assembler}' has no compatible sample in this config.\n"
                f"  Compatible technologies for '{assembler}': {ASSEMBLER_COMPATIBILITY[assembler]}\n"
                f"  Sample technologies found: {sample_tech_summary}"
            )
            
    for sample in config["samples"]:
        compatible_assemblers = [
            assembler
            for assembler in config["assemblers"]
            if sample["technology"] in ASSEMBLER_COMPATIBILITY[assembler]
            and (
                assembler not in HYBRID_ASSEMBLERS
                or sample_name_has_auxiliary_short_reads(sample["name"])
            )
        ]
        if len(compatible_assemblers) == 0:
            technology_compatible_assemblers = [
                assembler
                for assembler in config["assemblers"]
                if sample["technology"] in ASSEMBLER_COMPATIBILITY[assembler]
            ]
            hybrid_technology_compatible_assemblers = [
                assembler
                for assembler in technology_compatible_assemblers
                if assembler in HYBRID_ASSEMBLERS
            ]
            if (
                len(technology_compatible_assemblers) > 0
                and len(technology_compatible_assemblers) == len(hybrid_technology_compatible_assemblers)
                and not sample_name_has_auxiliary_short_reads(sample["name"])
            ):
                continue

            raise ValueError(
                f"Sample '{sample['name']}' with technology '{sample['technology']}' "
                "has no compatible assembler in config['assemblers']."
            )

def get_compatible_sample_assembler_pairs(require_long_reads=False, require_short_reads=False, require_auxiliary_short_reads=False, allowed_assemblers=None):
    pairs = []
    for sample in config["samples"]:
        sample_name = sample["name"]
        technology = sample["technology"]
        if require_long_reads and not sample_name_has_long_reads(sample_name):
            continue
        if require_short_reads and not sample_name_has_short_reads(sample_name):
            continue
        if require_auxiliary_short_reads and not sample_name_has_auxiliary_short_reads(sample_name):
            continue
        for assembler in config["assemblers"]:
            if allowed_assemblers is not None and assembler not in allowed_assemblers:
                continue
            if assembler in HYBRID_ASSEMBLERS and not sample_name_has_auxiliary_short_reads(sample_name):
                continue
            if technology in ASSEMBLER_COMPATIBILITY[assembler]:
                pairs.append({"sample": sample_name, "assembler": assembler})
    return pairs

def compatible_expand(pattern, require_long_reads=False, require_short_reads=False, require_auxiliary_short_reads=False, allowed_assemblers=None):
    pairs = get_compatible_sample_assembler_pairs(
        require_long_reads,
        require_short_reads,
        require_auxiliary_short_reads,
        allowed_assemblers,
    )
    return expand(
        pattern,
        zip,
        sample=[p["sample"] for p in pairs],
        assembler=[p["assembler"] for p in pairs],
    )

def compatible_reference_expand(pattern, require_long_reads=False, require_short_reads=False, require_auxiliary_short_reads=False, allowed_assemblers=None):
    expanded = []

    for reference in get_reference_names():
        expanded += compatible_expand(
            pattern.replace("{reference}", reference),
            require_long_reads=require_long_reads,
            require_short_reads=require_short_reads,
            require_auxiliary_short_reads=require_auxiliary_short_reads,
            allowed_assemblers=allowed_assemblers,
        )

    return expanded

def compatible_fraction_expand(pattern, require_long_reads=False, require_short_reads=False, require_auxiliary_short_reads=False, allowed_assemblers=None):
    expanded = []
    for fraction in get_fractions():
        expanded += compatible_expand(
            pattern.replace("{fraction}", fraction),
            require_long_reads=require_long_reads,
            require_short_reads=require_short_reads,
            require_auxiliary_short_reads=require_auxiliary_short_reads,
            allowed_assemblers=allowed_assemblers,
        )
    return expanded

def compatible_binner_expand(pattern, require_long_reads=False, require_short_reads=False, require_auxiliary_short_reads=False, allowed_assemblers=None):
    expanded = []
    for binner in get_configured_binners():
        expanded += compatible_expand(
            pattern.replace("{binner}", binner),
            require_long_reads=require_long_reads,
            require_short_reads=require_short_reads,
            require_auxiliary_short_reads=require_auxiliary_short_reads,
            allowed_assemblers=allowed_assemblers,
        )
    return expanded

def compatible_short_read_assembler_expand(pattern):
    return compatible_expand(
        pattern,
        require_short_reads=True,
        allowed_assemblers=SHORT_READ_ASSEMBLERS,
    )

def compatible_short_read_mapping_expand(pattern):
    expanded = []
    if config["short_read_mapping_evaluation"]:
        expanded += compatible_expand(pattern, require_short_reads=True)
    if is_binning_enabled() and short_read_binning_enabled():
        expanded += compatible_short_read_assembler_expand(pattern)
    return list(dict.fromkeys(expanded))

def compatible_auxiliary_short_read_mapping_expand(pattern):
    if is_binning_enabled() and short_read_cobinning_enabled():
        return compatible_expand(
            pattern,
            require_long_reads=True,
            require_auxiliary_short_reads=True,
        )
    return []

def get_binning_triples(include_short_read_binning=True):
    triples = []

    def add_binning_outputs(binning_names, require_long_reads=False, require_short_reads=False, require_auxiliary_short_reads=False, allowed_assemblers=None):
        pairs = get_compatible_sample_assembler_pairs(
            require_long_reads,
            require_short_reads,
            require_auxiliary_short_reads,
            allowed_assemblers,
        )
        for pair in pairs:
            for binning_name in binning_names:
                triples.append({
                    "sample": pair["sample"],
                    "assembler": pair["assembler"],
                    "binning": binning_name,
                })

    if is_binning_enabled() and long_read_binning_enabled():
        add_binning_outputs(
            expand("{binner}_bins_reads_alignement", binner=get_configured_binners()),
            require_long_reads=True,
        )
    if (
        include_short_read_binning
        and is_binning_enabled()
        and short_read_binning_enabled()
    ):
        add_binning_outputs(
            expand("{binner}_bins_short_reads_alignement", binner=get_configured_binners()),
            require_short_reads=True,
            allowed_assemblers=SHORT_READ_ASSEMBLERS,
        )
    if is_binning_enabled() and short_read_cobinning_enabled():
        add_binning_outputs(
            expand("{binner}_bins_cobinning_alignement", binner=get_configured_binners()),
            require_long_reads=True,
            require_auxiliary_short_reads=True,
        )
    if is_binning_enabled() and additional_reads_cobinning_enabled():
        add_binning_outputs(
            expand("{binner}_bins_additional_reads_cobinning_alignement", binner=get_configured_binners()),
            require_long_reads=True,
        )

    return triples

def compatible_binning_expand(pattern, include_short_read_binning=True):
    triples = get_binning_triples(include_short_read_binning)
    return expand(
        pattern,
        zip,
        sample=[t["sample"] for t in triples],
        assembler=[t["assembler"] for t in triples],
        binning=[t["binning"] for t in triples],
    )

def compatible_binning_target_expand(pattern):
    expanded = []
    for target_bin in config["kraken2_target_bins"]:
        for output in compatible_binning_expand(pattern.replace("{target_bin}", str(target_bin))):
            expanded.append(output)
    return expanded

validate_sample_technology_config()
validate_binning_config()
validate_reference_config()
validate_fraction_evaluation_tools()
validate_cleanup_config()

def get_long_read_fraction_path(sample, assembler, fraction):
    return f"outputs/{sample}/{assembler}/{fraction}_reads{READ_FRACTION_SUFFIX}"

def get_fastqc_fraction_read_path(sample, assembler, fraction, mate):
    return f"outputs/{sample}/{assembler}/fastqc/{fraction}/{mate}{READ_FRACTION_SUFFIX}"

# Return the path to the reads of a fraction of an assembly 
def get_read_path(wildcards) : 
    if(wildcards.fraction == "full") : 
        return get_long_read_path(wildcards)
    return get_long_read_fraction_path(wildcards.sample, wildcards.assembler, wildcards.fraction)

# Return the path to the reads of all fractions of an assembly 
def get_all_read_path(wildcards) :
    out = []
    for f in get_fractions() :
        wildcards.fraction = f
        out.append(get_read_path(wildcards))
    return out

def get_reference_names() : 
    return [os.path.splitext(os.path.basename(r))[0] for r in config["reference_genomes"]]

def get_reference(reference_name) : 
    for ref in config["reference_genomes"] : 
        if reference_name in ref : 
            return ref
    return None

# It determines the correct inputs according to the choice of fractions for the FastQC. 
def get_fastqc_R1(wildcards):
    if wildcards.fraction == "full":
        return get_short_read("short_reads_1", wildcards)
    return get_fastqc_fraction_read_path(wildcards.sample, wildcards.assembler, wildcards.fraction, "R1")

def get_fastqc_R2(wildcards):
    if wildcards.fraction == "full":
        return get_short_read("short_reads_2", wildcards)
    return get_fastqc_fraction_read_path(wildcards.sample, wildcards.assembler, wildcards.fraction, "R2")

##### Additional rules #####  
include : "rules/assembly.smk"
include : "rules/mapping.smk"
include : "rules/binning.smk"
include : "rules/bin_quality_analysis.smk"
include : "rules/read_quality_analysis.smk"
include : "rules/contig_quality_analysis.smk"

##### Improvements #####
"""
replace minimap2 by mapquick for hifi long reads mapping ?
replace kraken2 by sourmash for taxonomic assignation ?
"""

rule all :
    input :
        compatible_expand(f"outputs/{{sample}}/{{assembler}}/{ASSEMBLY_FILENAME}"),

        # Read quality analysis (FastQC for short reads, NanoPlot for long reads, kraken2, kat)
        compatible_fraction_expand("outputs/{sample}/{assembler}/fastqc/{fraction}/R1_fastqc.html", require_short_reads=True)
            if(fastqc_enabled()) else [],

        compatible_fraction_expand("outputs/{sample}/{assembler}/fastqc/{fraction}/R2_fastqc.html", require_short_reads=True)
            if(fastqc_enabled()) else [],

        compatible_fraction_expand("outputs/{sample}/{assembler}/nanoplot/{fraction}/NanoPlot-report.html", require_long_reads=True)
            if(nanoplot_enabled()) else [],
        compatible_fraction_expand("outputs/{sample}/{assembler}/kraken2/{fraction}/krona.html", require_long_reads=True)
            if(config["kraken2"] == True) else [],
        compatible_fraction_expand("outputs/{sample}/{assembler}/kat/{fraction}-stats.tsv", require_long_reads=True)
            if(config["kat"] == True) else [],
        compatible_expand("outputs/{sample}/{assembler}/kat/kat-plot.pdf", require_long_reads=True)
            if(config["kat"] == True and "mapped" in get_fractions() and "unmapped" in get_fractions()) else [],

        # Contig quality analysis (read mapping, short read mapping, metaquast, reference mapping)
        compatible_expand("outputs/{sample}/{assembler}/reads_on_contigs_mapping_evaluation/report.txt", require_long_reads=True)
            if(config["read_mapping_evaluation"] == True) else [],
        compatible_expand("outputs/{sample}/{assembler}/metaquast/report.txt")
            if(config["metaquast"] == True and ("abundance_information" in config)) else [],
        compatible_expand("outputs/{sample}/{assembler}/metaquast/results/summary/TSV/")
            if(config["metaquast"] == True) else [],
        expand("outputs/{sample}/long_reads_on_reference.{reference}.bam", sample=get_samples_with_long_reads(), reference=get_reference_names())
            if(config["reference_mapping_evaluation"] == True) else [],
        expand("outputs/{sample}/short_reads_on_reference.{reference}.bam", sample=get_samples_with_short_reads(), reference=get_reference_names())
            if(config["reference_mapping_evaluation"] == True) else [],
        compatible_reference_expand("outputs/{sample}/{assembler}/contigs_on_reference.{reference}.bam")
            if(config.get("contigs_on_reference_mapping", False) == True) else [],
        compatible_short_read_mapping_expand("outputs/{sample}/{assembler}/short_reads_on_contigs.bam")
            if(
                config["short_read_mapping_evaluation"] == True
                or (
                    is_binning_enabled()
                    and short_read_binning_enabled()
                )
            ) else [],
        compatible_auxiliary_short_read_mapping_expand("outputs/{sample}/{assembler}/auxiliary_short_reads_on_contigs.bam")
            if(is_binning_enabled() and short_read_cobinning_enabled()) else [],
        compatible_expand("outputs/{sample}/{assembler}/short_reads_on_contigs_mapping_evaluation/report.txt", require_short_reads=True)
            if(config["short_read_mapping_evaluation"] == True) else [],

        # Bins quality analysis (checkm, separate read and contig quality analysis by bin quality)
        compatible_binning_expand("outputs/{sample}/{assembler}/{binning}/checkm/checkm_report.txt")
            if(config["checkm"] == True) else [],
        compatible_binning_expand("outputs/{sample}/{assembler}/{binning}/checkm/checkm-plot.pdf")
            if(config["checkm"] == True) else [],
        compatible_binning_expand("outputs/{sample}/{assembler}/{binning}/gtdbtk/results/gtdbtk.bac120.summary.tsv")
            if(config["gtdbtk"] == True) else [],
        compatible_binning_target_expand("outputs/{sample}/{assembler}/{binning}/kraken2/bin.{target_bin}/krona.html")
            if(config["kraken2_on_bins"] == True) else [],
        compatible_binning_expand("outputs/{sample}/{assembler}/{binning}/read_contig_mapping_plot.pdf", include_short_read_binning=False)
            if(config["checkm"] == True and config["read_mapping_evaluation"] == True and long_read_mapping_plot_enabled()) else [],
        compatible_binning_expand("outputs/{sample}/{assembler}/{binning}/read_contig_mapping.txt", include_short_read_binning=False)
            if(config["checkm"] == True and config["read_mapping_evaluation"] == True and long_read_mapping_plot_enabled()) else [],
        compatible_binner_expand("outputs/{sample}/{assembler}/{binner}_bins_short_reads_alignement/read_contig_mapping_plot.pdf", require_short_reads=True, allowed_assemblers=SHORT_READ_ASSEMBLERS)
            if(config["checkm"] == True and is_binning_enabled() and short_read_binning_enabled()) else [],
        compatible_binner_expand("outputs/{sample}/{assembler}/{binner}_bins_short_reads_alignement/read_contig_mapping.txt", require_short_reads=True, allowed_assemblers=SHORT_READ_ASSEMBLERS)
            if(config["checkm"] == True and is_binning_enabled() and short_read_binning_enabled()) else [],
