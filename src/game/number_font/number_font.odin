package number_font

import rl "vendor:raylib"

@(private)
FONT_DATA :: #load("../../../assets/fonts/jetbrains-mono/JetBrainsMono-Bold.ttf")

BASE_SIZE :: 1200
CODEPOINTS := [10]rune{'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
FONT: rl.Font

load :: proc() {
	FONT = rl.LoadFontFromMemory(
		".ttf",
		raw_data(FONT_DATA),
		cast(i32)len(FONT_DATA),
		BASE_SIZE,
		&CODEPOINTS[0],
		len(CODEPOINTS),
	)
	assert(rl.IsFontValid(FONT), "failed to load embedded number font")
	rl.SetTextureFilter(FONT.texture, .BILINEAR)
}

unload :: proc() {
	rl.UnloadFont(FONT)
}
