# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop go-module systemd xdg-utils

DESCRIPTION="A native Linux filesystem for Microsoft OneDrive."
HOMEPAGE="https://github.com/jstaf/onedriver"
SRC_URI="https://github.com/jstaf/onedriver/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://github.com/foopsss/gentoo-overlay/releases/download/v${PV}/${P}-deps.tar.xz"

LICENSE="GPL-3 Apache-2.0 BSD-2-Clause ISC BSD-3-Clause MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="-gui"

RESTRICT="test"

DEPEND="
    dev-lang/go
    dev-libs/json-glib
    net-libs/webkit-gtk:4
"
RDEPEND="
    gui? (
	    sys-apps/systemd
    )
    =sys-fs/fuse-2.9.9-r2
"
BDEPEND="
    virtual/pkgconfig
"

src_prepare() {
	# Change the location of the onedriver logos in the main.go files for both onedriver and onedriver-launcher.
	sed -i -e 's!/usr/share/icons/onedriver/onedriver.png!/usr/share/icons/hicolor/256x256/apps/onedriver.png!' cmd/onedriver/main.go
	sed -i 's!/usr/share/icons/onedriver/onedriver-128.png!/usr/share/icons/hicolor/128x128/apps/onedriver-128.png!' cmd/onedriver-launcher/main.go

	# Change the location of the .svg logo in the desktop file.
	sed -i 's!Icon=/usr/share/icons/onedriver/onedriver.svg!Icon=/usr/share/pixmaps/onedriver.svg!' resources/onedriver.desktop

	eapply_user
}

src_compile() {
	emake onedriver

	if use gui; then
		emake onedriver-launcher
	fi
}

src_install() {
	dobin onedriver

	if use gui; then
		dobin onedriver-launcher

		doicon resources/onedriver.svg
		doicon -s 128 resources/onedriver-128.png
		doicon -s 256 resources/onedriver.png

		domenu resources/onedriver.desktop
	fi

	systemd_douserunit resources/onedriver@.service

	doman resources/onedriver.1
	dodoc README.md
}

pkg_postinst() {
	if use gui; then
		xdg_desktop_database_update
		xdg_icon_cache_update
	fi
	mandb

	elog "onedriver can be configured with a config file at '~/.config/onedriver/config.yml'."
	elog ""
	elog "It should be noted that this version of onedriver does not yet support shared items or Microsoft SharePoint."
	elog "Moreover, mounting the filesystem from the GUI and on log-in currently requires systemd, due to using a unit file to do so."
	elog "However, the filesystem itself works with other init systems if mounted through the CLI."
	elog "For more information see: https://github.com/jstaf/onedriver/issues/229."
}

pkg_postrm() {
	if use gui; then
		xdg_desktop_database_update
		xdg_icon_cache_update
	fi
	mandb
}
