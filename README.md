# Map reads to reference sequence

## Set up conda environments

1. bowtie2

```bash
mamba create -n bowtie2 -c bioconda bowtie2 samtools
```

2. bbmap

```bash
mamba create -n bbmap -c bioconda bbmap
```


## Run workflow

```bash
bash mapto.sh
```


