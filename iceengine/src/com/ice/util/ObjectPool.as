package org.ffilmation.utils {

		// Imports
		import flash.display.*
		import flash.utils.*
		import flash.net.*
		import flash.geom.*
		import flash.system.*
		
		/** 
		* <p>Object pooling is the process of storing objects in a pool when they are not in use so as to avoid the
		* overhead of creating them again and again. In AS3, objects that are tied to the library are expensive
		* to create. By storing them in a pool for later use you can greatly reduce memory usage and save a handful
		* of milliseconds every frame. ( This definition was copied from here http://mikegrundvig.blogspot.com/2007/05/as3-is-fast.html)</p>
		*
		* <p>This class will return instancies of any given class. When an object is no longer used, if you return it
		* to the pool it will be available to be used again. In a good implementation there would be some sort of factory
		* interface and you would provide an initialization method for each class to ensure properties are properly
		* initialized, but this is not the case here.</p>
		*
		* <p>The engine uses this pool mainly to reuse Sprites and MovieClips, which are very expensive to instantiate. You can
		* use it for you own classes if you want too</p>
		*
		* <p><b>IMPORTANT!</b>: This is a very simple implementation of an object Pool. There is no such thing as size control. If one of your scenes
		* allocated 100 Sprites, for example, once they are returned they will still exist inside the pool and use memory.
		* You can call ObjectPool.flush(Class) or ObjectPool.flush() at anytime to free these resources (after hiding an scene is a good moment).<br>
		* I decided not to automate this process for now because I'm not sure about the real scenarios this engine will face yet. I may do it in future
		* releases.</p>
		*
		* @see http://mikegrundvig.blogspot.com/2007/05/as3-is-fast.html
		*/
		public class ObjectPool {
			
			/** @private */
			private static var classInstances:Dictionary = new Dictionary(false)
		
			/**
			* This method returns an instance of a given Class. If some is available to be reused, that one is used. Otherwise a new instance
			* will be created.
			*
			* @param c The Class that is to be instantiated
			* @return An instance of the given class. You will need to cast it into the appropiate type
			*/
			public static function getInstanceOf(c:Class):Object {
				
				// Retrieve list of available objects for this class
				if(!ObjectPool.classInstances[c]) ObjectPool.classInstances[c] = new Array
				var instances:Array = ObjectPool.classInstances[c]
				
				// Is it empty ? Then add one
				if(instances.length==0) {
					instances.push(new c())
				}
				
				// Return
				var r:Object = instances.pop()
				if(r is MovieClip) (r as MovieClip).gotoAndPlay(1)
				return r

			}
			
			/**
			* Use this method to return unused objects to the pool and make them available to be used again later. Make sure you remove old
			* references to this object or you will get all sorts of weird results.
			*
			* <p>For convenience, if the instance is a DisplayObject, its coordinates, transform values, filters, etc. are reset.</p>
			*
			* @param object The object you are returning to the pool
			*/
			public static function returnInstance(object:Object):void {
				
				if(!object) return
				var c:Class = object.constructor
				
				// Reset display objects
				if(object is MovieClip) {
					var m:MovieClip = object as MovieClip
					m.gotoAndStop(1)
					for(var i in m) trace(i +" "+m[i])
				}

				if(object is Sprite) {
					var s:Sprite = object as Sprite
					s.graphics.clear()
				}

				if(object is Shape) {
					var sh:Shape = object as Shape
					sh.graphics.clear()
				}

				if(object is DisplayObject) {
					
					var d:DisplayObject = object as DisplayObject
					d.x = 0
					d.y = 0
					d.alpha = 1
					d.blendMode = BlendMode.NORMAL
					d.cacheAsBitmap = false
					d.filters = []
					d.mask = null
					d.rotation = 0
					d.scaleX = 1
					d.scaleY = 1
					d.scrollRect = null
					d.visible = true
					d.transform.matrix = new Matrix()
					d.transform.colorTransform = new ColorTransform()
					
				}

				// Retrieve list of available objects for this class
				if(!ObjectPool.classInstances[c]) ObjectPool.classInstances[c] = new Array
				var instances:Array = ObjectPool.classInstances[c]
				instances.push(object)

			}

			/**
			* Use this method delete stored instances and free some memory
			*
			* @param c The Class whose stored instances are to be flushed. Pass nothing or null to flush them all.
			*/
			public static function flush(c:Class=null):void {
				
				if(c) ObjectPool.classInstances[c] = null
				else {
					for(var i in ObjectPool.classInstances) ObjectPool.classInstances[i] = null
				}
				
				// This is really not needed and causes a very annoying player freeze.
				//ObjectPool.garbageCollect()

			}

			/**
			* Explicitly invokes the garbage collector
			* @private
			*/
			public static function garbageCollect():void {
				try	{
    	    var hlcp:LocalConnection = new LocalConnection()
    	    var hlcs:LocalConnection = new LocalConnection()
    	    hlcp.connect('name')
    	    hlcs.connect('name')
    	  }	catch (e:Error)	{
					System.gc()
					System.gc()
				}
			}

			
		}

}