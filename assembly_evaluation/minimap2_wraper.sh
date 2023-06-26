
assembly="$1"
run_type="$2"
run="$3"
output_directory="$6"
output="$5"
Ncpu=$(nproc)

mkdrir -p "$output_directory"

case $run_type in
    "pacbio-clr")
        sequencer_arguments="map-pb"
        ;;
    "ont")
        sequencer_arguments="map-ont"
        ;;
    "pacbio-hifi")
        sequencer_arguments="map-hifi"
        ;;
    *)
        echo "Unsupported or unrecognized read sequencer !"
        echo "$run_type"
        exit 1
        ;;
esac

minimap2 -t "$Ncpu" -cx "$sequencer_arguments" "$assembly" "$run" -o "$output"

