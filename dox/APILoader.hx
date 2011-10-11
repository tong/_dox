package dox;

//TODO required

class APILoader {
	
	public dynamic function onSuccess( t : String ) {}
	public dynamic function onFail( e : String ) {}
	
	public var url : String;
	public var required : Bool;
	
	public function new( url : String ) {
		this.url = url;
	}
	
	public function load( required : Bool = false ) {
		this.required = required;
		if( untyped window.navigator.onLine )
			_load();
		else {
			if( required ) {
				//TODO
			} else {
				onFail( "not online" );
			}
		}
	}
	
	function onHTTPSuccess( t ) {
		onSuccess(t);
	}
	
	function onHTTPError( e ) {
		/*
		trace(e);
		if( required ) {
			//TODO
		}
		*/
		onFail(e);
	}
	
	function _load() {
		trace(url);
		var r = new haxe.Http( url );
		r.onData = onHTTPSuccess;
		r.onError = onHTTPError;
		r.request( false );
	}
	
}
