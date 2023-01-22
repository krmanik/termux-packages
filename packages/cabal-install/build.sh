# shellcheck shell=bash
TERMUX_PKG_HOMEPAGE="https://www.haskell.org/cabal/"
TERMUX_PKG_DESCRIPTION="The command-line interface for Haskell-Cabal and Hackage"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="Aditya Alok <alok@termux.dev>"
TERMUX_PKG_VERSION=3.8.1.0
TERMUX_PKG_SRCURL="https://hackage.haskell.org/package/cabal-install-${TERMUX_PKG_VERSION}/cabal-install-${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=61ce436f2e14e12bf07ea1c81402362f46275014cd841a76566f0766d0ea67e6
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_SUGGESTS="ghc"
TERMUX_PKG_BUILD_DEPENDS="ghc-libs"

termux_step_post_get_source() {
	local resolv_version=0.1.2.0
	local tmpdir="$TERMUX_PKG_TMPDIR/resolv-$resolv_version"

	cabal fetch reslov-"$resolv_version" -d "$TERMUX_PKG_TMPDIR"

	(
		cd "$tmpdir"
		patch -p1 <"$TERMUX_PKG_BUILDER_DIR"/resolv.diff
		cabal install --lib
	)

}
