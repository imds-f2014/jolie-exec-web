include "exec.iol"

execution {single}

inputPort CodeServiceInput {
  Location: "local"
  Interfaces: ExecutableInterface
}

main
{
  start()() {
    doStart
  }
}
