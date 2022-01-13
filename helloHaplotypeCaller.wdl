## How to write your first WDL script running GATK haploytypecaller
##
## Reference: https://sites.google.com/a/broadinstitute.org/legacy-gatk-documentation/tutorials/7158-1-howto-Write-your-first-WDL-script-running-GATK-HaplotypeCaller
##
## let’s first look at how we would enter this command into the terminal
## https://www.broadinstitute.org/gatk/gatkdocs/org_broadinstitute_gatk_tools_walkers_haplotypecaller_HaplotypeCaller.php
## Running the tool in normal mode: 
## java -jar GenomeAnalysisTK.jar \ -T HaplotypeCaller \ -R reference.fasta \ -I input.bam \ -o output.vcf \ 
## Need to provide the following inputs:
## `reference.fasta`, `input.bam`, `output.vcf` and `GenomeAnalysisTK.jar`.
## Instead of making them absolute references (Hardcoding them), we will put each into a variable name.
## 3 of the inputs are files, we we will declare the variables as `File RefFasta`, `File inputBAM`, and `File GATK`
## The final input, `output.vcf`, is a filename to which the output will be written once the command is run. 
## So we will provide a `String sampleName` with which to name the output file
## Those were the core inputs we needed for the task. but GATK will look for supporting files.
## To tell Cromwell to put the supporting files into the working directory, we need to declare variables for each of them.
## Now we can write the command part of the task.
## Need to plug in the declared variables into the correct places within the command component of the task.
## The command has an -o option, but for the execution engine (Cromwell) to recognize the outputs, we need to specify them in the outputs{} component.
##
## Next steps:
## Validate the WDL Script before running: java -jar wdltool.jar validate helloHaplotypeCaller.wdl
## Generate the input file: java -jar wdltool.jar inputs helloHaplotypeCaller.wdl > helloHaplotypeCaller_inputs.json 
## Open the helloHaplotypeCaller_inputs.json file and replace "Type" with the absolute path to the files and tool locations
## Run the command: java -jar cromwell.jar run helloHaplotypeCaller.wdl helloHaplotypeCaller_inputs.json 


# WORKFLOW DEFINITION 

workflow helloHaplotypeCaller {
  
  call haplotypeCaller {
  
  }
}

# TASK DEFINITION

task haplotypeCaller {

   File RefFasta
   File inputBAM
   File GATK
   String sampleName
   File RefIndex
   File RefDict
   File bamIndex
   
   command {
   java -ja ${GATK} \
   -T HaplotypeCaller \
   -R ${RefFasta} \
   -I ${inputBam} \
   -O ${sampleName}.raw.indels.snps.vcf
   }
   
   outputs{
   File rawVCF = "${sampleName}.raw.indels.snps.vcf" 
   }
}

