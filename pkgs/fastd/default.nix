{ stdenv, fetchgit, cmake, bison, pkgconfig, libuecc, libsodium, libcap, json_c }:

stdenv.mkDerivation rec {
  version = "18";
  name = "fastd-${version}";

  src = fetchgit {
    url = "git://git.universe-factory.net/fastd";
    rev = "refs/tags/v${version}";
    sha256 = "0c9v3igv3812b3jr7jk75a2np658yy00b3i4kpbpdjgvqzc1jrq8";
  };

  nativeBuildInputs = [ pkgconfig bison cmake ];
  buildInputs = [ libuecc libsodium libcap json_c ];

  enableParallelBuilding = true;
}
