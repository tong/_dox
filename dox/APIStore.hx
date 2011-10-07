package dox;

import haxe.rtti.CType;

class APIStore {
	
	function new() {
	}
	
	public function init( cb : Array<APIDescription>->Void ) {
	}
	
	public function getAll( cb : Array<APIDescription>->Void ) {
	}
	
	public function get( name : String, cb : APIDescription->Void ) {
	}
	
	public function set( api : APIDescription, cb : String->Void ) {
	}
	
	/*
	public function setActive( api : APIDescription, cb : String->Void ) {
	}
	public function setXml( api : APIDescription, cb : String->Void ) {
	}
	public function setRoot( api : APIDescription, cb : String->Void ) {
	}
	*/
	
	public function clear( ?cb : String->Void ) {
	}
	
}
