package dox;

#if js

import js.Dom ;
import haxe.rtti.CType;
using dox.XMLUtil;

/**
	Custom (faaaast) XML 2 haxe.rtti parser
*/
class XMLParser {

	public var root : TypeRoot;
	
	var curplatform : String;
	
	public function new() {
		root = new Array();
		curplatform = "js"; //TODO
	}
	
	public function parseString( s : String ) {
		 parseXML( new DOMParser().parseFromString( s, "text/xml" ) );
	}
	
	public function parseXML( x : Dynamic ) {
		root = new Array<TypeTree>();
		var r = x.childNodes.item(0);
		parseElement( r, root );
	}
	
	public function parseElement( x : Dynamic, root : TypeRoot ) {
		var i = 0;
		while( i < x.childNodes.length ) {
			var e = x.childNodes.item(i);
			if( e.nodeType == Node.ELEMENT_NODE ) {
				merge( processElement(e) );
			}
			i++;
		}
	}
	
	public function processElement( x ) {
		return switch( x.nodeName ) {
		case "class": TClassdecl(xclass(x));
		case "enum": TEnumdecl(xenum(x));
		case "typedef": TTypedecl(xtypedef(x));
		default: xerror(x);
		}
	}
	
	function xclass( x : Dynamic ) : Classdef {
		var csuper = null;
		var doc = null;
		var tdynamic = null;
		var interfaces = new List();
		var fields = new List();
		var statics = new List();
		for( i in 0...x.childNodes.length ) {
			var c : Dynamic = x.childNodes.item(i);
			if( c.nodeType != Node.ELEMENT_NODE )
				continue;
			switch( c.nodeName ) {
			case "haxe_doc": doc = c.firstChild.nodeValue;
			case "extends": csuper = xpath(c);
			case "implements": interfaces.add(xpath(c));
			case "haxe_dynamic":
				//trace(c.firstChild);
				//TODO correct ?
				for( i in 0...c.childNodes.length ) {
					var e = c.childNodes.item(i);
					if( e.nodeType == Node.ELEMENT_NODE ) {
						//trace("xtype "+e.nodeName );
						tdynamic = xtype( e ); //xtype(new Fast(c.x.firstElement()));
					}
					
				}
			default :
				//trace( c.has("static") );
				if( c.has("static") )
					statics.add(xclassfield(c));
				else
					fields.add(xclassfield(c));
			}
		}
		var r = {
			path : mkPath( x.att("path") ),
			module : if( x.has("module") ) mkPath(x.att("module")) else null,
			doc : doc,
			isPrivate : x.has("private"),
			isExtern : x.has("extern"),
			isInterface : x.has("interface"),
			params : mkTypeParams(x.att("params")),
			superClass : csuper,
			interfaces : interfaces,
			fields : fields,
			statics : statics,
			tdynamic : tdynamic,
			platforms : defplat(),
		};
		//trace(r);
		return r;
	}
	
	function xclassfield( x : Dynamic ) : ClassField {
		var f = null;
		var doc = null;
		for( i in 0...x.childNodes.length ) {
			var e = x.childNodes.item(i);
			if( e.nodeType != Node.ELEMENT_NODE )
				continue;
			if( f == null ) {
				f = e;
			} else {
				switch( e.nodeName ) {
				case "haxe_doc":
					if( e.firstChild != null ) doc = e.firstChild.nodeValue;
					//doc = e.firstChild.nodeValue;
				default: xerror(e);
				}
			}
		}
		var t = xtype(f);
		return {
			name : x.nodeName,
			type : t,
			isPublic : x.has("public"),
			isOverride : x.has("override"),
			doc : doc, 
			get : if( x.has("get") ) mkRights( x.att("get") ) else RNormal,
			set : if( x.has("set") ) mkRights( x.att("set") ) else RNormal,
			params : if( x.has("params") ) mkTypeParams(x.att("params")) else null,
			platforms : defplat(),
		};
	}
	
	function xenum( x : Dynamic ) : Enumdef {
		var cl = new List();
		var doc = null;
		for( i in 0...x.childNodes.length ) {
			var c = x.childNodes.item(i);
			if( c.nodeType != Node.ELEMENT_NODE )
				continue;
			if( c.nodeName == "haxe_doc" ) {
				if( c.firstChild != null ) {
					doc = c.firstChild.nodeValue;
				}
			} else {
				cl.add( xenumfield(c) );
			}
		}
		return {
			path : mkPath( x.att("path") ),
			module : if( x.has("module") ) mkPath( x.att("module")) else null,
			doc : doc,
			isPrivate : x.has("private"),
			isExtern : x.has("extern"),
			params : mkTypeParams( x.att("params") ),
			constructors : cl,
			platforms : defplat(),
		};
	}
	
	function xenumfield( x : Dynamic ) : EnumField {
		var xdoc = null;
		var args = null;
		if( x.has("a") ) {
			var names = x.att("a").split(":");
			var elts = x.childNodes;
			var i = 0;
			args = new List();
			var i = 0;
			var j = 0;
			while( i < names.length ) {
				var e = elts.item(j);
				if( e.nodeType != Node.ELEMENT_NODE ) {
					j++;
					continue;
				}
				var c = names[i];
				var opt = false;
				if( c.charAt(0) == "?" ) {
					opt = true;
					c = c.substr(1);
				}
				args.add({
					name : c,
					opt : opt,
					t : xtype( e ),
				});
				i++;
			}
		}
		return {
			name : x.nodeName,
			args : args,
			doc : if( xdoc == null ) null else xdoc.firstChild.nodeValue, //if( xdoc == null ) null else new Fast(xdoc).innerData,
			platforms : defplat(),
		};
	}
	
	function xerror( c : Dynamic ) : Dynamic {
		return throw "Invalid "+c;
	}
	
	function xtypedef( x : Dynamic ) : Typedef {
		var doc = null;
		var t = null;
		for( i in 0...x.childNodes.length ) {
			var c = x.childNodes.item(i);
			if( c.nodeType != Node.ELEMENT_NODE )
				continue;
			if( c.nodeName == "haxe_doc" ) {
				if( c.firstChild != null ) {
					doc = c.firstChild.nodeValue;
				} 
			} else {
				t = xtype(c);
			}
		}
		var types = new Hash();
		if( curplatform != null )
			types.set( curplatform, t );
		return {
			path : mkPath(x.att("path")),
			module : if( x.has("module") ) mkPath(x.att("module")) else null,
			doc : doc,
			isPrivate : x.has("private"),
			params : mkTypeParams(x.att("params")),
			type : t,
			types : types,
			platforms : defplat(),
		};
		return null;
	}
	
	function xtype( x : Dynamic ) : CType {
		return switch( x.nodeName ) {
		case "unknown":
			CUnknown;
		case "e":
			CEnum(mkPath(x.att("path")),xtypeparams(x));
		case "c":
			CClass(mkPath(x.att("path")),xtypeparams(x));
		case "t":
			CTypedef(mkPath(x.att("path")),xtypeparams(x));
		case "f":
			var args = new List();
			var aname = x.att("a").split(":");
			var eargs = aname.iterator();
			for( i in 0...x.childNodes.length ) {
				var e = x.childNodes.item(i);
				if( e.nodeType != Node.ELEMENT_NODE )
					continue;
				var opt = false;
				var a = eargs.next();
				if( a == null )
					a = "";
				if( a.charAt(0) == "?" ) {
					opt = true;
					a = a.substr(1);
				}
				args.add({
					name : a,
					opt : opt,
					t : xtype(e),
				});
			}
			var ret = args.last();
			args.remove(ret);
			CFunction( args, ret.t );
		case "a":
			var fields = new List();
			for( i in 0...x.childNodes ) {
				var f = x.childNodes.item(i);
				if( f.nodeType != Node.ELEMENT_NODE )
					continue;
//				trace("TODO");
				fields.add({
					name : f.nodeName,
					t : xtype( f ),
				});
				/*
				fields.add({
					name : f.nodeName,
					t : xtype( new Fast(f.x.firstElement())),
				});
				*/
			}
			CAnonymous(fields);
		case "d":
//			trace("TODO");
			var t = null;
			var tx : Dynamic = null;
			for( i in 0...x.childNodes ) {
				var e = x.childNodes.item(i);
				if( e.nodeType != Node.ELEMENT_NODE )
					continue;
				tx = e;
				break;
			}
			if( tx != null )
				t = xtype(tx);
			CDynamic(t);
		default:
			xerror(x);
		}
		return null;
	}
	
	function xpath( x : Dynamic ) : PathParams {
		var path = mkPath( x.att("path") );
		var params = new List();
		for( i in 0...x.childNodes.length ) {
			var c = x.childNodes.item(i);
			if( c.nodeType != Node.ELEMENT_NODE ) continue;
			params.add( xtype( c ) );
		}
		return {
			path : path,
			params : params,
		};
	}
	
	function xtypeparams( x : Dynamic ) : List<CType> {
		var p = new List();
		for( i in 0...x.childNodes.length ) {
			var c = x.childNodes.item(i);
			if( c.nodeType != Node.ELEMENT_NODE ) continue;
			p.add(xtype(c));
		}
		return p;
	}
	
	inline function mkPath( p : String ) : Path {
		return p;
	}
	
	function mkTypeParams( p : String ) : TypeParams {
		var r = p.split(":");
		if( r[0] == "" )
			return new Array();
		return r;
	}
	
	function mkRights( r : String ) : Rights {
		return switch( r ) {
		case "null": RNo;
		case "method": RMethod;
		case "dynamic": RDynamic;
		case "inline": RInline;
		default: RCall(r);
		}
	}
	
	function defplat() {
		var l = new List();
		if( curplatform != null )
			l.add(curplatform);
		return l;
	}
	
	function merge( t : TypeTree ) {
		if( t == null ) {
			//TODO
			//trace("NULLNULLNULLNULLNULLNULLNULLNULLNULLNULLNULLNULL");
			return;
		}
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
	
}

#end
