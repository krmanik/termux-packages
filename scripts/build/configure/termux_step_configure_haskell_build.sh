# shellcheck shell=bash
termux_step_configure_haskell_build() {
	# DYNAMIC_EXECUTABLE="
	# --ghc-options=-dynamic
	# --enable-executable-dynamic
	# --disable-library-vanilla
	# "
	# if [[ "${TERMUX_PKG_EXTRA_CONFIGURE_ARGS}" != "${TERMUX_PKG_EXTRA_CONFIGURE_ARGS/--disable-executable-dynamic/}" ]]; then
	# 	DYNAMIC_EXECUTABLE=""
	# fi
	#

	host_flag="--host=${TERMUX_HOST_PLATFORM}"
	if [[ "${TERMUX_PKG_EXTRA_CONFIGURE_ARGS}" != "${TERMUX_PKG_EXTRA_CONFIGURE_ARGS/--host=/}" ]]; then
		host_flag=""
	fi

	libexec_flag="--libexecdir=${TERMUX_PREFIX}/libexec"
	if [[ "${TERMUX_PKG_EXTRA_CONFIGURE_ARGS}" != "${TERMUX_PKG_EXTRA_CONFIGURE_ARGS/--libexecdir=/}" ]]; then
		libexec_flag=""
	fi

	quiet_build=
	if [[ "${TERMUX_quiet_build}" = true ]]; then
		quiet_build="-v0"
	fi

	lib_stripping="--enable-library-stripping"
	if [[ "${TERMUX_PKG_EXTRA_CONFIGURE_ARGS}" != "${TERMUX_PKG_EXTRA_CONFIGURE_ARGS/--disable-library-stripping=/}" ]] || [[ "${TERMUX_DEBUG_BUILD}" = true ]]; then
		lib_stripping=""
	fi

	executable_stripping="--enable-executable-stripping"
	if [[ "${TERMUX_PKG_EXTRA_CONFIGURE_ARGS}" != "${TERMUX_PKG_EXTRA_CONFIGURE_ARGS/--disable-executable-stripping=/}" ]] || [[ "${TERMUX_DEBUG_BUILD}" = true ]]; then
		executable_stripping=""
	fi

	split_sections="--enable-split-sections"
	if [[ "${TERMUX_PKG_EXTRA_CONFIGURE_ARGS}" != "${TERMUX_PKG_EXTRA_CONFIGURE_ARGS/--disable-split-sections=/}" ]]; then
		split_sections=""
	fi

	# Avoid gnulib wrapping of functions when cross compiling. See
	# http://wiki.osdev.org/Cross-Porting_Software#Gnulib
	# https://gitlab.com/sortix/sortix/wikis/Gnulib
	# https://github.com/termux/termux-packages/issues/76
	avoid_gnulib=""
	avoid_gnulib+=" ac_cv_func_nl_langinfo=yes"
	avoid_gnulib+=" ac_cv_func_calloc_0_nonnull=yes"
	avoid_gnulib+=" ac_cv_func_chown_works=yes"
	avoid_gnulib+=" ac_cv_func_getgroups_works=yes"
	avoid_gnulib+=" ac_cv_func_malloc_0_nonnull=yes"
	avoid_gnulib+=" ac_cv_func_posix_spawn=no"
	avoid_gnulib+=" ac_cv_func_posix_spawnp=no"
	avoid_gnulib+=" ac_cv_func_realloc_0_nonnull=yes"
	avoid_gnulib+=" am_cv_func_working_getline=yes"
	avoid_gnulib+=" gl_cv_func_dup2_works=yes"
	avoid_gnulib+=" gl_cv_func_fcntl_f_dupfd_cloexec=yes"
	avoid_gnulib+=" gl_cv_func_fcntl_f_dupfd_works=yes"
	avoid_gnulib+=" gl_cv_func_fnmatch_posix=yes"
	avoid_gnulib+=" gl_cv_func_getcwd_abort_bug=no"
	avoid_gnulib+=" gl_cv_func_getcwd_null=yes"
	avoid_gnulib+=" gl_cv_func_getcwd_path_max=yes"
	avoid_gnulib+=" gl_cv_func_getcwd_posix_signature=yes"
	avoid_gnulib+=" gl_cv_func_gettimeofday_clobber=no"
	avoid_gnulib+=" gl_cv_func_gettimeofday_posix_signature=yes"
	avoid_gnulib+=" gl_cv_func_link_works=yes"
	avoid_gnulib+=" gl_cv_func_lstat_dereferences_slashed_symlink=yes"
	avoid_gnulib+=" gl_cv_func_malloc_0_nonnull=yes"
	avoid_gnulib+=" gl_cv_func_memchr_works=yes"
	avoid_gnulib+=" gl_cv_func_mkdir_trailing_dot_works=yes"
	avoid_gnulib+=" gl_cv_func_mkdir_trailing_slash_works=yes"
	avoid_gnulib+=" gl_cv_func_mkfifo_works=yes"
	avoid_gnulib+=" gl_cv_func_mknod_works=yes"
	avoid_gnulib+=" gl_cv_func_realpath_works=yes"
	avoid_gnulib+=" gl_cv_func_select_detects_ebadf=yes"
	avoid_gnulib+=" gl_cv_func_snprintf_posix=yes"
	avoid_gnulib+=" gl_cv_func_snprintf_retval_c99=yes"
	avoid_gnulib+=" gl_cv_func_snprintf_truncation_c99=yes"
	avoid_gnulib+=" gl_cv_func_stat_dir_slash=yes"
	avoid_gnulib+=" gl_cv_func_stat_file_slash=yes"
	avoid_gnulib+=" gl_cv_func_strerror_0_works=yes"
	avoid_gnulib+=" gl_cv_func_strtold_works=yes"
	avoid_gnulib+=" gl_cv_func_symlink_works=yes"
	avoid_gnulib+=" gl_cv_func_tzset_clobber=no"
	avoid_gnulib+=" gl_cv_func_unlink_honors_slashes=yes"
	avoid_gnulib+=" gl_cv_func_unlink_honors_slashes=yes"
	avoid_gnulib+=" gl_cv_func_vsnprintf_posix=yes"
	avoid_gnulib+=" gl_cv_func_vsnprintf_zerosize_c99=yes"
	avoid_gnulib+=" gl_cv_func_wcrtomb_works=yes"
	avoid_gnulib+=" gl_cv_func_wcwidth_works=yes"
	avoid_gnulib+=" gl_cv_func_working_getdelim=yes"
	avoid_gnulib+=" gl_cv_func_working_mkstemp=yes"
	avoid_gnulib+=" gl_cv_func_working_mktime=yes"
	avoid_gnulib+=" gl_cv_func_working_strerror=yes"
	avoid_gnulib+=" gl_cv_header_working_fcntl_h=yes"
	avoid_gnulib+=" gl_cv_C_locale_sans_EILSEQ=yes"

	# NOTE: We do not want to quote avoid_gnulib as we want word expansion.
	# shellcheck disable=SC2086
	# shellcheck disable=SC2250,SC2154,SC2248,SC2312
	env $avoid_gnulib cabal configure \
		$TERMUX_HASKELL_OPTIMISATION \
		--prefix=$TERMUX_PREFIX \
		--configure-option=--disable-rpath \
		--configure-option=--disable-rpath-hack \
		--configure-option=--host=$host_flag \
		--ghc-option=-optl-Wl,-rpath=$TERMUX_PREFIX/lib \
		--ghc-option=-optl-Wl,--enable-new-dtags \
		--with-compiler="$(command -v termux-ghc)" \
		--with-ghc-pkg="$(command -v termux-ghc-pkg)" \
		--with-hsc2hs="$(command -v termux-hsc2hs)" \
		--hsc2hs-option=--cross-compile \
		--with-ld=$LD \
		--with-strip=$STRIP \
		--with-ar=$AR \
		--with-pkg-config=$PKG_CONFIG \
		--with-happy="$(command -v happy)" \
		--with-alex="$(command -v alex)" \
		--extra-include-dirs=$TERMUX_PREFIX/include \
		--extra-lib-dirs=$TERMUX_PREFIX/lib \
		--disable-tests \
		$TERMUX_PKG_EXTRA_CONFIGURE_ARGS \
		$TERMUX_HASKELL_LLVM_BACKEND \
		$split_sections \
		$executable_stripping \
		$lib_stripping \
		$quiet_build \
		$libexec_flag
	# $DYNAMIC_EXECUTABLE
}
