# speedwm // minimal X window manager designed for productivity and aesthetics.
# See LICENSE file for copyright and license details.

# include make config
include options.mk
include host.mk
include toggle.mk

SRC = draw.c speedwm.c main.c
OBJ = ${SRC:.c=.o}

# ipc
ifdef YAJLLIBS
	IPC=speedwm-ipc
endif

# status
ifdef USESTATUS
	STATUS=status
endif

all: options speedwm ${IPC} ${STATUS}

options:
	@echo speedwm build options:
	@echo "CFLAGS   = [${CFLAGS}]"
	@echo "LDFLAGS  = [${LDFLAGS}]"
	@echo "CC       = [${CC}]"
	@echo

.c.o:
	${CC} -c ${CFLAGS} $<

${OBJ}: options.mk

speedwm: ${OBJ}
	${CC} -o $@ ${OBJ} ${LDFLAGS}

ifdef USESTATUS
status: status.o
	$(CC) status.o $(CFLAGS) $(LDFLAGS) -o status
status.o: status.c status.h
	$(CC) -c status.c
endif

ifdef YAJLLIBS
speedwm-ipc: toggle/ipc-speedwm-msg.o
	${CC} -o $@ toggle/ipc-speedwm-msg.c ${LDFLAGS} ; rm -f ipc-speedwm-msg.o
endif

clean:
	rm -f speedwm *.o speedwm-${VERSION}.tar.gz
	rm -f speedwm-ipc
	rm -f status
	rm -f *.html *.php
	echo "Cleaned!"

dist: clean
	mkdir -p speedwm-${VERSION}
	cp -R *.mk *.c *.h *.png docs/ modules/ scripts/ toggle/ LICENSE Makefile speedwm-${VERSION}
	[ -f README.md ] && cp -f README.md speedwm-${VERSION} || :
	[ -f speedwm.1 ] && cp -f speedwm.1 speedwm-${VERSION} || :
	tar -cf speedwm-${VERSION}.tar speedwm-${VERSION}
	gzip speedwm-${VERSION}.tar
	rm -rf speedwm-${VERSION} speedwm
	rm -rf speedwm-${VERSION} speedwm-ipc

install_only_bin: all
	@echo speedwm ${VERSION} build options:
	@echo "CFLAGS   = [${CFLAGS}]"
	@echo "LDFLAGS  = [${LDFLAGS}]"
	@echo "CC       = [${CC}]"
	mkdir -p ${DESTDIR}${PREFIX}/bin
	mkdir -p ${DESTDIR}${PREFIX}/share/speedwm
	mkdir -p ${DESTDIR}${PREFIX}/share/xsessions/
	mkdir -p ${DESTDIR}${PREFIX}/share/pixmaps/
	[ -f speedwm-ipc ] && cp -f speedwm-ipc ${DESTDIR}${PREFIX}/bin || :
	[ -f speedwm-ipc ] && chmod 755 ${DESTDIR}${PREFIX}/bin/speedwm-ipc || :
	[ -f speedwm.png ] && cp -f speedwm.png ${DESTDIR}${PREFIX}/share/pixmaps/speedwm.png || :
	[ -f speedwm ] && cp -f speedwm ${DESTDIR}${PREFIX}/bin || :
	[ -f docs/entry.desktop ] && cp -f docs/entry.desktop ${DESTDIR}${PREFIX}/share/xsessions/speedwm.desktop || :
	chmod 755 ${DESTDIR}${PREFIX}/bin/speedwm
	rm -f *.o

install_only_misc:
	mkdir -p ${DESTDIR}${PREFIX}/bin
	mkdir -p ${DESTDIR}${PREFIX}/share/speedwm
	cp -f docs/keybinds ${DESTDIR}${PREFIX}/share/speedwm/keybinds
	cp -f docs/dependencies ${DESTDIR}${PREFIX}/share/speedwm/dependencies
	cp -f docs/doc-* ${DESTDIR}${PREFIX}/share/speedwm/
	cp -f docs/example.* ${DESTDIR}${PREFIX}/share/speedwm/
	cp -f scripts/speedwm* ${DESTDIR}${PREFIX}/bin ; chmod +x ${DESTDIR}${PREFIX}/bin/speedwm*
	make modules_install
	echo ${VERSION} > ${DESTDIR}${PREFIX}/share/speedwm/speedwm-version

install: all
	@echo speedwm ${VERSION} build options:
	@echo "CFLAGS   = [${CFLAGS}]"
	@echo "LDFLAGS  = [${LDFLAGS}]"
	@echo "CC       = [${CC}]"
	mkdir -p ${DESTDIR}${PREFIX}/bin
	mkdir -p ${DESTDIR}${PREFIX}/share/speedwm
	mkdir -p ${DESTDIR}${PREFIX}/share/xsessions/
	mkdir -p ${DESTDIR}${PREFIX}/share/pixmaps/
	[ -f speedwm-ipc ] && cp -f speedwm-ipc ${DESTDIR}${PREFIX}/bin || :
	[ -f status ] && cp -f status ${DESTDIR}${PREFIX}/bin || :
	[ -f speedwm ] && cp -f speedwm ${DESTDIR}${PREFIX}/bin || :
	[ -f docs/entry.desktop ] && cp -f docs/entry.desktop ${DESTDIR}${PREFIX}/share/xsessions/speedwm.desktop || :
	[ -f speedwm-ipc ] && chmod 755 ${DESTDIR}${PREFIX}/bin/speedwm-ipc || :
	[ -f speedwm.png ] && cp -f speedwm.png ${DESTDIR}${PREFIX}/share/pixmaps/speedwm.png || :
	[ -f speedwm.1 ] && mkdir -p ${DESTDIR}${MANPREFIX}/man1 || :
	[ -f speedwm.1 ] && cp speedwm.1 ${DESTDIR}${MANPREFIX}/man1/speedwm.1 || :
	cp -f docs/keybinds ${DESTDIR}${PREFIX}/share/speedwm/keybinds
	cp -f docs/dependencies ${DESTDIR}${PREFIX}/share/speedwm/dependencies
	cp -f docs/doc-* ${DESTDIR}${PREFIX}/share/speedwm/
	cp -f docs/example.* ${DESTDIR}${PREFIX}/share/speedwm/
	cp -f scripts/speedwm* ${DESTDIR}${PREFIX}/bin ; chmod +x ${DESTDIR}${PREFIX}/bin/speedwm*
	chmod 755 ${DESTDIR}${PREFIX}/bin/speedwm
	[ -f status ] && chmod 755 ${DESTDIR}${PREFIX}/bin/status || :
	make modules_install
	[ -f ${DESTDIR}${PREFIX}/bin/speedwm ] && rm -f drw.o speedwm.o util.o speedwm speedwm-ipc || :
	echo ${VERSION} > ${DESTDIR}${PREFIX}/share/speedwm/speedwm-version
	rm -f status
	rm -f *.o

modules_install:
	cp -f modules/module_* ${DESTDIR}${PREFIX}/bin
	chmod +x ${DESTDIR}${PREFIX}/bin/module_*
   
uninstall:
	rm -rf ${DESTDIR}${PREFIX}/bin/speedwm* ${DESTDIR}${PREFIX}/bin/speedwm-stellar ${DESTDIR}${PREFIX}/bin/module_*
	rm -rf ${DESTDIR}${MANPREFIX}/man1/speedwm.1

docs:
	chmod +x scripts/speedwm-help
	./scripts/speedwm-help -a -o

help:
	@echo -- speedwm Makefile help --
	@echo
	@echo - Installation -
	@echo install: Installs speedwm. You may need to run this as root.
	@echo install_only_bin: Installs speedwm, leaving out all scripts and documentation.
	@echo install_only_misc: Opposite of install_only_bin, as in installs scripts and documentation.
	@echo uninstall: Uninstalls speedwm. You may need to run this as root.
	@echo modules_install: Install modules.
	@echo
	@echo - Documentation -
	@echo help: Displays this help sheet.
	@echo docs: View documentation for speedwm
	@echo html: Write HTML document based on documentation.
	@echo php: Write PHP document based on documentation. This is almost identical to html.
	@echo markdown: Write Markdown document based on documentation.
	@echo readme: Write output of speedwm-help -a to readme.
	@echo upload: git commit and git push this build.
	@echo
	@echo - Page -
	@echo page: Creates the https://speedie.gq/speedwm page in PHP form.
	@echo page_php: Creates the https://speedie.gq/speedwm page in PHP form.
	@echo page_html: Creates the https://speedie.gq/speedwm page in HTML form.
	@echo page_install: Copy the page to ${PAGEDIR} and copy the preview image.
	@echo page_push: git commit and git push the page in ${PAGEDIR}.
	@echo page page_install page_push to do all of the above page changes instantly.
	@echo css_install: Copy the CSS from docs/ to ${PAGEDIR}
	@echo previmg_install: Copy the preview image to ${PAGEDIR}
	@echo
	@echo - Releasing -
	@echo release to run make markdown, make upload, make page, make page_install, make page_push instantly.
	@echo page_release to run make page, make page_install and make page_push instantly.
	@echo dist to create a tarball.

release:
		rm -f speedwm.html
		rm -f readme.html
		rm -f readme
		make markdown
		make man
		make upload
		make page
		make page_install
		make page_push
		rm -f speedwm.html
		rm -f readme.html
		rm -f readme
		@echo "Complete!"

page_release:
		rm -f speedwm.html
		rm -f readme.html
		rm -f readme
		make markdown
		make page
		make page_install
		make page_push
		rm -f speedwm.html
		rm -f readme.html
		rm -f readme
		@echo "Complete!"

upload:
		chmod +x scripts/speedwm-mkpage
		./scripts/speedwm-mkpage --release
		@echo "Uploaded everything."

page:
		make page_php
	
page_html:
		chmod +x scripts/speedwm-mkpage
		chmod +x scripts/speedwm-help
		./scripts/speedwm-mkpage --make-page

page_php:
		chmod +x scripts/speedwm-mkpage
		chmod +x scripts/speedwm-help
		./scripts/speedwm-mkpage --make-page
		mv readme.html readme.php

page_install:
		[ -f readme.html ] && cp -f readme.html ${PAGEDIR}/speedwm.html || \
		[ -f readme.php ] && cp -f readme.php ${PAGEDIR}/speedwm.php || :
		make previmg_install
		make css_install
		@echo "Copied readme.html/php to ${PAGEDIR}."
	
previmg_install:
		[ -f docs/preview.png ] && cp -f docs/preview.png ${PAGEDIR}
		@echo "Copied preview image to ${PAGEDIR}/preview.png"

css_install:
		[ -f docs/speedwm.css.template ] && cp -f docs/speedwm.css.template ${PAGEDIR}/speedwm.css || :
		@echo "Copied CSS to ${PAGEDIR}."

page_push:
		echo ${PAGEDIR} > /tmp/speedwm-htmldir
		chmod +x scripts/speedwm-mkpage
		chmod +x scripts/speedwm-help
		./scripts/speedwm-mkpage --release-page

html:
		chmod +x scripts/speedwm-mkpage
		chmod +x scripts/speedwm-help
		./scripts/speedwm-mkpage --make-html
	
php:
		chmod +x scripts/speedwm-mkpage
		chmod +x scripts/speedwm-help
		./scripts/speedwm-mkpage --make-page
		mv readme.html readme.php

markdown:
		chmod +x scripts/speedwm-mkpage
		chmod +x scripts/speedwm-help
		./scripts/speedwm-mkpage --make-markdown
	
man:
		chmod +x scripts/speedwm-mkpage
		chmod +x scripts/speedwm-help
		./scripts/speedwm-mkpage --make-man

readme:
		chmod +x scripts/speedwm-mkpage
		chmod +x scripts/speedwm-help
		./scripts/speedwm-mkpage -mk

.PHONY: all options clean dist install install_only_bin install_only_misc modules_install uninstall help docs page page_html page_php page_install page_release html php markdown man readme page_push upload release previmg_install css_install
