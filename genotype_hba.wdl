version 1.0

workflow RunCtyper {
    input {
        File input_bam
        File input_bam_index
	File reference
        File KmerFile
	File KmerIndex
	File background
	File inputVcfsGz
        String output_name
	String output_vcf
    }

    call GenotypeSample {
        input:
            input_bam = input_bam,
            input_bam_index = input_bam_index,
            KmerFile = KmerFile,
            KmerIndex = KmerIndex
	    background = background
            output_name = output_name
    }

    output {
        File output_name = GenotypeSample.output_genotype,
	File output_vcf  = GenotypeSample.output_vcf
    }

    meta {
        description: "Run ctyper on a bam/cram file"
        author: "Chaisson lab"
    }
}

task RunCtyperTask {
    input {
        File input_bam
        File input_bam_index
	File reference
        File KmerFile
	File KmerIndex
	File background
	File inputVcfsGz
        String output_name
	String output_vcf
	Int nProc
    }

    command <<<
        set -euo pipefail
        ctyper -T ~{reference} -m ~{KmerFile} -i ~{input_bam} -o ~{output_name} -N ~{nProc} -b ~{background}
	tar zxvf ~{inputVcfsGz}
	ResultToVcf.sh ~{output_name} vcfs > ~{output_vcf}
    >>>

    output {
        File output_genotype = "~{output_name}"
        File output_vcf = "~{output_vcf}"	
    }

    runtime {
        docker: "mchaisso/ctyper:0.2"
	cpu: 1
	memory: "24G"
    }
}
