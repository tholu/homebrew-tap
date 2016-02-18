class Arpwatch < Formula
  desc "arpwatch is a computer software tool for monitoring Address Resolution Protocol traffic on a computer network."
  url "ftp://ftp.ee.lbl.gov/arpwatch-2.1a15.tar.gz"
  homepage "http://http://ee.lbl.gov/"
  sha256 "c1df9737e208a96a61fa92ddad83f4b4d9be66f8992f3c917e9edf4b05ff5898"

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    system "make install"
  end
end
# inlined Patch by joncooper to correctly make a directory & fix the /usr/bin/install invocation on OS X, see https://github.com/Homebrew/homebrew/pull/6268
__END__
diff --git a/Makefile.in b/Makefile.in
index 75fb4ba..3ccc2de 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -110,13 +110,15 @@ zap: zap.o intoa.o
  $(CC) $(CFLAGS) -o $@ zap.o intoa.o -lutil
 
 install: force
- $(INSTALL) -m 555 -o bin -g bin arpwatch $(DESTDIR)$(BINDEST)
- $(INSTALL) -m 555 -o bin -g bin arpsnmp $(DESTDIR)$(BINDEST)
+ mkdir -p $(DESTDIR)$(BINDEST)
+ $(INSTALL) -m 555 arpwatch $(DESTDIR)$(BINDEST)
+ $(INSTALL) -m 555 arpsnmp $(DESTDIR)$(BINDEST)
 
 install-man: force
- $(INSTALL) -m 444 -o bin -g bin $(srcdir)/arpwatch.8 \
+ mkdir -p $(DESTDIR)$(MANDEST)
+ $(INSTALL) -m 444 $(srcdir)/arpwatch.8 \
      $(DESTDIR)$(MANDEST)/man8
- $(INSTALL) -m 444 -o bin -g bin $(srcdir)/arpsnmp.8 \
+ $(INSTALL) -m 444 $(srcdir)/arpsnmp.8 \
      $(DESTDIR)$(MANDEST)/man8
 
 lint:  $(GENSRC) force
