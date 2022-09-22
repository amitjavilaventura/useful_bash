#!/bin/bash

set -e; set -u

# This script does
# - Takes the ELAND file used as input for proTRAC
# - Converts the ELAND file to BED
# - Converts the BED to BAM, so it can be used as input for featureCounts

# SET UP ==========================================================================================

# Set working directory
WORKDIR="path/to/workdir"
cd $WORKDIR

# Define singularity command 
module load module load singularity-3.8.3-gcc-11.2.0-rlxj6fi
sing_exec="singularity exec --bind $HOME path/to/sing/image"

# Define array of samples
SAMPLES_ARRAY=(musculus1 musculus2 caroli1 caroli2 pahari1 pahari2)
SAMPLE=${SAMPLES_ARRAY[$SLURM_ARRAY_TASK_ID]}

# Set output directory
OUTDIR="path/to/outdir"
mkdir -p $OUTDIR

# Set file names
MAPFILE="results/05_protrac/$SAMPLE/$SAMPLE.map.weighted"
BEDFILE="$OUTDIR/$SAMPLE.map.bed"
BAMFILE="$OUTDIR/$SAMPLE.map.bam"

# Set genome chrom size
GENOME="$HOME/bio/genomes/GRCm39/assembly/Mus_musculus.GRCm39.104.chrom.sizes"

# PROCESS DATA ====================================================================================

# Uncompress map file
if [ -f $MAPFILE.gz ]; then zcat $MAPFILE | sort -k1,1n -k2,2n > $MAPFILE.tmp; 
else cat $MAPFILE | sort -k1,1n -k2,2n > $MAPFILE.tmp;
fi

# MAP 2 BED -------------------------------------
# Uncompress map file with zcat
# Sort it for the 2 first fields
# Print the following fields chr ($1), start ($2 -1), end (start -1 +length($3), id (use sequence: $3)), score (use length($3)), strand ($7)
awk 'BEGIN{FS=OFS="\t"}{print $1, $2-1, $2-1+length($3), $3, length($3), $7}' $MAPFILE.tmp | sort -k1,1n -k2,2n > $BEDFILE

# BED 2 BAM -------------------------------------
# Use bedToBam from Bedtools
$sing_exec bedtools bedtobam -mapq 255 -i bedfile.bed -g $GENOME > $BAMFILE

# Remove temporary files ------------------------
rm $MAPFILE.tmp
