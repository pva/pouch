# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop java-vm-2 prefix xdg-utils

DESCRIPTION="Oracle's Java SE Development Kit"
HOMEPAGE="http://www.oracle.com/technetwork/java/javase/"
SRC_URI="amd64? ( jdk-${PV}_linux-x64_bin.tar.gz )"

S="${WORKDIR}/jdk-${PV}"

LICENSE="OTN"
SLOT="${PV%%.*}"
KEYWORDS="-* ~amd64"
IUSE="alsa commercial cups +fontconfig +gentoo-vm gtk2 gtk3 headless-awt javafx nsplugin selinux source"
REQUIRED_USE="
	elibc_glibc
	javafx? ( alsa fontconfig ^^ ( gtk2 gtk3 ) )
"
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
		>=app-accessibility/at-spi2-core-2.46.0
		dev-libs/glib:2
		dev-libs/libxml2:2
		dev-libs/libxslt
		media-libs/freetype:2
		x11-libs/gdk-pixbuf
		x11-libs/libX11
		x11-libs/libXtst
		x11-libs/libXxf86vm
		x11-libs/pango
		virtual/opengl

		gtk2? (
			x11-libs/cairo
			x11-libs/gtk+:2
		)
		gtk3? (
			x11-libs/cairo[glib]
			x11-libs/gtk+:3
		)
	)
	!prefix? (
		dev-libs/elfutils
	)
	alsa? ( media-libs/alsa-lib )
	cups? ( net-print/cups )
	fontconfig? ( media-libs/fontconfig:1.0 )
	selinux? ( sec-policy/selinux-java )"

pkg_nofetch() {
	einfo "Please download jdk-${PV}_linux-x64_bin.tar.gz and move it to"
	einfo "your distfiles directory:"
	einfo
	einfo "  https://www.oracle.com/technetwork/java/javase/downloads/jdk11-downloads-5066655.html"
	einfo
	einfo "If the above mentioned URL does not point to the correct version anymore,"
	einfo "please download the file from Oracle's Java download archive:"
	einfo
	einfo "  https://www.oracle.com/technetwork/java/javase/downloads/java-archive-javase11-5116896.html"
	einfo
}

src_install() {
	local dest="/opt/${P}"
	local ddest="${ED}/${dest#/}"

	# Create files used as storage for system preferences.
	mkdir .systemPrefs || die
	touch .systemPrefs/.system.lock || die
	touch .systemPrefs/.systemRootModFile || die

	if ! use alsa ; then
		rm -vf lib/libjsoundalsa.* || die
	fi

	if ! use commercial ; then
		rm -vfr jmods/*.jfr.* lib/jfr* \
			lib/missioncontrol || die
	fi

	if use headless-awt ; then
		rm -vf lib/lib*{[jx]awt,splashscreen}* \
		   bin/{appletviewer,javaws,policytool} || die
	fi

	if ! use javafx ; then
		rm -vf lib/lib*{decora,fx,glass,prism}* \
		   lib/libgstreamer-lite.* lib/*fx* \
		   bin/javapackager jmods/javafx* || die
	else
		if ! use gtk2 ; then
			rm -vf lib/libglassgtk2.* || die
		elif ! use gtk3 ; then
			rm -vf lib/libglassgtk3.* || die
		fi
	fi

	if ! use nsplugin ; then
		rm -vf lib/libnpjp2.* || die
	else
		local nsplugin=$(echo lib/libnpjp2.*)
		local nsplugin_link=${nsplugin##*/}
		nsplugin_link=${nsplugin_link/./-${PN}-${SLOT}.}
		dosym "${dest}/${nsplugin}" "/usr/$(get_libdir)/nsbrowser/plugins/${nsplugin_link}"
	fi

	if ! use source ; then
		rm -v lib/src.zip || die
	fi

	# Even though plugins linked against multiple ffmpeg versions are
	# provided, they generally lag behind what Gentoo has available.
	rm -vf lib/libavplugin* || die

#       # Prune all fontconfig files so that libfontconfig will be used.
#       rm -v lib/fontconfig.* || die

	# Install desktop file for the Java Control Panel. Using
	# ${PN}-${SLOT} to prevent file collision with JRE and other slots.
	if [[ -d lib/desktop/icons ]] ; then
		local icon
		pushd lib/desktop/icons >/dev/null || die
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

	dodir "${dest}"
	cp -pPR bin conf include jmods lib "${ddest}" || die

	# Only install Gentoo-specific fontconfig if flag is disabled.
	# https://docs.oracle.com/javase/8/docs/technotes/guides/intl/fontconfig.html
	if ! use fontconfig ; then
		insinto "${dest}"/lib/
		doins "$(prefixify_ro "${FILESDIR}"/fontconfig.properties)"
	fi

	# Needs to be done before CDS, bug #215225.
	java-vm_set-pax-markings "${ddest}"

	# See bug #207282.
	einfo "Creating the Class Data Sharing archives"
	# "${ddest}/bin/java" -server -Xshare:dump || die
	"${ddest}/bin/java" -server -Xshare:dump -Djdk.disableLastUsageTracking || die

	# Remove empty dirs we might have copied.
	find "${D}" -type d -empty -exec rmdir -v {} + || die

	use gentoo-vm && java-vm_install-env "${FILESDIR}"/${PN}-9.env.sh
	java-vm_revdep-mask
	java-vm_sandbox-predict /dev/random /proc/self/coredump_filter
}

pkg_postinst() {
	xdg_icon_cache_update
	java-vm-2_pkg_postinst

	if ! use headless-awt && ! use javafx ; then
		ewarn "You have disabled the javafx flag. Some modern desktop Java applications"
		ewarn "require this and they may fail with a confusing error message."
	fi

	if use gentoo-vm ; then
		ewarn "WARNING! You have enabled the gentoo-vm USE flag, making this JDK"
		ewarn "recognised by the system. This will almost certainly break things."
	else
		ewarn "The experimental gentoo-vm USE flag has not been enabled so this JDK"
		ewarn "will not be recognised by the system. For example, simply calling"
		ewarn "\"java\" will launch a different JVM. This is necessary until Gentoo"
		ewarn "fully supports Java 9. This JDK must therefore be invoked using its"
		ewarn "absolute location under ${EPREFIX}/opt/${P}."
	fi
}

pkg_postrm() {
	xdg_icon_cache_update
	java-vm-2_pkg_postrm
}
