package com.ice.helpers {
	
		// Imports
		import flash.utils.*

		import org.ffilmation.engine.core.*
		import org.ffilmation.engine.logicSolvers.collisionSolver.collisionModels.*
		
		/**
		* @private
		* THIS IS A HELPER OBJECT. OBJECTS IN THE HELPERS PACKAGE ARE NOT SUPPOSED TO BE USED EXTERNALLY. DOCUMENTATION ON THIS OBJECTS IS 
		* FOR DEVELOPER REFERENCE, NOT USERS OF THE ENGINE
		*
		* This object stores an object definition loaded from a definition XML
	  */
		public class ObjectDefinition extends ResourceDefinition {

			// Public vars
			public var _sprites:Array
			public var receiveLights:Boolean
			public var receiveShadows:Boolean
			public var castShadows:Boolean
			public var solid:Boolean
			
			// Constructor
			public function ObjectDefinition(data:XML,basepath:String):void {

			   super(data,basepath)

	  		 // Definition Lights enabled ?
	  		 this.receiveLights = data.@receiveLights.toString()!="false"
	  		 this.receiveShadows = data.@receiveShadows.toString()!="false"
	  		 this.castShadows = data.@castShadows.toString()!="false"
	  		 this.solid = data.@solid.toString()!="false"
			
			}	 

			// Return display model
			public function get sprites():Array {

				 // Parse display model
				 if(!this._sprites) {
				 
				 		this._sprites = new Array
				 		var sprites:XMLList = this.xmlData.displayModel.child("sprite")
				 		for(var i:Number=0;i<sprites.length();i++) {
				 			
				 				var spr:XML = sprites[i]
				 				
				 				// Check for library item
			   		    var clase:Class = getDefinitionByName(spr.@src) as Class
				 		
				 				// Check for shadow definition or use default
				 				try {
			   					var shadow:Class = getDefinitionByName(spr.@shadowsrc) as Class
			   				} catch(e:Error) {
			   					shadow = clase
			   				}
				 				this._sprites[this._sprites.length] = new SpriteDefinition(parseInt(spr.@angle),clase,shadow)
				 				
				 		}
								
				 		// Sort _sprites and add first one to the end of the list
				 		this._sprites.sortOn("angle", Array.NUMERIC)
				 		this._sprites[this._sprites.length] = this._sprites[0]
				 
				 }

				 return this._sprites

			}
			
			// Return a collision model for this definition
			public function get collisionModel():fEngineCollisionModel {
				 
				 // Retrieve collision model
				 if(this.xmlData.collisionModel.cilinder.length()>0) {
				 			return new fCilinderCollisionModel(this.xmlData.collisionModel.cilinder[0])
				 } else if(this.xmlData.collisionModel.box.length()>0) {
				 		  return new fBoxCollisionModel(this.xmlData.collisionModel.box[0])
				 } else throw new Error("Can't find a collision model")

			}
			

		}
		
} 
