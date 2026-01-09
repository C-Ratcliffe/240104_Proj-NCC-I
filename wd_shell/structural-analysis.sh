# Structural Analysis
while true
do
	echo Choose option:
	echo
	echo 1. Package install
	echo 2. FreeSurfer
	echo 3. FSL
	echo 4. Lesions
	echo 5. Skip structural analysis
	echo
	read "structselect?Selection (1/5): "

	if [[ $structselect == 1 ]]
	# Package install
	then
		# FreeSurfer
		# FSL-ANAT
		
		# FSQC
		mkdir fsqc
		pyenv exec python3.10 -m venv fsqc
		source ~/fsqc/bin/activate
		pip install --upgrade pip
		pip3 install fsqc
		deactivate

	elif [[ $structselect == 2 ]]
	# FreeSurfer reconstruction
	then
		# Shell setup
		export FREESURFER_HOME=~/freesurfer
		source $FREESURFER_HOME/SetUpFreeSurfer.sh
		# Environment setup
		fsdir=${derivdir}freesurfer-7.4.1/
		qcdir=${fsdir}QA/
		fsrdir=${fsdir}rdata/
		while true
		do
			echo Choose FreeSurfer action:
			echo
			echo 1. FreeSurfer reconstruction
			echo 2. FreeSurfer manual quality check
			echo 3. FreeSurfer quality check
			echo 4. FreeSurfer metric extraction
			echo 5. Skip FreeSurfer
			echo
			read "fsselect?Selection (1/5): "

			if [[ $fsselect == 1 ]]
			then
			# FreeSurfer Reconstruction
				if [[ ! -e ${fsdir}fsaverage ]]
				then
					ln -s ~/freesurfer/subjects/fsaverage ${fsdir}fsaverage
				fi
				for sub in ${rawdir}sub-*
				do
					subname=${sub#*/rawdata/}
					if [[ -e ${derivdir}anat_regrid/${subname}/anat/${subname}_FLAIR_1mm.nii.gz ]]
					then
						recon-all -sd ${fsdir} -i ${derivdir}anat_regrid/${subname}/anat/*T1w_1mm.nii* \
							-subjid $subname -flair ${derivdir}anat_regrid/${subname}/anat/*FLAIR_1mm.nii* \
							-flairpial -all -qcache -3T -mprage -parallel -openmp 4

					elif [[ -e ${derivdir}anat_regrid/${subname}/anat/${subname}_T2w_1mm.nii.gz ]]
					then
						recon-all -sd ${fsdir} -i ${derivdir}anat_regrid/${subname}/anat/*T1w_1mm.nii* \
							-subjid $subname -t2 ${derivdir}anat_regrid/${subname}/anat/*T2w_1mm.nii* \
							-t2pial -all -qcache -3T -mprage -parallel -openmp 4

					elif [[ -e ${sub}/anat/${subname}_FLAIR.nii.gz ]]
					then
						recon-all -sd ${fsdir} -i ${sub}/anat/*T1w.nii* \
							-subjid $subname -flair ${sub}/anat/*FLAIR.nii* \
							-flairpial -all -qcache -3T -mprage -parallel -openmp 4

					elif [[ -e ${sub}/anat/${subname}_T2w.nii.gz ]]
					then
						recon-all -sd ${fsdir} -i ${sub}/anat/*T1w.nii* \
							-subjid $subname -t2 ${sub}/anat/*T2w.nii* \
							-t2pial -all -qcache -3T -mprage -parallel -openmp 4

					elif [[ -e ${sub}/anat/${subname}_T1w.nii.gz ]]
					then
						recon-all -sd ${fsdir} -i ${sub}/anat/*T1w.nii* \
							-subjid $subname \
							-all -qcache -3T -mprage -parallel -openmp 4
					else
						echo No images found for recon-all.
					fi
				done

			elif [[ $fsselect == 2 ]]
			# Manual QC
			then
				while true
				do
					echo Please enter the subject number of the participant you would like to examine
					echo Alternatively, please enter 'x' to return
					echo
					read "subselect?Input: "

					if [[ $subselect == "x" ]]
					then
						break
					fi

					qcsub=${fsdir}sub-${subselect}/

					freeview -v \
					${qcsub}mri/T1.mgz \
					${qcsub}mri/wm.mgz \
					${qcsub}mri/brainmask.mgz \
					${qcsub}mri/aseg.mgz:colormap=lut:opacity=0.2 \
					-f ${qcsub}surf/lh.white:edgecolor=blue \
					${qcsub}surf/lh.pial:edgecolor=red \
					${qcsub}surf/rh.white:edgecolor=blue \
					${qcsub}surf/rh.pial:edgecolor=red
				done

			elif [[ $fsselect == 3 ]]
			# Automatic QC
			then
				mkdir -p ${qcdir}
				source ~/fsqc/bin/activate
				run_fsqc --subjects_dir ${fsdir} --output_dir ${qcdir} --fornix --outlier --shape --screenshots --surfaces
				deactivate

			elif [[ $fsselect == 4 ]]
			# Metrics
			then
				# Aliases and directories
				mkdir -p ${fsrdir}
				declare -a measurescort=('volume' 'thickness' 'thicknessstd' 'meancurv' 'gauscurv' 'foldind' 'curvind')
				declare -a measuressubcort=('volume')
				declare -a hemis=('lh' 'rh')
				# Table creation
			  for meas in ${measurescort[@]}
			  do
			    for hemi in ${hemis[@]}
			    do
			      aparcstats2table --skip \
			        --subjects ${fsdir}sub* \
			        --parc aparc.a2009s \
			        --hemi $hemi \
			        --measure $meas \
			        --delimiter tab \
			        --tablefile ${fsrdir}${hemi}_${meas}_uncut.tsv
			      cut -f 2-75 ${fsrdir}${hemi}_${meas}_uncut.tsv > ${fsrdir}${hemi}_${meas}.tsv
			      cut -f 76 ${fsrdir}${hemi}_${meas}_uncut.tsv > ${fsrdir}brainvol.tsv
			      rm ${fsrdir}${hemi}_${meas}_uncut.tsv
			    done
			    paste -d '\t' ${fsrdir}*_${meas}.tsv > ${fsrdir}cort_${meas}_temp.tsv
					cut -f 1- ${fsrdir}cort_${meas}_temp.tsv > ${fsrdir}cort_${meas}.tsv
			    rm ${fsrdir}lh_${meas}.tsv ${fsrdir}rh_${meas}.tsv ${fsrdir}cort_${meas}_temp.tsv
			  done
			  for meas in ${measuressubcort[@]}
			  do
			    asegstats2table --skip \
			      --subjects ${fsdir}sub* \
			      --meas $meas \
			      --delimiter tab \
			      --tablefile ${fsrdir}aseg_${meas}_uncut.tsv
			    cut -f 2-65 -d, ${fsrdir}aseg_${meas}_uncut.tsv > ${fsrdir}aseg_${meas}.tsv
			    rm ${fsrdir}aseg_${meas}_uncut.tsv

			    if [[ $meas == 'Area_mm2' ]]
			    then
			      mv ${fsrdir}aseg_${meas}.tsv ${fsrdir}aseg_area_uncut.tsv
			      cut -f 2-65 -d, ${fsrdir}aseg_area_uncut.tsv > ${fsrdir}aseg_area.tsv
			      rm ${fsrdir}aseg_area_uncut.tsv
			    fi
			  done

			elif [[ $fsselect == 5 ]]
			# FreeSurfer is skipped
			then
				echo FreeSurfer skipped.
				break

			else
				echo Invalid selection.
			fi
		done

	elif [[ $structselect == 3 ]]
	# FSL Processing
	then
		fslanatdir=${derivdir}fsl-6.0.7.10/
		fslrdir=${fslanatdir}rdata/
		fslsurfdir=${fslanatdir}surfs/
		mkdir -p ${fslrdir} ${fslsurfdir} ${fslanatdir}design/Extras/Display_Volumes/${testno} \
			${fslanatdir}design/Extras/Screenshots ${fslanatdir}design/Extras/Volumes
			${fslanatdir}input/ ${fslanatdir}processed/
		while true
		do
			echo Choose FSL action:
			echo
			echo 1. FSL segmentation
			echo 2. FSL concatenation, weighting, and randomisation
			echo 3. FSL volume estimation
			echo 4. Skip FSL
			echo
			read "fslselect?Selection (1/4): "
			if [[ $fslselect == 1 ]]
			# Segmentation
			then
				read "fslcopy?Copy scans (y/n): "
				if [[ $fslcopy == y ]]
				then
					mkdir -p ${fslanatdir}input/
					cp ${FSLDIR}/data/standard/MNI152_T1_1mm.nii.gz ${fslanatdir}design/mni.nii.gz
					bet ${fslanatdir}design/mni.nii.gz ${fslanatdir}design/mni-bet.nii.gz
					for sub in ${rawdir}sub-*
					do
						subname=${sub#*/rawdata/}
						if [[ -e ${derivdir}anat_regrid/${subname}/anat/${subname}_T1w_1mm.nii.gz ]]
						then
							cp ${derivdir}anat_regrid/${subname}/anat/${subname}_T1w_1mm.nii.gz ${fslanatdir}input/
						elif [[ -e ${sub}/anat/${subname}_T1w.nii.gz ]]
						then
							cp ${sub}/anat/${subname}_T1w.nii.gz ${fslanatdir}input/
						else 
							echo ${subname} skipped.
						fi
					done
				else
					echo Copying skipped.
				fi
				for subj in ${fslanatdir}input/*.nii.gz
				do
					subname=$(grep -E -o 'sub-[0-9][0-9][0-9]' <<< $subj)
					subpre=${fslanatdir}${subname}/${subname}
					mkdir -p ${fslanatdir}${subname}
					echo $subname
					N4BiasFieldCorrection -i $subj -o ${subpre}_biascorr.nii.gz
					cd ~/HD-BET/HD_BET/
					hd-bet -i ${subpre}_biascorr.nii.gz -o ${subpre}_biascorr-bet.nii.gz -device cpu \
						-mode accurate -tta 0
					cd ~
					flirt -omat ${subpre}_biascorr-bet2std.mat \
						-in ${subpre}_biascorr-bet.nii.gz \
						-ref ${fslanatdir}design/mni-bet.nii.gz \
						-out ${subpre}_biascorr-bet2std.nii.gz
					run_first_all -a ${subpre}_biascorr-bet2std.mat \
						-s L_Accu,L_Amyg,L_Caud,L_Hipp,L_Pall,L_Puta,L_Thal,R_Accu,R_Amyg,R_Caud,R_Hipp,R_Pall,R_Puta,R_Thal \
						-b \
						-i ${subpre}_biascorr-bet.nii.gz \
						-o ${subpre}_first
					mv $subj ${fslanatdir}processed/
				done
				rm -r ${fslanatdir}slicesdir_seg ${fslanatdir}slicesdir_reg
				first_roi_slicesdir ${fslanatdir}sub*/sub*biascorr.nii.gz ${fslanatdir}sub*/sub*firstseg.nii.gz
				mv slicesdir ${fslanatdir}slicesdir_seg
				${FSLDIR}/bin/slicesdir -p ${fslanatdir}design/mni.nii.gz ${fslanatdir}sub*/sub*biascorr-bet2std.nii.gz
				mv slicesdir ${fslanatdir}slicesdir_reg
				rm -r ${fslanatdir}input/ ${fslanatdir}processed/

			elif [[ $fslselect == 2 ]]
			# Concatenation, weighting, and randomise
			then
				#read "testno?Test number: "
				#read "design?Design (eg design.mat): "
				#read "contrast?Contrast (eg contrast.con): "
				#read "ftest?fTest (eg ftest.fts): "
				echo Patients vs grouped controls: hcc
				echo Patients vs NIMHANS controls vs HCP: f
				echo First seizure vs prior seizure: ncc
				echo All tests: a
				echo None: n 
				read "test?Test to run (hcc/ncc/f/a/n): "
				if [[ -e ${fslanatdir}design/design.all.txt ]]
				then
					Text2Vest ${fslanatdir}design/design.all.txt ${fslanatdir}design/design.all.mat
					Text2Vest ${fslanatdir}design/contrast.all.txt ${fslanatdir}design/contrast.all.con
					Text2Vest ${fslanatdir}design/ftest.all.txt ${fslanatdir}design/ftest.all.fts
					Text2Vest ${fslanatdir}design/design.ncc.txt ${fslanatdir}design/design.ncc.mat
					Text2Vest ${fslanatdir}design/contrast.ncc.txt ${fslanatdir}design/contrast.ncc.con
					Text2Vest ${fslanatdir}design/design.hcc.txt ${fslanatdir}design/design.hcc.mat
					Text2Vest ${fslanatdir}design/contrast.hcc.txt ${fslanatdir}design/contrast.hcc.con
					rm ${fslanatdir}design/*.txt
				fi
				for region in L_Accu L_Amyg L_Caud L_Hipp L_Pall L_Puta L_Thal R_Accu R_Amyg R_Caud R_Hipp R_Pall R_Puta R_Thal
				do
					mkdir -p ${fslanatdir}design/${region}
					if [[ $test == hcc || $test == a ]]
					then
						rm ${fslanatdir}design/${region}.hcc.bvars
						concat_bvars ${fslanatdir}design/${region}.hcc.bvars ${fslanatdir}sub*/sub*first-${region}_first.bvars
						first_utils --vertexAnalysis \
							--usebvars \
							-i ${fslanatdir}design/${region}.hcc.bvars \
							-d ${fslanatdir}design/design.hcc.mat \
							-o ${fslanatdir}design/${region}/design-hcc_${region} \
							--useReconMNI \
							-v >& ${fslanatdir}design/${region}/log_design-hcc_${region}.txt
						randomise -i ${fslanatdir}design/${region}/design-hcc_${region}.nii.gz \
							-m ${fslanatdir}design/${region}/design-hcc_${region}_mask.nii.gz \
							-o ${fslanatdir}design/${region}/design-hcc_${region} \
							-d ${fslanatdir}design/design.hcc.mat \
							-t ${fslanatdir}design/contrast.hcc.con \
							-T
					fi
					if [[ $test == ncc || $test == a ]]
					then
						rm ${fslanatdir}design/${region}.ncc.bvars
						concat_bvars ${fslanatdir}design/${region}.ncc.bvars \
							${fslanatdir}sub-002/sub-002_first-${region}_first.bvars \
							${fslanatdir}sub-003/sub-003_first-${region}_first.bvars \
							${fslanatdir}sub-007/sub-007_first-${region}_first.bvars \
							${fslanatdir}sub-008/sub-008_first-${region}_first.bvars \
							${fslanatdir}sub-010/sub-010_first-${region}_first.bvars \
							${fslanatdir}sub-011/sub-011_first-${region}_first.bvars \
							${fslanatdir}sub-012/sub-012_first-${region}_first.bvars \
							${fslanatdir}sub-014/sub-014_first-${region}_first.bvars \
							${fslanatdir}sub-015/sub-015_first-${region}_first.bvars \
							${fslanatdir}sub-016/sub-016_first-${region}_first.bvars \
							${fslanatdir}sub-018/sub-018_first-${region}_first.bvars \
							${fslanatdir}sub-021/sub-021_first-${region}_first.bvars \
							${fslanatdir}sub-022/sub-022_first-${region}_first.bvars \
							${fslanatdir}sub-024/sub-024_first-${region}_first.bvars \
							${fslanatdir}sub-027/sub-027_first-${region}_first.bvars \
							${fslanatdir}sub-030/sub-030_first-${region}_first.bvars \
							${fslanatdir}sub-031/sub-031_first-${region}_first.bvars \
							${fslanatdir}sub-033/sub-033_first-${region}_first.bvars
						first_utils --vertexAnalysis \
							--usebvars \
							-i ${fslanatdir}design/${region}.ncc.bvars \
							-d ${fslanatdir}design/design.ncc.mat \
							-o ${fslanatdir}design/${region}/design-ncc_${region} \
							--useReconMNI \
							-v >& ${fslanatdir}design/${region}/log_design-ncc_${region}.txt
						randomise -i ${fslanatdir}design/${region}/design-ncc_${region}.nii.gz \
							-m ${fslanatdir}design/${region}/design-ncc_${region}_mask.nii.gz \
							-o ${fslanatdir}design/${region}/design-ncc_${region} \
							-d ${fslanatdir}design/design.ncc.mat \
							-t ${fslanatdir}design/contrast.ncc.con \
							-T
					fi
					if [[ $test == f || $test == a ]]
					then
						rm ${fslanatdir}design/${region}.all.bvars
						concat_bvars ${fslanatdir}design/${region}.all.bvars ${fslanatdir}sub*/sub*first-${region}_first.bvars
						first_utils --vertexAnalysis \
							--usebvars \
							-i ${fslanatdir}design/${region}.all.bvars \
							-d ${fslanatdir}design/design.all.mat \
							-o ${fslanatdir}design/${region}/design-all_${region} \
							--useReconMNI \
							-v >& ${fslanatdir}design/${region}/log_design-all_${region}.txt
						randomise -i ${fslanatdir}design/${region}/design-all_${region}.nii.gz \
							-m ${fslanatdir}design/${region}/design-all_${region}_mask.nii.gz \
							-o ${fslanatdir}design/${region}/design-all_${region} \
							-d ${fslanatdir}design/design.all.mat \
							-t ${fslanatdir}design/contrast.all.con \
							-f ${fslanatdir}design/ftest.all.fts \
							-T
					elif [[ $test == n ]]
					then
						echo Randomise skipped.
						break
					else
						echo Invalid selection.
					fi
				done
				echo PLEASE REFER TO 'surfice-meshcreate.sh' BEFORE RUNNING STEP 3

			elif [[ $fslselect == 3 ]]
			# Volume estimation
			then
				mkdir -p ${fslanatdir}design/Extras/Display_Volumes/masks/ ${fslanatdir}design/Extras/Display_Volumes/pvals/ ${fslanatdir}design/Extras/Display_Volumes/tstats/
				cp ${fslanatdir}design/*_*/*mask.nii.gz ${fslanatdir}design/Extras/Display_Volumes/masks/
				cp ${fslanatdir}design/*_*/*tfce*.nii.gz ${fslanatdir}design/Extras/Display_Volumes/pvals/
				for i in ${fslanatdir}design/*_*/
				do
					j=${i##*design/}
					k=${j%%/}
					cp ${fslanatdir}design/${k}/design-*_${k}_tstat*.nii.gz ${fslanatdir}design/Extras/Display_Volumes/tstats/
				done
				
				rm ${fslanatdir}design/Extras/Volumes/tvals.tsv 
				for i in ${fslanatdir}design/Extras/Display_Volumes/tstats/*
				do 
					echo ${i##*tstats/} >> ${fslanatdir}design/Extras/Volumes/tstats.tsv
					fslstats $i -R >> ${fslanatdir}design/Extras/Volumes/tstats.txt
				done
				paste -d ' ' ${fslanatdir}design/Extras/Volumes/tstats.* > ${fslanatdir}design/Extras/Volumes/tvals.tsv
				rm ${fslanatdir}design/Extras/Volumes/tstats.*

				rm ${fslanatdir}design/Extras/Volumes/volumes.tsv
				for sub in ${fslanatdir}sub*
				do
					subname=${sub##*${fslanatdir}}
					echo ${subname}_vols > ${fslanatdir}design/Extras/Volumes/${subname}_vols.tsv
					fslstats -t ${sub}/sub*_origsegs.nii.gz -V > ${fslanatdir}design/Extras/Volumes/${subname}_vols.txt
					cut -d ' ' -f 2 ${fslanatdir}design/Extras/Volumes/${subname}_vols.txt >> ${fslanatdir}design/Extras/Volumes/${subname}_vols.tsv
				done
				paste -d ' ' ${fslanatdir}design/Extras/Volumes/*_vols.tsv > ${fslanatdir}design/Extras/Volumes/volumes.tsv
				rm ${fslanatdir}design/Extras/Volumes/*_vols*
				
				rm ${fslanatdir}design/Extras/Volumes/shapemin_shapemax.tsv
				for scan in ${fslanatdir}design/Extras/Display_Volumes/pvals/*tfce*
				do
					scanname=${scan##*/}
					scanlabel=${scanname%%.nii.gz}
					echo ${scanlabel} > ${fslanatdir}design/Extras/Volumes/${scanlabel}_shapes.tsv
					fslstats $scan -R > ${fslanatdir}design/Extras/Volumes/${scanlabel}_shapes.txt
					cut -d ' ' -f 2 ${fslanatdir}design/Extras/Volumes/${scanlabel}_shapes.txt > ${fslanatdir}design/Extras/Volumes/${scanlabel}_shapesigs.txt
					paste -d ' ' ${fslanatdir}design/Extras/Volumes/${scanlabel}_shapes.tsv ${fslanatdir}design/Extras/Volumes/${scanlabel}_shapesigs.txt > ${fslanatdir}design/Extras/Volumes/${scanlabel}_shapesigs.tsv
				done
				paste -d '\n' ${fslanatdir}design/Extras/Volumes/design-all*sigs.tsv > ${fslanatdir}design/Extras/Volumes/design-all_shapemin_shapemax.tsv
				paste -d '\n' ${fslanatdir}design/Extras/Volumes/design-ncc*sigs.tsv > ${fslanatdir}design/Extras/Volumes/design-ncc_shapemin_shapemax.tsv
				paste -d '\n' ${fslanatdir}design/Extras/Volumes/design-hcc*sigs.tsv > ${fslanatdir}design/Extras/Volumes/design-hcc_shapemin_shapemax.tsv
				rm ${fslanatdir}design/Extras/Volumes/*shapes*
			
			elif [[ $fslselect == 4 ]]
			# FSL analysis is skipped
			then
				echo FSL analysis skipped
				break

			else
				echo Invalid selection.
			fi
		done
	
	elif [[ $structselect == 4 ]]
	# Lesion mask volumes
	then
		rm ${derivdir}lesion-masks/oedema_vol.csv
		echo vox vols > ${derivdir}lesion-masks/temp-vols.csv
		echo sub-id > ${derivdir}lesion-masks/temp-ids.csv
		for subdir in ${rawdir}sub-*
		do
			subname=${subdir##*/}
			echo $subname >> ${derivdir}lesion-masks/temp-ids.csv
			mkdir -p ${derivdir}lesion-masks/${subname}
			# Files matching the wildcard for the oedema masks are saved to an array, which is then
			# evaluated for length > 0 to prevent errors when trying to skip over subjects for whom a
			# mask doesn't exist. The '(N)' flag is similarly used to prevent loop breaks when the 
			# wildcard isn't matched
			maskfile=(${derivdir}lesion-masks/${subname}/${subname}*oedema.nii.gz(N))
			if [[ ${#maskfile[@]} -gt 0 ]]
			then
				fslstats ${maskfile[1]} -V >> ${derivdir}lesion-masks/temp-vols.csv
			else
				echo NA NA >> ${derivdir}lesion-masks/temp-vols.csv
			fi
		done
		paste -d ' ' ${derivdir}lesion-masks/temp*s.csv > ${derivdir}lesion-masks/oedema_vol.csv
		rm ${derivdir}lesion-masks/temp*s.csv
		
	elif [[ $structselect == 5 ]]
	# Structural analysis is skipped
	then
		echo Structural analysis skipped.
		break

	else
		echo Invalid selection.
	fi
done