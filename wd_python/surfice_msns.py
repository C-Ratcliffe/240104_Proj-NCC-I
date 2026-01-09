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

# define the loop

overlays = ['all', 'hcc', 'ncc', 'nim']

for overlay in overlays:
	# overlay setup
	overlay_lh = f'display_vols/240104_Proj-NCC-I/msns/{overlay}.lh.annot'
	overlay_rh = f'display_vols/240104_Proj-NCC-I/msns/{overlay}.rh.annot'
	gl.overlayload(overlay_lh)
	gl.overlayload(overlay_rh)
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