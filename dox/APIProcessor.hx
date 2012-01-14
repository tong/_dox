package dox;

import haxe.rtti.CType;

/**

*/
class APIProcessor {
	
	public var root : TypeRoot;
	
	var curplatform : String;
	
	public function new( ?root : TypeRoot ) {
		if( root == null ) clear() else this.root = root;
	}
	
	public inline function clear() root = new Array()
	
	public function mergeRoot( root : TypeRoot ) {
		for( t in root ) {
			switch(t) {
			case TPackage(n,f,subs) :
				mergeRoot( subs );
				continue;
				//for( s in subs ) merge(t);
				//continue;
			default :
			}
			merge( t );
		}
	}
	
	public function merge( t : TypeTree ) {
		var inf = TypeApi.typeInfos(t);
		var pack = inf.path.split(".");
		var cur = root;
		var curpack = new Array();
		pack.pop();
		for( p in pack ) {
			var found = false;
			for( pk in cur )
				switch( pk ) {
				case TPackage(pname,_,subs):
					if( pname == p ) {
						found = true;
						cur = subs;
						break;
					}
				default:
				}
			curpack.push(p);
			if( !found ) {
				var pk = new Array();
				cur.push(TPackage(p,curpack.join("."),pk));
				cur = pk;
			}
		}
		var prev = null;
		for( ct in cur ) {
			var tinf;
			try
				tinf = TypeApi.typeInfos(ct)
			catch( e : Dynamic )
				continue;
			// compare params ?
			if( tinf.path == inf.path ) {
				if( tinf.module == inf.module && tinf.doc == inf.doc && tinf.isPrivate == inf.isPrivate )
					switch( ct ) {
					case TClassdecl(c):
						switch( t ) {
						case TClassdecl(c2):
							if( mergeClasses(c,c2) )
								return;
						default:
						}
					case TEnumdecl(e):
						switch( t ) {
						case TEnumdecl(e2):
							if( mergeEnums(e,e2) )
								return;
						default:
						}
					case TTypedecl(td):
						switch( t ) {
						case TTypedecl(td2):
							if( mergeTypedefs(td,td2) )
								return;
						default:
						}
					case TPackage(_,_,_):
					}
				// we already have a mapping, but which is incompatible
				throw "Incompatibilities between "+tinf.path+" in "+tinf.platforms.join(",")+" and "+curplatform;
			}
		}
		cur.push(t);
	}
	
	function mergeRights( f1 : ClassField, f2 : ClassField ) {
		if( f1.get == RInline && f1.set == RNo && f2.get == RNormal && f2.set == RMethod ) {
			f1.get = RNormal;
			f1.set = RMethod;
			return true;
		}
		return false;
	}
	
	function mergeFields( f : ClassField, f2 : ClassField ) {
		return TypeApi.fieldEq(f,f2) || (f.name == f2.name && (mergeRights(f,f2) || mergeRights(f2,f)) && TypeApi.fieldEq(f,f2));
	}
	
	function mergeClasses( c : Classdef, c2 : Classdef ) {
		// todo : compare supers & interfaces
		if( c.isInterface != c2.isInterface )
			return false;
		if( curplatform != null )
			c.platforms.add(curplatform);
		if( c.isExtern != c2.isExtern )
			c.isExtern = false;

		for( f2 in c2.fields ) {
			var found = null;
			for( f in c.fields )
				if( mergeFields(f,f2) ) {
					found = f;
					break;
				}
			if( found == null )
				c.fields.add(f2);
			else if( curplatform != null )
				found.platforms.add(curplatform);
		}
		for( f2 in c2.statics ) {
			var found = null;
			for( f in c.statics )
				if( mergeFields(f,f2) ) {
					found = f;
					break;
				}
			if( found == null )
				c.statics.add(f2);
			else if( curplatform != null )
				found.platforms.add(curplatform);
		}
		return true;
	}
	
	function mergeEnums( e : Enumdef, e2 : Enumdef ) {
		if( e.isExtern != e2.isExtern )
			return false;
		if( curplatform != null )
			e.platforms.add(curplatform);
		for( c2 in e2.constructors ) {
			var found = null;
			for( c in e.constructors )
				if( TypeApi.constructorEq(c,c2) ) {
					found = c;
					break;
				}
			if( found == null )
				return false; // don't allow by-platform constructor ?
			if( curplatform != null )
				found.platforms.add(curplatform);
		}
		return true;
	}

	function mergeTypedefs( t : Typedef, t2 : Typedef ) {
		if( curplatform == null )
			return false;
		t.platforms.add(curplatform);
		t.types.set(curplatform,t2.type);
		return true;
	}
	
	public function sort( ?l ) {
		if( l == null ) l = root;
		l.sort(function(e1,e2) {
			var n1 = switch e1 {
				case TPackage(p,_,_) : " "+p;
				default: TypeApi.typeInfos(e1).path;
			};
			var n2 = switch e2 {
				case TPackage(p,_,_) : " "+p;
				default: TypeApi.typeInfos( e2 ).path;
			};
			if( n1 > n2 )
				return 1;
			return -1;
		});
		for( x in l )
			switch( x ) {
			case TPackage(_,_,l): sort(l);
			case TClassdecl(c):
				c.fields = sortFields( c.fields );
				c.statics = sortFields( c.statics );
			case TEnumdecl(e):
			case TTypedecl(_):
			}
	}
	
	function sortFields( fl : Dynamic ) : List<haxe.rtti.ClassField> {
		var a = Lambda.array(fl);
		a.sort(function(f1 : ClassField,f2 : ClassField) {
			var v1 = TypeApi.isVar(f1.type);
			var v2 = TypeApi.isVar(f2.type);
			if( v1 && !v2 )
				return -1;
			if( v2 && !v1 )
				return 1;
			if( f1.name == "new" )
				return -1;
			if( f2.name == "new" )
				return 1;
			if( f1.name > f2.name )
				return 1;
			return -1;
		});
		return Lambda.list(a);
	}
	
}
