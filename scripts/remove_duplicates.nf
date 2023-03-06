#!/usr/bin/env nextflow

/*
 * Workflow for removing duplicate sequences using seqkit
 */
 
nextflow.enable.dsl=2

params.file = "$baseDir/seq/*.fasta"
file = Channel.fromPath(params.file)

log.info """
         Removing duplicate sequences using seqkit
         -----------------------------------------
         Input        : ${params.file}
         Tool         : seqkit
         """
         .stripIndent()


process remove_duplicates {
	
	input:
		path seq_file
	
	script:
		"""
		seqkit rmdup ${seq_file} -s -o ${seq_file}.duprem
		"""
	}


workflow { 
	remove_duplicates(file)
	}

	
workflow.onComplete {

	if ( workflow.success ) {
		log.info "\n>> Duplicates removed SUCCESSFULLY after $workflow.duration"
		} 

	else {
		log.info "\n>> Duplicates removed with ERRORS after $workflow.duration"
		}
	}
	
// Usage: $ nextflow run remove_duplicates.nf
