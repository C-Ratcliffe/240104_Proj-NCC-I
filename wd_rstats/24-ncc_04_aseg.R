# Preamble####
rm(list = ls())
cat('\014')

library(psych)
library(broom)

# Import####
# reading in the raw data

studydir <- '~/Documents/WD_Code/rstats/240104_Proj-NCC-I/'
setwd(studydir)
indir <- paste0(studydir, 'input/')
outdir <- paste0(studydir, 'output/')
dir.create(indir, showWarnings = F)
dir.create(outdir, showWarnings = F)
ptcvars <- read.csv(paste0(indir, 'participants.tsv'), sep = '\t', na.strings = "na")
opts.groups <- c('N-NCC', 'N-HC', 'HCP-HC', 'N-NCC-PS', 'N-NCC-FS')
opts.ptcs <- ptcvars$study_id
data.raw <- read.csv(paste0(indir, 'fsl/volumes.tsv'), sep = '\t', na.strings = "na", row.names = 1, header = F)
rownames(data.raw) <- opts.ptcs
data.raw <- cbind(ptcvars$group, ptcvars$first_sz, ptcvars$sz_rec, ptcvars$age_at_scan, ptcvars$sex, ptcvars$brain_vol, data.raw)
colnames(data.raw) <- c('group', 'first_sz', 'sz_rec', 'age_at_scan', 'sex'
	, 'brain_vol', 'Left_Accumbens', 'Left_Amygdala', 'Left_Caudate'
	, 'Left_Hippocampus', 'Left_Pallidum', 'Left_Putamen', 'Left_Thalamus'
	, 'Right_Accumbens', 'Right_Amygdala', 'Right_Caudate', 'Right_Hippocampus'
	, 'Right_Pallidum', 'Right_Putamen', 'Right_Thalamus')

# Formatting####
# organising the data into groups with demographics to aid omnibus testing

data.groups <- list('all' = data.raw[data.raw$group != 2, ]
	, 'first_sz' = data.raw[is.na(data.raw$first_sz) == F, ]
	, 'sz_rec' = data.raw[is.na(data.raw$sz_rec) == F, ]
)

data.models <- list()
data.summaries <- list()
data.desc <- list()

# Linear modelling####
# looping through the subcortical regions and creating linear models

for (i in 7:length(data.groups$all)){
	region <- colnames(data.groups$all)[i]
	temp.all <- paste0('all.', region)
	temp.first_sz <- paste0('first_sz.', region)
	temp.sz_rec <- paste0('sz_rec.', region)
	data.formulas <- list('all' = paste0(region, ' ~ group + age_at_scan + sex + brain_vol')
		, 'first_sz' = paste0(region, ' ~ first_sz + age_at_scan + sex + brain_vol')
		, 'sz_rec' = paste0(region, ' ~ sz_rec + age_at_scan + sex + brain_vol')
	)

	data.desc$all <- describeBy(data.groups$all[,7:20], group = data.groups$all$group)
	data.desc$first_sz <- describeBy(data.groups$first_sz[,7:20], group = data.groups$first_sz$first_sz)
	data.desc$sz_rec <- describeBy(data.groups$sz_rec[,7:20], group = data.groups$sz_rec$sz_rec)

	data.models[[temp.all]] <- lm(data.formulas$all, data = data.groups$all)
	data.models[[temp.first_sz]] <- lm(data.formulas$first_sz, data = data.groups$first_sz)
	data.models[[temp.sz_rec]] <- lm(data.formulas$sz_rec, data = data.groups$sz_rec)

	data.summaries[[temp.all]] <- summary(data.models[[temp.all]])
	data.summaries[[temp.first_sz]] <- summary(data.models[[temp.first_sz]])
	data.summaries[[temp.sz_rec]] <- summary(data.models[[temp.sz_rec]])
}


effects <- matrix(data = NA, nrow = 14, ncol = 3, dimnames = list(colnames(data.raw)[7:20], c('all', 'first_sz', 'sz_rec')))

effects[,1] <- (data.desc$all$'1'$mean - data.desc$all$'0'$mean)/sqrt((data.desc$all$'0'$sd^2 + data.desc$all$'1'$sd^2)/2)
effects[,2] <- (data.desc$first_sz$'1'$mean - data.desc$first_sz$'0'$mean)/sqrt((data.desc$first_sz$'0'$sd^2 + data.desc$first_sz$'1'$sd^2)/2)
effects[,3] <- (data.desc$sz_rec$'1'$mean - data.desc$sz_rec$'0'$mean)/sqrt((data.desc$sz_rec$'0'$sd^2 + data.desc$sz_rec$'1'$sd^2)/2)

means <- matrix(data = NA, nrow = 14, ncol = 3, dimnames = list(colnames(data.raw)[7:20], c('all', 'first_sz', 'sz_rec')))

means[,1] <- paste0(round(data.desc$all$'0'$mean, 2), ' (', round(data.desc$all$'0'$sd, 2), ')\\newline ', round(data.desc$all$'1'$mean, 2), ' (', round(data.desc$all$'1'$sd, 2), ')')
means[,2] <- paste0(round(data.desc$first_sz$'1'$mean, 2), ' (', round(data.desc$first_sz$'1'$sd, 2), ')\\newline ', round(data.desc$first_sz$'0'$mean, 2), ' (', round(data.desc$first_sz$'0'$sd, 2), ')')
means[,3] <- paste0(round(data.desc$sz_rec$'0'$mean, 2), ' (', round(data.desc$sz_rec$'0'$sd, 2), ')\\newline ', round(data.desc$sz_rec$'1'$mean, 2), ' (', round(data.desc$sz_rec$'1'$sd, 2), ')')

# data extraction####
# extracting the p-values and writing them out

pvals <- effects

j <- 1
for (i in seq(1, 40, 3)){
	pvals[j,1] <- data.summaries[[i]]$coefficients[2,4]
	i <- i+1
	pvals[j,2] <- data.summaries[[i]]$coefficients[2,4]
	i <- i+1
	pvals[j,3] <- data.summaries[[i]]$coefficients[2,4]
	j <- j+1
}

rowpreamble <- matrix(0, nrow = 2, ncol = 1)
rowpreamble[1,] <- '\\rowcolor[HTML]{FBFBFB}'
rowpreamble[2,] <- '\\rowcolor[HTML]{EFEFEF}'

table <- matrix(0, nrow = 14, ncol = 1)
table[,1] <- paste0(rowpreamble, ' ', rownames(effects), ' & '
	, means[,1], ' & ', round(pvals[,1], 3), ' & ', round(effects[,1], 2), ' & '
	, means[,2], ' & ', round(pvals[,2], 3), ' & ', round(effects[,2], 2), ' & '
	, means[,3], ' & ', round(pvals[,3], 3), ' & ', round(effects[,3], 2), ' \\\\'
)

write.table(pvals, paste0(outdir, 'fsl/vol-sigs.tsv'), quote = F, row.names = F)
write.table(effects, paste0(outdir, 'fsl/vol-effects.tsv'), quote = F, row.names = F)
write.table(table, paste0(outdir, 'fsl/table.txt'), quote = F, row.names = F)

temp.p.shape <- c(.079, .025, .003, .002, .001, .003, .002, .011, .749, .004, .010, .037, .019, .004)
temp.padj.shape <- p.adjust(temp.p.shape, 'bonferroni')

# EXTRA - all group tests####
# corrected linear models of subcortical volume
# mod1 <- HC-N ~ HC-P ~ PW-NCC
# mod2 <- HC-N ~ PW-NCC
# mod3 <- PW-NCC-FS ~ PW-NCC-PS
# mod4 <- PW-NCC-SF ~ PW-NCC-SR

models <- list()

for (i in c('mod1', 'mod2', 'mod3', 'mod4')){
	models[[i]] <- list()
	models[[i]]$model <- list()
	models[[i]]$summary <- list()
	models[[i]]$post <- list()
	models[[i]]$p <- list()
	models[[i]]$padj <- list()
	models[[i]]$cohen <- list()
	if (i == 'mod1') {
		temp.data <- data.raw
		models[[i]]$desc <- describeBy(
			temp.data[,7:20]
			, group = temp.data$group
			)
		models[[i]]$cohen$ncc.hcn <- (models[[i]]$desc$'0'$mean - models[[i]]$desc$'1'$mean)/sqrt((models[[i]]$desc$'0'$sd^2 + models[[i]]$desc$'1'$sd^2)/2)
		models[[i]]$cohen$ncc.hcp <- (models[[i]]$desc$'0'$mean - models[[i]]$desc$'2'$mean)/sqrt((models[[i]]$desc$'0'$sd^2 + models[[i]]$desc$'2'$sd^2)/2)
		models[[i]]$cohen$hcn.hcp <- (models[[i]]$desc$'1'$mean - models[[i]]$desc$'2'$mean)/sqrt((models[[i]]$desc$'1'$sd^2 + models[[i]]$desc$'2'$sd^2)/2)
	} else if (i == 'mod2') {
		temp.data <- data.raw[data.raw$group != 2, ]
		models[[i]]$desc <- describeBy(
			temp.data[,7:20]
			, group = temp.data$group
			)
		models[[i]]$cohen$ncc.hcn <- (models[[i]]$desc$'0'$mean - models[[i]]$desc$'1'$mean)/sqrt((models[[i]]$desc$'0'$sd^2 + models[[i]]$desc$'1'$sd^2)/2)
	} else if (i == 'mod3') {
		temp.data <- data.raw[is.na(data.raw$first_sz) != 1, ]
		temp.data$group <- temp.data$first_sz
		models[[i]]$desc <- describeBy(
			temp.data[,7:20]
			, group = temp.data$group
			)
		models[[i]]$cohen$fs.ps <- (models[[i]]$desc$'1'$mean - models[[i]]$desc$'0'$mean)/sqrt((models[[i]]$desc$'0'$sd^2 + models[[i]]$desc$'1'$sd^2)/2)
	} else if (i == 'mod4') {
		temp.data <- data.raw[is.na(data.raw$sz_rec) != 1, ]
		temp.data$group <- temp.data$sz_rec
		models[[i]]$desc <- describeBy(
			temp.data[,7:20]
			, group = temp.data$group
			)
		models[[i]]$cohen$sf.sr <- (models[[i]]$desc$'0'$mean - models[[i]]$desc$'1'$mean)/sqrt((models[[i]]$desc$'0'$sd^2 + models[[i]]$desc$'1'$sd^2)/2)
	}
	for (j in 7:length(data.raw)){
		k <- colnames(data.raw)[j]
		temp.formula <-  paste0(
			k
			, ' ~ group + age_at_scan + sex + brain_vol'
			)
		models[[i]]$model[[k]] <- lm(
			temp.formula
			, data = temp.data
			)
		models[[i]]$summary[[k]] <- summary(
			models[[i]]$model[[k]]
			)
		models[[i]]$post[[k]] <- pairwise.t.test(
			temp.data[,j]
			, temp.data$group
			, p.adj = 'bonf'
			)
		models[[i]]$p[k] <- models[[i]]$summary[[k]][[4]][2, 4]
	}
	models[[i]]$padj <- p.adjust(
		models[[i]]$p
		, 'bonferroni'
		)
}
