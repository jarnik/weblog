package pl.bigsoda.weblog.servicess;
import haxe.Json;
import hxangular.haxe.IService;
import js.Console;

/**
 * ...
 * @author tkwiatek
 */
class SocketService implements IService
{
	public var socketData:Dynamic;
	public var logData:Array<Dynamic>;
	public var debugData:Array<Dynamic>;
	public var statsData:Array<Dynamic>;
	public var inspectData:Array<Dynamic>;
	public var testData:Array<Dynamic>;
	private var logDeferred:Dynamic;
	private var debugDeferred:Dynamic;
	private var statsDeferred:Dynamic;
	private var inspectDeferred:Dynamic;
	private var testDeferred:Dynamic;
	private var rootScope:Dynamic;
	private var inspectSocketData:Dynamic;
	private var statsSocketData:Array<Dynamic> = new Array<Dynamic>();
	private var init:Bool = false;
	private var sce:Dynamic;
	private var index:Float = 0;
	
	@inject("$q", "$rootScope", "$sce")
	public function new(q, rootScope, sce) 
	{
		this.rootScope = rootScope;
		
		logDeferred = q.defer();
		debugDeferred = q.defer();
		statsDeferred = q.defer();
		testDeferred = q.defer();
		inspectDeferred = q.defer();
		
		socketData = new Array<Dynamic>();
		this.sce = sce;
		
		logData = new Array<Dynamic>();
		debugData = new Array<Dynamic>();
		statsData = new Array<Dynamic>();
		inspectData = new Array<Dynamic>();
		testData = new Array<Dynamic>();
		socketData = {
			logData: logData,
			debugData: debugData,
			inspectData: inspectData,
			testData: testData,
			statsData: statsData,
		}
		
		untyped __js__("console.log('SocketService')");
		var socket:Dynamic = untyped __js__("io.connect('http://localhost:18081/')");
		socket.on("data", onSocketData);
	}
	
	public function onSocketData(data:Dynamic):Void {
		//data.data = Json.parse(data.data);
		data = Json.parse(data);

		var max:UInt = 101;
		
		if (data.type == "log") {
			logData.insert(0, {
				id: index,
				time: Date.now(),
				device: data.device,
				message: data.data,
			});
			if (logData.length > max) logData.pop();
		}
		
		if (data.type == "stats") {
			statsSocketData.insert(0, data.data);
			statsData.insert(0, data.data);
			if (statsData.length > max) statsData.pop();
			if (statsSocketData.length > max) statsSocketData.pop();
		}
		

		if (data.type == "debug") {
			debugData.insert(0, {
				id: index,
				time: Date.now(),
				device: data.device,
				message: sce.trustAsHtml("<pre id='debug'>" + formatJson(data.data) + "</pre>"),
			});
			if (debugData.length > max) debugData.pop();
		}
		

		if (data.type == "inspect") {
			inspectSocketData = sce.trustAsHtml("<pre id='debug'>" + formatJson(data.data) + "</pre>");
			inspectData.insert(0, {
				id: index,
				time: Date.now(),
				device: data.device,
				message: sce.trustAsHtml("<pre id='debug'>" + formatJson(data.data) + "</pre>"),
			});
			if (inspectData.length > 1) inspectData.pop();
		}
		

		if (data.type == "test") {
			testData.insert(0, {
				id: index,
				time: Date.now(),
				device: data.device,
				message: sce.trustAsHtml(formatMunit(data.data)),
			});
		}
		
		index++;
		
		logDeferred.resolve(logData);
		debugDeferred.resolve(debugData);
		inspectDeferred.resolve(inspectData);
		testDeferred.resolve(testData);
		statsDeferred.resolve(statsData);
		
		rootScope.$apply();
	}
	
	inline function formatMunit(object:String):String 
	{
		object = object.split("------------------------------")[1];
		var ao = object.split("==============================");
		var desc:String = ao[0];
		var result:String = ao[1];
		return "<p><b>" + desc + "</b></p><p>" + result + "</p>";
	}
	
	inline function formatJson(object:Dynamic):String 
	{
		return untyped __js__("library.json.prettyPrint")(object);
	}
	
	public function getLogData():Dynamic {
		return logDeferred.promise;
	}
	public function getDebugData():Dynamic {
		return debugDeferred.promise;
	}
	public function getStatsData():Dynamic {
		return statsDeferred.promise;
	}
	public function getInspectData():Dynamic {
		return inspectDeferred.promise;
	}
	public function getInspectSocketData():Dynamic {
		return inspectSocketData;
	}
	public function getStatsSocketData():Dynamic {
		return statsSocketData;
	}
	public function getTestData():Dynamic {
		return testDeferred.promise;
	}
}