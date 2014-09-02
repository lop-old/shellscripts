if [ -f ~/.ssh/id_rsa.pub ]; then
	echo "Using existing key"
else
	echo "Generating a new key"
	ssh-keygen
fi

if [ ! -f ~/.ssh/id_rsa.pub ]; then
	echo "Failed to generate a public key!"
	exit 1
fi

chmod 700 ~/.ssh
chmod 600 ~/.ssh/*

if [ -z ${1} ]; then
	echo "Key is ready to use."
else
	# copy pub key to remote host
	scp ~/.ssh/id_rsa.pub $1:~/.ssh/authorized_keys
	ssh $1 'chmod 700 ~/.ssh'
	ssh $1 'chmod 600 ~/.ssh/*'
	echo "Key installed to ${1}"
fi

