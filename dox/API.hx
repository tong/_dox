package dox;

import haxe.rtti.CType;

/**
 * 
 */
class API {

	public static inline var REMOTE_HOST = "https://raw.github.com/tong/dox/master/";
	
	public var root(getRoot,null) : TypeRoot;
	public var store(default,null) : APIStore; // TODO remove !
	
	var processor : dox.APIProcessor;
	
	public function new() {
		processor = new dox.APIProcessor();
		//TODO browser dependent
		#if chrome
		store = new APIStoreWDB();
		#elseif droid
//		store = new APIStoreFile();
		#end
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
	
	// is this really required here ? ....->
	
	public inline function getType( path : String ) : Dynamic {
		return _get( root, path );
	}
	
	function _get( root : TypeRoot, path : String ) : Dynamic {
		for( tree in root ) {
			switch( tree ) {
			case TPackage(n,f,subs) :
				//if( f == path ) return tree;
				var c = _get( subs, path );
				if( c != null ) return c;
			case TTypedecl(t) :
				if( t.path == path ) return t;
			case TEnumdecl(e) :
				if( e.path == path ) return e;
			case TClassdecl(c) :
				//trace(c.path +" : "+ path);
				if( c.path == path ) {
					return c;
				}
			}
		}
		return null;
	}
	
}
