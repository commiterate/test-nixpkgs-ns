{
  lib,
  stdenv,
  fetchurl,
  versionCheckHook,
  gettext,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hello";
  version = "2.12.3";

  __structuredAttrs = true;

  #
  # Inputs.
  #

  src = fetchurl {
    url = "mirror://gnu/hello/hello-${finalAttrs.version}.tar.gz";
    hash = "sha256-DV9gFUOC/uELEUocNOeF2LH0kgc64tOm97FHaHs2aqA=";
  };

  # The GNU Hello `configure` script detects how to link libiconv but fails to actually make use of that.
  # Unfortunately, this cannot be a patch to `Makefile.am` because `autoreconfHook` causes a gettext
  # infrastructure mismatch error when trying to build `hello`.
  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    NIX_LDFLAGS = "-liconv";
  };

  buildInputs = lib.optionals stdenv.hostPlatform.isFreeBSD [
    gettext
  ];

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  #
  # Phases.
  #

  doCheck = true;

  doInstallCheck = true;

  #
  # Passthrough attributes.
  #

  meta = {
    description = "Program that produces a familiar, friendly greeting";
    homepage = "https://www.gnu.org/software/hello";
    license = lib.licenses.gpl3Plus;
    mainProgram = "hello";
  };
})
