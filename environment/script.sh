# Script de copia das chaves.
KEYPATH='/vagrant/keys'
mkdir -p /root/.ssh
cp $KEYPATH/key /root/.ssh/id_rsa
cp $KEYPATH/key /root/.ssh/id_rsa.pub
cp $KEYPATH/key.pub /root/.ssh/authorized_keys
chmod 400 /root/.ssh/id*

cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

