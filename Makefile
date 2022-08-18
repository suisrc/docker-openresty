.PHONY: start build

NOW = $(shell date -u '+%Y%m%d%I%M%S')

APP = openresty

dev1:
	bin/fluent-bit -c bin/fluent.conf

dev2:
	bin/openresty -p ${PWD} -c tst/nginx.conf

dev3:
	bin/nginx -p ${PWD} -c tst/nginx.conf

build:
	go build -buildmode=c-shared -o out_sls.so .

