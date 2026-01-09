fslanatdir=~/Documents/work_data/240104_Proj-NCC-I/derivatives/fsl-6.0.7.10/
indir=~/Desktop/Display_Volumes/
autoload -U zmv
zmv '~/Documents/work_data/240104_Proj-NCC-I/derivatives/fsl-6.0.7.10/design/Extras/Display_Volumes/masks/design-(*)_(*)_(*)_mask.nii.gz' '~/Documents/work_data/240104_Proj-NCC-I/derivatives/fsl-6.0.7.10/design/Extras/Display_Volumes/masks/${1}.${3}.${2:l}h.nii.gz'
zmv '~/Documents/work_data/240104_Proj-NCC-I/derivatives/fsl-6.0.7.10/design/Extras/Display_Volumes/pvals/design-(*)_(*)_(*)_tfce_corrp_(*).nii.gz' '~/Documents/work_data/240104_Proj-NCC-I/derivatives/fsl-6.0.7.10/design/Extras/Display_Volumes/pvals/${1}.${4}.${3}.${2:l}h.nii.gz'
zmv '~/Documents/work_data/240104_Proj-NCC-I/derivatives/fsl-6.0.7.10/design/Extras/Display_Volumes/tstats/design-(*)_(*)_(*)_tstat(*).nii.gz' '~/Documents/work_data/240104_Proj-NCC-I/derivatives/fsl-6.0.7.10/design/Extras/Display_Volumes/tstats/${1}.tval${4}.${3}.${2:l}h.nii.gz'

mkdir -p $indir
cp ${fslanatdir}design/Extras/Display_Volumes/*/* ${indir}

for i in lh rh
do
	#for j in all ncc hcc
	for j in ncc
	do
		fslmaths ${indir}${j}.Accu.${i}.nii.gz -bin ${indir}${j}.Accu.bin.${i}.nii.gz
		fslmaths ${indir}${j}.Amyg.${i}.nii.gz -bin ${indir}${j}.Amyg.bin.${i}.nii.gz
		fslmaths ${indir}${j}.Caud.${i}.nii.gz -bin ${indir}${j}.Caud.bin.${i}.nii.gz
		fslmaths ${indir}${j}.Hipp.${i}.nii.gz -bin ${indir}${j}.Hipp.bin.${i}.nii.gz
		fslmaths ${indir}${j}.Pall.${i}.nii.gz -bin ${indir}${j}.Pall.bin.${i}.nii.gz
		fslmaths ${indir}${j}.Puta.${i}.nii.gz -bin ${indir}${j}.Puta.bin.${i}.nii.gz
		fslmaths ${indir}${j}.Thal.${i}.nii.gz -bin ${indir}${j}.Thal.bin.${i}.nii.gz
		fslmaths ${indir}${j}.Accu.bin.${i}.nii.gz -mul 1 ${indir}${j}.Accu.temp.${i}.nii.gz
		fslmaths ${indir}${j}.Amyg.bin.${i}.nii.gz -mul 2 ${indir}${j}.Amyg.temp.${i}.nii.gz
		fslmaths ${indir}${j}.Caud.bin.${i}.nii.gz -mul 3 ${indir}${j}.Caud.temp.${i}.nii.gz
		fslmaths ${indir}${j}.Hipp.bin.${i}.nii.gz -mul 4 ${indir}${j}.Hipp.temp.${i}.nii.gz
		fslmaths ${indir}${j}.Pall.bin.${i}.nii.gz -mul 5 ${indir}${j}.Pall.temp.${i}.nii.gz
		fslmaths ${indir}${j}.Puta.bin.${i}.nii.gz -mul 6 ${indir}${j}.Puta.temp.${i}.nii.gz
		fslmaths ${indir}${j}.Thal.bin.${i}.nii.gz -mul 7 ${indir}${j}.Thal.temp.${i}.nii.gz
		fslmaths ${indir}${j}.Accu.temp.${i}.nii.gz \
			-add ${indir}${j}.Amyg.temp.${i}.nii.gz \
			-add ${indir}${j}.Caud.temp.${i}.nii.gz \
			-add ${indir}${j}.Hipp.temp.${i}.nii.gz \
			-add ${indir}${j}.Pall.temp.${i}.nii.gz \
			-add ${indir}${j}.Puta.temp.${i}.nii.gz \
			-add ${indir}${j}.Thal.temp.${i}.nii.gz \
			${indir}${j}.${i}.nii.gz
	done
	for j in tstat1 tstat2
	do
		ind=${j##*stat}
		for k in ncc hcc
		do
			for l in Accu Amyg Caud Hipp Pall Puta Thal
			do
				fslmaths ${indir}${k}.${j}.${l}.${i}.nii.gz \
				-thr 0.8 \
				-bin \
				-mul ${indir}${k}.tval${ind}.${l}.${i}.nii.gz \
				-mul ${indir}${k}.${l}.bin.${i}.nii.gz \
				${indir}${k}.${j}.${l}.${i}.sig.nii.gz
			done
		done
	done
	for j in fstat1 tstat1 tstat2 tstat3 tstat4 tstat5 tstat6
	do
		ind=${j##*stat}
		for k in all
		do
			for l in Accu Amyg Caud Hipp Pall Puta Thal
			do
				fslmaths ${indir}${k}.${j}.${l}.${i}.nii.gz \
				-thr 0.8 \
				-bin \
				-mul ${indir}${k}.tval${ind}.${l}.${i}.nii.gz \
				-mul ${indir}${k}.${l}.bin.${i}.nii.gz \
				${indir}${k}.${j}.${l}.${i}.sig.nii.gz
			done
		done
	done
done

rm ${indir}*.bin.* ${indir}*.temp.* ${indir}*.*stat*.*.*.nii.gz ${indir}*.Accu.*h.nii.gz \
	${indir}*.Amyg.*h.nii.gz ${indir}*.Caud.*h.nii.gz ${indir}*.Hipp.*h.nii.gz \
	${indir}*.Pall.*h.nii.gz ${indir}*.Puta.*h.nii.gz ${indir}*.Thal.*h.nii.gz 

python
import subprocess
subprocess.call(['/Applications/Surfice/surfice.app/Contents/MacOS/surfice', '-S', '~/Documents/scripts/240104_Proj-NCC-I/surfice-meshcreate.py', 'end'])
exit()

python
import subprocess
subprocess.call(['/Applications/Surfice/surfice.app/Contents/MacOS/surfice', '-S', '~/Documents/scripts/240104_Proj-NCC-I/surfice-meshimage.py', 'end'])
exit()