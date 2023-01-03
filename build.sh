echo 'install needed go bin'
go install github.com/mumoshu/variant@v0.38.0
go install github.com/goreleaser/goreleaser@latest
DIR_ROOT=${PWD}
for file in $(ls ./*-wrapper); do 
    CMD_NAME=$(basename $file | sed -e 's/-wrapper//')
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
project_name: ${CMD_NAME}
EOF
    cd ./tmp/cmd/${CMD_NAME}/ 
    go mod init ${CMD_NAME}
    go get github.com/mumoshu/variant/cmd
    goreleaser release -f ${DIR_ROOT}/.goreleaser.${CMD_NAME}.yaml
    cd ${DIR_ROOT}
done