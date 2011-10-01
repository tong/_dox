package dox;

import haxe.rtti.CType;
using StringTools;

class API {
	
	public static inline var REMOTE_HOST = "http://192.168.0.110/dox.c/";	
	
	//public var onAdd(default,null) : EventDispatcher<>;
	//public var onRemove()
	
	public var root(getRoot,null) : TypeRoot;
	//public var activeHaxeTargets(default,null) : Array<HaXeTarget>;
	
	var list : Array<APIDescription>;
	var store : APIStore;
	var processor : dox.rtti.XMLParser;
	var platforms : Array<String>;
	
	public function new() {
		//list = new Array();
		processor = new dox.rtti.XMLParser();
		//activeHaxeTargets = new Array();
		platforms = ["flash","js","neko","php"];
	}
	
	inline function getRoot() : TypeRoot return processor.root
	
	public function init( cb : String->Void ) {
		
		store = new APIStoreWDB();
		store.init( function(apis){
			if( apis == null ) {
				cb( "failed to init api store" );
				return;
			}
			list = apis;
			trace( list.length );
			if( list.length == 0 ) {
				//loadRemote( "http://192.168.0.110/dox/std.xml", function(e){
				trace( "Loading from remote url" );
				var t = haxe.Http.requestUrl( "http://192.168.0.110/dox.c/std.xml" );
				//parseString( t, true );
				/*
				var t = haxe.Http.requestUrl( "http://192.168.0.110/dox.c/std.xml" );
				var d = { name : "std", content : t };
				store.set( d, function(e){
					if( e != null ) {
						cb(e);
						return;
					}
					list.push(d);
					parseString( t, true );
					trace( root.length );
					cb(null);
				});
				*/
				
			} else {
				/*
				for( api in list ) {
					parseString( api.content );
					//processor.parseString( api.content,);
				}
				sort();
				trace( root.length );
				cb( null );
				*/
			}
		});
	}
	
	/*
	public function init( cb : String->Void ) {
	
		//var stime = haxe.Timer.stamp();
		store = new APIStore();
		store.init( function(r){
			if( r == null )
				cb( "failed to init database" );
			else if( r.length == 0 ) {
				// here ? not in application layer
				var t = haxe.Http.requestUrl( REMOTE_HOST+"api_std.xml" );
				trace("Remote file loaded");
				store.set( "std", t, function(e){
					if( e != null ) {
						processor.parseString( t, "flash" );
						processor.sort();
						cb( null );
					} else cb(e);
				});
			} else {
				for( d in r ) {
					//trace( d.name+":"+d.active );
					if( d.active ) {
						processor.parseString( d.content, "flash" );
					}
				}
				processor.sort();
				list = r;
				cb( null );
			}
		});
				
		/*
		processor.root = haxe.Unserializer.run( LocalStorage.getItem("testapi") );
		trace( processor.root.length );
		trace(">>>> "+( haxe.Timer.stamp()-stime) );
		
		trace(processor.root.length);
		*/
		
		/*
		var t = haxe.Http.requestUrl( "http://192.168.0.110/dox.chrome/api/flash.xml" );
		processor.parseString( t, "flash9" );
		processor.sort();
		trace(processor.root); // 33
		*/
		
		//var d = JSON.stringify( processor.root );
		//trace( JSON.parse( d ).length );
		
		//var d = haxe.Serializer.run( processor.root );
		//trace( haxe.Unserializer.run( d ).length );
		//LocalStorage.setItem( "testapi", d );
		
		/*
		trace(">");
		//var d = JSON.stringify( processor.root );
		//trace(d);
		
		//var rr = JSON.parse(d);
		//trace(">");
		//trace(rr);

		LocalStorage.setItem( "testapi", d );
		*/
		//TODO
		// load list of apis (infos)
		// load apis from local db marked as active
		// check if std is available
		/*
		store.init( function(e) {
			trace(">>>>");
	//		var t = haxe.Http.requestUrl( "http://192.168.0.110/dox.chrome/api/flash.xml" );
	//		store.save("test",t);
			/*
			store.get( 0,
				function(api){
					trace( "Std API loaded " );
					cb( null );
				},
				function(e){
					trace( e );
					cb( e );
				}
			);
//			processor.sort();
//			cb( null );
		});
	}
		*/
	
	/*
	public inline function iterator() : Iterator<APIDescription> {
		return list.iterator();
	}
	*/
	
	public function getTopLevel() : TypeRoot {
		var a = new Array<TypeTree>();
		for( t in root ) if( Type.enumIndex( t ) != 0 ) a.push( t );
		return a;
	}
	
	public function getTopLevelPackage() : TypeTree {
		return Type.createEnum( TypeTree, "TPackage", ["root","root",getTopLevel()] );
	}
	
	public function clear() {
		processor.clear();
	}
	
	public inline function sort() {
		processor.sort();
	}
	
	public function parseString( t : String, sort : Bool = false ) {
		for( p in platforms ) processor.parseString( t, p );
		if( sort ) processor.sort();
	}
	
	/*
	public function loadRemote( url : String, cb : String->Void ) {
		var r = new haxe.Http( url );
		r.onData = function(t){
			loadString( t );
		}
		r.onError = cb;
		r.request(false);
	}
	*/
	
	/*
	public function loadString( t : String, platforms : Array<String>, sort : Bool = false ) {
		//for( p in platforms ) processor.parseString( t, p );
		if( sort ) processor.sort();
	}
	*/
	
	/*
	public function loadRemote( name : String, url : String, platform : String, cb : String->Void ) {
		trace( "Loading remote API file [ "+name+", "+platform+", "+url+" ]" );
		var r = new haxe.Http( url );
		r.onData = function(t){
			trace( "Remote API file loaded." );
			//store.add( { name : name, project : null, active : true, content : t }, function(err){
			store.add( { name : name }, function(err){
				trace("saved!");
				//processor.parseString( t, "js" );
				processor.parseString( t, platform );
				processor.sort();
				cb( null );
			});
		//processor.parseString( t, platform );
		//	processor.sort();
		//	cb(null);
		}
		r.onError = cb;
		r.request(false);
	}
	*/
	
	/*
	public function loadRemoteAPIs( a : Array<{url:String,platform:String}>, cb : String->Void ) {
	}
	*/
	
	public function merge( tree : TypeTree, ?sort : Bool = true ) {
		processor.merge( tree );
		if( sort ) processor.sort();
	}
	
	public function remove( tree : TypeTree ) {
		//TODO
	}
	
	public function getType( path : String ) : TypeTree {
		var pkg : TypeRoot = null;
		var i = path.indexOf( "." );
		if( i == -1 ) pkg = root;
		else {
			var p = path.split( "." );
			p.pop();
			pkg = getTypePackage( p );
		}
		for( tree in pkg ) {
			return switch( tree ) {
			case TTypedecl(t) : if( t.path == path ) tree;
			case TEnumdecl(e) : if( e.path == path ) tree;
			case TClassdecl(c) : if( c.path == path ) tree;
			case TPackage(name,full,subs) : if( full == path ) tree;
			}
		}
		return null;
	}
	
	function getTypePackage( path : Array<String> ) : TypeRoot {
		for( tree in root ) {
			var p = _getTypePackage( path, tree, 0 );
			if( p != null ) {
				return p;
			}
		}
		return null;
	}
	
	function _getTypePackage( path : Array<String>, tree : TypeTree, depth : Int ) : TypeRoot {
		var p = path[depth];
		switch( tree ) {
		case TPackage(n,f,subs) :
			if( n == p ) {
				if( f == path.join(".") ) {
					return subs;
				}
				depth++;
				for( sub in subs ) {
					var p = _getTypePackage( path, sub, depth );
					if( p != null ) {
						return p;
					}
				}
				//return _getTypePackage( path, subs, ++depth );
			}
		default :
		}
		return null;
	}
	
	#if DEBUG
	
	public function toString() : String {
		return "API: "+root.length+"trees";
	}
	
	#end
	
}
