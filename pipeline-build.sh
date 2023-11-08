echo "Cleaning up old artifact location (if any)"
if [ -d ${WORKSPACE}/artifacts ]
then
	rm -rf ${WORKSPACE}/artifacts
fi

sed -i "s/version:.*/version: ${REL_NO}/" ${WORKSPACE}/galaxy.yml
/opt/python-3.9.6/bin/ansible --version
/opt/python-3.9.6/bin/ansible-galaxy collection build -f
mkdir -p ${WORKSPACE}/artifacts/$REL_NO
if [ $? -eq 0 ]
then
     echo "Signing the Package"
     set +x
     echo ${RPMPWD} | gpg -u "Dell Inc., PGRE 2012" --detach-sign --digest-algo SHA512 --default-key --no-tty --batch --passphrase-fd 0 --yes -v -v dellemc-openmanage-$REL_NO.tar.gz 
     set -x
     mv ${WORKSPACE}/dellemc-openmanage-$REL_NO.tar.gz.sig ${WORKSPACE}/artifacts/$REL_NO/dellemc-openmanage-$REL_NO.tar.gz.sig
     mv ${WORKSPACE}/dellemc-openmanage-$REL_NO.tar.gz ${WORKSPACE}/artifacts/$REL_NO/dellemc-openmanage-$REL_NO.tar.gz
fi

if [ $? -eq 0 ]
then
echo "jenkins-build=${BUILD_NUMBER}" > ${WORKSPACE}/BuildNumber.txt
echo "REL_NO=${REL_NO}" >> ${WORKSPACE}/BuildNumber.txt
fi
