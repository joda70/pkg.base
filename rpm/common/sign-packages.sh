#!/bin/bash
set -ex

required_env="PKG_SIGN_PACKAGES PKG_SIGN_KEY_PASSWORD BUILD_PLATFORM"

for v in ${required_env}; do
    if [ ! -n "${!v}" ]; then
        echo "${v} is required to upload packages"
        exit 1
    fi
done

packages=$(find /packages/${BUILD_PLATFORM} -type f -name '*.rpm')

for p in ${packages}; do

cat <<EOF > sign-rpms.exp
#!/usr/bin/expect
set timeout -1;
spawn -nottyinit rpmsign --addsign ${p};
expect -exact "Enter pass phrase:";
send -- "${PKG_SIGN_KEY_PASSWORD}\r";
expect eof;
EOF
  chmod +x sign-rpms.exp
  ./sign-rpms.exp
done


echo "Done signing!"
