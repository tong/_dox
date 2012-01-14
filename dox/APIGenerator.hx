package dox;

import js.Node;
import js.JSON;

/**
	Nodejs tool for generating dox files in json format
*/
class APIGenerator {
	
	static inline function print(t) js.Node.sys.print( t )
	
	static function main() {
		
		/*
		var p = new haxe.rtti.XmlParser();
		var x = Xml.parse( Node.fs.readFileSync( "test.xml", Node.UTF8 ) ).firstElement();
		p.process( x, "neko" );
		p.sort();
		*/
		
		/// generate std
		
		var timestamp = haxe.Timer.stamp();
		
		//var targets = ["flash","js","neko","php"];
		var targets = ["cpp","flash","js","neko","php"];
		var p = new haxe.rtti.XmlParser();
		for( t in targets ) {
			print( "  "+t+" .. " );
			var x = Xml.parse( Node.fs.readFileSync( "api/"+t+".xml", Node.UTF8 ) ).firstElement();
			for( e in x.elements() ) {
				//trace( e.get("path") );
				if( t == "cpp" && e.get("path") == "haxe.Int32" ) { // HACK
					x.removeChild( e );
				}
			}
			p.process( x, t );
			print( "done\n" );
		}
		
		p.sort();
		trace( p.root.length );
		Node.fs.writeFileSync( "std.json", JSON.stringify( p.root ) );
		
		print( "Done ("+(haxe.Timer.stamp()-timestamp)+")\n" );
		
	}
	
}
