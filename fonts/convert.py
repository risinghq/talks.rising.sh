"""Convert variable fonts to static fonts for Typst."""

from pathlib import Path
from fontTools.ttLib import TTFont
from fontTools.varLib.mutator import instantiateVariableFont

WEIGHTS = [400, 500, 600, 700]

def convert_font(var_font_path: Path) -> None:
    """Convert variable font to static fonts."""
    var_font = TTFont(var_font_path)
    base_name = var_font_path.stem.replace("[wght]", "")

    for weight in WEIGHTS:
        static_font = instantiateVariableFont(var_font, {"wght": float(weight)})
        output = var_font_path.parent / f"{base_name}-{weight}.ttf"
        static_font.save(str(output))

def main() -> None:
    """Find and convert all variable fonts."""
    fonts_dir = Path(__file__).parent
    var_fonts = list(fonts_dir.glob("*[wght].ttf"))

    if not var_fonts:
        print("No variable fonts found. Place *[wght].ttf files in fonts/ directory.")
        return

    for font in var_fonts:
        print(f"Converting {font.name}")
        convert_font(font)

    print(f"Generated {len(var_fonts)} font(s) with weights: {', '.join(map(str, WEIGHTS))}")

if __name__ == "__main__":
    main()
