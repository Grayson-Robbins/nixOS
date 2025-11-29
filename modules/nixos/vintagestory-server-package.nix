{ stdenv, fetchurl, lib, version ? "1.21.5", srcOverride ? null }:

stdenv.mkDerivation rec {
  pname = "vintagestory-server";
  inherit version;

  src = if srcOverride == null then
    fetchurl {
      url = "https://cdn.vintagestory.at/gamefiles/stable/vs_server_linux-x64_${version}.tar.gz";
      sha256 = "00ya5jfmhbfad08gn4db6ya7w9yjwqyzqmcrhjq9xmxnfkknbkr6";
    }
  else srcOverride;

  # Correct unpack: extract into $TMPDIR/source
  unpackPhase = ''
    echo "Unpacking Vintage Story server…"
    mkdir source
    tar -xzf "$src" -C source
  '';

  installPhase = ''
    echo "Installing Vintage Story server…"

    mkdir -p $out

    # Copy everything from the extracted directory (not from .)
    cp -r source/* $out/

    # Patch shebangs in shell scripts
    patchShebangs $out

    # Remove Windows CRLF if any slipped in
    find $out -type f -name "*.sh" -exec sed -i 's/\r$//' {} +
  '';

  meta = with lib; {
    description = "Vintage Story Dedicated Server (binary release)";
    homepage = "https://www.vintagestory.at/";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}

