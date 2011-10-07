package dox;

import haxe.rtti.CType;

class API {
	
	public static inline var REMOTE_API_HOST =
		#if DEBUG
		"http://192.168.0.110/dox.client//";	
		#else
		//TODO
		#end
		
	public var root(getRoot,null) : TypeRoot;
	
	var store : APIStore;
	var processor : dox.APIProcessor;
	
	public function new() {
		processor = new dox.APIProcessor();
	}
	
	inline function getRoot() : TypeRoot return processor.root
	
	public function init( cb : String->Void ) {
		store = new APIStoreWDB();
		store.init(function(apis){
			
			//clearStore(); return;

			trace( "API store ready ["+apis.length+"]" );
			if( apis.length == 0 ) {
				trace( "0 apis in database .. loading std from remote host" );
				loadRemote( "std", REMOTE_API_HOST+"std", cb );
			} else {
				for( a in apis ) {
					processor.mergeRoot( dox.APIJSONParser.parse( a.root ) );
				}
				cb( null );
			}
		});
	}
	
	public function loadRemote( name : String, url : String, cb : String->Void ) {
		var r = new haxe.Http( url );
		r.onData = function(t){
			store.set( { name : name, active : true, root : t }, function(e){
				var loaded = dox.APIJSONParser.parse( t );
				processor.mergeRoot( loaded );
				cb( null );
			});
		}
		r.onError = cb;
		r.request( false );
	}
	
	public function clearStore( ?cb : String->Void ) {
		store.clear( cb );
	}
	
	public function getTopLevel() : TypeRoot {
		var a = new Array<TypeTree>();
		for( t in root ) if( Type.enumIndex( t ) != 0 ) a.push( t );
		return a;
	}
	
	public function getTopLevelPackage() : TypeTree {
		return Type.createEnum( TypeTree, "TPackage", ["root","root",getTopLevel()] );
	}
	
}
