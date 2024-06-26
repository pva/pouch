# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop gnome2-utils java-vm-2 prefix

KEYWORDS="-* ~amd64"

if [[ "$(ver_cut 4)" == 0 ]] ; then
	S_PV="$(ver_cut 1-3)"
else
	MY_PV_EXT="u$(ver_cut 4)"
	S_PV="$(ver_cut 1-4)"
fi

MY_PV="$(ver_cut 2)${MY_PV_EXT}"

declare -A ARCH_FILES
ARCH_FILES[amd64]="jdk-${MY_PV}-linux-x64.tar.gz"

for keyword in ${KEYWORDS//-\*} ; do
	case "${keyword#\~}" in
		*-linux) continue ;;
	esac

	SRC_URI+="
		${keyword#\~}? (
			${ARCH_FILES[${keyword#\~}]}
		)"
done

DESCRIPTION="Oracle's Java SE Development Kit"
HOMEPAGE="http://www.oracle.com/technetwork/java/javase/"
LICENSE="OTN examples? ( BSD )"
SLOT="1.8"
IUSE="alsa commercial cups doc examples +fontconfig headless-awt javafx jce selinux source visualvm"
REQUIRED_USE="javafx? ( alsa fontconfig )"
RESTRICT="bindist fetch preserve-libs strip"
QA_PREBUILT="*"

# NOTES:
#
# * cups is dlopened.
#
# * libpng is also dlopened but only by libsplashscreen, which isn't
#   important, so we can exclude that.
#
# * We still need to work out the exact AWT and JavaFX dependencies
#   under MacOS. It doesn't appear to use many, if any, of the
#   dependencies below.
#
RDEPEND="
		!headless-awt? (
			x11-libs/libX11
			x11-libs/libXext
			x11-libs/libXi
			x11-libs/libXrender
			x11-libs/libXtst
		)
		javafx? (
			dev-libs/glib:2
			dev-libs/libxml2:2
			dev-libs/libxslt
			media-libs/freetype:2
			x11-libs/cairo
			x11-libs/gtk+:2
			x11-libs/libX11
			x11-libs/libXtst
			x11-libs/libXxf86vm
			x11-libs/pango
			virtual/opengl
		)
	alsa? ( media-libs/alsa-lib )
	cups? ( net-print/cups )
	doc? ( dev-java/java-sdk-docs:${SLOT} )
	fontconfig? ( media-libs/fontconfig:1.0 )
	!prefix? ( sys-libs/glibc:* )
	selinux? ( sec-policy/selinux-java )"

DEPEND="app-arch/zip"

S="${WORKDIR}/jdk$(ver_rs 3 _  ${S_PV})"

pkg_nofetch() {
	local a
	einfo "Please download these files and move them to your distfiles directory:"
	einfo
	for a in ${A} ; do
		[[ ! -f ${DISTDIR}/${a} ]] && einfo "  ${a}"
	done
	einfo
	einfo "  http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html"
	einfo
	einfo "If the above mentioned URL does not point to the correct version anymore,"
	einfo "please download the file from Oracle's Java download archive:"
	einfo
	einfo "  http://www.oracle.com/technetwork/java/javase/downloads/java-archive-javase8-2177648.html"
	einfo
}

src_prepare() {
	default

	if [[ -n ${JAVA_PKG_STRICT} ]] ; then
		# Mark this binary early to run it now.
		pax-mark m ./bin/javap

		eqawarn "Ensure that this only calls trackJavaUsage(). If not, see bug #559936."
		eqawarn
		eqawarn "$(./bin/javap -J-Duser.home=${T} -c sun.misc.PostVMInitHook || die)"
	fi

	# Remove the hook that calls Oracle's evil usage tracker. Not just
	# because it's evil but because it breaks the sandbox during builds
	# and we can't find any other feasible way to disable it or make it
	# write somewhere else. See bug #559936 for details.
	zip -d jre/lib/rt.jar sun/misc/PostVMInitHook.class || die
}

src_install() {
	local dest="/opt/${P}"
	local ddest="${ED}/${dest#/}"

	# Create files used as storage for system preferences.
	mkdir jre/.systemPrefs || die
	touch jre/.systemPrefs/.system.lock || die
	touch jre/.systemPrefs/.systemRootModFile || die

	if ! use alsa ; then
		rm -vf jre/lib/*/libjsoundalsa.* || die
	fi

	if ! use commercial ; then
		rm -vfr lib/missioncontrol jre/lib/jfr* || die
	fi

	if use headless-awt ; then
		rm -vf {,jre/}lib/*/lib*{[jx]awt,splashscreen}* \
		   {,jre/}bin/{javaws,policytool} \
		   bin/appletviewer || die
	fi

	if ! use javafx ; then
		rm -vf jre/lib/*/lib*{decora,fx,glass,prism}* \
		   jre/lib/*/libgstreamer-lite.* {,jre/}lib/{,ext/}*fx* \
		   bin/*javafx* bin/javapackager || die
	fi

	rm -vf jre/lib/*/libnpjp2.* || die

	# Even though plugins linked against multiple ffmpeg versions are
	# provided, they generally lag behind what Gentoo has available.
	rm -vf jre/lib/*/libavplugin* || die

	# Prune all fontconfig files so that libfontconfig will be used.
	rm -v jre/lib/fontconfig.* || die

	# Packaged as dev-util/visualvm but some users prefer this version.
	use visualvm || find -name "*visualvm*" -exec rm -vfr {} + || die

	# Install desktop file for the Java Control Panel. Using
	# ${PN}-${SLOT} to prevent file collision with JRE and other slots.
	if [[ -d jre/lib/desktop/icons ]] ; then
		einfo "Install desktop file"
		local icon
		pushd jre/lib/desktop/icons >/dev/null || die
		for icon in */*/apps/sun-jcontrol.png ; do
			insinto /usr/share/icons/"${icon%/*}"
			newins "${icon}" sun-jcontrol-${PN}-${SLOT}.png
		done
		popd >/dev/null || die
		make_desktop_entry \
			"${dest}"/bin/jcontrol \
			"Java Control Panel for Oracle JDK ${SLOT}" \
			sun-jcontrol-${PN}-${SLOT} \
			"Settings;Java;"
	fi

	dodoc COPYRIGHT
	einfo "${dest} and ${ddest}"
	dodir "${dest}"
	cp -pPR bin include jre lib man "${ddest}" || die

	ln -s policy/$(usex jce unlimited limited)/{US_export,local}_policy.jar \
		"${ddest}"/jre/lib/security/ || die

	if use source ; then
		cp -v src.zip "${ddest}" || die

		if use javafx ; then
			cp -v javafx-src.zip "${ddest}" || die
		fi
	fi

	# Only install Gentoo-specific fontconfig if flag is disabled.
	# https://docs.oracle.com/javase/8/docs/technotes/guides/intl/fontconfig.html
	if ! use fontconfig ; then
		insinto "${dest}"/jre/lib/
		doins "$(prefixify_ro "${FILESDIR}"/fontconfig.properties)"
	fi

	# Needs to be done before CDS, bug #215225.
	java-vm_set-pax-markings "${ddest}"

	# See bug #207282.
	einfo "Creating the Class Data Sharing archives"
	${ddest}/bin/java -server -Xshare:dump || die

	# Remove empty dirs we might have copied.
	find "${D}" -type d -empty -exec rmdir -v {} + || die

	java-vm_install-env "${FILESDIR}"/${PN}.env.sh
	java-vm_revdep-mask
	java-vm_sandbox-predict /dev/random /proc/self/coredump_filter
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
	java-vm-2_pkg_postinst

	if ! use headless-awt && ! use javafx ; then
		ewarn "You have disabled the javafx flag. Some modern desktop Java applications"
		ewarn "require this and they may fail with a confusing error message."
	fi
}

pkg_postrm() {
	gnome2_icon_cache_update
	java-vm-2_pkg_postrm
}
