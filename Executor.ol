include "runtime.iol"
include "file.iol"
include "console.iol"

include "Exec.iol"

execution { concurrent }

type CodeRequest:void {
	.code:string
}

interface CodeInterface {
	RequestResponse: exec(CodeRequest)(string), form(void)(string)
}

inputPort MyInput {
	Location: "socket://localhost:8000/"
	Protocol: http { .format = "html" }
	Interfaces: CodeInterface
}


outputPort CodeService{
	Interfaces: ExecutableInterface
}

main
{
  [ exec( request )( response ) {
	  f.filename = "tmp_exec.ol";

	  f.content = "include \"AbstractCodeCaller.iol\"
	  			   include \"console.iol\"
	  	define doStart
		{
			" +request.code+ " 
		}";

    writeFile@File(f)();
    response = f.content;
    scope( s ) {
    	with ( embedInfo ) {
			.type = "Jolie";
			.filepath = f.filename
		};
		loadEmbeddedService@Runtime( embedInfo )( CodeService.location );
		start@CodeService()()
	}

  }]{ nullProcess }

  [ form()(f) {
	f = "<html><body><form action='exec' method='POST'><label>Code to execute</label>:<br/><textarea name='code'></textarea><br/><input type='submit'/></form></body></html>"
  }]{ nullProcess }
}
