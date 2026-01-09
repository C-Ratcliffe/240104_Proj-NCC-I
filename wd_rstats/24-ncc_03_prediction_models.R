#preamble####
rm(list = ls())
cat("\014")

library(sysfonts)
library(MASS)
library(ggplot2)
library(psych)
library(pROC)

set.seed(123)

#data import and management####
##the participant data is read in as a table

tab <- list()

tab$ptcs <- as.data.frame(read.delim('~/Documents/WD_Code/rstats/240104_Proj-NCC-I/input/participants.tsv'
	, header = T, sep = "\t", dec = '.', numerals = 'no.loss', na.strings = 'na'
	, stringsAsFactors = F)
	)

for (i in c(8, 9)){
	tab$ptcs[,i] <- as.Date(as.character(tab$ptcs[,i]), format = '%y%m%d')
}

tab$ptcs$acute_time <- as.numeric(difftime(tab$ptcs$baseline_date, tab$ptcs$sz_date))

##for the prediction model, controls are removed

tab$ncc <- tab$ptcs[tab$ptcs$group == 0,]
tab$ncc$oedema_vol <- 100*(tab$ncc$oedema_vol/tab$ncc$brain_vol)
tab$ncc.full <- tab$ncc[rowSums(is.na(tab$ptcs[,c(1:10, 14)])) == 0, ]

tab$mod.ncc <- tab$ncc.full[, c(3, 4, 5, 6, 7, 10, 16, 14)]
tab$mod.ncc$sex <- as.factor(tab$mod.ncc$sex)
tab$mod.ncc$first_sz <- as.factor(tab$mod.ncc$first_sz)
tab$mod.ncc$sz_rec <- as.factor(tab$mod.ncc$sz_rec)
tab$mod.ncc$oedema_vol <- (tab$mod.ncc$oedema_vol/mean(tab$mod.ncc$oedema_vol))/sd(tab$mod.ncc$oedema_vol)

tab$na.ncc <- tab$ncc[, c(3, 4, 5, 6, 7, 10, 16, 14)]
tab$mod.ncc$oedema_vol[tab$mod.ncc$oedema_vol != 0] <- (tab$mod.ncc$oedema_vol[tab$mod.ncc$oedema_vol != 0]/mean(tab$mod.ncc$oedema_vol[tab$mod.ncc$oedema_vol != 0]))/sd(tab$mod.ncc$oedema_vol[tab$mod.ncc$oedema_vol != 0])

# univeriates
# univariate comparisons are computed between the predictors and seizure recurrence

uni <- list()

uni$age <- wilcox.test(tab$mod.ncc$age_at_scan ~ tab$mod.ncc$sz_rec)
uni$sex <- fisher.test(tab$mod.ncc$sex, tab$mod.ncc$sz_rec)
uni$first <- fisher.test(tab$mod.ncc$first_sz, tab$mod.ncc$sz_rec)
uni$v <- wilcox.test(tab$mod.ncc$v_no ~ tab$mod.ncc$sz_rec)
uni$nv <- wilcox.test(tab$mod.ncc$nv_no ~ tab$mod.ncc$sz_rec)
uni$acute <- fisher.test(tab$mod.ncc$sz_count, tab$mod.ncc$sz_rec)
uni$oedema <- wilcox.test(tab$mod.ncc$oedema_vol ~ tab$mod.ncc$sz_rec)


# model creation####
# the qualitative development model database is created
# the required predictors are extracted from the main table

opts.factors <- c( 'Age at Scan (Years)'
	, 'Sex'
	, 'First Seizure'
	, 'Viable Cysts'
	, 'Nonviable Cysts'
	, 'Acute Seizure Count'
	, 'Oedema Volume (z-score mm³)'
	, 'Seizure Recurrence'
)

# the qualitative development model is created and reduced with AIC

summary <- list()
mod <- list()

mod$all <- glm(`sz_rec` ~ `age_at_scan` + `sex` + `first_sz` + `v_no` + `nv_no` + `oedema_vol` + `sz_count`
	, family = 'binomial'
	, data = tab$mod.ncc
	)
summary$all <- summary(mod$all)
mod$less <- glm(`sz_rec` ~ `first_sz` + `v_no` + `nv_no` + `oedema_vol` + `sz_count`
	, family = 'binomial'
	, data = tab$mod.ncc
)
summary$less <- summary(mod$less)
mod$min <- glm(`sz_rec` ~ `oedema_vol` + `nv_no` + `sz_count`
	, family = 'binomial'
	, data = tab$mod.ncc
)
summary$min <- summary(mod$min)
mod$reduced <- stepAIC(mod$less, direction = 'backward', trace = T)

mod$final <- glm(`sz_rec` ~ `nv_no` + `sz_count`
	, family = 'binomial'
	, data = tab$mod.ncc
)
summary$final <- summary(mod$final)

# calibration####
# manual calibration in the large

boot.citl = function(data, n) {
	citl = rep(NA, n)

	for (i in 1:n) {
		samples = sample(data, size=length(data), replace=T)
		citl[i] <- mean(predict(mod$all, type = 'response')) - mean(samples == 1)
	}
	return(citl)
}

citl <- boot.citl(tab$mod.ncc$sz_rec, 1000)
citl_val <- mean(citl)
citl_conf <- t.test(citl)[['conf.int']]

# discrimination####
# calculating the c-index

boot.c_ind = function(data, n) {
	c_ind = list()
	for (i in 1:n) {
		repeat {
			samples = sample(data, size=length(data), replace=T)
			if (length(unique(samples)) == 2) {
				break
			}
		}
		c_ind[[i]] <- roc(samples, as.numeric(predict(mod$all, type = 'response')))
	}
	auc_vals <- sapply(c_ind, function(x) auc(x))
	return(auc_vals)
}

c_ind <- boot.c_ind(tab$mod.ncc$sz_rec, 1000)
c_ind_val <- mean(c_ind)
c_ind_conf <- t.test(c_ind)[['conf.int']]

# descriptives####
# figures are created to demonstrate distributions of data

desc <- describeBy(tab$ptcs, tab$ptcs$group, digits = 2)

tab$bp.full <- cbind(as.numeric(rowSums(is.na(tab$na.ncc)) != 0), tab$na.ncc)

for (i in c(2, 5, 6, 7, 8)){
	tab$bp <- as.data.frame(tab$bp.full[is.na(tab$bp.full[,i]) == 0, c(1, i)])
	colnames(tab$bp) <- c('group', 'val')
	tab$bp$group <- as.factor(tab$bp$group)
	min_val <- floor(min(tab$bp$val))
	max_val <- ceiling(max(tab$bp$val))
	plot <- ggplot(tab$bp, aes(x = group, y = val))+
		geom_boxplot(
			)+
		labs(x = 'Subset', y = opts.factors[i-1])+
		scale_x_discrete(labels = c('Included\nCases', 'Excluded\nCases')
			, limits = c('0', '1')
			)+
		scale_y_continuous(limits = c(min_val, max_val))+
		theme(text = element_text(family='sans', size = 12, colour = 'black')
			, legend.position = 'none'
			, panel.grid.minor = element_blank()
			, panel.grid.major.y = element_line(colour = 'grey', linewidth = 0.25)
			, panel.grid.major.x = element_blank()
			, panel.background = element_blank()
			, plot.background = element_blank()
			, plot.margin = unit(c(0, 0.25, 0, 0.25), "cm")
			, title = element_blank()
			, axis.text.x = element_text(colour = 'black', size = 10)
			, axis.text.y = element_text(colour = 'black', size = 10)
			, axis.title.y = element_text(colour = 'black', size = 12)
			, axis.ticks = element_blank()
		)
	filename <- paste0('~/Documents/WD_Projects/Diagrams/240129_Proj-NCC-I/chapter-3/figure-2/', colnames(tab$bp.full)[i], sep = '')
	ggsave(plot = plot, device = 'png', height = 1560, width = 780, units = 'px', filename = paste(filename, 'png', sep = '.'), dpi=300)
}

rm(max_val, min_val, i)
