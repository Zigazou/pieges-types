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

def visual_separator():
    return HorizontalChoice("-", ".", "(", ")")

def phonedigit_hex():
    return Choice(
        0,
        HEXDIG(),
        "*",
        "#",
        Optional(
            Group(visual_separator(), "visual-separator")
        )
    )

def phonedigit():
    return Choice(
        0,
        DIGIT(),
        Optional(
            Group(visual_separator(), "visual-separator")
        )
    )

def param_unreserved():
    return HorizontalChoice("[", "]", "/", ":", "&", "+", "$")

def mark():
    return HorizontalChoice("-", "_", ".", "!", "~", "*", "'", "(", ")")

def unreserved():
    return Choice(0, alphanum(), mark())

def paramchar():
    return Choice(
        0,
        Group(param_unreserved(), "param_unreserved"),
        Group(unreserved(), "unreserved"),
        Group(pct_encoded(), "pct-encoded")
    )

def pname():
    return OneOrMore(Choice(0, alphanum(), "-"))

def pvalue():
    return OneOrMore(NonTerminal("paramchar"))

def parameter():
    return Sequence(";", pname(), Optional(Sequence("=", pvalue())))

def uric():
    return Choice(
        0,
        Group(reserved(), "reserved"),
        Group(unreserved(), "unreserved"),
        Group(pct_encoded(), "pct-encoded")
    )

def context():
    return NonTerminal("context")

def isdn_subaddress():
    return Sequence(";isub=", OneOrMore(NonTerminal("uric")))

def parameter():
    return Sequence(
        ";",
        pname(),
        Optional(
            Sequence("=", pvalue())
        )
    )

def toplabel():
    return Choice(
        0,
        ALPHA(),
        Sequence(
            ALPHA(),
            ZeroOrMore(Choice(0, alphanum(), "-")),
            alphanum()
        )
    )

def domainlabel():
    return Choice(0,
        alphanum(),
        Sequence(
            alphanum(),
            ZeroOrMore(Sequence(alphanum(), "-")),
            alphanum()
        )
    )

def domainname():
    return Sequence(
        ZeroOrMore(Sequence(Group(domainlabel(), "domainlabel"), ".")),
        Group(toplabel(), "toplabel"),
        Optional(".")
    )

def local_number_digits():
    return Sequence(
        ZeroOrMore(NonTerminal("phonedigit_hex")),
        Choice(0, HEXDIG(), "*", "#"),
        ZeroOrMore(NonTerminal("phonedigit_hex"))
    )

def global_number_digits():
    return Sequence(
        "+",
        ZeroOrMore(NonTerminal("phonedigit")),
        DIGIT(),
        ZeroOrMore(NonTerminal("phonedigit"))
    )

def descriptor():
    return Choice(
        0,
        Group(domainname(), "domainname"),
        Group(global_number_digits(), "global-number-digits")
    )

def context():
    return Sequence(";phone-context=", NonTerminal("descriptor"))

def extension():
    return Sequence(";ext=", OneOrMore(NonTerminal("phonedigit")))

def par():
    return Choice(
        0,
        Group(parameter(), "parameter"),
        Group(extension(), "extension"),
        Group(isdn_subaddress(), "isdn-subaddress")
    )

def local_number():
    return Sequence(
        local_number_digits(),
        ZeroOrMore(NonTerminal("par")),
        context(),
        ZeroOrMore(NonTerminal("par"))
    )

def global_number():
    return Sequence(global_number_digits(), ZeroOrMore(NonTerminal("par")))

def telephone_subscriber():
    return Choice(
        0,
        Group(global_number(), "global-number"),
        Group(local_number(), "local-number")
    )

def telephone_uri():
    return Sequence("tel:", telephone_subscriber())

diagram_write(telephone_uri(), "tel-uri-railroad-diagram/telephone_uri.svg")
diagram_write(par(), "tel-uri-railroad-diagram/par.svg")
diagram_write(phonedigit(), "tel-uri-railroad-diagram/phonedigit.svg")
diagram_write(phonedigit_hex(), "tel-uri-railroad-diagram/phonedigit_hex.svg")
diagram_write(descriptor(), "tel-uri-railroad-diagram/descriptor.svg")
diagram_write(unreserved(), "tel-uri-railroad-diagram/unreserved.svg")
diagram_write(paramchar(), "tel-uri-railroad-diagram/paramchar.svg")
diagram_write(uric(), "tel-uri-railroad-diagram/uric.svg")
