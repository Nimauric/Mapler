#!/usr/bin/env bash
set -euo pipefail

#SBATCH --time=3-00:00:00
#SBATCH --mem=10G
#SBATCH --cpus-per-task=1

opera_path="$1"
long_reads="$2"
short_reads_1="$3"
short_reads_2="$4"
short_read_assembly="$5"
tmp_directory="$6"
output="$7"
cleanup="${8:-yes}"
threads="${9:-1}"

install_missing_perl_modules() {
    if [ -z "${CONDA_PREFIX:-}" ]; then
        echo "CONDA_PREFIX is not set. OPERA-MS wrapper must run inside its Snakemake conda environment." >&2
        exit 1
    fi

    TOOLS_DIR="$opera_path/tools_opera_ms"
    mkdir -p "$TOOLS_DIR"

    if [ ! -x "$TOOLS_DIR/perl" ]; then
        ln -sf /usr/bin/perl "$TOOLS_DIR/perl"
    fi

    if ! command -v samtools >/dev/null 2>&1; then
        echo "samtools is missing from the OPERA-MS conda environment." >&2
        exit 1
    fi

    ln -sf "$(command -v samtools)" "$TOOLS_DIR/samtools"

    export PERL5LIB="${CONDA_PREFIX}/lib/perl5${PERL5LIB:+:${PERL5LIB}}"

    if ! perl -MSwitch -e 1 2>/dev/null; then
        echo "Perl module Switch is missing. Installing it with cpanm inside the OPERA-MS conda environment..."
        cpanm --notest --local-lib-contained "$CONDA_PREFIX" Switch
    fi

    export PERL5LIB="${CONDA_PREFIX}/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
}

install_missing_perl_modules

if [ ! -d "$opera_path" ]; then
   echo "not here"
   mkdir -p "$opera_path"
   cd "$opera_path"
   cd ..
   git clone https://github.com/CSB5/OPERA-MS.git
   cd OPERA-MS
   make
   perl OPERA-MS.pl check-dependency
fi

CONTIG_ARG=""
if [ -n "$short_read_assembly" ] && [ "$short_read_assembly" != "none" ]; then
    CONTIG_ARG="--contig-file $short_read_assembly"
fi

perl "$opera_path"/OPERA-MS.pl \
    --num-processors "$threads" \
    --no-ref-clustering \
    $CONTIG_ARG \
    --short-read1 "$short_reads_1" \
    --short-read2 "$short_reads_2" \
    --long-read "$long_reads" \
    --out-dir "$tmp_directory"

./sources/assembly/finalize_assembly_output.sh "$tmp_directory"/OPERA-MS_results/final_assembly.fasta "$output"

if [ "$cleanup" != "no" ] && [ -s "$output" ]; then
    rm -rf "$tmp_directory"
fi
