# preamble####
rm(list = ls())
cat("\014")

# packages and aliases

library(extrafont)
library(R.matlab)
library(abind)
library(corrplot)
library(psych)
library(parallel)
library(NBR)
#library(brainconn)
library(NetworkToolbox)
library(igraph)
library(circlize)
library(viridis)
library(stringr)
library(freesurferformats)

#font_import(pattern = 'Roboto')
#loadfonts(device = 'win')

studydir <- '~/Documents/WD_Code/rstats/240104_Proj-NCC-I/'
setwd(studydir)
indir <- paste0(studydir, 'input/')
funcdir <- paste0(indir, 'func/')
netdir <- paste0(indir, 'nets/')
outdir <- paste0(studydir, 'output/nets/')
labeldir <- paste0(studydir, 'input/fs-labels/')
dir.create(outdir, showWarnings = F)

# data import and management####
# the participant data is read in as a table

#tab <- list()
#tab$ptcs <- as.data.frame(read.delim(paste0(indir, '/participants.tsv')
#	, header = T
#	, sep = "\t"
#	, dec = '.'
#	, numerals = 'no.loss'
#	, na.strings = 'na'
#	, stringsAsFactors = F
#	)
#)
#tab$ncc <- tab$ptcs[tab$ptcs$group != 2,]
#exc <- tab$ncc$study_id %in% c('sub-001', 'sub-005', 'sub-906', 'sub-908')
#tab$ncc <- tab$ncc[!exc,]
#tab$regions <- readLines(paste0(funcdir, 'destrieux.txt'))
#tab$coords <- read.delim(paste0(funcdir, 'coordinates.tsv')
#	, header = F
#	, sep ='\t'
#)
#for (i in 1:ncol(tab$coords)){
#	tab$coords[,i] <- as.integer(tab$coords[,i])
#}
#tab$destrieux <- cbind(tab$regions, tab$coords, 1)
#colnames(tab$destrieux) <- c('ROI.Name', 'x.mni', 'y.mni', 'z.mni', 'network')
#
#save(tab, file = paste0(outdir, 'tab.rdata'))

# Adjacency matrices are imported and extracted into a 3d array

#funclist <- list.files(paste0(netdir, 'func/'), full.names = T)
#mats <- lapply(funclist, readMat)
#extracted_items <- lapply(mats, '[', "Z")
#func <- simplify2array(extracted_items)
#func <- simplify2array(func)
#func <- tanh(func)
#dimnames(func) <- list(x = tab$regions, y = tab$regions, z = tab$ncc$study_id)
#for (i in 1:dim(func)[3]){
#	func[,,i] <- tanh(func[,,i])
#}
#save(func, file = paste0(outdir, 'func.rdata'))

#difflist <- list.files(paste0(netdir, 'diff/'), full.names = T)
#mats <- lapply(difflist, read.csv, header = F)
#for (i in 1:length(mats)){
#	mats[[i]] <- as.matrix(mats[[i]])
#}
#diff <- simplify2array(mats)
#dimnames(diff) <- list(x = tab$regions, y = tab$regions, z = tab$ncc$study_id)
#save(diff, file = paste0(outdir, 'diff.rdata'))

load(paste0(outdir, 'tab.rdata'))
load(paste0(outdir, 'func.rdata'))
load(paste0(outdir, 'diff.rdata'))

# plotting - individuals ####

#for(i in 1:length(tab$ncc$study_id)){
#	temp <- func[,,i]
#	temp[is.nan(temp)] <- 0
#	#temp.thr <- quantile(temp[temp != 0], probs = 0.90, na.rm = T)
#	#temp[temp < temp.thr] <- 0
#	#temp[temp >= temp.thr] <- 1
#	svg(paste0(outdir, 'ind_',  tab$ncc$study_id[i], '.svg'))
#	#png(paste0(outdir, 'ind_', tab$ncc$study_id[i], '.png'), width = 2100, height = 2100, units = 'px', res = 300)
#	corrplot(temp
#		, method = 'square'
#		, order = 'original'
#		, tl.col = 'black'
#		, tl.pos = 'lt'
#		, tl.srt = 90
#		, tl.cex = .25
#		, cl.pos = 'n'
#		, type = 'upper'
#		, bg = NULL
#		, addgrid.col = NULL
#		, addCoef.col = NULL
#		, diag = T
#		, family = 'Roboto Light'
#	)
#	temp <- diff[,,i]
#	temp[is.nan(temp)] <- 0
#	temp <- log(temp)
#	temp[is.infinite(temp)] <- 0
#	#temp.thr <- quantile(temp[temp != 0], probs = 0.90, na.rm = T)
#	#temp[temp < temp.thr] <- 0
#	#temp[temp >= temp.thr] <- 1
#	corrplot(temp
#		, method = 'square'
#		, order = 'original'
#		, tl.col = 'black'
#		, tl.pos = 'n'
#		, tl.srt = 90
#		, tl.cex = .25
#		, cl.pos = 'n'
#		, type = 'lower'
#		, bg = NULL
#		, addgrid.col = NULL
#		, addCoef.col = NULL
#		, diag = T
#		, is.corr = F
#		, add = T
#		, family = 'Roboto Light'
#	)
#	dev.off()
#}

# NBS - func####
# Network based statistics are run on the group designs
# The NBS are computed - * group + age + sex + ICV
# all: N-NCC vs HC
# fsz: N-NCC-FS vs N-NCC-PS
# rec: N-NCC-SF vs N-NCC-SR

edge_mat.rel <- list()
#nbs <- list()

temp <- func
#temp.ptcvars <- tab$ncc
edge_mat.rel[['func.all']] <- array(0, dim(temp[,,1]))
#nbs[['func.all']] <- nbr_lm(net = temp
#	, nnodes = 164
#	, idata = temp.ptcvars
#	, mod = "~ group + age_at_scan + sex + brain_vol"
#	, thrP = 0.01
#	, thrT = NULL
#	, nperm = 1000
#	, cores = detectCores()
#)

# An alternative array and ptcvars is created for the seizure comparisons
#temp <- func[,, is.na(tab$ncc$sz_rec) == F]
#temp.ptcvars <- tab$ncc[is.na(tab$ncc$sz_rec) == F,]
edge_mat.rel[['func.rec']] <- array(0, dim(temp[,,1]))
#nbs[['func.rec']] <- nbr_lm(net = temp
#	, nnodes = 164
#	, idata = temp.ptcvars
#	, mod = "~ sz_rec + age_at_scan + sex + brain_vol"
#	, thrP = 0.01
#	, thrT = NULL
#	, nperm = 1000
#	, cores = detectCores()
#)

# An alternative array and ptcvars is created for the NIMHANS comparisons
#temp <- func[,, is.na(tab$ncc$first_sz) == F]
#temp.ptcvars <- tab$ncc[is.na(tab$ncc$first_sz) == F,]
edge_mat.rel[['func.fsz']] <- array(0, dim(temp[,,1]))
#nbs[['func.fsz']] <- nbr_lm(net = temp
#	, nnodes = 164
#	, idata = temp.ptcvars
#	, mod = "~ first_sz + age_at_scan + sex + brain_vol"
#	, thrP = 0.01
#	, thrT = NULL
#	, nperm = 1000
#	, cores = detectCores()
#)

# NBS - diff####
# Network based statistics are run on the group designs
# The NBS are computed - * group + age + sex + ICV
# all: N-NCC vs HC
# fsz: N-NCC-FS vs N-NCC-PS
# rec: N-NCC-SF vs N-NCC-SR
# The MSNs are converted into a 3D array

#temp <- diff
#temp.ptcvars <- tab$ncc
edge_mat.rel[['diff.all']] <- array(0, dim(temp[,,1]))
#nbs[['diff.all']] <- nbr_lm(net = temp
#	, nnodes = 164
#	, idata = temp.ptcvars
#	, mod = "~ group + age_at_scan + sex + brain_vol"
#	, thrP = 0.01
#	, thrT = NULL
#	, nperm = 1000
#	, cores = detectCores()
#)

## An alternative array and ptcvars is created for the seizure comparisons
#temp <- diff[,, is.na(tab$ncc$sz_rec) == F]
#temp.ptcvars <- tab$ncc[is.na(tab$ncc$sz_rec) == F,]
edge_mat.rel[['diff.rec']] <- array(0, dim(temp[,,1]))
#nbs[['diff.rec']] <- nbr_lm(net = temp
#	, nnodes = 164
#	, idata = temp.ptcvars
#	, mod = "~ sz_rec + age_at_scan + sex + brain_vol"
#	, thrP = 0.01
#	, thrT = NULL
#	, nperm = 1000
#	, cores = detectCores()
#)

## An alternative array and ptcvars is created for the NIMHANS comparisons
#temp <- diff[,, is.na(tab$ncc$first_sz) == F]
#temp.ptcvars <- tab$ncc[is.na(tab$ncc$first_sz) == F,]
edge_mat.rel[['diff.fsz']] <- array(0, dim(temp[,,1]))
#nbs[['diff.fsz']] <- nbr_lm(net = temp
#	, nnodes = 164
#	, idata = temp.ptcvars
#	, mod = "~ first_sz + age_at_scan + sex + brain_vol"
#	, thrP = 0.01
#	, thrT = NULL
#	, nperm = 1000
#	, cores = detectCores()
#)

#save(nbs, file = paste0(outdir, 'nbs.rdata'))

load(paste0(outdir, 'nbs.rdata'))

# plotting - groups ####

func.group <- list()
func.group$ncc <- apply(func[,,tab$ncc$group == 0], MARGIN = c(1, 2), FUN = mean)
func.group$hc <- apply(func[,,tab$ncc$group == 1], MARGIN = c(1, 2), FUN = mean)
func.group$ps <- apply(func[,,tab$ncc$first_sz == 0 & is.na(tab$ncc$first_sz) == F], MARGIN = c(1, 2), FUN = mean)
func.group$fs <- apply(func[,,tab$ncc$first_sz == 1 & is.na(tab$ncc$first_sz) == F], MARGIN = c(1, 2), FUN = mean)
func.group$sf <- apply(func[,,tab$ncc$sz_rec == 0 & is.na(tab$ncc$sz_rec) == F], MARGIN = c(1, 2), FUN = mean)
func.group$sr <- apply(func[,,tab$ncc$sz_rec == 1 & is.na(tab$ncc$sz_rec) == F], MARGIN = c(1, 2), FUN = mean)

diff.group <- list()
diff.group$ncc <- apply(diff[,,tab$ncc$group == 0], MARGIN = c(1, 2), FUN = mean)
diff.group$hc <- apply(diff[,,tab$ncc$group == 1], MARGIN = c(1, 2), FUN = mean)
diff.group$ps <- apply(diff[,,tab$ncc$first_sz == 0 & is.na(tab$ncc$first_sz) == F], MARGIN = c(1, 2), FUN = mean)
diff.group$fs <- apply(diff[,,tab$ncc$first_sz == 1 & is.na(tab$ncc$first_sz) == F], MARGIN = c(1, 2), FUN = mean)
diff.group$sf <- apply(diff[,,tab$ncc$sz_rec == 0 & is.na(tab$ncc$sz_rec) == F], MARGIN = c(1, 2), FUN = mean)
diff.group$sr <- apply(diff[,,tab$ncc$sz_rec == 1 & is.na(tab$ncc$sz_rec) == F], MARGIN = c(1, 2), FUN = mean)

#save(func.group, file = paste0(outdir, 'funcgroup.rdata'))
#save(diff.group, file = paste0(outdir, 'diffgroup.rdata'))

#for(i in 1:length(func.group)){
#	temp <- func.group[[i]]
#	temp[is.nan(temp)] <- 0
#	temp.thr <- quantile(temp[temp != 0], probs = 0.85, na.rm = T)
#	temp[temp < temp.thr] <- 0
#	temp[temp >= temp.thr] <- 1
#	svg(paste0(outdir, 'group_', names(func.group)[i], '.svg'))
#	#png(paste0(outdir, 'group_', names(func.group)[i], '.png'), width = 2100, height = 2100, units = 'px', res = 300)
#	corrplot(temp
#		, method = 'square'
#		, order = 'original'
#		, tl.col = 'black'
#		, tl.pos = 'lt'
#		, tl.srt = 90
#		, tl.cex = .25
#		, cl.pos = 'n'
#		, type = 'upper'
#		, bg = NULL
#		, addgrid.col = NULL
#		, addCoef.col = NULL
#		, diag = T
#		, family = 'Roboto Light'
#	)
#	temp <- diff.group[[i]]
#	temp[is.nan(temp)] <- 0
#	temp <- log(temp)
#	temp[is.infinite(temp)] <- 0
#	temp.thr <- quantile(temp[temp != 0], probs = 0.85, na.rm = T)
#	temp[temp < temp.thr] <- 0
#	temp[temp >= temp.thr] <- 1
#	corrplot(temp
#		, method = 'square'
#		, order = 'original'
#		, tl.col = 'black'
#		, tl.pos = 'n'
#		, tl.srt = 90
#		, tl.cex = .25
#		, cl.pos = 'n'
#		, type = 'lower'
#		, bg = NULL
#		, addgrid.col = NULL
#		, addCoef.col = NULL
#		, diag = T
#		, is.corr = F
#		, add = T
#		, family = 'Roboto Light'
#	)
#	dev.off()
#}

#for(i in 1:length(func.group)){
#	temp <- func.group[[i]]
#	temp[is.nan(temp)] <- 0
#	temp.thr <- quantile(temp[temp != 0], probs = 0.98, na.rm = T)
#	temp[temp < temp.thr] <- 0
#	temp[temp >= temp.thr] <- 1
#	svg(paste0(outdir, 'group-thr_', names(func.group)[i], '.svg'))
#	#png(paste0(outdir, 'group-thr_', names(func.group)[i], '.png'), width = 2100, height = 2100, units = 'px', res = 300)
#	corrplot(temp
#		, method = 'square'
#		, order = 'original'
#		, tl.col = 'black'
#		, tl.pos = 'lt'
#		, tl.srt = 90
#		, tl.cex = .25
#		, cl.pos = 'n'
#		, type = 'upper'
#		, bg = NULL
#		, addgrid.col = NULL
#		, addCoef.col = NULL
#		, diag = T
#		, family = 'Roboto Light'
#	)
#	temp <- diff.group[[i]]
#	temp[is.nan(temp)] <- 0
#	temp <- log(temp)
#	temp[is.infinite(temp)] <- 0
#	temp.thr <- quantile(temp[temp != 0], probs = 0.98, na.rm = T)
#	temp[temp < temp.thr] <- 0
#	temp[temp >= temp.thr] <- 1
#	corrplot(temp
#		, method = 'square'
#		, order = 'original'
#		, tl.col = 'black'
#		, tl.pos = 'n'
#		, tl.srt = 90
#		, tl.cex = .25
#		, cl.pos = 'n'
#		, type = 'lower'
#		, bg = NULL
#		, addgrid.col = NULL
#		, addCoef.col = NULL
#		, diag = T
#		, is.corr = F
#		, add = T
#		, family = 'Roboto Light'
#	)
#	dev.off()
#}

# plotting edge matrices####

edge_comps <- list('func.all' = 2
	, 'func.fsz' = 1
	, 'func.rec' = 1
	, 'diff.all' = 2
	, 'diff.fsz' = 1
	, 'diff.rec' = 2
	)
edge_compind <- list()
edge_mat.abs <- list()

for (i in c('diff.all', 'diff.fsz', 'diff.rec', 'func.all', 'func.fsz', 'func.rec')){
	edge_compind[[i]] <- nbs[[i]]$components[[1]][c(nbs[[i]]$components[[1]][, 4] == edge_comps[[i]]), ]
	edge_mat.rel[[i]][edge_compind[[i]][, 2:3]] <- edge_compind[[i]][, 5]
	colnames(edge_mat.rel[[i]]) <- tab$regions
	rownames(edge_mat.rel[[i]]) <- tab$regions
#	svg(paste0(outdir, 'nbs.', i, '.svg'))
#	#png(paste0(outdir, 'nbs.', i, '.png'), width = 2100, height = 2100, units = 'px', res = 300)
#	temp <- edge_mat.rel[[i]]
#	corrplot(temp
#		, method = 'square'
#		, order = 'original'
#		, tl.col = 'black'
#		, tl.pos = 'lt'
#		, tl.srt = 90
#		, tl.cex = .25
#		, cl.pos = 'n'
#		, type = 'upper'
#		, bg = NULL
#		, addgrid.col = NULL
#		, addCoef.col = NULL
#		, diag = T
#		, is.corr = F
#		, family = 'Roboto Light'
#	)
#	edge_mat.abs[[i]] <- abs(edge_mat.rel[[i]])
#	edge_mat.abs[[i]][edge_mat.abs[[i]] != 0] <- 1
#	temp <- t(edge_mat.abs[[i]])
#	corrplot(temp
#		, method = 'square'
#		, order = 'original'
#		, tl.col = 'black'
#		, tl.pos = 'n'
#		, tl.srt = 90
#		, tl.cex = .25
#		, cl.pos = 'n'
#		, type = 'lower'
#		, bg = NULL
#		, addgrid.col = NULL
#		, addCoef.col = NULL
#		, diag = T
#		, is.corr = F
#		, add = T
#		, family = 'Roboto Light'
#	)
#	dev.off()
}

#save(edge_mat.rel, file = paste0(outdir, 'edgemat.rdata'))

# generating node files####

for (i in c('diff.all', 'diff.fsz', 'diff.rec', 'func.all', 'func.fsz', 'func.rec')){
	# threshold at the matrix level to remove noisy connections
	temp.mat <- edge_mat.rel[[i]]
	temp.matthr <- abs(temp.mat)
	temp.thr <- quantile(temp.matthr[temp.matthr != 0], probs = 0.85, na.rm = T)
	temp.matthr[temp.matthr <= temp.thr] <- 0
	temp.row <- rowSums(temp.matthr)
	temp.col <- colSums(temp.matthr)
	temp.vec <- temp.row + temp.col
	temp.rowthr <- quantile(temp.row[temp.row != 0], probs = 0.98, na.rm = T)
	temp.colthr <- quantile(temp.col[temp.col != 0], probs = 0.98, na.rm = T)
	temp.hub <- unique(c(names(temp.col[temp.col > temp.colthr]), names(temp.row[temp.row > temp.rowthr])))
	names(temp.vec) <- tab$regions
	temp.node <- temp.vec[temp.vec != 0]
	edge <- temp.mat[names(temp.node), names(temp.node)]
	node <- cbind(tab$coords[tab$regions %in% names(temp.node),], temp.node, 1, names(temp.node))
	write.table(node, paste0(outdir, 'subnetwork-', i, '.node'), col.names = F, row.names = F, quote = F, sep = '\t')
	write.table(edge, paste0(outdir, 'subnetwork-', i, '.edge'), col.names = F, row.names = F, quote = F, sep = '\t')

	chord_mat <- edge
	temp.colour_num <- length(names(temp.node))
	temp.colours <- viridis(temp.colour_num, direction = -1)

	svg(paste0(outdir, 'subnetwork-', i, '.svg'))
	#png(paste0(outdir, 'subnetwork-', i, '.png')
	#	, height = 2500
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
		, order = names(temp.node)
	)
	#The labels are rotated 90 degrees, and plotted separately
	for(j in get.all.sector.index()) {
		if (j %in% temp.hub){
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

	for (j in tab$regions) {
		if (j %in% temp.hub){
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
}

rm(list = c(ls(pattern = 'temp.'), funclist, difflist, mats, i, j))
