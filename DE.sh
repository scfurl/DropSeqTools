#!/bin/bash

progname=DigitalExpression

USAGE=$(cat << EOF
USAGE: $0 [-m <xmx> -i <in> -o <out> -n <num_bc> -p <pa>] 
       -m <xmx> (default $xmx)
       -i <in> input.bam file (Required)
       -o <out>  output directory (Required)
       -p <pa> program args supplied as a comma separated string
    e.g. ARGUMENT1=VALUE1,ARGUMENT2=VALUE2
       -n <num_core_bc> number core barcodes (Number of cells that you think are in the library.)
       -j <jar_deploy_dir> java deploy directory (absolute path required if running on a cluster)
       -e <echo_prefix> use this flag to signify to echo final command instead of running

To get help for the program rather than the script:
   $progname -- -h
EOF
)

function error_exit
{
    echo "$1" 1>&2
    exit 1
}

function usage () {
    echo "$USAGE" >&2
}

function check_set() {
    value=$1
    name=$2
    flag=$3
    if [ -z "$value" ]
    then error_exit "$name has not been specified.  $flag flag is required"
    fi
}

set -e

while getopts ":m:i:o:n:ep:j:" options; do
  case $options in
    m ) xmx=$OPTARG;;
    i ) in=$OPTARG;;
    o ) out=$OPTARG;;
    n ) num_bc=$OPTARG;;
    e ) echo_prefix="echo";;
    p ) pa=$OPTARG;;
    h ) usage
          exit 1;;
    \? ) usage
         exit 1;;
    * ) usage
          exit 1;;

  esac
done
shift $(($OPTIND - 1))

check_set "$in" "Input BAM"  "-i"
check_set "$out" "Output Directory" "-o"
check_set "$num_core_bc" "Number barcodes" "-n"

if [ -z "$xmx" ]
then xmx=4g
fi

if [ -z "jar_deploy_dir" ]
then jar_deploy_dir=`dirname $0`/jar
fi

command="$echo_prefix java -Xmx${xmx} -jar $jar_deploy_dir/dropseq.jar $progname INPUT=$in O=$out/DigExpr_Matrix.gz SUMMARY=$out/DigExpr_SUMMARY.txt  NUM_CORE_BARCODES=$num_core_bc"

$command


#Allowable pa - not implemented yet
# SUMMARY=File
# OUTPUT_READS_INSTEAD=Boolean
# OUTPUT=File
# NUM_CORE_BARCODES=Integer
# MIN_SUM_EXPRESSION=Integer
# INPUT=File
# CELL_BARCODE_TAG=String
# MOLECULAR_BARCODE_TAG=String
# GENE_EXON_TAG=String
# STRAND_TAG=String
# EDIT_DISTANCE=Integer
# READ_MQ=Integer
# MIN_BC_READ_THRESHOLD=Integer
# MIN_NUM_READS_PER_CELL=Integer
# MIN_NUM_GENES_PER_CELL=Integer
# MIN_NUM_TRANSCRIPTS_PER_CELL=Integer
# NUM_CORE_BARCODES=Integer
# CELL_BC_FILE=File
# USE_STRAND_INFO=Boolean
# RARE_UMI_FILTER_THRESHOLD=Double

