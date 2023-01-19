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

		[[ -d "${TERMUX_GHC_RUNTIME_FOLDER}" ]] && return

		local CHECKSUMS
		CHECKSUMS="$(
			cat <<-EOF
				aarch64:e94d1c2b0fb92ddd93bd90f50394293501c874da10f3732a70ea098563607962
				arm:1143cea56423a294e461c89a01963b20ddbe49e11f23041d8429dd0a7a8cbabe
				i686:f7ff072963f1f52f1dc38603c1debcad68fea39417f1a2c586512b201eb8b9da
				x86_64:4175f33d272669e3797eedbf93420a6a22955cd27d3aa782fd14f79ed1d526ba
			EOF
		)"

		termux_download "https://github.com/MrAdityaAlok/ghc-cross-tools/releases/download/ghc-v${TERMUX_GHC_VERSION}/ghc-${TERMUX_GHC_VERSION}-${TERMUX_ARCH}.tar.xz" \
			"${TERMUX_GHC_TAR}" \
			"$(echo "${CHECKSUMS}" | grep -w "${TERMUX_ARCH}" | cut -d ':' -f 2)"

		mkdir -p "${TERMUX_GHC_RUNTIME_FOLDER}"
		tar -xf "${TERMUX_GHC_TAR}" -C "${TERMUX_GHC_RUNTIME_FOLDER}"
		rm "${TERMUX_GHC_TAR}"

		# Get fix-path script.
		FIX_PATH_SCRIPT="$TERMUX_GHC_RUNTIME_FOLDER/fix-path.sh"
		termux_download "https://raw.githubusercontent.com/MrAdityaAlok/ghc-cross-tools/main/fix-path.sh" \
			"$FIX_PATH_SCRIPT" \
			19604368abe01534615fd908184d16149484d966a7de950e3dcddbc7fe066496
		# Fix ghc paths.
		bash "$FIX_PATH_SCRIPT" "$TERMUX_GHC_RUNTIME_FOLDER"

		# Strip hostname from tools:
		local _ghc_host="$TERMUX_ARCH-linux-android"
		if [[ "$TERMUX_ARCH" == "arm" ]]; then _ghc_host="armv7a-linux-androideabi"; fi
		for tool in "$TERMUX_GHC_RUNTIME_FOLDER"/bin/"$_ghc_host"-*; do
			mv "$tool" "${tool#*"$_ghc_host"-}"
		done

	else
		if [[ "${TERMUX_APP_PACKAGE_MANAGER}" == "apt" ]] && "$(dpkg-query -W -f '${db:Status-Status}\n' ghc 2>/dev/null)" != "installed" ||
			[[ "${TERMUX_APP_PACKAGE_MANAGER}" == "pacman" ]] && ! "$(pacman -Q ghc 2>/dev/null)"; then
			echo "Package 'ghc' is not installed."
			exit 1
		fi
	fi
}
