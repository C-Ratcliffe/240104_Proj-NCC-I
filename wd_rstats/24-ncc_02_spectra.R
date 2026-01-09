#preamble####
rm(list = ls())
cat("\014")

library(extrafont)
library(ggplot2)
library(RNifti)

#font_import(pattern = 'Roboto')
#loadfonts(device = "win")

indir <- "C:/Users/coreyar/Working_Directory_Code/rstats/240104_Proj-NCC-I/input/"
t1dir <- paste0(indir, 't1w/')
opts.files <- list.files(path = t1dir, full.names = T)
opts.filenames <- list.files(path = t1dir, full.names = F)
opts.names <- sub("_.*", "", opts.filenames)

for (i in seq_along(opts.files)){
	nifti.raw <- readNifti(opts.files[i])
	voxel.raw <- as.vector(nifti.raw)
	voxel.std <- (voxel.raw - mean(voxel.raw))/sd(voxel.raw)
	g <- ggplot(data.frame(Intensity = voxel.std)
			, aes(x = Intensity)
			)+
		geom_density(alpha = 0.0
			)+
		labs(title = element_text(opts.names[i])
			)+
		scale_x_continuous(limits = c(-1, 14)
			, breaks = c(-1, 2, 5, 8, 11, 14)
			)+
		scale_y_continuous(limits = c(0, 5)
			, breaks = c(0, 1, 2, 3, 4, 5)
			)+
		theme_minimal(
			)+
		theme(text = element_text(family = 'Roboto Light')
			, legend.position = 'none'
			, panel.grid.minor = element_blank()
			, panel.grid.major.y = element_line(colour = 'grey', linewidth = 0.25)
			, panel.grid.major.x = element_line(colour = 'grey', linewidth = 0.25)
			, panel.background = element_blank()
			, plot.background = element_blank()
			, plot.margin = unit(c(0, 0, 0, 0), "cm")
			, plot.title = element_text(hjust = 1, vjust = 1, size = 12)  # Align title to the right and top
			, plot.title.position = "plot"
			, axis.title.x = element_blank()
			, axis.title.y = element_blank()
			)
	# the plot is exported as an svg
	outdir <- "C:/Users/coreyar/Working_Directory_Code/rstats/240104_Proj-NCC-I/Output/t1w-spectra/"
	filename <- paste(outdir, opts.names[i], '.svg', sep = '')
	ggsave(filename, g, width = 5, height = 5, device = 'svg')
}
