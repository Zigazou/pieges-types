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

def reg_name():
    return ZeroOrMore(
        Choice(0, unreserved(), pct_encoded(), sub_delims())
    )

def pchar():
    return Choice(
        0,
        Group(unreserved(), "unreserved"),
        Group(pct_encoded(), "pct-encoded"),
        Group(sub_delims(), "sub-delims"),
        ":",
        "@"
    )

def host():
    return Choice(
        1,
        IP_literal(),
        IPv4address(),
        NonTerminal("reg-name")
    )

def userinfo():
    return ZeroOrMore(
        Choice(
            0,
            Group(unreserved(), "unreserved"),
            Group(pct_encoded(), "pct-encoded"),
            Group(sub_delims(), "sub-delims"),
            ":"
        )
    )

def sub_delims():
    return Choice(
        0,
        HorizontalChoice("!", "$", "&", "'", "(", ")"),
        HorizontalChoice("*", "+", ",", ";", "=")
    )

def unreserved():
    return Choice(
        0,
        HorizontalChoice(ALPHA(), DIGIT()),
        HorizontalChoice("-", ".", "_", "~")
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

def IPv4address():
    return Sequence(
        NonTerminal("dec-octet"), ".",
        NonTerminal("dec-octet"), ".",
        NonTerminal("dec-octet"), ".",
        NonTerminal("dec-octet")
    )

def IPv6address():
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

def IP_literal():
    return Sequence(
        "[",
        Choice(
            0,
            NonTerminal("IPv6address"),
            NonTerminal("IPvFuture")
        ),
        "]"
    )

def IPvFuture():
    return Sequence(
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
    )

def ls32():
    return Choice(
        0,
        Sequence(Group(h16(), "h16"), ":", Group(h16(), "h16")),
        Sequence(Group(IPv4address(), "IPv4address"))
    )

def segment_nz():
    return OneOrMore(pchar())

def segment():
    return ZeroOrMore(pchar())

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

def drive_letter():
    return Choice(0, Sequence(ALPHA(), ":"), Sequence(ALPHA()), "|")

def file_absolute():
    return Sequence("/", drive_letter(), path_absolute())

def inline_IP():
    return Sequence("%5B", Choice(0, IPv6address(), IPvFuture()), "%5D")

def file_host():
    return Choice(0, inline_IP(), IPv4address(), reg_name())

def unc_authority():
    return Sequence(Choice(0, "//", "///"), file_host())

def file_auth():
    return Choice(
        0,
        "localhost",
        Sequence(Optional(Sequence(userinfo(), "@")), host())
    )

def local_path():
    return Choice(
        0,
        Sequence(Optional(drive_letter()), path_absolute()),
        file_absolute()
    )

def auth_path():
    return Choice(
        0,
        Sequence(Optional(file_auth()), path_absolute()),
        Sequence(Optional(file_auth()), file_absolute()),
        unc_authority() #Sequence(unc_authority(), path_absolute())
    )

def file_hier_part():
    return Choice(0, Sequence("//", auth_path()), local_path())

def file_URI():
    return Sequence("file:", file_hier_part())

diagram_write(file_URI(), "file-uri-railroad-diagram/file_uri.svg")
