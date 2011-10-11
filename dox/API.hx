package dox;

import haxe.rtti.CType;

class API {

	public static inline var REMOTE_HOST = "https://raw.github.com/tong/dox/master/";
	//public static inline var REMOTE_HOST = "https://disktree.net/";

	/*
	public static inline var REMOTE_HOST =
		#if DEBUG
		"http://192.168.0.110/dox/";	
		#else
		"https://raw.github.com/tong/dox/master/"
		#end
	*/
	
	public var root(getRoot,null) : TypeRoot;
	public var store(default,null) : APIStore;
	
	var processor : dox.APIProcessor;
	
	public function new() {
		processor = new dox.APIProcessor();
		//TODO browser dependent
		store = new APIStoreWDB();
	}
	
	inline function getRoot() : TypeRoot return processor.root
	
	public function init( cb : String->Void ) {
		store.init(function(apis){
//			clearStore(); return;
			trace( "API store ready ("+apis.length+")" );
			if( apis.length == 0 ) {
				cb( "0" );
				return;
			}
			for( a in apis ) mergeString( a.root  );
			cb( null );
		});
	}
	
	public function addAPI( d : APIDescription, cb : String->Void ) {
		store.set( d, function(e){
			if( e != null ) cb(e) else {
				mergeString( d.root  );
				cb( null );
			}
		});
	}
	
	public function mergeString( t : String ) {
		processor.mergeRoot( dox.APIJSONParser.parse( t ) );
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
