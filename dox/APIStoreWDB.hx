package dox;

import haxe.rtti.CType;

class APIStoreWDB extends APIStore {
	
	var db : Dynamic;
	var index : Int;
	
	public function new() {
		super();
	}
	
	public override function init( cb : Array<APIDescription>->Void ) {
		db = untyped window.openDatabase( "dox", dox.Lib.VERSION, "DoX API database", 20*1024*1024 );	
		if( db == null ) {
			trace( 'failed to open database' );
			cb( null );
			return;
		}
		db.transaction(function(tx:SQLTransaction) {
			//tx.executeSql( 'CREATE TABLE IF NOT EXISTS apis (id REAL UNIQUE, name TEXT, content TEXT)', [],
			tx.executeSql( 'CREATE TABLE IF NOT EXISTS apis (id INTEGER PRIMARY KEY ASC, name TEXT, active INTEGER, root TEXT)', [],
				function(tx,r:SQLResultSet) {
					trace( "table ready: "+r );
					getAll(function(apis){
						index = apis.length;
						//trace(index);
						cb( apis );
					});
					/*
					getAll( function(loaded){
						trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> "+loaded.length);
						cb();
					});
					*/
					/*
					count(function(i:Int){
						index = i;
						if( index == 0 )
							cb([]);
						else {
							getDescriptions( cb );
						}
					});
					*/
				},
				function(tx,e){
					trace(e);
					cb( null );
				}
			);
		});
	}
	
	public override function getAll( cb : Array<APIDescription>->Void ) {
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
						//trace(d);
						a.push({
							name : d.name,
							active : d.active == 1,
							root : d.root
						});
						/*
						var d = r.rows.item(i);
						a.push( d );
						//.push( { name : d.name } );
						*/
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
			tx.executeSql('INSERT INTO apis(name,active,root) VALUES (?,?,?)', [ d.name, d.active?1:0, d.root ],
				function(tx:SQLTransaction,r:SQLResultSet){
					index++;
					cb( null );
				},
				function(tx,e){
					trace(e);
					cb( e.message ); //TODO hm ?
				}
			);
		});
	}
	
	/*
	public function setContent( name : String, content : String, cb : String->Void ) {
	}
	*/
	
	public override function clear( ?cb : String->Void ) {
		db.transaction( function(tx) {
			tx.executeSql( 'DROP TABLE IF EXISTS apis', [],
				function(tx:SQLTransaction,r:SQLResultSet) {
					if( cb != null ) cb( null );
				},
				function(tx,e){
					trace( e, "error" );
					if( cb != null ) cb( e );
				}
			);
		});
	}
	
	/*
	function count( cb : Int->Void ) {
		db.transaction(function(tx) {
			tx.executeSql( 'SELECT count(*) FROM apis', [], function(tx,r) {
				trace(r);
				trace(r.rows);
				trace(r.rows.length);
				trace(untyped r.rows.item(0)["count(*)"] );
				//?
				cb( untyped r.rows.item(0)["count(*)"] );
			});
		});
	}
	*/
	
}
