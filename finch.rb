require 'formula'

class Finch < Formula
  homepage 'http://developer.pidgin.im/wiki/Using%20Finch'
  url 'http://sourceforge.net/projects/pidgin/files/Pidgin/2.11.0/pidgin-2.11.0.tar.bz2'
  sha1 '9738a424ac9f6da8b68ebf11af00c55cafd6b4d2'

  depends_on 'pkg-config' => :build
  depends_on 'intltool' => :build
  depends_on 'libidn'
  depends_on 'gettext'
  depends_on 'glib'
  depends_on 'gnutls'
  # guntls used to use libgcrypt, and the configure script links this
  # library when testing for gnutls, so include it as a build-time
  # dependency. See:
  # https://github.com/mxcl/homebrew/issues/17129
  depends_on 'libgcrypt' => :build

  def install
    # To get it to compile, had to configure without support for:
    #   * Sametime (meanwhile)
    #   * Bonjour (avahi)
    #   * Communicating with other programs (d-bus)
    #   * Perl scripting
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-gtkui",
                          "--disable-gstreamer",
                          "--disable-vv",
                          "--disable-meanwhile",
                          "--disable-avahi",
                          "--disable-dbus",
                          "--disable-perl"
    system "make install"
  end
end