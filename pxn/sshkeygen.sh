
echo
# generate a public key if needed
if [ -f ~/.ssh/id_rsa.pub ]; then
	echo "Using existing key.."
else
	echo "Generating a new key.."
	ssh-keygen || exit 1
fi

# public key exists?
if [ ! -f ~/.ssh/id_rsa.pub ]; then
	echo "Failed to generate a public key!"
	exit 1
fi

chmod 700 ~/.ssh
chmod 600 ~/.ssh/*

if [ -z ${1} ]; then
	echo "Key is ready to use :-)"
else
	# install pub key to remote host
	PORT=""
	if [[ ${2} == \-p* ]]; then
		PORT="${2}"
	fi
	ssh-copy-id -i ~/.ssh/id_rsa.pub "${1}" ${PORT} || exit 1
#	ssh "${1}" 'chmod 700 ~/.ssh && chmod 600 ~/.ssh/*' || exit 1
	echo "Key installed to ${1}"
fi
echo

