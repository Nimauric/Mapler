
assembly="$1"
run_type="$2"
run="$3"
output="$4"
Ncpu=$(nproc)

case $sequencer in
    "PacBio RS II")
        sequencer_arguments="map-pb"
        ;;
    "MinION")
        sequencer_arguments="map-ont"
        ;;
    "pacbio-hifi")
        sequencer_arguments="map-hifi"
        ;;
    *)
        echo "Unsupported or unrecognized read sequencer !"
        echo $metadata
        exit 1
        ;;
esac

minimap2 -t "$Ncpu" -cx "$sequencer_arguments" "$assembly" "$run" -o "$output"
