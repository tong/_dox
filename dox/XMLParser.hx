package dox;

#if js

import haxe.rtti.CType;

/**
	Custom (faaaast) XML 2 haxe.rtti parser
*/
class XMLParser {

	public var root : TypeRoot;
	
	var curplatform : String;
	
	public function new() {
		root = new Array();
	}
	
			/*
	public function sort( ?l ) {
		if( l == null ) l = root;
		l.sort(function(e1,e2) {
			var n1 = switch e1 {
				case TPackage(p,_,_) : " "+p;
				default: TypeApi.typeInfos(e1).path;
			};
			var n2 = switch e2 {
				case TPackage(p,_,_) : " "+p;
				default: TypeApi.typeInfos(e2).path;
			};
			if( n1 > n2 )
				return 1;
			return -1;
		});
		for( x in l )
			switch( x ) {
			case TPackage(_,_,l): sort(l);
			case TClassdecl(c):
				//c.fields = sortFields(c.fields);
				//c.statics = sortFields(c.statics);
/* 
			case TEnumdecl(e):
			case TTypedecl(_):
			}
	}
	
	function sortFields(fl) {
		var a = Lambda.array(fl);
		a.sort(function(f1 : ClassField,f2 : ClassField) {
			if( f1 == null )trace( f1 );
			//var v1 = TypeApi.isVar(f1.type);
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
			trace(v1+" :  "+v2);
			return -1;
		});
		return Lambda.list(a);
	}
			*/
	
	public function parseString( s : String ) {
		 parseXML( new DOMParser().parseFromString( s, "text/xml" ).documentElement );
	}
	
	public function parseXML( x : Dynamic ) {
		root = new Array<TypeTree>();
		parseElement( x.childNodes.item(0), root );
	}
	
	public function parseElement( x : Dynamic, root : TypeRoot ) {
		var i = 0;
		while( i < x.childNodes.length ) {
			var tree : TypeTree = null;
			var i1 = x.childNodes.item(i);
			switch( i1.nodeType ) {
			case Node.ELEMENT_NODE :
				switch( i1.nodeName ) {

				case "typedef" :
					var t : Typedef = {
						types : null,
						type : null,
						platforms : null,
						path : Std.string( i1.attributes.getNamedItem( "path" ).value ),
						params : null,
						module : getStringAttribute( i1, "module" ),
						isPrivate : getBoolAttribute( i1, "private" ),
						doc : null
					};
					//trace(t.module);
					//var a : Dynamic = i1.attributes.getNamedItem("module");
					//if( a != null ) t.module = Std.string( a.value );
					var j = 0;
					while( j < i1.childNodes.length ) {
						var i2 = i1.childNodes.item(j);
						switch( i2.nodeType ) {
						case Node.ELEMENT_NODE :
							//trace(i2.nodeName);
							switch( i2.nodeName ) {
							case "haxe_doc" : t.doc = i2.textContent;
							case "a" :
								//trace("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
								var k = 0;
								while( k < i2.childNodes.length ) {
									var i3 = i2.childNodes.item(k);
									switch( i3.nodeType ) {
									case Node.ELEMENT_NODE :
										//trace( i3.nodeName );
										//mkRights();
										//trace( mkRights( getStringAttribute( i3, "set" ) ) );
										//t.types.set( i3.nodeName,  );
									}
									k++;
								}
								
							case "c" :
							}
						}
						j++;
					}
					//tree = TypeTree.TTypedecl(t);
					//root.push( TypeTree.TTypedecl(t) );
					//updatePAckages();
					merge( TypeTree.TTypedecl(t) );
					
				case "class" :								
					var c : Classdef = {
						tdynamic : null,
						superClass : null,
						statics : new List<ClassField>(),
						platforms : null,
						path : Std.string( i1.attributes.getNamedItem( "path" ).value ),
						params : i1.attributes.getNamedItem( "params" ).value,
						module : null,//i1.attributes.getNamedItem( "module" ).value,
						isPrivate : null,
						isInterface : false,
						isExtern : false,
						interfaces : null,
						fields : new List<ClassField>(),
						doc : null,
					};
					
					//TODO platforms
					
					//var a : Dynamic = i1.attributes.getNamedItem("module");
					//if( a != null ) c.module = Std.string( a.value );
					
					var a : Dynamic = i1.attributes.getNamedItem("module");
					if( a != null ) c.module = Std.string( a.value );
					
					//var a : Dynamic = i1.attributes.getNamedItem("private");
					//if( a != null && a.value == "1" ) c.isPrivate = true;
					c.isPrivate = getBoolAttribute( i1, "private" );
					
					var a : Dynamic = i1.attributes.getNamedItem("interface");
					if( a != null && a.value == "1" ) c.isInterface = true;
					
					//var a : Dynamic = i1.attributes.getNamedItem("extern");
					//if( a != null && a.value == "1" ) c.isExtern = true;
					c.isExtern = getBoolAttribute( i1, "extern" );
					
					//trace(c.module+":"+c.isPrivate);
					
					// PARSE FIELDS
					var j = 0;
					while( j < i1.childNodes.length ) {
						var i2 = i1.childNodes.item(j);
						switch( i2.nodeType ) {
						case Node.ELEMENT_NODE :
	//{ type : haxe.rtti.CType, set : haxe.rtti.Rights, platforms : haxe.rtti.Platforms, params : haxe.rtti.TypeParams,
	//name : String, isPublic : Bool, isOverride : Bool, get : haxe.rtti.Rights, doc : String }
							switch( i2.nodeName ) {
							case "extends" :
								var path = i2.attributes.getNamedItem("path").value;
								//var params = ,,
								c.superClass = { path : path, params : null }; //TODO params
							case "haxe_doc" :
								c.doc = i2.textContent;
							default :
								var cf : ClassField = {
									type : null,
									set : null,
									platforms : new List<String>(),
									params : new Array<String>(),
									name : i2.nodeName,
									isPublic :  false,
									isOverride : false,
									get : null,
									doc : null
								};
								var _static = false;
								if( i2.attributes != null ) {
									var s = i2.attributes.getNamedItem("static");
									if( s != null && s.value == "1" ) _static = true;
									var a = i2.attributes.getNamedItem("get");
									if( a != null ) cf.get = mkRights( a.value );
									var a = i2.attributes.getNamedItem("set");
									if( a != null ) cf.set = mkRights( a.value );
									var a = i2.attributes.getNamedItem("public");
									if( a != null && a.value == "1" ) cf.isPublic = true;
									var s = i2.attributes.getNamedItem( "override" );
									if( s != null && s.value == "1" ) cf.isOverride = true;
								}
								
								var k = 0;
								while( k < i2.childNodes.length ) {
									var i3 = i2.childNodes.item(k);
									switch( i3.nodeType ) {
									case Node.ELEMENT_NODE :
										switch( i3.nodeName ) {
										case "haxe_doc" :
											cf.doc = i3.textContent;
										case "c" :
											//trace( i3.attributes.getNamedItem("path").value );
											cf.params.push( i3.attributes.getNamedItem("path").value);
										case "f" :
											var param_names = i3.attributes.getNamedItem("a").value.split(":");
											var param_names_index = 0;
											//trace(param_names);
											var l = 0;
											while( l < i3.childNodes.length ) {
												var i4 = i3.childNodes.item(l);
												switch( i4.nodeName ) {
												case "c" :
													var param = param_names[param_names_index];
													param_names_index++;
													var s = ( param == null ) ? "" : param+":";
													s += i4.attributes.getNamedItem( "path" ).value;
													cf.params.push(s);
												case "e" :
													cf.params.push( i4.attributes.getNamedItem( "path" ).value );
												}
												l++;
											}
											if( cf.name == "isSpace" ) {
												//trace(cf.params);
											}
										}
										//default :
										//	trace("YOOOOOOOOOOOOOOOOOOOOOE "+i3.nodeName );
									}
									k++;
								}
								
								if( _static ) {
									c.statics.add( cf );
								} else {
									c.fields.add( cf );
								}
							}
						}
						j++;
					}
					//tree = TypeTree.TClassdecl(c);
					//root.push( TypeTree.TClassdecl(c) );
					//trace(c);
					merge( TypeTree.TClassdecl(c) );
					
				case "enum" :
					//TODO
					var e : Enumdef = {
						platforms : null,
						path : Std.string( i1.attributes.getNamedItem( "path" ).value ),
						params : null,
						module : null,
						isPrivate : false,
						isExtern : false,
						doc : null,
						constructors : new List()
					};
					
					var a : Dynamic = i1.attributes.getNamedItem("module");
					if( a != null ) e.module = Std.string( a.value );
					
					var a : Dynamic = i1.attributes.getNamedItem("private");
					if( a != null && a.value == "1" ) e.isPrivate = true;
					
					var a : Dynamic = i1.attributes.getNamedItem("extern");
					if( a != null && a.value == "1" ) e.isExtern = true;
					
					var j = 0;
					while( j < i1.childNodes.length ) {
						var i2 = i1.childNodes.item(j);
						switch( i2.nodeType ) {
						case Node.ELEMENT_NODE :
							//trace(i2);
							switch( i2.nodeName ) {
							case "haxe_doc" :
								e.doc = i2.textContent;
							default :
								//TODO
								var ef : EnumField  = {
									platforms : null,
									name : i2.nodeName,
									doc : null,
									args : null
								};
								e.constructors.add( ef );
							}
						}
						j++;
					}
					//tree = TypeTree.TEnumdecl(e);
					//root.push( TypeTree.TEnumdecl(e) );
					merge( TypeTree.TEnumdecl(e) );
				}
			//case Node.TEXT_NODE :
			}
			
		//	updatePackages();
			
			//root.push( tree );
			i++;
		}
	}
	
	function xerror( c ) : Dynamic {
		return throw "Invalid "+c.nodeName;
	}
	
	function xtypedef( x : Dynamic ) : Typedef {
		var doc = null;
		var t = null;
		var i = 0;
		while( i < x.childNodes.length ) {
			var c = x.childNodes.item(i);
			if( c.name == "haxe_doc" )
				doc = c.innerData;
			else
				t = xtype(c);
			i++;
		}
		var types = new Hash();
		if( curplatform != null )
			types.set(curplatform,t);
		return {
			path : mkPath(x.att.path),
			module : if( x.has.module ) mkPath(x.att.module) else null,
			doc : doc,
			isPrivate : x.x.exists("private"),
			params : mkTypeParams(x.att.params),
			type : t,
			types : types,
			platforms : defplat(),
		};
	}
	
	function xtype( x : Dynamic ) : CType {
		
		if( x.nodeName == null ) {
			trace("NNNNNNNNNNNNNNNNNNNNNNNNNNN");
			return null;
		}
		//trace( x.nodeName);	
		
		return switch( x.nodeName ) {
		case "f" :
			var args = new List();
			var aname = x.att.a.split(":");
			var eargs = aname.iterator();
			var i = 0;
			while( i < x.childNodes.length ) {
				var e = x.childNodes.item( i );
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
				i++;
			}
			var ret = args.last();
			args.remove(ret);
			CFunction(args,ret.t);
		case "a":
			var fields = new List();
			var i = 0;
			while( i < x.childNodes.length ) {
				var f = x.childNodes.item(i);
				fields.add({
					name : f.name,
					t : xtype( f.firstElement() ) //xtype( new Fast(f.x.firstElement() ) ),
				});
				i++;
			}
			CAnonymous(fields);
		case "d":
			var t = null;
			var tx = x.x.firstElement();
			if( tx != null )
				t = xtype( tx.firstElement() );  //xtype(new Fast(tx));
			CDynamic(t);
		default:
			xerror(x);
		}
		return null;
	}
	
	function mkPath( p : String ) : Path {
		return p;
	}
	
	function mkTypeParams( p : String ) : TypeParams {
		var pl = p.split(":");
		if( pl[0] == "" )
			return new Array();
		return pl;
	}
	
	function merge( t : TypeTree ) {
		//TODO
		var cur = root;
		var inf = TypeApi.typeInfos(t);
		//trace( inf );
		var pack = inf.path.split(".");
		pack.pop();
		//trace( pack );
		var curpack = new Array();
		for( p in pack ) {
			var found = false;
			for( pk in cur ) {
				switch( pk ) {
				case TPackage(pname,_,subs):
					if( pname == p ) {
						found = true;
						cur = subs;
						break;
					}
				default:
				}
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
	
	function mergeFields( f : ClassField, f2 : ClassField ) {
		return TypeApi.fieldEq(f,f2) || (f.name == f2.name && (mergeRights(f,f2) || mergeRights(f2,f)) && TypeApi.fieldEq(f,f2));
	}
	
	function mergeTypedefs( t : Typedef, t2 : Typedef ) {
		if( curplatform == null )
			return false;
		t.platforms.add(curplatform);
		t.types.set(curplatform,t2.type);
		return true;
	}
	
	function mergeRights( f1 : ClassField, f2 : ClassField ) {
		if( f1.get == RInline && f1.set == RNo && f2.get == RNormal && f2.set == RMethod ) {
			f1.get = RNormal;
			f1.set = RMethod;
			return true;
		}
		return false;
	}
	
	//function geClassdef( x : Dynamic ) 
	
	function getStringAttribute( e : Dynamic, name : String ) {
		var v = e.attributes.getNamedItem( name );
		return ( v == null ) ? null : v.value;
	}
	
	function getBoolAttribute( e : Dynamic, name : String ) {
		var v = e.attributes.getNamedItem( name );
		return ( v == null ) ? false : ( v.value == "1" );
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
	
}

#end
