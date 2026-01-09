rm(list = ls())
cat("\014")

library(caret)

# set aliases####
studydir <- 'C:/Users/coreyar/Working_Directory_Code/rstats/240104_Proj-NCC-I/'
setwd(studydir)
dir.create(paste0(studydir, 'output/fba'), showWarnings = F)
dir.create(paste0(studydir, 'output/fsl'), showWarnings = F)
dir.create(paste0(studydir, 'output/conn'), showWarnings = F)
metrics.dki <- c('ad', 'fa', 'md', 'rd', 'ak', 'mk', 'rk')
metrics.fba <- c('fd', 'fdc', 'logfc')

# import data####
df <- list()

df$raw <- read.delim(paste0(studydir, 'input/participants.tsv'), header = T, sep = "\t", dec = '.', numerals = 'no.loss', row.names = 1, na.strings = 'na')
for (i in c(1, 3, 4, 10, 11, 12, 13)){
	df$raw[,i] <- as.factor(df$raw[,i])
}

# check assumptions - check normality?####
assumptions <- list()
# across groups
assumptions[['age']] <- summary(aov(df$raw$age ~ df$raw$group))
assumptions[['age_post']] <- TukeyHSD(aov(df$raw$age ~ df$raw$group))
assumptions[['sex']] <- fisher.test(df$raw$sex, df$raw$group)
assumptions[['brain_vol']] <- summary(aov(df$raw$brain_vol ~ df$raw$group + df$raw$sex + df$raw$age_at_scan))
assumptions[['brain_vol_post']] <- TukeyHSD(aov(df$raw$brain_vol ~ df$raw$group))
# across first-seizure groups
assumptions[['v_no']] <- t.test(df$raw[df$raw$group == 0, ]$v_no ~ df$raw[df$raw$group == 0, ]$first_sz)
assumptions[['nv_no']] <- t.test(df$raw[df$raw$group == 0, ]$nv_no ~ df$raw[df$raw$group == 0, ]$first_sz)
assumptions[['sz_count']] <- t.test(df$raw[df$raw$group == 0, ]$sz_count ~ df$raw[df$raw$group == 0, ]$first_sz)
assumptions[['sz_type']] <- fisher.test(df$raw[df$raw$group == 0, ]$sz_type, df$raw[df$raw$group == 0, ]$first_sz)
assumptions[['anthel']] <- fisher.test(df$raw[df$raw$group == 0, ]$anthel, df$raw[df$raw$group == 0, ]$first_sz)
assumptions[['sz_rec']] <- fisher.test(df$raw[df$raw$group == 0, ]$sz_rec, df$raw[df$raw$group == 0, ]$first_sz)
assumptions[['oedema_vol']] <- t.test(df$raw[df$raw$group == 0, ]$oedema_vol ~ df$raw[df$raw$group == 0, ]$first_sz)

# export assumptions####
sink('output/assumptions.md')
print(assumptions)
sink()
closeAllConnections()

# re-encode data####

df$model <- df$raw[,c(1:6, 9, 13:15)]
temp <- dummyVars(as.formula(paste('~', 'group')), data = df$model)
temp <- data.frame(predict(temp, newdata = df$model))
df$dummy <- cbind(as.data.frame(temp), df$model[,-1])

# FBA matrices####
# exclusions

fba <- list()

fba$all <- df$dummy
exc <- row.names(fba$all) %in% c('sub-001', 'sub-005', 'sub-906', 'sub-908')
fba$all <- fba$all[!exc,]
fba$ncc <- fba$all[fba$all$group.0 == 1 & is.na(fba$all$first_sz) == F,]

# all participants - f-test
#
#fba$all.mat <- as.matrix(
#	cbind(fba$all[,1:3]
#		, ((fba$all[,4] - mean(fba$all[,4]))/sd(fba$all[,4]))
#		, as.numeric(fba$all[,5]) -1
#		, ((fba$all[,11] - mean(fba$all[,11]))/sd(fba$all[,11]))
#	)
#)
#fba$all.con <- matrix(
#	c(1, 0, -1, 0, 0, 0
#		, 0, 1, -1, 0, 0, 0
#		, 1, -1, 0, 0, 0, 0
#		, -1, 0, 1, 0, 0, 0
#		, 0, -1, 1, 0, 0, 0
#		, -1, 1, 0, 0 ,0 ,0
#	)
#	, nrow = 6
#	, ncol = 6
#	, byrow = T
#)
#fba$all.ft <- matrix(
#	c(1, 1, 0, 0, 0, 0
#	)
#	, nrow = 1
#	, ncol = 6
#	, byrow = T
#)

# all participants - t-test

fba$all <- fba$all[fba$all$group.2 == 0,]

fba$all.mat <- as.matrix(
	cbind(fba$all[,1:2]
		, ((fba$all[,4] - mean(fba$all[,4]))/sd(fba$all[,4]))
		, as.numeric(fba$all[,5]) -1
		, ((fba$all[,11] - mean(fba$all[,11]))/sd(fba$all[,11]))
	)
)
fba$all.con <- matrix(
	c( 1, -1, 0, 0, 0
		, -1, 1, 0, 0 ,0
	)
	, nrow = 2
	, ncol = 5
	, byrow = T
)

# ncc only comparisons

temp <- dummyVars(as.formula(paste('~', 'first_sz')), data = fba$ncc)
temp <- data.frame(predict(temp, newdata = fba$ncc))

fba$ncc.mat <- as.matrix(
	cbind(temp
		, ((fba$ncc[,4] - mean(fba$ncc[,4]))/sd(fba$ncc[,4]))
		, as.numeric(fba$ncc[,5]) - 1
		, ((fba$ncc[,11] - mean(fba$ncc[,11]))/sd(fba$ncc[,11]))
	)
)
fba$ncc.con <- matrix(
	c(1, -1, 0, 0, 0
		, -1, 1, 0, 0, 0
	)
	, nrow = 2
	, ncol = 5
	, byrow = T
)

# ncc vs combined hc comparisons
#
#fba$hcc.mat <- fba$all.mat
#fba$hcc.mat[,2] <- fba$hcc.mat[,2] + fba$hcc.mat[,3]
#fba$hcc.mat <- fba$hcc.mat[,-3]
#fba$hcc.con <- fba$ncc.con

# exporting the designs/contrasts/ftests

write.table(fba$all.mat, paste0(studydir, 'output/fba/', 'design.all', '.txt'), row.names = F, col.names = F, quote = F, sep = '\t')
write.table(fba$ncc.mat, paste0(studydir, 'output/fba/', 'design.ncc', '.txt'), row.names = F, col.names = F, quote = F, sep = '\t')
#write.table(fba$hcc.mat, paste0(studydir, 'output/fba/', 'design.hcc', '.txt'), row.names = F, col.names = F, quote = F, sep = '\t')
write.table(fba$all.con, paste0(studydir, 'output/fba/', 'contrast.all', '.txt'), row.names = F, col.names = F, quote = F, sep = '\t')
write.table(fba$ncc.con, paste0(studydir, 'output/fba/', 'contrast.ncc', '.txt'), row.names = F, col.names = F, quote = F, sep = '\t')
#write.table(fba$hcc.con, paste0(studydir, 'output/fba/', 'contrast.hcc', '.txt'), row.names = F, col.names = F, quote = F, sep = '\t')
#write.table(fba$all.ft, paste0(studydir, 'output/fba/', 'ftest.all', '.txt'), row.names = F, col.names = F, quote = F, sep = '\t')

# create file lists

for (i in metrics.dki){
	filename <- paste0(studydir, 'output/fba/files_', i, '.all.txt')
	#filename2 <- paste0(studydir, 'output/fba/files_', i, '.hcc.txt')
	df$temp <- paste0('../template/', i, '/', row.names(fba$all.mat), '_', i, '.mif', sep = '')
	write.table(df$temp, filename, sep = '', row.names = F, col.names = F, quote = F)
	#write.table(df$temp, filename2, sep = '', row.names = F, col.names = F, quote = F)
}
for (i in metrics.fba){
	filename <- paste0(studydir, 'output/fba/files_', i, '.all.txt')
	#filename2 <- paste0(studydir, 'output/fba/files_', i, '.hcc.txt')
	df$temp <- paste0(row.names(fba$all.mat), '_', i, '.mif', sep = '')
	write.table(df$temp, filename, sep = '', row.names = F, col.names = F, quote = F)
	#write.table(df$temp, filename2, sep = '', row.names = F, col.names = F, quote = F)
}
for (i in metrics.dki){
	filename <- paste0(studydir, 'output/fba/files_', i, '.ncc.txt')
	df$temp <- paste0('../template/', i, '/', row.names(fba$ncc.mat), '_', i, '.mif', sep = '')
	write.table(df$temp, filename, sep = '', row.names = F, col.names = F, quote = F)
}
for (i in metrics.fba){
	filename <- paste0(studydir, 'output/fba/files_', i, '.ncc.txt')
	df$temp <- paste0(row.names(fba$ncc.mat), '_', i, '.mif', sep = '')
	write.table(df$temp, filename, sep = '', row.names = F, col.names = F, quote = F)
}

# FSL matrices####

fsl <- list()

fsl$all <- df$dummy
fsl$ncc <- fsl$all[fsl$all$group.0 == 1 & is.na(fsl$all$first_sz) == F,]

# all groups anova

fsl$all.mat <- as.matrix(
	cbind(fsl$all[,1:3]
		, ((fsl$all[,4] - mean(fsl$all[,4]))/sd(fsl$all[,4]))
		, as.numeric(fsl$all[,5]) -1
		, ((fsl$all[,11] - mean(fsl$all[,11]))/sd(fsl$all[,11]))
	)
)
fsl$all.con <- matrix(
	c(1, 0, -1, 0, 0, 0
		, 0, 1, -1, 0, 0, 0
		, 1, -1, 0, 0, 0, 0
		, -1, 0, 1, 0, 0, 0
		, 0, -1, 1, 0, 0, 0
		, -1, 1, 0, 0 ,0 ,0
	)
	, nrow = 6
	, ncol = 6
	, byrow = T
)
fsl$all.ft <- matrix(
	c(1, 1, 0, 0, 0, 0
	)
	, nrow = 1
	, ncol = 6
	, byrow = T
)

# ncc only comparisons

temp <- dummyVars(as.formula(paste('~', 'first_sz')), data = fsl$ncc)
temp <- data.frame(predict(temp, newdata = fsl$ncc))

fsl$ncc.mat <- as.matrix(
	cbind(temp
		, ((fsl$ncc[,4] - mean(fsl$ncc[,4]))/sd(fsl$ncc[,4]))
		, as.numeric(fsl$ncc[,5]) - 1
		, ((fsl$ncc[,11] - mean(fsl$ncc[,11]))/sd(fsl$ncc[,11]))
	)
)
fsl$ncc.con <- matrix(
	c(1, -1, 0, 0, 0
		, -1, 1, 0, 0, 0
	)
	, nrow = 2
	, ncol = 5
	, byrow = T
)

# ncc vs combined hc comparisons

fsl$hcc.mat <- fsl$all.mat
fsl$hcc.mat[,2] <- fsl$hcc.mat[,2] + fsl$hcc.mat[,3]
fsl$hcc.mat <- fsl$hcc.mat[,-3]
fsl$hcc.con <- fsl$ncc.con

write.table(fsl$all.mat, paste0(studydir, 'output/fsl/', 'design.all', '.txt'), row.names = F, col.names = F, quote = F, sep = '\t')
write.table(fsl$ncc.mat, paste0(studydir, 'output/fsl/', 'design.ncc', '.txt'), row.names = F, col.names = F, quote = F, sep = '\t')
write.table(fsl$hcc.mat, paste0(studydir, 'output/fsl/', 'design.hcc', '.txt'), row.names = F, col.names = F, quote = F, sep = '\t')
write.table(fsl$all.con, paste0(studydir, 'output/fsl/', 'contrast.all', '.txt'), row.names = F, col.names = F, quote = F, sep = '\t')
write.table(fsl$ncc.con, paste0(studydir, 'output/fsl/', 'contrast.ncc', '.txt'), row.names = F, col.names = F, quote = F, sep = '\t')
write.table(fsl$hcc.con, paste0(studydir, 'output/fsl/', 'contrast.hcc', '.txt'), row.names = F, col.names = F, quote = F, sep = '\t')
write.table(fsl$all.ft, paste0(studydir, 'output/fsl/', 'ftest.all', '.txt'), row.names = F, col.names = F, quote = F, sep = '\t')

# CONN matrices####
# matrices for conn

conn <- list()

conn$all <- df$dummy[df$dummy$group.2 != 1,]
conn$base <- conn$all[,c(1, 2, 3, 4, 11)]
conn$base[conn$base != 0] <- 0

conn$all.mat <- as.matrix(
	cbind(conn$all[,1:2]
		, ((conn$all[,4] - mean(conn$all[,4]))/sd(conn$all[,4]))
		, as.numeric(conn$all[,5]) - 1
		, ((conn$all[,11] - mean(conn$all[,11]))/sd(conn$all[,11]))
	)
)

conn$first_sz <- conn$all[is.na(df$dummy$first_sz) == F,]
temp <- dummyVars(as.formula(paste('~', 'first_sz')), data = conn$first_sz)
temp <- data.frame(predict(temp, newdata = conn$first_sz))
conn$first_sz.mat <- as.matrix(
	cbind(temp
		, ((conn$first_sz[,4] - mean(conn$first_sz[,4]))/sd(conn$first_sz[,4]))
		, as.numeric(conn$first_sz[,5]) - 1
		, ((conn$first_sz[,11] - mean(conn$first_sz[,11]))/sd(conn$first_sz[,11]))
	)
)
conn$ncc.mat <- conn$base
for (i in rownames(conn$first_sz.mat)){
	conn$ncc.mat[i,] <- conn$first_sz.mat[i,]
}

conn$sz_rec <- conn$all[is.na(df$dummy$sz_rec) == F,]
temp <- dummyVars(as.formula(paste('~', 'sz_rec')), data = conn$sz_rec)
temp <- data.frame(predict(temp, newdata = conn$sz_rec))
conn$sz_rec.mat <- as.matrix(
	cbind(temp
		, ((conn$sz_rec[,4] - mean(conn$sz_rec[,4]))/sd(conn$sz_rec[,4]))
		, as.numeric(conn$sz_rec[,5]) - 1
		, ((conn$sz_rec[,11] - mean(conn$sz_rec[,11]))/sd(conn$sz_rec[,11]))
	)
)
conn$sz.mat <- conn$base
for (i in rownames(conn$sz_rec.mat)){
	conn$sz.mat[i,] <- conn$sz_rec.mat[i,]
}

conn$all.con <- fsl$ncc.con
conn$ncc.con <- fsl$ncc.con
conn$sz.con <- fsl$ncc.con

write.table(conn$all.mat, paste0(studydir, 'output/conn/', 'design.all', '.txt'), row.names = F, col.names = F, quote = F, sep = '\t')
write.table(conn$ncc.mat, paste0(studydir, 'output/conn/', 'design.ncc', '.txt'), row.names = F, col.names = F, quote = F, sep = '\t')
write.table(conn$sz.mat, paste0(studydir, 'output/conn/', 'design.sz', '.txt'), row.names = F, col.names = F, quote = F, sep = '\t')
write.table(conn$all.con, paste0(studydir, 'output/conn/', 'contrast.all', '.txt'), row.names = F, col.names = F, quote = F, sep = '\t')
write.table(conn$ncc.con, paste0(studydir, 'output/conn/', 'contrast.ncc', '.txt'), row.names = F, col.names = F, quote = F, sep = '\t')

save(list = ls(), file = '24-ncc_00_assumptions-designs.rdata')

