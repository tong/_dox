package dox;

import haxe.rtti.CType;

class APIJSONParser {
	
	public static function parse( t : String ) : TypeRoot {
		var r : TypeRoot = JSON.parse( t );
		for( t in r ) prepareTree( t );
		return r;
	}
	
	static function prepareTree( tree : TypeTree ) {
		switch( tree ) {
		case TPackage(n,f,s) :
//			trace("--------------------------------- "+f );
			for( t in s ) prepareTree( t );
		case TTypedecl(t) :
//			trace("------------------------------------ TTypedecl  "+t.path );
			t.type = createType( t.type );
			var types = new Hash<CType>();
			for( f in Reflect.fields( untyped t.types.h ) ) types.set( f.substr(1), createType( Reflect.field( untyped t.types.h, f ) ) );
			t.types = types;
			t.platforms = createList( t.platforms );
		case TEnumdecl(e) :
//			trace("------------------------------------ TEnumdecl  "+e.path );
			e.platforms = createList( e.platforms );
			e.constructors = createList( e.constructors );
			for( c in e.constructors ) c.platforms = createList( c.platforms );
		case TClassdecl(c) :
//			trace("------------------------------------ TClassdecl "+c.path );
			if( c.tdynamic != null ) c.tdynamic = createType( c.tdynamic );
			if( c.superClass != null ) c.superClass.params = createList( c.superClass.params );
			repairFields( c, "statics" );
			/*
			for( f in c.statics ) {
				f.type = createType( f.type );
				f.platforms = createList( f.platforms );
			}
			*/
			c.platforms = createList( c.platforms );
			c.interfaces = createList( c.interfaces );
			for( i in c.interfaces ) {
				i.params = createList( i.params );
				if( i.params.length > 0 ) {
					//TODO interface params
				}
			}
			repairFields( c, "fields" );
			/*
			for( f in c.fields ) {
				f.type = createType( f.type );
				f.platforms = createList( f.platforms );
			}
			*/
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
			/*
			var args = createList( t[2] );
			for( a in args ) a.t = createType( a.t );
			trace(args);
			CFunction( args, createType( t[3] ) );
			*/
			var args = createList( t[2] );
			//trace(args);
			for( a in args ) {
				a.t = createType( a.t );
				//trace( a.t );
			}
			CFunction( args, createType( t[3] ) );
			
		case 5 :
			var l = createList( t[2] );
			for( a in l ) {
				a.t = createType( a.t );
			}
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
		//trace( "repairFields" );
		var l = createList( Reflect.field( c, field ) );
		for( f in l ) {
			
			f.type = createType( f.type );
			f.platforms = createList( f.platforms );
			
			//RIGHTS
			/*
		trace( Type.enumIndex( Rights.RNormal ) ); //0
		trace( Type.enumIndex( Rights.RNo ) ); //1
		trace( Type.enumIndex( Rights.RCall("23") ) ); //2
		trace( Type.enumIndex( Rights.RMethod ) ); //3
		trace( Type.enumIndex( Rights.RDynamic ) ); //4
		trace( Type.enumIndex( Rights.RInline ) ); //5
		trace( Type.createEnumIndex( Rights, 0 ) );
		trace( Type.createEnumIndex( Rights, 1 ) );
		trace( Type.createEnumIndex( Rights, 2, ["23"] ) );
		trace( Type.createEnumIndex( Rights, 3 ) );
		trace( Type.createEnumIndex( Rights, 4 ) );
		trace( Type.createEnumIndex( Rights, 5 ) );
			*/
			
			var i : Int = f.get[1];
			if( i == 2 ) untyped f.get = Type.createEnumIndex( Rights, i, [f.get[2]] );
			else untyped f.get = Type.createEnumIndex( Rights, i );
			
			i = f.set[1];
			if( i == 2 ) untyped f.get = Type.createEnumIndex( Rights, i, [f.set[2]] );
			else untyped f.set = Type.createEnumIndex( Rights, i );
		}
		//trace( l );
		Reflect.setField( c, field, l );
		//trace("<<<");
		/*
		var l = createList( Reflect.field( c, field ) );
		Reflect.setField( c, field, l );
		*/
	}
	
}