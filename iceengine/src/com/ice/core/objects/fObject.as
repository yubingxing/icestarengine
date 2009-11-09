// Object class
package com.ice.core.objects {
	
		// Imports

		/** 
		* <p>An Object is a graphic element that is part of the the environment and is not projected in any way.
		* The library item is attached to the scene as is. Objects cast and receive shadows.</p>
		*
		* <p>Trees, statues and furniture are typical examples of objects.</p>
		* 
		* <p>Objects can't be moved and can't be added/removed dynamically because this allows several rendering optimizations. 
		* If you want to move something or add/remove it on the fly use the "Character" class instead</p>
		*
		* <p>YOU CAN'T CREATE INSTANCES OF THIS OBJECT.<br>
		* Objects are created when the scene is processed</p>
		*
		* @see org.ffilmation.engine.elements.fCharacter
		*/
		public class fObject extends fRenderableElement {
			
			// Constants
			
			/**
			* Limits size of object shadow projection relative to X times the object's height (amount of stretching movieClips will suffer)
			*/
			public static const MAXSHADOW = 2
			
			/**
			* Shadows are harder or softer depending on the distance from the shadow origin to the plane where the shadow is drawn
			* This constant defines the max distance in pixels at which a shadow will be seen. The shadow's alpha values will fade
			* from 1 to 0 along this distance
			*/
			public static const SHADOWRANGE = 100
			
			/**
			* Shadows become bigger as they fade away. This is the scaling factor -1. 1 means the shadow doubles in size
			*/
			public static const SHADOWSCALE = 0.7
			
			// Private properties
			/** @private */
			public var definition:fObjectDefinition
			/** @private */
			public var sprites:Array
			/** @private */
			public var _orientation:Number
			/** @private */
			public var shadowRange:Number
			
			// Public properties


			/** 
			* The collision model for this object. A collision model is a matematical representation of an object's geometry
			* that is used to manage collisions. For example, a box is a good collision model for a car, and a cilinder is a
			* good collision model for people.<br>
		  * Collision models need to be simple geometry so the engine can solve collisions fast.
		  * @private
			*/
			public var collisionModel:fEngineCollisionModel
			
			/**
			* The definition ID for this fObject. It is useful for example when processing collision events, as it will allow
			* you to know what kind of thing did you collide against.
			*/
			public var definitionID:String
			
			/**
			* This property provides a bit of rendering optimization.
			* Non-Animated objects can be rendered faster if their cacheAsBitmap property is set to true.
			* For animated objects this would slowdown performance as the cache would be redrawn continuously.
			* Don't confuse "animated" ( a looping movieClip ) with "moveable".
			* fObjects default to non-animated and fCharacters default to animated. You can use the <b>animated</b> attribute in your XMLs to change this
			 */
			public var animated:Boolean = false
			
			// Events
			
			/**
 			* The fObject.NEWORIENTATION constant defines the value of the 
 			* <code>type</code> property of the event object for a <code>objectNewOrientation</code> event.
 			* The event is dispatched when the object changes its orientation
 			* 
 			* @eventType objectNewOrientation
 			*/
		  public static const NEWORIENTATION:String = "objectNewOrientation"

			/**
 			* The fObject.GOTOANDPLAY constant defines the value of the 
 			* <code>type</code> property of the event object for a <code>objectGotoAndPlay</code> event.
 			* The event is dispatched when you execute a gotoAndPlay call in the object
 			* 
 			* @eventType objectGotoAndPlay
 			*/
		  public static const GOTOANDPLAY:String = "objectGotoAndPlay"


			/**
 			* The fObject.GOTOANDSTOP constant defines the value of the 
 			* <code>type</code> property of the event object for a <code>objectGotoAndStop</code> event.
 			* The event is dispatched when you execute a gotoAndPlay call in the object
 			* 
 			* @eventType objectGotoAndStop
 			*/
		  public static const GOTOANDSTOP:String = "objectGotoAndStop"


			// Constructor
			/** @private */
			function fObject(defObj:XML,scene:fScene):void {
				
				 // Previous
				 super(defObj,scene)
				 
				 // Make sure this object has a definition in the scene. If it doesn't, throw an error
			 	 this.definitionID = defObj.@definition
				 this.definition = this.scene.resourceManager.getObjectDefinition(this.definitionID)
				 if(!this.definition) {
						throw new Error("The scene does not contain a valid object definition that matches definition id '"+this.definitionID+"'")
				 }
				
				 // Retrieve all sprites for this object
				 try {
					 this.sprites = this.definition.sprites
				 } catch(e:Error) {
						throw new Error("Object definition '"+this.definitionID+"' contains an invalid display model or it can't be applied to object '"+this.id+"' "+e)
				 }
				
				 // Initialize rotation for this object
				 this._orientation = 0
						
	  		 // Is it animated ?
	  		 if(defObj.@animated.length()==1) this.animated = (defObj.@animated.toString()=="true")
	  				
	  		 // Definition Lights enabled ?
	  		 if(defObj.@receiveLights.length()!=1) this.receiveLights = this.definition.receiveLights
	  
	  		 // Definition Shadows enabled ?
	  		 if(defObj.@receiveShadows.length()!=1) this.receiveShadows = this.definition.receiveShadows
	  
	  		 // Definition Projects shadow ?
	  		 if(defObj.@castShadows.length()!=1) this.castShadows = this.definition.castShadows
	  
	  		 // Definition Solid ?
	  		 if(defObj.@solid.length()!=1) this.solid = this.definition.solid
				 
				 // Retrieve collision model
				 try {
	 			 	this.collisionModel = this.definition.collisionModel
				 } catch(e:Error) {
						throw new Error("Object definition '"+this.definitionID+"' contains an invalid collision model or it can't be applied to object '"+this.id+"'")
				 }

		     // Define shadowRange
		     this.shadowRange = this.height*fObject.MAXSHADOW*fEngine.DEFORMATION

		     // Define bounds. I need to load the symbol from the library to know its size. I will be destroyed immediately
			   this.top = this.z+this.height
				 this.x0 = this.x-this.radius
				 this.x1 = this.x+this.radius
				 this.y0 = this.y-this.radius
				 this.y1 = this.y+this.radius
				 
				 var clase:Class = this.sprites[0].sprite as Class
				 var tempSprite:MovieClip = objectPool.getInstanceOf(clase) as MovieClip
				 var w:Number = tempSprite.width
				 var h:Number = tempSprite.height
			   this.bounds2d = new Rectangle(-w/2,-h,w,h)
				 objectPool.returnInstance(tempSprite)

			   // Screen area
			   this.screenArea = this.bounds2d.clone()
				 this.screenArea.offsetPoint(fScene.translateCoords(this.x,this.y,this.z))
				
			 	 // Initial orientation
			 	 if(defObj.@orientation.length()>0) this.orientation = new Number(defObj.@orientation[0])
			 	 else this.orientation = 0
				 
			}

			/** @private */
			public override function distanceTo(x:Number,y:Number,z:Number):Number {
			
				 var n1:Number = mathUtils.distance3d(x,y,z,this.x,this.y,this.z)
				 var n2:Number = mathUtils.distance3d(x,y,z,this.x,this.y,this.top)
				 
				 return (n1<n2) ? n1 : n2
			
			}

			/**
			* The orientation (in degrees) of the object along the Z axis. That is, if the object was a man standing anywhere on our scene, this
			* would be where was his nose pointing. The default value of 0 indicates it is "looking" towards the positive X axis.
			*
			* The Axis in the Filmation Engine go like this.
			*		 
			*	<listing version="3.0">	 
			*		 positive Z
			*		         |
			*		         |      / positive X
			*		         |    /
			*		         |  /
			*	   (0,0,0) X/
			*		          \
			*		            \
			*		              \
			*		                \ positive Y
		  * </listing>
		  *
			* @param angle The angle, in degrees, when want to set
			*/
			public function set orientation(angle:Number):void {
				
				var correctedAngle:Number = angle%360
				if(correctedAngle<0) correctedAngle+=360
				this._orientation = correctedAngle
				correctedAngle/=360
				if(isNaN(correctedAngle)) return
				
				// Update collision model
				var newSprite:int = int(correctedAngle*this.sprites.length)
				this.collisionModel.orientation = (this.sprites[newSprite] as fSpriteDefinition).angle
				
				// Dispatch event so the render engine updates the screen
				this.dispatchEvent(new Event(fObject.NEWORIENTATION))
				
			}

			public function get orientation():Number {
				return this._orientation
	  	}


			/**
			* The height in pixels of an imaginary cilinder enclosing the object. It is used only for colision detection. You can change it anytime
			* This is useful for example if a character has rolling or crawling movements and you want to change its collision height during those
			* movements.
			*/
			public function set height(h:Number):void {
				this.collisionModel.height = h
				this.top = this.z+h
			}
			public function get height():Number {
				return this.collisionModel.height
	  	}

			/**
			* The radius in pixels of an imaginary cilinder enclosing the object. It is used only for colision detection.
			*/
			public function get radius():Number {
				return this.collisionModel.getRadius()
	  	}

			/**
			* Passes the stardard gotoAndPLay command to the base clip
			*
			* @param where A frame number or frame label
			*/
			public override function gotoAndPlay(where:*):void {
					
				if(this.flashClip) this.flashClip.gotoAndPlay(where)
			    
				// Dispatch event so the render engine updates the screen
				this.dispatchEvent(new Event(fObject.GOTOANDPLAY))

			}

			/**
			* Passes the stardard gotoAndStop command to the base clip
			*
			* @param where A frame number or frame label
			*/
			public override function gotoAndStop(where:*):void {
				
				if(this.flashClip) this.flashClip.gotoAndStop(where)

				// Dispatch event so the render engine updates the screen
				this.dispatchEvent(new Event(fObject.GOTOANDSTOP))
				
			}

			/**
			* Calls a function of the base clip
			*
			* @param what Name of the function to call
			*
			* @param param An optional extra parameter to pass to the function
			*/
			public override function call(what:String,param:*=null):void {
					
					if(this.flashClip) this.flashClip[what](param)

			}


			/**
			* Objects can't be moved
			* @private
			*/
			public override function moveTo(x:Number,y:Number,z:Number):void {
			  throw new Error("Filmation Engine Exception: You can't move a fObject. If you want to move "+this.id+" make it an fCharacter"); 
			}
			
			/**
			* Updates zIndex of this object so it displays with proper depth inside the scene
			* @private
			*/
			public function updateDepth():void {
				
				 var c:fCell = (this.cell==null)?(this.scene.translateToCell(this.x,this.y,this.z)):(this.cell)
				 var nz:Number = c.zIndex
				 this.setDepth(nz)
				 
			}
			
			/** @private */
			public function disposeObject():void {

				this.definition = null
				this.sprites = null
				this.collisionModel = null
				this.disposeRenderable()
				
			}

			/** @private */
			public override function dispose():void {
				this.disposeObject()
			}		



		}
		
		
}