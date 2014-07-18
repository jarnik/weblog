package pl.bigsoda.weblog.controllers;

import hxangular.AngularHelper;
import hxangular.haxe.IController;
import js.Console;
import haxe.Json;
/**
 * ...
 * @author tkwiatek
 */
class StatsController implements IController
{

	var scope:Dynamic;
	var rootScope:Dynamic;
	var http:Dynamic;
	var timeout:Dynamic;
	var socketData:Dynamic;
	var sce:Dynamic;
	var socketService:Dynamic;
	
	@inject("$scope", "$window", "$http", "$document", "$timeout", "$rootScope", "pl.bigsoda.weblog.servicess.SocketService", "$sce")
	public function new(scope, window, http, document, timeout, rootScope, socketService, sce) 
	{
		this.scope = scope;
		this.http = http;
		this.timeout = timeout;
		this.sce = sce;

		this.socketService = socketService;
		
		
		
		scope.config = {
			title: 'Products',
			tooltips: true,
			labels: false,
			mouseover: function() {},
			mouseout: function() {},
			click: function() {},
			legend: {
			  display: true,
			  //could be 'left, right'
			  position: 'right'
			}
		};
				
				
				
		AngularHelper.map(this.scope, this);
		socketService.getStatsData().then(onSocketData);

	}
	
	private function onSocketData(data:Dynamic):Void 
	{
		Console.log("onSocketData StatsController");
		scope.logs = data;
		//scope.selectedDebugItem = data;
		untyped __js__("setInterval")(function(){
			select(socketService.getStatsSocketData());	
		}, 1000);
	}
	private function drawData(data:Array<Dynamic>, field:String, max:Float, fillColor, lineColor,  ctx, width, height, offset):Void{	
		
		var ho = height/3 + offset;
		ctx.beginPath();
		
		ctx.fillStyle = fillColor;
		ctx.strokeStyle = lineColor;
		ctx.lineWidth = 1;
		ctx.moveTo(0, ho);
		
		
		for(i in 0...101){
			if(i > data.length - 1){
				ctx.lineTo((width/100) * i, ho);
			}else{
				var val = Reflect.field(data[i], field) / max;
				var sval = val * (height/3 - 10);
				ctx.lineTo((width/100) * i, Std.int(height/3 - sval) + offset);
			}
		}
		ctx.lineTo(width, ho);

		ctx.closePath();
		ctx.stroke();
		ctx.fill();
		
	}
	public function select(data:Array<Dynamic>):Void
	{
		scope.$apply(function () {
						
			var c = untyped __js__("document.getElementById")("statsCanvas");
			var height = untyped __js__("$(window).height()");
			var width = untyped __js__("$(window).width()");
			var height = 300;
			
			untyped __js__("$('#statsCanvas')").width(width).height(height);
			untyped __js__("$('#statsCanvas')").attr('width', width).attr('height', height);
			
			var ctx = c.getContext("2d");
			ctx.fillStyle = "#111111";
			ctx.fillRect(0,0,width,height);
			
			
			
			var maxMEM = 0.0;
			var maxFPS = 0.0;
			var maxMS = 0.0;
			for(i in 0...data.length){
				maxFPS = Math.max(maxFPS, data[i].fps);
				maxMEM = Math.max(maxMEM, data[i].mem);
				maxMS = Math.max(maxMS, data[i].ms);
			
			}
			
			drawData(data, "fps", maxFPS, "rgba(255, 0, 0, 0.3)", "rgba(255, 0, 0, 1)", ctx, width, height, 0);
			drawData(data, "ms", maxMS, "rgba(255, 198, 0, 0.3)", "rgba(255, 198, 0, 1)", ctx, width, height, 100);
			drawData(data, "mem", maxMEM, "rgba(0, 138, 255, 0.3)", "rgba(0, 138, 255, 1)", ctx, width, height, 200);
			
			ctx.fillStyle = "#111111";
			ctx.fillRect(0,100-1,width,3);
			ctx.fillRect(0,200-1,width,3);
			ctx.fillRect(0,300-1,width,3);
			
			ctx.fillStyle = "rgba(255, 0, 0, 1)";
			ctx.fillRect(0,100-1,width,1);
			ctx.fillStyle = "rgba(255, 198, 0, 1)";
			ctx.fillRect(0,200-1,width,1);
			ctx.fillStyle = "rgba(0, 138, 255, 1)";
			ctx.fillRect(0,300-1,width,1);
			/*
			Console.log(d);
			scope.statsChartData = d;*/
			
			scope.fps = data[0].fps;
			scope.mem = data[0].mem;
			scope.ms = data[0].ms;
			
        });
	}
}