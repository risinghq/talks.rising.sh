"""Convert variable fonts to static fonts for Typst."""

from pathlib import Path
from urllib.request import urlretrieve
from zipfile import ZipFile
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont

WEIGHTS = [400, 500, 600, 700]
GEIST_VERSION = "1.5.1"
GEIST_URL = f"https://github.com/vercel/geist-font/releases/download/{GEIST_VERSION}/geist-font-{GEIST_VERSION}.zip"


def download_fonts() -> None:
    """Download Geist variable fonts from GitHub if not present."""
    fonts_dir = Path(__file__).parent
    var_fonts = list(fonts_dir.glob("*[[]wght].ttf"))

    if var_fonts:
        return

    print(f"Downloading Geist {GEIST_VERSION}...")
    zip_path = fonts_dir / f"geist-font-{GEIST_VERSION}.zip"

    urlretrieve(GEIST_URL, zip_path)

    with ZipFile(zip_path) as zf:
        for name in zf.namelist():
            if "[wght].ttf" in name and not name.startswith("__MACOSX"):
                data = zf.read(name)
                output_name = Path(name).name
                (fonts_dir / output_name).write_bytes(data)

    zip_path.unlink()
    print("Download complete")


def convert_font(var_font_path: Path) -> None:
    """Convert variable font to static fonts."""
    var_font = TTFont(var_font_path)
    base_name = var_font_path.stem.replace("[wght]", "")

    for weight in WEIGHTS:
        static_font = instantiateVariableFont(var_font, {"wght": float(weight)})
        output = var_font_path.parent / f"{base_name}-{weight}.ttf"
        static_font.save(str(output))


def main() -> None:
    """Download and convert variable fonts."""
    fonts_dir = Path(__file__).parent

    download_fonts()

    var_fonts = list(fonts_dir.glob("*[[]wght].ttf"))

    for font in var_fonts:
        print(f"Converting {font.name}")
        convert_font(font)

    # Clean up variable font source files
    for font in var_fonts:
        font.unlink()

    for weight in WEIGHTS:
        mono_italic = fonts_dir / f"GeistMono-Italic-{weight}.ttf"
        if mono_italic.exists():
            mono_italic.unlink()

    print(f"Generated static fonts with weights: {', '.join(map(str, WEIGHTS))}")


if __name__ == "__main__":
    main()
