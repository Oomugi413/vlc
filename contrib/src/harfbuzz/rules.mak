# HARFBUZZ

HARFBUZZ_VERSION := 3.4.0
HARFBUZZ_URL := $(GITHUB)/harfbuzz/harfbuzz/releases/download/$(HARFBUZZ_VERSION)/harfbuzz-$(HARFBUZZ_VERSION).tar.xz
PKGS += harfbuzz
ifeq ($(call need_pkg,"harfbuzz"),)
PKGS_FOUND += harfbuzz
endif

$(TARBALLS)/harfbuzz-$(HARFBUZZ_VERSION).tar.xz:
	$(call download_pkg,$(HARFBUZZ_URL),harfbuzz)

.sum-harfbuzz: harfbuzz-$(HARFBUZZ_VERSION).tar.xz

harfbuzz: harfbuzz-$(HARFBUZZ_VERSION).tar.xz .sum-harfbuzz
	$(UNPACK)
	$(APPLY) $(SRC)/harfbuzz/0001-meson-Enable-big-objects-support-when-building-for-w.patch
	$(APPLY) $(SRC)/harfbuzz/0001-freetype-Fix-function-signatures-to-match-without-ca.patch
	$(APPLY) $(SRC)/harfbuzz/0002-Disable-Wcast-function-type-strict.patch
	$(APPLY) $(SRC)/harfbuzz/harfbuzz-fix-cmake-freetype.patch
	# build ragel as a native tool (which can't be installed)
	sed -i.orig -e 's,install : true,native : true,' $(UNPACK_DIR)/subprojects/packagefiles/ragel/meson.build
	$(MOVE)

DEPS_harfbuzz = freetype2 $(DEPS_freetype2)

HARFBUZZ_CONF := -Dfreetype=enabled \
	-Dglib=disabled \
	-Dgobject=disabled \
	-Ddocs=disabled \
	-Dtests=disabled \
	-Dragel_subproject=true

ifdef HAVE_DARWIN_OS
HARFBUZZ_CONF += -Dcoretext=enabled
endif

.harfbuzz: harfbuzz crossfile.meson
	$(MESONCLEAN)
	$(MESON) $(HARFBUZZ_CONF)
	+$(MESONBUILD)
	touch $@
