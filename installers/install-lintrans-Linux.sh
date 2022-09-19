#!/usr/bin/env sh

create_desktop_file() {
	rm -f doctordalek1963-lintrans.desktop
	touch doctordalek1963-lintrans.desktop
	echo "[Desktop Entry]"                          >> doctordalek1963-lintrans.desktop
	echo "Type=Application"                         >> doctordalek1963-lintrans.desktop
	echo "Version=1.5"                              >> doctordalek1963-lintrans.desktop
	echo "Name=lintrans"                            >> doctordalek1963-lintrans.desktop
	echo "Comment=Linear transformation visualizer" >> doctordalek1963-lintrans.desktop
	echo "Icon=$HOME/.lintrans/icons/128.xpm"       >> doctordalek1963-lintrans.desktop
	echo "Exec='$1' %f"                             >> doctordalek1963-lintrans.desktop
	echo "Terminal=false"                           >> doctordalek1963-lintrans.desktop
	echo "MimeType=application/lintrans-session"    >> doctordalek1963-lintrans.desktop
	echo "Categories=Education"                     >> doctordalek1963-lintrans.desktop
}

create_mime_type_file() {
	rm -f doctordalek1963-lintrans-session.xml
	touch doctordalek1963-lintrans-session.xml
	echo '<?xml version="1.0"?>'                                                     >> doctordalek1963-lintrans-session.xml
	echo '<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">' >> doctordalek1963-lintrans-session.xml
	echo '  <mime-type type="application/lintrans-session">'                         >> doctordalek1963-lintrans-session.xml
	echo '    <comment>lintrans session save file</comment>'                         >> doctordalek1963-lintrans-session.xml
	echo '    <glob pattern="*.lt"/>'                                                >> doctordalek1963-lintrans-session.xml
	echo '    <icon name="application-lintrans-session"/>'                           >> doctordalek1963-lintrans-session.xml
	echo '  </mime-type>'                                                            >> doctordalek1963-lintrans-session.xml
	echo '</mime-info>'                                                              >> doctordalek1963-lintrans-session.xml
}

download_icons() {
	dest="$HOME/.lintrans/icons"
	if [ ! -d "$dest" ]; then
		mkdir -p "$dest"
	fi

	wget -q --show-progress "https://github.com/DoctorDalek1963/lintrans/raw/v$1/src/lintrans/gui/assets/16.xpm" -O "$dest/16.xpm"
	wget -q --show-progress "https://github.com/DoctorDalek1963/lintrans/raw/v$1/src/lintrans/gui/assets/32.xpm" -O "$dest/32.xpm"
	wget -q --show-progress "https://github.com/DoctorDalek1963/lintrans/raw/v$1/src/lintrans/gui/assets/64.xpm" -O "$dest/64.xpm"
	wget -q --show-progress "https://github.com/DoctorDalek1963/lintrans/raw/v$1/src/lintrans/gui/assets/128.xpm" -O "$dest/128.xpm"
}

install_lintrans() {
	echo "Welcome to the lintrans installer!"

	latest_version="$(curl -sL https://github.com/DoctorDalek1963/lintrans/releases/latest | \grep -Po '(?<=/DoctorDalek1963/lintrans/releases/download/v)\d+\.\d+\.\d+(?=/lintrans-Linux)')"
	binary_url="https://github.com/DoctorDalek1963/lintrans/releases/download/v${latest_version}/lintrans-Linux-${latest_version}"

	echo "The latest release is lintrans v${latest_version}"
	echo

	prefix="$HOME/.local/bin"
	echo -n "Please enter an installation prefix (leave empty for ${prefix}): "
	read prefix_input

	if [ -n "$prefix_input" ]; then
		prefix="$prefix_input"
	fi

	filename="${prefix}/lintrans"

	if [ -x "$filename" ]; then
		current_version="$($filename --version | \grep -Po '(?<=lintrans \(version )\d+\.\d+\.\d+(?=\))')"

		if [ "$current_version" = "$latest_version" ]; then
			echo
			echo "You've got the latest version of lintrans installed there already!"
			exit 0
		fi
	fi

	echo
	echo "Now downloading the lintrans binary..."
	wget -q --show-progress "$binary_url" -O lintrans-binary

	mv lintrans-binary "$filename"
	chmod +x "$filename"

	echo
	echo "Now downloading the icons..."
	download_icons "$latest_version"

	echo
	echo "Now registering the XDG MIME type..."
	create_mime_type_file
	xdg-mime install --mode user doctordalek1963-lintrans-session.xml
	rm -f doctordalek1963-lintrans-session.xml

	echo
	echo "Now registering all the icons for XDG..."
	xdg-icon-resource install --mode user --context mimetypes --size 16 "$HOME/.lintrans/icons/16.xpm" application-lintrans-session
	xdg-icon-resource install --mode user --context mimetypes --size 32 "$HOME/.lintrans/icons/32.xpm" application-lintrans-session
	xdg-icon-resource install --mode user --context mimetypes --size 64 "$HOME/.lintrans/icons/64.xpm" application-lintrans-session
	xdg-icon-resource install --mode user --context mimetypes --size 128 "$HOME/.lintrans/icons/128.xpm" application-lintrans-session

	echo
	echo "Now installing the XDG .desktop file..."
	create_desktop_file "$filename"
	xdg-desktop-menu install --mode user doctordalek1963-lintrans.desktop
	rm -f doctordalek1963-lintrans.desktop

	echo
	echo "Thanks for installing lintrans!"
}

uninstall_lintrans() {
	echo "Welcome to the lintrans uninstaller!"
	echo

	prefix="$HOME/.local/bin"
	echo -n "Please enter the installation prefix where you installed lintrans (leave empty for ${prefix}): "
	read prefix_input

	if [ -n "$prefix_input" ]; then
		prefix="$prefix_input"
	fi

	filename="${prefix}/lintrans"

	[ -x "$filename" ] && rm "$filename"
	[ -d "$HOME/.lintrans" ] && rm -rf "$HOME/.lintrans"

	create_mime_type_file
	xdg-mime uninstall --mode user doctordalek1963-lintrans-session.xml
	rm -f doctordalek1963-lintrans-session.xml

	xdg-icon-resource uninstall --mode user --context mimetypes --size 16 application-lintrans-session
	xdg-icon-resource uninstall --mode user --context mimetypes --size 32 application-lintrans-session
	xdg-icon-resource uninstall --mode user --context mimetypes --size 64 application-lintrans-session
	xdg-icon-resource uninstall --mode user --context mimetypes --size 128 application-lintrans-session

	create_desktop_file "$filename"
	xdg-desktop-menu uninstall --mode user doctordalek1963-lintrans.desktop
	rm -f doctordalek1963-lintrans.desktop

	echo
	echo "Successfully uninstalled lintrans!"
}

if [ "$#" -lt 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	echo "Usage: $0 [--help] < install | uninstall >"
	exit 1
fi

if [ "$1" = "install" ]; then
	install_lintrans
elif [ "$1" = "uninstall" ]; then
	uninstall_lintrans
fi
