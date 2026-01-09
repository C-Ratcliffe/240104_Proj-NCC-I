# set up the env
import gl

# mesh
gl.resetdefaults()
mesh_file = f'display_vols/fs/mni/wholebrain-bi_seg.mz3'
gl.meshloadbilateral(mesh_file)
gl.shadername('phong_matte')
gl.shaderforbackgroundonly(1)
gl.shaderambientocclusion(.35)
gl.orientcubevisible(0)
gl.colorbarvisible(0)
gl.overlaycloseall()

# define the activation loop

nets = ['cyst', 'oedema']

for net in nets:
	# overlay setup
	activation = f'display_vols/240104_Proj-NCC-I/func/func.{net}.nonthr.nii'
	gl.overlayload(activation)
	gl.overlaycolorname(1, 'red-yellow')
	gl.overlayminmax(1, 0.0001, 1.5)
	gl.overlayload(activation)
	gl.overlaycolorname(2, 'blue-green')
	gl.overlayminmax(2, -1.5, -0.0001)
	gl.meshcurv()
	gl.shaderadjust('Diffuse', 1)
	# screenshot name 1
	gl.viewaxial(0)
	ss1 = f'{activation}_ax.png'
	gl.savebmpxy(ss1, 3000, 2000)
	gl.viewcoronal(0)
	ss2 = f'{activation}_cor.png'
	gl.savebmpxy(ss2, 3000, 2000)
	gl.viewsagittal(0)
	ss3 = f'{activation}_sag.png'
	gl.savebmpxy(ss3, 3000, 2000)
	gl.overlaycloseall()

# define the node loop

gl.shaderxray(0.5, 1)
nets = ['cystnode', 'oedemanode']

for net in nets:
	# overlay setup
	nodes = f'display_vols/240104_Proj-NCC-I/func/func.{net}.node'
	gl.nodeload(nodes)
	gl.nodethresh(2.1, 11)
	gl.nodesize(1, 0)
	gl.shaderadjust('Diffuse', 1)
	# screenshot name 1
	gl.viewaxial(0)
	ss1 = f'{nodes}_ax.png'
	gl.savebmpxy(ss1, 3000, 2000)
	gl.viewcoronal(0)
	ss2 = f'{nodes}_cor.png'
	gl.savebmpxy(ss2, 3000, 2000)
	gl.viewsagittal(0)
	ss3 = f'{nodes}_sag.png'
	gl.savebmpxy(ss3, 3000, 2000)
	gl.overlaycloseall()