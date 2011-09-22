package dox;

import haxe.rtti.CType;
using StringTools;

class HTMLPrinter {
	
	/**
		Generate HTML from a classdef
	*/
	public static function getClass( c : haxe.rtti.Classdef ) : JQ  {
		
		var e = new JQ( '<div class="doctype"></div>' );
		
		var title = new JQ( '<div class="type"></div>' );
		if( c.isExtern ) title.append( '<span class="extern">extern</span>' );
		if( c.isInterface ) title.append( '<span class="interface">interface</span>' );
		else title.append( '<span class="class">class</span>' );
		title.append( '<span class="name">'+c.path+'</span>' );
		if( c.params.length > 0 ) title.append( getTypeParameter( c.params ) );
		e.append( title );
		
		// TODO print known subclasses
		//....
		
		if( c.platforms != null ) {
			//trace( c.platforms );
			e.append( '<div class="platforms">Available in: '+c.platforms.join(", ")+'</div>' );
		}
		
		if( c.doc != null ) {
			var d = c.doc;
			if( d.length > 320 ) d = d.substr( 0, 320 );
			e.append( '<div class="description">'+d+'</div>'  );
		}
		
		//[path,module,doc,isPrivate,isExtern,isInterface,params,superClass,interfaces,fields,statics,tdynamic,platforms]
		
		var fields = new JQ( '<div></div>' );
		//trace( c.fields.iterator() );
		
		// Print statics
		for( f in c.statics ) {
			if( !f.isPublic )
				continue;
			fields.append( getFieldElement( f, true ) );
		}
		// Print fields
		for( f in c.fields ) {
			if( !f.isPublic )
				continue;
			fields.append( getFieldElement(f) );
		}
		
		e.append( fields );
		
		// extend stuff.......... links, notes, comments, etc
		//...........
		
		return e;
	}
	
	static function getFieldElement( f : ClassField, isStatic : Bool = false ) : JQ {
		var fd = new JQ( '<div class="field"></div>' );
		if( f.doc != null ) fd.append( '<div class="doc">'+f.doc+'</div>' );
		if( isStatic ) fd.append( '<span class="static">static</span>' );
		if( f.set != null ) {
			switch( f.set ) {
			case RNo : fd.append( '<span class="var">var</span>' );
			case RMethod, RInline : fd.append( '<span class="func">function</span>' );
			default :
				trace(f.set);
			}
		} else {
			trace("NN");
			fd.append( '<span class="var">var</span>' );
		}
		
		fd.append( '<span class="name">'+f.name+'</span>' );
		if( f.set != null ) {
			switch( f.set ) {
			case RNo :
			case RMethod, RInline :
				fd.append( '<span>(</span>' );
				if( f.params != null && f.params.length > 1 ) {
					var i = 0;
					while( i < f.params.length-1 ) {
						fd.append( '<span class="param">'+f.params[i]+'</span>' );
						if( i < f.params.length-2 ) fd.append( '<span>,</span>' );
						i++;
					}
				}
				fd.append( '<span>)</span>' );
			default :
			}
			fd.append( '<span>:</span>' );
			var rtype = ( f.params.length == 0 ) ? "Void" : (f.params[f.params.length-1]);
			fd.append( '<span class="rtype">'+rtype+'</span>' );
		}
		return fd;
	}
	
	/*
	public static function getIterator<T>(t) : Iterator<T> {
		return cast {
			h : t.h,
			hasNext : function() {
				return untyped (t.h != null);
			},
			next : function() {
				untyped {
					if( t.h == null )
						return null;
					var x = t.h[0];
					t.h = t.h[1];
					return x;
				}
			}
		}
	}
	*/
	
	static function getTypeParameter( params : Array<String> ) : String  {
		var s = "<";
		for( p in params ) s += p;
		s += ">";
		return '<span class="typeparams">'+s.htmlEscape()+'</span>';
	}
	
}
