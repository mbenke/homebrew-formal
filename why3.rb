require 'formula'

class Why3 < Formula
  homepage 'http://why3.lri.fr'
  url 'http://why3.lri.fr/download/why3-0.82.tar.gz'
  sha1 '40a08a204e3d947ac46253121b9f6ed7ff3efdfa'

  option 'without-native', 'Build without the native OCaml compiler'
  option 'with-doc', 'Install documentations'
  option 'with-ide', 'Install IDE'
  option 'with-coq-libs', 'Enable Coq realizations'
  option 'with-coq-tactic', 'Enable Coq "why3" tactic'

  depends_on 'objective-caml'
  depends_on 'coq' if build.include? 'with-coq-libs' or build.include? 'with-coq-tactics'
  depends_on 'lablgtk2' => 'with-gtksourceview2' if build.include? 'with-ide'

  def install
    homebrew_prefix_stdlib = `ocamlc -where`.gsub /\n/, ""
    prefix_stdlib = homebrew_prefix_stdlib.gsub HOMEBREW_PREFIX, prefix

    # The current version does not support Coq-8.4 and PVS
    args = ["--prefix=#{prefix}",
            "--disable-bench",
            "--enable-hypothesis-selection",
            "--disable-debug",
            "--disable-profiling",
            "--disable-pvs-libs"]
    args << ((build.include? 'without-native') ? '--disable-native-code' : '--enable-native-code')
    args << ((build.include? 'with-doc') ? '--enable-doc' : '--disable-doc')
    args << ((build.include? 'with-coq-libs') ? '--enable-coq-libs' : '--disable-coq-libs')
    args << ((build.include? 'with-coq-tactic') ? '--enable-coq-tactic' : '--disable-coq-tactic')
    system "./configure", *args

    # Fix a bug
    if build.include? 'without-native'
      chmod 0644, 'Makefile'
      inreplace 'Makefile', /OCAMLOPT *= no/, 'OCAMLOPT = true'
    end

    system "make"
    system "make byte"
    system "make install OCAMLLIB=#{prefix_stdlib}"
    system "make install-lib OCAMLLIB=#{prefix_stdlib}"
  end
end
