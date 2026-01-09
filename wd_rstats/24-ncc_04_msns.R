# Preamble####
rm(list = ls())
cat('\014')

library(extrafont)
library(ggplot2)
library(RNifti)
library(corrplot)
library(NBR)
library(parallel)
library(lattice)
library(circlize)
library(viridis)
library(stringr)
library(freesurferformats)

#font_import(pattern = 'Roboto')
#loadfonts(device = 'win')

# Import####
# reading in the raw data

studydir <- 'C:/Users/coreyar/Working_Directory_Code/rstats/240104_Proj-NCC-I/'
setwd(studydir)
load('24-ncc_04_msns.Rdata')
indir <- paste0(studydir, 'input/')
labeldir <- paste0(studydir, 'input/fs-labels/')
outdir <- paste0(studydir, 'output/')
chartdir <- paste0(outdir, 'msn-charts/')
circdir <- paste0(outdir, 'msn-chords/')
braindir <- paste0(outdir, 'msn-brains/')
dir.create(indir, showWarnings = F)
dir.create(outdir, showWarnings = F)
dir.create(chartdir, showWarnings = F)
dir.create(circdir, showWarnings = F)
dir.create(braindir, showWarnings = F)
ptcvars <- read.csv(paste0(indir, 'participants.tsv'), sep = '\t', na.strings = "na")
opts.regions <- readLines(paste0(indir, 'conn/atlas.tsv'))
opts.files <- list.files(path = paste0(indir, 'fs/')
	, pattern = 'cort'
	, full.names = T
	)
opts.metrics <- list.files(path = paste0(indir, 'fs/')
	, pattern = 'cort'
	, full.names = F
	)
opts.metrics <- sub('.tsv', '', opts.metrics)
opts.metrics <- sub('cort_', '', opts.metrics)
opts.groups <- c('N-NCC', 'N-HC', 'HCP-HC')
opts.ptcs <- ptcvars$study_id
data.raw <- lapply(opts.files, read.csv, sep = '\t')
names(data.raw) <- opts.metrics

# Standardisation####
# i.e. the distribution is built from all the participant measurements in each
# metric-region pair

data.norm <- data.raw
for (i in 1:length(data.norm)){
	for (j in 1:length(data.norm[[i]])){
		data.norm[[i]][[j]] <- ((data.norm[[i]][[j]]
			- mean(data.norm[[i]][[j]]))/sd(data.norm[[i]][[j]])
			)
	}
}

# Collation####
# creating a combined data structure for each feature

temp.data <- data.norm[[1]]
names(temp.data) <- opts.regions
data.metrics <- apply(temp.data, 1, as.list)
names(data.metrics) <- opts.ptcs
for (i in 1:length(data.metrics)){
	for (j in 1:length(data.metrics[[i]])){
		data.metrics[[i]][[j]] <- c(data.norm[[1]][i, j]
			, data.norm[[2]][i, j]
			, data.norm[[3]][i, j]
			, data.norm[[4]][i, j]
			, data.norm[[5]][i, j]
			, data.norm[[6]][i, j]
			, data.norm[[7]][i, j]
			)
	}
}

# Corrplots####
# correlation plots are computed and printed as svgs

data.msn <- list()
for(i in 1:length(opts.ptcs)){
	data.msn[[i]] <- cor(as.data.frame(data.metrics[[i]])
		, method = 'pearson'
		, use = 'complete.obs'
		)
#	svg(paste0(chartdir, opts.ptcs[i], '.svg'))
#	corrplot(data.msn[[i]]
#		, method = 'color'
#		, order = 'original'
#		, tl.col = 'black'
#		, tl.srt = 90
#		, tl.cex = .25
#		, cl.pos = 'n'
#		, type = 'full'
#		, number.font = 'Roboto Light'
#		, family = 'Roboto Light'
#	)
#	dev.off()
}

# Grouping####
# msns are grouped based on clinical/demographic features, based on stats
# requirements
# N-NCC: NIMHANS recruited NCC patients
# N-HC: NIMAHSN recruited healthy controls
# HCP-HC: HCP acquired healthy controls
# HC: Combined healthy controls
# N-NCC-FS: NCC patients with a first acute seizure
# N-NCC-PS: NCC patients with a recorded history of seizures

data.msn.group <- split(data.msn, ptcvars$group)
names(data.msn.group) <- opts.groups
for (i in 1:length(data.msn.group)){
	data.msn.group[[i]] <- Reduce("+", data.msn.group[[i]]) /
		length(data.msn.group[[i]]
		)
}
temp <- split(data.msn, (ptcvars$group > 0))
data.msn.group[['HC']] <- Reduce("+", temp[[2]]) / length(temp[[2]])
temp <- split(data.msn, (ptcvars$first_sz))
data.msn.group[['N-NCC-FS']] <- Reduce("+", temp[[1]]) / length(temp[[1]])
data.msn.group[['N-NCC-PS']] <- Reduce("+", temp[[2]]) / length(temp[[2]])

#for(i in 1:length(data.msn.group)){
#	svg(paste0(chartdir,  names(data.msn.group)[i], '.svg'))
#	#png(paste0(chartdir,  names(data.msn.group)[i], '.png')
#	#	, height = 2100
#	#	, width = 2100
#	#	, units = 'px'
#	#	, res = 300
#	#	)
#	corrplot(data.msn.group[[i]]
#		, method = 'color'
#		, order = 'hclust'
#		, tl.col = 'black'
#		, tl.srt = 90
#		, tl.cex = .25
#		, cl.pos = 'n'
#		, type = 'full'
#		, number.font = 'Roboto Light'
#		, family = 'Roboto Light'
#	)
#	dev.off()
#}

# NBS####
# Network based statistics are run on the group designs
# The NBS are computed - * group + age + sex + ICV
# all: N-NCC vs N-HC vs HCP-HC
# hcc: N-NCC vs HC
# ncc: N-NCC-FS vs N-NCC-PS
# nim: N-NCC vs N-HC
# The MSNs are converted into a 3D array

temp <- data.msn
m <- nrow(temp[[1]])
n <- ncol(temp[[1]])
p <- length(temp)
temp <- unlist(temp)
temp_array <- array(temp, dim = c(m, n, p))
edge_mat.rel <- list()
nbs <- list()

temp <- temp_array
edge_mat.rel[['all']] <- array(0, dim(temp[,,1]))
#nbs[['all']] <- nbr_lm_aov(net = temp
#	, nnodes = 148
#	, idata = ptcvars
#	, mod = "~ group + age_at_scan + sex + brain_vol"
#	, thrP = 0.01
#	, thrT = NULL
#	, nperm = 1000
#	, cores = detectCores()
#)

# An alternative ptcvars is created for the combined control comparisons
temp <- temp_array
temp_ptcvars <- ptcvars
temp_ptcvars$group <- ptcvars$group > 0
edge_mat.rel[['hcc']] <- array(0, dim(temp[,,1]))
#nbs[['hcc']] <- nbr_lm(net = temp
#	, nnodes = 148
#	, idata = temp_ptcvars
#	, mod = "~ group + age_at_scan + sex + brain_vol"
#	, thrP = 0.01
#	, thrT = NULL
#	, nperm = 1000
#	, cores = detectCores()
#)

# An alternative array and ptcvars is created for the seizure comparisons
temp <- temp_array[,,c(ptcvars$group == 0 & is.na(ptcvars$first_sz) == F)]
temp_ptcvars <- ptcvars[c(ptcvars$group == 0 & is.na(ptcvars$first_sz) == F),]
edge_mat.rel[['ncc']] <- array(0, dim(temp[,,1]))
#nbs[['ncc']] <- nbr_lm(net = temp
#	, nnodes = 148
#	, idata = temp_ptcvars
#	, mod = "~ first_sz + age_at_scan + sex + brain_vol"
#	, thrP = 0.01
#	, thrT = NULL
#	, nperm = 1000
#	, cores = detectCores()
#)

# An alternative array and ptcvars is created for the NIMHANS comparisons
temp <- temp_array[,,c(ptcvars$group < 2)]
temp_ptcvars <- ptcvars[c(ptcvars$group < 2),]
edge_mat.rel[['nim']] <- array(0, dim(temp[,,1]))
#nbs[['nim']] <- nbr_lm(net = temp
#	, nnodes = 148
#	, idata = temp_ptcvars
#	, mod = "~ group + age_at_scan + sex + brain_vol"
#	, thrP = 0.01
#	, thrT = NULL
#	, nperm = 1000
#	, cores = detectCores()
#)

#save(list = c('nbs'), file = "24-ncc_04_nbs.Rdata")

# Edge matrices and plots####

edge_comps <- list('all' = 2, 'hcc' = 4, 'ncc' = 4, 'nim' = 2)
edge_compind <- list()
edge_mat.abs <- list()

for (i in c('all', 'hcc', 'ncc', 'nim')){
	colnames(edge_mat.rel[[i]]) <- opts.regions
	rownames(edge_mat.rel[[i]]) <- opts.regions
	edge_compind[[i]] <- nbs[[i]]$components[[1]][c(nbs[[i]]$components[[1]][, 4] == edge_comps[[i]]), ]
	edge_mat.rel[[i]][edge_compind[[i]][, 2:3]] <- edge_compind[[i]][, 5]
	edge_mat.abs[[i]] <- abs(edge_mat.rel[[i]])
	#svg(paste0(chartdir, 'msn-rel.', i, '.svg'))
	png(paste0(chartdir, 'msn-rel.', i, '.png'), width = 2100, height = 2100, units = 'px', res = 300)
	corrplot(edge_mat.rel[[i]]
		, method = 'color'
		, order = 'original'
		, tl.col = 'black'
		, tl.pos = 'lt'
		, tl.srt = 90
		, tl.cex = .25
		, cl.pos = 'n'
		, type = 'upper'
		, bg = NULL
		, addgrid.col = NULL
		, addCoef.col = NULL
		, diag = F
		, is.corr = F
		, family = 'Roboto Light'
	)
	dev.off()
}

 # Subnetworks####
# plotting subnetworks from the MSN analysis

# the subnetwork of interest (i.e. the primary component identified as different
# between the levels of the variable of interest) is isolated from the MSN
# output

# the different data needed to create a Circos plot are extracted and stored in
# a list
subnetwork <- list()
for (i in c('all', 'hcc', 'ncc', 'nim')){
	# the required column and row names are indexed
	subnetwork[[i]]$row_ids <- opts.regions[c(edge_compind[[i]][, 2])]
	subnetwork[[i]]$col_ids <- opts.regions[c(edge_compind[[i]][, 3])]
	# the edge strengths are extracted
	subnetwork[[i]]$edge_strn <- edge_compind[[i]][, 5]
	# column ids, row ids, and edge strengths are stored together
	subnetwork[[i]]$sn <- cbind(row = subnetwork[[i]]$row_ids
		, col = subnetwork[[i]]$col_ids
		, strn = subnetwork[[i]]$edge_strn
		)
	# a list of the unique regions involved in the subnetwork is created
	subnetwork[[i]]$unique <- unique(c(subnetwork[[i]]$col_ids, subnetwork[[i]]$row_ids))
	subnetwork[[i]]$row_strns <- rowSums(edge_mat.abs[[i]])
	names(subnetwork[[i]]$row_strns) <- opts.regions
	subnetwork[[i]]$row_strns_ind <- subnetwork[[i]]$row_strns[subnetwork[[i]]$row_strns > 0]
	subnetwork[[i]]$row_strns_thr <- subnetwork[[i]]$row_strns[subnetwork[[i]]$row_strns
		> quantile(subnetwork[[i]]$row_strns, probs = 0.98)]
	subnetwork[[i]]$col_strns <- colSums(edge_mat.abs[[i]])
	names(subnetwork[[i]]$col_strns) <- opts.regions
	subnetwork[[i]]$col_strns_ind <- subnetwork[[i]]$col_strns[subnetwork[[i]]$col_strns > 0]
	subnetwork[[i]]$col_strns_thr <- subnetwork[[i]]$col_strns[subnetwork[[i]]$col_strns
		> quantile(subnetwork[[i]]$col_strns, probs = 0.98)]
	subnetwork[[i]]$strn_thr <- unique(c(names(subnetwork[[i]]$row_strns_thr)
		, names(subnetwork[[i]]$col_strns_thr))
		)
	for (j in opts.regions) {
		subnetwork[[i]]$roi_strns[j] <- sum(edge_mat.abs[[i]][,j]) + sum(edge_mat.abs[[i]][j,])
	}
	subnetwork[[i]]$roi_strns_thr <- subnetwork[[i]]$roi_strns[subnetwork[[i]]$roi_strns
		> quantile(subnetwork[[i]]$roi_strns, probs = 0.85)]
	subnetwork[[i]]$roi_strn_thr <- names(subnetwork[[i]]$roi_strns_thr)
	temp.mat <- edge_mat.abs[[i]]
	temp.thr <- quantile(temp.mat[temp.mat > 0], probs = 0.85)
	temp.mat[temp.mat <= temp.thr] <- 0
	temp.rowind <- apply(temp.mat, 1, function(x) !all(x == 0))
	temp.colind <- apply(temp.mat, 2, function(x) !all(x == 0))
	subnetwork[[i]]$sparse.em <- edge_mat.abs[[i]][temp.rowind, temp.colind]
	temp.regind <- unique(c(colnames(subnetwork[[i]]$sparse.em), rownames(subnetwork[[i]]$sparse.em)))
	subnetwork[[i]]$sparse.names <- opts.regions[opts.regions %in% temp.regind]
}

# Chord diagrams and Brain parcellations####
# Chord diagrams are computed to show adjacency
# NBS-derived subnetworks are mapped onto wholebrain parcellations
# Raw .annot labels are imported, and will have their values changed according
# to the NBS derived subnetworks
opts.labels <- list.files(path = paste0(labeldir)
	, pattern = 'annot'
	, full.names = T
)

for (i in c('all', 'hcc', 'ncc', 'nim')){
	chord_mat <- subnetwork[[i]]$sparse.em
	temp.colour_num <- length(subnetwork[[i]]$sparse.names)
	temp.colours <- viridis(temp.colour_num, direction = -1)

	svg(paste0(circdir, 'subnetwork-', i, '.svg'))
	#png(paste0(circdir, 'subnetwork-', i, '.png')
	#	, height = 1600
	#	, width = 2100
	#	, units = 'px'
	#	, res = 300
	#	)

	circos.par(canvas.xlim = c(-1.75, 1)
		, canvas.ylim = c(0, 0)
		, start.degree = 90
	)
	#The grid of the chord diagram is plotted first
	cD <- chordDiagram(abs(chord_mat)
		, annotationTrack = "grid"
		, grid.border = 1
		, transparency = 0.5
		, grid.col = temp.colours
		, order = subnetwork[[i]]$sparse.names
	)
	#The labels are rotated 90 degrees, and plotted separately
	for(j in get.all.sector.index()) {
		if (j %in% subnetwork[[i]]$strn_thr){
			xlim = get.cell.meta.data("xlim"
				, sector.index = j
				, track.index = 1
			)
			ylim = get.cell.meta.data("ylim"
				, sector.index = j
				, track.index = 1
			)
			circos.text(mean(xlim)
				, 2
				, "*"
				, sector.index = j
				, track.index = 1
				, facing = "downward"
				, cex = 2
				, adj = c(.5, .75)
				, niceFacing = TRUE
			)
		}
	}
	rois_sectors <- get.all.sector.index()
	circos.clear()
	#The legend is created, and applied to the finished chord diagram
	#Any region with a large enough adjacency value is marked with an asterisk

	for (j in opts.regions) {
		if (j %in% subnetwork[[i]]$strn_thr){
			rois_sectors[match(j, rois_sectors)] <- paste(j, "*", sep = " ")
		}
	}
	op <- par(family = 'Roboto Light')
	rois_strings <- str_replace_all(rois_sectors, "[_]", " ")
	rois_strings <- tools::toTitleCase(rois_strings)
	legend("left"
		, pch = 19
		, legend = rois_strings
		, col = temp.colours
		, bty = "n"
		, cex = 0.5
		, pt.cex = 1
		, border = "black"
	)
	par(op)
	dev.off()

	temp.lh <- read.fs.annot(opts.labels[1])
	temp.lh$colortable_df$struct_name[c(2:42, 44:76)] <- opts.regions[c(1:41, 42:74)]
	temp.rh <- read.fs.annot(opts.labels[2])
	temp.rh$colortable_df$struct_name[c(2:42, 44:76)] <- opts.regions[c(75:115, 116:148)]
	temp.lh.key <- cbind(temp.lh$colortable_df$struct_name
		, temp.lh$colortable_df$code, 0)
	temp.rh.key <- cbind(temp.rh$colortable_df$struct_name
		, temp.rh$colortable_df$code, 0)
	temp.lut <- subnetwork[[i]]$roi_strns
	temp.lut[!(temp.lut %in% subnetwork[[i]]$sparse.names)] <- 0
	temp.colourvals <- matrix(col2rgb('lightgrey'), nrow = length(opts.regions)
		, ncol = 3, dimnames = list(opts.regions, c('R', 'G', 'B')))
	temp.colmap <- cbind(subnetwork[[i]]$sparse.names, temp.colours)
	for (j in 1:nrow(temp.colmap)){
		k <- temp.colmap[j, 1]
		temp.colourvals[k, ] <- t(col2rgb(temp.colmap[j, 2]))
	}
	temp.colourlist <- list(names = names(temp.lut)
		, codes = ((temp.colourvals[,3] * 256*256) + (temp.colourvals[,2] * 256) + (temp.colourvals[,1]))
		)
	temp.na <- t(col2rgb('lightgrey'))
	temp.na.val <- ((temp.na[,3] * 256*256) + (temp.na[,2] * 256) + (temp.na[,1]))
	for (j in 1:nrow(temp.lh.key)){
		k <- temp.lh.key[j, 1]
		if (k %in% temp.colourlist$names){
			temp.lh.key[j, 3] <- temp.colourlist$codes[temp.colourlist$names == k]
		} else {
			temp.lh.key[j, 3] <- temp.na.val
		}
	}
	for (j in 1:nrow(temp.rh.key)){
		k <- temp.rh.key[j,1]
		if (k %in% temp.colourlist$names){
			temp.rh.key[j, 3] <- temp.colourlist$codes[temp.colourlist$names == k]
		} else {
			temp.rh.key[j, 3] <- temp.na.val
		}
	}
	for (j in 1:nrow(temp.lh.key)){
		temp.lh$label_codes[temp.lh$label_codes == temp.lh.key[j,2]] <- temp.lh.key[j,3]
		temp.rh$label_codes[temp.rh$label_codes == temp.rh.key[j,2]] <- temp.rh.key[j,3]
	}
	write.fs.annot(paste0(braindir, i, '.lh.annot'), fs.annot = temp.lh)
	write.fs.annot(paste0(braindir, i, '.rh.annot'), fs.annot = temp.rh)
}

#rm(list = ls()[grepl('temp', ls())], i, j, k, xlim, ylim, rois_sectors, op, cD, chord_mat, m, n, p, rois_strings)
#save(list = ls(), file = '24-ncc_04_msns.Rdata')
