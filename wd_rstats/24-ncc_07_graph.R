# preamble####
rm(list = ls())
cat("\014")

# packages and aliases

library(igraph)

#font_import(pattern = 'Roboto')
#loadfonts(device = 'win')

studydir <- 'C:/Users/coreyar/Working_Directory_Code/rstats/240104_Proj-NCC-I/'
setwd(studydir)
indir <- paste0(studydir, 'input/')
funcdir <- paste0(indir, 'func/')
netdir <- paste0(indir, 'nets/')
outdir <- paste0(studydir, 'output/nets/')
labeldir <- paste0(studydir, 'input/fs-labels/')
dir.create(outdir, showWarnings = F)
opt.tdensity <- 0.4

load(paste0(outdir, 'tab.rdata'))
load(paste0(outdir, 'func.rdata'))
load(paste0(outdir, 'funcgroup.rdata'))
load(paste0(outdir, 'diff.rdata'))
load(paste0(outdir, 'diffgroup.rdata'))
load(paste0(outdir, 'nbs.rdata'))

#gt_local <- list()
#gt_global <- list()

#for (i in 1: dim(func)[3]){
#	# the functional adjacency matrix is turned into an undirected, weighted
#	# graph
#	gt_local[[tab$ncc$study_id[i]]] <- list()
#	temp <- abs(func[,,i])
#	temp[is.nan(temp)] <- 0
#	gt_local[[i]][['f.graph']] <- graph_from_adjacency_matrix(temp
#		, mode = 'undirected'
#		, weighted = T
#		, diag = F
#	)
#	# the graph is thresholded to the desired edge density (0.4) by removing the
#	# weakest edges
#	temp.nodes <- vcount(gt_local[[i]][['f.graph']])
#	temp.target <- round(opt.tdensity * temp.nodes * (temp.nodes - 1) / 2)
#	gt_local[[i]][['f.graph']] <- delete_edges(
#		gt_local[[i]][['f.graph']],
#		E(gt_local[[i]][['f.graph']])[order(weight)[seq_len(ecount(gt_local[[i]][['f.graph']]) - temp.target)]]
#	)
#
#	# the diffusion adjacency matrix is turned into an undirected, weighted
#	# graph
#	temp <- diff[,,i]
#	temp[is.nan(temp)] <- 0
#	gt_local[[i]][['d.graph']] <- graph_from_adjacency_matrix(temp
#		, mode = 'undirected'
#		, weighted = T
#		, diag = F
#	)
#	# the graph is thresholded to the desired edge density (0.4) by removing the
#	# weakest edges
#	temp.nodes <- vcount(gt_local[[i]][['d.graph']])
#	temp.target <- round(opt.tdensity * temp.nodes * (temp.nodes - 1) / 2)
#	gt_local[[i]][['d.graph']] <- delete_edges(
#		gt_local[[i]][['d.graph']],
#		E(gt_local[[i]][['d.graph']])[order(weight)[seq_len(ecount(gt_local[[i]][['d.graph']]) - temp.target)]]
#	)
#
#	# local betweeness centrality is computed for the graphs
#	gt_local[[i]][['f.between']] <- betweenness(gt_local[[i]][['f.graph']]
#		, directed = F
#		, normalized = T
#	)
#	gt_local[[i]][['d.between']] <- betweenness(gt_local[[i]][['d.graph']]
#		, directed = F
#		, normalized = T
#	)
#	# local transitivity is computed for the graphs
#	gt_local[[i]][['f.clust']] <- transitivity(gt_local[[i]][['f.graph']]
#		, type = 'barrat'
#		, isolates = 'zero'
#	)
#	gt_local[[i]][['d.clust']] <- transitivity(gt_local[[i]][['d.graph']]
#		, type = 'barrat'
#		, isolates = 'zero'
#	)
#	# local efficiency is computed for the graphs
#	gt_local[[i]][['f.eff']] <- local_efficiency(gt_local[[i]][['f.graph']]
#		, mode = 'all'
#	)
#	gt_local[[i]][['d.eff']] <- local_efficiency(gt_local[[i]][['d.graph']]
#		, mode = 'all'
#	)
#	# shortest paths are computed for the graphs
#	gt_local[[i]][['f.short']] <- distances(gt_local[[i]][['f.graph']]
#		, mode = 'all'
#		, weights = NULL
#	)
#	gt_local[[i]][['d.short']] <- distances(gt_local[[i]][['d.graph']]
#		, mode = 'all'
#		, weights = NULL
#	)
#}
#save(gt_local, file = paste0(outdir, 'gtlocal.rdata'))

#for (i in names(gt_local)){
#	gt_global[[i]] <- list()
#	gt_global[[i]][['f.between']] <- betweenness(gt_local[[i]][['f.graph']]
#		, directed = F
#		, normalized = T
#	)
#	gt_global[[i]][['d.between']] <- betweenness(gt_local[[i]][['d.graph']]
#		, directed = F
#		, normalized = T
#	)
#	gt_global[[i]][['f.clust']] <- transitivity(gt_local[[i]][['f.graph']]
#		, type = 'global'
#		, isolates = 'zero'
#	)
#	gt_global[[i]][['d.clust']] <- transitivity(gt_local[[i]][['d.graph']]
#		, type = 'global'
#		, isolates = 'zero'
#	)
#	gt_global[[i]][['f.eff']] <- global_efficiency(gt_local[[i]][['f.graph']]
#	)
#	gt_global[[i]][['d.eff']] <- global_efficiency(gt_local[[i]][['d.graph']]
#	)
#	gt_global[[i]][['f.short']] <- mean_distance(gt_local[[i]][['f.graph']]
#		, directed = F
#		, weights = NULL
#	)
#	gt_global[[i]][['d.short']] <- mean_distance(gt_local[[i]][['d.graph']]
#		, directed = F
#		, weights = NULL
#	)
#}
#save(gt_global, file = paste0(outdir, 'gtglobal.rdata'))

load(paste0(outdir, 'gtlocal.rdata'))
load(paste0(outdir, 'gtglobal.rdata'))

temp.indices <- list(ncc = tab$ncc$group == 0
	, hc = tab$ncc$group == 1
	, ps = tab$ncc$first_sz == 0 & is.na(tab$ncc$first_sz) == F
	, fs = tab$ncc$first_sz == 1 & is.na(tab$ncc$first_sz) == F
	, sf = tab$ncc$sz_rec == 0 & is.na(tab$ncc$sz_rec) == F
	, sr = tab$ncc$sz_rec == 1 & is.na(tab$ncc$sz_rec) == F
)

gt_group <- list()

# group average measures
for (i in names(temp.indices)){
	temp.subset <- gt_global[temp.indices[[i]]]
	for (j in names(temp.subset[[1]])[1:8]){
		gt_group[[i]][[j]] <- mean(sapply(temp.subset, `[[`, j))
		k <- paste0(j, '_sd')
		gt_group[[i]][[k]] <- sd(sapply(temp.subset, `[[`, j))
	}
	for (j in names(temp.subset[[1]])[1:2]){
		sub_elements <- lapply(temp.subset, `[[`, j)
		temp <- Reduce(`+`, sub_elements)/length(sub_elements)
		gt_group[[i]][[j]] <- mean(temp[temp != 0])
		k <- paste0(j, '_dist')
		gt_group[[i]][[k]] <- density(simplify2array(sub_elements))
	}
}
gt_group <- simplify2array(gt_group)

gt_t <- list()

for (i in c(1, 3, 5)){
	temp.x <- gt_local[temp.indices[[i]]]
	temp.y <- gt_local[temp.indices[[i+1]]]
	for (j in names(temp.x[[1]])[3:6]){
		x <- sapply(temp.x, `[[`, j)
		y <- sapply(temp.y, `[[`, j)
		gt_t[[names(temp.indices)[i]]][[j]] <- t.test(x, y)
	}
	temp.x <- gt_global[temp.indices[[i]]]
	temp.y <- gt_global[temp.indices[[i+1]]]
	for (j in names(temp.x[[1]])[5:8]){
		x <- sapply(temp.x, `[[`, j)
		y <- sapply(temp.y, `[[`, j)
		gt_t[[names(temp.indices)[i]]][[j]] <- t.test(x, y)
	}
}

gt_hubs <- list()

for (i in names(gt_local)){
	gt_hubs[[i]] <- list()
	gt_hubs[[i]][['f.hubs']] <- hub_score(gt_local[[i]][['f.graph']]
		, scale = T
	)
	gt_hubs[[i]][['d.hubs']] <- hub_score(gt_local[[i]][['d.graph']]
		, scale = T
	)
}

# betweenness-based hubs are calculated

temp.nccvec <- tab$ncc$study_id[tab$ncc$group == 0]
temp.hcvec <- tab$ncc$study_id[tab$ncc$group == 1]

mat.bfhubs <- matrix(NA, nrow = 5, ncol = 27, dimnames = list(c(1, 2, 3, 4, 5), temp.nccvec))
mat.bdhubs <- matrix(NA, nrow = 5, ncol = 27, dimnames = list(c(1, 2, 3, 4, 5), temp.nccvec))
for (i in 1:length(temp.nccvec)){
	mat.bfhubs[,i] <- names(sort(gt_local[[temp.nccvec[i]]]$f.between, decreasing = T))[1:5]
	mat.bdhubs[,i] <- names(sort(gt_local[[temp.nccvec[i]]]$d.between, decreasing = T))[1:5]
}
hubs.between.func <- sort(table(mat.bfhubs), decreasing = T)
hubs.between.diff <- sort(table(mat.bdhubs), decreasing = T)
# degree-based hubs are calculated
mat.dfhubs <- matrix(NA, nrow = 5, ncol = 27, dimnames = list(c(1, 2, 3, 4, 5), temp.nccvec))
mat.ddhubs <- matrix(NA, nrow = 5, ncol = 27, dimnames = list(c(1, 2, 3, 4, 5), temp.nccvec))
for (i in 1:length(temp.nccvec)){
	mat.dfhubs[,i] <- names(sort(gt_hubs[[temp.nccvec[i]]]$f.hubs$vector, decreasing = T))[1:5]
	mat.ddhubs[,i] <- names(sort(gt_hubs[[temp.nccvec[i]]]$d.hubs$vector, decreasing = T))[1:5]
}
hubs.degree.func <- sort(table(mat.dfhubs), decreasing = T)
hubs.degree.diff <- sort(table(mat.ddhubs), decreasing = T)
