NACLRAW=nacl_raw.js
NACLVERSION=20110221
NACLUNPACKED=nacl-$(NACLVERSION)

PYTHON=python
EMCC=`which emcc`

all: build

$(NACLRAW): subnacl
	$(PYTHON) $(EMCC) \
		-s LINKABLE=1 \
		-s EXPORTED_FUNCTIONS="$$(cat subnacl/naclexports.sh)" \
		-s ALLOW_MEMORY_GROWTH=1 \
		--js-library nacl_randombytes_emscripten.js \
		--post-js subnacl/naclapi.js \
		-O1 --closure 1 -o $@ \
		-I subnacl/include \
		keys.c \
		$$(find subnacl -name '*.c')

clean:
	rm -f $(NACLRAW)
	rm -rf build

build: $(NACLRAW) nacl_cooked_prefix.js nacl_cooked.js nacl_cooked_suffix.js
	mkdir -p $@
	cat nacl_cooked_prefix.js $(NACLRAW) nacl_cooked.js nacl_cooked_suffix.js > $@/nacl.js

veryclean: clean
	rm -rf subnacl
	rm -rf $(NACLUNPACKED)

subnacl: import.py
	tar -jxvf $(NACLUNPACKED).tar.bz2
	python import.py $(NACLUNPACKED)
