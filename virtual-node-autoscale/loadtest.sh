export GOPATH=~/go
export PATH=$GOPATH/bin:$PATH
go get -u github.com/rakyll/hey
# This URL might be different
hey -z 5m http://store.13.90.60.80.nip.io/