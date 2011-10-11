package dox;

import haxe.rtti.CType;
using Lambda;
using StringTools;

class APISearch {
	
	public var active(default,null) : Bool;
	public var searchPrivateTypes : Bool;
	
	var term : String;
	var platforms : Array<String>;
	var traverser_packages : Array<TypeTree>;
	var traverser : Array<TypeTree>;
	
	public function new( searchPrivateTypes : Bool = false ) {
		this.searchPrivateTypes = searchPrivateTypes;
		active = false;
	}
	
	/**
		@term The term to search for
		@root The TypeRoot to search in
		@platforms Active haXe platforms
		@cb Callback method delivering the results
	*/
	public function run( term : String, root : TypeRoot, platforms : Array<String>, cb : TypeRoot->Void ) {
		
		//trace( "Searching: '"+term+"' ..."+platforms );
		
		this.term = term.toLowerCase();
		this.platforms = platforms;
		
		traverser_packages = new Array();
		traverser = new Array();
		active = true;
		
		searchTypes( root );
		
		//traverser.sort( sortTypeByAlphapbet );
		traverser.sort( sortTypeBySearchTermPosition );
		traverser_packages.sort( sortPackageBySearchTermPosition );
		
		var r = traverser.concat( traverser_packages );
		
		// move exact match to top
		var i = 0;
		for( tree in r ) {
			switch( tree ) {
			case TPackage(name,full,subs) : if( full == term ) { r.unshift( r.splice( i, 1 )[0] ); break; }
			case TTypedecl(t) : if( t.path == term ) { r.unshift( r.splice( i, 1 )[0] ); break; }
			case TEnumdecl(e) : if( e.path == term ) { r.unshift( r.splice( i, 1 )[0] ); break; }
			case TClassdecl(c) : if( c.path == term ) { r.unshift( r.splice( i, 1 )[0] ); break; }
			}
			i++;
		}
		
		cb( r );
	}
	
	public function abort() {
		active = false;
	}
	
	function searchTypes( root : TypeRoot ) {
		if( !active )
			return;
		for( tree in root ) {
			switch( tree ) {
			case TPackage(n,f,subs) :
				if( f == term )
					traverser_packages.push( tree );
				searchTypes( subs  );
			default :
				var t = TypeApi.typeInfos( tree );
				if( !searchPrivateTypes && t.isPrivate ) // "_"
					continue;
				if( compareStrings( t.path, term ) ) {
					var allowed = false;
					for( p in platforms ) {
						if( t.platforms.has( p ) ) {
							allowed = true;
							break;
						}
					}
					if( allowed )
						traverser.push( tree );
				}
			}
		}
	}
	
	inline function compareStrings( a : String, b : String ) : Bool {
		return a.toLowerCase().indexOf( b ) != -1;
	}
	
	function sortTypeByAlphapbet( a : TypeTree, b : TypeTree ) : Int {
		var na = Type.enumParameters(a)[0].path.toLowerCase();
		var nb = Type.enumParameters(b)[0].path.toLowerCase();
		var l = ( na.length < nb.length ) ? na.length : nb.length;
		for( i in 0...l ) {
			if( na.charCodeAt(i) < nb.charCodeAt(i) )
				return 1;
		}
		return -1;
	}
	
	function sortTypeBySearchTermPosition( a : TypeTree, b : TypeTree ) : Int {
		var na = Type.enumParameters(a)[0].path.toLowerCase();
		var nb = Type.enumParameters(b)[0].path.toLowerCase();
		var i1 = na.indexOf( term );
		var i2 = nb.indexOf( term );
		return ( i1 == i2 ) ? ( ( na.length > nb.length ) ? 1 : -1 ) : ( ( i1 > i2 ) ? 1 : -1 );
	}
	
	function sortPackageBySearchTermPosition( a : TypeTree, b : TypeTree ) : Int {
		var na = Type.enumParameters(a)[1].toLowerCase();
		var nb = Type.enumParameters(b)[1].toLowerCase();
		var i1 = na.indexOf( term );
		var i2 = nb.indexOf( term );
		return if( i1 == i2 ) {
			if( na.length > nb.length ) 1 else -1;
		} else {
			if( i1 > i2 ) 1 else -1;
		}
	}
	
}
