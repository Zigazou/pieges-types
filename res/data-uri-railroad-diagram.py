#!/usr/bin/env python3

import sys
from railroad import Diagram, Choice, Terminal, NonTerminal, Sequence, \
    MultipleChoice, Optional, OptionalSequence, Group, HorizontalChoice, \
    Stack, OneOrMore, ZeroOrMore

def diagram_write(element, filepath):
    with open(filepath, "w") as svg:
        Diagram(element).writeSvg(svg.write)

def ALPHA():
    return NonTerminal("ALPHA")

def DIGIT():
    return NonTerminal("DIGIT")

def HEXDIG():
    return NonTerminal("HEXDIG")

def pct_encoded():
    return Sequence("%", HEXDIG(), HEXDIG())

def reserved():
    return HorizontalChoice(";", "/", "?", ":", "@", "&", "=", "+", "$", ",")

def alphanum():
    return NonTerminal("ALPHANUM")

def unreserved():
    return Choice(
        0,
        HorizontalChoice(ALPHA(), DIGIT()),
        HorizontalChoice("-", ".", "_", "~")
    )

def uric():
    return Choice(
        0,
        Group(reserved(), "reserved"),
        Group(unreserved(), "unreserved"),
        Group(pct_encoded(), "pct-encoded")
    )

def attribute():
    return token()

def value():
    return Choice(0, token(), quoted_string())

def quoted_string():
    return Sequence('"', NonTerminal("ASCII"), '"')

def token():
    return OneOrMore(
        Choice(0, alphanum(), tspecials())
    )

def tspecials():
    return Choice(
        0,
        "(", ")", "<", ">", "@", ",", ";", ":", "\\", "/", "[", "]", "?", "="
    )

def type_():
    return Choice(0, discrete_type(), composite_type())

def discrete_type():
    return Choice(
        0,
        "text", "image", "audio", "video", "application",
        extension_token()
    )

def composite_type():
    return Choice(0, "message", "multipart", extension_token())

def extension_token():
    return Choice(0, ietf_token(), x_token())

def ietf_token():
    return NonTerminal("ietf-token")

def x_token():
    return Sequence(Choice(0, "X-", "x-"), NonTerminal("token"))

def subtype():
    return Choice(0, extension_token(), iana_token())

def iana_token():
    return NonTerminal("iana-token")

def parameter():
    return Sequence(attribute(), "=", value())

def data():
    return ZeroOrMore(uric())

def mediatype():
    return Sequence(
        Optional(Sequence(type_(), "/", subtype())),
        ZeroOrMore(Sequence(";", parameter()))
    )

def dataurl():
    return Sequence(
        "data:",
        Optional(mediatype()),
        Optional(";base64"),
        ",",
        data()
    )

diagram_write(dataurl(), "data-uri-railroad-diagram/dataurl.svg")

