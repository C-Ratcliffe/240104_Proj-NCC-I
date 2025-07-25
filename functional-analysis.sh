# Functional analysis
while true
do
	echo Choose option:
	echo
	echo 1. Package install
	echo 2. fMRIprep
	echo 3. Mask formatting
	echo 4. Skip functional analysis
	echo
	read "funcselect?Selection (1/4): "

	if [[ $funcselect == 1 ]]
	# Package install
	then
		python3 -m pip install fmriprep-docker
	
	elif [[ $funcselect == 2 ]]
	# fmri preprocessing analysis
	then
		open -a Docker
		fmridir=${derivdir}fmriprep/
		workdir=${fmridir}workdata/
		fsdir=${derivdir}freesurfer-7.4.1/
		for sub in ${fsdir}sub*/
		do
			subdir=${sub##*sub-}
			subname=${subdir%%/}
			if [[ ! -e ${fsdir}fsaverage ]]
			then
				cp -r ${fsdir}fsaverage ${fmridir}sourcedata/freesurfer/
			fi
			fmriprep-docker \
				$rawdir \
				$fmridir --participant-label \
				$subname \
				--use-syn-sdc \
				--ignore fieldmaps \
				--fs-license-file ~/freesurfer/license.txt \
				-w $workdir \
				--output-spaces MNI152NLin2009cAsym \
				--clean-workdir \
				--fs-subjects-dir ${fsdir}
		done
		
	elif [[ $funcselect == 3 ]]
	# mask formatting
	then
		conndir=${derivdir}conn/
		mkdir -p ${conndir}n-ncc_n-hc/rois/ ${conndir}n-ncc_n-hc/cysts/ ${conndir}n-ncc_n-hc/oedema/
		for sub in ${conndir}sub-*/
		do
			subdir=${sub##*sub-}
			subname=${subdir%%/}
			sublesion=${derivdir}lesion-masks/sub-${subname}/sub-${subname}
			if [[ ! -e ${sublesion}_space-T1w_mask-cyst.nii.gz ]]
			then 
				mrcalc ${rawdir}sub-${sub}/anat/sub-${sub}_T1w.nii.gz 0 -mult ${sublesion}_space-T1w_mask-cyst.nii.gz
			else
				echo Cyst mask present.
			fi
			if [[ ! -e ${sublesion}_space-T1w_mask-oedema.nii.gz ]]
			then 
				cp ${sublesion}_space-T1w_mask-cyst.nii.gz ${sublesion}_space-T1w_mask-oedema.nii.gz
			else
				echo Cyst mask present.
			fi

			cp ${sublesion}_space-T1w_mask-cyst.nii.gz ${conndir}n-ncc_n-hc/cysts/sub-${subname}_cyst.nii.gz
			antsApplyTransforms -i ${conndir}n-ncc_n-hc/cysts/sub-${subname}_cyst.nii.gz \
				-r ${sub}anat/sub-${subname}_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz \
				-t ${sub}anat/sub-${subname}_from-T1w_to-MNI152NLin2009cAsym_mode-image_xfm.h5 \
				-n Multilabel \
				-o ${conndir}n-ncc_n-hc/cysts/sub-${subname}_cyst.nii
			cp ${sublesion}_space-T1w_mask-oedema.nii.gz ${conndir}n-ncc_n-hc/oedema/sub-${subname}_oedema.nii.gz
			antsApplyTransforms -i ${conndir}n-ncc_n-hc/oedema/sub-${subname}_oedema.nii.gz \
				-r ${sub}anat/sub-${subname}_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz \
				-t ${sub}anat/sub-${subname}_from-T1w_to-MNI152NLin2009cAsym_mode-image_xfm.h5 \
				-n Multilabel \
				-o ${conndir}n-ncc_n-hc/oedema/sub-${subname}_oedema.nii
			maskfilter ${conndir}n-ncc_n-hc/cysts/sub-${subname}_cyst.nii dilate -npass 2 ${conndir}n-ncc_n-hc/cysts/sub-${subname}_cyst.nii -force
		done
		rm ${conndir}n-ncc_n-hc/cysts/sub-*.nii.gz ${conndir}n-ncc_n-hc/oedema/sub-*.nii.gz

	elif [[ $funcselect == 4 ]]
	# Functional analysis is skipped
	then
		echo Functional analysis skipped.
		break

	else
		echo Invalid selection.
	fi
done