find . -name "Move.toml" |
while read PACKAGE; do sui move test -p $PACKAGE; done
