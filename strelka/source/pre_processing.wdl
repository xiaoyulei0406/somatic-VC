task mkdir {

	String dirName

	command {
		mkdir ${dirName}
	}

	output {
		File path = "${dirName}"
	}
}

 task mkdir_vs {

	String dirName1
	String dirName2

	command {
		mkdir ${dirName1 + "_vs_" + dirName2}
	}

	output {
		File path = "${dirName1}_vs_${dirName2}"
	}
}

task mkdir_sample {
	String dirName1
	String dirName2

	command {
		mkdir ${dirName1 + "/" + dirName2}
	}

	output {
		File path = "${dirName1}/${dirName2}"
	}
}

task mkdir_variant {
	String dirName1

	command {
		mkdir ${dirName1}
	}
}
task bwa_mem {

 	Array[File] sample_info
	String sample_name_flag
	String Ref_file
	String outdir
			
	command {
		/BioBin/bwa/bwa mem -R '@RG\tID:1\tLB:lib1\tPL:ILLUMINA\tSM:${sample_name_flag}\tPU:unit1' -k 2 -t 24 ${Ref_file} ${if (length(sample_info) > 2) then (sample_info[1] + " " + sample_info[2]) else (sample_info[1])} > ${outdir + "/" + sample_name_flag + ".sam"} 
	}
  
	output {
		File sam = "${outdir}/${sample_name_flag}.sam"
	}
  
	runtime{
		docker:"bwa:base"
		cpu:"4"
		memory:"90G"
	}
}

task samtobam {

	File sam
	String? para

	command {
		/BioBin/samtools/samtools view -bS ${if para != "" then para else ""}  ${sam} -o ${sam}.bam && rm -f ${sam}

	}
  
	output {
		File outbam = "${sam}.bam"
	}

	runtime{
		docker:"bwa:base"
		cpu:"4"
		memory:"50G"
  }
}

task sortbam {

	File bam

	command {
		/BioBin/samtools/samtools sort ${bam} -o ${bam}.sorted.bam && rm -f ${bam}
	}

	output {
		File outbam = "${bam}.sorted.bam"
	}

	runtime{
		docker:"bwa:base"
		cpu:"4"
		memory:"80G"
	}
}

task markdup {
	
	File bam

	command {
		java -jar /gatk/gatk.jar MarkDuplicates --INPUT ${bam} --METRICS_FILE $output.metrics --OUTPUT ${bam}.dup.bam && rm -f ${bam}
	}

	output {
		File outbam = "${bam}.dup.bam"
		File outbai = "${bam}.dup.bam.bai"
	}

	runtime{
		docker:"gatk4/wd:latest"
		cpu:"4"
		memory:"50G"
	}
}

task markdup_bai {
	
	File bam

	command {
		/BioBin/samtools/samtools index ${bam} > ${bam}.bai
	}

	output {
		File outbai = "${bam}.bai"
	}

	runtime{
		docker:"bwa:base"
		cpu:"4"
		memory:"50G"
	}
}
