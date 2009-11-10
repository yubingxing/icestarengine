package com.ice.helpers {
	import com.ice.core.Scene;
	
		// Imports

		/** 
		* @private
		* THIS IS A HELPER OBJECT. OBJECTS IN THE HELPERS PACKAGE ARE NOT SUPPOSED TO BE USED EXTERNALLY. DOCUMENTATION ON THIS OBJECTS IS 
		* FOR DEVELOPER REFERENCE, NOT USERS OF THE ENGINE
		*
		* This object stores data of a fCellEvent. This data comes from the XML definition for that event
		*
		*/
		public class CellEventInfo {
		
				/**
				* Stores type of event
				*/
				public var name:String
				
				/**
				* Stores XML of event
				*/
				public var xml:XML
				
				/**
				* Coordinates and size of the evetn area
				*/
				public var i:int = 0
				public var j:int = 0
				public var k:int = 0
				public var x:int = 0
				public var y:int = 0
				public var z:int = 0
				public var width:int = 0
				public var depth:int = 0
				public var height:int = 0


				/**
				* Constructor
				*/
				function CellEventInfo(xml:XML,scene:Scene):void {
					
					this.xml = xml
					this.name = xml.@name[0].toString()

			   	this.i = int((new Number(xml.@x[0]))/scene.gridSize)
			   	this.j = int((new Number(xml.@y[0]))/scene.gridSize)
					this.k = int((new Number(xml.@z[0]))/scene.levelSize)
			   	
			   	this.x = this.i*scene.gridSize
			   	this.y = this.j*scene.gridSize
			   	this.z = this.k*scene.levelSize
			   		
			   	this.height = int((new Number(xml.@height[0]))/scene.levelSize)*scene.levelSize
			   	this.width = int((new Number(xml.@width[0]))/scene.gridSize)*scene.gridSize
			   	this.depth = int((new Number(xml.@depth[0]))/scene.gridSize)*scene.gridSize

					
				}

		}
		
}