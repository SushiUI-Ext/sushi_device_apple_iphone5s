ZSH != command -v zsh 2>/dev/null

.if empty(ZSH)
.error Zsh not present!
.endif

V ?= 0
BETA ?= 0

DEVICE := bangkk
PROJECT := SushiUI_EXT

MAKEFILE_DIR := Makefile.sh.d
MODULE_SOURCE_DIR := Makefile.mod.d
NZOUTPUT_DIR := device/nzoutput
OUTPUT_DIR := device/output

UNAME_S != uname -s 2>/dev/null

.if ${UNAME_S} == "Darwin"
HOST_OS := xnu
.elif ${UNAME_S} == "Linux"
HOST_OS := linux
.elif ${UNAME_S} == "FreeBSD"
HOST_OS := freebsd
.elif ${UNAME_S} == "OpenBSD"
HOST_OS := openbsd
.elif ${UNAME_S} == "NetBSD"
HOST_OS := netbsd
.elif ${UNAME_S} == "DragonFly"
HOST_OS := dragonfly
.else
HOST_OS := unknown
.endif

.if ${HOST_OS} == "unknown"
.error Unsupported host OS: ${UNAME_S}
.endif

.if ${V} == "1"
Q :=
.else
Q := @
.endif

.if ${BETA} == "1"
ENVSETUP := beta-envsetup.sh
.else
ENVSETUP := envsetup.sh
.endif

.PHONY: all check-env sushi-prepare sushi-compact clean

all: check-env sushi-compact

check-env:
	${Q}${ZSH} -ec 'source ./$(ENVSETUP); \
	if ! type sushidevinfo >/dev/null 2>&1; then \
		echo "ERROR: Failed to load SushiUI environment."; \
		exit 1; \
	fi; \
	echo "SushiUI Extended: $$VERSION"; \
	echo "Device: $$DEVICE"; \
	echo "Host OS: ${HOST_OS}"; \
	echo "Kernel: ${UNAME_S}"'

sushi-prepare: check-env
	${Q}${ZSH} -ec 'source ./$(ENVSETUP); \
	rm -rf "${NZOUTPUT_DIR}"; \
	mkdir -p "${NZOUTPUT_DIR}"; \
	cp -a "${MODULE_SOURCE_DIR}/." "${NZOUTPUT_DIR}/"; \
	${ZSH} "${MAKEFILE_DIR}/apkdown.sh"; \
	${ZSH} "${MAKEFILE_DIR}/systemfiles.sh"'

sushi-compact: sushi-prepare
	${Q}${ZSH} -ec 'source ./$(ENVSETUP); \
	mkdir -p "${OUTPUT_DIR}"; \
	ZIP_NAME="${PROJECT}_$${VERSION}_$${DEVICE}.zip"; \
	rm -f "${OUTPUT_DIR}/$${ZIP_NAME}"; \
	cd "${NZOUTPUT_DIR}"; \
	zip -r "../output/$${ZIP_NAME}" . >/dev/null; \
	echo "Created ${OUTPUT_DIR}/$${ZIP_NAME}."'

clean:
	${Q}rm -rf "${NZOUTPUT_DIR}" "${OUTPUT_DIR}"
