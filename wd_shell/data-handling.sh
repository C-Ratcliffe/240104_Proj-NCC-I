# Data Handling
while true
do
	echo Choose option:
	echo
	echo 1. Package install
	echo 2. HCP reorganisation
	echo 3. NIMHANS data reorganisation
	echo 4. HCP regridding
	echo 5. T1/T2w ratio generation
	echo 6. Skip data handling
	echo
	read "dataselect?Selection (1/6): "

	if [[ $dataselect == 1 ]]
	# Package install
	then
		# Needed to rename on Mac
		brew install rename
		
	elif [[ $dataselect == 2 ]]
	# HCP reorganisation
	then
		# HCP-specific aliases
		indir=~/HCP_data/
		declare -i k=930
		# All of the HCP files are copied over to the sourcedir (no jsons included)
		for i in ${indir}*/
		do
			subnum=sub-$k
			mkdir -p ${sourcedir}${subnum}/convert/
			for j in $(find $i -name '*.nii.gz')
			do
				scan=${j##*_3T_}
				if [ ! -e ${sourcedir}${subnum}/convert/${subnum}_${scan} ]
				then
					cp $j ${sourcedir}${subnum}/convert/${subnum}_${scan}
				fi
			done
			for j in $(find $i -name '*.bval')
			do
				scan=${j##*_3T_}
				if [ ! -e ${sourcedir}${subnum}/convert/${subnum}_${scan} ]
				then
					cp $j ${sourcedir}${subnum}/convert/${subnum}_${scan}
				fi
			done
			for j in $(find $i -name '*.bvec')
			do
				scan=${j##*_3T_}
				if [ ! -e ${sourcedir}${subnum}/convert/${subnum}_${scan} ]
				then
					cp $j ${sourcedir}${subnum}/convert/${subnum}_${scan}
				fi
			done
			k+=1
		done
		# k is unset as an integer, to prevent conflicts
		declare +i k
			
	elif [[ $dataselect == 3 ]]
	# BIDS renaming	
	then
		# All of the scans are converted from DICOMs (if required), then copied to their rawdata folder
		for ptc in ${sourcedir}sub-*
		do
			sub=${ptc##*/}
			outdir=${rawdir}${sub}/
			mkdir -p ${ptc}/convert ${outdir}anat/ ${outdir}dwi/ ${outdir}fmap/ ${outdir}func/ ${outdir}swi/
			/Applications/MRIcroGL.app/Contents/Resources/dcm2niix -o ${ptc}/convert -f ${sub}_%d -z y $ptc
			# aliases are set for the current subject, which are used to copy over and rename the files for each modality
			# T1w
			if [ -e ${sourcedir}${sub}/convert/${sub}_t1_mprage_sag_NO_GRAPPA.json ]
			then
				T1w=t1_mprage_sag_NO_GRAPPA
				cp ${sourcedir}${sub}/convert/${sub}_${T1w}.* ${outdir}anat/
				rename -f "s/${T1w}/T1w/g" ${outdir}anat/*
			elif [ -e ${sourcedir}${sub}/convert/${sub}_T1w_MPR1.json ]
			then
				T1w=T1w_MPR1
				cp ${sourcedir}${sub}/convert/${sub}_${T1w}.* ${outdir}anat/
				rename -f "s/${T1w}/T1w/g" ${outdir}anat/*
			fi
			# T2w
			if [ -e ${sourcedir}${sub}/convert/${sub}_t2_space_sag_p3_iso.json ]
			then
				T2w=t2_space_sag_p3_iso
				cp ${sourcedir}${sub}/convert/${sub}_${T2w}.* ${outdir}anat/
				rename -f "s/${T2w}/T2w/g" ${outdir}anat/*
			elif [ -e ${sourcedir}${sub}/convert/${sub}_t2_space_sag_p3_isoa.json ]
			then
				T2w=t2_space_sag_p3_isoa
				cp ${sourcedir}${sub}/convert/${sub}_${T2w}.* ${outdir}anat/
				rename -f "s/${T2w}/T2w/g" ${outdir}anat/*
			elif [ -e ${sourcedir}${sub}/convert/${sub}_t2_tse_ocor.json ]
			then
				T2w=t2_tse_ocor
				cp ${sourcedir}${sub}/convert/${sub}_${T2w}.* ${outdir}anat/
				rename -f "s/${T2w}/T2w/g" ${outdir}anat/*
			elif [ -e ${sourcedir}${sub}/convert/${sub}_T2w_SPC1.nii.gz ]
			then
				T2w=T2w_SPC1
				cp ${sourcedir}${sub}/convert/${sub}_${T2w}.* ${outdir}anat/
				rename -f "s/${T2w}/T2w/g" ${outdir}anat/*
			fi
			# FLAIR
			if [ -e ${sourcedir}${sub}/convert/${sub}_t2_space_dark-fluid_sag_p2_ns-t2prep.json ]
			then
				flair=t2_space_dark-fluid_sag_p2_ns-t2prep
				cp ${sourcedir}${sub}/convert/${sub}_${flair}.* ${outdir}anat/
				rename -f "s/${flair}/FLAIR/g" ${outdir}anat/*
			elif [ -e ${sourcedir}${sub}/convert/${sub}_3D_flair_space_dark-fluid_sag_p2_ns-t2prep.json ]
			then
				flair=3D_flair_space_dark-fluid_sag_p2_ns-t2prep
				cp ${sourcedir}${sub}/convert/${sub}_${flair}.* ${outdir}anat/
				rename -f "s/${flair}/FLAIR/g" ${outdir}anat/*
			fi
			# DIR
			if [ -e ${sourcedir}${sub}/convert/${sub}_dir_space_sag_p2_iso.json ]
			then
				dir=dir_space_sag_p2_iso
				cp ${sourcedir}${sub}/convert/${sub}_${dir}.* ${outdir}swi/
				rename -f "s/${dir}/acq-dir_swi/g" ${outdir}swi/*
			fi
			# CISS
			if [ -e ${sourcedir}${sub}/convert/${sub}_t2_space_ciss_tra_iso.json ]
			then
				ciss=t2_space_ciss_tra_iso
				cp ${sourcedir}${sub}/convert/${sub}_${ciss}.* ${outdir}swi/
				rename -f "s/${ciss}/acq-ciss_swi/g" ${outdir}swi/*
			fi
			# SWI
			if [ -e ${sourcedir}${sub}/convert/${sub}_t2_swi_tra_p2_2mm_SWI.json ]
			then
				swi=t2_swi_tra_p2_2mm_SWI
				cp ${sourcedir}${sub}/convert/${sub}_${swi}.* ${outdir}swi/
				rename -f "s/${swi}/swi/g" ${outdir}swi/*
			fi
			# DWI AP
			if [ -e ${sourcedir}${sub}/convert/${sub}_Diffusion_Kurtosis_FW_S2.json ]
			then
				dwiap=Diffusion_Kurtosis_FW_S2
				cp ${sourcedir}${sub}/convert/${sub}_${dwiap}.* ${outdir}dwi/
				rename -f "s/${dwiap}/dir-AP_dwi/g" ${outdir}dwi/*
			fi
			# DWI PA
			if [ -e ${sourcedir}${sub}/convert/${sub}_Diffusion_Kurtosis_rev.json ]
			then
				dwipa=Diffusion_Kurtosis_rev
				cp ${sourcedir}${sub}/convert/${sub}_${dwipa}.* ${outdir}dwi/
				rename -f "s/${dwipa}/dir-PA_dwi/g" ${outdir}dwi/*
			fi
			# DWI LR
			if [ -e ${sourcedir}${sub}/convert/${sub}_DWI_dir97_LR.nii.gz ]
			then
				dwilr=DWI_dir97_LR
				cp ${sourcedir}${sub}/convert/${sub}_${dwilr}.* ${outdir}dwi/
				rename -f "s/${dwilr}/dir-LR_dwi/g" ${outdir}dwi/*
			fi
			# DWI RL
			if [ -e ${sourcedir}${sub}/convert/${sub}_DWI_dir97_RL.nii.gz ]
			then
				dwirl=DWI_dir97_RL
				cp ${sourcedir}${sub}/convert/${sub}_${dwirl}.* ${outdir}dwi/
				rename -f "s/${dwirl}/dir-RL_dwi/g" ${outdir}dwi/*
			fi
			# rsfMRI
			if [ -e ${sourcedir}${sub}/convert/${sub}_MB_ep2d_bold_s8.json ]
			then
				rsfmri=MB_ep2d_bold_s8
				cp ${sourcedir}${sub}/convert/${sub}_${rsfmri}.* ${outdir}func/
				rename -f "s/${rsfmri}/task-rest_bold/g" ${outdir}func/*
			fi
			# rsfMRI LR
			if [ -e ${sourcedir}${sub}/convert/${sub}_rfMRI_REST1_LR.nii.gz ]
			then
				rsfmrilr=rfMRI_REST1_LR
				cp ${sourcedir}${sub}/convert/${sub}_${rsfmrilr}.* ${outdir}func/
				rename -f "s/${rsfmrilr}/task-rest_echo-1_bold/g" ${outdir}func/*
			fi
			# rsfMRI RL
			if [ -e ${sourcedir}${sub}/convert/${sub}_rfMRI_REST1_RL.nii.gz ]
			then
				rsfmrirl=rfMRI_REST1_RL
				cp ${sourcedir}${sub}/convert/${sub}_${rsfmrirl}.* ${outdir}func/
				rename -f "s/${rsfmrirl}/task-rest_echo-2_bold/g" ${outdir}func/*
			fi
			# fMap magnitude1
			if [ -e ${sourcedir}${sub}/convert/${sub}_Field_Mapping_e1.json ]
			then
				fmapm1=Field_Mapping_e1
				cp ${sourcedir}${sub}/convert/${sub}_${fmapm1}.* ${outdir}fmap/
				rename -f "s/${fmapm1}/magnitude1/g" ${outdir}fmap/*
			elif [ -e ${sourcedir}${sub}/convert/${sub}_Field_Mapping_e1a.json ]
			then
				fmapm1=Field_Mapping_e1a
				cp ${sourcedir}${sub}/convert/${sub}_${fmapm1}.* ${outdir}fmap/
				rename -f "s/${fmapm1}/magnitude1/g" ${outdir}fmap/*
			elif [ -e ${sourcedir}${sub}/convert/${sub}_FieldMap_Magnitude.nii.gz ]
			then
				fmapm1=FieldMap_Magnitude
				cp ${sourcedir}${sub}/convert/${sub}_${fmapm1}.* ${outdir}fmap/
				rename -f "s/${fmapm1}/magnitude1/g" ${outdir}fmap/*
			fi
			# fMap magnitude2
			if [ -e ${sourcedir}${sub}/convert/${sub}_Field_Mapping_e2.json ]
			then
				fmapm2=Field_Mapping_e2
				cp ${sourcedir}${sub}/convert/${sub}_${fmapm2}.* ${outdir}fmap/
				rename -f "s/${fmapm2}/magnitude2/g" ${outdir}fmap/*
			elif [ -e ${sourcedir}${sub}/convert/${sub}_Field_Mapping_e2a.json ]
			then
				fmapm2=Field_Mapping_e2a
				cp ${sourcedir}${sub}/convert/${sub}_${fmapm2}.* ${outdir}fmap/
				rename -f "s/${fmapm2}/magnitude2/g" ${outdir}fmap/*
			fi
			# fMap phasediff
			if [ -e ${sourcedir}${sub}/convert/${sub}_Field_Mapping_e2_ph.json ]
			then
				fmapp1=Field_Mapping_e2_ph
				cp ${sourcedir}${sub}/convert/${sub}_${fmapp1}.* ${outdir}fmap/
				rename -f "s/${fmapp1}/phasediff/g" ${outdir}fmap/*
			elif [ -e ${sourcedir}${sub}/convert/${sub}_Field_Mapping_e2_pha.json ]
			then
				fmapp1=Field_Mapping_e2_pha
				cp ${sourcedir}${sub}/convert/${sub}_${fmapp1}.* ${outdir}fmap/
				rename -f "s/${fmapp1}/phasediff/g" ${outdir}fmap/*
			elif [ -e ${sourcedir}${sub}/convert/${sub}_FieldMap_Phase.nii.gz ]
			then
				fmapp1=FieldMap_Phase
				cp ${sourcedir}${sub}/convert/${sub}_${fmapp1}.* ${outdir}fmap/
				rename -f "s/${fmapp1}/phasediff/g" ${outdir}fmap/*
			fi
			# fMap epi LR 
			if [ -e ${sourcedir}${sub}/convert/${sub}_3T_SpinEchoFieldMap_LR.nii.gz ]
			then
				fmapselr=3T_SpinEchoFieldMap_LR
				cp ${sourcedir}${sub}/convert/${sub}_${fmapselr}.* ${outdir}fmap/
				rename -f "s/${fmapselr}/dir-LR_epi/g" ${outdir}fmap/*
			fi
			# fMap epi RL
			if [ -e ${sourcedir}${sub}/convert/${sub}_SpinEchoFieldMap_RL.nii.gz ]
			then
				fmapserl=SpinEchoFieldMap_RL
				cp ${sourcedir}${sub}/convert/${sub}_${fmapserl}.* ${outdir}fmap/
				rename -f "s/${fmapserl}/dir-RL_epi/g" ${outdir}fmap/*
			fi
		done
		# empty folders in the rawdata directory are removed
		find "$rawdir" -type d -empty -delete

	elif [[ $dataselect == 4 ]]
	# HCP files are regridded to match NIMHANS data (1mm iso)
	then
		for i in ${rawdir}sub-9[3-9][0-9]/anat/
		do
			subdir=${i##*rawdata/}
			regdir=${derivdir}anat_regrid/${subdir}
			echo mkdir -p ${regdir}
			for j in ${i}*
			do
				sub=${j##*/anat/}
				echo mrgrid ${j} regrid -voxel 1.00 ${regdir}${sub%%.nii.gz}_1mm.nii.gz
			done
		done

	elif [[ $dataselect == 5 ]]
	# Patient T2w scans are coregistered to T1w subject space and used to generate T1w/T2w ratio images
	then
		for i in ${rawdir}sub-0[0-9][0-9]/anat/
		do
			subdir=${i##*rawdata/}
			coregdir=${derivdir}anat_coreg/${subdir}
			ratiodir=${derivdir}anat_ratio/${subdir}
			sub=${subdir%%/anat/}
			mkdir -p ${coregdir} ${ratiodir}
			antsRegistrationSyN.sh -d 3 -t a -f ${i}*T1w.nii.gz -m ${i}*T2w.nii.gz -o ${coregdir}coreg-syn -n 4
			mv ${coregdir}coreg-synWarped.nii.gz ${coregdir}${sub}_space-T1w_T2w.nii.gz
			mv ${coregdir}coreg-syn00GenericAffine.mat ${coregdir}${sub}_space-T2w2T1w_warp.mat
			mv ${coregdir}coreg-synInverseWarped.nii.gz ${coregdir}${sub}_space-T1w2T2w_warp.nii.gz
			fslmaths ${i}*T1w.nii.gz -div ${coregdir}${sub}_space-T1w_T2w.nii.gz ${ratiodir}${sub}_ratio-raw.nii.gz
			fslmaths ${ratiodir}${sub}_ratio-raw.nii.gz -thr 1 -bin ${ratiodir}${sub}_ratio-thr.nii.gz
			fslmaths ${ratiodir}${sub}_ratio-raw.nii.gz -uthr 1 ${ratiodir}${sub}_ratio-uthr.nii.gz
			fslmaths ${ratiodir}${sub}_ratio-thr.nii.gz -add ${ratiodir}${sub}_ratio-uthr.nii.gz ${ratiodir}${sub}_ratio-T1wT2w.nii.gz
			rm ${coregdir}coreg-syn* ${ratiodir}*thr*
		done

	elif [[ $dataselect == 6 ]]
	# Data handling is skipped
	then
		echo Data handling skipped.
		break
		
	else
		echo Invalid selection.
	fi
done