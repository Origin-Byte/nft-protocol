find . -name "Move.toml" -not -path "./local/*" |
while read PACKAGE; do sui move test -p $PACKAGE; done
