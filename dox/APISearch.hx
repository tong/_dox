package dox;

import haxe.rtti.CType;

class APISearch {
	
	var active : Bool;
	var term : String;
	var traverser_packages : Array<TypeTree>;
	var traverser : Array<TypeTree>;
	
	public function new() {
		active = false;
	}
	
	public function run( term : String, root : TypeRoot, cb : Array<TypeTree>->Void ) {
		
		//trace( "Searching: '"+term+"' ..." );
		
		this.term = term.toLowerCase();
		
		active = true;
		traverser_packages = new Array();
		traverser = new Array();
		searchTypes( root );
		
		//traverser.sort( sortTypeByAlphapbet );
		traverser.sort( sortTypeBySearchTermPosition );
		traverser_packages.sort( sortPackageBySearchTermPosition );
		
		// TODO search/sort is complete remove unused length from array ... (?)
		//..
		
		// move full math to front
		var i = 0;
		var r = traverser.concat( traverser_packages );
		for( tree in r ) {
			switch(tree) {
			case TPackage(name,full,subs) : if( full == term ) { r.unshift( r.splice( i, 1 )[0] ); }
			case TTypedecl(t) : if( t.path == term ) { r.unshift( r.splice( i, 1 )[0] ); }
			case TEnumdecl(e) : if( e.path == term ) { r.unshift( r.splice( i, 1 )[0] ); }
			case TClassdecl(c) : if( c.path == term ) { r.unshift( r.splice( i, 1 )[0] ); }
			}
			i++;
		}
		
		//cb( traverser.concat( traverser_packages ) );
		//cb( traverser_packages.concat( traverser ) );
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
			case TPackage(name,full,subs) :
				if( compareStrings( full, term ) ) traverser_packages.push( tree );
				searchTypes( subs  );
			case TTypedecl(t) :
				if( compareStrings( t.path, term ) ) traverser.push( tree );
			case TEnumdecl(e) :
				if( compareStrings( e.path, term ) ) traverser.push( tree );
			case TClassdecl(c) :
				if( compareStrings( c.path, term ) ) traverser.push( tree );
			}
		}
	}
	
	inline function compareStrings( a : String, b : String ) : Bool {
		return a.toLowerCase().indexOf( b ) != -1;
	}
	
	function sortTypeByAlphapbet( a : TypeTree, b : TypeTree ) : Int {
		var na = Type.enumParameters(a)[0].path.toLowerCase();
		var nb = Type.enumParameters(b)[0].path.toLowerCase();
		var i = 0;
		while( i < na.length && i < nb.length ) {
			if( na.charCodeAt(i) < nb.charCodeAt(i) )
				return 1;
			i++;
		}
		return -1;
	}
	
	function sortTypeBySearchTermPosition( a : TypeTree, b : TypeTree ) : Int {
		var na = Type.enumParameters(a)[0].path.toLowerCase();
		var nb = Type.enumParameters(b)[0].path.toLowerCase();
		var i1 = na.indexOf( term );
		var i2 = nb.indexOf( term );
		/*
		if( i1 == i2 ) {
			return if( na.length > nb.length ) 1 else -1;
		} else {
			return if( i1 > i2 ) 1 else -1;
		}
		*/
		return ( i1 == i2 ) ? ( ( na.length > nb.length ) ? 1 : -1 ) : ( ( i1 > i2 ) ? 1 : -1 );
	}
	
	function sortPackageBySearchTermPosition( a : TypeTree, b : TypeTree ) : Int {
		var na = Type.enumParameters(a)[1].toLowerCase();
		var nb = Type.enumParameters(b)[1].toLowerCase();
		var i1 = na.indexOf( term );
		var i2 = nb.indexOf( term );
		if( i1 == i2 ) {
			return if( na.length > nb.length ) 1 else -1;
		} else {
			return if( i1 > i2 ) 1 else -1;
		}
	}
	
}
