package dox;

import haxe.rtti.CType;
using StringTools;

/*
private typedef TODO = {
	//var line : Int;
	var tree : TypeTree;
	var field : 
	var info : String;
}
*/

/*
private class List {
	function new() {
	}
}
*/

class API {

	//public var onAdd()
	//public var onRemove()
	
	public var root(getRoot,null) : TypeRoot;
	//public var store(default,null) : APIStore;
	
	var processor : dox.rtti.XMLParser;
	var traverser : Array<TypeTree>;
	var store : APIStore;
	//var apis : Array<APIDescription>;
	
	public function new() {
		store = new APIStore();
		//store.onAdd = function onStoreAdd;
		//store.onRemove
		processor = new dox.rtti.XMLParser();
		//apis = new Array();
	}
	
	inline function getRoot() : TypeRoot {
		return processor.root;
	}
	
	public function init( cb : String->Void ) {
		//TODO
		// load list of apis (infos)
		// load apis from local db marked as active
		// check if std is available
		store.init( function(apis) {
			if( apis.length == 0 ) {
				loadRemote( "http://192.168.0.110/dox.web/www/api_js.xml", function(e){
					cb( null );
				} );
			} else {
				for( api in apis ) {
					processor.parseString( api.content );
				}
				processor.sort();
				cb( null );
			}
		});
	}
	
	public function getBaseTree() : TypeTree {
		var a = new Array<TypeTree>();
		for( tree in root ) {
			if( Type.enumIndex(tree) != 0 )
				a.push(tree);
		}
		return Type.createEnum( TypeTree, "TPackage", ["root","root",a] );
		
	}
	
	//function loadAPIContents( api ) {
	
	public function clear() {
		processor.clear();
	}
	
	/*
	public function loadString( t : String, cb : String->Void ) {
		//var time = haxe.Timer.stamp();
		processor.parseString( t );
		//trace( processor.root );
		//trace( processor.root.length );
		processor.sort();
		//trace(  haxe.Timer.stamp()-time );
		//TODO apis.set( name, {} );
		cb( null );
	}
	
	public function loadURL( url : String, cb : String->Void ) {
		var time = haxe.Timer.stamp();
		var xhttp = new XMLHttpRequest();
		xhttp.open( "GET", url, false );
		xhttp.send(null);
		processor.parseXML( xhttp.responseXML );
		processor.sort();
		trace(  haxe.Timer.stamp()-time );
		cb( null );
	}
	
	public function loadRemote( name : String ) {
		//TODO load from dox webserver
	}
	*/
	
	public function loadRemote( url : String, cb : String->Void ) {
		var http = new haxe.Http( url );
		http.onData = function(t){
			trace( "API file loaded from remote host" );
			store.add( { name : "justtest", project : null, active : true, content : t }, function(err){
				trace("saved!");
				processor.parseString( t );
				processor.sort();
				cb( null );
			});
		}
		http.onError = cb;
		http.request(false);
	}
	
	/*
	public function set( root : TypeRoot ) {
		//this.api = api;
		processor.root = root;
	}

	public function addXml( x : Xml, platform : String, sort : Bool = false ) {
		processor.process( x, platform );
		if( sort ) processor.sort();
	}
	*/
	
	public function merge( tree : TypeTree, ?sort : Bool = true ) {
		processor.merge( tree );
		if( sort ) processor.sort();
	}
	
	
	public function remove( tree : TypeTree ) {
		//TODO
	}
	
	/*
	// hmmm lets create the todo list from the builder tool ?
	
	public function generateTODOList( ?root : TypeRoot ) : Array<TODO> {
		if( root == null ) root = this.root;
		var list = new Array<TODO>();
		_generateTODOList( list, root );
		return list;
	}
	
	function _generateTODOList( list : Array<TODO>, root : TypeTree ) {
		for( tree in root ) {
			switch( tree ) {
			case TTypedecl(t) :
			case TEnumdecl(e) :
			case TClassdecl(c) :
			case TPackage(name,full,subs) :
			}
		}
	}
	
	function searchLineWithTerm( term : String ) : Bool {
		//var i = indexOf( "TODO" )
	}
	
	*/
	
	public function getType( path : String ) : TypeTree {
		//if( root == null ) root = this.root;
		var pkg : TypeRoot = null;
		var i = path.indexOf(".");
		if( i == -1 ) {
			pkg = root;
		} else {
			var p = path.split(".");
			p.pop();
			pkg = getTypePackage( p );
		}
		//trace(pkg);
		for( tree in pkg ) {
			switch( tree ) {
			case TTypedecl(t) : if( t.path == path ) return tree;
			case TEnumdecl(e) : if( e.path == path ) return tree;
			case TClassdecl(c) : if( c.path == path ) return tree;
			case TPackage(name,full,subs) : if( full == path ) return tree;
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
	
	public function search( term : String ) : TypeRoot {
		trace( "Searching: '"+term+"' ..." );
		traverser = new Array();
		searchTypes( processor.root, term );
		//trace( traverser );
		//TODO sort
		//traverser.sort( sortByAlphabet );
		var r = new Array<TypeTree>();
		for( t in traverser ) {
			//if( t.path == term ) trace("23");
			r.push( t );
		}
		return r;
	}
	
	/*
	public function searchPackage( n : String ) : TypeRoot {
		// //TODO
		for( tree in root() ) {
			switch( tree ) {
			case TPackage(name,full,subs) :
				trace(name);
			default :
			}
		}
		return null;
	}
	*/
	
	function searchTypes( root : TypeRoot, term : String ) {
		for( tree in root ) {
			//if( !activeSearch ) return; // abort search
			switch( tree ) {
			case TPackage(name,full,subs) :
				if( name.fastCodeAt(0) == 95 ) // "_"
					continue;
				var parts = full.split( "." );
				for( p in parts ) {
					if( compareNames( p,term ) ) {
						traverser.push( tree );
					}
				}
				searchTypes( subs, term  );
			case TTypedecl(t) :
				if( compareNames( t.path, term ) ) {
					traverser.push(tree);
				}
			case TEnumdecl(e) :
				if( compareNames( e.path, term ) ) {
					traverser.push( tree );
				}
			case TClassdecl(c) :
				if( compareNames( c.path, term ) ) {
					traverser.push( tree );
				}
			}
		}
	}
	
	inline function compareNames( a : String, b : String ) : Bool {
		return a.toLowerCase().indexOf( b.toLowerCase() ) != -1;
	}
	
}
