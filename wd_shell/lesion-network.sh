templatedir=~/Documents/work_data/240104_Proj-NCC-I/derivatives/fba/template/
bundledir=${templatedir}roi/bundles/
lesiondir=${templatedir}lesion-mapping-dilate/
tractseg_wmdir=~/Documents/work_data/240104_Proj-NCC-I/derivatives/tractseg/template/

mrcalc ${lesiondir}group/sub-008_lesion-network_fixel.mif \
${lesiondir}group/sub-009_lesion-network_fixel.mif -add \
${lesiondir}group/sub-022_lesion-network_fixel.mif -add \
${lesiondir}group/sub-030_lesion-network_fixel.mif -add \
${lesiondir}group/sr_short_fixel.mif

mrcalc ${lesiondir}group/sub-008_lesion-network_long_fixel.mif \
${lesiondir}group/sub-009_lesion-network_long_fixel.mif -add \
${lesiondir}group/sub-022_lesion-network_long_fixel.mif -add \
${lesiondir}group/sub-030_lesion-network_long_fixel.mif -add \
${lesiondir}group/sr_long_fixel.mif

mrcalc ${lesiondir}group/sub-002_lesion-network_fixel.mif \
${lesiondir}group/sub-003_lesion-network_fixel.mif -add \
${lesiondir}group/sub-004_lesion-network_fixel.mif -add \
${lesiondir}group/sub-007_lesion-network_fixel.mif -add \
${lesiondir}group/sub-014_lesion-network_fixel.mif -add \
${lesiondir}group/sub-015_lesion-network_fixel.mif -add \
${lesiondir}group/sub-016_lesion-network_fixel.mif -add \
${lesiondir}group/sub-017_lesion-network_fixel.mif -add \
${lesiondir}group/sub-021_lesion-network_fixel.mif -add \
${lesiondir}group/sf_short_fixel.mif

mrcalc ${lesiondir}group/sub-002_lesion-network_long_fixel.mif \
${lesiondir}group/sub-003_lesion-network_long_fixel.mif -add \
${lesiondir}group/sub-004_lesion-network_long_fixel.mif -add \
${lesiondir}group/sub-007_lesion-network_long_fixel.mif -add \
${lesiondir}group/sub-014_lesion-network_long_fixel.mif -add \
${lesiondir}group/sub-015_lesion-network_long_fixel.mif -add \
${lesiondir}group/sub-016_lesion-network_long_fixel.mif -add \
${lesiondir}group/sub-017_lesion-network_long_fixel.mif -add \
${lesiondir}group/sub-021_lesion-network_long_fixel.mif -add \
${lesiondir}group/sf_long_fixel.mif

mrthreshold -ignorezero -percentile 60 ${lesiondir}group/sr_long_fixel.mif ${lesiondir}group/sr_long_fixel-thr.mif
mrthreshold -ignorezero -percentile 60 ${lesiondir}group/sf_long_fixel.mif ${lesiondir}group/sf_long_fixel-thr.mif

mrcalc ${lesiondir}group/sf_long_fixel.mif 27320 -divide ${lesiondir}group/sf_long_fixel_std.mif
mrcalc ${lesiondir}group/sr_long_fixel.mif 58806 -divide ${lesiondir}group/sr_long_fixel_std.mif

mrcalc ${lesiondir}group/sr_long_fixel_std.mif ${lesiondir}group/sf_long_fixel_std.mif -subtract ${lesiondir}group/subtraction.mif

mrthreshold -abs 0.01 ${lesiondir}group/subtraction.mif ${lesiondir}group/sr_sub.mif
mrthreshold -abs -0.01 -comparison lt ${lesiondir}group/subtraction.mif ${lesiondir}group/sf_sub.mif

mrthreshold -abs 0.01 ${lesiondir}group/sf_short_fixel.mif ${lesiondir}group/sf_short_fixel_std.mif
mrthreshold -abs 0.01 ${lesiondir}group/sr_short_fixel.mif ${lesiondir}group/sr_short_fixel_std.mif

mrcalc ${lesiondir}group/sr_short_fixel_std.mif ${lesiondir}group/sf_short_fixel_std.mif -subtract ${lesiondir}group/subtraction_short.mif

mrthreshold -abs 0.01 ${lesiondir}group/subtraction_short.mif ${lesiondir}group/sr_sub_short.mif
mrthreshold -abs -0.01 -comparison lt ${lesiondir}group/subtraction_short.mif ${lesiondir}group/sf_sub_short.mif

fixel2voxel ${lesiondir}group/sf_long_sub.mif absmax ${lesiondir}group/sf_long_sub_voxel.mif
fixel2voxel ${lesiondir}group/sf_short_sub.mif absmax ${lesiondir}group/sf_short_sub_voxel.mif
fixel2voxel ${lesiondir}group/sr_long_sub.mif absmax ${lesiondir}group/sr_long_sub_voxel.mif
fixel2voxel ${lesiondir}group/sr_short_sub.mif absmax ${lesiondir}group/sr_short_sub_voxel.mif

touch ${lesiondir}group/sf_long_sub.tsv
touch ${lesiondir}group/sf_short_sub.tsv
touch ${lesiondir}group/sr_long_sub.tsv
touch ${lesiondir}group/sr_short_sub.tsv

for i in ${tractseg_wmdir}tractseg_output/TOM_trackings/*.tck
do
	tractfile=${i##*TOM_trackings/}
	tract=${tractfile%%.tck}
	mrconvert ${bundledir}${tract}_voxel.mif -coord 3 0 -axes 0,1,2 ${bundledir}temp.mif
	mrstats -output count -mask ${lesiondir}group/sf_long_sub_voxel.mif -ignorezero ${bundledir}temp.mif >> ${lesiondir}group/sf_long_sub.tsv
	mrstats -output count -mask ${lesiondir}group/sf_short_sub_voxel.mif -ignorezero ${bundledir}temp.mif >> ${lesiondir}group/sf_short_sub.tsv
	mrstats -output count -mask ${lesiondir}group/sr_long_sub_voxel.mif -ignorezero ${bundledir}temp.mif >> ${lesiondir}group/sr_long_sub.tsv
	mrstats -output count -mask ${lesiondir}group/sr_short_sub_voxel.mif -ignorezero ${bundledir}temp.mif >> ${lesiondir}group/sr_short_sub.tsv
	rm ${bundledir}temp.mif
done
paste -d ' ' ${bundledir}tracts.tsv ${bundledir}volumes.tsv ${lesiondir}group/sf_long_sub.tsv > ${lesiondir}group/sf_long_sub-vols.tsv
paste -d ' ' ${bundledir}tracts.tsv ${bundledir}volumes.tsv ${lesiondir}group/sf_short_sub.tsv > ${lesiondir}group/sf_short_sub-vols.tsv
paste -d ' ' ${bundledir}tracts.tsv ${bundledir}volumes.tsv ${lesiondir}group/sr_long_sub.tsv > ${lesiondir}group/sr_long_sub-vols.tsv
paste -d ' ' ${bundledir}tracts.tsv ${bundledir}volumes.tsv ${lesiondir}group/sr_short_sub.tsv > ${lesiondir}group/sr_short_sub-vols.tsv
rm ${lesiondir}group/sf_long_sub.tsv ${lesiondir}group/sf_short_sub.tsv ${lesiondir}group/sr_long_sub.tsv ${lesiondir}group/sr_short_sub.tsv ${lesiondir}group/sf_long_sub_voxel.mif ${lesiondir}group/sf_short_sub_voxel.mif ${lesiondir}group/sr_long_sub_voxel.mif  ${lesiondir}group/sr_short_sub_voxel.mif