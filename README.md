![logo.png](https://github.com/AndolfoG/HRP/blob/main/LOGO.png)


# Introduction
Welcome to the full-length **H**omology-based **R**-gene **P**rediction (**HRP**) project.
This project aims to develop an informatics pipeline for genome-wide resistance (R)-genes (also known as NB-LRR genes) prediction and classification.
We sincerely wish our method can significantly benefit your R-gene study, and enjoy high-performances.


## Table of Contents to use HRP
- [Essential software](#software)
###### B. Example commands
###### C. IPS2fpGs.sh script



## <a name="software"></a>Essential software
Make sure below programs are correctly installed according to their installation manual.

- InterProScan, a HMM based domain identification package (Jones *et al*., 2014)

- MEME Suite, command line programs to discover novel and ungapped motifs (Bailey *et al*., 2006)

- BEDTools utilities, tools for a wide-range of genomics analysis tasks (Quinlan and Hall, 2010)

- genBlastG, algorithm that uses the HSPs reported by BLAST to define high-quality gene models (She *et al*., 2011)

- AGAT Suite, tools to handle gene annotations in any GTF/GFF format (Dainat, 2020)

- IGV, interactive tool for the visual exploration of genomic data (Thorvaldsdóttir *et al*., 2013)

	
## B. Example commands
Please follow the example commands for execution instruction of HRP method

###### 1. Data preparation
Download the genome sequence and the protein sequences (encoded by gene set) of interest, for example related to the sugar beet genome assembly RefBeet-1.2
			
			
	wget -O RefBeet-1-2_proteins.fasta https://bvseq.boku.ac.at/Genome/Download/RefBeet-1.2/BeetSet-2.genes.1408.pep
	wget -O RefBeet-1-2_genome.fasta https://bvseq.boku.ac.at/Genome/Download/RefBeet-1.2/RefBeet-1.2.fna.gz


###### 2. Identification of NB domain using a protein domain search (PDS)
An InterProScan example command using the data from 1
			
			
	interproscan -f TSV -app Pfam -i RefBeet-1-2_proteins.fasta -b RefBeet-1-2_proteins	


###### 3. Decomposition into motifs of NB Pfam domains
###### 3.1. BED file formatting of NB Pfam domains using the data from 2


	grep NB-ARC RefBeet-1-2_proteins.tsv | cut -f1,7,8 > NB.bed


###### 3.2. Extraction of NB Pfam domain sequences using the data from 1 and 3.1
			
		
	bedtools getfasta -fi RefBeet-1-2_proteins.fasta -bed NB.bed -fo NB_Pfam_Domain_Sequences.fasta


###### 3.3. A MEME example command using data from 3.2
			
			
	meme NB_Pfam_Domain_Sequences.fasta -protein -o meme_out -protein -mod zoops -motifs 19 -minw 4 -maxw 7 -objfun classic -markov_order 0


###### 4. Identification of additional NB Pfam domain using NB motif search
A MAST example command using data from 1 and 3.3
			
			
	mast -o mast_out meme_out.txt RefBeet-1-2_proteins.fasta

	
###### 5. Identification of LRR domain using a protein domain search (PDS)
An InterProScan example command using sequences from 1, filtered on the base of gene-ID list from 2 and 4
			
			
	interproscan -f TSV -app SUPERFAMILY -i RefBeet-1-2_proteins_subset.fasta -b RefBeet-1-2_proteins	
	

###### 6. Classification in full-length or partial NB-LRR genes
IPS2fpGs.sh command example using data from 2 and 5
			
			
	IPS2FPGs RefBeet-1-2_proteins.tsv -o output_file.tsv


###### 7. de novo prediction of NB-LRR genes
A genBlastG example command using data from 6
			
			
	genblastG -q Full-length_NB-LRRs.fasta -t RefBeet-1-2_genome.fasta -gff -cdna -pro -o genblastG-output


###### 8. Selection of non-redundant NB-LRR genes
###### 8.1. Filtering of NB-LRR gene models longer than 20 kbp using the data from 7

	
	agat_sp_filter_gene_by_length.pl --gff genblastG-output.gff --size 20000 --test "<" -o genblastG-output_FbL.gff
			

###### 8.2. Identification of overlapped gene models using the data from 8.1


	grep transcript genblastG-output_FbL.gff | gff2bed | sortBed | clusterBed -s | cut -f4,11  > genblastG-output_FbL_clusters


###### 8.3. Estimation of putative NB-LRR protein sequences using the data from 7
	
	
	awk 'BEGIN{FS="[> ]"} /^>/{val=$2;next}  {print val,length($0);val=""} END{if(val!=""){print val}}' genblastG-output.pro | tr ' ' \\t > genblastG-output_FbL_length


###### 8.4.  List of non-redundant NB-LRR gene models using the data from 8.2 and 8.3
	
	
	join -t $'\t' -1 1 -2 1 -o 1.1,1.2,2.2 <( sort -bk1 genblastG-output_FbL_clusters) <(sort -bk1 genblastG-output_FbL_length) | sort -bk2,2 -bk3,3 -nr | sort -uk1,1 | cut -f1 > R-gene_ID_list


###### 9. Annotation of NB-LRR proteins
An InterProScan example command using the data extracted from 6 on the base of 8.4
	
	
	interproscan -f TSV,GFF3 -i NB-LRR_gene_candidates.fasta -b RefBeet-1-2_B-LRR_gene_candidates


###### 10. Comparison and visual inspection of NB-LRR genes predicted by HRP using data from 8.1 and 9.1
The candidate R loci identified from HRP could be exported in GFF format and imported into the IGV genome browser for comparison and visual inspection


## C. Bash script
IPS2fpGs.sh, The aim of this script is to feed it InterProScan results and return the full-length and partial NB-LRR genes classification on the base of R protein domains. Users can download and use the IPS2FPGs freely for research purpose only with acknowledgment to us and quoting HRP paper as reference

	
