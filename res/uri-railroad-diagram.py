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

def unreserved():
    return Choice(
        0,
        HorizontalChoice(ALPHA(), DIGIT()),
        HorizontalChoice("-", ".", "_", "~")
    )

def pct_encoded():
    return [ "%", HEXDIG(), HEXDIG() ]

def sub_delims():
    return Choice(
        0,
        HorizontalChoice("!", "$", "&", "'", "(", ")"),
        HorizontalChoice("*", "+", ",", ";", "=")
    )


def pchar():
    return [
        Group(unreserved(), "unreserved"),
        Group(Sequence(*pct_encoded()), "pct-encoded"),
        Group(sub_delims(), "sub-delims"),
        ":",
        "@"
    ]

def scheme():
    return Sequence(
        ALPHA(),
        ZeroOrMore(
            HorizontalChoice(ALPHA(), DIGIT()),
            HorizontalChoice("+", "-", ".")
        )
    )

def reg_name():
    return ZeroOrMore(
        Choice(
            0,
            unreserved(),
            Sequence(*pct_encoded()),
            sub_delims()
        )
    )

def host():
    return Choice(
        1,
        Sequence(*ip_literal()),
        Sequence(*ipv4address()),
        NonTerminal("reg-name")
    )

def port():
    return NonTerminal("port")

def userinfo():
    return ZeroOrMore(
        Choice(
            0,
            Group(unreserved(), "unreserved"),
            Group(Sequence(*pct_encoded()), "pct-encoded"),
            Group(sub_delims(), "sub-delims"),
            ":"
        )
    )

def h16():
    return Sequence(
        HEXDIG(), Optional(Sequence(
            HEXDIG(), Optional(Sequence(
                HEXDIG(), Optional(HEXDIG())
            ))
        ))
    )

def dec_octet():
    return Choice(
        0,
        DIGIT(),
        Sequence(
            HorizontalChoice( "1", "2", "3", "4", "5", "6", "7", "8", "9"),
            DIGIT()
        ),
        Sequence("1", DIGIT(), DIGIT()),
        Sequence("2", HorizontalChoice("0", "1", "2", "3", "4"), DIGIT()),
        Sequence("25", HorizontalChoice("0", "1", "2", "3", "4", "5"))
    )

def ipv4address():
    return [
        NonTerminal("dec-octet"), ".",
        NonTerminal("dec-octet"), ".",
        NonTerminal("dec-octet"), ".",
        NonTerminal("dec-octet")
    ]

def ipv6address():
    return Choice(
        0,
        Sequence(
            NonTerminal("h16"), ":",
            NonTerminal("h16"), ":",
            NonTerminal("h16"), ":",
            NonTerminal("h16"), ":",
            NonTerminal("h16"), ":",
            NonTerminal("h16"), ":",
            NonTerminal("ls32")
        ),
        Sequence(
            "::",
            NonTerminal("h16"), ":",
            NonTerminal("h16"), ":",
            NonTerminal("h16"), ":",
            NonTerminal("h16"), ":",
            NonTerminal("h16"), ":",
            NonTerminal("ls32")
        ),
        Sequence(
            Optional(NonTerminal("h16")),
            "::",
            NonTerminal("h16"), ":",
            NonTerminal("h16"), ":",
            NonTerminal("h16"), ":",
            NonTerminal("h16"), ":",
            NonTerminal("ls32")
        ),
        Sequence(
            Optional(
                Sequence(
                    Optional(Sequence(NonTerminal("h16"), ":")),
                    NonTerminal("h16")
                )
            ),
            "::",
            NonTerminal("h16"), ":",
            NonTerminal("h16"), ":",
            NonTerminal("h16"), ":",
            NonTerminal("ls32")
        ),
        Sequence(
            Optional(
                Sequence(
                    Optional(Sequence(
                        NonTerminal("h16"), ":",
                        Optional(Sequence(
                            NonTerminal("h16"),":"
                        ))
                    )),
                    NonTerminal("h16")
                )
            ),
            "::",
            NonTerminal("h16"), ":",
            NonTerminal("h16"), ":",
            NonTerminal("ls32")
        ),
        Sequence(
            Optional(
                Sequence(
                    Optional(Sequence(
                        NonTerminal("h16"), ":",
                        Optional(Sequence(
                            NonTerminal("h16"),":",
                            Optional(Sequence(
                                NonTerminal("h16"),":"
                            ))
                        ))
                    )),
                    NonTerminal("h16")
                )
            ),
            "::",
            NonTerminal("h16"), ":",
            NonTerminal("ls32")
        ),
        Sequence(
            Optional(
                Sequence(
                    Optional(Sequence(
                        NonTerminal("h16"), ":",
                        Optional(Sequence(
                            NonTerminal("h16"),":",
                            Optional(Sequence(
                                NonTerminal("h16"),":",
                                Optional(Sequence(
                                    NonTerminal("h16"),":"
                                ))
                            ))
                        ))
                    )),
                    NonTerminal("h16")
                )
            ),
            "::",
            NonTerminal("ls32")
        ),
        Sequence(
            Optional(
                Sequence(
                    Optional(Sequence(
                        NonTerminal("h16"), ":",
                        Optional(Sequence(
                            NonTerminal("h16"),":",
                            Optional(Sequence(
                                NonTerminal("h16"),":",
                                Optional(Sequence(
                                    NonTerminal("h16"),":",
                                    Optional(Sequence(
                                        NonTerminal("h16"),":"
                                    ))
                                ))
                            ))
                        ))
                    )),
                    NonTerminal("h16")
                )
            ),
            "::",
            NonTerminal("h16")
        ),
        Sequence(
            Optional(
                Sequence(
                    Optional(Sequence(
                        NonTerminal("h16"), ":",
                        Optional(Sequence(
                            NonTerminal("h16"),":",
                            Optional(Sequence(
                                NonTerminal("h16"),":",
                                Optional(Sequence(
                                    NonTerminal("h16"),":",
                                    Optional(Sequence(
                                        NonTerminal("h16"),":",
                                        Optional(Sequence(
                                            NonTerminal("h16"),":"
                                        ))
                                    ))
                                ))
                            ))
                        ))
                    )),
                    NonTerminal("h16")
                )
            ),
            "::"
        )
    )

def ip_literal():
    return [
        "[",
        Choice(
            0,
            NonTerminal("IPv6address"),
            NonTerminal("IPvFuture")
        ),
        "]"
    ]

def ipvfuture():
    return [
        "v",
        OneOrMore(NonTerminal("HEXDIG")),
        ".",
        OneOrMore(
            Choice(
                0,
                unreserved(),
                sub_delims(),
                ":"
            )
        )
    ]

def ls32():
    return Choice(
        0,
        Sequence(Group(h16(), "h16"), ":", Group(h16(), "h16")),
        Sequence(Group(Sequence(*ipv4address()), "IPv4address"))
    )

def authority():
    return [
        Optional(Sequence(NonTerminal("userinfo"), "@")),
        NonTerminal("host"),
        Optional(Sequence(":", NonTerminal("port")))
    ]

def segment_nz():
    return OneOrMore(Choice(0, *pchar()))

def segment():
    return ZeroOrMore(Choice(0, *pchar()))

def path_abempty():
    return Optional(Sequence("/", NonTerminal("segment")))

def path_absolute():
    return Sequence(
        "/",
        Optional(
            Sequence(
                NonTerminal("segment-nz"),
                Optional(Sequence("/", NonTerminal("segment")))
            )
        )
    )

def path_rootless():
    return Sequence(
        NonTerminal("segment-nz"),
        Optional(Sequence("/", NonTerminal("segment")))
    )

def path_empty():
    return NonTerminal("path-empty")

def hier_part():
    return Optional(
        Choice(
            0,
            Sequence(
                "//",
                Group(Sequence(*authority()), "authority"),
                Group(path_abempty(), "path-abempty")
            ),
            Group(path_absolute(), "path-absolute"),
            Group(path_rootless(), "path-rootless")
        )
    )

def query():
    return ZeroOrMore(
        Group(Choice(0, *pchar()), "pchar"),
        "/", "?"
    )

def fragment():
    return ZeroOrMore(
        Group(Choice(0, *pchar()), "pchar"),
        "/", "?"
    )

def uri():
    return Sequence(
        NonTerminal("scheme"), ":",
        Group(hier_part(), "hier-part"),
        Optional(Sequence("?", NonTerminal("query"))),
        Optional(Sequence("#", NonTerminal("fragment")))
    )



diagram_write(uri(), "uri-railroad-diagram/uri.svg")
diagram_write(segment(), "uri-railroad-diagram/segment.svg")
diagram_write(scheme(), "uri-railroad-diagram/scheme.svg")
diagram_write(segment_nz(), "uri-railroad-diagram/segment_nz.svg")
diagram_write(Choice(0, *pchar()), "uri-railroad-diagram/pchar.svg")
diagram_write(query(), "uri-railroad-diagram/query.svg")
diagram_write(fragment(), "uri-railroad-diagram/fragment.svg")
diagram_write(userinfo(), "uri-railroad-diagram/userinfo.svg")
diagram_write(h16(), "uri-railroad-diagram/h16.svg")
diagram_write(ls32(), "uri-railroad-diagram/ls32.svg")
diagram_write(dec_octet(), "uri-railroad-diagram/dec_octet.svg")
diagram_write(Sequence(*ipv4address()), "uri-railroad-diagram/ipv4address.svg")
diagram_write(ipv6address(), "uri-railroad-diagram/ipv6address.svg")
diagram_write(Sequence(*ip_literal()), "uri-railroad-diagram/ip_literal.svg")
diagram_write(Sequence(*ipvfuture()), "uri-railroad-diagram/ipvfuture.svg")
diagram_write(host(), "uri-railroad-diagram/host.svg")
diagram_write(reg_name(), "uri-railroad-diagram/reg_name.svg")
