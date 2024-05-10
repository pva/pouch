# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=8

inherit desktop java-vm-2 prefix

MY_PV="$(ver_cut 2)u$(ver_cut 4)"
S_PV="$(ver_rs 3 '_')"

# This URIs need to be updated when bumping!
JDK_URI="http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html#jdk-${MY_PV}-oth-JPR"
# This is a list of archs supported by this update.
AT_AVAILABLE=( amd64 x86 )
FX_VERSION="2_2_$(ver_cut 4)"

AT_x86="jdk-${MY_PV}-linux-i586.tar.gz"
AT_amd64="jdk-${MY_PV}-linux-x64.tar.gz"

DESCRIPTION="Oracle's Java SE Development Kit"
HOMEPAGE="http://www.oracle.com/technetwork/java/javase/"
for d in "${AT_AVAILABLE[@]}"; do
	SRC_URI+=" ${d}? ("
	SRC_URI+=" $(eval "echo \${$(echo AT_${d/-/_})}")"
	SRC_URI+=" )"
done
unset d

LICENSE="Oracle-BCLA-JavaSE examples? ( BSD )"
SLOT="1.7"
KEYWORDS="~amd64 ~x86"
IUSE="+X alsa aqua derby doc examples +fontconfig pax_kernel selinux source"

RESTRICT="fetch strip"
QA_PREBUILT="*"

COMMON_DEP=""
RDEPEND="${COMMON_DEP}
	X? ( !aqua? (
		x11-libs/libX11
		x11-libs/libXext
		x11-libs/libXi
		x11-libs/libXrender
		x11-libs/libXtst
	) )
	alsa? ( media-libs/alsa-lib )
	doc? ( dev-java/java-sdk-docs:1.7 )
	fontconfig? ( media-libs/fontconfig )
	selinux? ( sec-policy/selinux-java )"
# scanelf won't create a PaX header, so depend on paxctl to avoid fallback
# marking. #427642
DEPEND="${COMMON_DEP}
	examples? ( kernel_linux? ( app-arch/unzip ) )
	pax_kernel? ( sys-apps/paxctl )"

S="${WORKDIR}"/jdk${S_PV}

check_tarballs_available() {
	local uri=$1; shift
	local dl= unavailable=
	for dl in "${@}"; do
		[[ ! -f "${DISTDIR}/${dl}" ]] && unavailable+=" ${dl}"
	done

	if [[ -n "${unavailable}" ]]; then
		if [[ -z ${_check_tarballs_available_once} ]]; then
			einfo
			einfo "Oracle requires you to download the needed files manually after"
			einfo "accepting their license through a javascript capable web browser."
			einfo
			_check_tarballs_available_once=1
		fi
		einfo "Download the following files:"
		for dl in ${unavailable}; do
			einfo "  ${dl}"
		done
		einfo "at '${uri}'"
		einfo "and move them to \${DISTDIR}"
		einfo
		einfo "If the above mentioned urls do not point to the correct version anymore,"
		einfo "please download the files from Oracle's java download archive:"
		einfo
		einfo "   http://www.oracle.com/technetwork/java/javase/downloads/java-archive-downloads-javase7-521261.html#jdk-${MY_PV}-oth-JPR"
		einfo
	fi
}

pkg_nofetch() {
	local distfiles=( $(eval "echo \${$(echo AT_${ARCH/-/_})}") )
	check_tarballs_available "${JDK_URI}" "${distfiles[@]}"
}

src_install() {
	local dest="/opt/${P}"
	local ddest="${ED}${dest}"

	# Create files used as storage for system preferences.
	mkdir jre/.systemPrefs || die
	touch jre/.systemPrefs/.system.lock || die
	touch jre/.systemPrefs/.systemRootModFile || die

	# We should not need the ancient plugin for Firefox 2 anymore, plus it has
	# writable executable segments
	if use x86; then
		rm -vf {,jre/}lib/i386/libjavaplugin_oji.so \
			{,jre/}lib/i386/libjavaplugin_nscp*.so
		rm -vrf jre/plugin/i386
		rm -vf {,jre/}lib/i386/libnpjp2.so \
			{,jre/}lib/i386/libjavaplugin_jni.so
	fi

	dodir "${dest}"
	cp -pPR bin include jre lib man "${ddest}" || die

	if use derby; then
		cp -pPR db "${ddest}" || die
	fi

	if use source; then
		cp -p src.zip "${ddest}" || die
	fi

	# Install desktop file for the Java Control Panel.
	# Using ${PN}-${SLOT} to prevent file collision with jre and or
	# other slots.  make_desktop_entry can't be used as ${P} would
	# end up in filename.
	newicon jre/lib/desktop/icons/hicolor/48x48/apps/sun-jcontrol.png \
		sun-jcontrol-${PN}-${SLOT}.png || die
	sed -e "s#Name=.*#Name=Java Control Panel for Oracle JDK ${SLOT}#" \
		-e "s#Exec=.*#Exec=/opt/${P}/jre/bin/jcontrol#" \
		-e "s#Icon=.*#Icon=sun-jcontrol-${PN}-${SLOT}#" \
		-e "s#Application;##" \
		-e "/Encoding/d" \
		jre/lib/desktop/applications/sun_java.desktop \
		> "${T}"/jcontrol-${PN}-${SLOT}.desktop || die
	domenu "${T}"/jcontrol-${PN}-${SLOT}.desktop

	# Prune all fontconfig files so libfontconfig will be used and only install
	# a Gentoo specific one if fontconfig is disabled.
	# http://docs.oracle.com/javase/7/docs/technotes/guides/intl/fontconfig.html
	rm "${ddest}"/jre/lib/fontconfig.*
	if ! use fontconfig; then
		cp "${FILESDIR}"/fontconfig.Gentoo.properties "${T}"/fontconfig.properties || die
		eprefixify "${T}"/fontconfig.properties
		insinto "${dest}"/jre/lib/
		doins "${T}"/fontconfig.properties
	fi

	# This needs to be done before CDS - #215225
	java-vm_set-pax-markings "${ddest}"

	# see bug #207282
	einfo "Creating the Class Data Sharing archives"
	case ${ARCH} in
		x86)
			${ddest}/bin/java -client -Xshare:dump || die
			# limit heap size for large memory on x86 #467518
			# this is a workaround and shouldn't be needed.
			${ddest}/bin/java -server -Xms64m -Xmx64m -Xshare:dump || die
			;;
		*)
			${ddest}/bin/java -server -Xshare:dump || die
			;;
	esac

	# Remove empty dirs we might have copied
	find "${D}" -type d -empty -exec rmdir -v {} + || die

	set_java_env
	java-vm_revdep-mask
	java-vm_sandbox-predict /dev/random /proc/self/coredump_filter
}
