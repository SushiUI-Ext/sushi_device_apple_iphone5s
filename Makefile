ZSH != command -v zsh 2>/dev/null

.if empty(ZSH)
.error Zsh not present!
.endif

SHELL := ${ZSH}
.SHELLFLAGS := -e -c
.ONESHELL:

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
	${Q}source ./$(ENVSETUP)
	${Q}if ! type sushidevinfo >/dev/null 2>&1; then
		echo "ERROR: Failed to load SushiUI environment."
		exit 1
	fi
	${Q}echo "SushiUI Extended: $$VERSION"
	${Q}echo "Device: $$DEVICE"
	${Q}echo "Host OS: ${HOST_OS}"
	${Q}echo "Kernel: ${UNAME_S}"

sushi-prepare: check-env
	${Q}source ./$(ENVSETUP)
	${Q}rm -rf "${NZOUTPUT_DIR}"
	${Q}mkdir -p "${NZOUTPUT_DIR}"
	${Q}cp -a "${MODULE_SOURCE_DIR}/." "${NZOUTPUT_DIR}/"
	${Q}zsh "${MAKEFILE_DIR}/apkdown.sh"
	${Q}zsh "${MAKEFILE_DIR}/systemfiles.sh"

sushi-compact: sushi-prepare
	${Q}source ./$(ENVSETUP)
	${Q}mkdir -p "${OUTPUT_DIR}"
	${Q}ZIP_NAME="${PROJECT}_$${VERSION}_$${DEVICE}.zip"
	${Q}rm -f "${OUTPUT_DIR}/$${ZIP_NAME}"
	${Q}cd "${NZOUTPUT_DIR}"
	${Q}zip -r "../output/$${ZIP_NAME}" . >/dev/null
	${Q}echo "Created ${OUTPUT_DIR}/$${ZIP_NAME}."

clean:
	${Q}rm -rf "${NZOUTPUT_DIR}" "${OUTPUT_DIR}"
