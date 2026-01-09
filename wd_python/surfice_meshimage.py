import gl
gl.resetdefaults()
mesh_dir = f'~/Desktop/Display_Volumes/'			
groups = ['ncc', 'hcc']
			
for i in groups:
		meshbi = f'{mesh_dir}{i}.lh.obj'
		gl.resetdefaults()
		gl.cameradistance(1.4)
		gl.meshloadbilateral(meshbi)
		gl.shadername('phong_matte')
		gl.shaderambientocclusion(.35)
		gl.orientcubevisible(0)
		gl.colorbarvisible(0)
		gl.overlaycloseall()
		overlay_base = f'{mesh_dir}{i}.lh.nii.gz'
		gl.overlayload(overlay_base)
		gl.overlaycolorname(1, 'viridis')
		gl.overlayopacity(1, 50)
		overlay_accu = f'{mesh_dir}{i}.tstat1.Accu.lh.sig.nii.gz'
		gl.overlayload(overlay_accu)
		gl.overlaycolorname(2, 'red-yellow')
		gl.overlayminmax(2, 1.5, 4.5)
		overlay_amyg = f'{mesh_dir}{i}.tstat1.amyg.lh.sig.nii.gz'
		gl.overlayload(overlay_amyg)
		gl.overlaycolorname(3, 'red-yellow')
		gl.overlayminmax(3, 1.5, 4.5)
		overlay_caud = f'{mesh_dir}{i}.tstat1.caud.lh.sig.nii.gz'
		gl.overlayload(overlay_caud)
		gl.overlaycolorname(4, 'red-yellow')
		gl.overlayminmax(4, 1.5, 4.5)
		overlay_hipp = f'{mesh_dir}{i}.tstat1.hipp.lh.sig.nii.gz'
		gl.overlayload(overlay_hipp)
		gl.overlaycolorname(5, 'red-yellow')
		gl.overlayminmax(5, 1.5, 4.5)
		overlay_pall = f'{mesh_dir}{i}.tstat1.pall.lh.sig.nii.gz'
		gl.overlayload(overlay_pall)
		gl.overlaycolorname(6, 'red-yellow')
		gl.overlayminmax(6, 1.5, 4.5)
		overlay_puta = f'{mesh_dir}{i}.tstat1.puta.lh.sig.nii.gz'
		gl.overlayload(overlay_puta)
		gl.overlaycolorname(7, 'red-yellow')
		gl.overlayminmax(7, 1.5, 4.5)
		overlay_thal = f'{mesh_dir}{i}.tstat1.thal.lh.sig.nii.gz'
		gl.overlayload(overlay_thal)
		gl.overlaycolorname(8, 'red-yellow')
		gl.overlayminmax(8, 1.5, 4.5)
		overlay_accu = f'{mesh_dir}{i}.tstat2.Accu.lh.sig.nii.gz'
		gl.overlayload(overlay_accu)
		gl.overlaycolorname(9, 'blue-green')
		gl.overlayminmax(9, 1.5, 4.5)
		overlay_amyg = f'{mesh_dir}{i}.tstat2.amyg.lh.sig.nii.gz'
		gl.overlayload(overlay_amyg)
		gl.overlaycolorname(10, 'blue-green')
		gl.overlayminmax(10, 1.5, 4.5)
		overlay_caud = f'{mesh_dir}{i}.tstat2.caud.lh.sig.nii.gz'
		gl.overlayload(overlay_caud)
		gl.overlaycolorname(11, 'blue-green')
		gl.overlayminmax(11, 1.5, 4.5)
		overlay_hipp = f'{mesh_dir}{i}.tstat2.hipp.lh.sig.nii.gz'
		gl.overlayload(overlay_hipp)
		gl.overlaycolorname(12, 'blue-green')
		gl.overlayminmax(12, 1.5, 4.5)
		overlay_pall = f'{mesh_dir}{i}.tstat2.pall.lh.sig.nii.gz'
		gl.overlayload(overlay_pall)
		gl.overlaycolorname(13, 'blue-green')
		gl.overlayminmax(13, 1.5, 4.5)
		overlay_puta = f'{mesh_dir}{i}.tstat2.puta.lh.sig.nii.gz'
		gl.overlayload(overlay_puta)
		gl.overlaycolorname(14, 'blue-green')
		gl.overlayminmax(14, 1.5, 4.5)
		overlay_thal = f'{mesh_dir}{i}.tstat2.thal.lh.sig.nii.gz'
		gl.overlayload(overlay_thal)
		gl.overlaycolorname(15, 'blue-green')
		gl.overlayminmax(15, 1.5, 4.5)
		gl.shaderadjust('Diffuse', 1)
		gl.hemispherepry(105)
		gl.hemispheredistance(0.8)
		gl.azimuthelevation(180, 0)
		ss1 = f'{i}.tstat1_a180_e20.png'
		gl.savebmpxy(ss1, 2000, 3000)
		gl.hemispherepry(-75)
		gl.hemispheredistance(1)
		gl.azimuthelevation(180, 0)
		ss2 = f'{i}.tstat1_a0_e-20.png'
		gl.savebmpxy(ss2, 2000, 3000)
		gl.overlaycloseall()


groups = ['all']
			
for i in groups:
		meshbi = f'{mesh_dir}{i}.lh.obj'
		gl.resetdefaults()
		gl.cameradistance(1.4)
		gl.meshloadbilateral(meshbi)
		gl.shadername('phong_matte')
		gl.shaderambientocclusion(.35)
		gl.orientcubevisible(0)
		gl.colorbarvisible(0)
		gl.overlaycloseall()
		overlay_base = f'{mesh_dir}{i}.lh.nii.gz'
		gl.overlayload(overlay_base)
		gl.overlaycolorname(1, 'viridis')
		gl.overlayopacity(1, 50)
		overlay_accu = f'{mesh_dir}{i}.tstat1.Accu.lh.sig.nii.gz'
		gl.overlayload(overlay_accu)
		gl.overlaycolorname(2, 'red-yellow')
		gl.overlayminmax(2, 1.5, 4.5)
		overlay_amyg = f'{mesh_dir}{i}.tstat1.amyg.lh.sig.nii.gz'
		gl.overlayload(overlay_amyg)
		gl.overlaycolorname(3, 'red-yellow')
		gl.overlayminmax(3, 1.5, 4.5)
		overlay_caud = f'{mesh_dir}{i}.tstat1.caud.lh.sig.nii.gz'
		gl.overlayload(overlay_caud)
		gl.overlaycolorname(4, 'red-yellow')
		gl.overlayminmax(4, 1.5, 4.5)
		overlay_hipp = f'{mesh_dir}{i}.tstat1.hipp.lh.sig.nii.gz'
		gl.overlayload(overlay_hipp)
		gl.overlaycolorname(5, 'red-yellow')
		gl.overlayminmax(5, 1.5, 4.5)
		overlay_pall = f'{mesh_dir}{i}.tstat1.pall.lh.sig.nii.gz'
		gl.overlayload(overlay_pall)
		gl.overlaycolorname(6, 'red-yellow')
		gl.overlayminmax(6, 1.5, 4.5)
		overlay_puta = f'{mesh_dir}{i}.tstat1.puta.lh.sig.nii.gz'
		gl.overlayload(overlay_puta)
		gl.overlaycolorname(7, 'red-yellow')
		gl.overlayminmax(7, 1.5, 4.5)
		overlay_thal = f'{mesh_dir}{i}.tstat1.thal.lh.sig.nii.gz'
		gl.overlayload(overlay_thal)
		gl.overlaycolorname(8, 'red-yellow')
		gl.overlayminmax(8, 1.5, 4.5)
		overlay_accu = f'{mesh_dir}{i}.tstat4.Accu.lh.sig.nii.gz'
		gl.overlayload(overlay_accu)
		gl.overlaycolorname(9, 'blue-green')
		gl.overlayminmax(9, 1.5, 4.5)
		overlay_amyg = f'{mesh_dir}{i}.tstat4.amyg.lh.sig.nii.gz'
		gl.overlayload(overlay_amyg)
		gl.overlaycolorname(10, 'blue-green')
		gl.overlayminmax(10, 1.5, 4.5)
		overlay_caud = f'{mesh_dir}{i}.tstat4.caud.lh.sig.nii.gz'
		gl.overlayload(overlay_caud)
		gl.overlaycolorname(11, 'blue-green')
		gl.overlayminmax(11, 1.5, 4.5)
		overlay_hipp = f'{mesh_dir}{i}.tstat4.hipp.lh.sig.nii.gz'
		gl.overlayload(overlay_hipp)
		gl.overlaycolorname(12, 'blue-green')
		gl.overlayminmax(12, 1.5, 4.5)
		overlay_pall = f'{mesh_dir}{i}.tstat4.pall.lh.sig.nii.gz'
		gl.overlayload(overlay_pall)
		gl.overlaycolorname(13, 'blue-green')
		gl.overlayminmax(13, 1.5, 4.5)
		overlay_puta = f'{mesh_dir}{i}.tstat4.puta.lh.sig.nii.gz'
		gl.overlayload(overlay_puta)
		gl.overlaycolorname(14, 'blue-green')
		gl.overlayminmax(14, 1.5, 4.5)
		overlay_thal = f'{mesh_dir}{i}.tstat4.thal.lh.sig.nii.gz'
		gl.overlayload(overlay_thal)
		gl.overlaycolorname(15, 'blue-green')
		gl.overlayminmax(15, 1.5, 4.5)
		gl.shaderadjust('Diffuse', 1)
		gl.hemispherepry(105)
		gl.hemispheredistance(0.8)
		gl.azimuthelevation(180, 0)
		ss1 = f'{i}.tstat1_a180_e20.png'
		gl.savebmpxy(ss1, 2000, 3000)
		gl.hemispherepry(-75)
		gl.hemispheredistance(1)
		gl.azimuthelevation(180, 0)
		ss2 = f'{i}.tstat1_a0_e-20.png'
		gl.savebmpxy(ss2, 2000, 3000)
		gl.overlaycloseall()
		
		overlay_base = f'{mesh_dir}{i}.lh.nii.gz'
		gl.overlayload(overlay_base)
		gl.overlaycolorname(1, 'viridis')
		gl.overlayopacity(1, 50)
		overlay_accu = f'{mesh_dir}{i}.tstat2.Accu.lh.sig.nii.gz'
		gl.overlayload(overlay_accu)
		gl.overlaycolorname(2, 'red-yellow')
		gl.overlayminmax(2, 1.5, 4.5)
		overlay_amyg = f'{mesh_dir}{i}.tstat2.amyg.lh.sig.nii.gz'
		gl.overlayload(overlay_amyg)
		gl.overlaycolorname(3, 'red-yellow')
		gl.overlayminmax(3, 1.5, 4.5)
		overlay_caud = f'{mesh_dir}{i}.tstat2.caud.lh.sig.nii.gz'
		gl.overlayload(overlay_caud)
		gl.overlaycolorname(4, 'red-yellow')
		gl.overlayminmax(4, 1.5, 4.5)
		overlay_hipp = f'{mesh_dir}{i}.tstat2.hipp.lh.sig.nii.gz'
		gl.overlayload(overlay_hipp)
		gl.overlaycolorname(5, 'red-yellow')
		gl.overlayminmax(5, 1.5, 4.5)
		overlay_pall = f'{mesh_dir}{i}.tstat2.pall.lh.sig.nii.gz'
		gl.overlayload(overlay_pall)
		gl.overlaycolorname(6, 'red-yellow')
		gl.overlayminmax(6, 1.5, 4.5)
		overlay_puta = f'{mesh_dir}{i}.tstat2.puta.lh.sig.nii.gz'
		gl.overlayload(overlay_puta)
		gl.overlaycolorname(7, 'red-yellow')
		gl.overlayminmax(7, 1.5, 4.5)
		overlay_thal = f'{mesh_dir}{i}.tstat2.thal.lh.sig.nii.gz'
		gl.overlayload(overlay_thal)
		gl.overlaycolorname(8, 'red-yellow')
		gl.overlayminmax(8, 1.5, 4.5)
		overlay_accu = f'{mesh_dir}{i}.tstat5.Accu.lh.sig.nii.gz'
		gl.overlayload(overlay_accu)
		gl.overlaycolorname(9, 'blue-green')
		gl.overlayminmax(9, 1.5, 4.5)
		overlay_amyg = f'{mesh_dir}{i}.tstat5.amyg.lh.sig.nii.gz'
		gl.overlayload(overlay_amyg)
		gl.overlaycolorname(10, 'blue-green')
		gl.overlayminmax(10, 1.5, 4.5)
		overlay_caud = f'{mesh_dir}{i}.tstat5.caud.lh.sig.nii.gz'
		gl.overlayload(overlay_caud)
		gl.overlaycolorname(11, 'blue-green')
		gl.overlayminmax(11, 1.5, 4.5)
		overlay_hipp = f'{mesh_dir}{i}.tstat5.hipp.lh.sig.nii.gz'
		gl.overlayload(overlay_hipp)
		gl.overlaycolorname(12, 'blue-green')
		gl.overlayminmax(12, 1.5, 4.5)
		overlay_pall = f'{mesh_dir}{i}.tstat5.pall.lh.sig.nii.gz'
		gl.overlayload(overlay_pall)
		gl.overlaycolorname(13, 'blue-green')
		gl.overlayminmax(13, 1.5, 4.5)
		overlay_puta = f'{mesh_dir}{i}.tstat5.puta.lh.sig.nii.gz'
		gl.overlayload(overlay_puta)
		gl.overlaycolorname(14, 'blue-green')
		gl.overlayminmax(14, 1.5, 4.5)
		overlay_thal = f'{mesh_dir}{i}.tstat5.thal.lh.sig.nii.gz'
		gl.overlayload(overlay_thal)
		gl.overlaycolorname(15, 'blue-green')
		gl.overlayminmax(15, 1.5, 4.5)
		gl.shaderadjust('Diffuse', 1)
		gl.hemispherepry(105)
		gl.hemispheredistance(0.8)
		gl.azimuthelevation(180, 0)
		ss1 = f'{i}.tstat2_a180_e20.png'
		gl.savebmpxy(ss1, 2000, 3000)
		gl.hemispherepry(-75)
		gl.hemispheredistance(1)
		gl.azimuthelevation(180, 0)
		ss2 = f'{i}.tstat2_a0_e-20.png'
		gl.savebmpxy(ss2, 2000, 3000)
		gl.overlaycloseall()
		
		overlay_base = f'{mesh_dir}{i}.lh.nii.gz'
		gl.overlayload(overlay_base)
		gl.overlaycolorname(1, 'viridis')
		gl.overlayopacity(1, 50)
		overlay_accu = f'{mesh_dir}{i}.tstat3.Accu.lh.sig.nii.gz'
		gl.overlayload(overlay_accu)
		gl.overlaycolorname(2, 'red-yellow')
		gl.overlayminmax(2, 1.5, 4.5)
		overlay_amyg = f'{mesh_dir}{i}.tstat3.amyg.lh.sig.nii.gz'
		gl.overlayload(overlay_amyg)
		gl.overlaycolorname(3, 'red-yellow')
		gl.overlayminmax(3, 1.5, 4.5)
		overlay_caud = f'{mesh_dir}{i}.tstat3.caud.lh.sig.nii.gz'
		gl.overlayload(overlay_caud)
		gl.overlaycolorname(4, 'red-yellow')
		gl.overlayminmax(4, 1.5, 4.5)
		overlay_hipp = f'{mesh_dir}{i}.tstat3.hipp.lh.sig.nii.gz'
		gl.overlayload(overlay_hipp)
		gl.overlaycolorname(5, 'red-yellow')
		gl.overlayminmax(5, 1.5, 4.5)
		overlay_pall = f'{mesh_dir}{i}.tstat3.pall.lh.sig.nii.gz'
		gl.overlayload(overlay_pall)
		gl.overlaycolorname(6, 'red-yellow')
		gl.overlayminmax(6, 1.5, 4.5)
		overlay_puta = f'{mesh_dir}{i}.tstat3.puta.lh.sig.nii.gz'
		gl.overlayload(overlay_puta)
		gl.overlaycolorname(7, 'red-yellow')
		gl.overlayminmax(7, 1.5, 4.5)
		overlay_thal = f'{mesh_dir}{i}.tstat3.thal.lh.sig.nii.gz'
		gl.overlayload(overlay_thal)
		gl.overlaycolorname(8, 'red-yellow')
		gl.overlayminmax(8, 1.5, 4.5)
		overlay_accu = f'{mesh_dir}{i}.tstat6.Accu.lh.sig.nii.gz'
		gl.overlayload(overlay_accu)
		gl.overlaycolorname(9, 'blue-green')
		gl.overlayminmax(9, 1.5, 4.5)
		overlay_amyg = f'{mesh_dir}{i}.tstat6.amyg.lh.sig.nii.gz'
		gl.overlayload(overlay_amyg)
		gl.overlaycolorname(10, 'blue-green')
		gl.overlayminmax(10, 1.5, 4.5)
		overlay_caud = f'{mesh_dir}{i}.tstat6.caud.lh.sig.nii.gz'
		gl.overlayload(overlay_caud)
		gl.overlaycolorname(11, 'blue-green')
		gl.overlayminmax(11, 1.5, 4.5)
		overlay_hipp = f'{mesh_dir}{i}.tstat6.hipp.lh.sig.nii.gz'
		gl.overlayload(overlay_hipp)
		gl.overlaycolorname(12, 'blue-green')
		gl.overlayminmax(12, 1.5, 4.5)
		overlay_pall = f'{mesh_dir}{i}.tstat6.pall.lh.sig.nii.gz'
		gl.overlayload(overlay_pall)
		gl.overlaycolorname(13, 'blue-green')
		gl.overlayminmax(13, 1.5, 4.5)
		overlay_puta = f'{mesh_dir}{i}.tstat6.puta.lh.sig.nii.gz'
		gl.overlayload(overlay_puta)
		gl.overlaycolorname(14, 'blue-green')
		gl.overlayminmax(14, 1.5, 4.5)
		overlay_thal = f'{mesh_dir}{i}.tstat6.thal.lh.sig.nii.gz'
		gl.overlayload(overlay_thal)
		gl.overlaycolorname(15, 'blue-green')
		gl.overlayminmax(15, 1.5, 4.5)
		gl.shaderadjust('Diffuse', 1)
		gl.hemispherepry(105)
		gl.hemispheredistance(0.8)
		gl.azimuthelevation(180, 0)
		ss1 = f'{i}.tstat3_a180_e20.png'
		gl.savebmpxy(ss1, 2000, 3000)
		gl.hemispherepry(-75)
		gl.hemispheredistance(1)
		gl.azimuthelevation(180, 0)
		ss2 = f'{i}.tstat3_a0_e-20.png'
		gl.savebmpxy(ss2, 2000, 3000)
		gl.overlaycloseall()