# tremor (fixed-point Vorbis)

TREMOR_URL := https://gitlab.xiph.org/xiph/tremor/-/archive/master/tremor-master.tar.gz

PKGS += tremor
ifeq ($(call need_pkg,"tremor"),)
PKGS_FOUND += tremor
endif

$(TARBALLS)/tremor-master.tar.gz:
	$(call download_pkg,$(TREMOR_URL),tremor)

.sum-tremor: tremor-master.tar.gz

tremor: tremor-master.tar.gz .sum-tremor
	# Stuff that does not depend on libogg
	$(UNPACK)
	$(APPLY) $(SRC)/tremor/tremor.patch
	$(MOVE)

DEPS_tremor = ogg $(DEPS_ogg)

.tremor: tremor
	# Stuff that depends on libogg
	$(RECONF)
	cd $< && \
	$(HOSTVARS) CFLAGS="$(CFLAGS) $(NOTHUMB)" ./configure $(HOSTCONF)
	cd $< && $(MAKE) install
	touch $@
