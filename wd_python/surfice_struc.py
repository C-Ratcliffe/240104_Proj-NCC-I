# set up the env
import gl

# mesh
gl.resetdefaults()
mesh_file = f'display_vols/fs/mni/lh.inflated'
gl.meshloadbilateral(mesh_file)
gl.shadername('phong_matte')
gl.shaderforbackgroundonly(1)
gl.shaderambientocclusion(.35)
gl.orientcubevisible(0)
gl.colorbarvisible(0)
gl.overlaycloseall()

overlay = f'display_vols/fs/mni/lh.aparc.a2009s.annot'
gl.overlayload(overlay)
gl.shaderadjust('Diffuse', 1)
# screenshot name 1
gl.hemispherepry(-105)
gl.hemispheredistance(0.7)
gl.azimuthelevation(180, -20)
ss1 = f'{overlay}_a180_e-20.png'
gl.savebmpxy(ss1, 3000, 2000)
gl.hemispherepry(75)
gl.hemispheredistance(0.69)
gl.azimuthelevation(180, 20)
ss2 = f'{overlay}_a180_e20.png'
gl.savebmpxy(ss2, 3000, 2000)
gl.overlaycloseall()

gl.resetdefaults()
mesh_file = f'display_vols/fsl/all.lh.obj'
gl.meshloadbilateral(mesh_file)
gl.shadername('phong_matte')
gl.shaderforbackgroundonly(1)
gl.shaderambientocclusion(.35)
gl.orientcubevisible(0)
gl.colorbarvisible(0)
gl.overlaycloseall()

overlay_lh = f'display_vols/fsl/all_lh.nii.gz'
overlay_rh = f'display_vols/fsl/all_rh.nii.gz'
gl.overlayload(overlay_lh)
gl.overlayload(overlay_rh)
gl.overlaycolorname(1, 'Viridis')
gl.overlayminmax(1, 1, 7)
gl.overlaycolorname(2, 'Viridis')
gl.overlayminmax(2, 8, 14)
gl.shaderadjust('Diffuse', 1)
# screenshot name 1
gl.hemispherepry(-105)
gl.hemispheredistance(0.1)
gl.azimuthelevation(180, -20)
ss1 = f'{overlay_lh}_a180_e-20.png'
gl.savebmpxy(ss1, 3000, 2000)
gl.hemispherepry(75)
gl.hemispheredistance(0.1)
gl.azimuthelevation(180, 20)
ss2 = f'{overlay_lh}_a180_e20.png'
gl.savebmpxy(ss2, 3000, 2000)
gl.overlaycloseall()