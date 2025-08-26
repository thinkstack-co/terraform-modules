# Copyright ReportLab Europe Ltd. 2000-2017
# see license.txt for license details
# history https://hg.reportlab.com/hg-public/reportlab/log/tip/src/reportlab/platypus/paraparser.py
__all__ = ("ParaFrag", "ParaParser")
__version__ = "3.5.20"
__doc__ = """The parser used to process markup within paragraphs"""
import copy
import re
import sys
import unicodedata
from html.entities import name2codepoint
from html.parser import HTMLParser

import reportlab.lib.sequencer
from reportlab.lib.abag import ABag
from reportlab.lib.colors import black, toColor
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY, TA_LEFT, TA_RIGHT
from reportlab.lib.fonts import ps2tt, tt2ps
from reportlab.lib.units import cm, inch, mm, pica
from reportlab.lib.utils import ImageReader, annotateException, asUnicode, encode_label
from reportlab.rl_config import platypus_link_underline

_re_para = re.compile(r"^\s*<\s*para(?:\s+|>|/>)")

sizeDelta = 2  # amount to reduce font size by for super and sub script
subFraction = 0.5  # fraction of font size that a sub script should be lowered
supFraction = 0.5  # fraction of font size that a super script should be raised

DEFAULT_INDEX_NAME = "_indexAdd"


def _convnum(s, unit=1, allowRelative=True):
    if s[0] in ("+", "-") and allowRelative:
        try:
            return ("relative", int(s) * unit)
        except ValueError:
            return ("relative", float(s) * unit)
    else:
        try:
            return int(s) * unit
        except ValueError:
            return float(s) * unit


def _num(
    s,
    unit=1,
    allowRelative=True,
    _unit_map={"i": inch, "in": inch, "pt": 1, "cm": cm, "mm": mm, "pica": pica},
    _re_unit=re.compile(r"^\s*(.*)(i|in|cm|mm|pt|pica)\s*$"),
):
    """Convert a string like '10cm' to an int or float (in points).
    The default unit is point, but optionally you can use other
    default units like mm.
    """
    m = _re_unit.match(s)
    if m:
        unit = _unit_map[m.group(2)]
        s = m.group(1)
    return _convnum(s, unit, allowRelative)


def _int(s):
    try:
        return int(s)
    except:
        raise ValueError("cannot convert %r to int" % s)


def _bool(s):
    s = s.lower()
    if s in ("true", "1", "yes"):
        return True
    if s in ("false", "0", "no"):
        return False
    raise ValueError("cannot convert %r to bool value" % s)


def _numpct(s, unit=1, allowRelative=False):
    if s.endswith("%"):
        return _PCT(_convnum(s[:-1], allowRelative=allowRelative))
    else:
        return _num(s, unit, allowRelative)


class _PCT(float):
    def __new__(cls, v):
        self = float.__new__(cls, v * 0.01)
        self._normalizer = 1.0
        self._value = v
        return self

    def normalizedValue(self, normalizer):
        if not normalizer:
            normaliser = self._normalizer
        r = _PCT(normalizer * self._value)
        r._value = self._value
        r._normalizer = normalizer
        return r

    def __copy__(self):
        r = _PCT(float(self))
        r._value = self._value
        r._normalizer = normalizer
        return r

    def __deepcopy__(self, mem):
        return self.__copy__()


def fontSizeNormalize(frag, attr, default):
    if not hasattr(frag, attr):
        return default
    v = _numpct(getattr(frag, attr), allowRelative=True)
    return (
        (v[1] + frag.fontSize)
        if isinstance(v, tuple)
        else v.normalizedValue(frag.fontSize)
        if isinstance(v, _PCT)
        else v
    )


class _ExValidate:
    """class for syntax checking attributes"""

    def __init__(self, tag, attr):
        self.tag = tag
        self.attr = attr

    def invalid(self, s):
        raise ValueError("<%s> invalid value %r for attribute %s" % (self.tag, s, self.attr))

    def validate(self, parser, s):
        raise ValueError("abstract method called")
        return s

    def __call__(self, parser, s):
        try:
            return self.validate(parser, s)
        except:
            self.invalid(s)


class _CheckSup(_ExValidate):
    """class for syntax checking <sup|sub> attributes
    if the check succeeds then we always return the string for later evaluation"""

    def validate(self, parser, s):
        self.fontSize = parser._stack[-1].fontSize
        fontSizeNormalize(self, self.attr, "")
        return s

    def __call__(self, parser, s):
        setattr(self, self.attr, s)
        return _ExValidate.__call__(self, parser, s)


_lineRepeats = dict(single=1, double=2, triple=3)
_re_us_value = re.compile(r"^\s*(.*)\s*\*\s*(P|L|f|F)\s*$")


class _CheckUS(_ExValidate):
    """class for syntax checking <u|strike> width/offset attributes"""

    def validate(self, parser, s):
        s = s.strip()
        if s:
            m = _re_us_value.match(s)
            if m:
                v = float(m.group(1))
                if m.group(2) == "P":
                    return parser._stack[0].fontSize * v
            else:
                _num(s, allowRelative=False)
        return s


def _valignpc(s):
    s = s.lower()
    if s in ("baseline", "sub", "super", "top", "text-top", "middle", "bottom", "text-bottom"):
        return s
    if s.endswith("%"):
        n = _convnum(s[:-1])
        if isinstance(n, tuple):
            n = n[1]
        return _PCT(n)
    n = _num(s)
    if isinstance(n, tuple):
        n = n[1]
    return n


def _autoLeading(x):
    x = x.lower()
    if x in ("", "min", "max", "off"):
        return x
    raise ValueError("Invalid autoLeading=%r" % x)


def _align(s):
    s = s.lower()
    if s == "left":
        return TA_LEFT
    elif s == "right":
        return TA_RIGHT
    elif s == "justify":
        return TA_JUSTIFY
    elif s in ("centre", "center"):
        return TA_CENTER
    else:
        raise ValueError("illegal alignment %r" % s)


def _bAnchor(s):
    s = s.lower()
    if not s in ("start", "middle", "end", "numeric"):
        raise ValueError("illegal bullet anchor %r" % s)
    return s


def _wordWrapConv(s):
    s = s.upper().strip()
    if not s:
        return None
    if s not in ("CJK", "RTL", "LTR"):
        raise ValueError("cannot convert wordWrap=%r" % s)
    return s


def _textTransformConv(s):
    s = s.lower().strip()
    if not s:
        return None
    if s not in ("uppercase", "lowercase", "capitalize", "none"):
        raise ValueError("cannot convert textTransform=%r" % s)
    return s


_paraAttrMap = {
    "font": ("fontName", None),
    "face": ("fontName", None),
    "fontsize": ("fontSize", _num),
    "size": ("fontSize", _num),
    "leading": ("leading", _num),
    "autoleading": ("autoLeading", _autoLeading),
    "lindent": ("leftIndent", _num),
    "rindent": ("rightIndent", _num),
    "findent": ("firstLineIndent", _num),
    "align": ("alignment", _align),
    "spaceb": ("spaceBefore", _num),
    "spacea": ("spaceAfter", _num),
    "bfont": ("bulletFontName", None),
    "bfontsize": ("bulletFontSize", _num),
    "boffsety": ("bulletOffsetY", _num),
    "bindent": ("bulletIndent", _num),
    "bcolor": ("bulletColor", toColor),
    "banchor": ("bulletAnchor", _bAnchor),
    "color": ("textColor", toColor),
    "backcolor": ("backColor", toColor),
    "bgcolor": ("backColor", toColor),
    "bg": ("backColor", toColor),
    "fg": ("textColor", toColor),
    "justifybreaks": ("justifyBreaks", _bool),
    "justifylastline": ("justifyLastLine", _int),
    "wordwrap": ("wordWrap", _wordWrapConv),
    "shaping": ("shaping", _bool),
    "allowwidows": ("allowWidows", _bool),
    "alloworphans": ("allowOrphans", _bool),
    "splitlongwords": ("splitLongWords", _bool),
    "borderwidth": ("borderWidth", _num),
    "borderpadding": ("borderPadding", _num),
    "bordercolor": ("borderColor", toColor),
    "borderradius": ("borderRadius", _num),
    "texttransform": ("textTransform", _textTransformConv),
    "enddots": ("endDots", None),
    "underlinewidth": ("underlineWidth", _CheckUS("para", "underlineWidth")),
    "underlinecolor": ("underlineColor", toColor),
    "underlineoffset": ("underlineOffset", _CheckUS("para", "underlineOffset")),
    "underlinegap": ("underlineGap", _CheckUS("para", "underlineGap")),
    "strikewidth": ("strikeWidth", _CheckUS("para", "strikeWidth")),
    "strikecolor": ("strikeColor", toColor),
    "strikeoffset": ("strikeOffset", _CheckUS("para", "strikeOffset")),
    "strikegap": ("strikeGap", _CheckUS("para", "strikeGap")),
    "spaceshrinkage": ("spaceShrinkage", _num),
    "hyphenationLanguage": ("hyphenationLang", None),
    "hyphenationOverflow": ("hyphenationOverflow", _bool),
    "hyphenationMinWordLength": ("hyphenationMinWordLength", _int),
    "uriWasteReduce": ("uriWasteReduce", _num),
    "embeddedHyphenation": ("embeddedHyphenation", _bool),
}

_bulletAttrMap = {
    "font": ("bulletFontName", None),
    "face": ("bulletFontName", None),
    "size": ("bulletFontSize", _num),
    "fontsize": ("bulletFontSize", _num),
    "offsety": ("bulletOffsetY", _num),
    "indent": ("bulletIndent", _num),
    "color": ("bulletColor", toColor),
    "fg": ("bulletColor", toColor),
    "anchor": ("bulletAnchor", _bAnchor),
}

# things which are valid font attributes
_fontAttrMap = {
    "size": ("fontSize", _num),
    "face": ("fontName", None),
    "name": ("fontName", None),
    "fg": ("textColor", toColor),
    "color": ("textColor", toColor),
    "backcolor": ("backColor", toColor),
    "bgcolor": ("backColor", toColor),
}
# things which are valid span attributes
_spanAttrMap = {
    "size": ("fontSize", _num),
    "face": ("fontName", None),
    "name": ("fontName", None),
    "fg": ("textColor", toColor),
    "color": ("textColor", toColor),
    "backcolor": ("backColor", toColor),
    "bgcolor": ("backColor", toColor),
    "style": ("style", None),
}
# things which are valid font attributes
_linkAttrMap = {
    "size": ("fontSize", _num),
    "face": ("fontName", None),
    "name": ("fontName", None),
    "fg": ("textColor", toColor),
    "color": ("textColor", toColor),
    "backcolor": ("backColor", toColor),
    "bgcolor": ("backColor", toColor),
    "dest": ("link", None),
    "destination": ("link", None),
    "target": ("link", None),
    "href": ("link", None),
    "ucolor": ("underlineColor", toColor),
    "uoffset": ("underlineOffset", _CheckUS("link", "underlineOffset")),
    "uwidth": ("underlineWidth", _CheckUS("link", "underlineWidth")),
    "ugap": ("underlineGap", _CheckUS("link", "underlineGap")),
    "underline": ("underline", _bool),
    "ukind": ("underlineKind", None),
}
_anchorAttrMap = {
    "name": ("name", None),
}
_imgAttrMap = {
    "src": ("src", None),
    "width": ("width", _numpct),
    "height": ("height", _numpct),
    "valign": ("valign", _valignpc),
}
_indexAttrMap = {
    "name": ("name", None),
    "item": ("item", None),
    "offset": ("offset", None),
    "format": ("format", None),
}
_supAttrMap = {
    "rise": ("supr", _CheckSup("sup|sub", "rise")),
    "size": ("sups", _CheckSup("sup|sub", "size")),
}
_uAttrMap = {
    "color": ("underlineColor", toColor),
    "width": ("underlineWidth", _CheckUS("underline", "underlineWidth")),
    "offset": ("underlineOffset", _CheckUS("underline", "underlineOffset")),
    "gap": ("underlineGap", _CheckUS("underline", "underlineGap")),
    "kind": ("underlineKind", None),
}
_strikeAttrMap = {
    "color": ("strikeColor", toColor),
    "width": ("strikeWidth", _CheckUS("strike", "strikeWidth")),
    "offset": ("strikeOffset", _CheckUS("strike", "strikeOffset")),
    "gap": ("strikeGap", _CheckUS("strike", "strikeGap")),
    "kind": ("strikeKind", None),
}


def _addAttributeNames(m):
    K = list(m.keys())
    for k in K:
        n = m[k][0]
        if n not in m:
            m[n] = m[k]
        n = n.lower()
        if n not in m:
            m[n] = m[k]


_addAttributeNames(_paraAttrMap)
_addAttributeNames(_fontAttrMap)
_addAttributeNames(_spanAttrMap)
_addAttributeNames(_bulletAttrMap)
_addAttributeNames(_anchorAttrMap)
_addAttributeNames(_linkAttrMap)


def _applyAttributes(obj, attr):
    for k, v in attr.items():
        if isinstance(v, (list, tuple)) and v[0] == "relative":
            if hasattr(obj, k):
                v = v[1] + getattr(obj, k)
            else:
                v = v[1]
        setattr(obj, k, v)


# Named character entities intended to be supported from the special font
# with additions suggested by Christoph Zwerschke who also suggested the
# numeric entity names that follow.
greeks = {
    "Aacute": "\xc1",  # LATIN CAPITAL LETTER A WITH ACUTE
    "aacute": "\xe1",  # LATIN SMALL LETTER A WITH ACUTE
    "Abreve": "\u0102",  # LATIN CAPITAL LETTER A WITH BREVE
    "abreve": "\u0103",  # LATIN SMALL LETTER A WITH BREVE
    "ac": "\u223e",  # INVERTED LAZY S
    "acd": "\u223f",  # SINE WAVE
    "acE": "\u223e\u0333",  # INVERTED LAZY S with double underline
    "Acirc": "\xc2",  # LATIN CAPITAL LETTER A WITH CIRCUMFLEX
    "acirc": "\xe2",  # LATIN SMALL LETTER A WITH CIRCUMFLEX
    "acute": "\xb4",  # ACUTE ACCENT
    "Acy": "\u0410",  # CYRILLIC CAPITAL LETTER A
    "acy": "\u0430",  # CYRILLIC SMALL LETTER A
    "AElig": "\xc6",  # LATIN CAPITAL LETTER AE
    "aelig": "\xe6",  # LATIN SMALL LETTER AE
    "af": "\u2061",  # FUNCTION APPLICATION
    "Afr": "\U0001d504",  # MATHEMATICAL FRAKTUR CAPITAL A
    "afr": "\U0001d51e",  # MATHEMATICAL FRAKTUR SMALL A
    "Agrave": "\xc0",  # LATIN CAPITAL LETTER A WITH GRAVE
    "agrave": "\xe0",  # LATIN SMALL LETTER A WITH GRAVE
    "alefsym": "\u2135",  # ALEF SYMBOL
    "aleph": "\u2135",  # ALEF SYMBOL
    "Alpha": "\u0391",  # GREEK CAPITAL LETTER ALPHA
    "alpha": "\u03b1",  # GREEK SMALL LETTER ALPHA
    "Amacr": "\u0100",  # LATIN CAPITAL LETTER A WITH MACRON
    "amacr": "\u0101",  # LATIN SMALL LETTER A WITH MACRON
    "amalg": "\u2a3f",  # AMALGAMATION OR COPRODUCT
    "AMP": "\x26",  # AMPERSAND
    "amp": "\x26",  # AMPERSAND
    "And": "\u2a53",  # DOUBLE LOGICAL AND
    "and": "\u2227",  # LOGICAL AND
    "andand": "\u2a55",  # TWO INTERSECTING LOGICAL AND
    "andd": "\u2a5c",  # LOGICAL AND WITH HORIZONTAL DASH
    "andslope": "\u2a58",  # SLOPING LARGE AND
    "andv": "\u2a5a",  # LOGICAL AND WITH MIDDLE STEM
    "ang": "\u2220",  # ANGLE
    "ange": "\u29a4",  # ANGLE WITH UNDERBAR
    "angle": "\u2220",  # ANGLE
    "angmsd": "\u2221",  # MEASURED ANGLE
    "angmsdaa": "\u29a8",  # MEASURED ANGLE WITH OPEN ARM ENDING IN ARROW POINTING UP AND RIGHT
    "angmsdab": "\u29a9",  # MEASURED ANGLE WITH OPEN ARM ENDING IN ARROW POINTING UP AND LEFT
    "angmsdac": "\u29aa",  # MEASURED ANGLE WITH OPEN ARM ENDING IN ARROW POINTING DOWN AND RIGHT
    "angmsdad": "\u29ab",  # MEASURED ANGLE WITH OPEN ARM ENDING IN ARROW POINTING DOWN AND LEFT
    "angmsdae": "\u29ac",  # MEASURED ANGLE WITH OPEN ARM ENDING IN ARROW POINTING RIGHT AND UP
    "angmsdaf": "\u29ad",  # MEASURED ANGLE WITH OPEN ARM ENDING IN ARROW POINTING LEFT AND UP
    "angmsdag": "\u29ae",  # MEASURED ANGLE WITH OPEN ARM ENDING IN ARROW POINTING RIGHT AND DOWN
    "angmsdah": "\u29af",  # MEASURED ANGLE WITH OPEN ARM ENDING IN ARROW POINTING LEFT AND DOWN
    "angrt": "\u221f",  # RIGHT ANGLE
    "angrtvb": "\u22be",  # RIGHT ANGLE WITH ARC
    "angrtvbd": "\u299d",  # MEASURED RIGHT ANGLE WITH DOT
    "angsph": "\u2222",  # SPHERICAL ANGLE
    "angst": "\xc5",  # LATIN CAPITAL LETTER A WITH RING ABOVE
    "angzarr": "\u237c",  # RIGHT ANGLE WITH DOWNWARDS ZIGZAG ARROW
    "Aogon": "\u0104",  # LATIN CAPITAL LETTER A WITH OGONEK
    "aogon": "\u0105",  # LATIN SMALL LETTER A WITH OGONEK
    "Aopf": "\U0001d538",  # MATHEMATICAL DOUBLE-STRUCK CAPITAL A
    "aopf": "\U0001d552",  # MATHEMATICAL DOUBLE-STRUCK SMALL A
    "ap": "\u2248",  # ALMOST EQUAL TO
    "apacir": "\u2a6f",  # ALMOST EQUAL TO WITH CIRCUMFLEX ACCENT
    "apE": "\u2a70",  # APPROXIMATELY EQUAL OR EQUAL TO
    "ape": "\u224a",  # ALMOST EQUAL OR EQUAL TO
    "apid": "\u224b",  # TRIPLE TILDE
    "apos": "'",  # APOSTROPHE
    "ApplyFunction": "\u2061",  # FUNCTION APPLICATION
    "approx": "\u2248",  # ALMOST EQUAL TO
    "approxeq": "\u224a",  # ALMOST EQUAL OR EQUAL TO
    "Aring": "\xc5",  # LATIN CAPITAL LETTER A WITH RING ABOVE
    "aring": "\xe5",  # LATIN SMALL LETTER A WITH RING ABOVE
    "Ascr": "\U0001d49c",  # MATHEMATICAL SCRIPT CAPITAL A
    "ascr": "\U0001d4b6",  # MATHEMATICAL SCRIPT SMALL A
    "Assign": "\u2254",  # COLON EQUALS
    "ast": "*",  # ASTERISK
    "asymp": "\u2248",  # ALMOST EQUAL TO
    "asympeq": "\u224d",  # EQUIVALENT TO
    "Atilde": "\xc3",  # LATIN CAPITAL LETTER A WITH TILDE
    "atilde": "\xe3",  # LATIN SMALL LETTER A WITH TILDE
    "Auml": "\xc4",  # LATIN CAPITAL LETTER A WITH DIAERESIS
    "auml": "\xe4",  # LATIN SMALL LETTER A WITH DIAERESIS
    "awconint": "\u2233",  # ANTICLOCKWISE CONTOUR INTEGRAL
    "awint": "\u2a11",  # ANTICLOCKWISE INTEGRATION
    "backcong": "\u224c",  # ALL EQUAL TO
    "backepsilon": "\u03f6",  # GREEK REVERSED LUNATE EPSILON SYMBOL
    "backprime": "\u2035",  # REVERSED PRIME
    "backsim": "\u223d",  # REVERSED TILDE
    "backsimeq": "\u22cd",  # REVERSED TILDE EQUALS
    "Backslash": "\u2216",  # SET MINUS
    "Barv": "\u2ae7",  # SHORT DOWN TACK WITH OVERBAR
    "barvee": "\u22bd",  # NOR
    "Barwed": "\u2306",  # PERSPECTIVE
    "barwed": "\u2305",  # PROJECTIVE
    "barwedge": "\u2305",  # PROJECTIVE
    "bbrk": "\u23b5",  # BOTTOM SQUARE BRACKET
    "bbrktbrk": "\u23b6",  # BOTTOM SQUARE BRACKET OVER TOP SQUARE BRACKET
    "bcong": "\u224c",  # ALL EQUAL TO
    "Bcy": "\u0411",  # CYRILLIC CAPITAL LETTER BE
    "bcy": "\u0431",  # CYRILLIC SMALL LETTER BE
    "bdquo": "\u201e",  # DOUBLE LOW-9 QUOTATION MARK
    "becaus": "\u2235",  # BECAUSE
    "Because": "\u2235",  # BECAUSE
    "because": "\u2235",  # BECAUSE
    "bemptyv": "\u29b0",  # REVERSED EMPTY SET
    "bepsi": "\u03f6",  # GREEK REVERSED LUNATE EPSILON SYMBOL
    "bernou": "\u212c",  # SCRIPT CAPITAL B
    "Bernoullis": "\u212c",  # SCRIPT CAPITAL B
    "Beta": "\u0392",  # GREEK CAPITAL LETTER BETA
    "beta": "\u03b2",  # GREEK SMALL LETTER BETA
    "beth": "\u2136",  # BET SYMBOL
    "between": "\u226c",  # BETWEEN
    "Bfr": "\U0001d505",  # MATHEMATICAL FRAKTUR CAPITAL B
    "bfr": "\U0001d51f",  # MATHEMATICAL FRAKTUR SMALL B
    "bigcap": "\u22c2",  # N-ARY INTERSECTION
    "bigcirc": "\u25ef",  # LARGE CIRCLE
    "bigcup": "\u22c3",  # N-ARY UNION
    "bigodot": "\u2a00",  # N-ARY CIRCLED DOT OPERATOR
    "bigoplus": "\u2a01",  # N-ARY CIRCLED PLUS OPERATOR
    "bigotimes": "\u2a02",  # N-ARY CIRCLED TIMES OPERATOR
    "bigsqcup": "\u2a06",  # N-ARY SQUARE UNION OPERATOR
    "bigstar": "\u2605",  # BLACK STAR
    "bigtriangledown": "\u25bd",  # WHITE DOWN-POINTING TRIANGLE
    "bigtriangleup": "\u25b3",  # WHITE UP-POINTING TRIANGLE
    "biguplus": "\u2a04",  # N-ARY UNION OPERATOR WITH PLUS
    "bigvee": "\u22c1",  # N-ARY LOGICAL OR
    "bigwedge": "\u22c0",  # N-ARY LOGICAL AND
    "bkarow": "\u290d",  # RIGHTWARDS DOUBLE DASH ARROW
    "blacklozenge": "\u29eb",  # BLACK LOZENGE
    "blacksquare": "\u25aa",  # BLACK SMALL SQUARE
    "blacktriangle": "\u25b4",  # BLACK UP-POINTING SMALL TRIANGLE
    "blacktriangledown": "\u25be",  # BLACK DOWN-POINTING SMALL TRIANGLE
    "blacktriangleleft": "\u25c2",  # BLACK LEFT-POINTING SMALL TRIANGLE
    "blacktriangleright": "\u25b8",  # BLACK RIGHT-POINTING SMALL TRIANGLE
    "blank": "\u2423",  # OPEN BOX
    "blk12": "\u2592",  # MEDIUM SHADE
    "blk14": "\u2591",  # LIGHT SHADE
    "blk34": "\u2593",  # DARK SHADE
    "block": "\u2588",  # FULL BLOCK
    "bne": "=\u20e5",  # EQUALS SIGN with reverse slash
    "bnequiv": "\u2261\u20e5",  # IDENTICAL TO with reverse slash
    "bNot": "\u2aed",  # REVERSED DOUBLE STROKE NOT SIGN
    "bnot": "\u2310",  # REVERSED NOT SIGN
    "Bopf": "\U0001d539",  # MATHEMATICAL DOUBLE-STRUCK CAPITAL B
    "bopf": "\U0001d553",  # MATHEMATICAL DOUBLE-STRUCK SMALL B
    "bot": "\u22a5",  # UP TACK
    "bottom": "\u22a5",  # UP TACK
    "bowtie": "\u22c8",  # BOWTIE
    "boxbox": "\u29c9",  # TWO JOINED SQUARES
    "boxDL": "\u2557",  # BOX DRAWINGS DOUBLE DOWN AND LEFT
    "boxDl": "\u2556",  # BOX DRAWINGS DOWN DOUBLE AND LEFT SINGLE
    "boxdL": "\u2555",  # BOX DRAWINGS DOWN SINGLE AND LEFT DOUBLE
    "boxdl": "\u2510",  # BOX DRAWINGS LIGHT DOWN AND LEFT
    "boxDR": "\u2554",  # BOX DRAWINGS DOUBLE DOWN AND RIGHT
    "boxDr": "\u2553",  # BOX DRAWINGS DOWN DOUBLE AND RIGHT SINGLE
    "boxdR": "\u2552",  # BOX DRAWINGS DOWN SINGLE AND RIGHT DOUBLE
    "boxdr": "\u250c",  # BOX DRAWINGS LIGHT DOWN AND RIGHT
    "boxH": "\u2550",  # BOX DRAWINGS DOUBLE HORIZONTAL
    "boxh": "\u2500",  # BOX DRAWINGS LIGHT HORIZONTAL
    "boxHD": "\u2566",  # BOX DRAWINGS DOUBLE DOWN AND HORIZONTAL
    "boxHd": "\u2564",  # BOX DRAWINGS DOWN SINGLE AND HORIZONTAL DOUBLE
    "boxhD": "\u2565",  # BOX DRAWINGS DOWN DOUBLE AND HORIZONTAL SINGLE
    "boxhd": "\u252c",  # BOX DRAWINGS LIGHT DOWN AND HORIZONTAL
    "boxHU": "\u2569",  # BOX DRAWINGS DOUBLE UP AND HORIZONTAL
    "boxHu": "\u2567",  # BOX DRAWINGS UP SINGLE AND HORIZONTAL DOUBLE
    "boxhU": "\u2568",  # BOX DRAWINGS UP DOUBLE AND HORIZONTAL SINGLE
    "boxhu": "\u2534",  # BOX DRAWINGS LIGHT UP AND HORIZONTAL
    "boxminus": "\u229f",  # SQUARED MINUS
    "boxplus": "\u229e",  # SQUARED PLUS
    "boxtimes": "\u22a0",  # SQUARED TIMES
    "boxUL": "\u255d",  # BOX DRAWINGS DOUBLE UP AND LEFT
    "boxUl": "\u255c",  # BOX DRAWINGS UP DOUBLE AND LEFT SINGLE
    "boxuL": "\u255b",  # BOX DRAWINGS UP SINGLE AND LEFT DOUBLE
    "boxul": "\u2518",  # BOX DRAWINGS LIGHT UP AND LEFT
    "boxUR": "\u255a",  # BOX DRAWINGS DOUBLE UP AND RIGHT
    "boxUr": "\u2559",  # BOX DRAWINGS UP DOUBLE AND RIGHT SINGLE
    "boxuR": "\u2558",  # BOX DRAWINGS UP SINGLE AND RIGHT DOUBLE
    "boxur": "\u2514",  # BOX DRAWINGS LIGHT UP AND RIGHT
    "boxV": "\u2551",  # BOX DRAWINGS DOUBLE VERTICAL
    "boxv": "\u2502",  # BOX DRAWINGS LIGHT VERTICAL
    "boxVH": "\u256c",  # BOX DRAWINGS DOUBLE VERTICAL AND HORIZONTAL
    "boxVh": "\u256b",  # BOX DRAWINGS VERTICAL DOUBLE AND HORIZONTAL SINGLE
    "boxvH": "\u256a",  # BOX DRAWINGS VERTICAL SINGLE AND HORIZONTAL DOUBLE
    "boxvh": "\u253c",  # BOX DRAWINGS LIGHT VERTICAL AND HORIZONTAL
    "boxVL": "\u2563",  # BOX DRAWINGS DOUBLE VERTICAL AND LEFT
    "boxVl": "\u2562",  # BOX DRAWINGS VERTICAL DOUBLE AND LEFT SINGLE
    "boxvL": "\u2561",  # BOX DRAWINGS VERTICAL SINGLE AND LEFT DOUBLE
    "boxvl": "\u2524",  # BOX DRAWINGS LIGHT VERTICAL AND LEFT
    "boxVR": "\u2560",  # BOX DRAWINGS DOUBLE VERTICAL AND RIGHT
    "boxVr": "\u255f",  # BOX DRAWINGS VERTICAL DOUBLE AND RIGHT SINGLE
    "boxvR": "\u255e",  # BOX DRAWINGS VERTICAL SINGLE AND RIGHT DOUBLE
    "boxvr": "\u251c",  # BOX DRAWINGS LIGHT VERTICAL AND RIGHT
    "bprime": "\u2035",  # REVERSED PRIME
    "Breve": "\u02d8",  # BREVE
    "breve": "\u02d8",  # BREVE
    "brvbar": "\xa6",  # BROKEN BAR
    "Bscr": "\u212c",  # SCRIPT CAPITAL B
    "bscr": "\U0001d4b7",  # MATHEMATICAL SCRIPT SMALL B
    "bsemi": "\u204f",  # REVERSED SEMICOLON
    "bsim": "\u223d",  # REVERSED TILDE
    "bsime": "\u22cd",  # REVERSED TILDE EQUALS
    "bsol": "\\",  # REVERSE SOLIDUS
    "bsolb": "\u29c5",  # SQUARED FALLING DIAGONAL SLASH
    "bsolhsub": "\u27c8",  # REVERSE SOLIDUS PRECEDING SUBSET
    "bull": "\u2022",  # BULLET
    "bullet": "\u2022",  # BULLET
    "bump": "\u224e",  # GEOMETRICALLY EQUIVALENT TO
    "bumpE": "\u2aae",  # EQUALS SIGN WITH BUMPY ABOVE
    "bumpe": "\u224f",  # DIFFERENCE BETWEEN
    "Bumpeq": "\u224e",  # GEOMETRICALLY EQUIVALENT TO
    "bumpeq": "\u224f",  # DIFFERENCE BETWEEN
    "Cacute": "\u0106",  # LATIN CAPITAL LETTER C WITH ACUTE
    "cacute": "\u0107",  # LATIN SMALL LETTER C WITH ACUTE
    "Cap": "\u22d2",  # DOUBLE INTERSECTION
    "cap": "\u2229",  # INTERSECTION
    "capand": "\u2a44",  # INTERSECTION WITH LOGICAL AND
    "capbrcup": "\u2a49",  # INTERSECTION ABOVE BAR ABOVE UNION
    "capcap": "\u2a4b",  # INTERSECTION BESIDE AND JOINED WITH INTERSECTION
    "capcup": "\u2a47",  # INTERSECTION ABOVE UNION
    "capdot": "\u2a40",  # INTERSECTION WITH DOT
    "CapitalDifferentialD": "\u2145",  # DOUBLE-STRUCK ITALIC CAPITAL D
    "caps": "\u2229\ufe00",  # INTERSECTION with serifs
    "caret": "\u2041",  # CARET INSERTION POINT
    "caron": "\u02c7",  # CARON
    "Cayleys": "\u212d",  # BLACK-LETTER CAPITAL C
    "ccaps": "\u2a4d",  # CLOSED INTERSECTION WITH SERIFS
    "Ccaron": "\u010c",  # LATIN CAPITAL LETTER C WITH CARON
    "ccaron": "\u010d",  # LATIN SMALL LETTER C WITH CARON
    "Ccedil": "\xc7",  # LATIN CAPITAL LETTER C WITH CEDILLA
    "ccedil": "\xe7",  # LATIN SMALL LETTER C WITH CEDILLA
    "Ccirc": "\u0108",  # LATIN CAPITAL LETTER C WITH CIRCUMFLEX
    "ccirc": "\u0109",  # LATIN SMALL LETTER C WITH CIRCUMFLEX
    "Cconint": "\u2230",  # VOLUME INTEGRAL
    "ccups": "\u2a4c",  # CLOSED UNION WITH SERIFS
    "ccupssm": "\u2a50",  # CLOSED UNION WITH SERIFS AND SMASH PRODUCT
    "Cdot": "\u010a",  # LATIN CAPITAL LETTER C WITH DOT ABOVE
    "cdot": "\u010b",  # LATIN SMALL LETTER C WITH DOT ABOVE
    "cedil": "\xb8",  # CEDILLA
    "Cedilla": "\xb8",  # CEDILLA
    "cemptyv": "\u29b2",  # EMPTY SET WITH SMALL CIRCLE ABOVE
    "cent": "\xa2",  # CENT SIGN
    "CenterDot": "\xb7",  # MIDDLE DOT
    "centerdot": "\xb7",  # MIDDLE DOT
    "Cfr": "\u212d",  # BLACK-LETTER CAPITAL C
    "cfr": "\U0001d520",  # MATHEMATICAL FRAKTUR SMALL C
    "CHcy": "\u0427",  # CYRILLIC CAPITAL LETTER CHE
    "chcy": "\u0447",  # CYRILLIC SMALL LETTER CHE
    "check": "\u2713",  # CHECK MARK
    "checkmark": "\u2713",  # CHECK MARK
    "Chi": "\u03a7",  # GREEK CAPITAL LETTER CHI
    "chi": "\u03c7",  # GREEK SMALL LETTER CHI
    "cir": "\u25cb",  # WHITE CIRCLE
    "circ": "\u02c6",  # MODIFIER LETTER CIRCUMFLEX ACCENT
    "circeq": "\u2257",  # RING EQUAL TO
    "circlearrowleft": "\u21ba",  # ANTICLOCKWISE OPEN CIRCLE ARROW
    "circlearrowright": "\u21bb",  # CLOCKWISE OPEN CIRCLE ARROW
    "circledast": "\u229b",  # CIRCLED ASTERISK OPERATOR
    "circledcirc": "\u229a",  # CIRCLED RING OPERATOR
    "circleddash": "\u229d",  # CIRCLED DASH
    "CircleDot": "\u2299",  # CIRCLED DOT OPERATOR
    "circledR": "\xae",  # REGISTERED SIGN
    "circledS": "\u24c8",  # CIRCLED LATIN CAPITAL LETTER S
    "CircleMinus": "\u2296",  # CIRCLED MINUS
    "CirclePlus": "\u2295",  # CIRCLED PLUS
    "CircleTimes": "\u2297",  # CIRCLED TIMES
    "cirE": "\u29c3",  # CIRCLE WITH TWO HORIZONTAL STROKES TO THE RIGHT
    "cire": "\u2257",  # RING EQUAL TO
    "cirfnint": "\u2a10",  # CIRCULATION FUNCTION
    "cirmid": "\u2aef",  # VERTICAL LINE WITH CIRCLE ABOVE
    "cirscir": "\u29c2",  # CIRCLE WITH SMALL CIRCLE TO THE RIGHT
    "ClockwiseContourIntegral": "\u2232",  # CLOCKWISE CONTOUR INTEGRAL
    "CloseCurlyDoubleQuote": "\u201d",  # RIGHT DOUBLE QUOTATION MARK
    "CloseCurlyQuote": "\u2019",  # RIGHT SINGLE QUOTATION MARK
    "clubs": "\u2663",  # BLACK CLUB SUIT
    "clubsuit": "\u2663",  # BLACK CLUB SUIT
    "Colon": "\u2237",  # PROPORTION
    "colon": ":",  # COLON
    "Colone": "\u2a74",  # DOUBLE COLON EQUAL
    "colone": "\u2254",  # COLON EQUALS
    "coloneq": "\u2254",  # COLON EQUALS
    "comma": ",",  # COMMA
    "commat": "@",  # COMMERCIAL AT
    "comp": "\u2201",  # COMPLEMENT
    "compfn": "\u2218",  # RING OPERATOR
    "complement": "\u2201",  # COMPLEMENT
    "complexes": "\u2102",  # DOUBLE-STRUCK CAPITAL C
    "cong": "\u2245",  # APPROXIMATELY EQUAL TO
    "congdot": "\u2a6d",  # CONGRUENT WITH DOT ABOVE
    "Congruent": "\u2261",  # IDENTICAL TO
    "Conint": "\u222f",  # SURFACE INTEGRAL
    "conint": "\u222e",  # CONTOUR INTEGRAL
    "ContourIntegral": "\u222e",  # CONTOUR INTEGRAL
    "Copf": "\u2102",  # DOUBLE-STRUCK CAPITAL C
    "copf": "\U0001d554",  # MATHEMATICAL DOUBLE-STRUCK SMALL C
    "coprod": "\u2210",  # N-ARY COPRODUCT
    "Coproduct": "\u2210",  # N-ARY COPRODUCT
    "COPY": "\xa9",  # COPYRIGHT SIGN
    "copy": "\xa9",  # COPYRIGHT SIGN
    "copysr": "\u2117",  # SOUND RECORDING COPYRIGHT
    "CounterClockwiseContourIntegral": "\u2233",  # ANTICLOCKWISE CONTOUR INTEGRAL
    "crarr": "\u21b5",  # DOWNWARDS ARROW WITH CORNER LEFTWARDS
    "Cross": "\u2a2f",  # VECTOR OR CROSS PRODUCT
    "cross": "\u2717",  # BALLOT X
    "Cscr": "\U0001d49e",  # MATHEMATICAL SCRIPT CAPITAL C
    "cscr": "\U0001d4b8",  # MATHEMATICAL SCRIPT SMALL C
    "csub": "\u2acf",  # CLOSED SUBSET
    "csube": "\u2ad1",  # CLOSED SUBSET OR EQUAL TO
    "csup": "\u2ad0",  # CLOSED SUPERSET
    "csupe": "\u2ad2",  # CLOSED SUPERSET OR EQUAL TO
    "ctdot": "\u22ef",  # MIDLINE HORIZONTAL ELLIPSIS
    "cudarrl": "\u2938",  # RIGHT-SIDE ARC CLOCKWISE ARROW
    "cudarrr": "\u2935",  # ARROW POINTING RIGHTWARDS THEN CURVING DOWNWARDS
    "cuepr": "\u22de",  # EQUAL TO OR PRECEDES
    "cuesc": "\u22df",  # EQUAL TO OR SUCCEEDS
    "cularr": "\u21b6",  # ANTICLOCKWISE TOP SEMICIRCLE ARROW
    "cularrp": "\u293d",  # TOP ARC ANTICLOCKWISE ARROW WITH PLUS
    "Cup": "\u22d3",  # DOUBLE UNION
    "cup": "\u222a",  # UNION
    "cupbrcap": "\u2a48",  # UNION ABOVE BAR ABOVE INTERSECTION
    "CupCap": "\u224d",  # EQUIVALENT TO
    "cupcap": "\u2a46",  # UNION ABOVE INTERSECTION
    "cupcup": "\u2a4a",  # UNION BESIDE AND JOINED WITH UNION
    "cupdot": "\u228d",  # MULTISET MULTIPLICATION
    "cupor": "\u2a45",  # UNION WITH LOGICAL OR
    "cups": "\u222a\ufe00",  # UNION with serifs
    "curarr": "\u21b7",  # CLOCKWISE TOP SEMICIRCLE ARROW
    "curarrm": "\u293c",  # TOP ARC CLOCKWISE ARROW WITH MINUS
    "curlyeqprec": "\u22de",  # EQUAL TO OR PRECEDES
    "curlyeqsucc": "\u22df",  # EQUAL TO OR SUCCEEDS
    "curlyvee": "\u22ce",  # CURLY LOGICAL OR
    "curlywedge": "\u22cf",  # CURLY LOGICAL AND
    "curren": "\xa4",  # CURRENCY SIGN
    "curvearrowleft": "\u21b6",  # ANTICLOCKWISE TOP SEMICIRCLE ARROW
    "curvearrowright": "\u21b7",  # CLOCKWISE TOP SEMICIRCLE ARROW
    "cuvee": "\u22ce",  # CURLY LOGICAL OR
    "cuwed": "\u22cf",  # CURLY LOGICAL AND
    "cwconint": "\u2232",  # CLOCKWISE CONTOUR INTEGRAL
    "cwint": "\u2231",  # CLOCKWISE INTEGRAL
    "cylcty": "\u232d",  # CYLINDRICITY
    "Dagger": "\u2021",  # DOUBLE DAGGER
    "dagger": "\u2020",  # DAGGER
    "daleth": "\u2138",  # DALET SYMBOL
    "Darr": "\u21a1",  # DOWNWARDS TWO HEADED ARROW
    "dArr": "\u21d3",  # DOWNWARDS DOUBLE ARROW
    "darr": "\u2193",  # DOWNWARDS ARROW
    "dash": "\u2010",  # HYPHEN
    "Dashv": "\u2ae4",  # VERTICAL BAR DOUBLE LEFT TURNSTILE
    "dashv": "\u22a3",  # LEFT TACK
    "dbkarow": "\u290f",  # RIGHTWARDS TRIPLE DASH ARROW
    "dblac": "\u02dd",  # DOUBLE ACUTE ACCENT
    "Dcaron": "\u010e",  # LATIN CAPITAL LETTER D WITH CARON
    "dcaron": "\u010f",  # LATIN SMALL LETTER D WITH CARON
    "Dcy": "\u0414",  # CYRILLIC CAPITAL LETTER DE
    "dcy": "\u0434",  # CYRILLIC SMALL LETTER DE
    "DD": "\u2145",  # DOUBLE-STRUCK ITALIC CAPITAL D
    "dd": "\u2146",  # DOUBLE-STRUCK ITALIC SMALL D
    "ddagger": "\u2021",  # DOUBLE DAGGER
    "ddarr": "\u21ca",  # DOWNWARDS PAIRED ARROWS
    "DDotrahd": "\u2911",  # RIGHTWARDS ARROW WITH DOTTED STEM
    "ddotseq": "\u2a77",  # EQUALS SIGN WITH TWO DOTS ABOVE AND TWO DOTS BELOW
    "deg": "\xb0",  # DEGREE SIGN
    "Del": "\u2207",  # NABLA
    "Delta": "\u0394",  # GREEK CAPITAL LETTER DELTA
    "delta": "\u03b4",  # GREEK SMALL LETTER DELTA
    "demptyv": "\u29b1",  # EMPTY SET WITH OVERBAR
    "dfisht": "\u297f",  # DOWN FISH TAIL
    "Dfr": "\U0001d507",  # MATHEMATICAL FRAKTUR CAPITAL D
    "dfr": "\U0001d521",  # MATHEMATICAL FRAKTUR SMALL D
    "dHar": "\u2965",  # DOWNWARDS HARPOON WITH BARB LEFT BESIDE DOWNWARDS HARPOON WITH BARB RIGHT
    "dharl": "\u21c3",  # DOWNWARDS HARPOON WITH BARB LEFTWARDS
    "dharr": "\u21c2",  # DOWNWARDS HARPOON WITH BARB RIGHTWARDS
    "DiacriticalAcute": "\xb4",  # ACUTE ACCENT
    "DiacriticalDot": "\u02d9",  # DOT ABOVE
    "DiacriticalDoubleAcute": "\u02dd",  # DOUBLE ACUTE ACCENT
    "DiacriticalGrave": "`",  # GRAVE ACCENT
    "DiacriticalTilde": "\u02dc",  # SMALL TILDE
    "diam": "\u22c4",  # DIAMOND OPERATOR
    "Diamond": "\u22c4",  # DIAMOND OPERATOR
    "diamond": "\u22c4",  # DIAMOND OPERATOR
    "diamondsuit": "\u2666",  # BLACK DIAMOND SUIT
    "diams": "\u2666",  # BLACK DIAMOND SUIT
    "die": "\xa8",  # DIAERESIS
    "DifferentialD": "\u2146",  # DOUBLE-STRUCK ITALIC SMALL D
    "digamma": "\u03dd",  # GREEK SMALL LETTER DIGAMMA
    "disin": "\u22f2",  # ELEMENT OF WITH LONG HORIZONTAL STROKE
    "div": "\xf7",  # DIVISION SIGN
    "divide": "\xf7",  # DIVISION SIGN
    "divideontimes": "\u22c7",  # DIVISION TIMES
    "divonx": "\u22c7",  # DIVISION TIMES
    "DJcy": "\u0402",  # CYRILLIC CAPITAL LETTER DJE
    "djcy": "\u0452",  # CYRILLIC SMALL LETTER DJE
    "dlcorn": "\u231e",  # BOTTOM LEFT CORNER
    "dlcrop": "\u230d",  # BOTTOM LEFT CROP
    "dollar": "$",  # DOLLAR SIGN
    "Dopf": "\U0001d53b",  # MATHEMATICAL DOUBLE-STRUCK CAPITAL D
    "dopf": "\U0001d555",  # MATHEMATICAL DOUBLE-STRUCK SMALL D
    "Dot": "\xa8",  # DIAERESIS
    "dot": "\u02d9",  # DOT ABOVE
    "doteq": "\u2250",  # APPROACHES THE LIMIT
    "doteqdot": "\u2251",  # GEOMETRICALLY EQUAL TO
    "DotEqual": "\u2250",  # APPROACHES THE LIMIT
    "dotminus": "\u2238",  # DOT MINUS
    "dotplus": "\u2214",  # DOT PLUS
    "dotsquare": "\u22a1",  # SQUARED DOT OPERATOR
    "doublebarwedge": "\u2306",  # PERSPECTIVE
    "DoubleContourIntegral": "\u222f",  # SURFACE INTEGRAL
    "DoubleDot": "\xa8",  # DIAERESIS
    "DoubleDownArrow": "\u21d3",  # DOWNWARDS DOUBLE ARROW
    "DoubleLeftArrow": "\u21d0",  # LEFTWARDS DOUBLE ARROW
    "DoubleLeftRightArrow": "\u21d4",  # LEFT RIGHT DOUBLE ARROW
    "DoubleLeftTee": "\u2ae4",  # VERTICAL BAR DOUBLE LEFT TURNSTILE
    "DoubleLongLeftArrow": "\u27f8",  # LONG LEFTWARDS DOUBLE ARROW
    "DoubleLongLeftRightArrow": "\u27fa",  # LONG LEFT RIGHT DOUBLE ARROW
    "DoubleLongRightArrow": "\u27f9",  # LONG RIGHTWARDS DOUBLE ARROW
    "DoubleRightArrow": "\u21d2",  # RIGHTWARDS DOUBLE ARROW
    "DoubleRightTee": "\u22a8",  # TRUE
    "DoubleUpArrow": "\u21d1",  # UPWARDS DOUBLE ARROW
    "DoubleUpDownArrow": "\u21d5",  # UP DOWN DOUBLE ARROW
    "DoubleVerticalBar": "\u2225",  # PARALLEL TO
    "DownArrow": "\u2193",  # DOWNWARDS ARROW
    "Downarrow": "\u21d3",  # DOWNWARDS DOUBLE ARROW
    "downarrow": "\u2193",  # DOWNWARDS ARROW
    "DownArrowBar": "\u2913",  # DOWNWARDS ARROW TO BAR
    "DownArrowUpArrow": "\u21f5",  # DOWNWARDS ARROW LEFTWARDS OF UPWARDS ARROW
    "downdownarrows": "\u21ca",  # DOWNWARDS PAIRED ARROWS
    "downharpoonleft": "\u21c3",  # DOWNWARDS HARPOON WITH BARB LEFTWARDS
    "downharpoonright": "\u21c2",  # DOWNWARDS HARPOON WITH BARB RIGHTWARDS
    "DownLeftRightVector": "\u2950",  # LEFT BARB DOWN RIGHT BARB DOWN HARPOON
    "DownLeftTeeVector": "\u295e",  # LEFTWARDS HARPOON WITH BARB DOWN FROM BAR
    "DownLeftVector": "\u21bd",  # LEFTWARDS HARPOON WITH BARB DOWNWARDS
    "DownLeftVectorBar": "\u2956",  # LEFTWARDS HARPOON WITH BARB DOWN TO BAR
    "DownRightTeeVector": "\u295f",  # RIGHTWARDS HARPOON WITH BARB DOWN FROM BAR
    "DownRightVector": "\u21c1",  # RIGHTWARDS HARPOON WITH BARB DOWNWARDS
    "DownRightVectorBar": "\u2957",  # RIGHTWARDS HARPOON WITH BARB DOWN TO BAR
    "DownTee": "\u22a4",  # DOWN TACK
    "DownTeeArrow": "\u21a7",  # DOWNWARDS ARROW FROM BAR
    "drbkarow": "\u2910",  # RIGHTWARDS TWO-HEADED TRIPLE DASH ARROW
    "drcorn": "\u231f",  # BOTTOM RIGHT CORNER
    "drcrop": "\u230c",  # BOTTOM RIGHT CROP
    "Dscr": "\U0001d49f",  # MATHEMATICAL SCRIPT CAPITAL D
    "dscr": "\U0001d4b9",  # MATHEMATICAL SCRIPT SMALL D
    "DScy": "\u0405",  # CYRILLIC CAPITAL LETTER DZE
    "dscy": "\u0455",  # CYRILLIC SMALL LETTER DZE
    "dsol": "\u29f6",  # SOLIDUS WITH OVERBAR
    "Dstrok": "\u0110",  # LATIN CAPITAL LETTER D WITH STROKE
    "dstrok": "\u0111",  # LATIN SMALL LETTER D WITH STROKE
    "dtdot": "\u22f1",  # DOWN RIGHT DIAGONAL ELLIPSIS
    "dtri": "\u25bf",  # WHITE DOWN-POINTING SMALL TRIANGLE
    "dtrif": "\u25be",  # BLACK DOWN-POINTING SMALL TRIANGLE
    "duarr": "\u21f5",  # DOWNWARDS ARROW LEFTWARDS OF UPWARDS ARROW
    "duhar": "\u296f",  # DOWNWARDS HARPOON WITH BARB LEFT BESIDE UPWARDS HARPOON WITH BARB RIGHT
    "dwangle": "\u29a6",  # OBLIQUE ANGLE OPENING UP
    "DZcy": "\u040f",  # CYRILLIC CAPITAL LETTER DZHE
    "dzcy": "\u045f",  # CYRILLIC SMALL LETTER DZHE
    "dzigrarr": "\u27ff",  # LONG RIGHTWARDS SQUIGGLE ARROW
    "Eacute": "\xc9",  # LATIN CAPITAL LETTER E WITH ACUTE
    "eacute": "\xe9",  # LATIN SMALL LETTER E WITH ACUTE
    "easter": "\u2a6e",  # EQUALS WITH ASTERISK
    "Ecaron": "\u011a",  # LATIN CAPITAL LETTER E WITH CARON
    "ecaron": "\u011b",  # LATIN SMALL LETTER E WITH CARON
    "ecir": "\u2256",  # RING IN EQUAL TO
    "Ecirc": "\xca",  # LATIN CAPITAL LETTER E WITH CIRCUMFLEX
    "ecirc": "\xea",  # LATIN SMALL LETTER E WITH CIRCUMFLEX
    "ecolon": "\u2255",  # EQUALS COLON
    "Ecy": "\u042d",  # CYRILLIC CAPITAL LETTER E
    "ecy": "\u044d",  # CYRILLIC SMALL LETTER E
    "eDDot": "\u2a77",  # EQUALS SIGN WITH TWO DOTS ABOVE AND TWO DOTS BELOW
    "Edot": "\u0116",  # LATIN CAPITAL LETTER E WITH DOT ABOVE
    "eDot": "\u2251",  # GEOMETRICALLY EQUAL TO
    "edot": "\u0117",  # LATIN SMALL LETTER E WITH DOT ABOVE
    "ee": "\u2147",  # DOUBLE-STRUCK ITALIC SMALL E
    "efDot": "\u2252",  # APPROXIMATELY EQUAL TO OR THE IMAGE OF
    "Efr": "\U0001d508",  # MATHEMATICAL FRAKTUR CAPITAL E
    "efr": "\U0001d522",  # MATHEMATICAL FRAKTUR SMALL E
    "eg": "\u2a9a",  # DOUBLE-LINE EQUAL TO OR GREATER-THAN
    "Egrave": "\xc8",  # LATIN CAPITAL LETTER E WITH GRAVE
    "egrave": "\xe8",  # LATIN SMALL LETTER E WITH GRAVE
    "egs": "\u2a96",  # SLANTED EQUAL TO OR GREATER-THAN
    "egsdot": "\u2a98",  # SLANTED EQUAL TO OR GREATER-THAN WITH DOT INSIDE
    "el": "\u2a99",  # DOUBLE-LINE EQUAL TO OR LESS-THAN
    "Element": "\u2208",  # ELEMENT OF
    "elinters": "\u23e7",  # ELECTRICAL INTERSECTION
    "ell": "\u2113",  # SCRIPT SMALL L
    "els": "\u2a95",  # SLANTED EQUAL TO OR LESS-THAN
    "elsdot": "\u2a97",  # SLANTED EQUAL TO OR LESS-THAN WITH DOT INSIDE
    "Emacr": "\u0112",  # LATIN CAPITAL LETTER E WITH MACRON
    "emacr": "\u0113",  # LATIN SMALL LETTER E WITH MACRON
    "empty": "\u2205",  # EMPTY SET
    "emptyset": "\u2205",  # EMPTY SET
    "EmptySmallSquare": "\u25fb",  # WHITE MEDIUM SQUARE
    "emptyv": "\u2205",  # EMPTY SET
    "EmptyVerySmallSquare": "\u25ab",  # WHITE SMALL SQUARE
    "emsp": "\u2003",  # EM SPACE
    "emsp13": "\u2004",  # THREE-PER-EM SPACE
    "emsp14": "\u2005",  # FOUR-PER-EM SPACE
    "ENG": "\u014a",  # LATIN CAPITAL LETTER ENG
    "eng": "\u014b",  # LATIN SMALL LETTER ENG
    "ensp": "\u2002",  # EN SPACE
    "Eogon": "\u0118",  # LATIN CAPITAL LETTER E WITH OGONEK
    "eogon": "\u0119",  # LATIN SMALL LETTER E WITH OGONEK
    "Eopf": "\U0001d53c",  # MATHEMATICAL DOUBLE-STRUCK CAPITAL E
    "eopf": "\U0001d556",  # MATHEMATICAL DOUBLE-STRUCK SMALL E
    "epar": "\u22d5",  # EQUAL AND PARALLEL TO
    "eparsl": "\u29e3",  # EQUALS SIGN AND SLANTED PARALLEL
    "eplus": "\u2a71",  # EQUALS SIGN ABOVE PLUS SIGN
    "epsi": "\u03b5",  # GREEK SMALL LETTER EPSILON
    "Epsilon": "\u0395",  # GREEK CAPITAL LETTER EPSILON
    "epsilon": "\u03b5",  # GREEK SMALL LETTER EPSILON
    "epsiv": "\u03f5",  # GREEK LUNATE EPSILON SYMBOL
    "eqcirc": "\u2256",  # RING IN EQUAL TO
    "eqcolon": "\u2255",  # EQUALS COLON
    "eqsim": "\u2242",  # MINUS TILDE
    "eqslantgtr": "\u2a96",  # SLANTED EQUAL TO OR GREATER-THAN
    "eqslantless": "\u2a95",  # SLANTED EQUAL TO OR LESS-THAN
    "Equal": "\u2a75",  # TWO CONSECUTIVE EQUALS SIGNS
    "equals": "=",  # EQUALS SIGN
    "EqualTilde": "\u2242",  # MINUS TILDE
    "equest": "\u225f",  # QUESTIONED EQUAL TO
    "Equilibrium": "\u21cc",  # RIGHTWARDS HARPOON OVER LEFTWARDS HARPOON
    "equiv": "\u2261",  # IDENTICAL TO
    "equivDD": "\u2a78",  # EQUIVALENT WITH FOUR DOTS ABOVE
    "eqvparsl": "\u29e5",  # IDENTICAL TO AND SLANTED PARALLEL
    "erarr": "\u2971",  # EQUALS SIGN ABOVE RIGHTWARDS ARROW
    "erDot": "\u2253",  # IMAGE OF OR APPROXIMATELY EQUAL TO
    "Escr": "\u2130",  # SCRIPT CAPITAL E
    "escr": "\u212f",  # SCRIPT SMALL E
    "esdot": "\u2250",  # APPROACHES THE LIMIT
    "Esim": "\u2a73",  # EQUALS SIGN ABOVE TILDE OPERATOR
    "esim": "\u2242",  # MINUS TILDE
    "Eta": "\u0397",  # GREEK CAPITAL LETTER ETA
    "eta": "\u03b7",  # GREEK SMALL LETTER ETA
    "ETH": "\xd0",  # LATIN CAPITAL LETTER ETH
    "eth": "\xf0",  # LATIN SMALL LETTER ETH
    "Euml": "\xcb",  # LATIN CAPITAL LETTER E WITH DIAERESIS
    "euml": "\xeb",  # LATIN SMALL LETTER E WITH DIAERESIS
    "euro": "\u20ac",  # EURO SIGN
    "excl": "!",  # EXCLAMATION MARK
    "exist": "\u2203",  # THERE EXISTS
    "Exists": "\u2203",  # THERE EXISTS
    "expectation": "\u2130",  # SCRIPT CAPITAL E
    "ExponentialE": "\u2147",  # DOUBLE-STRUCK ITALIC SMALL E
    "exponentiale": "\u2147",  # DOUBLE-STRUCK ITALIC SMALL E
    "fallingdotseq": "\u2252",  # APPROXIMATELY EQUAL TO OR THE IMAGE OF
    "Fcy": "\u0424",  # CYRILLIC CAPITAL LETTER EF
    "fcy": "\u0444",  # CYRILLIC SMALL LETTER EF
    "female": "\u2640",  # FEMALE SIGN
    "ffilig": "\ufb03",  # LATIN SMALL LIGATURE FFI
    "fflig": "\ufb00",  # LATIN SMALL LIGATURE FF
    "ffllig": "\ufb04",  # LATIN SMALL LIGATURE FFL
    "Ffr": "\U0001d509",  # MATHEMATICAL FRAKTUR CAPITAL F
    "ffr": "\U0001d523",  # MATHEMATICAL FRAKTUR SMALL F
    "filig": "\ufb01",  # LATIN SMALL LIGATURE FI
    "FilledSmallSquare": "\u25fc",  # BLACK MEDIUM SQUARE
    "FilledVerySmallSquare": "\u25aa",  # BLACK SMALL SQUARE
    "fjlig": "fj",  # fj ligature
    "flat": "\u266d",  # MUSIC FLAT SIGN
    "fllig": "\ufb02",  # LATIN SMALL LIGATURE FL
    "fltns": "\u25b1",  # WHITE PARALLELOGRAM
    "fnof": "\u0192",  # LATIN SMALL LETTER F WITH HOOK
    "Fopf": "\U0001d53d",  # MATHEMATICAL DOUBLE-STRUCK CAPITAL F
    "fopf": "\U0001d557",  # MATHEMATICAL DOUBLE-STRUCK SMALL F
    "ForAll": "\u2200",  # FOR ALL
    "forall": "\u2200",  # FOR ALL
    "fork": "\u22d4",  # PITCHFORK
    "forkv": "\u2ad9",  # ELEMENT OF OPENING DOWNWARDS
    "Fouriertrf": "\u2131",  # SCRIPT CAPITAL F
    "fpartint": "\u2a0d",  # FINITE PART INTEGRAL
    "frac12": "\xbd",  # VULGAR FRACTION ONE HALF
    "frac13": "\u2153",  # VULGAR FRACTION ONE THIRD
    "frac14": "\xbc",  # VULGAR FRACTION ONE QUARTER
    "frac15": "\u2155",  # VULGAR FRACTION ONE FIFTH
    "frac16": "\u2159",  # VULGAR FRACTION ONE SIXTH
    "frac18": "\u215b",  # VULGAR FRACTION ONE EIGHTH
    "frac23": "\u2154",  # VULGAR FRACTION TWO THIRDS
    "frac25": "\u2156",  # VULGAR FRACTION TWO FIFTHS
    "frac34": "\xbe",  # VULGAR FRACTION THREE QUARTERS
    "frac35": "\u2157",  # VULGAR FRACTION THREE FIFTHS
    "frac38": "\u215c",  # VULGAR FRACTION THREE EIGHTHS
    "frac45": "\u2158",  # VULGAR FRACTION FOUR FIFTHS
    "frac56": "\u215a",  # VULGAR FRACTION FIVE SIXTHS
    "frac58": "\u215d",  # VULGAR FRACTION FIVE EIGHTHS
    "frac78": "\u215e",  # VULGAR FRACTION SEVEN EIGHTHS
    "frasl": "\u2044",  # FRACTION SLASH
    "frown": "\u2322",  # FROWN
    "Fscr": "\u2131",  # SCRIPT CAPITAL F
    "fscr": "\U0001d4bb",  # MATHEMATICAL SCRIPT SMALL F
    "gacute": "\u01f5",  # LATIN SMALL LETTER G WITH ACUTE
    "Gamma": "\u0393",  # GREEK CAPITAL LETTER GAMMA
    "gamma": "\u03b3",  # GREEK SMALL LETTER GAMMA
    "Gammad": "\u03dc",  # GREEK LETTER DIGAMMA
    "gammad": "\u03dd",  # GREEK SMALL LETTER DIGAMMA
    "gap": "\u2a86",  # GREATER-THAN OR APPROXIMATE
    "Gbreve": "\u011e",  # LATIN CAPITAL LETTER G WITH BREVE
    "gbreve": "\u011f",  # LATIN SMALL LETTER G WITH BREVE
    "Gcedil": "\u0122",  # LATIN CAPITAL LETTER G WITH CEDILLA
    "Gcirc": "\u011c",  # LATIN CAPITAL LETTER G WITH CIRCUMFLEX
    "gcirc": "\u011d",  # LATIN SMALL LETTER G WITH CIRCUMFLEX
    "Gcy": "\u0413",  # CYRILLIC CAPITAL LETTER GHE
    "gcy": "\u0433",  # CYRILLIC SMALL LETTER GHE
    "Gdot": "\u0120",  # LATIN CAPITAL LETTER G WITH DOT ABOVE
    "gdot": "\u0121",  # LATIN SMALL LETTER G WITH DOT ABOVE
    "gE": "\u2267",  # GREATER-THAN OVER EQUAL TO
    "ge": "\u2265",  # GREATER-THAN OR EQUAL TO
    "gEl": "\u2a8c",  # GREATER-THAN ABOVE DOUBLE-LINE EQUAL ABOVE LESS-THAN
    "gel": "\u22db",  # GREATER-THAN EQUAL TO OR LESS-THAN
    "geq": "\u2265",  # GREATER-THAN OR EQUAL TO
    "geqq": "\u2267",  # GREATER-THAN OVER EQUAL TO
    "geqslant": "\u2a7e",  # GREATER-THAN OR SLANTED EQUAL TO
    "ges": "\u2a7e",  # GREATER-THAN OR SLANTED EQUAL TO
    "gescc": "\u2aa9",  # GREATER-THAN CLOSED BY CURVE ABOVE SLANTED EQUAL
    "gesdot": "\u2a80",  # GREATER-THAN OR SLANTED EQUAL TO WITH DOT INSIDE
    "gesdoto": "\u2a82",  # GREATER-THAN OR SLANTED EQUAL TO WITH DOT ABOVE
    "gesdotol": "\u2a84",  # GREATER-THAN OR SLANTED EQUAL TO WITH DOT ABOVE LEFT
    "gesl": "\u22db\ufe00",  # GREATER-THAN slanted EQUAL TO OR LESS-THAN
    "gesles": "\u2a94",  # GREATER-THAN ABOVE SLANTED EQUAL ABOVE LESS-THAN ABOVE SLANTED EQUAL
    "Gfr": "\U0001d50a",  # MATHEMATICAL FRAKTUR CAPITAL G
    "gfr": "\U0001d524",  # MATHEMATICAL FRAKTUR SMALL G
    "Gg": "\u22d9",  # VERY MUCH GREATER-THAN
    "gg": "\u226b",  # MUCH GREATER-THAN
    "ggg": "\u22d9",  # VERY MUCH GREATER-THAN
    "gimel": "\u2137",  # GIMEL SYMBOL
    "GJcy": "\u0403",  # CYRILLIC CAPITAL LETTER GJE
    "gjcy": "\u0453",  # CYRILLIC SMALL LETTER GJE
    "gl": "\u2277",  # GREATER-THAN OR LESS-THAN
    "gla": "\u2aa5",  # GREATER-THAN BESIDE LESS-THAN
    "glE": "\u2a92",  # GREATER-THAN ABOVE LESS-THAN ABOVE DOUBLE-LINE EQUAL
    "glj": "\u2aa4",  # GREATER-THAN OVERLAPPING LESS-THAN
    "gnap": "\u2a8a",  # GREATER-THAN AND NOT APPROXIMATE
    "gnapprox": "\u2a8a",  # GREATER-THAN AND NOT APPROXIMATE
    "gnE": "\u2269",  # GREATER-THAN BUT NOT EQUAL TO
    "gne": "\u2a88",  # GREATER-THAN AND SINGLE-LINE NOT EQUAL TO
    "gneq": "\u2a88",  # GREATER-THAN AND SINGLE-LINE NOT EQUAL TO
    "gneqq": "\u2269",  # GREATER-THAN BUT NOT EQUAL TO
    "gnsim": "\u22e7",  # GREATER-THAN BUT NOT EQUIVALENT TO
    "Gopf": "\U0001d53e",  # MATHEMATICAL DOUBLE-STRUCK CAPITAL G
    "gopf": "\U0001d558",  # MATHEMATICAL DOUBLE-STRUCK SMALL G
    "grave": "`",  # GRAVE ACCENT
    "GreaterEqual": "\u2265",  # GREATER-THAN OR EQUAL TO
    "GreaterEqualLess": "\u22db",  # GREATER-THAN EQUAL TO OR LESS-THAN
    "GreaterFullEqual": "\u2267",  # GREATER-THAN OVER EQUAL TO
    "GreaterGreater": "\u2aa2",  # DOUBLE NESTED GREATER-THAN
    "GreaterLess": "\u2277",  # GREATER-THAN OR LESS-THAN
    "GreaterSlantEqual": "\u2a7e",  # GREATER-THAN OR SLANTED EQUAL TO
    "GreaterTilde": "\u2273",  # GREATER-THAN OR EQUIVALENT TO
    "Gscr": "\U0001d4a2",  # MATHEMATICAL SCRIPT CAPITAL G
    "gscr": "\u210a",  # SCRIPT SMALL G
    "gsim": "\u2273",  # GREATER-THAN OR EQUIVALENT TO
    "gsime": "\u2a8e",  # GREATER-THAN ABOVE SIMILAR OR EQUAL
    "gsiml": "\u2a90",  # GREATER-THAN ABOVE SIMILAR ABOVE LESS-THAN
    "GT": ">",  # GREATER-THAN SIGN
    "Gt": "\u226b",  # MUCH GREATER-THAN
    "gt": ">",  # GREATER-THAN SIGN
    "gtcc": "\u2aa7",  # GREATER-THAN CLOSED BY CURVE
    "gtcir": "\u2a7a",  # GREATER-THAN WITH CIRCLE INSIDE
    "gtdot": "\u22d7",  # GREATER-THAN WITH DOT
    "gtlPar": "\u2995",  # DOUBLE LEFT ARC GREATER-THAN BRACKET
    "gtquest": "\u2a7c",  # GREATER-THAN WITH QUESTION MARK ABOVE
    "gtrapprox": "\u2a86",  # GREATER-THAN OR APPROXIMATE
    "gtrarr": "\u2978",  # GREATER-THAN ABOVE RIGHTWARDS ARROW
    "gtrdot": "\u22d7",  # GREATER-THAN WITH DOT
    "gtreqless": "\u22db",  # GREATER-THAN EQUAL TO OR LESS-THAN
    "gtreqqless": "\u2a8c",  # GREATER-THAN ABOVE DOUBLE-LINE EQUAL ABOVE LESS-THAN
    "gtrless": "\u2277",  # GREATER-THAN OR LESS-THAN
    "gtrsim": "\u2273",  # GREATER-THAN OR EQUIVALENT TO
    "gvertneqq": "\u2269\ufe00",  # GREATER-THAN BUT NOT EQUAL TO - with vertical stroke
    "gvnE": "\u2269\ufe00",  # GREATER-THAN BUT NOT EQUAL TO - with vertical stroke
    "Hacek": "\u02c7",  # CARON
    "hairsp": "\u200a",  # HAIR SPACE
    "half": "\xbd",  # VULGAR FRACTION ONE HALF
    "hamilt": "\u210b",  # SCRIPT CAPITAL H
    "HARDcy": "\u042a",  # CYRILLIC CAPITAL LETTER HARD SIGN
    "hardcy": "\u044a",  # CYRILLIC SMALL LETTER HARD SIGN
    "hArr": "\u21d4",  # LEFT RIGHT DOUBLE ARROW
    "harr": "\u2194",  # LEFT RIGHT ARROW
    "harrcir": "\u2948",  # LEFT RIGHT ARROW THROUGH SMALL CIRCLE
    "harrw": "\u21ad",  # LEFT RIGHT WAVE ARROW
    "Hat": "^",  # CIRCUMFLEX ACCENT
    "hbar": "\u210f",  # PLANCK CONSTANT OVER TWO PI
    "Hcirc": "\u0124",  # LATIN CAPITAL LETTER H WITH CIRCUMFLEX
    "hcirc": "\u0125",  # LATIN SMALL LETTER H WITH CIRCUMFLEX
    "hearts": "\u2665",  # BLACK HEART SUIT
    "heartsuit": "\u2665",  # BLACK HEART SUIT
    "hellip": "\u2026",  # HORIZONTAL ELLIPSIS
    "hercon": "\u22b9",  # HERMITIAN CONJUGATE MATRIX
    "Hfr": "\u210c",  # BLACK-LETTER CAPITAL H
    "hfr": "\U0001d525",  # MATHEMATICAL FRAKTUR SMALL H
    "HilbertSpace": "\u210b",  # SCRIPT CAPITAL H
    "hksearow": "\u2925",  # SOUTH EAST ARROW WITH HOOK
    "hkswarow": "\u2926",  # SOUTH WEST ARROW WITH HOOK
    "hoarr": "\u21ff",  # LEFT RIGHT OPEN-HEADED ARROW
    "homtht": "\u223b",  # HOMOTHETIC
    "hookleftarrow": "\u21a9",  # LEFTWARDS ARROW WITH HOOK
    "hookrightarrow": "\u21aa",  # RIGHTWARDS ARROW WITH HOOK
    "Hopf": "\u210d",  # DOUBLE-STRUCK CAPITAL H
    "hopf": "\U0001d559",  # MATHEMATICAL DOUBLE-STRUCK SMALL H
    "horbar": "\u2015",  # HORIZONTAL BAR
    "HorizontalLine": "\u2500",  # BOX DRAWINGS LIGHT HORIZONTAL
    "Hscr": "\u210b",  # SCRIPT CAPITAL H
    "hscr": "\U0001d4bd",  # MATHEMATICAL SCRIPT SMALL H
    "hslash": "\u210f",  # PLANCK CONSTANT OVER TWO PI
    "Hstrok": "\u0126",  # LATIN CAPITAL LETTER H WITH STROKE
    "hstrok": "\u0127",  # LATIN SMALL LETTER H WITH STROKE
    "HumpDownHump": "\u224e",  # GEOMETRICALLY EQUIVALENT TO
    "HumpEqual": "\u224f",  # DIFFERENCE BETWEEN
    "hybull": "\u2043",  # HYPHEN BULLET
    "hyphen": "\u2010",  # HYPHEN
    "Iacute": "\xcd",  # LATIN CAPITAL LETTER I WITH ACUTE
    "iacute": "\xed",  # LATIN SMALL LETTER I WITH ACUTE
    "ic": "\u2063",  # INVISIBLE SEPARATOR
    "Icirc": "\xce",  # LATIN CAPITAL LETTER I WITH CIRCUMFLEX
    "icirc": "\xee",  # LATIN SMALL LETTER I WITH CIRCUMFLEX
    "Icy": "\u0418",  # CYRILLIC CAPITAL LETTER I
    "icy": "\u0438",  # CYRILLIC SMALL LETTER I
    "Idot": "\u0130",  # LATIN CAPITAL LETTER I WITH DOT ABOVE
    "IEcy": "\u0415",  # CYRILLIC CAPITAL LETTER IE
    "iecy": "\u0435",  # CYRILLIC SMALL LETTER IE
    "iexcl": "\xa1",  # INVERTED EXCLAMATION MARK
    "iff": "\u21d4",  # LEFT RIGHT DOUBLE ARROW
    "Ifr": "\u2111",  # BLACK-LETTER CAPITAL I
    "ifr": "\U0001d526",  # MATHEMATICAL FRAKTUR SMALL I
    "Igrave": "\xcc",  # LATIN CAPITAL LETTER I WITH GRAVE
    "igrave": "\xec",  # LATIN SMALL LETTER I WITH GRAVE
    "ii": "\u2148",  # DOUBLE-STRUCK ITALIC SMALL I
    "iiiint": "\u2a0c",  # QUADRUPLE INTEGRAL OPERATOR
    "iiint": "\u222d",  # TRIPLE INTEGRAL
    "iinfin": "\u29dc",  # INCOMPLETE INFINITY
    "iiota": "\u2129",  # TURNED GREEK SMALL LETTER IOTA
    "IJlig": "\u0132",  # LATIN CAPITAL LIGATURE IJ
    "ijlig": "\u0133",  # LATIN SMALL LIGATURE IJ
    "Im": "\u2111",  # BLACK-LETTER CAPITAL I
    "Imacr": "\u012a",  # LATIN CAPITAL LETTER I WITH MACRON
    "imacr": "\u012b",  # LATIN SMALL LETTER I WITH MACRON
    "image": "\u2111",  # BLACK-LETTER CAPITAL I
    "ImaginaryI": "\u2148",  # DOUBLE-STRUCK ITALIC SMALL I
    "imagline": "\u2110",  # SCRIPT CAPITAL I
    "imagpart": "\u2111",  # BLACK-LETTER CAPITAL I
    "imath": "\u0131",  # LATIN SMALL LETTER DOTLESS I
    "imof": "\u22b7",  # IMAGE OF
    "imped": "\u01b5",  # LATIN CAPITAL LETTER Z WITH STROKE
    "Implies": "\u21d2",  # RIGHTWARDS DOUBLE ARROW
    "in": "\u2208",  # ELEMENT OF
    "incare": "\u2105",  # CARE OF
    "infin": "\u221e",  # INFINITY
    "infintie": "\u29dd",  # TIE OVER INFINITY
    "inodot": "\u0131",  # LATIN SMALL LETTER DOTLESS I
    "Int": "\u222c",  # DOUBLE INTEGRAL
    "int": "\u222b",  # INTEGRAL
    "intcal": "\u22ba",  # INTERCALATE
    "integers": "\u2124",  # DOUBLE-STRUCK CAPITAL Z
    "Integral": "\u222b",  # INTEGRAL
    "intercal": "\u22ba",  # INTERCALATE
    "Intersection": "\u22c2",  # N-ARY INTERSECTION
    "intlarhk": "\u2a17",  # INTEGRAL WITH LEFTWARDS ARROW WITH HOOK
    "intprod": "\u2a3c",  # INTERIOR PRODUCT
    "InvisibleComma": "\u2063",  # INVISIBLE SEPARATOR
    "InvisibleTimes": "\u2062",  # INVISIBLE TIMES
    "IOcy": "\u0401",  # CYRILLIC CAPITAL LETTER IO
    "iocy": "\u0451",  # CYRILLIC SMALL LETTER IO
    "Iogon": "\u012e",  # LATIN CAPITAL LETTER I WITH OGONEK
    "iogon": "\u012f",  # LATIN SMALL LETTER I WITH OGONEK
    "Iopf": "\U0001d540",  # MATHEMATICAL DOUBLE-STRUCK CAPITAL I
    "iopf": "\U0001d55a",  # MATHEMATICAL DOUBLE-STRUCK SMALL I
    "Iota": "\u0399",  # GREEK CAPITAL LETTER IOTA
    "iota": "\u03b9",  # GREEK SMALL LETTER IOTA
    "iprod": "\u2a3c",  # INTERIOR PRODUCT
    "iquest": "\xbf",  # INVERTED QUESTION MARK
    "Iscr": "\u2110",  # SCRIPT CAPITAL I
    "iscr": "\U0001d4be",  # MATHEMATICAL SCRIPT SMALL I
    "isin": "\u2208",  # ELEMENT OF
    "isindot": "\u22f5",  # ELEMENT OF WITH DOT ABOVE
    "isinE": "\u22f9",  # ELEMENT OF WITH TWO HORIZONTAL STROKES
    "isins": "\u22f4",  # SMALL ELEMENT OF WITH VERTICAL BAR AT END OF HORIZONTAL STROKE
    "isinsv": "\u22f3",  # ELEMENT OF WITH VERTICAL BAR AT END OF HORIZONTAL STROKE
    "isinv": "\u2208",  # ELEMENT OF
    "it": "\u2062",  # INVISIBLE TIMES
    "Itilde": "\u0128",  # LATIN CAPITAL LETTER I WITH TILDE
    "itilde": "\u0129",  # LATIN SMALL LETTER I WITH TILDE
    "Iukcy": "\u0406",  # CYRILLIC CAPITAL LETTER BYELORUSSIAN-UKRAINIAN I
    "iukcy": "\u0456",  # CYRILLIC SMALL LETTER BYELORUSSIAN-UKRAINIAN I
    "Iuml": "\xcf",  # LATIN CAPITAL LETTER I WITH DIAERESIS
    "iuml": "\xef",  # LATIN SMALL LETTER I WITH DIAERESIS
    "Jcirc": "\u0134",  # LATIN CAPITAL LETTER J WITH CIRCUMFLEX
    "jcirc": "\u0135",  # LATIN SMALL LETTER J WITH CIRCUMFLEX
    "Jcy": "\u0419",  # CYRILLIC CAPITAL LETTER SHORT I
    "jcy": "\u0439",  # CYRILLIC SMALL LETTER SHORT I
    "Jfr": "\U0001d50d",  # MATHEMATICAL FRAKTUR CAPITAL J
    "jfr": "\U0001d527",  # MATHEMATICAL FRAKTUR SMALL J
    "jmath": "\u0237",  # LATIN SMALL LETTER DOTLESS J
    "Jopf": "\U0001d541",  # MATHEMATICAL DOUBLE-STRUCK CAPITAL J
    "jopf": "\U0001d55b",  # MATHEMATICAL DOUBLE-STRUCK SMALL J
    "Jscr": "\U0001d4a5",  # MATHEMATICAL SCRIPT CAPITAL J
    "jscr": "\U0001d4bf",  # MATHEMATICAL SCRIPT SMALL J
    "Jsercy": "\u0408",  # CYRILLIC CAPITAL LETTER JE
    "jsercy": "\u0458",  # CYRILLIC SMALL LETTER JE
    "Jukcy": "\u0404",  # CYRILLIC CAPITAL LETTER UKRAINIAN IE
    "jukcy": "\u0454",  # CYRILLIC SMALL LETTER UKRAINIAN IE
    "Kappa": "\u039a",  # GREEK CAPITAL LETTER KAPPA
    "kappa": "\u03ba",  # GREEK SMALL LETTER KAPPA
    "kappav": "\u03f0",  # GREEK KAPPA SYMBOL
    "Kcedil": "\u0136",  # LATIN CAPITAL LETTER K WITH CEDILLA
    "kcedil": "\u0137",  # LATIN SMALL LETTER K WITH CEDILLA
    "Kcy": "\u041a",  # CYRILLIC CAPITAL LETTER KA
    "kcy": "\u043a",  # CYRILLIC SMALL LETTER KA
    "Kfr": "\U0001d50e",  # MATHEMATICAL FRAKTUR CAPITAL K
    "kfr": "\U0001d528",  # MATHEMATICAL FRAKTUR SMALL K
    "kgreen": "\u0138",  # LATIN SMALL LETTER KRA
    "KHcy": "\u0425",  # CYRILLIC CAPITAL LETTER HA
    "khcy": "\u0445",  # CYRILLIC SMALL LETTER HA
    "KJcy": "\u040c",  # CYRILLIC CAPITAL LETTER KJE
    "kjcy": "\u045c",  # CYRILLIC SMALL LETTER KJE
    "Kopf": "\U0001d542",  # MATHEMATICAL DOUBLE-STRUCK CAPITAL K
    "kopf": "\U0001d55c",  # MATHEMATICAL DOUBLE-STRUCK SMALL K
    "Kscr": "\U0001d4a6",  # MATHEMATICAL SCRIPT CAPITAL K
    "kscr": "\U0001d4c0",  # MATHEMATICAL SCRIPT SMALL K
    "lAarr": "\u21da",  # LEFTWARDS TRIPLE ARROW
    "Lacute": "\u0139",  # LATIN CAPITAL LETTER L WITH ACUTE
    "lacute": "\u013a",  # LATIN SMALL LETTER L WITH ACUTE
    "laemptyv": "\u29b4",  # EMPTY SET WITH LEFT ARROW ABOVE
    "lagran": "\u2112",  # SCRIPT CAPITAL L
    "Lambda": "\u039b",  # GREEK CAPITAL LETTER LAMDA
    "lambda": "\u03bb",  # GREEK SMALL LETTER LAMDA
    "Lang": "\u27ea",  # MATHEMATICAL LEFT DOUBLE ANGLE BRACKET
    "lang": "\u27e8",  # MATHEMATICAL LEFT ANGLE BRACKET
    "langd": "\u2991",  # LEFT ANGLE BRACKET WITH DOT
    "langle": "\u27e8",  # MATHEMATICAL LEFT ANGLE BRACKET
    "lap": "\u2a85",  # LESS-THAN OR APPROXIMATE
    "Laplacetrf": "\u2112",  # SCRIPT CAPITAL L
    "laquo": "\xab",  # LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
    "Larr": "\u219e",  # LEFTWARDS TWO HEADED ARROW
    "lArr": "\u21d0",  # LEFTWARDS DOUBLE ARROW
    "larr": "\u2190",  # LEFTWARDS ARROW
    "larrb": "\u21e4",  # LEFTWARDS ARROW TO BAR
    "larrbfs": "\u291f",  # LEFTWARDS ARROW FROM BAR TO BLACK DIAMOND
    "larrfs": "\u291d",  # LEFTWARDS ARROW TO BLACK DIAMOND
    "larrhk": "\u21a9",  # LEFTWARDS ARROW WITH HOOK
    "larrlp": "\u21ab",  # LEFTWARDS ARROW WITH LOOP
    "larrpl": "\u2939",  # LEFT-SIDE ARC ANTICLOCKWISE ARROW
    "larrsim": "\u2973",  # LEFTWARDS ARROW ABOVE TILDE OPERATOR
    "larrtl": "\u21a2",  # LEFTWARDS ARROW WITH TAIL
    "lat": "\u2aab",  # LARGER THAN
    "lAtail": "\u291b",  # LEFTWARDS DOUBLE ARROW-TAIL
    "latail": "\u2919",  # LEFTWARDS ARROW-TAIL
    "late": "\u2aad",  # LARGER THAN OR EQUAL TO
    "lates": "\u2aad\ufe00",  # LARGER THAN OR slanted EQUAL
    "lBarr": "\u290e",  # LEFTWARDS TRIPLE DASH ARROW
    "lbarr": "\u290c",  # LEFTWARDS DOUBLE DASH ARROW
    "lbbrk": "\u2772",  # LIGHT LEFT TORTOISE SHELL BRACKET ORNAMENT
    "lbrace": "{",  # LEFT CURLY BRACKET
    "lbrack": "[",  # LEFT SQUARE BRACKET
    "lbrke": "\u298b",  # LEFT SQUARE BRACKET WITH UNDERBAR
    "lbrksld": "\u298f",  # LEFT SQUARE BRACKET WITH TICK IN BOTTOM CORNER
    "lbrkslu": "\u298d",  # LEFT SQUARE BRACKET WITH TICK IN TOP CORNER
    "Lcaron": "\u013d",  # LATIN CAPITAL LETTER L WITH CARON
    "lcaron": "\u013e",  # LATIN SMALL LETTER L WITH CARON
    "Lcedil": "\u013b",  # LATIN CAPITAL LETTER L WITH CEDILLA
    "lcedil": "\u013c",  # LATIN SMALL LETTER L WITH CEDILLA
    "lceil": "\u2308",  # LEFT CEILING
    "lcub": "{",  # LEFT CURLY BRACKET
    "Lcy": "\u041b",  # CYRILLIC CAPITAL LETTER EL
    "lcy": "\u043b",  # CYRILLIC SMALL LETTER EL
    "ldca": "\u2936",  # ARROW POINTING DOWNWARDS THEN CURVING LEFTWARDS
    "ldquo": "\u201c",  # LEFT DOUBLE QUOTATION MARK
    "ldquor": "\u201e",  # DOUBLE LOW-9 QUOTATION MARK
    "ldrdhar": "\u2967",  # LEFTWARDS HARPOON WITH BARB DOWN ABOVE RIGHTWARDS HARPOON WITH BARB DOWN
    "ldrushar": "\u294b",  # LEFT BARB DOWN RIGHT BARB UP HARPOON
    "ldsh": "\u21b2",  # DOWNWARDS ARROW WITH TIP LEFTWARDS
    "lE": "\u2266",  # LESS-THAN OVER EQUAL TO
    "le": "\u2264",  # LESS-THAN OR EQUAL TO
    "LeftAngleBracket": "\u27e8",  # MATHEMATICAL LEFT ANGLE BRACKET
    "LeftArrow": "\u2190",  # LEFTWARDS ARROW
    "Leftarrow": "\u21d0",  # LEFTWARDS DOUBLE ARROW
    "leftarrow": "\u2190",  # LEFTWARDS ARROW
    "LeftArrowBar": "\u21e4",  # LEFTWARDS ARROW TO BAR
    "LeftArrowRightArrow": "\u21c6",  # LEFTWARDS ARROW OVER RIGHTWARDS ARROW
    "leftarrowtail": "\u21a2",  # LEFTWARDS ARROW WITH TAIL
    "LeftCeiling": "\u2308",  # LEFT CEILING
    "LeftDoubleBracket": "\u27e6",  # MATHEMATICAL LEFT WHITE SQUARE BRACKET
    "LeftDownTeeVector": "\u2961",  # DOWNWARDS HARPOON WITH BARB LEFT FROM BAR
    "LeftDownVector": "\u21c3",  # DOWNWARDS HARPOON WITH BARB LEFTWARDS
    "LeftDownVectorBar": "\u2959",  # DOWNWARDS HARPOON WITH BARB LEFT TO BAR
    "LeftFloor": "\u230a",  # LEFT FLOOR
    "leftharpoondown": "\u21bd",  # LEFTWARDS HARPOON WITH BARB DOWNWARDS
    "leftharpoonup": "\u21bc",  # LEFTWARDS HARPOON WITH BARB UPWARDS
    "leftleftarrows": "\u21c7",  # LEFTWARDS PAIRED ARROWS
    "LeftRightArrow": "\u2194",  # LEFT RIGHT ARROW
    "Leftrightarrow": "\u21d4",  # LEFT RIGHT DOUBLE ARROW
    "leftrightarrow": "\u2194",  # LEFT RIGHT ARROW
    "leftrightarrows": "\u21c6",  # LEFTWARDS ARROW OVER RIGHTWARDS ARROW
    "leftrightharpoons": "\u21cb",  # LEFTWARDS HARPOON OVER RIGHTWARDS HARPOON
    "leftrightsquigarrow": "\u21ad",  # LEFT RIGHT WAVE ARROW
    "LeftRightVector": "\u294e",  # LEFT BARB UP RIGHT BARB UP HARPOON
    "LeftTee": "\u22a3",  # LEFT TACK
    "LeftTeeArrow": "\u21a4",  # LEFTWARDS ARROW FROM BAR
    "LeftTeeVector": "\u295a",  # LEFTWARDS HARPOON WITH BARB UP FROM BAR
    "leftthreetimes": "\u22cb",  # LEFT SEMIDIRECT PRODUCT
    "LeftTriangle": "\u22b2",  # NORMAL SUBGROUP OF
    "LeftTriangleBar": "\u29cf",  # LEFT TRIANGLE BESIDE VERTICAL BAR
    "LeftTriangleEqual": "\u22b4",  # NORMAL SUBGROUP OF OR EQUAL TO
    "LeftUpDownVector": "\u2951",  # UP BARB LEFT DOWN BARB LEFT HARPOON
    "LeftUpTeeVector": "\u2960",  # UPWARDS HARPOON WITH BARB LEFT FROM BAR
    "LeftUpVector": "\u21bf",  # UPWARDS HARPOON WITH BARB LEFTWARDS
    "LeftUpVectorBar": "\u2958",  # UPWARDS HARPOON WITH BARB LEFT TO BAR
    "LeftVector": "\u21bc",  # LEFTWARDS HARPOON WITH BARB UPWARDS
    "LeftVectorBar": "\u2952",  # LEFTWARDS HARPOON WITH BARB UP TO BAR
    "lEg": "\u2a8b",  # LESS-THAN ABOVE DOUBLE-LINE EQUAL ABOVE GREATER-THAN
    "leg": "\u22da",  # LESS-THAN EQUAL TO OR GREATER-THAN
    "leq": "\u2264",  # LESS-THAN OR EQUAL TO
    "leqq": "\u2266",  # LESS-THAN OVER EQUAL TO
    "leqslant": "\u2a7d",  # LESS-THAN OR SLANTED EQUAL TO
    "les": "\u2a7d",  # LESS-THAN OR SLANTED EQUAL TO
    "lescc": "\u2aa8",  # LESS-THAN CLOSED BY CURVE ABOVE SLANTED EQUAL
    "lesdot": "\u2a7f",  # LESS-THAN OR SLANTED EQUAL TO WITH DOT INSIDE
    "lesdoto": "\u2a81",  # LESS-THAN OR SLANTED EQUAL TO WITH DOT ABOVE
    "lesdotor": "\u2a83",  # LESS-THAN OR SLANTED EQUAL TO WITH DOT ABOVE RIGHT
    "lesg": "\u22da\ufe00",  # LESS-THAN slanted EQUAL TO OR GREATER-THAN
    "lesges": "\u2a93",  # LESS-THAN ABOVE SLANTED EQUAL ABOVE GREATER-THAN ABOVE SLANTED EQUAL
    "lessapprox": "\u2a85",  # LESS-THAN OR APPROXIMATE
    "lessdot": "\u22d6",  # LESS-THAN WITH DOT
    "lesseqgtr": "\u22da",  # LESS-THAN EQUAL TO OR GREATER-THAN
    "lesseqqgtr": "\u2a8b",  # LESS-THAN ABOVE DOUBLE-LINE EQUAL ABOVE GREATER-THAN
    "LessEqualGreater": "\u22da",  # LESS-THAN EQUAL TO OR GREATER-THAN
    "LessFullEqual": "\u2266",  # LESS-THAN OVER EQUAL TO
    "LessGreater": "\u2276",  # LESS-THAN OR GREATER-THAN
    "lessgtr": "\u2276",  # LESS-THAN OR GREATER-THAN
    "LessLess": "\u2aa1",  # DOUBLE NESTED LESS-THAN
    "lesssim": "\u2272",  # LESS-THAN OR EQUIVALENT TO
    "LessSlantEqual": "\u2a7d",  # LESS-THAN OR SLANTED EQUAL TO
    "LessTilde": "\u2272",  # LESS-THAN OR EQUIVALENT TO
    "lfisht": "\u297c",  # LEFT FISH TAIL
    "lfloor": "\u230a",  # LEFT FLOOR
    "Lfr": "\U0001d50f",  # MATHEMATICAL FRAKTUR CAPITAL L
    "lfr": "\U0001d529",  # MATHEMATICAL FRAKTUR SMALL L
    "lg": "\u2276",  # LESS-THAN OR GREATER-THAN
    "lgE": "\u2a91",  # LESS-THAN ABOVE GREATER-THAN ABOVE DOUBLE-LINE EQUAL
    "lHar": "\u2962",  # LEFTWARDS HARPOON WITH BARB UP ABOVE LEFTWARDS HARPOON WITH BARB DOWN
    "lhard": "\u21bd",  # LEFTWARDS HARPOON WITH BARB DOWNWARDS
    "lharu": "\u21bc",  # LEFTWARDS HARPOON WITH BARB UPWARDS
    "lharul": "\u296a",  # LEFTWARDS HARPOON WITH BARB UP ABOVE LONG DASH
    "lhblk": "\u2584",  # LOWER HALF BLOCK
    "LJcy": "\u0409",  # CYRILLIC CAPITAL LETTER LJE
    "ljcy": "\u0459",  # CYRILLIC SMALL LETTER LJE
    "Ll": "\u22d8",  # VERY MUCH LESS-THAN
    "ll": "\u226a",  # MUCH LESS-THAN
    "llarr": "\u21c7",  # LEFTWARDS PAIRED ARROWS
    "llcorner": "\u231e",  # BOTTOM LEFT CORNER
    "Lleftarrow": "\u21da",  # LEFTWARDS TRIPLE ARROW
    "llhard": "\u296b",  # LEFTWARDS HARPOON WITH BARB DOWN BELOW LONG DASH
    "lltri": "\u25fa",  # LOWER LEFT TRIANGLE
    "Lmidot": "\u013f",  # LATIN CAPITAL LETTER L WITH MIDDLE DOT
    "lmidot": "\u0140",  # LATIN SMALL LETTER L WITH MIDDLE DOT
    "lmoust": "\u23b0",  # UPPER LEFT OR LOWER RIGHT CURLY BRACKET SECTION
    "lmoustache": "\u23b0",  # UPPER LEFT OR LOWER RIGHT CURLY BRACKET SECTION
    "lnap": "\u2a89",  # LESS-THAN AND NOT APPROXIMATE
    "lnapprox": "\u2a89",  # LESS-THAN AND NOT APPROXIMATE
    "lnE": "\u2268",  # LESS-THAN BUT NOT EQUAL TO
    "lne": "\u2a87",  # LESS-THAN AND SINGLE-LINE NOT EQUAL TO
    "lneq": "\u2a87",  # LESS-THAN AND SINGLE-LINE NOT EQUAL TO
    "lneqq": "\u2268",  # LESS-THAN BUT NOT EQUAL TO
    "lnsim": "\u22e6",  # LESS-THAN BUT NOT EQUIVALENT TO
    "loang": "\u27ec",  # MATHEMATICAL LEFT WHITE TORTOISE SHELL BRACKET
    "loarr": "\u21fd",  # LEFTWARDS OPEN-HEADED ARROW
    "lobrk": "\u27e6",  # MATHEMATICAL LEFT WHITE SQUARE BRACKET
    "LongLeftArrow": "\u27f5",  # LONG LEFTWARDS ARROW
    "Longleftarrow": "\u27f8",  # LONG LEFTWARDS DOUBLE ARROW
    "longleftarrow": "\u27f5",  # LONG LEFTWARDS ARROW
    "LongLeftRightArrow": "\u27f7",  # LONG LEFT RIGHT ARROW
    "Longleftrightarrow": "\u27fa",  # LONG LEFT RIGHT DOUBLE ARROW
    "longleftrightarrow": "\u27f7",  # LONG LEFT RIGHT ARROW
    "longmapsto": "\u27fc",  # LONG RIGHTWARDS ARROW FROM BAR
    "LongRightArrow": "\u27f6",  # LONG RIGHTWARDS ARROW
    "Longrightarrow": "\u27f9",  # LONG RIGHTWARDS DOUBLE ARROW
    "longrightarrow": "\u27f6",  # LONG RIGHTWARDS ARROW
    "looparrowleft": "\u21ab",  # LEFTWARDS ARROW WITH LOOP
    "looparrowright": "\u21ac",  # RIGHTWARDS ARROW WITH LOOP
    "lopar": "\u2985",  # LEFT WHITE PARENTHESIS
    "Lopf": "\U0001d543",  # MATHEMATICAL DOUBLE-STRUCK CAPITAL L
    "lopf": "\U0001d55d",  # MATHEMATICAL DOUBLE-STRUCK SMALL L
    "loplus": "\u2a2d",  # PLUS SIGN IN LEFT HALF CIRCLE
    "lotimes": "\u2a34",  # MULTIPLICATION SIGN IN LEFT HALF CIRCLE
    "lowast": "\u2217",  # ASTERISK OPERATOR
    "lowbar": "_",  # LOW LINE
    "LowerLeftArrow": "\u2199",  # SOUTH WEST ARROW
    "LowerRightArrow": "\u2198",  # SOUTH EAST ARROW
    "loz": "\u25ca",  # LOZENGE
    "lozenge": "\u25ca",  # LOZENGE
    "lozf": "\u29eb",  # BLACK LOZENGE
    "lpar": "(",  # LEFT PARENTHESIS
    "lparlt": "\u2993",  # LEFT ARC LESS-THAN BRACKET
    "lrarr": "\u21c6",  # LEFTWARDS ARROW OVER RIGHTWARDS ARROW
    "lrcorner": "\u231f",  # BOTTOM RIGHT CORNER
    "lrhar": "\u21cb",  # LEFTWARDS HARPOON OVER RIGHTWARDS HARPOON
    "lrhard": "\u296d",  # RIGHTWARDS HARPOON WITH BARB DOWN BELOW LONG DASH
    "lrm": "\u200e",  # LEFT-TO-RIGHT MARK
    "lrtri": "\u22bf",  # RIGHT TRIANGLE
    "lsaquo": "\u2039",  # SINGLE LEFT-POINTING ANGLE QUOTATION MARK
    "Lscr": "\u2112",  # SCRIPT CAPITAL L
    "lscr": "\U0001d4c1",  # MATHEMATICAL SCRIPT SMALL L
    "Lsh": "\u21b0",  # UPWARDS ARROW WITH TIP LEFTWARDS
    "lsh": "\u21b0",  # UPWARDS ARROW WITH TIP LEFTWARDS
    "lsim": "\u2272",  # LESS-THAN OR EQUIVALENT TO
    "lsime": "\u2a8d",  # LESS-THAN ABOVE SIMILAR OR EQUAL
    "lsimg": "\u2a8f",  # LESS-THAN ABOVE SIMILAR ABOVE GREATER-THAN
    "lsqb": "[",  # LEFT SQUARE BRACKET
    "lsquo": "\u2018",  # LEFT SINGLE QUOTATION MARK
    "lsquor": "\u201a",  # SINGLE LOW-9 QUOTATION MARK
    "Lstrok": "\u0141",  # LATIN CAPITAL LETTER L WITH STROKE
    "lstrok": "\u0142",  # LATIN SMALL LETTER L WITH STROKE
    "LT": "\x3c",  # LESS-THAN SIGN
    "Lt": "\u226a",  # MUCH LESS-THAN
    "lt": "\x3c",  # LESS-THAN SIGN
    "ltcc": "\u2aa6",  # LESS-THAN CLOSED BY CURVE
    "ltcir": "\u2a79",  # LESS-THAN WITH CIRCLE INSIDE
    "ltdot": "\u22d6",  # LESS-THAN WITH DOT
    "lthree": "\u22cb",  # LEFT SEMIDIRECT PRODUCT
    "ltimes": "\u22c9",  # LEFT NORMAL FACTOR SEMIDIRECT PRODUCT
    "ltlarr": "\u2976",  # LESS-THAN ABOVE LEFTWARDS ARROW
    "ltquest": "\u2a7b",  # LESS-THAN WITH QUESTION MARK ABOVE
    "ltri": "\u25c3",  # WHITE LEFT-POINTING SMALL TRIANGLE
    "ltrie": "\u22b4",  # NORMAL SUBGROUP OF OR EQUAL TO
    "ltrif": "\u25c2",  # BLACK LEFT-POINTING SMALL TRIANGLE
    "ltrPar": "\u2996",  # DOUBLE RIGHT ARC LESS-THAN BRACKET
    "lurdshar": "\u294a",  # LEFT BARB UP RIGHT BARB DOWN HARPOON
    "luruhar": "\u2966",  # LEFTWARDS HARPOON WITH BARB UP ABOVE RIGHTWARDS HARPOON WITH BARB UP
    "lvertneqq": "\u2268\ufe00",  # LESS-THAN BUT NOT EQUAL TO - with vertical stroke
    "lvnE": "\u2268\ufe00",  # LESS-THAN BUT NOT EQUAL TO - with vertical stroke
    "macr": "\xaf",  # MACRON
    "male": "\u2642",  # MALE SIGN
    "malt": "\u2720",  # MALTESE CROSS
    "maltese": "\u2720",  # MALTESE CROSS
    "Map": "\u2905",  # RIGHTWARDS TWO-HEADED ARROW FROM BAR
    "map": "\u21a6",  # RIGHTWARDS ARROW FROM BAR
    "mapsto": "\u21a6",  # RIGHTWARDS ARROW FROM BAR
    "mapstodown": "\u21a7",  # DOWNWARDS ARROW FROM BAR
    "mapstoleft": "\u21a4",  # LEFTWARDS ARROW FROM BAR
    "mapstoup": "\u21a5",  # UPWARDS ARROW FROM BAR
    "marker": "\u25ae",  # BLACK VERTICAL RECTANGLE
    "mcomma": "\u2a29",  # MINUS SIGN WITH COMMA ABOVE
    "Mcy": "\u041c",  # CYRILLIC CAPITAL LETTER EM
    "mcy": "\u043c",  # CYRILLIC SMALL LETTER EM
    "mdash": "\u2014",  # EM DASH
    "mDDot": "\u223a",  # GEOMETRIC PROPORTION
    "measuredangle": "\u2221",  # MEASURED ANGLE
    "MediumSpace": "\u205f",  # MEDIUM MATHEMATICAL SPACE
    "Mellintrf": "\u2133",  # SCRIPT CAPITAL M
    "Mfr": "\U0001d510",  # MATHEMATICAL FRAKTUR CAPITAL M
    "mfr": "\U0001d52a",  # MATHEMATICAL FRAKTUR SMALL M
    "mho": "\u2127",  # INVERTED OHM SIGN
    "micro": "\xb5",  # MICRO SIGN
    "mid": "\u2223",  # DIVIDES
    "midast": "*",  # ASTERISK
    "midcir": "\u2af0",  # VERTICAL LINE WITH CIRCLE BELOW
    "middot": "\xb7",  # MIDDLE DOT
    "minus": "\u2212",  # MINUS SIGN
    "minusb": "\u229f",  # SQUARED MINUS
    "minusd": "\u2238",  # DOT MINUS
    "minusdu": "\u2a2a",  # MINUS SIGN WITH DOT BELOW
    "MinusPlus": "\u2213",  # MINUS-OR-PLUS SIGN
    "mlcp": "\u2adb",  # TRANSVERSAL INTERSECTION
    "mldr": "\u2026",  # HORIZONTAL ELLIPSIS
    "mnplus": "\u2213",  # MINUS-OR-PLUS SIGN
    "models": "\u22a7",  # MODELS
    "Mopf": "\U0001d544",  # MATHEMATICAL DOUBLE-STRUCK CAPITAL M
    "mopf": "\U0001d55e",  # MATHEMATICAL DOUBLE-STRUCK SMALL M
    "mp": "\u2213",  # MINUS-OR-PLUS SIGN
    "Mscr": "\u2133",  # SCRIPT CAPITAL M
    "mscr": "\U0001d4c2",  # MATHEMATICAL SCRIPT SMALL M
    "mstpos": "\u223e",  # INVERTED LAZY S
    "Mu": "\u039c",  # GREEK CAPITAL LETTER MU
    "mu": "\u03bc",  # GREEK SMALL LETTER MU
    "multimap": "\u22b8",  # MULTIMAP
    "mumap": "\u22b8",  # MULTIMAP
    "nabla": "\u2207",  # NABLA
    "Nacute": "\u0143",  # LATIN CAPITAL LETTER N WITH ACUTE
    "nacute": "\u0144",  # LATIN SMALL LETTER N WITH ACUTE
    "nang": "\u2220\u20d2",  # ANGLE with vertical line
    "nap": "\u2249",  # NOT ALMOST EQUAL TO
    "napE": "\u2a70\u0338",  # APPROXIMATELY EQUAL OR EQUAL TO with slash
    "napid": "\u224b\u0338",  # TRIPLE TILDE with slash
    "napos": "\u0149",  # LATIN SMALL LETTER N PRECEDED BY APOSTROPHE
    "napprox": "\u2249",  # NOT ALMOST EQUAL TO
    "natur": "\u266e",  # MUSIC NATURAL SIGN
    "natural": "\u266e",  # MUSIC NATURAL SIGN
    "naturals": "\u2115",  # DOUBLE-STRUCK CAPITAL N
    "nbsp": "\xa0",  # NO-BREAK SPACE
    "nbump": "\u224e\u0338",  # GEOMETRICALLY EQUIVALENT TO with slash
    "nbumpe": "\u224f\u0338",  # DIFFERENCE BETWEEN with slash
    "ncap": "\u2a43",  # INTERSECTION WITH OVERBAR
    "Ncaron": "\u0147",  # LATIN CAPITAL LETTER N WITH CARON
    "ncaron": "\u0148",  # LATIN SMALL LETTER N WITH CARON
    "Ncedil": "\u0145",  # LATIN CAPITAL LETTER N WITH CEDILLA
    "ncedil": "\u0146",  # LATIN SMALL LETTER N WITH CEDILLA
    "ncong": "\u2247",  # NEITHER APPROXIMATELY NOR ACTUALLY EQUAL TO
    "ncongdot": "\u2a6d\u0338",  # CONGRUENT WITH DOT ABOVE with slash
    "ncup": "\u2a42",  # UNION WITH OVERBAR
    "Ncy": "\u041d",  # CYRILLIC CAPITAL LETTER EN
    "ncy": "\u043d",  # CYRILLIC SMALL LETTER EN
    "ndash": "\u2013",  # EN DASH
    "ne": "\u2260",  # NOT EQUAL TO
    "nearhk": "\u2924",  # NORTH EAST ARROW WITH HOOK
    "neArr": "\u21d7",  # NORTH EAST DOUBLE ARROW
    "nearr": "\u2197",  # NORTH EAST ARROW
    "nearrow": "\u2197",  # NORTH EAST ARROW
    "nedot": "\u2250\u0338",  # APPROACHES THE LIMIT with slash
    "NegativeMediumSpace": "\u200b",  # ZERO WIDTH SPACE
    "NegativeThickSpace": "\u200b",  # ZERO WIDTH SPACE
    "NegativeThinSpace": "\u200b",  # ZERO WIDTH SPACE
    "NegativeVeryThinSpace": "\u200b",  # ZERO WIDTH SPACE
    "nequiv": "\u2262",  # NOT IDENTICAL TO
    "nesear": "\u2928",  # NORTH EAST ARROW AND SOUTH EAST ARROW
    "nesim": "\u2242\u0338",  # MINUS TILDE with slash
    "NestedGreaterGreater": "\u226b",  # MUCH GREATER-THAN
    "NestedLessLess": "\u226a",  # MUCH LESS-THAN
    "NewLine": "\n",  # LINE FEED (LF)
    "nexist": "\u2204",  # THERE DOES NOT EXIST
    "nexists": "\u2204",  # THERE DOES NOT EXIST
    "Nfr": "\U0001d511",  # MATHEMATICAL FRAKTUR CAPITAL N
    "nfr": "\U0001d52b",  # MATHEMATICAL FRAKTUR SMALL N
    "ngE": "\u2267\u0338",  # GREATER-THAN OVER EQUAL TO with slash
    "nge": "\u2271",  # NEITHER GREATER-THAN NOR EQUAL TO
    "ngeq": "\u2271",  # NEITHER GREATER-THAN NOR EQUAL TO
    "ngeqq": "\u2267\u0338",  # GREATER-THAN OVER EQUAL TO with slash
    "ngeqslant": "\u2a7e\u0338",  # GREATER-THAN OR SLANTED EQUAL TO with slash
    "nges": "\u2a7e\u0338",  # GREATER-THAN OR SLANTED EQUAL TO with slash
    "nGg": "\u22d9\u0338",  # VERY MUCH GREATER-THAN with slash
    "ngsim": "\u2275",  # NEITHER GREATER-THAN NOR EQUIVALENT TO
    "nGt": "\u226b\u20d2",  # MUCH GREATER THAN with vertical line
    "ngt": "\u226f",  # NOT GREATER-THAN
    "ngtr": "\u226f",  # NOT GREATER-THAN
    "nGtv": "\u226b\u0338",  # MUCH GREATER THAN with slash
    "nhArr": "\u21ce",  # LEFT RIGHT DOUBLE ARROW WITH STROKE
    "nharr": "\u21ae",  # LEFT RIGHT ARROW WITH STROKE
    "nhpar": "\u2af2",  # PARALLEL WITH HORIZONTAL STROKE
    "ni": "\u220b",  # CONTAINS AS MEMBER
    "nis": "\u22fc",  # SMALL CONTAINS WITH VERTICAL BAR AT END OF HORIZONTAL STROKE
    "nisd": "\u22fa",  # CONTAINS WITH LONG HORIZONTAL STROKE
    "niv": "\u220b",  # CONTAINS AS MEMBER
    "NJcy": "\u040a",  # CYRILLIC CAPITAL LETTER NJE
    "njcy": "\u045a",  # CYRILLIC SMALL LETTER NJE
    "nlArr": "\u21cd",  # LEFTWARDS DOUBLE ARROW WITH STROKE
    "nlarr": "\u219a",  # LEFTWARDS ARROW WITH STROKE
    "nldr": "\u2025",  # TWO DOT LEADER
    "nlE": "\u2266\u0338",  # LESS-THAN OVER EQUAL TO with slash
    "nle": "\u2270",  # NEITHER LESS-THAN NOR EQUAL TO
    "nLeftarrow": "\u21cd",  # LEFTWARDS DOUBLE ARROW WITH STROKE
    "nleftarrow": "\u219a",  # LEFTWARDS ARROW WITH STROKE
    "nLeftrightarrow": "\u21ce",  # LEFT RIGHT DOUBLE ARROW WITH STROKE
    "nleftrightarrow": "\u21ae",  # LEFT RIGHT ARROW WITH STROKE
    "nleq": "\u2270",  # NEITHER LESS-THAN NOR EQUAL TO
    "nleqq": "\u2266\u0338",  # LESS-THAN OVER EQUAL TO with slash
    "nleqslant": "\u2a7d\u0338",  # LESS-THAN OR SLANTED EQUAL TO with slash
    "nles": "\u2a7d\u0338",  # LESS-THAN OR SLANTED EQUAL TO with slash
    "nless": "\u226e",  # NOT LESS-THAN
    "nLl": "\u22d8\u0338",  # VERY MUCH LESS-THAN with slash
    "nlsim": "\u2274",  # NEITHER LESS-THAN NOR EQUIVALENT TO
    "nLt": "\u226a\u20d2",  # MUCH LESS THAN with vertical line
    "nlt": "\u226e",  # NOT LESS-THAN
    "nltri": "\u22ea",  # NOT NORMAL SUBGROUP OF
    "nltrie": "\u22ec",  # NOT NORMAL SUBGROUP OF OR EQUAL TO
    "nLtv": "\u226a\u0338",  # MUCH LESS THAN with slash
    "nmid": "\u2224",  # DOES NOT DIVIDE
    "NoBreak": "\u2060",  # WORD JOINER
    "NonBreakingSpace": "\xa0",  # NO-BREAK SPACE
    "Nopf": "\u2115",  # DOUBLE-STRUCK CAPITAL N
    "nopf": "\U0001d55f",  # MATHEMATICAL DOUBLE-STRUCK SMALL N
    "Not": "\u2aec",  # DOUBLE STROKE NOT SIGN
    "not": "\xac",  # NOT SIGN
    "NotCongruent": "\u2262",  # NOT IDENTICAL TO
    "NotCupCap": "\u226d",  # NOT EQUIVALENT TO
    "NotDoubleVerticalBar": "\u2226",  # NOT PARALLEL TO
    "NotElement": "\u2209",  # NOT AN ELEMENT OF
    "NotEqual": "\u2260",  # NOT EQUAL TO
    "NotEqualTilde": "\u2242\u0338",  # MINUS TILDE with slash
    "NotExists": "\u2204",  # THERE DOES NOT EXIST
    "NotGreater": "\u226f",  # NOT GREATER-THAN
    "NotGreaterEqual": "\u2271",  # NEITHER GREATER-THAN NOR EQUAL TO
    "NotGreaterFullEqual": "\u2267\u0338",  # GREATER-THAN OVER EQUAL TO with slash
    "NotGreaterGreater": "\u226b\u0338",  # MUCH GREATER THAN with slash
    "NotGreaterLess": "\u2279",  # NEITHER GREATER-THAN NOR LESS-THAN
    "NotGreaterSlantEqual": "\u2a7e\u0338",  # GREATER-THAN OR SLANTED EQUAL TO with slash
    "NotGreaterTilde": "\u2275",  # NEITHER GREATER-THAN NOR EQUIVALENT TO
    "NotHumpDownHump": "\u224e\u0338",  # GEOMETRICALLY EQUIVALENT TO with slash
    "NotHumpEqual": "\u224f\u0338",  # DIFFERENCE BETWEEN with slash
    "notin": "\u2209",  # NOT AN ELEMENT OF
    "notindot": "\u22f5\u0338",  # ELEMENT OF WITH DOT ABOVE with slash
    "notinE": "\u22f9\u0338",  # ELEMENT OF WITH TWO HORIZONTAL STROKES with slash
    "notinva": "\u2209",  # NOT AN ELEMENT OF
    "notinvb": "\u22f7",  # SMALL ELEMENT OF WITH OVERBAR
    "notinvc": "\u22f6",  # ELEMENT OF WITH OVERBAR
    "NotLeftTriangle": "\u22ea",  # NOT NORMAL SUBGROUP OF
    "NotLeftTriangleBar": "\u29cf\u0338",  # LEFT TRIANGLE BESIDE VERTICAL BAR with slash
    "NotLeftTriangleEqual": "\u22ec",  # NOT NORMAL SUBGROUP OF OR EQUAL TO
    "NotLess": "\u226e",  # NOT LESS-THAN
    "NotLessEqual": "\u2270",  # NEITHER LESS-THAN NOR EQUAL TO
    "NotLessGreater": "\u2278",  # NEITHER LESS-THAN NOR GREATER-THAN
    "NotLessLess": "\u226a\u0338",  # MUCH LESS THAN with slash
    "NotLessSlantEqual": "\u2a7d\u0338",  # LESS-THAN OR SLANTED EQUAL TO with slash
    "NotLessTilde": "\u2274",  # NEITHER LESS-THAN NOR EQUIVALENT TO
    "NotNestedGreaterGreater": "\u2aa2\u0338",  # DOUBLE NESTED GREATER-THAN with slash
    "NotNestedLessLess": "\u2aa1\u0338",  # DOUBLE NESTED LESS-THAN with slash
    "notni": "\u220c",  # DOES NOT CONTAIN AS MEMBER
    "notniva": "\u220c",  # DOES NOT CONTAIN AS MEMBER
    "notnivb": "\u22fe",  # SMALL CONTAINS WITH OVERBAR
    "notnivc": "\u22fd",  # CONTAINS WITH OVERBAR
    "NotPrecedes": "\u2280",  # DOES NOT PRECEDE
    "NotPrecedesEqual": "\u2aaf\u0338",  # PRECEDES ABOVE SINGLE-LINE EQUALS SIGN with slash
    "NotPrecedesSlantEqual": "\u22e0",  # DOES NOT PRECEDE OR EQUAL
    "NotReverseElement": "\u220c",  # DOES NOT CONTAIN AS MEMBER
    "NotRightTriangle": "\u22eb",  # DOES NOT CONTAIN AS NORMAL SUBGROUP
    "NotRightTriangleBar": "\u29d0\u0338",  # VERTICAL BAR BESIDE RIGHT TRIANGLE with slash
    "NotRightTriangleEqual": "\u22ed",  # DOES NOT CONTAIN AS NORMAL SUBGROUP OR EQUAL
    "NotSquareSubset": "\u228f\u0338",  # SQUARE IMAGE OF with slash
    "NotSquareSubsetEqual": "\u22e2",  # NOT SQUARE IMAGE OF OR EQUAL TO
    "NotSquareSuperset": "\u2290\u0338",  # SQUARE ORIGINAL OF with slash
    "NotSquareSupersetEqual": "\u22e3",  # NOT SQUARE ORIGINAL OF OR EQUAL TO
    "NotSubset": "\u2282\u20d2",  # SUBSET OF with vertical line
    "NotSubsetEqual": "\u2288",  # NEITHER A SUBSET OF NOR EQUAL TO
    "NotSucceeds": "\u2281",  # DOES NOT SUCCEED
    "NotSucceedsEqual": "\u2ab0\u0338",  # SUCCEEDS ABOVE SINGLE-LINE EQUALS SIGN with slash
    "NotSucceedsSlantEqual": "\u22e1",  # DOES NOT SUCCEED OR EQUAL
    "NotSucceedsTilde": "\u227f\u0338",  # SUCCEEDS OR EQUIVALENT TO with slash
    "NotSuperset": "\u2283\u20d2",  # SUPERSET OF with vertical line
    "NotSupersetEqual": "\u2289",  # NEITHER A SUPERSET OF NOR EQUAL TO
    "NotTilde": "\u2241",  # NOT TILDE
    "NotTildeEqual": "\u2244",  # NOT ASYMPTOTICALLY EQUAL TO
    "NotTildeFullEqual": "\u2247",  # NEITHER APPROXIMATELY NOR ACTUALLY EQUAL TO
    "NotTildeTilde": "\u2249",  # NOT ALMOST EQUAL TO
    "NotVerticalBar": "\u2224",  # DOES NOT DIVIDE
    "npar": "\u2226",  # NOT PARALLEL TO
    "nparallel": "\u2226",  # NOT PARALLEL TO
    "nparsl": "\u2afd\u20e5",  # DOUBLE SOLIDUS OPERATOR with reverse slash
    "npart": "\u2202\u0338",  # PARTIAL DIFFERENTIAL with slash
    "npolint": "\u2a14",  # LINE INTEGRATION NOT INCLUDING THE POLE
    "npr": "\u2280",  # DOES NOT PRECEDE
    "nprcue": "\u22e0",  # DOES NOT PRECEDE OR EQUAL
    "npre": "\u2aaf\u0338",  # PRECEDES ABOVE SINGLE-LINE EQUALS SIGN with slash
    "nprec": "\u2280",  # DOES NOT PRECEDE
    "npreceq": "\u2aaf\u0338",  # PRECEDES ABOVE SINGLE-LINE EQUALS SIGN with slash
    "nrArr": "\u21cf",  # RIGHTWARDS DOUBLE ARROW WITH STROKE
    "nrarr": "\u219b",  # RIGHTWARDS ARROW WITH STROKE
    "nrarrc": "\u2933\u0338",  # WAVE ARROW POINTING DIRECTLY RIGHT with slash
    "nrarrw": "\u219d\u0338",  # RIGHTWARDS WAVE ARROW with slash
    "nRightarrow": "\u21cf",  # RIGHTWARDS DOUBLE ARROW WITH STROKE
    "nrightarrow": "\u219b",  # RIGHTWARDS ARROW WITH STROKE
    "nrtri": "\u22eb",  # DOES NOT CONTAIN AS NORMAL SUBGROUP
    "nrtrie": "\u22ed",  # DOES NOT CONTAIN AS NORMAL SUBGROUP OR EQUAL
    "nsc": "\u2281",  # DOES NOT SUCCEED
    "nsccue": "\u22e1",  # DOES NOT SUCCEED OR EQUAL
    "nsce": "\u2ab0\u0338",  # SUCCEEDS ABOVE SINGLE-LINE EQUALS SIGN with slash
    "Nscr": "\U0001d4a9",  # MATHEMATICAL SCRIPT CAPITAL N
    "nscr": "\U0001d4c3",  # MATHEMATICAL SCRIPT SMALL N
    "nshortmid": "\u2224",  # DOES NOT DIVIDE
    "nshortparallel": "\u2226",  # NOT PARALLEL TO
    "nsim": "\u2241",  # NOT TILDE
    "nsime": "\u2244",  # NOT ASYMPTOTICALLY EQUAL TO
    "nsimeq": "\u2244",  # NOT ASYMPTOTICALLY EQUAL TO
    "nsmid": "\u2224",  # DOES NOT DIVIDE
    "nspar": "\u2226",  # NOT PARALLEL TO
    "nsqsube": "\u22e2",  # NOT SQUARE IMAGE OF OR EQUAL TO
    "nsqsupe": "\u22e3",  # NOT SQUARE ORIGINAL OF OR EQUAL TO
    "nsub": "\u2284",  # NOT A SUBSET OF
    "nsubE": "\u2ac5\u0338",  # SUBSET OF ABOVE EQUALS SIGN with slash
    "nsube": "\u2288",  # NEITHER A SUBSET OF NOR EQUAL TO
    "nsubset": "\u2282\u20d2",  # SUBSET OF with vertical line
    "nsubseteq": "\u2288",  # NEITHER A SUBSET OF NOR EQUAL TO
    "nsubseteqq": "\u2ac5\u0338",  # SUBSET OF ABOVE EQUALS SIGN with slash
    "nsucc": "\u2281",  # DOES NOT SUCCEED
    "nsucceq": "\u2ab0\u0338",  # SUCCEEDS ABOVE SINGLE-LINE EQUALS SIGN with slash
    "nsup": "\u2285",  # NOT A SUPERSET OF
    "nsupE": "\u2ac6\u0338",  # SUPERSET OF ABOVE EQUALS SIGN with slash
    "nsupe": "\u2289",  # NEITHER A SUPERSET OF NOR EQUAL TO
    "nsupset": "\u2283\u20d2",  # SUPERSET OF with vertical line
    "nsupseteq": "\u2289",  # NEITHER A SUPERSET OF NOR EQUAL TO
    "nsupseteqq": "\u2ac6\u0338",  # SUPERSET OF ABOVE EQUALS SIGN with slash
    "ntgl": "\u2279",  # NEITHER GREATER-THAN NOR LESS-THAN
    "Ntilde": "\xd1",  # LATIN CAPITAL LETTER N WITH TILDE
    "ntilde": "\xf1",  # LATIN SMALL LETTER N WITH TILDE
    "ntlg": "\u2278",  # NEITHER LESS-THAN NOR GREATER-THAN
    "ntriangleleft": "\u22ea",  # NOT NORMAL SUBGROUP OF
    "ntrianglelefteq": "\u22ec",  # NOT NORMAL SUBGROUP OF OR EQUAL TO
    "ntriangleright": "\u22eb",  # DOES NOT CONTAIN AS NORMAL SUBGROUP
    "ntrianglerighteq": "\u22ed",  # DOES NOT CONTAIN AS NORMAL SUBGROUP OR EQUAL
    "Nu": "\u039d",  # GREEK CAPITAL LETTER NU
    "nu": "\u03bd",  # GREEK SMALL LETTER NU
    "num": "#",  # NUMBER SIGN
    "numero": "\u2116",  # NUMERO SIGN
    "numsp": "\u2007",  # FIGURE SPACE
    "nvap": "\u224d\u20d2",  # EQUIVALENT TO with vertical line
    "nVDash": "\u22af",  # NEGATED DOUBLE VERTICAL BAR DOUBLE RIGHT TURNSTILE
    "nVdash": "\u22ae",  # DOES NOT FORCE
    "nvDash": "\u22ad",  # NOT TRUE
    "nvdash": "\u22ac",  # DOES NOT PROVE
    "nvge": "\u2265\u20d2",  # GREATER-THAN OR EQUAL TO with vertical line
    "nvgt": ">\u20d2",  # GREATER-THAN SIGN with vertical line
    "nvHarr": "\u2904",  # LEFT RIGHT DOUBLE ARROW WITH VERTICAL STROKE
    "nvinfin": "\u29de",  # INFINITY NEGATED WITH VERTICAL BAR
    "nvlArr": "\u2902",  # LEFTWARDS DOUBLE ARROW WITH VERTICAL STROKE
    "nvle": "\u2264\u20d2",  # LESS-THAN OR EQUAL TO with vertical line
    "nvlt": "\x3c\u20d2",  # LESS-THAN SIGN with vertical line
    "nvltrie": "\u22b4\u20d2",  # NORMAL SUBGROUP OF OR EQUAL TO with vertical line
    "nvrArr": "\u2903",  # RIGHTWARDS DOUBLE ARROW WITH VERTICAL STROKE
    "nvrtrie": "\u22b5\u20d2",  # CONTAINS AS NORMAL SUBGROUP OR EQUAL TO with vertical line
    "nvsim": "\u223c\u20d2",  # TILDE OPERATOR with vertical line
    "nwarhk": "\u2923",  # NORTH WEST ARROW WITH HOOK
    "nwArr": "\u21d6",  # NORTH WEST DOUBLE ARROW
    "nwarr": "\u2196",  # NORTH WEST ARROW
    "nwarrow": "\u2196",  # NORTH WEST ARROW
    "nwnear": "\u2927",  # NORTH WEST ARROW AND NORTH EAST ARROW
    "Oacute": "\xd3",  # LATIN CAPITAL LETTER O WITH ACUTE
    "oacute": "\xf3",  # LATIN SMALL LETTER O WITH ACUTE
    "oast": "\u229b",  # CIRCLED ASTERISK OPERATOR
    "ocir": "\u229a",  # CIRCLED RING OPERATOR
    "Ocirc": "\xd4",  # LATIN CAPITAL LETTER O WITH CIRCUMFLEX
    "ocirc": "\xf4",  # LATIN SMALL LETTER O WITH CIRCUMFLEX
    "Ocy": "\u041e",  # CYRILLIC CAPITAL LETTER O
    "ocy": "\u043e",  # CYRILLIC SMALL LETTER O
    "odash": "\u229d",  # CIRCLED DASH
    "Odblac": "\u0150",  # LATIN CAPITAL LETTER O WITH DOUBLE ACUTE
    "odblac": "\u0151",  # LATIN SMALL LETTER O WITH DOUBLE ACUTE
    "odiv": "\u2a38",  # CIRCLED DIVISION SIGN
    "odot": "\u2299",  # CIRCLED DOT OPERATOR
    "odsold": "\u29bc",  # CIRCLED ANTICLOCKWISE-ROTATED DIVISION SIGN
    "OElig": "\u0152",  # LATIN CAPITAL LIGATURE OE
    "oelig": "\u0153",  # LATIN SMALL LIGATURE OE
    "ofcir": "\u29bf",  # CIRCLED BULLET
    "Ofr": "\U0001d512",  # MATHEMATICAL FRAKTUR CAPITAL O
    "ofr": "\U0001d52c",  # MATHEMATICAL FRAKTUR SMALL O
    "ogon": "\u02db",  # OGONEK
    "Ograve": "\xd2",  # LATIN CAPITAL LETTER O WITH GRAVE
    "ograve": "\xf2",  # LATIN SMALL LETTER O WITH GRAVE
    "ogt": "\u29c1",  # CIRCLED GREATER-THAN
    "ohbar": "\u29b5",  # CIRCLE WITH HORIZONTAL BAR
    "ohm": "\u03a9",  # GREEK CAPITAL LETTER OMEGA
    "oint": "\u222e",  # CONTOUR INTEGRAL
    "olarr": "\u21ba",  # ANTICLOCKWISE OPEN CIRCLE ARROW
    "olcir": "\u29be",  # CIRCLED WHITE BULLET
    "olcross": "\u29bb",  # CIRCLE WITH SUPERIMPOSED X
    "oline": "\u203e",  # OVERLINE
    "olt": "\u29c0",  # CIRCLED LESS-THAN
    "Omacr": "\u014c",  # LATIN CAPITAL LETTER O WITH MACRON
    "omacr": "\u014d",  # LATIN SMALL LETTER O WITH MACRON
    "Omega": "\u03a9",  # GREEK CAPITAL LETTER OMEGA
    "omega": "\u03c9",  # GREEK SMALL LETTER OMEGA
    "Omicron": "\u039f",  # GREEK CAPITAL LETTER OMICRON
    "omicron": "\u03bf",  # GREEK SMALL LETTER OMICRON
    "omid": "\u29b6",  # CIRCLED VERTICAL BAR
    "ominus": "\u2296",  # CIRCLED MINUS
    "Oopf": "\U0001d546",  # MATHEMATICAL DOUBLE-STRUCK CAPITAL O
    "oopf": "\U0001d560",  # MATHEMATICAL DOUBLE-STRUCK SMALL O
    "opar": "\u29b7",  # CIRCLED PARALLEL
    "OpenCurlyDoubleQuote": "\u201c",  # LEFT DOUBLE QUOTATION MARK
    "OpenCurlyQuote": "\u2018",  # LEFT SINGLE QUOTATION MARK
    "operp": "\u29b9",  # CIRCLED PERPENDICULAR
    "oplus": "\u2295",  # CIRCLED PLUS
    "Or": "\u2a54",  # DOUBLE LOGICAL OR
    "or": "\u2228",  # LOGICAL OR
    "orarr": "\u21bb",  # CLOCKWISE OPEN CIRCLE ARROW
    "ord": "\u2a5d",  # LOGICAL OR WITH HORIZONTAL DASH
    "order": "\u2134",  # SCRIPT SMALL O
    "orderof": "\u2134",  # SCRIPT SMALL O
    "ordf": "\xaa",  # FEMININE ORDINAL INDICATOR
    "ordm": "\xba",  # MASCULINE ORDINAL INDICATOR
    "origof": "\u22b6",  # ORIGINAL OF
    "oror": "\u2a56",  # TWO INTERSECTING LOGICAL OR
    "orslope": "\u2a57",  # SLOPING LARGE OR
    "orv": "\u2a5b",  # LOGICAL OR WITH MIDDLE STEM
    "oS": "\u24c8",  # CIRCLED LATIN CAPITAL LETTER S
    "Oscr": "\U0001d4aa",  # MATHEMATICAL SCRIPT CAPITAL O
    "oscr": "\u2134",  # SCRIPT SMALL O
    "Oslash": "\xd8",  # LATIN CAPITAL LETTER O WITH STROKE
    "oslash": "\xf8",  # LATIN SMALL LETTER O WITH STROKE
    "osol": "\u2298",  # CIRCLED DIVISION SLASH
    "Otilde": "\xd5",  # LATIN CAPITAL LETTER O WITH TILDE
    "otilde": "\xf5",  # LATIN SMALL LETTER O WITH TILDE
    "Otimes": "\u2a37",  # MULTIPLICATION SIGN IN DOUBLE CIRCLE
    "otimes": "\u2297",  # CIRCLED TIMES
    "otimesas": "\u2a36",  # CIRCLED MULTIPLICATION SIGN WITH CIRCUMFLEX ACCENT
    "Ouml": "\xd6",  # LATIN CAPITAL LETTER O WITH DIAERESIS
    "ouml": "\xf6",  # LATIN SMALL LETTER O WITH DIAERESIS
    "ovbar": "\u233d",  # APL FUNCTIONAL SYMBOL CIRCLE STILE
    "OverBar": "\u203e",  # OVERLINE
    "OverBrace": "\u23de",  # TOP CURLY BRACKET
    "OverBracket": "\u23b4",  # TOP SQUARE BRACKET
    "OverParenthesis": "\u23dc",  # TOP PARENTHESIS
    "par": "\u2225",  # PARALLEL TO
    "para": "\xb6",  # PILCROW SIGN
    "parallel": "\u2225",  # PARALLEL TO
    "parsim": "\u2af3",  # PARALLEL WITH TILDE OPERATOR
    "parsl": "\u2afd",  # DOUBLE SOLIDUS OPERATOR
    "part": "\u2202",  # PARTIAL DIFFERENTIAL
    "PartialD": "\u2202",  # PARTIAL DIFFERENTIAL
    "Pcy": "\u041f",  # CYRILLIC CAPITAL LETTER PE
    "pcy": "\u043f",  # CYRILLIC SMALL LETTER PE
    "percnt": "%",  # PERCENT SIGN
    "period": ".",  # FULL STOP
    "permil": "\u2030",  # PER MILLE SIGN
    "perp": "\u22a5",  # UP TACK
    "pertenk": "\u2031",  # PER TEN THOUSAND SIGN
    "Pfr": "\U0001d513",  # MATHEMATICAL FRAKTUR CAPITAL P
    "pfr": "\U0001d52d",  # MATHEMATICAL FRAKTUR SMALL P
    "Phi": "\u03a6",  # GREEK CAPITAL LETTER PHI
    "phi": "\u03c6",  # GREEK SMALL LETTER PHI
    "phiv": "\u03d5",  # GREEK PHI SYMBOL
    "phmmat": "\u2133",  # SCRIPT CAPITAL M
    "phone": "\u260e",  # BLACK TELEPHONE
    "Pi": "\u03a0",  # GREEK CAPITAL LETTER PI
    "pi": "\u03c0",  # GREEK SMALL LETTER PI
    "pitchfork": "\u22d4",  # PITCHFORK
    "piv": "\u03d6",  # GREEK PI SYMBOL
    "planck": "\u210f",  # PLANCK CONSTANT OVER TWO PI
    "planckh": "\u210e",  # PLANCK CONSTANT
    "plankv": "\u210f",  # PLANCK CONSTANT OVER TWO PI
    "plus": "+",  # PLUS SIGN
    "plusacir": "\u2a23",  # PLUS SIGN WITH CIRCUMFLEX ACCENT ABOVE
    "plusb": "\u229e",  # SQUARED PLUS
    "pluscir": "\u2a22",  # PLUS SIGN WITH SMALL CIRCLE ABOVE
    "plusdo": "\u2214",  # DOT PLUS
    "plusdu": "\u2a25",  # PLUS SIGN WITH DOT BELOW
    "pluse": "\u2a72",  # PLUS SIGN ABOVE EQUALS SIGN
    "PlusMinus": "\xb1",  # PLUS-MINUS SIGN
    "plusmn": "\xb1",  # PLUS-MINUS SIGN
    "plussim": "\u2a26",  # PLUS SIGN WITH TILDE BELOW
    "plustwo": "\u2a27",  # PLUS SIGN WITH SUBSCRIPT TWO
    "pm": "\xb1",  # PLUS-MINUS SIGN
    "Poincareplane": "\u210c",  # BLACK-LETTER CAPITAL H
    "pointint": "\u2a15",  # INTEGRAL AROUND A POINT OPERATOR
    "Popf": "\u2119",  # DOUBLE-STRUCK CAPITAL P
    "popf": "\U0001d561",  # MATHEMATICAL DOUBLE-STRUCK SMALL P
    "pound": "\xa3",  # POUND SIGN
    "Pr": "\u2abb",  # DOUBLE PRECEDES
    "pr": "\u227a",  # PRECEDES
    "prap": "\u2ab7",  # PRECEDES ABOVE ALMOST EQUAL TO
    "prcue": "\u227c",  # PRECEDES OR EQUAL TO
    "prE": "\u2ab3",  # PRECEDES ABOVE EQUALS SIGN
    "pre": "\u2aaf",  # PRECEDES ABOVE SINGLE-LINE EQUALS SIGN
    "prec": "\u227a",  # PRECEDES
    "precapprox": "\u2ab7",  # PRECEDES ABOVE ALMOST EQUAL TO
    "preccurlyeq": "\u227c",  # PRECEDES OR EQUAL TO
    "Precedes": "\u227a",  # PRECEDES
    "PrecedesEqual": "\u2aaf",  # PRECEDES ABOVE SINGLE-LINE EQUALS SIGN
    "PrecedesSlantEqual": "\u227c",  # PRECEDES OR EQUAL TO
    "PrecedesTilde": "\u227e",  # PRECEDES OR EQUIVALENT TO
    "preceq": "\u2aaf",  # PRECEDES ABOVE SINGLE-LINE EQUALS SIGN
    "precnapprox": "\u2ab9",  # PRECEDES ABOVE NOT ALMOST EQUAL TO
    "precneqq": "\u2ab5",  # PRECEDES ABOVE NOT EQUAL TO
    "precnsim": "\u22e8",  # PRECEDES BUT NOT EQUIVALENT TO
    "precsim": "\u227e",  # PRECEDES OR EQUIVALENT TO
    "Prime": "\u2033",  # DOUBLE PRIME
    "prime": "\u2032",  # PRIME
    "primes": "\u2119",  # DOUBLE-STRUCK CAPITAL P
    "prnap": "\u2ab9",  # PRECEDES ABOVE NOT ALMOST EQUAL TO
    "prnE": "\u2ab5",  # PRECEDES ABOVE NOT EQUAL TO
    "prnsim": "\u22e8",  # PRECEDES BUT NOT EQUIVALENT TO
    "prod": "\u220f",  # N-ARY PRODUCT
    "Product": "\u220f",  # N-ARY PRODUCT
    "profalar": "\u232e",  # ALL AROUND-PROFILE
    "profline": "\u2312",  # ARC
    "profsurf": "\u2313",  # SEGMENT
    "prop": "\u221d",  # PROPORTIONAL TO
    "Proportion": "\u2237",  # PROPORTION
    "Proportional": "\u221d",  # PROPORTIONAL TO
    "propto": "\u221d",  # PROPORTIONAL TO
    "prsim": "\u227e",  # PRECEDES OR EQUIVALENT TO
    "prurel": "\u22b0",  # PRECEDES UNDER RELATION
    "Pscr": "\U0001d4ab",  # MATHEMATICAL SCRIPT CAPITAL P
    "pscr": "\U0001d4c5",  # MATHEMATICAL SCRIPT SMALL P
    "Psi": "\u03a8",  # GREEK CAPITAL LETTER PSI
    "psi": "\u03c8",  # GREEK SMALL LETTER PSI
    "puncsp": "\u2008",  # PUNCTUATION SPACE
    "Qfr": "\U0001d514",  # MATHEMATICAL FRAKTUR CAPITAL Q
    "qfr": "\U0001d52e",  # MATHEMATICAL FRAKTUR SMALL Q
    "qint": "\u2a0c",  # QUADRUPLE INTEGRAL OPERATOR
    "Qopf": "\u211a",  # DOUBLE-STRUCK CAPITAL Q
    "qopf": "\U0001d562",  # MATHEMATICAL DOUBLE-STRUCK SMALL Q
    "qprime": "\u2057",  # QUADRUPLE PRIME
    "Qscr": "\U0001d4ac",  # MATHEMATICAL SCRIPT CAPITAL Q
    "qscr": "\U0001d4c6",  # MATHEMATICAL SCRIPT SMALL Q
    "quaternions": "\u210d",  # DOUBLE-STRUCK CAPITAL H
    "quatint": "\u2a16",  # QUATERNION INTEGRAL OPERATOR
    "quest": "?",  # QUESTION MARK
    "questeq": "\u225f",  # QUESTIONED EQUAL TO
    "QUOT": '"',  # QUOTATION MARK
    "quot": '"',  # QUOTATION MARK
    "rAarr": "\u21db",  # RIGHTWARDS TRIPLE ARROW
    "race": "\u223d\u0331",  # REVERSED TILDE with underline
    "Racute": "\u0154",  # LATIN CAPITAL LETTER R WITH ACUTE
    "racute": "\u0155",  # LATIN SMALL LETTER R WITH ACUTE
    "radic": "\u221a",  # SQUARE ROOT
    "raemptyv": "\u29b3",  # EMPTY SET WITH RIGHT ARROW ABOVE
    "Rang": "\u27eb",  # MATHEMATICAL RIGHT DOUBLE ANGLE BRACKET
    "rang": "\u27e9",  # MATHEMATICAL RIGHT ANGLE BRACKET
    "rangd": "\u2992",  # RIGHT ANGLE BRACKET WITH DOT
    "range": "\u29a5",  # REVERSED ANGLE WITH UNDERBAR
    "rangle": "\u27e9",  # MATHEMATICAL RIGHT ANGLE BRACKET
    "raquo": "\xbb",  # RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
    "Rarr": "\u21a0",  # RIGHTWARDS TWO HEADED ARROW
    "rArr": "\u21d2",  # RIGHTWARDS DOUBLE ARROW
    "rarr": "\u2192",  # RIGHTWARDS ARROW
    "rarrap": "\u2975",  # RIGHTWARDS ARROW ABOVE ALMOST EQUAL TO
    "rarrb": "\u21e5",  # RIGHTWARDS ARROW TO BAR
    "rarrbfs": "\u2920",  # RIGHTWARDS ARROW FROM BAR TO BLACK DIAMOND
    "rarrc": "\u2933",  # WAVE ARROW POINTING DIRECTLY RIGHT
    "rarrfs": "\u291e",  # RIGHTWARDS ARROW TO BLACK DIAMOND
    "rarrhk": "\u21aa",  # RIGHTWARDS ARROW WITH HOOK
    "rarrlp": "\u21ac",  # RIGHTWARDS ARROW WITH LOOP
    "rarrpl": "\u2945",  # RIGHTWARDS ARROW WITH PLUS BELOW
    "rarrsim": "\u2974",  # RIGHTWARDS ARROW ABOVE TILDE OPERATOR
    "Rarrtl": "\u2916",  # RIGHTWARDS TWO-HEADED ARROW WITH TAIL
    "rarrtl": "\u21a3",  # RIGHTWARDS ARROW WITH TAIL
    "rarrw": "\u219d",  # RIGHTWARDS WAVE ARROW
    "rAtail": "\u291c",  # RIGHTWARDS DOUBLE ARROW-TAIL
    "ratail": "\u291a",  # RIGHTWARDS ARROW-TAIL
    "ratio": "\u2236",  # RATIO
    "rationals": "\u211a",  # DOUBLE-STRUCK CAPITAL Q
    "RBarr": "\u2910",  # RIGHTWARDS TWO-HEADED TRIPLE DASH ARROW
    "rBarr": "\u290f",  # RIGHTWARDS TRIPLE DASH ARROW
    "rbarr": "\u290d",  # RIGHTWARDS DOUBLE DASH ARROW
    "rbbrk": "\u2773",  # LIGHT RIGHT TORTOISE SHELL BRACKET ORNAMENT
    "rbrace": "}",  # RIGHT CURLY BRACKET
    "rbrack": "]",  # RIGHT SQUARE BRACKET
    "rbrke": "\u298c",  # RIGHT SQUARE BRACKET WITH UNDERBAR
    "rbrksld": "\u298e",  # RIGHT SQUARE BRACKET WITH TICK IN BOTTOM CORNER
    "rbrkslu": "\u2990",  # RIGHT SQUARE BRACKET WITH TICK IN TOP CORNER
    "Rcaron": "\u0158",  # LATIN CAPITAL LETTER R WITH CARON
    "rcaron": "\u0159",  # LATIN SMALL LETTER R WITH CARON
    "Rcedil": "\u0156",  # LATIN CAPITAL LETTER R WITH CEDILLA
    "rcedil": "\u0157",  # LATIN SMALL LETTER R WITH CEDILLA
    "rceil": "\u2309",  # RIGHT CEILING
    "rcub": "}",  # RIGHT CURLY BRACKET
    "Rcy": "\u0420",  # CYRILLIC CAPITAL LETTER ER
    "rcy": "\u0440",  # CYRILLIC SMALL LETTER ER
    "rdca": "\u2937",  # ARROW POINTING DOWNWARDS THEN CURVING RIGHTWARDS
    "rdldhar": "\u2969",  # RIGHTWARDS HARPOON WITH BARB DOWN ABOVE LEFTWARDS HARPOON WITH BARB DOWN
    "rdquo": "\u201d",  # RIGHT DOUBLE QUOTATION MARK
    "rdquor": "\u201d",  # RIGHT DOUBLE QUOTATION MARK
    "rdsh": "\u21b3",  # DOWNWARDS ARROW WITH TIP RIGHTWARDS
    "Re": "\u211c",  # BLACK-LETTER CAPITAL R
    "real": "\u211c",  # BLACK-LETTER CAPITAL R
    "realine": "\u211b",  # SCRIPT CAPITAL R
    "realpart": "\u211c",  # BLACK-LETTER CAPITAL R
    "reals": "\u211d",  # DOUBLE-STRUCK CAPITAL R
    "rect": "\u25ad",  # WHITE RECTANGLE
    "REG": "\xae",  # REGISTERED SIGN
    "reg": "\xae",  # REGISTERED SIGN
    "ReverseElement": "\u220b",  # CONTAINS AS MEMBER
    "ReverseEquilibrium": "\u21cb",  # LEFTWARDS HARPOON OVER RIGHTWARDS HARPOON
    "ReverseUpEquilibrium": "\u296f",  # DOWNWARDS HARPOON WITH BARB LEFT BESIDE UPWARDS HARPOON WITH BARB RIGHT
    "rfisht": "\u297d",  # RIGHT FISH TAIL
    "rfloor": "\u230b",  # RIGHT FLOOR
    "Rfr": "\u211c",  # BLACK-LETTER CAPITAL R
    "rfr": "\U0001d52f",  # MATHEMATICAL FRAKTUR SMALL R
    "rHar": "\u2964",  # RIGHTWARDS HARPOON WITH BARB UP ABOVE RIGHTWARDS HARPOON WITH BARB DOWN
    "rhard": "\u21c1",  # RIGHTWARDS HARPOON WITH BARB DOWNWARDS
    "rharu": "\u21c0",  # RIGHTWARDS HARPOON WITH BARB UPWARDS
    "rharul": "\u296c",  # RIGHTWARDS HARPOON WITH BARB UP ABOVE LONG DASH
    "Rho": "\u03a1",  # GREEK CAPITAL LETTER RHO
    "rho": "\u03c1",  # GREEK SMALL LETTER RHO
    "rhov": "\u03f1",  # GREEK RHO SYMBOL
    "RightAngleBracket": "\u27e9",  # MATHEMATICAL RIGHT ANGLE BRACKET
    "RightArrow": "\u2192",  # RIGHTWARDS ARROW
    "Rightarrow": "\u21d2",  # RIGHTWARDS DOUBLE ARROW
    "rightarrow": "\u2192",  # RIGHTWARDS ARROW
    "RightArrowBar": "\u21e5",  # RIGHTWARDS ARROW TO BAR
    "RightArrowLeftArrow": "\u21c4",  # RIGHTWARDS ARROW OVER LEFTWARDS ARROW
    "rightarrowtail": "\u21a3",  # RIGHTWARDS ARROW WITH TAIL
    "RightCeiling": "\u2309",  # RIGHT CEILING
    "RightDoubleBracket": "\u27e7",  # MATHEMATICAL RIGHT WHITE SQUARE BRACKET
    "RightDownTeeVector": "\u295d",  # DOWNWARDS HARPOON WITH BARB RIGHT FROM BAR
    "RightDownVector": "\u21c2",  # DOWNWARDS HARPOON WITH BARB RIGHTWARDS
    "RightDownVectorBar": "\u2955",  # DOWNWARDS HARPOON WITH BARB RIGHT TO BAR
    "RightFloor": "\u230b",  # RIGHT FLOOR
    "rightharpoondown": "\u21c1",  # RIGHTWARDS HARPOON WITH BARB DOWNWARDS
    "rightharpoonup": "\u21c0",  # RIGHTWARDS HARPOON WITH BARB UPWARDS
    "rightleftarrows": "\u21c4",  # RIGHTWARDS ARROW OVER LEFTWARDS ARROW
    "rightleftharpoons": "\u21cc",  # RIGHTWARDS HARPOON OVER LEFTWARDS HARPOON
    "rightrightarrows": "\u21c9",  # RIGHTWARDS PAIRED ARROWS
    "rightsquigarrow": "\u219d",  # RIGHTWARDS WAVE ARROW
    "RightTee": "\u22a2",  # RIGHT TACK
    "RightTeeArrow": "\u21a6",  # RIGHTWARDS ARROW FROM BAR
    "RightTeeVector": "\u295b",  # RIGHTWARDS HARPOON WITH BARB UP FROM BAR
    "rightthreetimes": "\u22cc",  # RIGHT SEMIDIRECT PRODUCT
    "RightTriangle": "\u22b3",  # CONTAINS AS NORMAL SUBGROUP
    "RightTriangleBar": "\u29d0",  # VERTICAL BAR BESIDE RIGHT TRIANGLE
    "RightTriangleEqual": "\u22b5",  # CONTAINS AS NORMAL SUBGROUP OR EQUAL TO
    "RightUpDownVector": "\u294f",  # UP BARB RIGHT DOWN BARB RIGHT HARPOON
    "RightUpTeeVector": "\u295c",  # UPWARDS HARPOON WITH BARB RIGHT FROM BAR
    "RightUpVector": "\u21be",  # UPWARDS HARPOON WITH BARB RIGHTWARDS
    "RightUpVectorBar": "\u2954",  # UPWARDS HARPOON WITH BARB RIGHT TO BAR
    "RightVector": "\u21c0",  # RIGHTWARDS HARPOON WITH BARB UPWARDS
    "RightVectorBar": "\u2953",  # RIGHTWARDS HARPOON WITH BARB UP TO BAR
    "ring": "\u02da",  # RING ABOVE
    "risingdotseq": "\u2253",  # IMAGE OF OR APPROXIMATELY EQUAL TO
    "rlarr": "\u21c4",  # RIGHTWARDS ARROW OVER LEFTWARDS ARROW
    "rlhar": "\u21cc",  # RIGHTWARDS HARPOON OVER LEFTWARDS HARPOON
    "rlm": "\u200f",  # RIGHT-TO-LEFT MARK
    "rmoust": "\u23b1",  # UPPER RIGHT OR LOWER LEFT CURLY BRACKET SECTION
    "rmoustache": "\u23b1",  # UPPER RIGHT OR LOWER LEFT CURLY BRACKET SECTION
    "rnmid": "\u2aee",  # DOES NOT DIVIDE WITH REVERSED NEGATION SLASH
    "roang": "\u27ed",  # MATHEMATICAL RIGHT WHITE TORTOISE SHELL BRACKET
    "roarr": "\u21fe",  # RIGHTWARDS OPEN-HEADED ARROW
    "robrk": "\u27e7",  # MATHEMATICAL RIGHT WHITE SQUARE BRACKET
    "ropar": "\u2986",  # RIGHT WHITE PARENTHESIS
    "Ropf": "\u211d",  # DOUBLE-STRUCK CAPITAL R
    "ropf": "\U0001d563",  # MATHEMATICAL DOUBLE-STRUCK SMALL R
    "roplus": "\u2a2e",  # PLUS SIGN IN RIGHT HALF CIRCLE
    "rotimes": "\u2a35",  # MULTIPLICATION SIGN IN RIGHT HALF CIRCLE
    "RoundImplies": "\u2970",  # RIGHT DOUBLE ARROW WITH ROUNDED HEAD
    "rpar": ")",  # RIGHT PARENTHESIS
    "rpargt": "\u2994",  # RIGHT ARC GREATER-THAN BRACKET
    "rppolint": "\u2a12",  # LINE INTEGRATION WITH RECTANGULAR PATH AROUND POLE
    "rrarr": "\u21c9",  # RIGHTWARDS PAIRED ARROWS
    "Rrightarrow": "\u21db",  # RIGHTWARDS TRIPLE ARROW
    "rsaquo": "\u203a",  # SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
    "Rscr": "\u211b",  # SCRIPT CAPITAL R
    "rscr": "\U0001d4c7",  # MATHEMATICAL SCRIPT SMALL R
    "Rsh": "\u21b1",  # UPWARDS ARROW WITH TIP RIGHTWARDS
    "rsh": "\u21b1",  # UPWARDS ARROW WITH TIP RIGHTWARDS
    "rsqb": "]",  # RIGHT SQUARE BRACKET
    "rsquo": "\u2019",  # RIGHT SINGLE QUOTATION MARK
    "rsquor": "\u2019",  # RIGHT SINGLE QUOTATION MARK
    "rthree": "\u22cc",  # RIGHT SEMIDIRECT PRODUCT
    "rtimes": "\u22ca",  # RIGHT NORMAL FACTOR SEMIDIRECT PRODUCT
    "rtri": "\u25b9",  # WHITE RIGHT-POINTING SMALL TRIANGLE
    "rtrie": "\u22b5",  # CONTAINS AS NORMAL SUBGROUP OR EQUAL TO
    "rtrif": "\u25b8",  # BLACK RIGHT-POINTING SMALL TRIANGLE
    "rtriltri": "\u29ce",  # RIGHT TRIANGLE ABOVE LEFT TRIANGLE
    "RuleDelayed": "\u29f4",  # RULE-DELAYED
    "ruluhar": "\u2968",  # RIGHTWARDS HARPOON WITH BARB UP ABOVE LEFTWARDS HARPOON WITH BARB UP
    "rx": "\u211e",  # PRESCRIPTION TAKE
    "Sacute": "\u015a",  # LATIN CAPITAL LETTER S WITH ACUTE
    "sacute": "\u015b",  # LATIN SMALL LETTER S WITH ACUTE
    "sbquo": "\u201a",  # SINGLE LOW-9 QUOTATION MARK
    "Sc": "\u2abc",  # DOUBLE SUCCEEDS
    "sc": "\u227b",  # SUCCEEDS
    "scap": "\u2ab8",  # SUCCEEDS ABOVE ALMOST EQUAL TO
    "Scaron": "\u0160",  # LATIN CAPITAL LETTER S WITH CARON
    "scaron": "\u0161",  # LATIN SMALL LETTER S WITH CARON
    "sccue": "\u227d",  # SUCCEEDS OR EQUAL TO
    "scE": "\u2ab4",  # SUCCEEDS ABOVE EQUALS SIGN
    "sce": "\u2ab0",  # SUCCEEDS ABOVE SINGLE-LINE EQUALS SIGN
    "Scedil": "\u015e",  # LATIN CAPITAL LETTER S WITH CEDILLA
    "scedil": "\u015f",  # LATIN SMALL LETTER S WITH CEDILLA
    "Scirc": "\u015c",  # LATIN CAPITAL LETTER S WITH CIRCUMFLEX
    "scirc": "\u015d",  # LATIN SMALL LETTER S WITH CIRCUMFLEX
    "scnap": "\u2aba",  # SUCCEEDS ABOVE NOT ALMOST EQUAL TO
    "scnE": "\u2ab6",  # SUCCEEDS ABOVE NOT EQUAL TO
    "scnsim": "\u22e9",  # SUCCEEDS BUT NOT EQUIVALENT TO
    "scpolint": "\u2a13",  # LINE INTEGRATION WITH SEMICIRCULAR PATH AROUND POLE
    "scsim": "\u227f",  # SUCCEEDS OR EQUIVALENT TO
    "Scy": "\u0421",  # CYRILLIC CAPITAL LETTER ES
    "scy": "\u0441",  # CYRILLIC SMALL LETTER ES
    "sdot": "\u22c5",  # DOT OPERATOR
    "sdotb": "\u22a1",  # SQUARED DOT OPERATOR
    "sdote": "\u2a66",  # EQUALS SIGN WITH DOT BELOW
    "searhk": "\u2925",  # SOUTH EAST ARROW WITH HOOK
    "seArr": "\u21d8",  # SOUTH EAST DOUBLE ARROW
    "searr": "\u2198",  # SOUTH EAST ARROW
    "searrow": "\u2198",  # SOUTH EAST ARROW
    "sect": "\xa7",  # SECTION SIGN
    "semi": ";",  # SEMICOLON
    "seswar": "\u2929",  # SOUTH EAST ARROW AND SOUTH WEST ARROW
    "setminus": "\u2216",  # SET MINUS
    "setmn": "\u2216",  # SET MINUS
    "sext": "\u2736",  # SIX POINTED BLACK STAR
    "Sfr": "\U0001d516",  # MATHEMATICAL FRAKTUR CAPITAL S
    "sfr": "\U0001d530",  # MATHEMATICAL FRAKTUR SMALL S
    "sfrown": "\u2322",  # FROWN
    "sharp": "\u266f",  # MUSIC SHARP SIGN
    "SHCHcy": "\u0429",  # CYRILLIC CAPITAL LETTER SHCHA
    "shchcy": "\u0449",  # CYRILLIC SMALL LETTER SHCHA
    "SHcy": "\u0428",  # CYRILLIC CAPITAL LETTER SHA
    "shcy": "\u0448",  # CYRILLIC SMALL LETTER SHA
    "ShortDownArrow": "\u2193",  # DOWNWARDS ARROW
    "ShortLeftArrow": "\u2190",  # LEFTWARDS ARROW
    "shortmid": "\u2223",  # DIVIDES
    "shortparallel": "\u2225",  # PARALLEL TO
    "ShortRightArrow": "\u2192",  # RIGHTWARDS ARROW
    "ShortUpArrow": "\u2191",  # UPWARDS ARROW
    "shy": "\xad",  # SOFT HYPHEN
    "Sigma": "\u03a3",  # GREEK CAPITAL LETTER SIGMA
    "sigma": "\u03c3",  # GREEK SMALL LETTER SIGMA
    "sigmaf": "\u03c2",  # GREEK SMALL LETTER FINAL SIGMA
    "sigmav": "\u03c2",  # GREEK SMALL LETTER FINAL SIGMA
    "sim": "\u223c",  # TILDE OPERATOR
    "simdot": "\u2a6a",  # TILDE OPERATOR WITH DOT ABOVE
    "sime": "\u2243",  # ASYMPTOTICALLY EQUAL TO
    "simeq": "\u2243",  # ASYMPTOTICALLY EQUAL TO
    "simg": "\u2a9e",  # SIMILAR OR GREATER-THAN
    "simgE": "\u2aa0",  # SIMILAR ABOVE GREATER-THAN ABOVE EQUALS SIGN
    "siml": "\u2a9d",  # SIMILAR OR LESS-THAN
    "simlE": "\u2a9f",  # SIMILAR ABOVE LESS-THAN ABOVE EQUALS SIGN
    "simne": "\u2246",  # APPROXIMATELY BUT NOT ACTUALLY EQUAL TO
    "simplus": "\u2a24",  # PLUS SIGN WITH TILDE ABOVE
    "simrarr": "\u2972",  # TILDE OPERATOR ABOVE RIGHTWARDS ARROW
    "slarr": "\u2190",  # LEFTWARDS ARROW
    "SmallCircle": "\u2218",  # RING OPERATOR
    "smallsetminus": "\u2216",  # SET MINUS
    "smashp": "\u2a33",  # SMASH PRODUCT
    "smeparsl": "\u29e4",  # EQUALS SIGN AND SLANTED PARALLEL WITH TILDE ABOVE
    "smid": "\u2223",  # DIVIDES
    "smile": "\u2323",  # SMILE
    "smt": "\u2aaa",  # SMALLER THAN
    "smte": "\u2aac",  # SMALLER THAN OR EQUAL TO
    "smtes": "\u2aac\ufe00",  # SMALLER THAN OR slanted EQUAL
    "SOFTcy": "\u042c",  # CYRILLIC CAPITAL LETTER SOFT SIGN
    "softcy": "\u044c",  # CYRILLIC SMALL LETTER SOFT SIGN
    "sol": "/",  # SOLIDUS
    "solb": "\u29c4",  # SQUARED RISING DIAGONAL SLASH
    "solbar": "\u233f",  # APL FUNCTIONAL SYMBOL SLASH BAR
    "Sopf": "\U0001d54a",  # MATHEMATICAL DOUBLE-STRUCK CAPITAL S
    "sopf": "\U0001d564",  # MATHEMATICAL DOUBLE-STRUCK SMALL S
    "spades": "\u2660",  # BLACK SPADE SUIT
    "spadesuit": "\u2660",  # BLACK SPADE SUIT
    "spar": "\u2225",  # PARALLEL TO
    "sqcap": "\u2293",  # SQUARE CAP
    "sqcaps": "\u2293\ufe00",  # SQUARE CAP with serifs
    "sqcup": "\u2294",  # SQUARE CUP
    "sqcups": "\u2294\ufe00",  # SQUARE CUP with serifs
    "Sqrt": "\u221a",  # SQUARE ROOT
    "sqsub": "\u228f",  # SQUARE IMAGE OF
    "sqsube": "\u2291",  # SQUARE IMAGE OF OR EQUAL TO
    "sqsubset": "\u228f",  # SQUARE IMAGE OF
    "sqsubseteq": "\u2291",  # SQUARE IMAGE OF OR EQUAL TO
    "sqsup": "\u2290",  # SQUARE ORIGINAL OF
    "sqsupe": "\u2292",  # SQUARE ORIGINAL OF OR EQUAL TO
    "sqsupset": "\u2290",  # SQUARE ORIGINAL OF
    "sqsupseteq": "\u2292",  # SQUARE ORIGINAL OF OR EQUAL TO
    "squ": "\u25a1",  # WHITE SQUARE
    "Square": "\u25a1",  # WHITE SQUARE
    "square": "\u25a1",  # WHITE SQUARE
    "SquareIntersection": "\u2293",  # SQUARE CAP
    "SquareSubset": "\u228f",  # SQUARE IMAGE OF
    "SquareSubsetEqual": "\u2291",  # SQUARE IMAGE OF OR EQUAL TO
    "SquareSuperset": "\u2290",  # SQUARE ORIGINAL OF
    "SquareSupersetEqual": "\u2292",  # SQUARE ORIGINAL OF OR EQUAL TO
    "SquareUnion": "\u2294",  # SQUARE CUP
    "squarf": "\u25aa",  # BLACK SMALL SQUARE
    "squf": "\u25aa",  # BLACK SMALL SQUARE
    "srarr": "\u2192",  # RIGHTWARDS ARROW
    "Sscr": "\U0001d4ae",  # MATHEMATICAL SCRIPT CAPITAL S
    "sscr": "\U0001d4c8",  # MATHEMATICAL SCRIPT SMALL S
    "ssetmn": "\u2216",  # SET MINUS
    "ssmile": "\u2323",  # SMILE
    "sstarf": "\u22c6",  # STAR OPERATOR
    "Star": "\u22c6",  # STAR OPERATOR
    "star": "\u2606",  # WHITE STAR
    "starf": "\u2605",  # BLACK STAR
    "straightepsilon": "\u03f5",  # GREEK LUNATE EPSILON SYMBOL
    "straightphi": "\u03d5",  # GREEK PHI SYMBOL
    "strns": "\xaf",  # MACRON
    "Sub": "\u22d0",  # DOUBLE SUBSET
    "sub": "\u2282",  # SUBSET OF
    "subdot": "\u2abd",  # SUBSET WITH DOT
    "subE": "\u2ac5",  # SUBSET OF ABOVE EQUALS SIGN
    "sube": "\u2286",  # SUBSET OF OR EQUAL TO
    "subedot": "\u2ac3",  # SUBSET OF OR EQUAL TO WITH DOT ABOVE
    "submult": "\u2ac1",  # SUBSET WITH MULTIPLICATION SIGN BELOW
    "subnE": "\u2acb",  # SUBSET OF ABOVE NOT EQUAL TO
    "subne": "\u228a",  # SUBSET OF WITH NOT EQUAL TO
    "subplus": "\u2abf",  # SUBSET WITH PLUS SIGN BELOW
    "subrarr": "\u2979",  # SUBSET ABOVE RIGHTWARDS ARROW
    "Subset": "\u22d0",  # DOUBLE SUBSET
    "subset": "\u2282",  # SUBSET OF
    "subseteq": "\u2286",  # SUBSET OF OR EQUAL TO
    "subseteqq": "\u2ac5",  # SUBSET OF ABOVE EQUALS SIGN
    "SubsetEqual": "\u2286",  # SUBSET OF OR EQUAL TO
    "subsetneq": "\u228a",  # SUBSET OF WITH NOT EQUAL TO
    "subsetneqq": "\u2acb",  # SUBSET OF ABOVE NOT EQUAL TO
    "subsim": "\u2ac7",  # SUBSET OF ABOVE TILDE OPERATOR
    "subsub": "\u2ad5",  # SUBSET ABOVE SUBSET
    "subsup": "\u2ad3",  # SUBSET ABOVE SUPERSET
    "succ": "\u227b",  # SUCCEEDS
    "succapprox": "\u2ab8",  # SUCCEEDS ABOVE ALMOST EQUAL TO
    "succcurlyeq": "\u227d",  # SUCCEEDS OR EQUAL TO
    "Succeeds": "\u227b",  # SUCCEEDS
    "SucceedsEqual": "\u2ab0",  # SUCCEEDS ABOVE SINGLE-LINE EQUALS SIGN
    "SucceedsSlantEqual": "\u227d",  # SUCCEEDS OR EQUAL TO
    "SucceedsTilde": "\u227f",  # SUCCEEDS OR EQUIVALENT TO
    "succeq": "\u2ab0",  # SUCCEEDS ABOVE SINGLE-LINE EQUALS SIGN
    "succnapprox": "\u2aba",  # SUCCEEDS ABOVE NOT ALMOST EQUAL TO
    "succneqq": "\u2ab6",  # SUCCEEDS ABOVE NOT EQUAL TO
    "succnsim": "\u22e9",  # SUCCEEDS BUT NOT EQUIVALENT TO
    "succsim": "\u227f",  # SUCCEEDS OR EQUIVALENT TO
    "SuchThat": "\u220b",  # CONTAINS AS MEMBER
    "Sum": "\u2211",  # N-ARY SUMMATION
    "sum": "\u2211",  # N-ARY SUMMATION
    "sung": "\u266a",  # EIGHTH NOTE
    "Sup": "\u22d1",  # DOUBLE SUPERSET
    "sup": "\u2283",  # SUPERSET OF
    "sup1": "\xb9",  # SUPERSCRIPT ONE
    "sup2": "\xb2",  # SUPERSCRIPT TWO
    "sup3": "\xb3",  # SUPERSCRIPT THREE
    "supdot": "\u2abe",  # SUPERSET WITH DOT
    "supdsub": "\u2ad8",  # SUPERSET BESIDE AND JOINED BY DASH WITH SUBSET
    "supE": "\u2ac6",  # SUPERSET OF ABOVE EQUALS SIGN
    "supe": "\u2287",  # SUPERSET OF OR EQUAL TO
    "supedot": "\u2ac4",  # SUPERSET OF OR EQUAL TO WITH DOT ABOVE
    "Superset": "\u2283",  # SUPERSET OF
    "SupersetEqual": "\u2287",  # SUPERSET OF OR EQUAL TO
    "suphsol": "\u27c9",  # SUPERSET PRECEDING SOLIDUS
    "suphsub": "\u2ad7",  # SUPERSET BESIDE SUBSET
    "suplarr": "\u297b",  # SUPERSET ABOVE LEFTWARDS ARROW
    "supmult": "\u2ac2",  # SUPERSET WITH MULTIPLICATION SIGN BELOW
    "supnE": "\u2acc",  # SUPERSET OF ABOVE NOT EQUAL TO
    "supne": "\u228b",  # SUPERSET OF WITH NOT EQUAL TO
    "supplus": "\u2ac0",  # SUPERSET WITH PLUS SIGN BELOW
    "Supset": "\u22d1",  # DOUBLE SUPERSET
    "supset": "\u2283",  # SUPERSET OF
    "supseteq": "\u2287",  # SUPERSET OF OR EQUAL TO
    "supseteqq": "\u2ac6",  # SUPERSET OF ABOVE EQUALS SIGN
    "supsetneq": "\u228b",  # SUPERSET OF WITH NOT EQUAL TO
    "supsetneqq": "\u2acc",  # SUPERSET OF ABOVE NOT EQUAL TO
    "supsim": "\u2ac8",  # SUPERSET OF ABOVE TILDE OPERATOR
    "supsub": "\u2ad4",  # SUPERSET ABOVE SUBSET
    "supsup": "\u2ad6",  # SUPERSET ABOVE SUPERSET
    "swarhk": "\u2926",  # SOUTH WEST ARROW WITH HOOK
    "swArr": "\u21d9",  # SOUTH WEST DOUBLE ARROW
    "swarr": "\u2199",  # SOUTH WEST ARROW
    "swarrow": "\u2199",  # SOUTH WEST ARROW
    "swnwar": "\u292a",  # SOUTH WEST ARROW AND NORTH WEST ARROW
    "szlig": "\xdf",  # LATIN SMALL LETTER SHARP S
    "Tab": "\t",  # CHARACTER TABULATION
    "target": "\u2316",  # POSITION INDICATOR
    "Tau": "\u03a4",  # GREEK CAPITAL LETTER TAU
    "tau": "\u03c4",  # GREEK SMALL LETTER TAU
    "tbrk": "\u23b4",  # TOP SQUARE BRACKET
    "Tcaron": "\u0164",  # LATIN CAPITAL LETTER T WITH CARON
    "tcaron": "\u0165",  # LATIN SMALL LETTER T WITH CARON
    "Tcedil": "\u0162",  # LATIN CAPITAL LETTER T WITH CEDILLA
    "tcedil": "\u0163",  # LATIN SMALL LETTER T WITH CEDILLA
    "Tcy": "\u0422",  # CYRILLIC CAPITAL LETTER TE
    "tcy": "\u0442",  # CYRILLIC SMALL LETTER TE
    "telrec": "\u2315",  # TELEPHONE RECORDER
    "Tfr": "\U0001d517",  # MATHEMATICAL FRAKTUR CAPITAL T
    "tfr": "\U0001d531",  # MATHEMATICAL FRAKTUR SMALL T
    "there4": "\u2234",  # THEREFORE
    "Therefore": "\u2234",  # THEREFORE
    "therefore": "\u2234",  # THEREFORE
    "Theta": "\u0398",  # GREEK CAPITAL LETTER THETA
    "theta": "\u03b8",  # GREEK SMALL LETTER THETA
    "thetasym": "\u03d1",  # GREEK THETA SYMBOL
    "thetav": "\u03d1",  # GREEK THETA SYMBOL
    "thickapprox": "\u2248",  # ALMOST EQUAL TO
    "thicksim": "\u223c",  # TILDE OPERATOR
    "ThickSpace": "\u205f\u200a",  # space of width 5/18 em
    "thinsp": "\u2009",  # THIN SPACE
    "ThinSpace": "\u2009",  # THIN SPACE
    "thkap": "\u2248",  # ALMOST EQUAL TO
    "thksim": "\u223c",  # TILDE OPERATOR
    "THORN": "\xde",  # LATIN CAPITAL LETTER THORN
    "thorn": "\xfe",  # LATIN SMALL LETTER THORN
    "Tilde": "\u223c",  # TILDE OPERATOR
    "tilde": "\u02dc",  # SMALL TILDE
    "TildeEqual": "\u2243",  # ASYMPTOTICALLY EQUAL TO
    "TildeFullEqual": "\u2245",  # APPROXIMATELY EQUAL TO
    "TildeTilde": "\u2248",  # ALMOST EQUAL TO
    "times": "\xd7",  # MULTIPLICATION SIGN
    "timesb": "\u22a0",  # SQUARED TIMES
    "timesbar": "\u2a31",  # MULTIPLICATION SIGN WITH UNDERBAR
    "timesd": "\u2a30",  # MULTIPLICATION SIGN WITH DOT ABOVE
    "tint": "\u222d",  # TRIPLE INTEGRAL
    "toea": "\u2928",  # NORTH EAST ARROW AND SOUTH EAST ARROW
    "top": "\u22a4",  # DOWN TACK
    "topbot": "\u2336",  # APL FUNCTIONAL SYMBOL I-BEAM
    "topcir": "\u2af1",  # DOWN TACK WITH CIRCLE BELOW
    "Topf": "\U0001d54b",  # MATHEMATICAL DOUBLE-STRUCK CAPITAL T
    "topf": "\U0001d565",  # MATHEMATICAL DOUBLE-STRUCK SMALL T
    "topfork": "\u2ada",  # PITCHFORK WITH TEE TOP
    "tosa": "\u2929",  # SOUTH EAST ARROW AND SOUTH WEST ARROW
    "tprime": "\u2034",  # TRIPLE PRIME
    "TRADE": "\u2122",  # TRADE MARK SIGN
    "trade": "\u2122",  # TRADE MARK SIGN
    "triangle": "\u25b5",  # WHITE UP-POINTING SMALL TRIANGLE
    "triangledown": "\u25bf",  # WHITE DOWN-POINTING SMALL TRIANGLE
    "triangleleft": "\u25c3",  # WHITE LEFT-POINTING SMALL TRIANGLE
    "trianglelefteq": "\u22b4",  # NORMAL SUBGROUP OF OR EQUAL TO
    "triangleq": "\u225c",  # DELTA EQUAL TO
    "triangleright": "\u25b9",  # WHITE RIGHT-POINTING SMALL TRIANGLE
    "trianglerighteq": "\u22b5",  # CONTAINS AS NORMAL SUBGROUP OR EQUAL TO
    "tridot": "\u25ec",  # WHITE UP-POINTING TRIANGLE WITH DOT
    "trie": "\u225c",  # DELTA EQUAL TO
    "triminus": "\u2a3a",  # MINUS SIGN IN TRIANGLE
    "triplus": "\u2a39",  # PLUS SIGN IN TRIANGLE
    "trisb": "\u29cd",  # TRIANGLE WITH SERIFS AT BOTTOM
    "tritime": "\u2a3b",  # MULTIPLICATION SIGN IN TRIANGLE
    "trpezium": "\u23e2",  # WHITE TRAPEZIUM
    "Tscr": "\U0001d4af",  # MATHEMATICAL SCRIPT CAPITAL T
    "tscr": "\U0001d4c9",  # MATHEMATICAL SCRIPT SMALL T
    "TScy": "\u0426",  # CYRILLIC CAPITAL LETTER TSE
    "tscy": "\u0446",  # CYRILLIC SMALL LETTER TSE
    "TSHcy": "\u040b",  # CYRILLIC CAPITAL LETTER TSHE
    "tshcy": "\u045b",  # CYRILLIC SMALL LETTER TSHE
    "Tstrok": "\u0166",  # LATIN CAPITAL LETTER T WITH STROKE
    "tstrok": "\u0167",  # LATIN SMALL LETTER T WITH STROKE
    "twixt": "\u226c",  # BETWEEN
    "twoheadleftarrow": "\u219e",  # LEFTWARDS TWO HEADED ARROW
    "twoheadrightarrow": "\u21a0",  # RIGHTWARDS TWO HEADED ARROW
    "Uacute": "\xda",  # LATIN CAPITAL LETTER U WITH ACUTE
    "uacute": "\xfa",  # LATIN SMALL LETTER U WITH ACUTE
    "Uarr": "\u219f",  # UPWARDS TWO HEADED ARROW
    "uArr": "\u21d1",  # UPWARDS DOUBLE ARROW
    "uarr": "\u2191",  # UPWARDS ARROW
    "Uarrocir": "\u2949",  # UPWARDS TWO-HEADED ARROW FROM SMALL CIRCLE
    "Ubrcy": "\u040e",  # CYRILLIC CAPITAL LETTER SHORT U
    "ubrcy": "\u045e",  # CYRILLIC SMALL LETTER SHORT U
    "Ubreve": "\u016c",  # LATIN CAPITAL LETTER U WITH BREVE
    "ubreve": "\u016d",  # LATIN SMALL LETTER U WITH BREVE
    "Ucirc": "\xdb",  # LATIN CAPITAL LETTER U WITH CIRCUMFLEX
    "ucirc": "\xfb",  # LATIN SMALL LETTER U WITH CIRCUMFLEX
    "Ucy": "\u0423",  # CYRILLIC CAPITAL LETTER U
    "ucy": "\u0443",  # CYRILLIC SMALL LETTER U
    "udarr": "\u21c5",  # UPWARDS ARROW LEFTWARDS OF DOWNWARDS ARROW
    "Udblac": "\u0170",  # LATIN CAPITAL LETTER U WITH DOUBLE ACUTE
    "udblac": "\u0171",  # LATIN SMALL LETTER U WITH DOUBLE ACUTE
    "udhar": "\u296e",  # UPWARDS HARPOON WITH BARB LEFT BESIDE DOWNWARDS HARPOON WITH BARB RIGHT
    "ufisht": "\u297e",  # UP FISH TAIL
    "Ufr": "\U0001d518",  # MATHEMATICAL FRAKTUR CAPITAL U
    "ufr": "\U0001d532",  # MATHEMATICAL FRAKTUR SMALL U
    "Ugrave": "\xd9",  # LATIN CAPITAL LETTER U WITH GRAVE
    "ugrave": "\xf9",  # LATIN SMALL LETTER U WITH GRAVE
    "uHar": "\u2963",  # UPWARDS HARPOON WITH BARB LEFT BESIDE UPWARDS HARPOON WITH BARB RIGHT
    "uharl": "\u21bf",  # UPWARDS HARPOON WITH BARB LEFTWARDS
    "uharr": "\u21be",  # UPWARDS HARPOON WITH BARB RIGHTWARDS
    "uhblk": "\u2580",  # UPPER HALF BLOCK
    "ulcorn": "\u231c",  # TOP LEFT CORNER
    "ulcorner": "\u231c",  # TOP LEFT CORNER
    "ulcrop": "\u230f",  # TOP LEFT CROP
    "ultri": "\u25f8",  # UPPER LEFT TRIANGLE
    "Umacr": "\u016a",  # LATIN CAPITAL LETTER U WITH MACRON
    "umacr": "\u016b",  # LATIN SMALL LETTER U WITH MACRON
    "uml": "\xa8",  # DIAERESIS
    "UnderBar": "_",  # LOW LINE
    "UnderBrace": "\u23df",  # BOTTOM CURLY BRACKET
    "UnderBracket": "\u23b5",  # BOTTOM SQUARE BRACKET
    "UnderParenthesis": "\u23dd",  # BOTTOM PARENTHESIS
    "Union": "\u22c3",  # N-ARY UNION
    "UnionPlus": "\u228e",  # MULTISET UNION
    "Uogon": "\u0172",  # LATIN CAPITAL LETTER U WITH OGONEK
    "uogon": "\u0173",  # LATIN SMALL LETTER U WITH OGONEK
    "Uopf": "\U0001d54c",  # MATHEMATICAL DOUBLE-STRUCK CAPITAL U
    "uopf": "\U0001d566",  # MATHEMATICAL DOUBLE-STRUCK SMALL U
    "UpArrow": "\u2191",  # UPWARDS ARROW
    "Uparrow": "\u21d1",  # UPWARDS DOUBLE ARROW
    "uparrow": "\u2191",  # UPWARDS ARROW
    "UpArrowBar": "\u2912",  # UPWARDS ARROW TO BAR
    "UpArrowDownArrow": "\u21c5",  # UPWARDS ARROW LEFTWARDS OF DOWNWARDS ARROW
    "UpDownArrow": "\u2195",  # UP DOWN ARROW
    "Updownarrow": "\u21d5",  # UP DOWN DOUBLE ARROW
    "updownarrow": "\u2195",  # UP DOWN ARROW
    "UpEquilibrium": "\u296e",  # UPWARDS HARPOON WITH BARB LEFT BESIDE DOWNWARDS HARPOON WITH BARB RIGHT
    "upharpoonleft": "\u21bf",  # UPWARDS HARPOON WITH BARB LEFTWARDS
    "upharpoonright": "\u21be",  # UPWARDS HARPOON WITH BARB RIGHTWARDS
    "uplus": "\u228e",  # MULTISET UNION
    "UpperLeftArrow": "\u2196",  # NORTH WEST ARROW
    "UpperRightArrow": "\u2197",  # NORTH EAST ARROW
    "Upsi": "\u03d2",  # GREEK UPSILON WITH HOOK SYMBOL
    "upsi": "\u03c5",  # GREEK SMALL LETTER UPSILON
    "upsih": "\u03d2",  # GREEK UPSILON WITH HOOK SYMBOL
    "Upsilon": "\u03a5",  # GREEK CAPITAL LETTER UPSILON
    "upsilon": "\u03c5",  # GREEK SMALL LETTER UPSILON
    "UpTee": "\u22a5",  # UP TACK
    "UpTeeArrow": "\u21a5",  # UPWARDS ARROW FROM BAR
    "upuparrows": "\u21c8",  # UPWARDS PAIRED ARROWS
    "urcorn": "\u231d",  # TOP RIGHT CORNER
    "urcorner": "\u231d",  # TOP RIGHT CORNER
    "urcrop": "\u230e",  # TOP RIGHT CROP
    "Uring": "\u016e",  # LATIN CAPITAL LETTER U WITH RING ABOVE
    "uring": "\u016f",  # LATIN SMALL LETTER U WITH RING ABOVE
    "urtri": "\u25f9",  # UPPER RIGHT TRIANGLE
    "Uscr": "\U0001d4b0",  # MATHEMATICAL SCRIPT CAPITAL U
    "uscr": "\U0001d4ca",  # MATHEMATICAL SCRIPT SMALL U
    "utdot": "\u22f0",  # UP RIGHT DIAGONAL ELLIPSIS
    "Utilde": "\u0168",  # LATIN CAPITAL LETTER U WITH TILDE
    "utilde": "\u0169",  # LATIN SMALL LETTER U WITH TILDE
    "utri": "\u25b5",  # WHITE UP-POINTING SMALL TRIANGLE
    "utrif": "\u25b4",  # BLACK UP-POINTING SMALL TRIANGLE
    "uuarr": "\u21c8",  # UPWARDS PAIRED ARROWS
    "Uuml": "\xdc",  # LATIN CAPITAL LETTER U WITH DIAERESIS
    "uuml": "\xfc",  # LATIN SMALL LETTER U WITH DIAERESIS
    "uwangle": "\u29a7",  # OBLIQUE ANGLE OPENING DOWN
    "vangrt": "\u299c",  # RIGHT ANGLE VARIANT WITH SQUARE
    "varepsilon": "\u03f5",  # GREEK LUNATE EPSILON SYMBOL
    "varkappa": "\u03f0",  # GREEK KAPPA SYMBOL
    "varnothing": "\u2205",  # EMPTY SET
    "varphi": "\u03d5",  # GREEK PHI SYMBOL
    "varpi": "\u03d6",  # GREEK PI SYMBOL
    "varpropto": "\u221d",  # PROPORTIONAL TO
    "vArr": "\u21d5",  # UP DOWN DOUBLE ARROW
    "varr": "\u2195",  # UP DOWN ARROW
    "varrho": "\u03f1",  # GREEK RHO SYMBOL
    "varsigma": "\u03c2",  # GREEK SMALL LETTER FINAL SIGMA
    "varsubsetneq": "\u228a\ufe00",  # SUBSET OF WITH NOT EQUAL TO - variant with stroke through bottom members
    "varsubsetneqq": "\u2acb\ufe00",  # SUBSET OF ABOVE NOT EQUAL TO - variant with stroke through bottom members
    "varsupsetneq": "\u228b\ufe00",  # SUPERSET OF WITH NOT EQUAL TO - variant with stroke through bottom members
    "varsupsetneqq": "\u2acc\ufe00",  # SUPERSET OF ABOVE NOT EQUAL TO - variant with stroke through bottom members
    "vartheta": "\u03d1",  # GREEK THETA SYMBOL
    "vartriangleleft": "\u22b2",  # NORMAL SUBGROUP OF
    "vartriangleright": "\u22b3",  # CONTAINS AS NORMAL SUBGROUP
    "Vbar": "\u2aeb",  # DOUBLE UP TACK
    "vBar": "\u2ae8",  # SHORT UP TACK WITH UNDERBAR
    "vBarv": "\u2ae9",  # SHORT UP TACK ABOVE SHORT DOWN TACK
    "Vcy": "\u0412",  # CYRILLIC CAPITAL LETTER VE
    "vcy": "\u0432",  # CYRILLIC SMALL LETTER VE
    "VDash": "\u22ab",  # DOUBLE VERTICAL BAR DOUBLE RIGHT TURNSTILE
    "Vdash": "\u22a9",  # FORCES
    "vDash": "\u22a8",  # TRUE
    "vdash": "\u22a2",  # RIGHT TACK
    "Vdashl": "\u2ae6",  # LONG DASH FROM LEFT MEMBER OF DOUBLE VERTICAL
    "Vee": "\u22c1",  # N-ARY LOGICAL OR
    "vee": "\u2228",  # LOGICAL OR
    "veebar": "\u22bb",  # XOR
    "veeeq": "\u225a",  # EQUIANGULAR TO
    "vellip": "\u22ee",  # VERTICAL ELLIPSIS
    "Verbar": "\u2016",  # DOUBLE VERTICAL LINE
    "verbar": "|",  # VERTICAL LINE
    "Vert": "\u2016",  # DOUBLE VERTICAL LINE
    "vert": "|",  # VERTICAL LINE
    "VerticalBar": "\u2223",  # DIVIDES
    "VerticalLine": "|",  # VERTICAL LINE
    "VerticalSeparator": "\u2758",  # LIGHT VERTICAL BAR
    "VerticalTilde": "\u2240",  # WREATH PRODUCT
    "VeryThinSpace": "\u200a",  # HAIR SPACE
    "Vfr": "\U0001d519",  # MATHEMATICAL FRAKTUR CAPITAL V
    "vfr": "\U0001d533",  # MATHEMATICAL FRAKTUR SMALL V
    "vltri": "\u22b2",  # NORMAL SUBGROUP OF
    "vnsub": "\u2282\u20d2",  # SUBSET OF with vertical line
    "vnsup": "\u2283\u20d2",  # SUPERSET OF with vertical line
    "Vopf": "\U0001d54d",  # MATHEMATICAL DOUBLE-STRUCK CAPITAL V
    "vopf": "\U0001d567",  # MATHEMATICAL DOUBLE-STRUCK SMALL V
    "vprop": "\u221d",  # PROPORTIONAL TO
    "vrtri": "\u22b3",  # CONTAINS AS NORMAL SUBGROUP
    "Vscr": "\U0001d4b1",  # MATHEMATICAL SCRIPT CAPITAL V
    "vscr": "\U0001d4cb",  # MATHEMATICAL SCRIPT SMALL V
    "vsubnE": "\u2acb\ufe00",  # SUBSET OF ABOVE NOT EQUAL TO - variant with stroke through bottom members
    "vsubne": "\u228a\ufe00",  # SUBSET OF WITH NOT EQUAL TO - variant with stroke through bottom members
    "vsupnE": "\u2acc\ufe00",  # SUPERSET OF ABOVE NOT EQUAL TO - variant with stroke through bottom members
    "vsupne": "\u228b\ufe00",  # SUPERSET OF WITH NOT EQUAL TO - variant with stroke through bottom members
    "Vvdash": "\u22aa",  # TRIPLE VERTICAL BAR RIGHT TURNSTILE
    "vzigzag": "\u299a",  # VERTICAL ZIGZAG LINE
    "Wcirc": "\u0174",  # LATIN CAPITAL LETTER W WITH CIRCUMFLEX
    "wcirc": "\u0175",  # LATIN SMALL LETTER W WITH CIRCUMFLEX
    "wedbar": "\u2a5f",  # LOGICAL AND WITH UNDERBAR
    "Wedge": "\u22c0",  # N-ARY LOGICAL AND
    "wedge": "\u2227",  # LOGICAL AND
    "wedgeq": "\u2259",  # ESTIMATES
    "weierp": "\u2118",  # SCRIPT CAPITAL P
    "Wfr": "\U0001d51a",  # MATHEMATICAL FRAKTUR CAPITAL W
    "wfr": "\U0001d534",  # MATHEMATICAL FRAKTUR SMALL W
    "Wopf": "\U0001d54e",  # MATHEMATICAL DOUBLE-STRUCK CAPITAL W
    "wopf": "\U0001d568",  # MATHEMATICAL DOUBLE-STRUCK SMALL W
    "wp": "\u2118",  # SCRIPT CAPITAL P
    "wr": "\u2240",  # WREATH PRODUCT
    "wreath": "\u2240",  # WREATH PRODUCT
    "Wscr": "\U0001d4b2",  # MATHEMATICAL SCRIPT CAPITAL W
    "wscr": "\U0001d4cc",  # MATHEMATICAL SCRIPT SMALL W
    "xcap": "\u22c2",  # N-ARY INTERSECTION
    "xcirc": "\u25ef",  # LARGE CIRCLE
    "xcup": "\u22c3",  # N-ARY UNION
    "xdtri": "\u25bd",  # WHITE DOWN-POINTING TRIANGLE
    "Xfr": "\U0001d51b",  # MATHEMATICAL FRAKTUR CAPITAL X
    "xfr": "\U0001d535",  # MATHEMATICAL FRAKTUR SMALL X
    "xhArr": "\u27fa",  # LONG LEFT RIGHT DOUBLE ARROW
    "xharr": "\u27f7",  # LONG LEFT RIGHT ARROW
    "Xi": "\u039e",  # GREEK CAPITAL LETTER XI
    "xi": "\u03be",  # GREEK SMALL LETTER XI
    "xlArr": "\u27f8",  # LONG LEFTWARDS DOUBLE ARROW
    "xlarr": "\u27f5",  # LONG LEFTWARDS ARROW
    "xmap": "\u27fc",  # LONG RIGHTWARDS ARROW FROM BAR
    "xnis": "\u22fb",  # CONTAINS WITH VERTICAL BAR AT END OF HORIZONTAL STROKE
    "xodot": "\u2a00",  # N-ARY CIRCLED DOT OPERATOR
    "Xopf": "\U0001d54f",  # MATHEMATICAL DOUBLE-STRUCK CAPITAL X
    "xopf": "\U0001d569",  # MATHEMATICAL DOUBLE-STRUCK SMALL X
    "xoplus": "\u2a01",  # N-ARY CIRCLED PLUS OPERATOR
    "xotime": "\u2a02",  # N-ARY CIRCLED TIMES OPERATOR
    "xrArr": "\u27f9",  # LONG RIGHTWARDS DOUBLE ARROW
    "xrarr": "\u27f6",  # LONG RIGHTWARDS ARROW
    "Xscr": "\U0001d4b3",  # MATHEMATICAL SCRIPT CAPITAL X
    "xscr": "\U0001d4cd",  # MATHEMATICAL SCRIPT SMALL X
    "xsqcup": "\u2a06",  # N-ARY SQUARE UNION OPERATOR
    "xuplus": "\u2a04",  # N-ARY UNION OPERATOR WITH PLUS
    "xutri": "\u25b3",  # WHITE UP-POINTING TRIANGLE
    "xvee": "\u22c1",  # N-ARY LOGICAL OR
    "xwedge": "\u22c0",  # N-ARY LOGICAL AND
    "Yacute": "\xdd",  # LATIN CAPITAL LETTER Y WITH ACUTE
    "yacute": "\xfd",  # LATIN SMALL LETTER Y WITH ACUTE
    "YAcy": "\u042f",  # CYRILLIC CAPITAL LETTER YA
    "yacy": "\u044f",  # CYRILLIC SMALL LETTER YA
    "Ycirc": "\u0176",  # LATIN CAPITAL LETTER Y WITH CIRCUMFLEX
    "ycirc": "\u0177",  # LATIN SMALL LETTER Y WITH CIRCUMFLEX
    "Ycy": "\u042b",  # CYRILLIC CAPITAL LETTER YERU
    "ycy": "\u044b",  # CYRILLIC SMALL LETTER YERU
    "yen": "\xa5",  # YEN SIGN
    "Yfr": "\U0001d51c",  # MATHEMATICAL FRAKTUR CAPITAL Y
    "yfr": "\U0001d536",  # MATHEMATICAL FRAKTUR SMALL Y
    "YIcy": "\u0407",  # CYRILLIC CAPITAL LETTER YI
    "yicy": "\u0457",  # CYRILLIC SMALL LETTER YI
    "Yopf": "\U0001d550",  # MATHEMATICAL DOUBLE-STRUCK CAPITAL Y
    "yopf": "\U0001d56a",  # MATHEMATICAL DOUBLE-STRUCK SMALL Y
    "Yscr": "\U0001d4b4",  # MATHEMATICAL SCRIPT CAPITAL Y
    "yscr": "\U0001d4ce",  # MATHEMATICAL SCRIPT SMALL Y
    "YUcy": "\u042e",  # CYRILLIC CAPITAL LETTER YU
    "yucy": "\u044e",  # CYRILLIC SMALL LETTER YU
    "Yuml": "\u0178",  # LATIN CAPITAL LETTER Y WITH DIAERESIS
    "yuml": "\xff",  # LATIN SMALL LETTER Y WITH DIAERESIS
    "Zacute": "\u0179",  # LATIN CAPITAL LETTER Z WITH ACUTE
    "zacute": "\u017a",  # LATIN SMALL LETTER Z WITH ACUTE
    "Zcaron": "\u017d",  # LATIN CAPITAL LETTER Z WITH CARON
    "zcaron": "\u017e",  # LATIN SMALL LETTER Z WITH CARON
    "Zcy": "\u0417",  # CYRILLIC CAPITAL LETTER ZE
    "zcy": "\u0437",  # CYRILLIC SMALL LETTER ZE
    "Zdot": "\u017b",  # LATIN CAPITAL LETTER Z WITH DOT ABOVE
    "zdot": "\u017c",  # LATIN SMALL LETTER Z WITH DOT ABOVE
    "zeetrf": "\u2128",  # BLACK-LETTER CAPITAL Z
    "ZeroWidthSpace": "\u200b",  # ZERO WIDTH SPACE
    "Zeta": "\u0396",  # GREEK CAPITAL LETTER ZETA
    "zeta": "\u03b6",  # GREEK SMALL LETTER ZETA
    "Zfr": "\u2128",  # BLACK-LETTER CAPITAL Z
    "zfr": "\U0001d537",  # MATHEMATICAL FRAKTUR SMALL Z
    "ZHcy": "\u0416",  # CYRILLIC CAPITAL LETTER ZHE
    "zhcy": "\u0436",  # CYRILLIC SMALL LETTER ZHE
    "zigrarr": "\u21dd",  # RIGHTWARDS SQUIGGLE ARROW
    "Zopf": "\u2124",  # DOUBLE-STRUCK CAPITAL Z
    "zopf": "\U0001d56b",  # MATHEMATICAL DOUBLE-STRUCK SMALL Z
    "Zscr": "\U0001d4b5",  # MATHEMATICAL SCRIPT CAPITAL Z
    "zscr": "\U0001d4cf",  # MATHEMATICAL SCRIPT SMALL Z
    "zwj": "\u200d",  # ZERO WIDTH JOINER
    "zwnj": "\u200c",  # ZERO WIDTH NON-JOINER
}

known_entities = dict([(k, chr(v)) for k, v in name2codepoint.items()])
for k in greeks:
    if k not in known_entities:
        known_entities[k] = greeks[k]
# K = list(known_entities.keys())
# for k in K:
#   known_entities[asBytes(k)] = known_entities[k]
# del k, f, K


# ------------------------------------------------------------------------
class ParaFrag(ABag):
    """class ParaFrag contains the intermediate representation of string
    segments as they are being parsed by the ParaParser.
    fontname, fontSize, rise, textColor, cbDefn
    """


_greek2Utf8 = None


def _greekConvert(data):
    global _greek2Utf8
    if not _greek2Utf8:
        import codecs

        from reportlab.pdfbase.rl_codecs import RL_Codecs

        # our decoding map
        dm = codecs.make_identity_dict(range(32, 256))
        for k in range(0, 32):
            dm[k] = None
        dm.update(RL_Codecs._RL_Codecs__rl_codecs_data["symbol"][0])
        _greek2Utf8 = {}
        for k, v in dm.items():
            if not v:
                u = "\0"
            else:
                u = chr(v)
            _greek2Utf8[chr(k)] = u
    return "".join(map(_greek2Utf8.__getitem__, data))


# ------------------------------------------------------------------
# !!! NOTE !!! THIS TEXT IS NOW REPLICATED IN PARAGRAPH.PY !!!
# The ParaFormatter will be able to format the following
# tags:
#       < /b > - bold
#       < /i > - italics
#       < u [color="red"] [width="pts"] [offset="pts"]> < /u > - underline
#           width and offset can be empty meaning use existing canvas line width
#           or with an f/F suffix regarded as a fraction of the font size
#       < strike > < /strike > - strike through has the same parameters as underline
#       < super [size="pts"] [rise="pts"]> < /super > - superscript
#       < sup ="pts"] [rise="pts"]> < /sup > - superscript
#       < sub ="pts"] [rise="pts"]> < /sub > - subscript
#       <font name=fontfamily/fontname color=colorname size=float>
#        <span name=fontfamily/fontname color=colorname backcolor=colorname size=float style=stylename>
#       < bullet > </bullet> - bullet text (at head of para only)
#       <onDraw name=callable label="a label"/>
#       <index [name="callablecanvasattribute"] label="a label"/>
#       <link>link text</link>
#           attributes of links
#               size/fontSize/uwidth/uoffset=num
#               name/face/fontName=name
#               fg/textColor/color/ucolor=color
#               backcolor/backColor/bgcolor=color
#               dest/destination/target/href/link=target
#               underline=bool turn on underline
#       <a>anchor text</a>
#           attributes of anchors
#               fontSize=num
#               fontName=name
#               fg/textColor/color=color
#               backcolor/backColor/bgcolor=color
#               href=href
#       <a name="anchorpoint"/>
#       <unichar name="unicode character name"/>
#       <unichar value="unicode code point"/>
#       <img src="path" width="1in" height="1in" valign="bottom"/>
#               width="w%" --> fontSize*w/100   idea from Roberto Alsina
#               height="h%" --> linewidth*h/100 <ralsina@netmanagers.com.ar>
#       <greek> - </greek>
#       <nobr> ... </nobr> turn off word breaking and hyphenation
#
#       The whole may be surrounded by <para> </para> tags
#
# It will also be able to handle any MathML specified Greek characters.
# ------------------------------------------------------------------
class ParaParser(HTMLParser):
    # ----------------------------------------------------------
    # First we will define all of the xml tag handler functions.
    #
    # start_<tag>(attributes)
    # end_<tag>()
    #
    # While parsing the xml ParaFormatter will call these
    # functions to handle the string formatting tags.
    # At the start of each tag the corresponding field will
    # be set to 1 and at the end tag the corresponding field will
    # be set to 0.  Then when handle_data is called the options
    # for that data will be aparent by the current settings.
    # ----------------------------------------------------------

    def __getattr__(self, attrName):
        """This way we can handle <TAG> the same way as <tag> (ignoring case)."""
        if (
            attrName != attrName.lower()
            and attrName != "caseSensitive"
            and not self.caseSensitive
            and (attrName.startswith("start_") or attrName.startswith("end_"))
        ):
            return getattr(self, attrName.lower())
        raise AttributeError(attrName)

    #### bold
    def start_b(self, attributes):
        self._push("b", bold=1)

    def end_b(self):
        self._pop("b")

    def start_strong(self, attributes):
        self._push("strong", bold=1)

    def end_strong(self):
        self._pop("strong")

    #### italics
    def start_i(self, attributes):
        self._push("i", italic=1)

    def end_i(self):
        self._pop("i")

    def start_em(self, attributes):
        self._push("em", italic=1)

    def end_em(self):
        self._pop("em")

    def _new_line(self, k):
        frag = self._stack[-1]
        frag.us_lines = frag.us_lines + [
            (
                self.nlines,
                k,
                getattr(frag, k + "Color", self._defaultLineColors[k]),
                getattr(frag, k + "Width", self._defaultLineWidths[k]),
                getattr(frag, k + "Offset", self._defaultLineOffsets[k]),
                frag.rise,
                _lineRepeats[getattr(frag, k + "Kind", "single")],
                getattr(frag, k + "Gap", self._defaultLineGaps[k]),
            )
        ]
        self.nlines += 1

    #### underline
    def start_u(self, attributes):
        A = self.getAttributes(attributes, _uAttrMap)
        self._push("u", **A)
        self._new_line("underline")

    def end_u(self):
        self._pop("u")

    #### strike
    def start_strike(self, attributes):
        A = self.getAttributes(attributes, _strikeAttrMap)
        self._push("strike", strike=1, **A)
        self._new_line("strike")

    def end_strike(self):
        self._pop("strike")

    #### link
    def _handle_link(self, tag, attributes):
        A = self.getAttributes(attributes, _linkAttrMap)
        underline = A.pop("underline", self._defaultLinkUnderline)
        A["link"] = self._stack[-1].link + [
            (
                self.nlinks,
                A.pop("link", "").strip(),
            )
        ]
        self.nlinks += 1
        self._push(tag, **A)
        if underline:
            self._new_line("underline")

    def start_link(self, attributes):
        self._handle_link("link", attributes)

    def end_link(self):
        if self._pop("link").link is None:
            raise ValueError("<link> has no target or href")

    #### anchor
    def start_a(self, attributes):
        anchor = "name" in attributes
        if anchor:
            A = self.getAttributes(attributes, _anchorAttrMap)
            name = A.get("name", None)
            name = name.strip()
            if not name:
                self._syntax_error('<a name="..."/> anchor variant requires non-blank name')
            if len(A) > 1:
                self._syntax_error('<a name="..."/> anchor variant only allows name attribute')
                A = dict(name=A["name"])
            A["_selfClosingTag"] = "anchor"
            self._push("a", **A)
        else:
            self._handle_link("a", attributes)

    def end_a(self):
        frag = self._stack[-1]
        sct = getattr(frag, "_selfClosingTag", "")
        if sct:
            if not (sct == "anchor" and frag.name):
                raise ValueError("Parser failure in <a/>")
            defn = frag.cbDefn = ABag()
            defn.label = defn.kind = "anchor"
            defn.name = frag.name
            del frag.name, frag._selfClosingTag
            self.handle_data("")
            self._pop("a")
        else:
            if self._pop("a").link is None:
                raise ValueError("<link> has no href")

    def start_img(self, attributes):
        A = self.getAttributes(attributes, _imgAttrMap)
        if not A.get("src"):
            self._syntax_error("<img> needs src attribute")
        A["_selfClosingTag"] = "img"
        self._push("img", **A)

    def end_img(self):
        frag = self._stack[-1]
        if not getattr(frag, "_selfClosingTag", ""):
            raise ValueError("Parser failure in <img/>")
        defn = frag.cbDefn = ABag()
        defn.kind = "img"
        defn.src = getattr(frag, "src", None)
        defn.image = ImageReader(defn.src)
        size = defn.image.getSize()
        defn.width = getattr(frag, "width", size[0])
        defn.height = getattr(frag, "height", size[1])
        defn.valign = getattr(frag, "valign", "bottom")
        del frag._selfClosingTag
        self.handle_data("")
        self._pop("img")

    #### super script
    def start_super(self, attributes):
        A = self.getAttributes(attributes, _supAttrMap)
        # A['sup']=1
        self._push("super", **A)
        frag = self._stack[-1]
        frag.rise += fontSizeNormalize(frag, "supr", frag.fontSize * supFraction)
        frag.fontSize = fontSizeNormalize(frag, "sups", frag.fontSize - min(sizeDelta, 0.2 * frag.fontSize))

    def end_super(self):
        self._pop("super")

    start_sup = start_super
    end_sup = end_super

    #### sub script
    def start_sub(self, attributes):
        A = self.getAttributes(attributes, _supAttrMap)
        self._push("sub", **A)
        frag = self._stack[-1]
        frag.rise -= fontSizeNormalize(frag, "supr", frag.fontSize * subFraction)
        frag.fontSize = fontSizeNormalize(frag, "sups", frag.fontSize - min(sizeDelta, 0.2 * frag.fontSize))

    def end_sub(self):
        self._pop("sub")

    def start_nobr(self, attrs):
        self.getAttributes(attrs, {})
        self._push("nobr", nobr=True)

    def end_nobr(self):
        self._pop("nobr")

    #### greek script
    #### add symbol encoding
    def handle_charref(self, name):
        try:
            if name[0] == "x":
                n = int(name[1:], 16)
            else:
                n = int(name)
        except ValueError:
            self.unknown_charref(name)
            return
        self.handle_data(chr(n))  # .encode('utf8'))

    def syntax_error(self, lineno, message):
        self._syntax_error(message)

    def _syntax_error(self, message):
        if message[:10] == "attribute " and message[-17:] == " value not quoted":
            return
        if self._crashOnError:
            raise ValueError("paraparser: syntax error: %s" % message)
        self.errors.append(message)

    def start_greek(self, attr):
        self._push("greek", greek=1)

    def end_greek(self):
        self._pop("greek")

    def start_unichar(self, attr):
        if "name" in attr:
            if "code" in attr:
                self._syntax_error("<unichar/> invalid with both name and code attributes")
            try:
                v = unicodedata.lookup(attr["name"])
            except KeyError:
                self._syntax_error('<unichar/> invalid name attribute\n"%s"' % ascii(attr["name"]))
                v = "\0"
        elif "code" in attr:
            try:
                v = attr["code"].lower()
                if v.startswith("0x"):
                    v = int(v, 16)
                else:
                    v = int(v, 0)  # treat as a python literal would be
                v = chr(v)
            except:
                self._syntax_error("<unichar/> invalid code attribute %s" % ascii(attr["code"]))
                v = "\0"
        else:
            v = None
            if attr:
                self._syntax_error("<unichar/> invalid attribute %s" % list(attr.keys())[0])

        if v is not None:
            self.handle_data(v)
        self._push("unichar", _selfClosingTag="unichar")

    def end_unichar(self):
        self._pop("unichar")

    def start_font(self, attr):
        A = self.getAttributes(attr, _spanAttrMap)
        if "fontName" in A:
            A["fontName"], A["bold"], A["italic"] = ps2tt(A["fontName"])
        self._push("font", **A)

    def end_font(self):
        self._pop("font")

    def start_span(self, attr):
        A = self.getAttributes(attr, _spanAttrMap)
        if "style" in A:
            style = self.findSpanStyle(A.pop("style"))
            D = {}
            for k in "fontName fontSize textColor backColor".split():
                v = getattr(style, k, self)
                if v is self:
                    continue
                D[k] = v
            D.update(A)
            A = D
        if "fontName" in A:
            A["fontName"], A["bold"], A["italic"] = ps2tt(A["fontName"])
        self._push("span", **A)

    def end_span(self):
        self._pop("span")

    def start_br(self, attr):
        self._push("br", _selfClosingTag="br", lineBreak=True, text="")

    def end_br(self):
        # print('\nend_br called, %d frags in list' % len(self.fragList))
        frag = self._stack[-1]
        if not (frag._selfClosingTag == "br" and frag.lineBreak):
            raise ValueError("Parser failure in <br/>")
        del frag._selfClosingTag
        self.handle_data("")
        self._pop("br")

    def _initial_frag(self, attr, attrMap, bullet=0):
        style = self._style
        if attr != {}:
            style = copy.deepcopy(style)
            _applyAttributes(style, self.getAttributes(attr, attrMap))
            self._style = style

        # initialize semantic values
        frag = ParaFrag()
        frag.rise = 0
        frag.greek = 0
        frag.link = []
        try:
            if bullet:
                frag.fontName, frag.bold, frag.italic = ps2tt(style.bulletFontName)
                frag.fontSize = style.bulletFontSize
                frag.textColor = hasattr(style, "bulletColor") and style.bulletColor or style.textColor
            else:
                frag.fontName, frag.bold, frag.italic = ps2tt(style.fontName)
                frag.fontSize = style.fontSize
                frag.textColor = style.textColor
        except:
            annotateException("error with style name=%s" % style.name)
        frag.us_lines = []
        self.nlinks = self.nlines = 0
        self._defaultLineWidths = dict(
            underline=getattr(style, "underlineWidth", ""),
            strike=getattr(style, "strikeWidth", ""),
        )
        self._defaultLineColors = dict(
            underline=getattr(style, "underlineColor", ""),
            strike=getattr(style, "strikeColor", ""),
        )
        self._defaultLineOffsets = dict(
            underline=getattr(style, "underlineOffset", ""),
            strike=getattr(style, "strikeOffset", ""),
        )
        self._defaultLineGaps = dict(
            underline=getattr(style, "underlineGap", ""),
            strike=getattr(style, "strikeGap", ""),
        )
        self._defaultLinkUnderline = getattr(style, "linkUnderline", platypus_link_underline)
        return frag

    def start_para(self, attr):
        frag = self._initial_frag(attr, _paraAttrMap)
        frag.__tag__ = "para"
        self._stack = [frag]

    def end_para(self):
        self._pop("para")

    def start_bullet(self, attr):
        if hasattr(self, "bFragList"):
            self._syntax_error("only one <bullet> tag allowed")
        self.bFragList = []
        frag = self._initial_frag(attr, _bulletAttrMap, 1)
        frag.isBullet = 1
        frag.__tag__ = "bullet"
        self._stack.append(frag)

    def end_bullet(self):
        self._pop("bullet")

    # ---------------------------------------------------------------
    def start_seqdefault(self, attr):
        try:
            default = attr["id"]
        except KeyError:
            default = None
        self._seq.setDefaultCounter(default)

    def end_seqdefault(self):
        pass

    def start_seqreset(self, attr):
        try:
            id = attr["id"]
        except KeyError:
            id = None
        try:
            base = int(attr["base"])
        except:
            base = 0
        self._seq.reset(id, base)

    def end_seqreset(self):
        pass

    def start_seqchain(self, attr):
        try:
            order = attr["order"]
        except KeyError:
            order = ""
        order = order.split()
        seq = self._seq
        for p, c in zip(order[:-1], order[1:]):
            seq.chain(p, c)

    end_seqchain = end_seqreset

    def start_seqformat(self, attr):
        try:
            id = attr["id"]
        except KeyError:
            id = None
        try:
            value = attr["value"]
        except KeyError:
            value = "1"
        self._seq.setFormat(id, value)

    end_seqformat = end_seqreset

    # AR hacking in aliases to allow the proper casing for RML.
    # the above ones should be deprecated over time. 2001-03-22
    start_seqDefault = start_seqdefault
    end_seqDefault = end_seqdefault
    start_seqReset = start_seqreset
    end_seqReset = end_seqreset
    start_seqChain = start_seqchain
    end_seqChain = end_seqchain
    start_seqFormat = start_seqformat
    end_seqFormat = end_seqformat

    def start_seq(self, attr):
        # if it has a template, use that; otherwise try for id;
        # otherwise take default sequence
        if "template" in attr:
            templ = attr["template"]
            self.handle_data(templ % self._seq)
            return
        elif "id" in attr:
            id = attr["id"]
        else:
            id = None
        increment = attr.get("inc", None)
        if not increment:
            output = self._seq.nextf(id)
        else:
            # accepts "no" for do not increment, or an integer.
            # thus, 0 and 1 increment by the right amounts.
            if increment.lower() == "no":
                output = self._seq.thisf(id)
            else:
                incr = int(increment)
                output = self._seq.thisf(id)
                self._seq.reset(id, self._seq._this() + incr)
        self.handle_data(output)

    def end_seq(self):
        pass

    def start_ondraw(self, attr):
        defn = ABag()
        if "name" in attr:
            defn.name = attr["name"]
        else:
            self._syntax_error("<onDraw> needs at least a name attribute")

        defn.label = attr.get("label", None)
        defn.kind = "onDraw"
        self._push("ondraw", cbDefn=defn)
        self.handle_data("")
        self._pop("ondraw")

    start_onDraw = start_ondraw
    end_onDraw = end_ondraw = end_seq

    def start_index(self, attr):
        attr = self.getAttributes(attr, _indexAttrMap)
        defn = ABag()
        if "item" in attr:
            label = attr["item"]
        else:
            self._syntax_error("<index> needs at least an item attribute")
        if "name" in attr:
            name = attr["name"]
        else:
            name = DEFAULT_INDEX_NAME
        format = attr.get("format", None)
        if format is not None and format not in ("123", "I", "i", "ABC", "abc"):
            raise ValueError("index tag format is %r not valid 123 I i ABC or abc" % offset)
        offset = attr.get("offset", None)
        if offset is not None:
            try:
                offset = int(offset)
            except:
                raise ValueError("index tag offset is %r not an int" % offset)
        defn.label = encode_label((label, format, offset))
        defn.name = name
        defn.kind = "index"
        self._push("index", cbDefn=defn)
        self.handle_data("")
        self._pop(
            "index",
        )

    end_index = end_seq

    def start_unknown(self, attr):
        pass

    end_unknown = end_seq

    # ---------------------------------------------------------------
    def _push(self, tag, **attr):
        frag = copy.copy(self._stack[-1])
        frag.__tag__ = tag
        _applyAttributes(frag, attr)
        self._stack.append(frag)

    def _pop(self, tag):
        frag = self._stack.pop()
        if tag == frag.__tag__:
            return frag
        raise ValueError("Parse error: saw </%s> instead of expected </%s>" % (tag, frag.__tag__))

    def getAttributes(self, attr, attrMap):
        A = {}
        for k, v in attr.items():
            if not self.caseSensitive:
                k = k.lower()
            if k in attrMap:
                j = attrMap[k]
                func = j[1]
                if func is not None:
                    # it's a function
                    v = func(self, v) if isinstance(func, _ExValidate) else func(v)
                A[j[0]] = v
            else:
                self._syntax_error("invalid attribute name %s attrMap=%r" % (k, list(sorted(attrMap.keys()))))
        return A

    # ----------------------------------------------------------------

    def __init__(self, verbose=0, caseSensitive=0, ignoreUnknownTags=1, crashOnError=True):
        HTMLParser.__init__(self, **(dict(convert_charrefs=False)))
        self.verbose = verbose
        # HTMLParser is case insenstive anyway, but the rml interface still needs this
        # all start/end_ methods should have a lower case version for HMTMParser
        self.caseSensitive = caseSensitive
        self.ignoreUnknownTags = ignoreUnknownTags
        self._crashOnError = crashOnError

    def _iReset(self):
        self.fragList = []
        if hasattr(self, "bFragList"):
            delattr(self, "bFragList")

    def _reset(self, style):
        """reset the parser"""

        HTMLParser.reset(self)
        # initialize list of string segments to empty
        self.errors = []
        self._style = style
        self._iReset()

    # ----------------------------------------------------------------
    def handle_data(self, data):
        "Creates an intermediate representation of string segments."

        # The old parser would only 'see' a string after all entities had
        # been processed.  Thus, 'Hello &trade; World' would emerge as one
        # fragment.    HTMLParser processes these separately.  We want to ensure
        # that successive calls like this are concatenated, to prevent too many
        # fragments being created.

        frag = copy.copy(self._stack[-1])
        if hasattr(frag, "cbDefn"):
            kind = frag.cbDefn.kind
            if data:
                self._syntax_error("Only empty <%s> tag allowed" % kind)
        elif hasattr(frag, "_selfClosingTag"):
            if data != "":
                self._syntax_error("No content allowed in %s tag" % frag._selfClosingTag)
            return
        else:
            # get the right parameters for the
            if frag.greek:
                frag.fontName = "symbol"
                data = _greekConvert(data)

        # bold, italic
        frag.fontName = tt2ps(frag.fontName, frag.bold, frag.italic)
        # in 3.14.0a1 the needed to use the commented line below
        # frag = frag.clone(fontName=tt2ps(frag.fontName,frag.bold,frag.italic))

        # save our data
        frag.text = data

        if hasattr(frag, "isBullet"):
            delattr(frag, "isBullet")
            self.bFragList.append(frag)
        else:
            self.fragList.append(frag)

    def handle_cdata(self, data):
        self.handle_data(data)

    def _setup_for_parse(self, style):
        self._seq = reportlab.lib.sequencer.getSequencer()
        self._reset(style)  # reinitialise the parser

    def _complete_parse(self):
        "Reset after parsing, to be ready for next paragraph"
        if self._stack:
            self._syntax_error(
                "parse ended with %d unclosed tags\n %s"
                % (len(self._stack), "\n ".join((x.__tag__ for x in reversed(self._stack))))
            )
        del self._seq
        style = self._style
        del self._style
        if len(self.errors) == 0:
            fragList = self.fragList
            bFragList = hasattr(self, "bFragList") and self.bFragList or None
            self._iReset()
        else:
            fragList = bFragList = None

        return style, fragList, bFragList

    def _tt_handle(self, tt):
        "Iterate through a pre-parsed tuple tree (e.g. from pyrxp)"
        # import pprint
        # pprint.pprint(tt)
        # find the corresponding start_tagname and end_tagname methods.
        # These must be defined.
        tag = tt[0]
        try:
            start = getattr(self, "start_" + tag)
            end = getattr(self, "end_" + tag)
        except AttributeError:
            if not self.ignoreUnknownTags:
                raise ValueError('Invalid tag "%s"' % tag)
            start = self.start_unknown
            end = self.end_unknown

        # call the start_tagname method
        start(tt[1] or {})
        # if tree node has any children, they will either be further nodes,
        # or text.  Accordingly, call either this function, or handle_data.
        C = tt[2]
        if C:
            M = self._tt_handlers
            for c in C:
                M[isinstance(c, (list, tuple))](c)

        # call the end_tagname method
        end()

    def _tt_start(self, tt):
        self._tt_handlers = self.handle_data, self._tt_handle
        self._tt_handle(tt)

    def tt_parse(self, tt, style):
        """parse from tupletree form"""
        self._setup_for_parse(style)
        self._tt_start(tt)
        return self._complete_parse()

    def findSpanStyle(self, style):
        raise ValueError("findSpanStyle not implemented in this parser")

    # HTMLParser interface
    def parse(self, text, style):
        "attempt replacement for parse"
        self._setup_for_parse(style)
        text = asUnicode(text)
        if not (len(text) >= 6 and text[0] == "<" and _re_para.match(text)):
            text = "<para>" + text + "</para>"
        try:
            self.feed(text)
        except:
            annotateException("\nparagraph text %s caused exception" % ascii(text))
        return self._complete_parse()

    def handle_starttag(self, tag, attrs):
        "Called by HTMLParser when a tag starts"

        # tuple tree parser used to expect a dict.  HTML parser
        # gives list of two-element tuples
        if isinstance(attrs, list):
            d = {}
            for k, v in attrs:
                d[k] = v
            attrs = d
        if not self.caseSensitive:
            tag = tag.lower()
        try:
            start = getattr(self, "start_" + tag)
        except AttributeError:
            if not self.ignoreUnknownTags:
                raise ValueError('Invalid tag "%s"' % tag)
            start = self.start_unknown
        # call it
        start(attrs or {})

    def handle_endtag(self, tag):
        "Called by HTMLParser when a tag ends"
        # find the existing end_tagname method
        if not self.caseSensitive:
            tag = tag.lower()
        try:
            end = getattr(self, "end_" + tag)
        except AttributeError:
            if not self.ignoreUnknownTags:
                raise ValueError('Invalid tag "%s"' % tag)
            end = self.end_unknown
        # call it
        end()

    def handle_entityref(self, name):
        "Handles a named entity."
        try:
            v = known_entities[name]
        except:
            v = "&%s;" % name
        self.handle_data(v)


if __name__ == "__main__":
    from reportlab.lib.styles import _baseFontName
    from reportlab.platypus import cleanBlockQuotedText

    _parser = ParaParser()

    def check_text(text, p=_parser):
        print("##########")
        text = cleanBlockQuotedText(text)
        l, rv, bv = p.parse(text, style)
        if rv is None:
            for l in _parser.errors:
                print(l)
        else:
            print("ParaStyle", l.fontName, l.fontSize, l.textColor)
            for l in rv:
                sys.stdout.write(l.fontName, l.fontSize, l.textColor, l.bold, l.rise, "|%s|" % l.text[:25])
                if hasattr(l, "cbDefn"):
                    print("cbDefn", getattr(l.cbDefn, "name", ""), getattr(l.cbDefn, "label", ""), l.cbDefn.kind)
                else:
                    print()

    style = ParaFrag()
    style.fontName = _baseFontName
    style.fontSize = 12
    style.textColor = black
    style.bulletFontName = black
    style.bulletFontName = _baseFontName
    style.bulletFontSize = 12

    text = """
    <b><i><greek>a</greek>D</i></b>&beta;<unichr value="0x394"/>
    <font name="helvetica" size="15" color=green>
    Tell me, O muse, of that ingenious hero who travelled far and wide
    after</font> he had sacked the famous town of Troy. Many cities did he visit,
    and many were the nations with whose manners and customs he was acquainted;
    moreover he suffered much by sea while trying to save his own life
    and bring his men safely home; but do what he might he could not save
    his men, for they perished through their own sheer folly in eating
    the cattle of the Sun-god Hyperion; so the god prevented them from
    ever reaching home. Tell me, too, about all these things, O daughter
    of Jove, from whatsoever source you<super>1</super> may know them.
    """
    check_text(text)
    check_text("<para> </para>")
    check_text(
        '<para font="%s" size=24 leading=28.8 spaceAfter=72>ReportLab -- Reporting for the Internet Age</para>'
        % _baseFontName
    )
    check_text(
        """
    <font color=red>&tau;</font>Tell me, O muse, of that ingenious hero who travelled far and wide
    after he had sacked the famous town of Troy. Many cities did he visit,
    and many were the nations with whose manners and customs he was acquainted;
    moreover he suffered much by sea while trying to save his own life
    and bring his men safely home; but do what he might he could not save
    his men, for they perished through their own sheer folly in eating
    the cattle of the Sun-god Hyperion; so the god prevented them from
    ever reaching home. Tell me, too, about all these things, O daughter
    of Jove, from whatsoever source you may know them."""
    )
    check_text(
        '''
    Telemachus took this speech as of good omen and rose at once, for
    he was bursting with what he had to say. He stood in the middle of
    the assembly and the good herald Pisenor brought him his staff. Then,
    turning to Aegyptius, "Sir," said he, "it is I, as you will shortly
    learn, who have convened you, for it is I who am the most aggrieved.
    I have not got wind of any host approaching about which I would warn
    you, nor is there any matter of public moment on which I would speak.
    My grieveance is purely personal, and turns on two great misfortunes
    which have fallen upon my house. The first of these is the loss of
    my excellent father, who was chief among all you here present, and
    was like a father to every one of you; the second is much more serious,
    and ere long will be the utter ruin of my estate. The sons of all
    the chief men among you are pestering my mother to marry them against
    her will. They are afraid to go to her father Icarius, asking him
    to choose the one he likes best, and to provide marriage gifts for
    his daughter, but day by day they keep hanging about my father's house,
    sacrificing our oxen, sheep, and fat goats for their banquets, and
    never giving so much as a thought to the quantity of wine they drink.
    No estate can stand such recklessness; we have now no Ulysses to ward
    off harm from our doors, and I cannot hold my own against them. I
    shall never all my days be as good a man as he was, still I would
    indeed defend myself if I had power to do so, for I cannot stand such
    treatment any longer; my house is being disgraced and ruined. Have
    respect, therefore, to your own consciences and to public opinion.
    Fear, too, the wrath of heaven, lest the gods should be displeased
    and turn upon you. I pray you by Jove and Themis, who is the beginning
    and the end of councils, [do not] hold back, my friends, and leave
    me singlehanded- unless it be that my brave father Ulysses did some
    wrong to the Achaeans which you would now avenge on me, by aiding
    and abetting these suitors. Moreover, if I am to be eaten out of house
    and home at all, I had rather you did the eating yourselves, for I
    could then take action against you to some purpose, and serve you
    with notices from house to house till I got paid in full, whereas
    now I have no remedy."'''
    )

    check_text(
        """
But as the sun was rising from the fair sea into the firmament of
heaven to shed light on mortals and immortals, they reached Pylos
the city of Neleus. Now the people of Pylos were gathered on the sea
shore to offer sacrifice of black bulls to Neptune lord of the Earthquake.
There were nine guilds with five hundred men in each, and there were
nine bulls to each guild. As they were eating the inward meats and
burning the thigh bones [on the embers] in the name of Neptune, Telemachus
and his crew arrived, furled their sails, brought their ship to anchor,
and went ashore. """
    )
    check_text(
        """
So the neighbours and kinsmen of Menelaus were feasting and making
merry in his house. There was a bard also to sing to them and play
his lyre, while two tumblers went about performing in the midst of
them when the man struck up with his tune.]"""
    )
    check_text(
        """
"When we had passed the [Wandering] rocks, with Scylla and terrible
Charybdis, we reached the noble island of the sun-god, where were
the goodly cattle and sheep belonging to the sun Hyperion. While still
at sea in my ship I could bear the cattle lowing as they came home
to the yards, and the sheep bleating. Then I remembered what the blind
Theban prophet Teiresias had told me, and how carefully Aeaean Circe
had warned me to shun the island of the blessed sun-god. So being
much troubled I said to the men, 'My men, I know you are hard pressed,
but listen while I <strike>tell you the prophecy that</strike> Teiresias made me, and
how carefully Aeaean Circe warned me to shun the island of the blessed
sun-god, for it was here, she said, that our worst danger would lie.
Head the ship, therefore, away from the island."""
    )
    check_text("""A&lt;B&gt;C&amp;D&quot;E&apos;F""")
    check_text("""A&lt; B&gt; C&amp; D&quot; E&apos; F""")
    check_text("""<![CDATA[<>&'"]]>""")
    check_text(
        """<bullet face=courier size=14 color=green>+</bullet>
There was a bard also to sing to them and play
his lyre, while two tumblers went about performing in the midst of
them when the man struck up with his tune.]"""
    )
    check_text("""<onDraw name="myFunc" label="aaa   bbb">A paragraph""")
    check_text("""<para><onDraw name="myFunc" label="aaa   bbb">B paragraph</para>""")
    # HVB, 30.05.2003: Test for new features
    _parser.caseSensitive = 0
    check_text(
        """Here comes <FONT FACE="Helvetica" SIZE="14pt">Helvetica 14</FONT> with <STRONG>strong</STRONG> <EM>emphasis</EM>."""
    )
    check_text(
        """Here comes <font face="Helvetica" size="14pt">Helvetica 14</font> with <Strong>strong</Strong> <em>emphasis</em>."""
    )
    check_text("""Here comes <font face="Courier" size="3cm">Courier 3cm</font> and normal again.""")
    check_text("""Before the break <br/>the middle line <br/> and the last line.""")
    check_text("""This should be an inline image <img src='../../../docs/images/testimg.gif'/>!""")
    check_text("""aaa&nbsp;bbbb <u>underline&#32;</u> cccc""")
