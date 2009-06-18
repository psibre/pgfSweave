#!/usr/bin/env Rscript

version <- '$Id$\n'
usage <- "Usage: pgfsweave-script.R [options] file

A simple front-end for pgfSweave()

Options:
  -h, --help                print short help message and exit
  -v, --version             print pgfSweave version info and exit
  -d, --dvi                 dont use texi2dvi option pdf=T i.e. call latex 
                            (defalt is pdflatex)
  -s, --pgfsweave-only      dont compile to pdf/dvi, only run Sweave
  -n, --graphics-only       dont use the texi2dvi() funciton in R, compile 
                            graphics only ; ignored if --pgfsweave-only is
                            used

Package repositories: 
http://www.rforge.net/pgfSweave/ (for scm)
http://r-forge.r-project.org/projects/pgfsweave/ (for precompiled packages)
"

library(getopt)
library(pgfSweave)

#Column 3: Argument mask of the flag. An integer. Possible values: 
# 0=no argument, 1=required argument, 2=optional argument. 
optspec <- matrix(c(
  'help'          , 'h', 0, "logical",
  'version'       , 'v', 0, "logical",
  'dvi'           , 'd', 0, "logical",
  'pgfsweave-only', 's', 0, "logical",
  'graphics-only' , 'n', 0, "logical"
),ncol=4,byrow=T)

opt <- try(getopt(optspec),silent=TRUE)
if(class(opt) == 'try-error') opt <- list()

if( !is.null(opt$help    )) { cat(usage); q(status=1) }
if( !is.null(opt$version )) { cat(version); q(status=1) }
opt$dvi <- ifelse(is.null(opt$dvi), FALSE, TRUE )
opt[['pgfsweave-only']] <- ifelse(
                            is.null(opt[['pgfsweave-only']]), FALSE, TRUE )
opt[['graphics-only']] <- ifelse(
                            is.null(opt[['graphics-only']]), FALSE, TRUE )
                            
args <- commandArgs(TRUE)
file <- args[length(args)]

cat('pgfsweave-script.R: using options:\n')
print(opt)

if(opt[['graphics-only']]){
    # In the first case run through pgfSweave but no not compile document or 
    # graphics from within R. Instead, run the shell script generated by 
    # pgfSweave() to compile the graphics
    
    pgfSweave(file, pdf=!opt$dvi,compile.tex=FALSE) 
                   
        #compile the graphics
    bn <- strsplit(basename(file), "\\.Rnw")[[1]][1]
    dn <- dirname(file)
    fn <- file.path(dn, bn)
    cmds <- readLines(paste(fn, "sh", sep = "."))
    dummy <- lapply(cmds, system)
    
}else{
    # In this case, just make a call to the R function pgfSweave() with the
    # options intact.
    
    pgfSweave(file, pdf=!opt$dvi,compile.tex = !opt[['pgfsweave-only']])
}

