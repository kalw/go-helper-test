go install github.com/mumoshu/variant/cmd@v0.38.0
DIR_ROOT=${PWD}
for file in $(ls ./*.yaml); do 
    CMD_NAME=$(basename $file | sed -e 's/.yaml//')
    mkdir -p ./tmp/cmd/${CMD_NAME}
	cat << EOF > ./tmp/cmd/${CMD_NAME}/main.go
package main
import "github.com/mumoshu/variant/cmd"
func main() {
    cmd.YAML(\`
$(cat ${file})
\`)
}
EOF
    #cp .goreleaser.yaml $GOPATH/src/${CMD_NAME}/
    cat << EOF > .goreleaser.${CMD_NAME}.yaml
$(cat .goreleaser.yaml)
builds:
  - binary: ${CMD_NAME}
    #main: ./tmp/cmd/${CMD_NAME}/
    env:
      - CGO_ENABLED=0
    goos:
      - linux
      - windows
      - darwin
      - freebsd
EOF
    cd ./tmp/cmd/${CMD_NAME}/ 
    go mod init ${CMD_NAME}
    go get github.com/mumoshu/variant/cmd
    goreleaser release --snapshot -f ${DIR_ROOT}/.goreleaser.${CMD_NAME}.yaml
    cd ${DIR_ROOT}
done