# Makefile
#
# Copyright (c) 2012, Luke Southam <luke@devthe.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# - Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
#
# - Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in
#   the documentation and/or other materials provided with the
#   distribution.
#
# - Neither the name of the DEVTHE.COM LIMITED nor the names of its
#   contributors may be used to endorse or promote products derived
#   from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
# THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

SHELL := /bin/bash

APP := app/

STATIC := $(APP)/static

LESS := $(STATIC)/less
CSS := $(LESS)/css

COFFEE := $(STATIC)/coffee
JS :=  $(COFFEE)/js

cleanCss:
	! test -d $(CSS) || rm -r $(CSS)
	[ ! -L $(STATIC)/css ] || rm $(STATIC)/css  
	mkdir $(CSS)

cleanJs:
	! test -d $(JS) || rm -r $(JS)
	[ ! -L $(STATIC)/js ] || rm $(STATIC)/js
	mkdir $(JS)

clean: cleanCss cleanJs
	find . -type f -name '*.pyc' -exec rm -f {} ';'
	find . -type f -name '.*.swp' -exec rm -f {} ';'
	find . -type f -name '*~' -exec rm -f {} ';'


server: clean css js
	pid=`lsof -i tcp:8080 | tail -n +2 | awk '{print $2}'`
	if [ -n "$$pid" ]; then \
		kill $$pid; \
	fi
	dev_appserver.py app &
	@sleep 5
	chromium-browser --temp-profile --app=http://localhost:8080/
	kill `lsof -i tcp:8080 | tail -n +2 | awk '{print $2}'`
	wait `lsof -i tcp:8080 | tail -n +2 | awk '{print $2}'`

commit: clean
	git add .
	git commit -a

push: clean
	git push

pull:
	git pull

css: cleanCss
	python .scripts/less.py $(LESS)
	ln -s ../../$(CSS) $(STATIC)/css


js: cleanJs
	python .scripts/build.py $(COFFEE) > $(JS)/main.js
	ln -s ../../$(JS) $(STATIC)/js

deploy: js css
	appcfg.py update app/