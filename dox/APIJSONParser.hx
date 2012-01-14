package dox;

import haxe.rtti.CType;
#if cpp
import hxjson2.JSON;
#end

/**
	Reads a typetree from a json string
*/
class APIJSONParser {
	
	public static function parse( t : String ) : TypeRoot {
		//var stime = haxe.Timer.stamp();
		var r : TypeRoot = JSON.parse( t );
		//trace(haxe.Timer.stamp()-stime);
		for( t in r ) prepareTree( t );
		return r;
		/*
		var w = new Worker("js/worker/json.js");
		w.onmessage = function(e){
			trace(haxe.Timer.stamp()-stime);
			cb(e.data);
		}
		w.postMessage( t );
		*/
	}
	
	static function prepareTree( tree : TypeTree ) {
		switch( tree ) {
		case TPackage(n,f,s) :
			for( t in s ) prepareTree( t );
		case TTypedecl(t) :
			t.type = createType( t.type );
			var types = new Hash<CType>();
			for( f in Reflect.fields( untyped t.types.h ) ) types.set( f.substr(1), createType( Reflect.field( untyped t.types.h, f ) ) );
			t.types = types;
			t.platforms = createList( t.platforms );
		case TEnumdecl(e) :
			e.platforms = createList( e.platforms );
			e.constructors = createList( e.constructors );
			for( c in e.constructors ) c.platforms = createList( c.platforms );
		case TClassdecl(c) :
			if( c.tdynamic != null ) c.tdynamic = createType( c.tdynamic );
			if( c.superClass != null ) c.superClass.params = createList( c.superClass.params );
			repairFields( c, "statics" );
			c.platforms = createList( c.platforms );
			c.interfaces = createList( c.interfaces );
			for( i in c.interfaces ) {
				i.params = createList( i.params );
				if( i.params.length > 0 ) {
					//TODO interface params
				}
			}
			repairFields( c, "fields" );
		}
	}
	
	static function createList<T>( d : Dynamic ) : List<T>  {
		var l = new List<T>();
		untyped l.q = d.q;
		untyped l.h = d.h;
		untyped l.length = d.length;
		return l;
	}
	
	static function createType( t : Dynamic ) : CType {
		return switch( t[1] ) {
		case 0 :
			CUnknown;
		case 1 :
			CEnum( t[2], createTypeParams( t[3] ) );
		case 2 :
			CClass( t[2], createTypeParams( t[3] ) );
		case 3 :
			CTypedef( t[2], createTypeParams( t[3] ) );
		case 4 :
			var args = createList( t[2] );
			for( a in args )
				a.t = createType( a.t );
			CFunction( args, createType( t[3] ) );
		case 5 :
			var l = createList( t[2] );
			for( a in l )
				a.t = createType( a.t );
			CAnonymous( l );
		case 6 :
			CDynamic( ( t.t != null ) ? createType( t.t ) : null );
		}
	}
	
	static function createTypeParams( t : Dynamic ) : List<CType> {
		/*
		var r = createList( t );
		for( p in r ) p = createType( p );
		return r;
		*/
		var r = new List<CType>();
		var l = createList( t );
		for( p in l ) {
			r.add( createType(p) );
		}
		return r;
	}
	
	static function repairFields( c : Dynamic, field : String ) {
		var l = createList( Reflect.field( c, field ) );
		for( f in l ) {
			//
			f.type = createType( f.type );
			f.platforms = createList( f.platforms );
			// RIGHTS
			var i : Int = f.get[1];
			if( i == 2 ) untyped f.get = Type.createEnumIndex( Rights, i, [f.get[2]] );
			else untyped f.get = Type.createEnumIndex( Rights, i );
			i = f.set[1];
			if( i == 2 ) untyped f.get = Type.createEnumIndex( Rights, i, [f.set[2]] );
			else untyped f.set = Type.createEnumIndex( Rights, i );
		}
		Reflect.setField( c, field, l );
	}
	
}
