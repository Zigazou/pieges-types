GHC=ghc
PROGRAMS=abnf-parse abnf-generate
MODULES=Generator.hs Types.hs Parse.hs
TARBALL=/tmp/eusthatius.tar

all: ${PROGRAMS}

%: %.hs ${MODULES}
	${GHC} -o $@ --make $< 

dist: distrib

distrib: clean
	(cd ..; tar cvf ${TARBALL} Eusthatius)
	gzip --force --best --verbose ${TARBALL}

clean:
	rm -f *~ *.o *.hi *.parse test-generator ${PROGRAMS}
	rm -f compare/*~ tests/*~



