# shellcheck shell=bash
# Utility function to setup a GHC cross-compiler toolchain targeting Android.
termux_setup_ghc_cross_compiler() {
	local TERMUX_GHC_VERSION=9.2.5
	local GHC_PREFIX="ghc-cross-${TERMUX_GHC_VERSION}-${TERMUX_ARCH}"
	if [[ "${TERMUX_ON_DEVICE_BUILD}" == false ]]; then
		local TERMUX_GHC_RUNTIME_FOLDER

		if [[ "${TERMUX_PACKAGES_OFFLINE-false}" == true ]]; then
			TERMUX_GHC_RUNTIME_FOLDER="${TERMUX_SCRIPTDIR}/build-tools/${GHC_PREFIX}-runtime"
		else
			TERMUX_GHC_RUNTIME_FOLDER="${TERMUX_COMMON_CACHEDIR}/${GHC_PREFIX}-runtime"
		fi

		local TERMUX_GHC_TAR="${TERMUX_COMMON_CACHEDIR}/${GHC_PREFIX}.tar.xz"

		export PATH="${TERMUX_GHC_RUNTIME_FOLDER}/bin:${PATH}"

		test -d "${TERMUX_PREFIX}/lib/ghc-${TERMUX_GHC_VERSION}" ||
			termux_error_exit "Package 'ghc-libs' is not installed. It is required by GHC cross-compiler." \
				"You should specify it in 'TERMUX_PKG_BUILD_DEPENDS'."

		[[ -d "${TERMUX_GHC_RUNTIME_FOLDER}" ]] && return

		local CHECKSUMS
		CHECKSUMS="$(
			cat <<-EOF
				aarch64:0401a8ac93c6366805d837394d92fb67c9afcf86f7aa6f58a23c3588cdf7b654
				arm:b956ffdac9136647683fb5556e405d822d264bd9e1109b7286d53c89eb71c926
				i686:d5c959a3f6e4db47857fb83973986fcd00d23a82c3026c1d2c8e44564f7c2265
				x86_64:bbb84e5bddc12d97eecd86e6dc70e37a28c2f22a9bbf1b3d20b49e1f4c15519d
			EOF
		)"

		termux_download "https://github.com/MrAdityaAlok/ghc-cross-tools/releases/download/ghc-v${TERMUX_GHC_VERSION}/ghc-cross-bin-${TERMUX_GHC_VERSION}-${TERMUX_ARCH}.tar.xz" \
			"${TERMUX_GHC_TAR}" \
			"$(echo "${CHECKSUMS}" | grep -w "${TERMUX_ARCH}" | cut -d ':' -f 2)"

		mkdir -p "${TERMUX_GHC_RUNTIME_FOLDER}"
		tar -xf "${TERMUX_GHC_TAR}" -C "${TERMUX_GHC_RUNTIME_FOLDER}"
		rm "${TERMUX_GHC_TAR}"

		# Replace ghc settings with settings of the cross compiler.
		# NOTE: This edits file in $TERMUX_PREFIX after timestamp creation. Remove it in massage step.
		sed "s|\$topdir/bin/unlit|${TERMUX_GHC_RUNTIME_FOLDER}/lib/ghc-${TERMUX_GHC_VERSION}/bin/unlit|g" \
			"${TERMUX_GHC_RUNTIME_FOLDER}/lib/ghc-${TERMUX_GHC_VERSION}/settings" > \
			"${TERMUX_PREFIX}/lib/ghc-${TERMUX_GHC_VERSION}/settings"

		for tool in ghc ghc-pkg hsc2hs hp2ps; do
			sed -i "s|\$executablename|${TERMUX_GHC_RUNTIME_FOLDER}/lib/ghc-${TERMUX_GHC_VERSION}/bin/${tool}|g" \
				"${TERMUX_GHC_RUNTIME_FOLDER}/bin/${tool}"
		done

	else
		if [[ "${TERMUX_APP_PACKAGE_MANAGER}" == "apt" ]] && "$(dpkg-query -W -f '${db:Status-Status}\n' ghc 2>/dev/null)" != "installed" ||
			[[ "${TERMUX_APP_PACKAGE_MANAGER}" == "pacman" ]] && ! "$(pacman -Q ghc 2>/dev/null)"; then
			echo "Package 'ghc' is not installed."
			exit 1
		fi
	fi
}
