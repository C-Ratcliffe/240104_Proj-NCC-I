rm(list = ls())
cat('\014')

library('RNOmni')
library('fmsb')
library('extrafont')
library('tidyverse')
library('Cairo')
library('svglite')

#Import the data####

studydir <- 'C:/Users/coreyar/Working_Directory_Code/rstats/240104_Proj-NCC-I/'
setwd(studydir)
indir <- paste0(studydir, 'input/')
fbadir <- paste0(indir, 'fba/')
ptcvars <- read.csv(paste0(indir, 'participants.tsv'), sep = '\t')
opt.metrics = list.files(path = fbadir, pattern = '\\mean.tsv$')
opt.tracts <- read.csv(paste(fbadir, '/tracts.csv', sep = ''), header = F)[[1]]
means_raw <- lapply(paste(fbadir, opt.metrics, sep = ''), read.csv, sep = ',', header = F, row.names = 1)
opt.metrics <- gsub("_mean.tsv", "", opt.metrics)
opt.subs <- rownames(means_raw[[1]])
ptcvars <- ptcvars[ptcvars[,1] %in% opt.subs, ]
names(means_raw) <- opt.metrics
opt.toi <- c('CC_1', 'CC_2', 'CC_3', 'CC_4', 'CC_5', 'CC_6', 'CC_7', 'CG_', 'MLF_', 'T_OCC_', 'T_PAR_', 'T_POSTC_', 'T_PREC_', 'T_PREF_', 'T_PREM_')

ind.group <- list(ind.n_ncc = which(ptcvars$group == '0')
	, ind.n_hc = which(ptcvars$group == '1')
	, ind.hcp_hc = which(ptcvars$group == '2'))

ind.seiz <- list(ind.ncc_ps = which(ptcvars$first_sz == '0')
	, ind.ncc_fs = which(ptcvars$first_sz == '1'))

ind.recc <- list(ind.ncc_sf = which(ptcvars$sz_rec == '0')
	, ind.ncc_sr = which(ptcvars$sz_rec == '1'))

#Create standard deviations####

means_z <- means_raw
for (i in 1:length(means_raw)){
	metric <- as.data.frame(means_raw[[i]])
	colnames(means_z[[i]]) <- opt.tracts
	rownames(means_z[[i]]) <- sub('sub.', 'sub-', rownames(means_z[[i]]))
	for (j in 1:ncol(metric)){
		col <- RankNorm(metric[,j])
		control <- col[ptcvars$group == 1]
		means_z[[i]][,j] <- (col - mean(control))/(sd(control))
	}
}

means_tracts <- array(data = NA, dim = c(length(opt.tracts), length(ind.group), length(opt.metrics)))
dimnames(means_tracts) <- list(opt.tracts, names(ind.group), opt.metrics)
for (i in 1:length(means_z)){
	for (j in 1:length(ind.group)){
		means_tracts[ , j, i] <- colMeans(means_z[[i]][ind.group[[j]], ])
	}
}

means_tracts[,2,] <- 0

for (i in 1:dim(means_tracts)[3]){
	fname <- paste0(studydir, 'output/fba/tracts/', colnames(means_tracts[1,,])[i], '.tsv', sep = '')
	write.table(means_tracts[,,i], fname, quote = F, sep = '\t')
}

#Format the data for spider plots####

ind.roi <- c(opt.toi[4:1]
	, paste0(opt.toi[8:15], 'left')
	, rev(paste0(opt.toi[8:15], 'right'))
	, opt.toi[7:5]
	)

ind.spider <- list()
for (i in opt.metrics){
	ind.spider[[i]] <- matrix(data = NA
		, nrow = length(ptcvars[ptcvars$group != 2, "study_id"])
		, ncol = length(ind.roi)
		, dimnames=list(ptcvars[ptcvars$group != 2, "study_id"], ind.roi))
	for (j in 1:length(ind.roi)){
		ind.spider[[i]][,j] <- means_z[[i]][ptcvars$group != 2,ind.roi[j]]
	}
}

data.labels <- ind.roi
data.labels <- sub('_right', ' (R)', data.labels)
data.labels <- sub('_left', ' (L)', data.labels)

#Creating spider plots####

opar <- par()
for (i in 1:length(ind.spider)){

	#finding the limits using the absolute highest value
	datasheet <- ind.spider[[i]]
	absmax <- pmax(abs(floor(min(datasheet))), abs(ceiling(max(datasheet))))
	absmin <- -1*absmax

	#the data is split to reflect left vs right tracts
	data <- as.data.frame(rbind(absmax, absmin, -1.96, 0, 1.96, ind.spider[[i]]))

	#filenames are designated
	fname <- paste(studydir, 'output/fba/spiderplots/', opt.metrics[i], sep = '')

	#individual####
	#fmsb is used to create a radar chart for each subject, with 1 SD in both directions also plotted
	for (j in 6:nrow(data)){

		#subject specific data is extracted
		data.radar <- data[c(1:5, j), ]

		#the output device is set up
		fname_individual <- paste(fname, sub('sub.', 'sub-', rownames(data.radar[6,])), sep = '_')
		CairoSVG(file = paste(fname_individual, 'svg', sep = '.')
			, pointsize = 10
			, family = 'Roboto Light'
			, bg = 'transparent'
			, xpd = NA
		)
		par(mar = c(0, 0, 0, 0))

		#the radar chart is plotted
		radarchart(data.radar
			, axistype = 4
			, seg = 2
			, plwd = c(0.5, 0.5, 0.5, 2)
			, pty = c(32, 32, 32, 20)
			, plty = c(5, 5, 5, 3)
			, vlcex = 0.6
			, cglty = 1
			, cglwd = 1
			, maxmin = T
			, caxislabels = c(absmin, 0, absmax)
			, cglcol = '#000000'
			, axislabcol = '#000000'
			, pcol = c('#000000', '#000000', '#000000', '#440154ff')
			, pfcol = c('#CCCCCC20', '#99999920', '#66666620', '#44015460')
			, col.main = '#000000'
			, font.main = 1
			, vlabels = data.labels
		)
		dev.off()
	}
	#group####
	#n-ncc vs n-hc
	for (j in 1:2){

		#subject specific data is extracted
		data.radar <- rbind(data[1:5, ], colMeans(data[c(ind.group[[j]] + 5), ]))

		#the output device is set up
		fname_group <- paste(fname, sub('ind.', '', names(ind.group)[j]), sep = '_')
		CairoSVG(file = paste(fname_group, 'svg', sep = '.')
			, pointsize = 10
			, family = 'Roboto Light'
			, bg = 'transparent'
			, xpd = NA
		)
		par(mar = c(0, 0, 0, 0))

		#the radar chart is plotted
		radarchart(data.radar
			, axistype = 4
			, seg = 2
			, plwd = c(0.5, 0.5, 0.5, 2)
			, pty = c(32, 32, 32, 20)
			, plty = c(5, 5, 5, 3)
			, vlcex = 0.6
			, cglty = 1
			, cglwd = 1
			, maxmin = T
			, caxislabels = c(absmin, 0, absmax)
			, cglcol = '#000000'
			, axislabcol = '#000000'
			, pcol = c('#000000', '#000000', '#000000', '#440154ff')
			, pfcol = c('#CCCCCC20', '#99999920', '#66666620', '#44015460')
			, col.main = '#000000'
			, font.main = 1
			, vlabels = data.labels
		)
		dev.off()
	}
	#seiz####
	#prior seizure vs first seizure
	for (j in 1:2){

		#subject specific data is extracted
		data.radar <- rbind(data[1:5, ], colMeans(data[c(ind.seiz[[j]] + 5), ]))

		#the output device is set up
		fname_group <- paste(fname, sub('ind.', '', names(ind.seiz)[j]), sep = '_')
		CairoSVG(file = paste(fname_group, 'svg', sep = '.')
			, pointsize = 10
			, family = 'Roboto Light'
			, bg = 'transparent'
			, xpd = NA
		)
		par(mar = c(0, 0, 0, 0))

		#the radar chart is plotted
		radarchart(data.radar
			, axistype = 4
			, seg = 2
			, plwd = c(0.5, 0.5, 0.5, 2)
			, pty = c(32, 32, 32, 20)
			, plty = c(5, 5, 5, 3)
			, vlcex = 0.6
			, cglty = 1
			, cglwd = 1
			, maxmin = T
			, caxislabels = c(absmin, 0, absmax)
			, cglcol = '#000000'
			, axislabcol = '#000000'
			, pcol = c('#000000', '#000000', '#000000', '#440154ff')
			, pfcol = c('#CCCCCC20', '#99999920', '#66666620', '#44015460')
			, col.main = '#000000'
			, font.main = 1
			, vlabels = data.labels
		)
		dev.off()
	}
	#seiz rec####
	#seizure freedom vs seizure recurrence
	for (j in 1:2){

		#subject specific data is extracted
		data.radar <- rbind(data[1:5, ], colMeans(data[c(ind.recc[[j]] + 5), ]))

		#the output device is set up
		fname_group <- paste(fname, sub('ind.', '', names(ind.recc)[j]), sep = '_')
		CairoSVG(file = paste(fname_group, 'svg', sep = '.')
			, pointsize = 10
			, family = 'Roboto Light'
			, bg = 'transparent'
			, xpd = NA
		)
		par(mar = c(0, 0, 0, 0))

		#the radar chart is plotted
		radarchart(data.radar
			, axistype = 4
			, seg = 2
			, plwd = c(0.5, 0.5, 0.5, 2)
			, pty = c(32, 32, 32, 20)
			, plty = c(5, 5, 5, 3)
			, vlcex = 0.6
			, cglty = 1
			, cglwd = 1
			, maxmin = T
			, caxislabels = c(absmin, 0, absmax)
			, cglcol = '#000000'
			, axislabcol = '#000000'
			, pcol = c('#000000', '#000000', '#000000', '#440154ff')
			, pfcol = c('#CCCCCC20', '#99999920', '#66666620', '#44015460')
			, col.main = '#000000'
			, font.main = 1
			, vlabels = data.labels
		)
		dev.off()
	}
}

par <- opar

#clean up####

rm(i, j, metric, col, control, par, opar, absmax, absmin, data.radar, datasheet)
