// RESOURCE MANAGER
package com.ice.core.scene.initialize {
	
	// Imports
	
	/**
	 * The resource manager loads and stores all resources (material and objects definitions, media, etc) available to this scene
	 * IMPORTANT: All paths are relative to the path of the XML where the path is defined. This is mandatory because the standalone editor
	 * does not have a valid basepath
	 * @private
	 */
	public class SceneResourceManager extends EventDispatcher {
		
		// Static properties
		
		/**
		 * An string describing the process of loading and processing scene resources.
		 * Events dispatched by the resource manager contain this String as a description of what is happening
		 */
		public static const LOADINGDESCRIPTION:String = "Loading resources"
		
		// Gets the absolute path for a path relative to a base XML file
		public static function mergePaths(base:String,path:String):String {
			
			// Path is already absolute
			if(path.indexOf(":")>=0) return path
			
			// Path is relative
			base = base.split("\\").join("/")
			base = base.substr(0,base.lastIndexOf("/"))
			var p1:Array = base.split("/")
			var p2:Array = path.split("/")
			for(var i:int=0;i<p2.length;i++) {
				if(p2[i]==".") {}
				else if(p2[i]=="..") {
					if(p1.length>0) p1.pop()
					else p1.push(p2[i])
				}
				else p1.push(p2[i])
			}
			
			var ret:String = p1.join("/")
			return ret
			
		}
		
		// Private vars
		private var scene:fScene
		private var objectDefinitions:Object
		private var materialDefinitions:Object
		private var loadedFiles:Array
		
		// Temporal
		private var mediaSrcs:Array
		private var srcs:Array
		private var src:String
		private var queuePointer:Number
		
		// Constructor
		public function SceneResourceManager(s:fScene):void {
			
			this.scene = s
			this.objectDefinitions = new Object()
			this.materialDefinitions = new Object()
			this.loadedFiles = new Array
			
			// Media SWFs pending load are stored here
			this.mediaSrcs = new Array
			
			// Definition files pending load are stored here
			this.srcs = new Array
			
		}	
		
		/**
		 * Retrieves a list of all material definition ids
		 */
		public function getMaterials():Array {
			var ret:Array = new Array
			for(var i in this.materialDefinitions) ret.push(i)
			return ret
		}
		
		/**
		 * Retrieves a list of all object definition ids
		 */
		public function getObjects():Array {
			var ret:Array = new Array
			for(var i in this.objectDefinitions) ret.push(i)
			return ret
		}
		
		/**
		 * This method is called to retrieve a material definition
		 */
		public function getMaterialDefinition(id:String):fMaterialDefinition {
			return this.materialDefinitions[id]
		}
		
		/**
		 * This method is called to retrieve an object definition
		 */
		public function getObjectDefinition(id:String):fObjectDefinition {
			return this.objectDefinitions[id]
		}
		
		/**
		 * This method adds resources from a given xml to the manager
		 *
		 * @param xmlObj Where to search for resource definitions
		 * @param basepath Path of the XML we are processing, so relative paths can be resolved
		 */
		public function addResourcesFrom(xmlObj:XML,basePath:String):void {
			
			// Only if this XML is not already loaded
			if(this.loadedFiles.indexOf(basePath)<0) {
				
				this.loadedFiles.push(basePath)
				
				// Retrieve media files
				var temp:XMLList = xmlObj.child("media")
				for(var i:Number=0;i<temp.length();i++) {
					var relativePath:String = temp[i].@src
					var absolulePath:String = SceneResourceManager.mergePaths(basePath,relativePath)
					if(this.mediaSrcs.indexOf(absolulePath)<0) this.mediaSrcs.push(absolulePath)
				}
				
				// Retrieve Object definitions
				var defs:XMLList = xmlObj.child("objectDefinition")
				for(i=0;i<defs.length();i++) {
					this.objectDefinitions[defs[i].@name] = new fObjectDefinition(defs[i].copy(),basePath)
				}
				
				// Retrieve Material definitions
				defs = xmlObj.child("materialDefinition")
				for(i=0;i<defs.length();i++) this.materialDefinitions[defs[i].@name] = new fMaterialDefinition(defs[i].copy(),basePath)
				
				// Retrieve nested definition files
				for(i=0;i<xmlObj.child("definitions").length();i++) {
					relativePath = xmlObj.child("definitions")[i].@src
					absolulePath = SceneResourceManager.mergePaths(basePath,relativePath)
					if(this.srcs.indexOf(absolulePath)<0) this.srcs.push(absolulePath)
				}
				
			}
			
			this.loadDefinitionFiles()
			
		}
		
		
		// PRIVATE METHODS. NO NEED TO USE THEM EXTERNALLY
		
		private function loadDefinitionFiles():void {
			
			// If there are pending definition files, process them
			if(this.srcs.length>0) {
				
				// Load
				this.src = this.srcs.shift()
				var url:URLRequest = new URLRequest(this.src)
				var loadUrl:URLLoader = new URLLoader(url)
				loadUrl.load(url)
				loadUrl.addEventListener(ProgressEvent.PROGRESS, this.XMLloadProgress)
				loadUrl.addEventListener(Event.COMPLETE, this.XMLloadComplete)
				loadUrl.addEventListener(IOErrorEvent.IO_ERROR ,this.XMLloadError)
				this.dispatchEvent(new fProcessEvent(fScene.LOADPROGRESS,0,SceneResourceManager.LOADINGDESCRIPTION,0,"Loading definition file: "+this.src))
				
			} else {
				
				// If there are no definition files left, start loading media files
				this.loadMediaFiles()
			}
			
		}
		
		// Error loading current definition file
		private function XMLloadError(event:IOErrorEvent):void {
			
			event.target.removeEventListener(ProgressEvent.PROGRESS, this.XMLloadProgress)
			event.target.removeEventListener(Event.COMPLETE, this.XMLloadComplete)
			event.target.removeEventListener(IOErrorEvent.IO_ERROR ,this.XMLloadError)
			this.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,"Error loading file: "+this.src))
			
		}
		
		
		// Update status of current definition file
		private function XMLloadProgress(event:ProgressEvent):void {
			
			var percent:Number = (event.bytesLoaded/event.bytesTotal)
			this.dispatchEvent(new fProcessEvent(fScene.LOADPROGRESS,0,SceneResourceManager.LOADINGDESCRIPTION,percent,"Loading definition file: "+this.src))
			
		}
		
		// Definition file complete
		private function XMLloadComplete(event:Event):void {
			
			this.dispatchEvent(new fProcessEvent(fScene.LOADPROGRESS,0,SceneResourceManager.LOADINGDESCRIPTION,100,"Loading definition file: "+this.src))
			event.target.removeEventListener(ProgressEvent.PROGRESS, this.XMLloadProgress)
			event.target.removeEventListener(Event.COMPLETE, this.XMLloadComplete)
			event.target.removeEventListener(IOErrorEvent.IO_ERROR ,this.XMLloadError)
			
			// Add resources (will continue loads if necessary)
			this.addResourcesFrom(new XML(event.target.data),this.src)
			
		}
		
		
		// Start loading media files
		private function loadMediaFiles():void {
			
			// Read media files
			this.dispatchEvent(new fProcessEvent(fScene.LOADPROGRESS,0,SceneResourceManager.LOADINGDESCRIPTION,0,"Loading media files"))
			
			// Listen to media load events
			this.queuePointer = -1
			this.scene.engine.addEventListener(fEngine.MEDIALOADCOMPLETE,this.loadComplete)
			this.scene.engine.addEventListener(fEngine.MEDIALOADPROGRESS,this.loadProgress)
			this.scene.engine.addEventListener(fEngine.MEDIALOADERROR,this.loadError)
			this.loadComplete(new Event("Dummy"))
			
		}
		
		// Error loading current definition file
		private function loadError(event:Event):void {
			
			this.scene.engine.removeEventListener(fEngine.MEDIALOADCOMPLETE,this.loadComplete)
			this.scene.engine.removeEventListener(fEngine.MEDIALOADPROGRESS,this.loadProgress)
			this.scene.engine.removeEventListener(fEngine.MEDIALOADERROR,this.loadError)
			this.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,"Error loading "+this.src))
			
		}
		
		// Process loaded media file and load next one
		private function loadComplete(event:Event):void {
			
			this.queuePointer++
			if(this.queuePointer<this.mediaSrcs.length) {
				
				// Load
				this.src = this.mediaSrcs[this.queuePointer]
				var current:Number = 100*(this.queuePointer)/this.mediaSrcs.length
				this.dispatchEvent(new fProcessEvent(fScene.LOADPROGRESS,current,SceneResourceManager.LOADINGDESCRIPTION,current,"Loading media files ( current: "+this.src+"  ) "))
				
				this.scene.engine.loadMedia(this.src)
				
			} else {
				
				// All loaded
				this.mediaSrcs = new Array
				this.scene.engine.removeEventListener(fEngine.MEDIALOADCOMPLETE,this.loadComplete)
				this.scene.engine.removeEventListener(fEngine.MEDIALOADPROGRESS,this.loadProgress)
				this.scene.engine.removeEventListener(fEngine.MEDIALOADERROR,this.loadError)
				this.dispatchEvent(new fProcessEvent(fScene.LOADPROGRESS,100,SceneResourceManager.LOADINGDESCRIPTION,100,"All media files loaded"))
				this.dispatchEvent(new Event(Event.COMPLETE))
			}
			
		}
		
		// Update status of current media file
		private function loadProgress(event:ProgressEvent):void {
			
			var percent:Number = (event.bytesLoaded/event.bytesTotal)
			var current:Number = 100*(this.queuePointer+percent)/this.mediaSrcs.length
			this.dispatchEvent(new fProcessEvent(fScene.LOADPROGRESS,current,SceneResourceManager.LOADINGDESCRIPTION,100*percent,"Loading media files ( current: "+this.src+"  ) "))
			
		}
		
		
	}
	
}