#!/usr/bin/env nextflow

/*
 * Workflow for creating base composition table from FASTA format sequences
 */

nextflow.enable.dsl=2

// Input
params.input = "$baseDir/seq/*"
file = Channel.fromPath(params.input)

// Calculating base composition for each sequence
process baseComp {
	
	input:
		path FASTAin
	
	output:
		path '*.tsv'
	
	script:
	$/
	#!python
	
	from Bio import SeqIO
	
	fin = open("${FASTAin}")
	seq_records = SeqIO.parse(fin, "fasta")
	
	fout = open("${FASTAin}".split(".")[0]+"_base_comp.tsv", "w+")
	
	for record in seq_records:
		header, seq = record.id, str(record.seq)
		temp = "\t".join([header, str(seq.count("A")), str(seq.count("T")), str(seq.count("G")), \
		str(seq.count("C")), str(((seq.count("G")+seq.count("C"))/len(seq))*100),"\n"])
		fout.write(temp)
	/$
	}

// Adding header and creating final output file
process finalOutput{

	input:
		path 'temp_base_comp.tsv'
	
	output:
		path 'base_comp.tsv'
	
	publishDir 'output', mode: 'copy', overwrite: true
	
	script:
	"""
	sed "1i Accession.ID\tCount_A\tCount_T\tCount_G\tCount_C\tGC_percent\n" temp_base_comp.tsv > base_comp.tsv
	"""
	}

// Running workflow
workflow {
	baseComp(file) | collectFile(name: 'temp_base_comp.tsv') | finalOutput
	}

// Usage: $ nextflow run base_composition.nf

