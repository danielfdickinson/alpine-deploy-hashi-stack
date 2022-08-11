#!/bin/sh
[ -d /etc/unbound/dnssec-root ] && {
	[ ! -s /etc/unbound/dnssec-root/trusted-key.key ] && {
		cp /usr/share/dnssec-root/trusted-key.key /etc/unbound/dnssec-root/trusted-key.key
		chown unbound:unbound /etc/unbound/dnssec-root/trusted-key.key
		wget -q -O /etc/unbound/dnssec-root/named.cache https://internic.net/domain/named.cache
	}
	[ ! -s /etc/unbound/dnssec-root/named.cache ] && {
		wget -q -O /etc/unbound/dnssec-root/named.cache https://internic.net/domain/named.cache
	}
	/usr/sbin/unbound-anchor -r /etc/unbound/dnssec-root/named.cache -a /etc/unbound/dnssec-root/trusted-key.key -R
	chown unbound:unbound /etc/unbound/dnssec-root/trusted-key.key
}
