#!/bin/bash
#SBATCH --job-name=bt2idx
#SBATCH --partition=amd
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=2048
#SBATCH --time=60   # Time limit hrs:min:sec
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

# download refseq
gb="U30316.1"
curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&rettype=fasta&id=${gb}" > ${gb}.fa


# input/output variables
FA=${gb}.fa # this is your ref sequence 
WD="results/bowtie2" # this is where your results will be
mkdir -p results/bowtie2
bt2base="${WD}/$(basename ${FA%.*})"    #${ref%.*}

# create index
conda activate bowtie2
if [ ! -f "${bt2base}.rev.1.bt2" ]
then	
bowtie2-build --threads "${cpus}" "${FA}" ${bt2base}
fi
conda deactivate
