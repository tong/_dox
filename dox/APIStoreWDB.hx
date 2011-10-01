package dox;

import haxe.rtti.CType;

class APIStoreWDB extends APIStore {
	
	var db : Dynamic;
	var index : Int;
	
	public function new() {
		super();
	}
	
	public override function init( cb : Array<APIDescription>->Void ) {
		
		db = untyped window.openDatabase( "dox", "0.2", "DoX API database", 10*1024*1024 );	
		if( db == null ) {
			trace( 'failed to open database' );
			//cb( 'failed to open database' );
			cb( null );
			return;
		}
	
		//clear(function(e){}); return;
		
		db.transaction(function(tx:SQLTransaction) {
			//tx.executeSql( 'CREATE TABLE IF NOT EXISTS apis (id REAL UNIQUE, name TEXT, content TEXT)', [],
			tx.executeSql( 'CREATE TABLE IF NOT EXISTS apis (id INTEGER PRIMARY KEY ASC, name TEXT, active INTEGER, content TEXT)', [],
				function(tx,r:SQLResultSet) {
					//trace( "table ready: "+r );
					count(function(i:Int){
						index = i;
						if( index == 0 )
							cb([]);
						else {
							getDescriptions( cb );
						}
					});
				},
				function(tx,e){
					trace(e);
					cb( null );
				}
			);
		});
	}
	
	 function getDescriptions( cb : Array<APIDescription>->Void ) {
		db.transaction(function(tx){
			//tx.executeSql( 'SELECT * FROM apis ORDER BY id DESC LIMIT ?', [],
			tx.executeSql( 'SELECT * FROM apis ORDER BY id DESC LIMIT ?', [100],
				function(tx:SQLTransaction,r:SQLResultSet){
					var a = new Array<APIDescription>();
					var i = 0;
					while( i < r.rows.length ) {
						//a.push( r.rows.item(i) );
						//trace( r.rows.item(i)  );
						//trace( Reflect.fields( r.rows.item(i) ) );
						var d = r.rows.item(i);
						a.push( d );
						//.push( { name : d.name } );
						i++;
					}
					//trace(a);
					cb(a);
				},
				function(tx,e){
					//TODO cb(err);
					trace(e);
					cb(null);
				}
			);
		});
	}
	
	
	public override function get( name : String, cb : APIDescription->Void ) {
		//TODO
	}
	
	//public function set( name : String, ?content : String, cb : String->Void ) {
	//public function set( name : String, active : Bool, content : String, cb : String->Void ) {
	public override function set( d : APIDescription, cb : String->Void ) {
		
		db.transaction(function(tx){
			tx.executeSql('INSERT INTO apis(name,active,content) VALUES (?,?,?)', [d.name,true,d.content],
				function(tx:SQLTransaction,r:SQLResultSet){
					index++;
					cb(null);
				},
				function(tx,err){
					trace(err);
					//TODO
					cb(err.message);
				}
			);
		});
	}
	
	/*
	public function setContent( name : String, content : String, cb : String->Void ) {
	}
	*/
	
	public override function clear( cb : String->Void ) {
		db.transaction( function(tx) {
			tx.executeSql( 'DROP TABLE IF EXISTS apis', [],
				function(tx:SQLTransaction,r:SQLResultSet) {
					cb( null );
				},
				function(tx,err){
					trace(err);
					//TODO
					//cb(err.message);
				}
			);
		});
	}
	
	function count( cb : Int->Void ) {
		db.transaction(function(tx) {
			tx.executeSql( 'SELECT count(*) FROM apis', [], function(tx,r) {
				/*
				trace(r);
				trace(r.rows);
				trace(r.rows.length);
				trace(untyped r.rows.item(0)["count(*)"] );
				*/
				//?
				cb( untyped r.rows.item(0)["count(*)"] );
			});
		});
	}
	
}
