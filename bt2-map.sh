#!/bin/bash
#SBATCH --job-name=bt2map
#SBATCH --partition=amd
#SBATCH --array=1-2 #3-15,17,18,20-27,30-43,45-54
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=4096
#SBATCH --time=300   # Time limit hrs:min:sec
#SBATCH --output=slurm_%j.log   # Standard output and error log

# exit when any command fails
set -e
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

eval "$(conda shell.bash hook)"

# cd to YOUR project directory, modify this line
cd /gpfs/space/home/taavi74/Projects/mapto

# slurm variables
cpus="$SLURM_CPUS_PER_TASK"
ID=EV$(printf %02d $SLURM_ARRAY_TASK_ID) # OUR sample id


# input/output variables
gb="U30316.1"
FA=${gb}.fa # this is your ref sequence 
WD="results/bowtie2" # this is where your results will be

bt2base="${WD}/$(basename ${FA%.*})"    #${ref%.*}

conda activate bowtie2

fq1=$(ls -m /gpfs/space/projects/preterm/saja-aastased/results/trimmed_reads/${ID}*1.fastq.gz)
fq2=$(ls -m /gpfs/space/projects/preterm/saja-aastased/results/trimmed_reads/${ID}*2.fastq.gz)
input="-1 $(echo $fq1 | sed 's/ //g') -2 $(echo $fq2 | sed 's/ //g')"

# map library to reference
if [ ! -f "${bt2base}-${ID}.bam" ]
then
bowtie2 \
   -p "${cpus}" \
   -x "${bt2base}" \
   $input \
   2> "${bt2base}-${ID}.bowtie2.log" | \
   samtools view -@ "${cpus}" -bS | \
   samtools sort -@ "${cpus}" -o "${bt2base}-${ID}.bam"
samtools index "${bt2base}-${ID}.bam"
fi
conda deactivate

conda activate bbmap
bam="${bt2base}-${ID}.bam"
covstats="${bt2base}-${ID}.covstats.txt"
rpkm="${bt2base}-${ID}.rpkm.txt"
if [[ ! -f "$covstats" ]] | [[ ! -e "$covstats" ]]
then
echo "Working on $bam"
pileup.sh in=$bam out=$covstats rpkm=$rpkm dupecoverage=false
fi
conda deactivate

