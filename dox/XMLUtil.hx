package dox;

class XMLUtil {
	
	public static inline function att( x : Dynamic, n : String ) : String {
		return x.attributes.getNamedItem(n).value;
	}
	
	public static inline function has( x : Dynamic, n : String ) : Bool  {
		return x.attributes.getNamedItem(n) != null;
	}
	
}
