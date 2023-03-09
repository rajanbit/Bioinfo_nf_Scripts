#!/usr/bin/env nextflow

/*
 * Workflow for phylogenetic tree construction using
 * FASTA records
 */
 
nextflow.enable.dsl=2

// Inputs
params.file = "$baseDir/seq/*.fasta"
file = Channel.fromPath(params.file)
params.treemaker = "NA"

// Printing log 
log.info """
         Phylogenetic Tree Construction
         ------------------------------
         Input        : ${params.file}
         Output       : Tree/tree.*
         Tools        : MAFFT, RAxML/IQTREE' 
         """
         .stripIndent()

// Remove duplicate sequences
process remove_duplicates {
	input: 
		path fasta
	
	output:
		path '*.duprem'

	script:
		"""
		seqkit rmdup ${fasta} -s -o ${fasta}.duprem
		"""
	}

// Perform multiple sequence alignment
process sequence_alignment {
	input: 
		path 'seq.mfasta'
	
	output: 
		path 'seq.aln'
	
	script:
		"""
		mafft --auto seq.mfasta > seq.aln
		"""
	}

// Phylogenetic tree construction
process tree_construction {
	publishDir 'Tree', mode: 'copy', overwrite: true
	
	input:
		path 'seq.aln'
	
	output:
		path 'tree.*'
	
	script:
		if( params.treemaker == "NA")
			"""
			echo "TREEMAKER NOT SPECIFIED"
			"""
			
		else if( params.treemaker == "raxml-ng")
			"""
			raxml-ng --msa seq.aln --all --model GTR+G --prefix tree --threads 2 --seed 12345 -bs-tree 100
			"""
			
			
		else if( params.treemaker == "iqtree")
			"""
			iqtree -s seq.aln -T 2 -B 1000 --prefix tree
			"""
		else
			"""
			echo INVALID TREEMAKER
			"""
	}

// Running workflow
workflow {
	remove_duplicates(file) | collectFile(name: 'seq.mfasta') | sequence_alignment | tree_construction
	}

// Usage: nextflow run phylogenetic_tree.nf --treemaker <iqtree OR raxml>

