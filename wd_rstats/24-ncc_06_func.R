# Preamble####
rm(list = ls())
cat('\014')

library(RNifti)

studydir <- 'C:/Users/coreyar/Working_Directory_Code/rstats/240104_Proj-NCC-I/'
setwd(studydir)
indir <- paste0(studydir, 'input/')
outdir <- paste0(studydir, 'output/func/')
funcdir <- paste0(studydir, 'input/func/')
opt.vals <- read.csv(paste(funcdir, 'values.tsv', sep = ''), sep ='\t', header = F)
opt.ints <- c(rep(0, 28), 1:164)
write.table(t(opt.ints), paste0(outdir, 'index.tsv'), col.names = F, row.names = F, sep = ' ')
write.table(opt.vals, paste0(outdir, 'values.tsv'), col.names = F, row.names = F, sep = ' ')
index <- rbind(opt.vals, opt.ints)

destrieux <- readNifti(paste0(funcdir, "destrieux.nii", sep = ''))
for (i in 1:ncol(index)){
	destrieux[destrieux == index[1, i]] <- index[2, i]
}
writeNifti(destrieux, paste0(outdir, 'destrieux.nii'))

tab <- list()
tab$cystsize <- read.csv(paste(funcdir, 'cyst_table.tsv', sep = ''), sep ='\t', header = T)
tab$cystroi <- read.csv(paste(funcdir, 'cyst_ROIs.txt', sep = ''), sep =' ', header = F)[,1:3]
tab$cystnode <- cbind(tab$cystroi, 1 - tab$cystsize[,3], tab$cystsize[,2])
tab$oedemasize <- read.csv(paste(funcdir, 'oedema_table.tsv', sep = ''), sep ='\t', header = T)
tab$oedemaroi <- read.csv(paste(funcdir, 'oedema_ROIs.txt', sep = ''), sep =' ', header = F)[,1:3]
tab$oedemanode <- cbind(tab$oedemaroi, 1 - tab$oedemasize[,3], tab$oedemasize[,2])

for (i in c('cystnode', 'oedemanode')){
	node <- tab[[i]]
	write.table(node, paste0(outdir, 'func.', i, '.node'), col.names = F, row.names = F, quote = F, sep = '\t')
}
