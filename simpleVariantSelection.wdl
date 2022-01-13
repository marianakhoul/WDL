## How to write a simple multistep workflow
##
## Reference: https://sites.google.com/a/broadinstitute.org/legacy-gatk-documentation/tutorials/7221-2-howto-Write-a-simple-multistep-workflow?authuser=0
## 
## A branched multistep workflow building off of the helloHaplotypeCaller.wdl script
## Output of the helloHaplotypeCaller.wdl script will be used in 2 calls for SNP and Indels.
## Inside the workflow we will have 3 task calls: the haplotypeCaller and a select task that has 2 alias names depending if we want SNP or Indel.
## haplotypeCaller is the very start of our workflow and the remaining tasks will have their inputs generated from this task (previous step of the workflow).
## To specify an input, follow the format: input: inputname=taskname.outputname 
## To tell the select task to take the rawVCF output from haplotypeCaller, we write:
## input: rawVCF=haplotypecaller.rawVCF
## The task select has an input called type which doesn't accept input from earlier steps.
## We can specify type as INDEL or SNP by passing a string
## Unlike the previous haplotypeCaller task, we will be declarin global variables inside the workflow declaration
## With global variables, we only declare the variables once and pass them to all our tasks in one place
## The left side of the declaration in the input: is the same spelling as the global declaration, right side is any spelling you want.
## Although you write the global variables in the workflow, you need to redeclare them in the tasks.
##

# WORKFLOW DEFINITION 

workflow SimpleVariantSelection {
  
   File RefFasta
   File inputBAM
   File GATK
   String sampleName
   File RefIndex
   File RefDict
   File bamIndex
  
  
  call haplotypeCaller {
    input:
    sampleName=name,
    GATK=gatk,
    RefIndex=refIndex,
    RefDict=refDict,
    RefFasta=refFasta
  }
  
  call select as selectSNPs {
    input:
    type="SNP",
    sampleName=name,
    GATK=gatk,
    RefIndex=refIndex,
    RefDict=refDict,
    RefFasta=refFasta,
    rawVCF=haplotypecaller.rawVCF
  }
  
  call select as selectIndels {
    input:
    type="INDEL",
    sampleName=name,
    GATK=gatk,
    RefIndex=refIndex,
    RefDict=refDict,
    RefFasta=refFasta,
    rawVCF=haplotypecaller.rawVCF
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

task select {
  
   File RefFasta
   File inputBAM
   File GATK
   String sampleName
   File RefIndex
   File RefDict
   File bamIndex
    
   command {
      java -jar ${GATK} \
      -T SelectVariants \
      -R ${RefFasta} \
      -V ${rawVCF} \
      -selectType ${type} \
      -O ${sampleName}_raw.${type}.vcf
   }
   outputs {
      File rawSubset = "${sampleName}_raw.${type}.vcf" 
  }
}
