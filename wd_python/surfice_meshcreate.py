import gl
gl.resetdefaults()
mesh_dir = f'~/Desktop/Display_Volumes/'
hemis = ['lh', 'rh']
regions = ['Accu', 'Amyg', 'Caud', 'Hipp', 'Pall', 'Puta', 'Thal']
groups = ['all', 'hcc', 'ncc']

for i in groups:
	for j in regions:
		for k in hemis:
			niiname = f'{mesh_dir}{i}.{j}.{k}.nii.gz'
			meshname = f'{mesh_dir}{i}.{j}.{k}.obj'
			gl.meshcreate(niiname, meshname, 0.05, 1, 1, 2)