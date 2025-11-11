# codecs support
__all__ = ["RL_Codecs"]
import codecs
from collections import namedtuple

StdCodecData = namedtuple("StdCodecData", "exceptions rexceptions")
ExtCodecData = namedtuple("ExtCodecData", "baseName exceptions rexceptions")


class RL_Codecs:
    __rl_codecs_data = {
        "winansi": StdCodecData(
            {
                0x007F: 0x2022,  # BULLET
                0x0080: 0x20AC,  # EURO SIGN
                0x0081: 0x2022,  # BULLET
                0x0082: 0x201A,  # SINGLE LOW-9 QUOTATION MARK
                0x0083: 0x0192,  # LATIN SMALL LETTER F WITH HOOK
                0x0084: 0x201E,  # DOUBLE LOW-9 QUOTATION MARK
                0x0085: 0x2026,  # HORIZONTAL ELLIPSIS
                0x0086: 0x2020,  # DAGGER
                0x0087: 0x2021,  # DOUBLE DAGGER
                0x0088: 0x02C6,  # MODIFIER LETTER CIRCUMFLEX ACCENT
                0x0089: 0x2030,  # PER MILLE SIGN
                0x008A: 0x0160,  # LATIN CAPITAL LETTER S WITH CARON
                0x008B: 0x2039,  # SINGLE LEFT-POINTING ANGLE QUOTATION MARK
                0x008C: 0x0152,  # LATIN CAPITAL LIGATURE OE
                0x008D: 0x2022,  # BULLET
                0x008E: 0x017D,  # LATIN CAPITAL LETTER Z WITH CARON
                0x008F: 0x2022,  # BULLET
                0x0090: 0x2022,  # BULLET
                0x0091: 0x2018,  # LEFT SINGLE QUOTATION MARK
                0x0092: 0x2019,  # RIGHT SINGLE QUOTATION MARK
                0x0093: 0x201C,  # LEFT DOUBLE QUOTATION MARK
                0x0094: 0x201D,  # RIGHT DOUBLE QUOTATION MARK
                0x0095: 0x2022,  # BULLET
                0x0096: 0x2013,  # EN DASH
                0x0097: 0x2014,  # EM DASH
                0x0098: 0x02DC,  # SMALL TILDE
                0x0099: 0x2122,  # TRADE MARK SIGN
                0x009A: 0x0161,  # LATIN SMALL LETTER S WITH CARON
                0x009B: 0x203A,  # SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
                0x009C: 0x0153,  # LATIN SMALL LIGATURE OE
                0x009D: 0x2022,  # BULLET
                0x009E: 0x017E,  # LATIN SMALL LETTER Z WITH CARON
                0x009F: 0x0178,  # LATIN CAPITAL LETTER Y WITH DIAERESIS
                0x00A0: 0x0020,  # SPACE
            },
            {0x2022: 0x7F, 0x20: 0x20, 0xA0: 0x20},
        ),
        "macroman": StdCodecData(
            {
                0x007F: None,  # UNDEFINED
                0x0080: 0x00C4,  # LATIN CAPITAL LETTER A WITH DIAERESIS
                0x0081: 0x00C5,  # LATIN CAPITAL LETTER A WITH RING ABOVE
                0x0082: 0x00C7,  # LATIN CAPITAL LETTER C WITH CEDILLA
                0x0083: 0x00C9,  # LATIN CAPITAL LETTER E WITH ACUTE
                0x0084: 0x00D1,  # LATIN CAPITAL LETTER N WITH TILDE
                0x0085: 0x00D6,  # LATIN CAPITAL LETTER O WITH DIAERESIS
                0x0086: 0x00DC,  # LATIN CAPITAL LETTER U WITH DIAERESIS
                0x0087: 0x00E1,  # LATIN SMALL LETTER A WITH ACUTE
                0x0088: 0x00E0,  # LATIN SMALL LETTER A WITH GRAVE
                0x0089: 0x00E2,  # LATIN SMALL LETTER A WITH CIRCUMFLEX
                0x008A: 0x00E4,  # LATIN SMALL LETTER A WITH DIAERESIS
                0x008B: 0x00E3,  # LATIN SMALL LETTER A WITH TILDE
                0x008C: 0x00E5,  # LATIN SMALL LETTER A WITH RING ABOVE
                0x008D: 0x00E7,  # LATIN SMALL LETTER C WITH CEDILLA
                0x008E: 0x00E9,  # LATIN SMALL LETTER E WITH ACUTE
                0x008F: 0x00E8,  # LATIN SMALL LETTER E WITH GRAVE
                0x0090: 0x00EA,  # LATIN SMALL LETTER E WITH CIRCUMFLEX
                0x0091: 0x00EB,  # LATIN SMALL LETTER E WITH DIAERESIS
                0x0092: 0x00ED,  # LATIN SMALL LETTER I WITH ACUTE
                0x0093: 0x00EC,  # LATIN SMALL LETTER I WITH GRAVE
                0x0094: 0x00EE,  # LATIN SMALL LETTER I WITH CIRCUMFLEX
                0x0095: 0x00EF,  # LATIN SMALL LETTER I WITH DIAERESIS
                0x0096: 0x00F1,  # LATIN SMALL LETTER N WITH TILDE
                0x0097: 0x00F3,  # LATIN SMALL LETTER O WITH ACUTE
                0x0098: 0x00F2,  # LATIN SMALL LETTER O WITH GRAVE
                0x0099: 0x00F4,  # LATIN SMALL LETTER O WITH CIRCUMFLEX
                0x009A: 0x00F6,  # LATIN SMALL LETTER O WITH DIAERESIS
                0x009B: 0x00F5,  # LATIN SMALL LETTER O WITH TILDE
                0x009C: 0x00FA,  # LATIN SMALL LETTER U WITH ACUTE
                0x009D: 0x00F9,  # LATIN SMALL LETTER U WITH GRAVE
                0x009E: 0x00FB,  # LATIN SMALL LETTER U WITH CIRCUMFLEX
                0x009F: 0x00FC,  # LATIN SMALL LETTER U WITH DIAERESIS
                0x00A0: 0x2020,  # DAGGER
                0x00A1: 0x00B0,  # DEGREE SIGN
                0x00A4: 0x00A7,  # SECTION SIGN
                0x00A5: 0x2022,  # BULLET
                0x00A6: 0x00B6,  # PILCROW SIGN
                0x00A7: 0x00DF,  # LATIN SMALL LETTER SHARP S
                0x00A8: 0x00AE,  # REGISTERED SIGN
                0x00AA: 0x2122,  # TRADE MARK SIGN
                0x00AB: 0x00B4,  # ACUTE ACCENT
                0x00AC: 0x00A8,  # DIAERESIS
                0x00AD: None,  # UNDEFINED
                0x00AE: 0x00C6,  # LATIN CAPITAL LETTER AE
                0x00AF: 0x00D8,  # LATIN CAPITAL LETTER O WITH STROKE
                0x00B0: None,  # UNDEFINED
                0x00B2: None,  # UNDEFINED
                0x00B3: None,  # UNDEFINED
                0x00B4: 0x00A5,  # YEN SIGN
                0x00B6: None,  # UNDEFINED
                0x00B7: None,  # UNDEFINED
                0x00B8: None,  # UNDEFINED
                0x00B9: None,  # UNDEFINED
                0x00BA: None,  # UNDEFINED
                0x00BB: 0x00AA,  # FEMININE ORDINAL INDICATOR
                0x00BC: 0x00BA,  # MASCULINE ORDINAL INDICATOR
                0x00BD: None,  # UNDEFINED
                0x00BE: 0x00E6,  # LATIN SMALL LETTER AE
                0x00BF: 0x00F8,  # LATIN SMALL LETTER O WITH STROKE
                0x00C0: 0x00BF,  # INVERTED QUESTION MARK
                0x00C1: 0x00A1,  # INVERTED EXCLAMATION MARK
                0x00C2: 0x00AC,  # NOT SIGN
                0x00C3: None,  # UNDEFINED
                0x00C4: 0x0192,  # LATIN SMALL LETTER F WITH HOOK
                0x00C5: None,  # UNDEFINED
                0x00C6: None,  # UNDEFINED
                0x00C7: 0x00AB,  # LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
                0x00C8: 0x00BB,  # RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
                0x00C9: 0x2026,  # HORIZONTAL ELLIPSIS
                0x00CA: 0x0020,  # SPACE
                0x00CB: 0x00C0,  # LATIN CAPITAL LETTER A WITH GRAVE
                0x00CC: 0x00C3,  # LATIN CAPITAL LETTER A WITH TILDE
                0x00CD: 0x00D5,  # LATIN CAPITAL LETTER O WITH TILDE
                0x00CE: 0x0152,  # LATIN CAPITAL LIGATURE OE
                0x00CF: 0x0153,  # LATIN SMALL LIGATURE OE
                0x00D0: 0x2013,  # EN DASH
                0x00D1: 0x2014,  # EM DASH
                0x00D2: 0x201C,  # LEFT DOUBLE QUOTATION MARK
                0x00D3: 0x201D,  # RIGHT DOUBLE QUOTATION MARK
                0x00D4: 0x2018,  # LEFT SINGLE QUOTATION MARK
                0x00D5: 0x2019,  # RIGHT SINGLE QUOTATION MARK
                0x00D6: 0x00F7,  # DIVISION SIGN
                0x00D7: None,  # UNDEFINED
                0x00D8: 0x00FF,  # LATIN SMALL LETTER Y WITH DIAERESIS
                0x00D9: 0x0178,  # LATIN CAPITAL LETTER Y WITH DIAERESIS
                0x00DA: 0x2044,  # FRACTION SLASH
                0x00DB: 0x00A4,  # CURRENCY SIGN
                0x00DC: 0x2039,  # SINGLE LEFT-POINTING ANGLE QUOTATION MARK
                0x00DD: 0x203A,  # SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
                0x00DE: 0xFB01,  # LATIN SMALL LIGATURE FI
                0x00DF: 0xFB02,  # LATIN SMALL LIGATURE FL
                0x00E0: 0x2021,  # DOUBLE DAGGER
                0x00E1: 0x00B7,  # MIDDLE DOT
                0x00E2: 0x201A,  # SINGLE LOW-9 QUOTATION MARK
                0x00E3: 0x201E,  # DOUBLE LOW-9 QUOTATION MARK
                0x00E4: 0x2030,  # PER MILLE SIGN
                0x00E5: 0x00C2,  # LATIN CAPITAL LETTER A WITH CIRCUMFLEX
                0x00E6: 0x00CA,  # LATIN CAPITAL LETTER E WITH CIRCUMFLEX
                0x00E7: 0x00C1,  # LATIN CAPITAL LETTER A WITH ACUTE
                0x00E8: 0x00CB,  # LATIN CAPITAL LETTER E WITH DIAERESIS
                0x00E9: 0x00C8,  # LATIN CAPITAL LETTER E WITH GRAVE
                0x00EA: 0x00CD,  # LATIN CAPITAL LETTER I WITH ACUTE
                0x00EB: 0x00CE,  # LATIN CAPITAL LETTER I WITH CIRCUMFLEX
                0x00EC: 0x00CF,  # LATIN CAPITAL LETTER I WITH DIAERESIS
                0x00ED: 0x00CC,  # LATIN CAPITAL LETTER I WITH GRAVE
                0x00EE: 0x00D3,  # LATIN CAPITAL LETTER O WITH ACUTE
                0x00EF: 0x00D4,  # LATIN CAPITAL LETTER O WITH CIRCUMFLEX
                0x00F0: None,  # UNDEFINED
                0x00F1: 0x00D2,  # LATIN CAPITAL LETTER O WITH GRAVE
                0x00F2: 0x00DA,  # LATIN CAPITAL LETTER U WITH ACUTE
                0x00F3: 0x00DB,  # LATIN CAPITAL LETTER U WITH CIRCUMFLEX
                0x00F4: 0x00D9,  # LATIN CAPITAL LETTER U WITH GRAVE
                0x00F5: 0x0131,  # LATIN SMALL LETTER DOTLESS I
                0x00F6: 0x02C6,  # MODIFIER LETTER CIRCUMFLEX ACCENT
                0x00F7: 0x02DC,  # SMALL TILDE
                0x00F8: 0x00AF,  # MACRON
                0x00F9: 0x02D8,  # BREVE
                0x00FA: 0x02D9,  # DOT ABOVE
                0x00FB: 0x02DA,  # RING ABOVE
                0x00FC: 0x00B8,  # CEDILLA
                0x00FD: 0x02DD,  # DOUBLE ACUTE ACCENT
                0x00FE: 0x02DB,  # OGONEK
                0x00FF: 0x02C7,  # CARON
            },
            None,
        ),
        "standard": StdCodecData(
            {
                0x0027: 0x2019,  # RIGHT SINGLE QUOTATION MARK
                0x0060: 0x2018,  # LEFT SINGLE QUOTATION MARK
                0x007F: None,  # UNDEFINED
                0x0080: None,  # UNDEFINED
                0x0081: None,  # UNDEFINED
                0x0082: None,  # UNDEFINED
                0x0083: None,  # UNDEFINED
                0x0084: None,  # UNDEFINED
                0x0085: None,  # UNDEFINED
                0x0086: None,  # UNDEFINED
                0x0087: None,  # UNDEFINED
                0x0088: None,  # UNDEFINED
                0x0089: None,  # UNDEFINED
                0x008A: None,  # UNDEFINED
                0x008B: None,  # UNDEFINED
                0x008C: None,  # UNDEFINED
                0x008D: None,  # UNDEFINED
                0x008E: None,  # UNDEFINED
                0x008F: None,  # UNDEFINED
                0x0090: None,  # UNDEFINED
                0x0091: None,  # UNDEFINED
                0x0092: None,  # UNDEFINED
                0x0093: None,  # UNDEFINED
                0x0094: None,  # UNDEFINED
                0x0095: None,  # UNDEFINED
                0x0096: None,  # UNDEFINED
                0x0097: None,  # UNDEFINED
                0x0098: None,  # UNDEFINED
                0x0099: None,  # UNDEFINED
                0x009A: None,  # UNDEFINED
                0x009B: None,  # UNDEFINED
                0x009C: None,  # UNDEFINED
                0x009D: None,  # UNDEFINED
                0x009E: None,  # UNDEFINED
                0x009F: None,  # UNDEFINED
                0x00A0: None,  # UNDEFINED
                0x00A4: 0x2044,  # FRACTION SLASH
                0x00A6: 0x0192,  # LATIN SMALL LETTER F WITH HOOK
                0x00A8: 0x00A4,  # CURRENCY SIGN
                0x00A9: 0x0027,  # APOSTROPHE
                0x00AA: 0x201C,  # LEFT DOUBLE QUOTATION MARK
                0x00AC: 0x2039,  # SINGLE LEFT-POINTING ANGLE QUOTATION MARK
                0x00AD: 0x203A,  # SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
                0x00AE: 0xFB01,  # LATIN SMALL LIGATURE FI
                0x00AF: 0xFB02,  # LATIN SMALL LIGATURE FL
                0x00B0: None,  # UNDEFINED
                0x00B1: 0x2013,  # EN DASH
                0x00B2: 0x2020,  # DAGGER
                0x00B3: 0x2021,  # DOUBLE DAGGER
                0x00B4: 0x00B7,  # MIDDLE DOT
                0x00B5: None,  # UNDEFINED
                0x00B7: 0x2022,  # BULLET
                0x00B8: 0x201A,  # SINGLE LOW-9 QUOTATION MARK
                0x00B9: 0x201E,  # DOUBLE LOW-9 QUOTATION MARK
                0x00BA: 0x201D,  # RIGHT DOUBLE QUOTATION MARK
                0x00BC: 0x2026,  # HORIZONTAL ELLIPSIS
                0x00BD: 0x2030,  # PER MILLE SIGN
                0x00BE: None,  # UNDEFINED
                0x00C0: None,  # UNDEFINED
                0x00C1: 0x0060,  # GRAVE ACCENT
                0x00C2: 0x00B4,  # ACUTE ACCENT
                0x00C3: 0x02C6,  # MODIFIER LETTER CIRCUMFLEX ACCENT
                0x00C4: 0x02DC,  # SMALL TILDE
                0x00C5: 0x00AF,  # MACRON
                0x00C6: 0x02D8,  # BREVE
                0x00C7: 0x02D9,  # DOT ABOVE
                0x00C8: 0x00A8,  # DIAERESIS
                0x00C9: None,  # UNDEFINED
                0x00CA: 0x02DA,  # RING ABOVE
                0x00CB: 0x00B8,  # CEDILLA
                0x00CC: None,  # UNDEFINED
                0x00CD: 0x02DD,  # DOUBLE ACUTE ACCENT
                0x00CE: 0x02DB,  # OGONEK
                0x00CF: 0x02C7,  # CARON
                0x00D0: 0x2014,  # EM DASH
                0x00D1: None,  # UNDEFINED
                0x00D2: None,  # UNDEFINED
                0x00D3: None,  # UNDEFINED
                0x00D4: None,  # UNDEFINED
                0x00D5: None,  # UNDEFINED
                0x00D6: None,  # UNDEFINED
                0x00D7: None,  # UNDEFINED
                0x00D8: None,  # UNDEFINED
                0x00D9: None,  # UNDEFINED
                0x00DA: None,  # UNDEFINED
                0x00DB: None,  # UNDEFINED
                0x00DC: None,  # UNDEFINED
                0x00DD: None,  # UNDEFINED
                0x00DE: None,  # UNDEFINED
                0x00DF: None,  # UNDEFINED
                0x00E0: None,  # UNDEFINED
                0x00E1: 0x00C6,  # LATIN CAPITAL LETTER AE
                0x00E2: None,  # UNDEFINED
                0x00E3: 0x00AA,  # FEMININE ORDINAL INDICATOR
                0x00E4: None,  # UNDEFINED
                0x00E5: None,  # UNDEFINED
                0x00E6: None,  # UNDEFINED
                0x00E7: None,  # UNDEFINED
                0x00E8: 0x0141,  # LATIN CAPITAL LETTER L WITH STROKE
                0x00E9: 0x00D8,  # LATIN CAPITAL LETTER O WITH STROKE
                0x00EA: 0x0152,  # LATIN CAPITAL LIGATURE OE
                0x00EB: 0x00BA,  # MASCULINE ORDINAL INDICATOR
                0x00EC: None,  # UNDEFINED
                0x00ED: None,  # UNDEFINED
                0x00EE: None,  # UNDEFINED
                0x00EF: None,  # UNDEFINED
                0x00F0: None,  # UNDEFINED
                0x00F1: 0x00E6,  # LATIN SMALL LETTER AE
                0x00F2: None,  # UNDEFINED
                0x00F3: None,  # UNDEFINED
                0x00F4: None,  # UNDEFINED
                0x00F5: 0x0131,  # LATIN SMALL LETTER DOTLESS I
                0x00F6: None,  # UNDEFINED
                0x00F7: None,  # UNDEFINED
                0x00F8: 0x0142,  # LATIN SMALL LETTER L WITH STROKE
                0x00F9: 0x00F8,  # LATIN SMALL LETTER O WITH STROKE
                0x00FA: 0x0153,  # LATIN SMALL LIGATURE OE
                0x00FB: 0x00DF,  # LATIN SMALL LETTER SHARP S
                0x00FC: None,  # UNDEFINED
                0x00FD: None,  # UNDEFINED
                0x00FE: None,  # UNDEFINED
                0x00FF: None,  # UNDEFINED
            },
            None,
        ),
        "symbol": StdCodecData(
            {
                0x0022: 0x2200,  # FOR ALL
                0x0024: 0x2203,  # THERE EXISTS
                0x0027: 0x220B,  # CONTAINS AS MEMBER
                0x002A: 0x2217,  # ASTERISK OPERATOR
                0x002D: 0x2212,  # MINUS SIGN
                0x0040: 0x2245,  # APPROXIMATELY EQUAL TO
                0x0041: 0x0391,  # GREEK CAPITAL LETTER ALPHA
                0x0042: 0x0392,  # GREEK CAPITAL LETTER BETA
                0x0043: 0x03A7,  # GREEK CAPITAL LETTER CHI
                0x0044: 0x2206,  # INCREMENT
                0x0045: 0x0395,  # GREEK CAPITAL LETTER EPSILON
                0x0046: 0x03A6,  # GREEK CAPITAL LETTER PHI
                0x0047: 0x0393,  # GREEK CAPITAL LETTER GAMMA
                0x0048: 0x0397,  # GREEK CAPITAL LETTER ETA
                0x0049: 0x0399,  # GREEK CAPITAL LETTER IOTA
                0x004A: 0x03D1,  # GREEK THETA SYMBOL
                0x004B: 0x039A,  # GREEK CAPITAL LETTER KAPPA
                0x004C: 0x039B,  # GREEK CAPITAL LETTER LAMDA
                0x004D: 0x039C,  # GREEK CAPITAL LETTER MU
                0x004E: 0x039D,  # GREEK CAPITAL LETTER NU
                0x004F: 0x039F,  # GREEK CAPITAL LETTER OMICRON
                0x0050: 0x03A0,  # GREEK CAPITAL LETTER PI
                0x0051: 0x0398,  # GREEK CAPITAL LETTER THETA
                0x0052: 0x03A1,  # GREEK CAPITAL LETTER RHO
                0x0053: 0x03A3,  # GREEK CAPITAL LETTER SIGMA
                0x0054: 0x03A4,  # GREEK CAPITAL LETTER TAU
                0x0055: 0x03A5,  # GREEK CAPITAL LETTER UPSILON
                0x0056: 0x03C2,  # GREEK SMALL LETTER FINAL SIGMA
                0x0057: 0x2126,  # OHM SIGN
                0x0058: 0x039E,  # GREEK CAPITAL LETTER XI
                0x0059: 0x03A8,  # GREEK CAPITAL LETTER PSI
                0x005A: 0x0396,  # GREEK CAPITAL LETTER ZETA
                0x005C: 0x2234,  # THEREFORE
                0x005E: 0x22A5,  # UP TACK
                0x0060: 0xF8E5,  # [unknown unicode name for radicalex]
                0x0061: 0x03B1,  # GREEK SMALL LETTER ALPHA
                0x0062: 0x03B2,  # GREEK SMALL LETTER BETA
                0x0063: 0x03C7,  # GREEK SMALL LETTER CHI
                0x0064: 0x03B4,  # GREEK SMALL LETTER DELTA
                0x0065: 0x03B5,  # GREEK SMALL LETTER EPSILON
                0x0066: 0x03C6,  # GREEK SMALL LETTER PHI
                0x0067: 0x03B3,  # GREEK SMALL LETTER GAMMA
                0x0068: 0x03B7,  # GREEK SMALL LETTER ETA
                0x0069: 0x03B9,  # GREEK SMALL LETTER IOTA
                0x006A: 0x03D5,  # GREEK PHI SYMBOL
                0x006B: 0x03BA,  # GREEK SMALL LETTER KAPPA
                0x006C: 0x03BB,  # GREEK SMALL LETTER LAMDA
                0x006D: 0x00B5,  # MICRO SIGN
                0x006E: 0x03BD,  # GREEK SMALL LETTER NU
                0x006F: 0x03BF,  # GREEK SMALL LETTER OMICRON
                0x0070: 0x03C0,  # GREEK SMALL LETTER PI
                0x0071: 0x03B8,  # GREEK SMALL LETTER THETA
                0x0072: 0x03C1,  # GREEK SMALL LETTER RHO
                0x0073: 0x03C3,  # GREEK SMALL LETTER SIGMA
                0x0074: 0x03C4,  # GREEK SMALL LETTER TAU
                0x0075: 0x03C5,  # GREEK SMALL LETTER UPSILON
                0x0076: 0x03D6,  # GREEK PI SYMBOL
                0x0077: 0x03C9,  # GREEK SMALL LETTER OMEGA
                0x0078: 0x03BE,  # GREEK SMALL LETTER XI
                0x0079: 0x03C8,  # GREEK SMALL LETTER PSI
                0x007A: 0x03B6,  # GREEK SMALL LETTER ZETA
                0x007E: 0x223C,  # TILDE OPERATOR
                0x007F: None,  # UNDEFINED
                0x0080: None,  # UNDEFINED
                0x0081: None,  # UNDEFINED
                0x0082: None,  # UNDEFINED
                0x0083: None,  # UNDEFINED
                0x0084: None,  # UNDEFINED
                0x0085: None,  # UNDEFINED
                0x0086: None,  # UNDEFINED
                0x0087: None,  # UNDEFINED
                0x0088: None,  # UNDEFINED
                0x0089: None,  # UNDEFINED
                0x008A: None,  # UNDEFINED
                0x008B: None,  # UNDEFINED
                0x008C: None,  # UNDEFINED
                0x008D: None,  # UNDEFINED
                0x008E: None,  # UNDEFINED
                0x008F: None,  # UNDEFINED
                0x0090: None,  # UNDEFINED
                0x0091: None,  # UNDEFINED
                0x0092: None,  # UNDEFINED
                0x0093: None,  # UNDEFINED
                0x0094: None,  # UNDEFINED
                0x0095: None,  # UNDEFINED
                0x0096: None,  # UNDEFINED
                0x0097: None,  # UNDEFINED
                0x0098: None,  # UNDEFINED
                0x0099: None,  # UNDEFINED
                0x009A: None,  # UNDEFINED
                0x009B: None,  # UNDEFINED
                0x009C: None,  # UNDEFINED
                0x009D: None,  # UNDEFINED
                0x009E: None,  # UNDEFINED
                0x009F: None,  # UNDEFINED
                0x00A0: 0x20AC,  # EURO SIGN
                0x00A1: 0x03D2,  # GREEK UPSILON WITH HOOK SYMBOL
                0x00A2: 0x2032,  # PRIME
                0x00A3: 0x2264,  # LESS-THAN OR EQUAL TO
                0x00A4: 0x2044,  # FRACTION SLASH
                0x00A5: 0x221E,  # INFINITY
                0x00A6: 0x0192,  # LATIN SMALL LETTER F WITH HOOK
                0x00A7: 0x2663,  # BLACK CLUB SUIT
                0x00A8: 0x2666,  # BLACK DIAMOND SUIT
                0x00A9: 0x2665,  # BLACK HEART SUIT
                0x00AA: 0x2660,  # BLACK SPADE SUIT
                0x00AB: 0x2194,  # LEFT RIGHT ARROW
                0x00AC: 0x2190,  # LEFTWARDS ARROW
                0x00AD: 0x2191,  # UPWARDS ARROW
                0x00AE: 0x2192,  # RIGHTWARDS ARROW
                0x00AF: 0x2193,  # DOWNWARDS ARROW
                0x00B2: 0x2033,  # DOUBLE PRIME
                0x00B3: 0x2265,  # GREATER-THAN OR EQUAL TO
                0x00B4: 0x00D7,  # MULTIPLICATION SIGN
                0x00B5: 0x221D,  # PROPORTIONAL TO
                0x00B6: 0x2202,  # PARTIAL DIFFERENTIAL
                0x00B7: 0x2022,  # BULLET
                0x00B8: 0x00F7,  # DIVISION SIGN
                0x00B9: 0x2260,  # NOT EQUAL TO
                0x00BA: 0x2261,  # IDENTICAL TO
                0x00BB: 0x2248,  # ALMOST EQUAL TO
                0x00BC: 0x2026,  # HORIZONTAL ELLIPSIS
                0x00BD: 0xF8E6,  # [unknown unicode name for arrowvertex]
                0x00BE: 0xF8E7,  # [unknown unicode name for arrowhorizex]
                0x00BF: 0x21B5,  # DOWNWARDS ARROW WITH CORNER LEFTWARDS
                0x00C0: 0x2135,  # ALEF SYMBOL
                0x00C1: 0x2111,  # BLACK-LETTER CAPITAL I
                0x00C2: 0x211C,  # BLACK-LETTER CAPITAL R
                0x00C3: 0x2118,  # SCRIPT CAPITAL P
                0x00C4: 0x2297,  # CIRCLED TIMES
                0x00C5: 0x2295,  # CIRCLED PLUS
                0x00C6: 0x2205,  # EMPTY SET
                0x00C7: 0x2229,  # INTERSECTION
                0x00C8: 0x222A,  # UNION
                0x00C9: 0x2283,  # SUPERSET OF
                0x00CA: 0x2287,  # SUPERSET OF OR EQUAL TO
                0x00CB: 0x2284,  # NOT A SUBSET OF
                0x00CC: 0x2282,  # SUBSET OF
                0x00CD: 0x2286,  # SUBSET OF OR EQUAL TO
                0x00CE: 0x2208,  # ELEMENT OF
                0x00CF: 0x2209,  # NOT AN ELEMENT OF
                0x00D0: 0x2220,  # ANGLE
                0x00D1: 0x2207,  # NABLA
                0x00D2: 0xF6DA,  # [unknown unicode name for registerserif]
                0x00D3: 0xF6D9,  # [unknown unicode name for copyrightserif]
                0x00D4: 0xF6DB,  # [unknown unicode name for trademarkserif]
                0x00D5: 0x220F,  # N-ARY PRODUCT
                0x00D6: 0x221A,  # SQUARE ROOT
                0x00D7: 0x22C5,  # DOT OPERATOR
                0x00D8: 0x00AC,  # NOT SIGN
                0x00D9: 0x2227,  # LOGICAL AND
                0x00DA: 0x2228,  # LOGICAL OR
                0x00DB: 0x21D4,  # LEFT RIGHT DOUBLE ARROW
                0x00DC: 0x21D0,  # LEFTWARDS DOUBLE ARROW
                0x00DD: 0x21D1,  # UPWARDS DOUBLE ARROW
                0x00DE: 0x21D2,  # RIGHTWARDS DOUBLE ARROW
                0x00DF: 0x21D3,  # DOWNWARDS DOUBLE ARROW
                0x00E0: 0x25CA,  # LOZENGE
                0x00E1: 0x2329,  # LEFT-POINTING ANGLE BRACKET
                0x00E2: 0xF8E8,  # [unknown unicode name for registersans]
                0x00E3: 0xF8E9,  # [unknown unicode name for copyrightsans]
                0x00E4: 0xF8EA,  # [unknown unicode name for trademarksans]
                0x00E5: 0x2211,  # N-ARY SUMMATION
                0x00E6: 0xF8EB,  # [unknown unicode name for parenlefttp]
                0x00E7: 0xF8EC,  # [unknown unicode name for parenleftex]
                0x00E8: 0xF8ED,  # [unknown unicode name for parenleftbt]
                0x00E9: 0xF8EE,  # [unknown unicode name for bracketlefttp]
                0x00EA: 0xF8EF,  # [unknown unicode name for bracketleftex]
                0x00EB: 0xF8F0,  # [unknown unicode name for bracketleftbt]
                0x00EC: 0xF8F1,  # [unknown unicode name for bracelefttp]
                0x00ED: 0xF8F2,  # [unknown unicode name for braceleftmid]
                0x00EE: 0xF8F3,  # [unknown unicode name for braceleftbt]
                0x00EF: 0xF8F4,  # [unknown unicode name for braceex]
                0x00F0: None,  # UNDEFINED
                0x00F1: 0x232A,  # RIGHT-POINTING ANGLE BRACKET
                0x00F2: 0x222B,  # INTEGRAL
                0x00F3: 0x2320,  # TOP HALF INTEGRAL
                0x00F4: 0xF8F5,  # [unknown unicode name for integralex]
                0x00F5: 0x2321,  # BOTTOM HALF INTEGRAL
                0x00F6: 0xF8F6,  # [unknown unicode name for parenrighttp]
                0x00F7: 0xF8F7,  # [unknown unicode name for parenrightex]
                0x00F8: 0xF8F8,  # [unknown unicode name for parenrightbt]
                0x00F9: 0xF8F9,  # [unknown unicode name for bracketrighttp]
                0x00FA: 0xF8FA,  # [unknown unicode name for bracketrightex]
                0x00FB: 0xF8FB,  # [unknown unicode name for bracketrightbt]
                0x00FC: 0xF8FC,  # [unknown unicode name for bracerighttp]
                0x00FD: 0xF8FD,  # [unknown unicode name for bracerightmid]
                0x00FE: 0xF8FE,  # [unknown unicode name for bracerightbt]
                0x00FF: None,  # UNDEFINED
            },
            {
                0x0394: 0x0044,  # GREEK CAPITAL LETTER DELTA
                0x03A9: 0x0057,  # GREEK CAPITAL LETTER OMEGA
                0x03BC: 0x006D,  # GREEK SMALL LETTER MU
            },
        ),
        "zapfdingbats": StdCodecData(
            {
                0x0021: 0x2701,  # UPPER BLADE SCISSORS
                0x0022: 0x2702,  # BLACK SCISSORS
                0x0023: 0x2703,  # LOWER BLADE SCISSORS
                0x0024: 0x2704,  # WHITE SCISSORS
                0x0025: 0x260E,  # BLACK TELEPHONE
                0x0026: 0x2706,  # TELEPHONE LOCATION SIGN
                0x0027: 0x2707,  # TAPE DRIVE
                0x0028: 0x2708,  # AIRPLANE
                0x0029: 0x2709,  # ENVELOPE
                0x002A: 0x261B,  # BLACK RIGHT POINTING INDEX
                0x002B: 0x261E,  # WHITE RIGHT POINTING INDEX
                0x002C: 0x270C,  # VICTORY HAND
                0x002D: 0x270D,  # WRITING HAND
                0x002E: 0x270E,  # LOWER RIGHT PENCIL
                0x002F: 0x270F,  # PENCIL
                0x0030: 0x2710,  # UPPER RIGHT PENCIL
                0x0031: 0x2711,  # WHITE NIB
                0x0032: 0x2712,  # BLACK NIB
                0x0033: 0x2713,  # CHECK MARK
                0x0034: 0x2714,  # HEAVY CHECK MARK
                0x0035: 0x2715,  # MULTIPLICATION X
                0x0036: 0x2716,  # HEAVY MULTIPLICATION X
                0x0037: 0x2717,  # BALLOT X
                0x0038: 0x2718,  # HEAVY BALLOT X
                0x0039: 0x2719,  # OUTLINED GREEK CROSS
                0x003A: 0x271A,  # HEAVY GREEK CROSS
                0x003B: 0x271B,  # OPEN CENTRE CROSS
                0x003C: 0x271C,  # HEAVY OPEN CENTRE CROSS
                0x003D: 0x271D,  # LATIN CROSS
                0x003E: 0x271E,  # SHADOWED WHITE LATIN CROSS
                0x003F: 0x271F,  # OUTLINED LATIN CROSS
                0x0040: 0x2720,  # MALTESE CROSS
                0x0041: 0x2721,  # STAR OF DAVID
                0x0042: 0x2722,  # FOUR TEARDROP-SPOKED ASTERISK
                0x0043: 0x2723,  # FOUR BALLOON-SPOKED ASTERISK
                0x0044: 0x2724,  # HEAVY FOUR BALLOON-SPOKED ASTERISK
                0x0045: 0x2725,  # FOUR CLUB-SPOKED ASTERISK
                0x0046: 0x2726,  # BLACK FOUR POINTED STAR
                0x0047: 0x2727,  # WHITE FOUR POINTED STAR
                0x0048: 0x2605,  # BLACK STAR
                0x0049: 0x2729,  # STRESS OUTLINED WHITE STAR
                0x004A: 0x272A,  # CIRCLED WHITE STAR
                0x004B: 0x272B,  # OPEN CENTRE BLACK STAR
                0x004C: 0x272C,  # BLACK CENTRE WHITE STAR
                0x004D: 0x272D,  # OUTLINED BLACK STAR
                0x004E: 0x272E,  # HEAVY OUTLINED BLACK STAR
                0x004F: 0x272F,  # PINWHEEL STAR
                0x0050: 0x2730,  # SHADOWED WHITE STAR
                0x0051: 0x2731,  # HEAVY ASTERISK
                0x0052: 0x2732,  # OPEN CENTRE ASTERISK
                0x0053: 0x2733,  # EIGHT SPOKED ASTERISK
                0x0054: 0x2734,  # EIGHT POINTED BLACK STAR
                0x0055: 0x2735,  # EIGHT POINTED PINWHEEL STAR
                0x0056: 0x2736,  # SIX POINTED BLACK STAR
                0x0057: 0x2737,  # EIGHT POINTED RECTILINEAR BLACK STAR
                0x0058: 0x2738,  # HEAVY EIGHT POINTED RECTILINEAR BLACK STAR
                0x0059: 0x2739,  # TWELVE POINTED BLACK STAR
                0x005A: 0x273A,  # SIXTEEN POINTED ASTERISK
                0x005B: 0x273B,  # TEARDROP-SPOKED ASTERISK
                0x005C: 0x273C,  # OPEN CENTRE TEARDROP-SPOKED ASTERISK
                0x005D: 0x273D,  # HEAVY TEARDROP-SPOKED ASTERISK
                0x005E: 0x273E,  # SIX PETALLED BLACK AND WHITE FLORETTE
                0x005F: 0x273F,  # BLACK FLORETTE
                0x0060: 0x2740,  # WHITE FLORETTE
                0x0061: 0x2741,  # EIGHT PETALLED OUTLINED BLACK FLORETTE
                0x0062: 0x2742,  # CIRCLED OPEN CENTRE EIGHT POINTED STAR
                0x0063: 0x2743,  # HEAVY TEARDROP-SPOKED PINWHEEL ASTERISK
                0x0064: 0x2744,  # SNOWFLAKE
                0x0065: 0x2745,  # TIGHT TRIFOLIATE SNOWFLAKE
                0x0066: 0x2746,  # HEAVY CHEVRON SNOWFLAKE
                0x0067: 0x2747,  # SPARKLE
                0x0068: 0x2748,  # HEAVY SPARKLE
                0x0069: 0x2749,  # BALLOON-SPOKED ASTERISK
                0x006A: 0x274A,  # EIGHT TEARDROP-SPOKED PROPELLER ASTERISK
                0x006B: 0x274B,  # HEAVY EIGHT TEARDROP-SPOKED PROPELLER ASTERISK
                0x006C: 0x25CF,  # BLACK CIRCLE
                0x006D: 0x274D,  # SHADOWED WHITE CIRCLE
                0x006E: 0x25A0,  # BLACK SQUARE
                0x006F: 0x274F,  # LOWER RIGHT DROP-SHADOWED WHITE SQUARE
                0x0070: 0x2750,  # UPPER RIGHT DROP-SHADOWED WHITE SQUARE
                0x0071: 0x2751,  # LOWER RIGHT SHADOWED WHITE SQUARE
                0x0072: 0x2752,  # UPPER RIGHT SHADOWED WHITE SQUARE
                0x0073: 0x25B2,  # BLACK UP-POINTING TRIANGLE
                0x0074: 0x25BC,  # BLACK DOWN-POINTING TRIANGLE
                0x0075: 0x25C6,  # BLACK DIAMOND
                0x0076: 0x2756,  # BLACK DIAMOND MINUS WHITE X
                0x0077: 0x25D7,  # RIGHT HALF BLACK CIRCLE
                0x0078: 0x2758,  # LIGHT VERTICAL BAR
                0x0079: 0x2759,  # MEDIUM VERTICAL BAR
                0x007A: 0x275A,  # HEAVY VERTICAL BAR
                0x007B: 0x275B,  # HEAVY SINGLE TURNED COMMA QUOTATION MARK ORNAMENT
                0x007C: 0x275C,  # HEAVY SINGLE COMMA QUOTATION MARK ORNAMENT
                0x007D: 0x275D,  # HEAVY DOUBLE TURNED COMMA QUOTATION MARK ORNAMENT
                0x007E: 0x275E,  # HEAVY DOUBLE COMMA QUOTATION MARK ORNAMENT
                0x007F: None,  # UNDEFINED
                0x0080: 0x2768,  # MEDIUM LEFT PARENTHESIS ORNAMENT
                0x0081: 0x2769,  # MEDIUM RIGHT PARENTHESIS ORNAMENT
                0x0082: 0x276A,  # MEDIUM FLATTENED LEFT PARENTHESIS ORNAMENT
                0x0083: 0x276B,  # MEDIUM FLATTENED RIGHT PARENTHESIS ORNAMENT
                0x0084: 0x276C,  # MEDIUM LEFT-POINTING ANGLE BRACKET ORNAMENT
                0x0085: 0x276D,  # MEDIUM RIGHT-POINTING ANGLE BRACKET ORNAMENT
                0x0086: 0x276E,  # HEAVY LEFT-POINTING ANGLE QUOTATION MARK ORNAMENT
                0x0087: 0x276F,  # HEAVY RIGHT-POINTING ANGLE QUOTATION MARK ORNAMENT
                0x0088: 0x2770,  # HEAVY LEFT-POINTING ANGLE BRACKET ORNAMENT
                0x0089: 0x2771,  # HEAVY RIGHT-POINTING ANGLE BRACKET ORNAMENT
                0x008A: 0x2772,  # LIGHT LEFT TORTOISE SHELL BRACKET ORNAMENT
                0x008B: 0x2773,  # LIGHT RIGHT TORTOISE SHELL BRACKET ORNAMENT
                0x008C: 0x2774,  # MEDIUM LEFT CURLY BRACKET ORNAMENT
                0x008D: 0x2775,  # MEDIUM RIGHT CURLY BRACKET ORNAMENT
                0x008E: None,  # UNDEFINED
                0x008F: None,  # UNDEFINED
                0x0090: None,  # UNDEFINED
                0x0091: None,  # UNDEFINED
                0x0092: None,  # UNDEFINED
                0x0093: None,  # UNDEFINED
                0x0094: None,  # UNDEFINED
                0x0095: None,  # UNDEFINED
                0x0096: None,  # UNDEFINED
                0x0097: None,  # UNDEFINED
                0x0098: None,  # UNDEFINED
                0x0099: None,  # UNDEFINED
                0x009A: None,  # UNDEFINED
                0x009B: None,  # UNDEFINED
                0x009C: None,  # UNDEFINED
                0x009D: None,  # UNDEFINED
                0x009E: None,  # UNDEFINED
                0x009F: None,  # UNDEFINED
                0x00A0: None,  # UNDEFINED
                0x00A1: 0x2761,  # CURVED STEM PARAGRAPH SIGN ORNAMENT
                0x00A2: 0x2762,  # HEAVY EXCLAMATION MARK ORNAMENT
                0x00A3: 0x2763,  # HEAVY HEART EXCLAMATION MARK ORNAMENT
                0x00A4: 0x2764,  # HEAVY BLACK HEART
                0x00A5: 0x2765,  # ROTATED HEAVY BLACK HEART BULLET
                0x00A6: 0x2766,  # FLORAL HEART
                0x00A7: 0x2767,  # ROTATED FLORAL HEART BULLET
                0x00A8: 0x2663,  # BLACK CLUB SUIT
                0x00A9: 0x2666,  # BLACK DIAMOND SUIT
                0x00AA: 0x2665,  # BLACK HEART SUIT
                0x00AB: 0x2660,  # BLACK SPADE SUIT
                0x00AC: 0x2460,  # CIRCLED DIGIT ONE
                0x00AD: 0x2461,  # CIRCLED DIGIT TWO
                0x00AE: 0x2462,  # CIRCLED DIGIT THREE
                0x00AF: 0x2463,  # CIRCLED DIGIT FOUR
                0x00B0: 0x2464,  # CIRCLED DIGIT FIVE
                0x00B1: 0x2465,  # CIRCLED DIGIT SIX
                0x00B2: 0x2466,  # CIRCLED DIGIT SEVEN
                0x00B3: 0x2467,  # CIRCLED DIGIT EIGHT
                0x00B4: 0x2468,  # CIRCLED DIGIT NINE
                0x00B5: 0x2469,  # CIRCLED NUMBER TEN
                0x00B6: 0x2776,  # DINGBAT NEGATIVE CIRCLED DIGIT ONE
                0x00B7: 0x2777,  # DINGBAT NEGATIVE CIRCLED DIGIT TWO
                0x00B8: 0x2778,  # DINGBAT NEGATIVE CIRCLED DIGIT THREE
                0x00B9: 0x2779,  # DINGBAT NEGATIVE CIRCLED DIGIT FOUR
                0x00BA: 0x277A,  # DINGBAT NEGATIVE CIRCLED DIGIT FIVE
                0x00BB: 0x277B,  # DINGBAT NEGATIVE CIRCLED DIGIT SIX
                0x00BC: 0x277C,  # DINGBAT NEGATIVE CIRCLED DIGIT SEVEN
                0x00BD: 0x277D,  # DINGBAT NEGATIVE CIRCLED DIGIT EIGHT
                0x00BE: 0x277E,  # DINGBAT NEGATIVE CIRCLED DIGIT NINE
                0x00BF: 0x277F,  # DINGBAT NEGATIVE CIRCLED NUMBER TEN
                0x00C0: 0x2780,  # DINGBAT CIRCLED SANS-SERIF DIGIT ONE
                0x00C1: 0x2781,  # DINGBAT CIRCLED SANS-SERIF DIGIT TWO
                0x00C2: 0x2782,  # DINGBAT CIRCLED SANS-SERIF DIGIT THREE
                0x00C3: 0x2783,  # DINGBAT CIRCLED SANS-SERIF DIGIT FOUR
                0x00C4: 0x2784,  # DINGBAT CIRCLED SANS-SERIF DIGIT FIVE
                0x00C5: 0x2785,  # DINGBAT CIRCLED SANS-SERIF DIGIT SIX
                0x00C6: 0x2786,  # DINGBAT CIRCLED SANS-SERIF DIGIT SEVEN
                0x00C7: 0x2787,  # DINGBAT CIRCLED SANS-SERIF DIGIT EIGHT
                0x00C8: 0x2788,  # DINGBAT CIRCLED SANS-SERIF DIGIT NINE
                0x00C9: 0x2789,  # DINGBAT CIRCLED SANS-SERIF NUMBER TEN
                0x00CA: 0x278A,  # DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT ONE
                0x00CB: 0x278B,  # DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT TWO
                0x00CC: 0x278C,  # DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT THREE
                0x00CD: 0x278D,  # DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT FOUR
                0x00CE: 0x278E,  # DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT FIVE
                0x00CF: 0x278F,  # DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT SIX
                0x00D0: 0x2790,  # DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT SEVEN
                0x00D1: 0x2791,  # DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT EIGHT
                0x00D2: 0x2792,  # DINGBAT NEGATIVE CIRCLED SANS-SERIF DIGIT NINE
                0x00D3: 0x2793,  # DINGBAT NEGATIVE CIRCLED SANS-SERIF NUMBER TEN
                0x00D4: 0x2794,  # HEAVY WIDE-HEADED RIGHTWARDS ARROW
                0x00D5: 0x2192,  # RIGHTWARDS ARROW
                0x00D6: 0x2194,  # LEFT RIGHT ARROW
                0x00D7: 0x2195,  # UP DOWN ARROW
                0x00D8: 0x2798,  # HEAVY SOUTH EAST ARROW
                0x00D9: 0x2799,  # HEAVY RIGHTWARDS ARROW
                0x00DA: 0x279A,  # HEAVY NORTH EAST ARROW
                0x00DB: 0x279B,  # DRAFTING POINT RIGHTWARDS ARROW
                0x00DC: 0x279C,  # HEAVY ROUND-TIPPED RIGHTWARDS ARROW
                0x00DD: 0x279D,  # TRIANGLE-HEADED RIGHTWARDS ARROW
                0x00DE: 0x279E,  # HEAVY TRIANGLE-HEADED RIGHTWARDS ARROW
                0x00DF: 0x279F,  # DASHED TRIANGLE-HEADED RIGHTWARDS ARROW
                0x00E0: 0x27A0,  # HEAVY DASHED TRIANGLE-HEADED RIGHTWARDS ARROW
                0x00E1: 0x27A1,  # BLACK RIGHTWARDS ARROW
                0x00E2: 0x27A2,  # THREE-D TOP-LIGHTED RIGHTWARDS ARROWHEAD
                0x00E3: 0x27A3,  # THREE-D BOTTOM-LIGHTED RIGHTWARDS ARROWHEAD
                0x00E4: 0x27A4,  # BLACK RIGHTWARDS ARROWHEAD
                0x00E5: 0x27A5,  # HEAVY BLACK CURVED DOWNWARDS AND RIGHTWARDS ARROW
                0x00E6: 0x27A6,  # HEAVY BLACK CURVED UPWARDS AND RIGHTWARDS ARROW
                0x00E7: 0x27A7,  # SQUAT BLACK RIGHTWARDS ARROW
                0x00E8: 0x27A8,  # HEAVY CONCAVE-POINTED BLACK RIGHTWARDS ARROW
                0x00E9: 0x27A9,  # RIGHT-SHADED WHITE RIGHTWARDS ARROW
                0x00EA: 0x27AA,  # LEFT-SHADED WHITE RIGHTWARDS ARROW
                0x00EB: 0x27AB,  # BACK-TILTED SHADOWED WHITE RIGHTWARDS ARROW
                0x00EC: 0x27AC,  # FRONT-TILTED SHADOWED WHITE RIGHTWARDS ARROW
                0x00ED: 0x27AD,  # HEAVY LOWER RIGHT-SHADOWED WHITE RIGHTWARDS ARROW
                0x00EE: 0x27AE,  # HEAVY UPPER RIGHT-SHADOWED WHITE RIGHTWARDS ARROW
                0x00EF: 0x27AF,  # NOTCHED LOWER RIGHT-SHADOWED WHITE RIGHTWARDS ARROW
                0x00F0: None,  # UNDEFINED
                0x00F1: 0x27B1,  # NOTCHED UPPER RIGHT-SHADOWED WHITE RIGHTWARDS ARROW
                0x00F2: 0x27B2,  # CIRCLED HEAVY WHITE RIGHTWARDS ARROW
                0x00F3: 0x27B3,  # WHITE-FEATHERED RIGHTWARDS ARROW
                0x00F4: 0x27B4,  # BLACK-FEATHERED SOUTH EAST ARROW
                0x00F5: 0x27B5,  # BLACK-FEATHERED RIGHTWARDS ARROW
                0x00F6: 0x27B6,  # BLACK-FEATHERED NORTH EAST ARROW
                0x00F7: 0x27B7,  # HEAVY BLACK-FEATHERED SOUTH EAST ARROW
                0x00F8: 0x27B8,  # HEAVY BLACK-FEATHERED RIGHTWARDS ARROW
                0x00F9: 0x27B9,  # HEAVY BLACK-FEATHERED NORTH EAST ARROW
                0x00FA: 0x27BA,  # TEARDROP-BARBED RIGHTWARDS ARROW
                0x00FB: 0x27BB,  # HEAVY TEARDROP-SHANKED RIGHTWARDS ARROW
                0x00FC: 0x27BC,  # WEDGE-TAILED RIGHTWARDS ARROW
                0x00FD: 0x27BD,  # HEAVY WEDGE-TAILED RIGHTWARDS ARROW
                0x00FE: 0x27BE,  # OPEN-OUTLINED RIGHTWARDS ARROW
                0x00FF: None,  # UNDEFINED
            },
            None,
        ),
        "pdfdoc": StdCodecData(
            {
                # compatibility with pike pdf
                0x0000: 0x0000,  # (NULL) U
                0x0001: 0x0001,  # (START OF HEADING) U
                0x0002: 0x0002,  # (START OF TEXT) U
                0x0003: 0x0003,  # (END OF TEXT) U
                0x0004: 0x0004,  # (END OF TEXT) U
                0x0005: 0x0005,  # (END OF TRANSMISSION) U
                0x0006: 0x0006,  # (ACKNOWLEDGE) U
                0x0007: 0x0007,  # (BELL) U
                0x0008: 0x0008,  # (BACKSPACE) U
                0x000B: 0x000B,  # (LINE TABULATION) U
                0x000C: 0x000C,  # (FORM FEED) U
                0x000E: 0x000E,  # (SHIFT OUT) U
                0x000F: 0x000F,  # (SHIFT IN) U
                0x0010: 0x0010,  # (DATA LINK ESCAPE) U
                0x0011: 0x0011,  # (DEVICE CONTROL ONE) U
                0x0012: 0x0012,  # (DEVICE CONTROL TWO) U
                0x0013: 0x0013,  # (DEVICE CONTROL THREE) U
                0x0014: 0x0014,  # (DEVICE CONTROL FOUR) U
                0x0015: 0x0015,  # (NEGATIVE ACKNOWLEDGE) U
                0x0016: 0x0016,  # was a typo U+0017 in in PDF SPEC U
                0x0017: 0x0017,  # (END OF TRANSMISSION BLOCK) U
                0x007F: 0x007F,  # delete pdf spec UNDEFINED
                0x009F: 0x009F,  # application program command APC pdf spec UNDEFINED
                0x00AD: 0x00AD,  # soft hyphen spec UNDEFINED
                # properly defined by the pdf spec
                0x0009: 0x0009,  # (CHARACTER TABULATION) SR
                0x000A: 0x000A,  # (LINE FEED) SR
                0x000D: 0x000D,  # (CARRIAGE RETURN) SR
                0x0080: 0x2022,  # BULLET
                0x0081: 0x2020,  # DAGGER
                0x0082: 0x2021,  # DOUBLE DAGGER
                0x0083: 0x2026,  # HORIZONTAL ELLIPSIS
                0x0084: 0x2014,  # EM DASH
                0x0085: 0x2013,  # EN DASH
                0x0086: 0x0192,  # LATIN SMALL LETTER F WITH HOOK
                0x0087: 0x2044,  # FRACTION SLASH
                0x0088: 0x2039,  # SINGLE LEFT-POINTING ANGLE QUOTATION MARK
                0x0089: 0x203A,  # SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
                0x008A: 0x2212,  # MINUS SIGN
                0x008B: 0x2030,  # PER MILLE SIGN
                0x008C: 0x201E,  # DOUBLE LOW-9 QUOTATION MARK
                0x008D: 0x201C,  # LEFT DOUBLE QUOTATION MARK
                0x008E: 0x201D,  # RIGHT DOUBLE QUOTATION MARK
                0x008F: 0x2018,  # LEFT SINGLE QUOTATION MARK
                0x0090: 0x2019,  # RIGHT SINGLE QUOTATION MARK
                0x0091: 0x201A,  # SINGLE LOW-9 QUOTATION MARK
                0x0092: 0x2122,  # TRADE MARK SIGN
                0x0093: 0xFB01,  # LATIN SMALL LIGATURE FI
                0x0094: 0xFB02,  # LATIN SMALL LIGATURE FL
                0x0095: 0x0141,  # LATIN CAPITAL LETTER L WITH STROKE
                0x0096: 0x0152,  # LATIN CAPITAL LIGATURE OE
                0x0097: 0x0160,  # LATIN CAPITAL LETTER S WITH CARON
                0x0098: 0x0178,  # LATIN CAPITAL LETTER Y WITH DIAERESIS
                0x0099: 0x017D,  # LATIN CAPITAL LETTER Z WITH CARON
                0x009A: 0x0131,  # LATIN SMALL LETTER DOTLESS I
                0x009B: 0x0142,  # LATIN SMALL LETTER L WITH STROKE
                0x009C: 0x0153,  # LATIN SMALL LIGATURE OE
                0x009D: 0x0161,  # LATIN SMALL LETTER S WITH CARON
                0x009E: 0x017E,  # LATIN SMALL LETTER Z WITH CARON
                0x00A0: 0x20AC,  # EURO SIGN
                24: 0x02D8,  # breve
                25: 0x02C7,  # caron
                26: 0x02C6,  # circumflex
                27: 0x02D9,  # dotaccent
                28: 0x02DD,  # hungarumlaut
                29: 0x02DB,  # ogonek
                30: 0x02DA,  # ring
                31: 0x02DC,  # tilde
            },
            None,
        ),
        "macexpert": StdCodecData(
            {
                0x0021: 0xF721,  # [unknown unicode name for exclamsmall]
                0x0022: 0xF6F8,  # [unknown unicode name for Hungarumlautsmall]
                0x0023: 0xF7A2,  # [unknown unicode name for centoldstyle]
                0x0024: 0xF724,  # [unknown unicode name for dollaroldstyle]
                0x0025: 0xF6E4,  # [unknown unicode name for dollarsuperior]
                0x0026: 0xF726,  # [unknown unicode name for ampersandsmall]
                0x0027: 0xF7B4,  # [unknown unicode name for Acutesmall]
                0x0028: 0x207D,  # SUPERSCRIPT LEFT PARENTHESIS
                0x0029: 0x207E,  # SUPERSCRIPT RIGHT PARENTHESIS
                0x002A: 0x2025,  # TWO DOT LEADER
                0x002B: 0x2024,  # ONE DOT LEADER
                0x002F: 0x2044,  # FRACTION SLASH
                0x0030: 0xF730,  # [unknown unicode name for zerooldstyle]
                0x0031: 0xF731,  # [unknown unicode name for oneoldstyle]
                0x0032: 0xF732,  # [unknown unicode name for twooldstyle]
                0x0033: 0xF733,  # [unknown unicode name for threeoldstyle]
                0x0034: 0xF734,  # [unknown unicode name for fouroldstyle]
                0x0035: 0xF735,  # [unknown unicode name for fiveoldstyle]
                0x0036: 0xF736,  # [unknown unicode name for sixoldstyle]
                0x0037: 0xF737,  # [unknown unicode name for sevenoldstyle]
                0x0038: 0xF738,  # [unknown unicode name for eightoldstyle]
                0x0039: 0xF739,  # [unknown unicode name for nineoldstyle]
                0x003C: None,  # UNDEFINED
                0x003D: 0xF6DE,  # [unknown unicode name for threequartersemdash]
                0x003E: None,  # UNDEFINED
                0x003F: 0xF73F,  # [unknown unicode name for questionsmall]
                0x0040: None,  # UNDEFINED
                0x0041: None,  # UNDEFINED
                0x0042: None,  # UNDEFINED
                0x0043: None,  # UNDEFINED
                0x0044: 0xF7F0,  # [unknown unicode name for Ethsmall]
                0x0045: None,  # UNDEFINED
                0x0046: None,  # UNDEFINED
                0x0047: 0x00BC,  # VULGAR FRACTION ONE QUARTER
                0x0048: 0x00BD,  # VULGAR FRACTION ONE HALF
                0x0049: 0x00BE,  # VULGAR FRACTION THREE QUARTERS
                0x004A: 0x215B,  # VULGAR FRACTION ONE EIGHTH
                0x004B: 0x215C,  # VULGAR FRACTION THREE EIGHTHS
                0x004C: 0x215D,  # VULGAR FRACTION FIVE EIGHTHS
                0x004D: 0x215E,  # VULGAR FRACTION SEVEN EIGHTHS
                0x004E: 0x2153,  # VULGAR FRACTION ONE THIRD
                0x004F: 0x2154,  # VULGAR FRACTION TWO THIRDS
                0x0050: None,  # UNDEFINED
                0x0051: None,  # UNDEFINED
                0x0052: None,  # UNDEFINED
                0x0053: None,  # UNDEFINED
                0x0054: None,  # UNDEFINED
                0x0055: None,  # UNDEFINED
                0x0056: 0xFB00,  # LATIN SMALL LIGATURE FF
                0x0057: 0xFB01,  # LATIN SMALL LIGATURE FI
                0x0058: 0xFB02,  # LATIN SMALL LIGATURE FL
                0x0059: 0xFB03,  # LATIN SMALL LIGATURE FFI
                0x005A: 0xFB04,  # LATIN SMALL LIGATURE FFL
                0x005B: 0x208D,  # SUBSCRIPT LEFT PARENTHESIS
                0x005C: None,  # UNDEFINED
                0x005D: 0x208E,  # SUBSCRIPT RIGHT PARENTHESIS
                0x005E: 0xF6F6,  # [unknown unicode name for Circumflexsmall]
                0x005F: 0xF6E5,  # [unknown unicode name for hypheninferior]
                0x0060: 0xF760,  # [unknown unicode name for Gravesmall]
                0x0061: 0xF761,  # [unknown unicode name for Asmall]
                0x0062: 0xF762,  # [unknown unicode name for Bsmall]
                0x0063: 0xF763,  # [unknown unicode name for Csmall]
                0x0064: 0xF764,  # [unknown unicode name for Dsmall]
                0x0065: 0xF765,  # [unknown unicode name for Esmall]
                0x0066: 0xF766,  # [unknown unicode name for Fsmall]
                0x0067: 0xF767,  # [unknown unicode name for Gsmall]
                0x0068: 0xF768,  # [unknown unicode name for Hsmall]
                0x0069: 0xF769,  # [unknown unicode name for Ismall]
                0x006A: 0xF76A,  # [unknown unicode name for Jsmall]
                0x006B: 0xF76B,  # [unknown unicode name for Ksmall]
                0x006C: 0xF76C,  # [unknown unicode name for Lsmall]
                0x006D: 0xF76D,  # [unknown unicode name for Msmall]
                0x006E: 0xF76E,  # [unknown unicode name for Nsmall]
                0x006F: 0xF76F,  # [unknown unicode name for Osmall]
                0x0070: 0xF770,  # [unknown unicode name for Psmall]
                0x0071: 0xF771,  # [unknown unicode name for Qsmall]
                0x0072: 0xF772,  # [unknown unicode name for Rsmall]
                0x0073: 0xF773,  # [unknown unicode name for Ssmall]
                0x0074: 0xF774,  # [unknown unicode name for Tsmall]
                0x0075: 0xF775,  # [unknown unicode name for Usmall]
                0x0076: 0xF776,  # [unknown unicode name for Vsmall]
                0x0077: 0xF777,  # [unknown unicode name for Wsmall]
                0x0078: 0xF778,  # [unknown unicode name for Xsmall]
                0x0079: 0xF779,  # [unknown unicode name for Ysmall]
                0x007A: 0xF77A,  # [unknown unicode name for Zsmall]
                0x007B: 0x20A1,  # COLON SIGN
                0x007C: 0xF6DC,  # [unknown unicode name for onefitted]
                0x007D: 0xF6DD,  # [unknown unicode name for rupiah]
                0x007E: 0xF6FE,  # [unknown unicode name for Tildesmall]
                0x007F: None,  # UNDEFINED
                0x0080: None,  # UNDEFINED
                0x0081: 0xF6E9,  # [unknown unicode name for asuperior]
                0x0082: 0xF6E0,  # [unknown unicode name for centsuperior]
                0x0083: None,  # UNDEFINED
                0x0084: None,  # UNDEFINED
                0x0085: None,  # UNDEFINED
                0x0086: None,  # UNDEFINED
                0x0087: 0xF7E1,  # [unknown unicode name for Aacutesmall]
                0x0088: 0xF7E0,  # [unknown unicode name for Agravesmall]
                0x0089: 0xF7E2,  # [unknown unicode name for Acircumflexsmall]
                0x008A: 0xF7E4,  # [unknown unicode name for Adieresissmall]
                0x008B: 0xF7E3,  # [unknown unicode name for Atildesmall]
                0x008C: 0xF7E5,  # [unknown unicode name for Aringsmall]
                0x008D: 0xF7E7,  # [unknown unicode name for Ccedillasmall]
                0x008E: 0xF7E9,  # [unknown unicode name for Eacutesmall]
                0x008F: 0xF7E8,  # [unknown unicode name for Egravesmall]
                0x0090: 0xF7EA,  # [unknown unicode name for Ecircumflexsmall]
                0x0091: 0xF7EB,  # [unknown unicode name for Edieresissmall]
                0x0092: 0xF7ED,  # [unknown unicode name for Iacutesmall]
                0x0093: 0xF7EC,  # [unknown unicode name for Igravesmall]
                0x0094: 0xF7EE,  # [unknown unicode name for Icircumflexsmall]
                0x0095: 0xF7EF,  # [unknown unicode name for Idieresissmall]
                0x0096: 0xF7F1,  # [unknown unicode name for Ntildesmall]
                0x0097: 0xF7F3,  # [unknown unicode name for Oacutesmall]
                0x0098: 0xF7F2,  # [unknown unicode name for Ogravesmall]
                0x0099: 0xF7F4,  # [unknown unicode name for Ocircumflexsmall]
                0x009A: 0xF7F6,  # [unknown unicode name for Odieresissmall]
                0x009B: 0xF7F5,  # [unknown unicode name for Otildesmall]
                0x009C: 0xF7FA,  # [unknown unicode name for Uacutesmall]
                0x009D: 0xF7F9,  # [unknown unicode name for Ugravesmall]
                0x009E: 0xF7FB,  # [unknown unicode name for Ucircumflexsmall]
                0x009F: 0xF7FC,  # [unknown unicode name for Udieresissmall]
                0x00A0: None,  # UNDEFINED
                0x00A1: 0x2078,  # SUPERSCRIPT EIGHT
                0x00A2: 0x2084,  # SUBSCRIPT FOUR
                0x00A3: 0x2083,  # SUBSCRIPT THREE
                0x00A4: 0x2086,  # SUBSCRIPT SIX
                0x00A5: 0x2088,  # SUBSCRIPT EIGHT
                0x00A6: 0x2087,  # SUBSCRIPT SEVEN
                0x00A7: 0xF6FD,  # [unknown unicode name for Scaronsmall]
                0x00A8: None,  # UNDEFINED
                0x00A9: 0xF6DF,  # [unknown unicode name for centinferior]
                0x00AA: 0x2082,  # SUBSCRIPT TWO
                0x00AB: None,  # UNDEFINED
                0x00AC: 0xF7A8,  # [unknown unicode name for Dieresissmall]
                0x00AD: None,  # UNDEFINED
                0x00AE: 0xF6F5,  # [unknown unicode name for Caronsmall]
                0x00AF: 0xF6F0,  # [unknown unicode name for osuperior]
                0x00B0: 0x2085,  # SUBSCRIPT FIVE
                0x00B1: None,  # UNDEFINED
                0x00B2: 0xF6E1,  # [unknown unicode name for commainferior]
                0x00B3: 0xF6E7,  # [unknown unicode name for periodinferior]
                0x00B4: 0xF7FD,  # [unknown unicode name for Yacutesmall]
                0x00B5: None,  # UNDEFINED
                0x00B6: 0xF6E3,  # [unknown unicode name for dollarinferior]
                0x00B7: None,  # UNDEFINED
                0x00B8: None,  # UNDEFINED
                0x00B9: 0xF7FE,  # [unknown unicode name for Thornsmall]
                0x00BA: None,  # UNDEFINED
                0x00BB: 0x2089,  # SUBSCRIPT NINE
                0x00BC: 0x2080,  # SUBSCRIPT ZERO
                0x00BD: 0xF6FF,  # [unknown unicode name for Zcaronsmall]
                0x00BE: 0xF7E6,  # [unknown unicode name for AEsmall]
                0x00BF: 0xF7F8,  # [unknown unicode name for Oslashsmall]
                0x00C0: 0xF7BF,  # [unknown unicode name for questiondownsmall]
                0x00C1: 0x2081,  # SUBSCRIPT ONE
                0x00C2: 0xF6F9,  # [unknown unicode name for Lslashsmall]
                0x00C3: None,  # UNDEFINED
                0x00C4: None,  # UNDEFINED
                0x00C5: None,  # UNDEFINED
                0x00C6: None,  # UNDEFINED
                0x00C7: None,  # UNDEFINED
                0x00C8: None,  # UNDEFINED
                0x00C9: 0xF7B8,  # [unknown unicode name for Cedillasmall]
                0x00CA: None,  # UNDEFINED
                0x00CB: None,  # UNDEFINED
                0x00CC: None,  # UNDEFINED
                0x00CD: None,  # UNDEFINED
                0x00CE: None,  # UNDEFINED
                0x00CF: 0xF6FA,  # [unknown unicode name for OEsmall]
                0x00D0: 0x2012,  # FIGURE DASH
                0x00D1: 0xF6E6,  # [unknown unicode name for hyphensuperior]
                0x00D2: None,  # UNDEFINED
                0x00D3: None,  # UNDEFINED
                0x00D4: None,  # UNDEFINED
                0x00D5: None,  # UNDEFINED
                0x00D6: 0xF7A1,  # [unknown unicode name for exclamdownsmall]
                0x00D7: None,  # UNDEFINED
                0x00D8: 0xF7FF,  # [unknown unicode name for Ydieresissmall]
                0x00D9: None,  # UNDEFINED
                0x00DA: 0x00B9,  # SUPERSCRIPT ONE
                0x00DB: 0x00B2,  # SUPERSCRIPT TWO
                0x00DC: 0x00B3,  # SUPERSCRIPT THREE
                0x00DD: 0x2074,  # SUPERSCRIPT FOUR
                0x00DE: 0x2075,  # SUPERSCRIPT FIVE
                0x00DF: 0x2076,  # SUPERSCRIPT SIX
                0x00E0: 0x2077,  # SUPERSCRIPT SEVEN
                0x00E1: 0x2079,  # SUPERSCRIPT NINE
                0x00E2: 0x2070,  # SUPERSCRIPT ZERO
                0x00E3: None,  # UNDEFINED
                0x00E4: 0xF6EC,  # [unknown unicode name for esuperior]
                0x00E5: 0xF6F1,  # [unknown unicode name for rsuperior]
                0x00E6: 0xF6F3,  # [unknown unicode name for tsuperior]
                0x00E7: None,  # UNDEFINED
                0x00E8: None,  # UNDEFINED
                0x00E9: 0xF6ED,  # [unknown unicode name for isuperior]
                0x00EA: 0xF6F2,  # [unknown unicode name for ssuperior]
                0x00EB: 0xF6EB,  # [unknown unicode name for dsuperior]
                0x00EC: None,  # UNDEFINED
                0x00ED: None,  # UNDEFINED
                0x00EE: None,  # UNDEFINED
                0x00EF: None,  # UNDEFINED
                0x00F0: None,  # UNDEFINED
                0x00F1: 0xF6EE,  # [unknown unicode name for lsuperior]
                0x00F2: 0xF6FB,  # [unknown unicode name for Ogoneksmall]
                0x00F3: 0xF6F4,  # [unknown unicode name for Brevesmall]
                0x00F4: 0xF7AF,  # [unknown unicode name for Macronsmall]
                0x00F5: 0xF6EA,  # [unknown unicode name for bsuperior]
                0x00F6: 0x207F,  # SUPERSCRIPT LATIN SMALL LETTER N
                0x00F7: 0xF6EF,  # [unknown unicode name for msuperior]
                0x00F8: 0xF6E2,  # [unknown unicode name for commasuperior]
                0x00F9: 0xF6E8,  # [unknown unicode name for periodsuperior]
                0x00FA: 0xF6F7,  # [unknown unicode name for Dotaccentsmall]
                0x00FB: 0xF6FC,  # [unknown unicode name for Ringsmall]
                0x00FC: None,  # UNDEFINED
                0x00FD: None,  # UNDEFINED
                0x00FE: None,  # UNDEFINED
                0x00FF: None,  # UNDEFINED
            },
            None,
        ),
    }
    __rl_extension_codecs = {
        "extpdfdoc": ExtCodecData("pdfdoc", None, None),
    }
    # for k,v in __rl_codecs_data.items():
    #   __rl_codecs_data[k+'enc'] = __rl_codecs_data[k+'encoding'] = v
    # del k,v

    __rl_dynamic_codecs = []

    def __init__(self):
        raise NotImplementedError

    @staticmethod
    def _makeCodecInfo(name, encoding_map, decoding_map):
        ### Codec APIs
        class Codec(codecs.Codec):
            def encode(self, input, errors="strict", charmap_encode=codecs.charmap_encode, encoding_map=encoding_map):
                return charmap_encode(input, errors, encoding_map)

            def decode(self, input, errors="strict", charmap_decode=codecs.charmap_decode, decoding_map=decoding_map):
                return charmap_decode(input, errors, decoding_map)

        class StreamWriter(Codec, codecs.StreamWriter):
            pass

        class StreamReader(Codec, codecs.StreamReader):
            pass

        C = Codec()
        return codecs.CodecInfo(C.encode, C.decode, streamreader=StreamReader, streamwriter=StreamWriter, name=name)

    @staticmethod
    def _256_exception_codec(name, exceptions, rexceptions, baseRange=range(32, 256)):
        decoding_map = codecs.make_identity_dict(baseRange)
        decoding_map.update(exceptions)
        encoding_map = codecs.make_encoding_map(decoding_map)
        if rexceptions:
            encoding_map.update(rexceptions)
        return RL_Codecs._makeCodecInfo(name, encoding_map, decoding_map)

    __rl_codecs_cache = {}

    @staticmethod
    def __rl_codecs(
        name, cache=__rl_codecs_cache, data=__rl_codecs_data, extension_codecs=__rl_extension_codecs, _256=True
    ):
        try:
            return cache[name]
        except KeyError:
            if name in extension_codecs:
                x = extension_codecs[name]
                e, r = data[x.baseName]
                if x.exceptions:
                    if e:
                        e = e.copy()
                        e.update(x.exceptions)
                    else:
                        e = x.exceptions
                if x.rexceptions:
                    if r:
                        r = r.copy()
                        r.update(x.rexceptions)
                    else:
                        r = x.exceptions
            else:
                e, r = data[name]
            cache[name] = c = (
                RL_Codecs._256_exception_codec(name, e, r) if _256 else RL_Codecs._makeCodecInfo(name, e, r or {})
            )
        return c

    @staticmethod
    def _rl_codecs(name):
        name = name.lower()
        from reportlab.pdfbase.pdfmetrics import standardEncodings

        for e in standardEncodings + ("ExtPdfdocEncoding",):
            e = e[:-8].lower()
            if name.startswith(e):
                return RL_Codecs.__rl_codecs(e)
        if name in RL_Codecs.__rl_dynamic_codecs:
            return RL_Codecs.__rl_codecs(name, _256=False)
        return None

    @staticmethod
    def register():
        codecs.register(RL_Codecs._rl_codecs)

    @staticmethod
    def add_dynamic_codec(name, exceptions, rexceptions):
        name = name.lower()
        RL_Codecs.remove_dynamic_codec(name)
        RL_Codecs.__rl_codecs_data[name] = (exceptions, rexceptions)
        RL_Codecs.__rl_dynamic_codecs.append(name)

    @staticmethod
    def remove_dynamic_codec(name):
        name = name.lower()
        if name in RL_Codecs.__rl_dynamic_codecs:
            RL_Codecs.__rl_codecs_data.pop(name, None)
            RL_Codecs.__rl_codecs_cache.pop(name, None)
            RL_Codecs.__rl_dynamic_codecs.remove(name)

    @staticmethod
    def reset_dynamic_codecs():
        map(RL_Codecs.remove_dynamic_codec, RL_Codecs.__rl_dynamic_codecs)
