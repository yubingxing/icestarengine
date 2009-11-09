// The Material Class provides an abstract interface between the Engine and the user defined materials
package com.ice.core {
	
		// Imports
	  
		/**
		* <p>Every Plane (walls and floors) in the scene is assigned a Material. The fMaterial Class is used as an interface
		* between the engine and the user-defined materials. The engine provides several material types: Each will end up in
		* a different class being instantiated. See fMaterialTypes to see how materials are defined</p>
		*
		* @see org.ffilmation.engine.core.fMaterialTypes
		*
		*/
		public class fMaterial {
		
			// Static properties

			/**
			* This is an internal cache of materials, so only one material instance is created per definition per scene
			*/
			private static var usedMaterialsPerScene:Object = new Object
			private static var currentScene:fScene
			private static var currentSceneMaterials:Object

			// Private properties
			/** @private */
			public var definition:fMaterialDefinition		// Definition data
			private var type:String				    					// Material type
			private var cls:fEngineMaterial							// The class that generates the material
			
			// Public properties
			
			/**
			* The ID for this material. You can use it, for example, to know the type of Wall you collided against
			* in a collision event.
			*/
			public var id:String

			// Static functions
			/** @private */
			public static function getMaterial(id:String,scene:fScene=null):fMaterial {
					
				 // Use a new cache ?
				 if(scene) {
				 	if(!fMaterial.usedMaterialsPerScene[scene.id]) fMaterial.usedMaterialsPerScene[scene.id] = new Object
				 	fMaterial.currentScene = scene
				 	fMaterial.currentSceneMaterials = fMaterial.usedMaterialsPerScene[scene.id]
				 }
				 
				 // Is material already created for this definition
				 if(fMaterial.currentSceneMaterials[id]) {
				 	
				 		var mat:fMaterial = fMaterial.currentSceneMaterials[id]
				 
				 } else {
				 
				 		mat = new fMaterial(id)
							
				 		// Make sure this material has a definition in the scene. If it doesn't, throw an error
				 		try {
         		
				 				// Special materials
				 				if(id=="default") {
				 					mat.definition = null
				 					mat.type = "default"
				 					mat.cls = new fDefaultMaterial(mat.definition)
				 				} else if(id.toLowerCase()=="invisible") {
				 					mat.definition = null
				 					mat.type = "invisible"
				 					mat.cls = new fInvisibleMaterial(mat.definition)
				 				} else {
				 					mat.definition = fMaterial.currentScene.resourceManager.getMaterialDefinition(id)
				 					mat.type = mat.definition.type
				 					mat.cls = null
				 					if(mat.type == fMaterialTypes.TILE) mat.cls = new fTileMaterial(mat.definition)
				 					else if(mat.type == fMaterialTypes.PERLIN) mat.cls = new fPerlinMaterial(mat.definition)
				 					else if(mat.type == fMaterialTypes.DOOR) mat.cls = new fDoorMaterial(mat.definition)
				 					else if(mat.type == fMaterialTypes.CLIP) mat.cls = new fClipMaterial(mat.definition)
				 					else if(mat.type == fMaterialTypes.WINDOW) mat.cls = new fWindowMaterial(mat.definition)
				 					else if(mat.type == fMaterialTypes.FENCE) mat.cls = new fFenceMaterial(mat.definition)
				 					else if(mat.type == fMaterialTypes.PROCEDURAL) {
				 						var r:Class = getDefinitionByName(mat.definition.xmlData.classname) as Class
				 						mat.cls = new r(mat.definition)
				 					}
				 				}
				 				fMaterial.currentSceneMaterials[id] = mat
				 		
				 		} catch (e:Error) {
			 				throw new Error("The scene does not contain a valid material definition that matches definition id '"+id+"'")
				 		}
				 		
				 		
				 }
				 
				 return mat
				 
			}
			
			// Frees all materials for one scene
			public static function disposeMaterials(scene:fScene):void {
				
				var mats:Object = fMaterial.usedMaterialsPerScene[scene.id]
				if(mats) {
					for(var i in mats) {
						var mat:fMaterial = mats[i]
						mat.dispose()
						delete mats[i]
					}
				}
				fMaterial.usedMaterialsPerScene[scene.id] = null
				
			}


			// Constructor
			/** @private */
			public function fMaterial(id:String):void {
				 this.id = id
			}

			/** @private */
			public function getDiffuse(element:fRenderableElement,width:Number,height,fromPlane:Boolean = false):DisplayObject {
				var s:DisplayObject = this.cls.getDiffuse(element,width,height)
				if(!s) return null
				var r:Sprite = new Sprite()
				r.addChild(s)
				if(fromPlane && element is fWall) s.y = -height
				return r
			}

			/** @private */
			public function getBump(element:fRenderableElement,width:Number,height:Number,fromPlane:Boolean = false):DisplayObject {
				var s:DisplayObject = this.cls.getBump(element,width,height)
				if(!s) return null
				var r:Sprite = new Sprite()
				r.addChild(s)
				if(fromPlane && element is fWall) s.y = -height
				return r
			}

			/** @private */
			public function getContours(element:fRenderableElement,width:Number,height:Number):Array {
				
				var t:Array = this.cls.getContours(element,width,height)
				
				// Adjust wall coordinates
				if(element is fWall) {
					var el:fWall = element as fWall
					var tl:int = t.length
					for(var i:int=0;i<tl;i++) {
						var c:Array = t[i]
						var cl:int = c.length
						for(var j:int=0;j<cl;j++) {
							c[j].y = el.pixelHeight-c[j].y
						}
					}	
				}
				
				return t
			}

			/** @private */
			public function getHoles(element:fRenderableElement,width:Number,height:Number):Array {
				
				var t:Array = this.cls.getHoles(element,width,height)
				var ret:Array = []
				

				// Convert holes to wall coordinates
				if(element is fWall) {

						var el:fWall = element as fWall
						var tl:int = t.length 
						for(c=0;c<tl;c++) {
						  mcontainer = t[c]
			        nobj = new fPlaneBounds()
							nobj.z = el.z+height-(mcontainer.y+mcontainer.height)
							nobj.top = el.z+height-mcontainer.y
							nobj.xrel = mcontainer.x
							nobj.yrel = mcontainer.y
							nobj.width = mcontainer.width
							nobj.height = mcontainer.height

							if(el.vertical) {
								nobj.vertical = true
								nobj.x = el.x
								nobj.x0 = el.x
								nobj.x1 = el.x
								nobj.y = nobj.y0 = el.y+mcontainer.x
								nobj.y1 = el.y+mcontainer.x+mcontainer.width
							} else {
							  nobj.vertical = false
								nobj.y = el.y
								nobj.x = nobj.x0 = el.x+mcontainer.x
								nobj.x1 = el.x+mcontainer.x+mcontainer.width
								nobj.y0 = el.y
								nobj.y1 = el.y
						  }
						  
							block = this.cls.getHoleBlock(element,c)
							if(block) {
								block.x = nobj.xrel
								block.y = nobj.yrel-height
							}
							ret[ret.length] = new fHole(c,nobj,block)
						}
				
			  } else {

				// Convert holes to floor coordinates

						tl = t.length
						for(var c:Number=0;c<tl;c++) {
						  var mcontainer:Rectangle = t[c]
							var nobj:fPlaneBounds = new fPlaneBounds()
							nobj.z = element.z
							nobj.xrel = mcontainer.x
							nobj.yrel = mcontainer.y
							nobj.x0 = nobj.x = element.x+mcontainer.x
							nobj.y0 = nobj.y = element.y+mcontainer.y-mcontainer.height
							nobj.width = mcontainer.width
							nobj.height = mcontainer.height
							nobj.x1 = nobj.x0+nobj.width  
							nobj.y1 = nobj.y0+nobj.height  
							
							var block:MovieClip = this.cls.getHoleBlock(element,c)
							if(block) {
								block.x = nobj.xrel
								block.y = nobj.yrel
							}
							ret[ret.length] = new fHole(c,nobj,block)
						}
        }
			  
				
				return ret
			}
			
			/** @private */
			public function dispose():void {
				if(this.cls) this.cls.dispose()
				this.cls = null
				this.definition = null
			}

		}

}
