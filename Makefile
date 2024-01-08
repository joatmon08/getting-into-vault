boundary-auth:
	boundary authenticate password

boundary-ssh:
	boundary connect ssh -target-name vault-servers-ssh -target-scope-name vault