#! /usr/bin/env Rscript
suppressPackageStartupMessages(require(rtracklayer))
suppressPackageStartupMessages(require(parallel))

regionCapture <- function(seqname,start,end,bw,datapoints) {
  # capture bigwig signal in region with given datapoints
  step <- (end-start) / datapoints
  regions <- GRanges(seqnames=rep(seqname,datapoints), ranges=IRanges(as.integer(seq(start,end,step))[1:datapoints],as.integer(seq(start,end,step))[2:(datapoints+1)]-1))
  return(as.numeric(mean(import(bw,which=regions,as="NumericList"))))
}

orientation_correct <- function(values,strand) {
  if(strand == "-"){
    return(rev(values))
  }
  else{
    return(values)
  }
}

signal_caputer_around_sites <- function(bigWigFile,bed,resolution=50,span=3000,cores=4L) {
  # options
  # bigWigFile: bigWigFile to be capture
  # bedFile: bedFile contain sites information
  # resolution: resolution for capture
  # span: span for upstream, downstream & gene body normalization length
  # cores: cores used for parallel
  
  datapoints <- span * 2 / resolution + 1
  
  seqname <- bed[,1]
  midpoints <- as.integer((bed[,2] + bed[,3] - 1) / 2)
  # get strand information
  if(ncol(bed)>5) { 
    strand <- bed[,6]
  } else {
    strand <- rep(".",nrow(bed))
  }
  
  # capture
  # IRange is 1-based
  # [repair] single batch import: build all per-site datapoint windows at once.
  # Per-site per-region import was far too slow (thousands of file opens).
  starts <- midpoints - span - as.integer(resolution/2)
  nsite <- length(starts)
  site <- rep(seq_len(nsite), each = datapoints)
  allw <- GRanges(
    seqnames = seqname[site],
    ranges = IRanges(
      start = rep(starts, each = datapoints) +
        rep(as.integer(seq(0, by = resolution, length.out = datapoints)), times = nsite),
      width = resolution))
  covs <- import(bigWigFile, which = allw, as = "NumericList")
  mu <- vapply(covs, function(x) if (length(x)) mean(x) else 0, numeric(1))
  signal <- matrix(mu, nrow = datapoints)
  
  # correct orientation & get average signal
  write.table(t(signal),file="temp_signal.txt",quote=F,row.names=F,col.names=F,sep="\t")
  write.table(strand,file="temp_strand.txt",quote=F,row.names=F,col.names=F,sep="\t")
  # [repair] Windows: no paste/awk -> pure-R reverse per strand
  signal_rev <- as.data.frame(t(signal))
  rev_idx <- strand != "+"
  signal_rev[rev_idx, ] <- signal_rev[rev_idx, ncol(signal_rev):1, drop = FALSE]
  write.table(signal_rev, file="temp_signal_rev.txt", quote=F, row.names=F, col.names=F, sep="	")
  signal_rev <- read.table("temp_signal_rev.txt")
  delete_result <- file.remove("temp_signal.txt")
  delete_result <- file.remove("temp_strand.txt")
  delete_result <- file.remove("temp_signal_rev.txt")
  return(apply(signal_rev,2,mean))
  
}
