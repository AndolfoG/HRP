![logo.png](https://github.com/AndolfoG/HRP/blob/main/LOGO.png)


# Introduction
Welcome to the full-length **H**omology-based **R**-gene **P**rediction (**HRP**) project.
This project aims to develop an informatics pipeline for genome-wide resistance (R)-genes (also known as NB-LRR genes) prediction and classification.
We sincerely wish our method can significantly benefit your R-gene study, and enjoy high-performances.


## Table of Contents to use HRP
###### A. Essential software
###### B. Example commands
###### C. IPS2fpGs.sh script



## A. Essential software
Make sure below programs are correctly installed according to their installation manual.
	
	- InterProScan, a HMM based domain identification package (Jones et al., 2014)

	- MEME Suite, command line programs to discover novel and ungapped motifs (Bailey et al., 2006)

	- BEDTools utilities, tools for a wide-range of genomics analysis tasks (Quinlan and Hall, 2010)

	- genBlastG, algorithm that uses the HSPs reported by BLAST to define high-quality gene models (She et al., 2011)

	- AGAT Suite, tools to handle gene annotations in any GTF/GFF format (Dainat, 2020)

	- IGV, interactive tool for the visual exploration of genomic data (Thorvaldsdóttir et al., 2013)

	
###### B. Example commands
Please follow the example commands for execution instruction of HRP method

	## 1. Data preparation

		Download the genome sequence and the protein sequences (encoded by gene set) of interest, for example related to the sugar beet genome assembly RefBeet-1.2:
			[wget -O RefBeet-1-2_proteins.fasta https://bvseq.boku.ac.at/Genome/Download/RefBeet-1.2/BeetSet-2.genes.1408.pep]
			[wget -O RefBeet-1-2_genome.fasta https://bvseq.boku.ac.at/Genome/Download/RefBeet-1.2/RefBeet-1.2.fna.gz]


	## 2. Identification of NB domain using a protein domain search (PDS)

		An InterProScan example command using the data from 1
			[interproscan -f TSV -app Pfam -i RefBeet-1-2_proteins.fasta -b RefBeet-1-2_proteins]	


	## 3. Decomposition into motifs of NB Pfam domains

