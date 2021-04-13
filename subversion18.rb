# typed: false
# frozen_string_literal: true

class Subversion18 < Formula
  desc "Version control system"
  homepage "https://subversion.apache.org/"
  url "https://www.apache.org/dyn/closer.lua?path=subversion/subversion-1.8.16.tar.bz2"
  mirror "https://archive.apache.org/dist/subversion/subversion-1.8.16.tar.bz2"
  sha256 "f18f6e8309270982135aae54d96958f9ca6b93f8a4e746dd634b1b5b84edb346"

  bottle do
    sha256 el_capitan: "c8e084464d3a30b65381af6cb2b225dd5511cb0f074a67a2fe6c89d66a1fae30"
    sha256 yosemite:   "0d80b06e7c27264ff0c533ad93f9a4ff0c9702d50740c87862d1368fe2c70bc5"
    sha256 mavericks:  "2514644016e8f2a8feb77fc31b3620af91c3310cf501b8e402e3b972eef98f42"
  end

  option "with-unicode-path", "Build with support for OS X UTF-8-MAC filename"

  deprecated_option "unicode-path" => "with-unicode-path"

  depends_on "pkg-config" => :build
  depends_on "scons" => :build # For Serf
  depends_on "apr"
  depends_on "apr-util"
  depends_on "openssl@1.1" # For Serf
  depends_on "sqlite" # build against Homebrew version for consistency

  resource "serf" do
    url "https://www.apache.org/dyn/closer.lua?path=serf/serf-1.3.9.tar.bz2"
    mirror "https://archive.apache.org/dist/serf/serf-1.3.9.tar.bz2"
    sha256 "549c2d21c577a8a9c0450facb5cca809f26591f048e466552240947bdf7a87cc"
  end

  # Python3-compatible SConstruct file for serf 1.3.9, from http://svn.apache.org/repos/asf/serf/branches/1.3.x/SConstruct
  resource "serf-SConstruct" do
    url "https://gist.githubusercontent.com/tholu/e9f0a9edf5a93820412808719117a2b0/raw/1f53eebcdce824cfe24a7fae3a3e3e9dc5239175/SConstruct"
    sha256 "8012cc09469b2c284f915e8d2c8def9492d25e4a55a1abac316d2bbc4acf4917"
  end

  # Patch for Subversion handling of OS X UTF-8-MAC filename.
  if build.with? "unicode-path"
    patch :p0 do
      url "https://gist.githubusercontent.com/tholu/fb5d30c586e33b53ecba/raw/a266b1aa01f95cdc38fcedda4c6bce253dfb58c2/svn_1.8.x_darwin_unicode_precomp.patch"
      sha256 "2eaee628e3161bce4b1697660281cab30f42265369bfa7074ea435e441d543e7"
    end
  end

  def install
    serf_prefix = "#{libexec}serf"

    resource("serf").stage do
      # Fixing the SConstruct file of serf 1.3.9 to be Python3 compatible (https://github.com/tholu/homebrew-tap/issues/10)
      resource("serf-SConstruct").stage do |stage|
        @serf_sconstruct_path = Dir.pwd
        stage.staging.retain!
      end
      cp "#{@serf_sconstruct_path}/SConstruct", "."

      # SConstruct merges in gssapi linkflags using scons's MergeFlags,
      # but that discards duplicate values - including the duplicate
      # values we want, like multiple -arch values for a universal build.
      # Passing 0 as the `unique` kwarg turns this behaviour off.
      inreplace "SConstruct", "unique=1", "unique=0"

      # scons ignores our compiler and flags unless explicitly passed
      args = %W[PREFIX=#{serf_prefix} GSSAPI=/usr CC=#{ENV.cc}
                CFLAGS=#{ENV.cflags} LINKFLAGS=#{ENV.ldflags}
                OPENSSL=#{Formula["openssl@1.1"].opt_prefix}]

      if MacOS.version >= :sierra || !MacOS::CLT.installed?
        args << "APR=#{Formula["apr"].opt_prefix}"
        args << "APU=#{Formula["apr-util"].opt_prefix}"
      end

      system "scons", *args
      system "scons", "install"
    end

    # Use existing system zlib
    # Use dep-provided other libraries
    # Don't mess with Apache modules (since we're not sudo)
    args = ["--disable-debug",
            "--prefix=#{prefix}",
            "--with-zlib=/usr",
            "--with-sqlite=#{Formula["sqlite"].opt_prefix}",
            "--with-serf=#{serf_prefix}",
            "--disable-mod-activation",
            "--disable-nls",
            "--without-apache-libexecdir",
            "--without-berkeley-db"]

    args << "--enable-javahl" << "--without-jikes" if build.with? "java"
    args << "--without-gnupg" if build.without? "gnupg"

    if MacOS::CLT.installed? && MacOS.version < :sierra
      args << "--with-apr=/usr"
      args << "--with-apr-util=/usr"
    else
      args << "--with-apr=#{Formula["apr"].opt_prefix}"
      args << "--with-apr-util=#{Formula["apr-util"].opt_prefix}"
      args << "--with-apxs=no"
    end

    inreplace "Makefile.in",
              "toolsdir = @bindir@/svn-tools",
              "toolsdir = @libexecdir@/svn-tools"

    system "./configure", *args
    system "make"
    system "make", "install"
    bash_completion.install "tools/client-side/bash_completion" => "subversion"

    system "make", "tools"
    system "make", "install-tools"
  end

  def caveats
    s = <<~EOS
      svntools have been installed to:
        #{opt_libexec}
    EOS

    if build.with? "unicode-path"
      s += <<~EOS
        This unicode-path version implements a hack to deal with composed/decomposed
        unicode handling on Mac OS X which is different from linux and windows.
        It is borrowed from http://subversion.tigris.org/issues/show_bug.cgi?id=2464 and
        _WILL_ break some setups. Please be sure you understand what you
        are asking for when you install this version.
      EOS
    end

    s
  end

  test do
    system "#{bin}/svnadmin", "create", "test"
    system "#{bin}/svnadmin", "verify", "test"
  end
end
