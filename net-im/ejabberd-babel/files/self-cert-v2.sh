#! /bin/sh
#
# self-cert.sh for ejabberd, stolen from:
# mkimapdcert,v 1.1 2001/01/02 03:54:25 drobbins Exp
#
# Copyright 2000 Double Precision, Inc.  See COPYING for
# distribution information.
#
# This is a short script to quickly generate a self-signed X.509 key for
# eJabberd.  Normally this script would get called by an automatic
# package installation routine.

test -x /usr/bin/openssl || exit 0

prefix="/usr"
pemfile="/etc/jabber/ssl.pem"
randfile="/etc/jabber/ssl.rand"

if test -f $pemfile
then
	echo "$pemfile already exists."
	exit 1
fi

cp /dev/null $pemfile
chmod 640 $pemfile
chown root:jabber $pemfile

cleanup() {
	rm -f $pemfile
	rm -f $randfile
	exit 1
}

dd if=/dev/urandom of=$randfile count=1 2>/dev/null
/usr/bin/openssl req -new -x509 -days 365 -nodes \
	-config /etc/jabber/ssl.cnf -out $pemfile -keyout $pemfile || cleanup
/usr/bin/openssl gendh -rand $randfile 512 >> $pemfile || cleanup
/usr/bin/openssl x509 -subject -dates -fingerprint -noout -in $pemfile || cleanup
rm -f $randfile

