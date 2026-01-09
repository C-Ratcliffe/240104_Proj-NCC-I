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
gl.shaderxray(0.5, 1)

# define the loop

#nets = ['func.all', 'func.fsz', 'func.rec', 'diff.all', 'diff.fsz', 'diff.rec']
nets = ['func.all', 'func.fsz', 'func.rec', 'diff.all', 'diff.fsz', 'diff.rec']

for net in nets:
	# overlay setup
	nodes = f'display_vols/240104_Proj-NCC-I/nets/subnetwork-{net}.node'
	gl.nodeload(nodes)
	gl.nodethresh(0, 5)
	gl.edgesize(1, 0)
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