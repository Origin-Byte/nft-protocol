find . -name "Move.toml" -not -path "./local/*" |
while read PACKAGE; do sui move test -p $PACKAGE --gas_limit 5000000000; done
