// Character class
package com.ice.core.logic.collision {
	
		// Imports

		/** 
		* This class constains all methods related to collision detection and solving.
		* @private
		*/
		public class CollisionSolver {

			/** 
			* This methods tests a character's collisions at its current position, generates collision events (if any)
			* and moves the character into a valid position if necessary.
			* dx,dy and dz indicate the direction of the character and are useful to optimize tests
			*/
			public static function solveCharacterCollisions(character:fCharacter,dx:Number,dy:Number,dz:Number):void {
			
		 		var scene:fScene = character.scene
		 		var testCell:fCell,testElement:fRenderableElement, confirm:Collision
		 		var primaryCandidates:Array = new Array
		 		var secondaryCandidates:Array = new Array
		 		var radius:Number = character.radius+scene.gridSize
		 		var realRadius:Number = character.radius
				var i:int
				var j:int
				var l:int
				var some:Boolean
				var tz:Number
				var gs:int = scene.gridSize
				var charz:Number = Math.max(character.z,0)
		 		
			 	// Test against floors
			 	if(dz<0) {
						
					mx = character.x+radius
					my = character.y+radius
					for(ty = character.y-radius;ty<=my;ty+=gs) {
						for(tx = character.x-radius;tx<=mx;tx+=gs) {
					
							try {
								if(character.z>0) {
									testCell = scene.translateToCell(tx,ty,character.z)
									if(testCell.walls.top) primaryCandidates[primaryCandidates.length] = (testCell.walls.top)
								} else {
									testCell = scene.translateToCell(tx,ty,0)
									primaryCandidates[primaryCandidates.length] = (testCell.walls.bottom)
								}
								
			 					if(testCell.walls.up) secondaryCandidates[secondaryCandidates.length] = (testCell.walls.up)
			 					if(testCell.walls.down) secondaryCandidates[secondaryCandidates.length] = (testCell.walls.down)
			 					if(testCell.walls.left) secondaryCandidates[secondaryCandidates.length] = (testCell.walls.left)
			 					if(testCell.walls.right) secondaryCandidates[secondaryCandidates.length] = (testCell.walls.right)
          			
			 					var nchars:Number = testCell.charactersOccupying.length
			 					for(k=0;k<nchars;k++) if(testCell.charactersOccupying[k]!=character && testCell.charactersOccupying[k]._visible) secondaryCandidates[secondaryCandidates.length] = (testCell.charactersOccupying[k])
			 					
			 					var nobjects:Number = testCell.walls.objects.length
			 					for(var k:Number=0;k<nobjects;k++) if(testCell.walls.objects[k]._visible) secondaryCandidates[secondaryCandidates.length] = (testCell.walls.objects[k])
							} catch (e:Error) {
							}
			 				
			 		
			 			}
			 		}
			 			
        
				}
				
				if(dz>0) {
					
					mx = character.x+radius
					my = character.y+radius
					for(ty = character.y-radius;ty<=my;ty+=gs) {
						for(tx = character.x-radius;tx<=mx;tx+=gs) {

							try {
								testCell = scene.translateToCell(tx,ty,character.z+character.height)
								if(testCell.walls.bottom) primaryCandidates[primaryCandidates.length] = (testCell.walls.bottom)	
			 					
			 					if(testCell.walls.up) secondaryCandidates[secondaryCandidates.length] = (testCell.walls.up)
			 					if(testCell.walls.down) secondaryCandidates[secondaryCandidates.length] = (testCell.walls.down)
			 					if(testCell.walls.left) secondaryCandidates[secondaryCandidates.length] = (testCell.walls.left)
			 					if(testCell.walls.right) secondaryCandidates[secondaryCandidates.length] = (testCell.walls.right)
			 					
			 					nchars = testCell.charactersOccupying.length
			 					for(k=0;k<nchars;k++) if(testCell.charactersOccupying[k]!=character && testCell.charactersOccupying[k]._visible) secondaryCandidates[secondaryCandidates.length] = (testCell.charactersOccupying[k])
			 					
			 					nobjects = testCell.walls.objects.length
			 					for(k=0;k<nobjects;k++) if(testCell.walls.objects[k]._visible) secondaryCandidates[secondaryCandidates.length] = (testCell.walls.objects[k])
							} catch (e:Error) {
							}
			 				
			 			}
			 			
			 		}
					
				}
				
				
				if(dx<0) {
					
					for(tz=charz;tz<=character.top;tz+=scene.levelSize) {
						
						var my:Number = character.y+radius
						for(var ty:Number = character.y-radius;ty<=my;ty+=gs) {
						
							try {
								testCell = scene.translateToCell(character.x-realRadius,ty,tz)
								if(testCell.walls.right) primaryCandidates[primaryCandidates.length] = (testCell.walls.right)
            		
			 					nchars = testCell.charactersOccupying.length
			 					for(k=0;k<nchars;k++) if(testCell.charactersOccupying[k]!=character && testCell.charactersOccupying[k]._visible) primaryCandidates[primaryCandidates.length] = (testCell.charactersOccupying[k])
			 					
			 					nobjects = testCell.walls.objects.length
			 					for(k=0;k<nobjects;k++) if(testCell.walls.objects[k]._visible) primaryCandidates[primaryCandidates.length] = (testCell.walls.objects[k])
          			
								if(testCell.walls.up && testCell.walls.up.y>(character.y-realRadius)) secondaryCandidates[secondaryCandidates.length] = (testCell.walls.up)
								if(testCell.walls.down && testCell.walls.down.y<(character.y+realRadius)) secondaryCandidates[secondaryCandidates.length] = (testCell.walls.down)
								if(testCell.walls.top && testCell.walls.top.z<character.top) secondaryCandidates[secondaryCandidates.length] = (testCell.walls.top)
								if(testCell.walls.bottom && testCell.walls.bottom.z>character.z) secondaryCandidates[secondaryCandidates.length] = (testCell.walls.bottom)
							} catch (e:Error) {
								
								// This means we went outside scene limits and found a null cell. We return a false wall to simulate a collision

								var xcell:Number = ((character.x-realRadius)/gs)
								var ycell:Number = (ty/gs)
								if(xcell<0) xcell = -1
								if(ycell<0) ycell = -1
								
								var ntx:int = gs*(int(xcell)+1)
								var nty:int = gs*(int(ycell))
								var gh:int = scene.height
								primaryCandidates[primaryCandidates.length] = (new fWall(<wall x={ntx} y={nty} size={gs} height={gh} z={0} direction={"vertical"} />,scene))
							}	
							
						}
					}
					
        
				}
        
				if(dx>0) {
					
					for(tz=charz;tz<=character.top;tz+=scene.levelSize) {

						my = character.y+radius
						for(ty = character.y-radius;ty<=my;ty+=gs) {

							try {
								testCell = scene.translateToCell(character.x+realRadius,ty,tz)
								if(testCell.walls.left) primaryCandidates[primaryCandidates.length] = (testCell.walls.left)
            		
			 					nchars = testCell.charactersOccupying.length
			 					for(k=0;k<nchars;k++) if(testCell.charactersOccupying[k]!=character && testCell.charactersOccupying[k]._visible) primaryCandidates[primaryCandidates.length] = (testCell.charactersOccupying[k])
          			
			 					nobjects = testCell.walls.objects.length
			 					for(k=0;k<nobjects;k++) if(testCell.walls.objects[k]._visible) primaryCandidates[primaryCandidates.length] = (testCell.walls.objects[k])
          			
								if(testCell.walls.up && testCell.walls.up.y>(character.y-realRadius)) secondaryCandidates[secondaryCandidates.length] = (testCell.walls.up)
								if(testCell.walls.down && testCell.walls.down.y<(character.y+realRadius)) secondaryCandidates[secondaryCandidates.length] = (testCell.walls.down)
								if(testCell.walls.top && testCell.walls.top.z<character.top) secondaryCandidates[secondaryCandidates.length] = (testCell.walls.top)
								if(testCell.walls.bottom && testCell.walls.bottom.z>character.z) secondaryCandidates[secondaryCandidates.length] = (testCell.walls.bottom)
							
							} catch (e:Error) {

								// This means we went outside scene limits and found a null cell. We return a false wall to simulate a collision

								xcell = ((character.x+realRadius)/gs)
								ycell = (ty/gs)
								if(xcell<0) xcell = -1
								if(ycell<0) ycell = -1
								
								ntx = gs*(int(xcell))
								nty = gs*(int(ycell))
								gh = scene.height
								primaryCandidates[primaryCandidates.length] = (new fWall(<wall x={ntx} y={nty} size={gs} height={gh} z={0} direction={"vertical"} />,scene))
							}
							
						}
						
					}
        
				}
        
				if(dy<0) {
					
					for(tz=charz;tz<=character.top;tz+=scene.levelSize) {
						
						var mx:Number = character.x+radius
						for(var tx:Number = character.x-radius;tx<=mx;tx+=gs) {
							
							try {
								testCell = scene.translateToCell(tx,character.y-realRadius,tz)
								if(testCell.walls.down) primaryCandidates[primaryCandidates.length] = (testCell.walls.down)
            		
			 					nchars = testCell.charactersOccupying.length
			 					for(k=0;k<nchars;k++) if(testCell.charactersOccupying[k]!=character && testCell.charactersOccupying[k]._visible) primaryCandidates[primaryCandidates.length] = (testCell.charactersOccupying[k])
         	  		
			 					nobjects = testCell.walls.objects.length
			 					for(k=0;k<nobjects;k++) if(testCell.walls.objects[k]._visible) primaryCandidates[primaryCandidates.length] = (testCell.walls.objects[k])
          			
								if(testCell.walls.left && testCell.walls.left.x>(character.x-realRadius)) secondaryCandidates[secondaryCandidates.length] = (testCell.walls.left)
								if(testCell.walls.right && testCell.walls.right.x<(character.x+realRadius)) secondaryCandidates[secondaryCandidates.length] = (testCell.walls.right)
								if(testCell.walls.top && testCell.walls.top.z<character.top) secondaryCandidates[secondaryCandidates.length] = (testCell.walls.top)
								if(testCell.walls.bottom && testCell.walls.bottom.z>character.z) secondaryCandidates[secondaryCandidates.length] = (testCell.walls.bottom)
							} catch (e:Error) {

								// This means we went outside scene limits and found a null cell. We return a false wall to simulate a collision

								xcell = (tx/gs)
								ycell = ((character.y-realRadius)/gs)
								if(xcell<0) xcell = -1
								if(ycell<0) ycell = -1
								
								ntx = gs*(int(xcell))
								nty = gs*(int(ycell+1))

								gh = scene.height
								primaryCandidates[primaryCandidates.length] = (new fWall(<wall x={ntx} y={nty} size={gs} height={gh} z={0} direction={"horizontal"} />,scene))
							}
							
						}
					}
				
				}
        
				if(dy>0) {
					
					for(tz=charz;tz<=character.top;tz+=scene.levelSize) {
						
						mx = character.x+radius
						for(tx=character.x-radius;tx<=mx;tx+=gs) {
						
							try {
								testCell = scene.translateToCell(tx,character.y+realRadius,tz)
								if(testCell.walls.up) primaryCandidates[primaryCandidates.length] = (testCell.walls.up)
          			
			 					nchars = testCell.charactersOccupying.length
			 					for(k=0;k<nchars;k++) if(testCell.charactersOccupying[k]!=character && testCell.charactersOccupying[k]._visible) primaryCandidates[primaryCandidates.length] = (testCell.charactersOccupying[k])
          			
			 					nobjects = testCell.walls.objects.length
			 					for(k=0;k<nobjects;k++) if(testCell.walls.objects[k]._visible) primaryCandidates[primaryCandidates.length] = (testCell.walls.objects[k])
          			
								if(testCell.walls.left && testCell.walls.left.x>(character.x-realRadius)) secondaryCandidates[secondaryCandidates.length] = (testCell.walls.left)
								if(testCell.walls.right && testCell.walls.right.x<(character.x+realRadius)) secondaryCandidates[secondaryCandidates.length] = (testCell.walls.right)
								if(testCell.walls.top && testCell.walls.top.z<character.top) secondaryCandidates[secondaryCandidates.length] = (testCell.walls.top)
								if(testCell.walls.bottom && testCell.walls.bottom.z>character.z) secondaryCandidates[secondaryCandidates.length] = (testCell.walls.bottom)
							} catch (e:Error) {

								// This means we went outside scene limits and found a null cell. We return a false wall to simulate a collision

								xcell = (tx/gs)
								ycell = ((character.y+realRadius)/gs)
								if(xcell<0) xcell = -1
								if(ycell<0) ycell = -1
								
								ntx = gs*(int(xcell))
								nty = gs*(int(ycell))
								gh = scene.height
								primaryCandidates[primaryCandidates.length] = (new fWall(<wall x={ntx} y={nty} size={gs} height={gh} z={0} direction={"horizontal"} />,scene))
							}
							
						}
					}
        
				}
        
				// Make primary unique
				var temp:Array = new Array
				l = primaryCandidates.length
				for(j=0;j<l;j++) if(primaryCandidates[j]._visible && temp.indexOf(primaryCandidates[j])<0) temp[temp.length] = primaryCandidates[j]
				
				// Sort primary by distance to object
				l = temp.length
				primaryCandidates = []
				var cx:Number = character.x
				var cy:Number = character.y
				var cz:Number = character.z
				for(j=0;j<l;j++) {
					var cc:CollisionCandidate = objectPool.getInstanceOf(CollisionCandidate) as CollisionCandidate
					cc.element = temp[j]
					cc.distance = temp[j].distanceTo(cx,cy,cz)
					primaryCandidates[primaryCandidates.length] = cc
				}
				primaryCandidates.sortOn("distance",Array.NUMERIC)
				
				// Test primary fCollisions
				some = false
				for(j=0;j<l;j++) {
					
					testElement = primaryCandidates[j].element
					confirm = CollisionSolver.testPrimaryCollision(character,testElement,dx,dy,dz)
					objectPool.returnInstance(primaryCandidates[j])
		  	  if(confirm!=null) {
		  	  	
		  	  	if(testElement.solid) {
		  	  		some = true
							if(confirm.z>=0) {
								character.z = confirm.z
 								character.top = character.z+character.height		  	  		
 							}
	 						if(confirm.x>=0) character.x = confirm.x
	 						if(confirm.y>=0) character.y = confirm.y

	 						character.dispatchEvent(new fCollideEvent(fCharacter.COLLIDE,testElement))
	 					} else {
	 						character.dispatchEvent(new fWalkoverEvent(fCharacter.WALKOVER,testElement))
	 					}
	 					
		 			}
					
				}
				
				// If no primary fCollisions were confirmed, test secondary
				if(!some) {
        
					// Make secondary unique
					temp = new Array
					l = secondaryCandidates.length
					for(j=0;j<l;j++) if(secondaryCandidates[j]._visible && temp.indexOf(secondaryCandidates[j])<0) temp[temp.length] = secondaryCandidates[j]
					secondaryCandidates = temp
					l = secondaryCandidates.length
        
					// Test secondary fCollisions
					for(j=0;j<l;j++) {
						
						testElement = secondaryCandidates[j]
						confirm = CollisionSolver.testSecondaryCollision(character,testElement,dx,dy,dz)
		  		  if(confirm!=null) {
		  		  	
		  	  		if(testElement.solid) {
		  	  			some = true
								if(confirm.z>=0) {
									character.z = confirm.z
 									character.top = character.z+character.height		  	  		
 								}
	 							if(confirm.x>=0) character.x = confirm.x
	 							if(confirm.y>=0) character.y = confirm.y
	 							character.dispatchEvent(new fCollideEvent(fCharacter.COLLIDE,testElement))
	 						} else {
	 							character.dispatchEvent(new fWalkoverEvent(fCharacter.WALKOVER,testElement))
	 						}
		 				}
						
					}
					
				}
			
			}
		
			/** 
			* This methods tests a point's collision against an element in the scene
			* @return A boolean result
			*/
			public static function testPointCollision(x:Number,y:Number,z:Number,element:fRenderableElement):Boolean {
				
				if(element is fFloor) return CollisionSolver.testFloorPointCollision(x,y,z,element as fFloor)
				if(element is fWall) return CollisionSolver.testWallPointCollision(x,y,z,element as fWall)
				if(element is fObject) return CollisionSolver.testObjectPointCollision(x,y,z,element as fObject)
				return false
					
			}

			/** 
			* This methods tests a point's collision against a Floor
			* @return A boolean result
			*/
			public static function testFloorPointCollision(x:Number,y:Number,z:Number,floor:fFloor):Boolean {

				if(!floor.solid) return false
				
				// Inside polygon ?
				if(!floor.shapePolygon.isPointInside(x-floor.x,y-floor.y)) return false
				
				// Loop through holes and see if point is inside one
				var hl:int = floor.holes.length
				for(var h:int=0;h<hl;h++) {
				
					 	if(floor.holes[h].open) {
						 	var hole:fPlaneBounds = floor.holes[h].bounds
						 	if(hole.x<=x && (hole.x+hole.width)>=x && hole.y<=y && (hole.y+hole.height)>=y) {
							 		return false
						 	}
			 	  	}
				}				

				return true

			}

			/** 
			* This methods tests a point's collision against a wall
			* @return A boolean result
			*/
			public static function testWallPointCollision(x:Number,y:Number,z:Number,wall:fWall):Boolean {

				if(!wall.solid) return false
				
				if(wall.vertical) {
					
					// Inside polygon ?
					if(!wall.shapePolygon.isPointInside(y-wall.y0,z-wall.z)) return false

					// Loop through holes and see if point is inside one	
					var wl:int = wall.holes.length
					for(var h:int=0;h<wl;h++) {
					
						 	if(wall.holes[h].open) {
							 	var hole:fPlaneBounds = wall.holes[h].bounds
							 	if(hole.z<=z && hole.top>=z && hole.y0<=y && hole.y1>=y) {
							 		return false
							 	}
			 				}	  	
					}				
			  } else {
					
					// Inside polygon ?
					if(!wall.shapePolygon.isPointInside(x-wall.x0,z-wall.z)) return false

					// Loop through holes and see if point is inside one
					wl = wall.holes.length
					for(h=0;h<wl;h++) {
					
						 	if(wall.holes[h].open) {
							 	hole = wall.holes[h].bounds
							 	if(hole.z<=z && hole.top>=z && hole.x0<=x && hole.x1>=x) {
							 		return false
							 	}
			 				}	  	
					}				
			  }
				
				return true

			}

			/** 
			* This methods tests a point's collision against an object
			* @return A boolean result
			*/
			public static function testObjectPointCollision(x:Number,y:Number,z:Number,obj:fObject):Boolean {

					if(!obj.solid) false
					
					// Above or below the object
					if(z<obj.z || z>=obj.top) return false
					
					// Must check radius
					return (mathUtils.distance(obj.x,obj.y,x,y)<obj.radius)

			}


			/** 
			* This methods tests a character's primary Collisions at its current position against another element in the scene
			* @return A collision object if any collision was found, null otherwise
			*/
			public static function testPrimaryCollision(character:fCharacter,element:fRenderableElement,dx:Number,dy:Number,dz:Number):Collision {
				
				if(element is fFloor) return CollisionSolver.testFloorPrimaryCollision(character,element as fFloor,dx,dy,dz)
				if(element is fWall) return CollisionSolver.testWallPrimaryCollision(character,element as fWall,dx,dy,dz)
				if(element is fObject) return CollisionSolver.testObjectPrimaryCollision(character,element as fObject,dx,dy,dz)
				return null
				
			}

			/** 
			* This methods tests a character's secondary Collisions at its current position against another element in the scene
			* @return A collision object if any collision was found, null otherwise
			*/
			public static function testSecondaryCollision(character:fCharacter,element:fRenderableElement,dx:Number,dy:Number,dz:Number):Collision {
				
				if(element is fFloor) return CollisionSolver.testFloorSecondaryCollision(character,element as fFloor,dx,dy,dz)
				if(element is fWall) return CollisionSolver.testWallSecondaryCollision(character,element as fWall,dx,dy,dz)
				if(element is fObject) return CollisionSolver.testObjectSecondaryCollision(character,element as fObject,dx,dy,dz)
				return null
					
			}


			/* 
			* Test primary fCollision from an object into a floor
			* @return A collision object if any collision was found, null otherwise
			*/
			private static function testFloorPrimaryCollision(obj:fObject,floor:fFloor,dx:Number,dy:Number,dz:Number):Collision {
				
				if(obj.z>=floor.z || obj.top<=floor.z) return null
				
				// Test 4 edges
				if(obj.x>(floor.x+floor.width)) {
					var ny0:Number = floor.y-obj.y
					var ny1:Number = floor.y+floor.depth-obj.y
					var col:fPoint3d = obj.collisionModel.testSegment(floor.x+floor.width-obj.x,ny0,0,floor.x+floor.width-obj.x,ny1,0)
					if(!col) return null
				}

				if(obj.x<floor.x) {
					ny0 = floor.y-obj.y
					ny1 = floor.y+floor.depth-obj.y
					col = obj.collisionModel.testSegment(floor.x-obj.x,ny0,0,floor.x-obj.x,ny1,0)
					if(!col) return null
				}

				if(obj.y>(floor.y+floor.depth)) {
					var nx0:Number = floor.x-obj.x
					var nx1:Number = floor.x+floor.width-obj.x
					col = obj.collisionModel.testSegment(nx0,floor.y+floor.depth-obj.y,0,nx1,floor.y+floor.depth-obj.y,0)
					if(!col) return null
				}

				if(obj.y<floor.y) {
					nx0 = floor.x-obj.x
					nx1 = floor.x+floor.width-obj.x
					col = obj.collisionModel.testSegment(nx0,floor.y-obj.y,0,nx1,floor.y-obj.y,0)
					if(!col) return null
				}

				var x:Number, y:Number
				x = obj.x
				y = obj.y

				// Loop through holes and see if point is inside one
				var fl:int = floor.holes.length
				for(var h:int=0;h<fl;h++) {
				
					 	if(floor.holes[h].open) {
						 	var hole:fPlaneBounds = floor.holes[h].bounds
						 	if(hole.width>=(2*obj.radius) && hole.height>=(2*obj.radius) && hole.x<=x && (hole.x+hole.width)>=x && hole.y<=y && (hole.y+hole.height)>=y) {
							 		return null
						 	}
			 			}  	
				}				
				
				// Return fCollision point
				if(dz>0) return new Collision(-1,-1,floor.z-obj.height)
				else return new Collision(-1,-1,floor.z)
				
			}

			/* 
			* Test primary fCollision from an object into a wall
			* @return A collision object if any collision was found, null otherwise
			*/
			private static function testWallPrimaryCollision(obj:fObject,wall:fWall,dx:Number,dy:Number,dz:Number):Collision {
				
				if(obj.z>=wall.top || obj.top<=wall.z) return null
				
				var x:Number, y:Number, z:Number, z2:Number
				var any:Boolean
				var radius:Number = obj.radius

				if(wall.vertical) {
					
					var ny0:Number = wall.y0-obj.y
					var ny1:Number = wall.y1-obj.y
					var col:fPoint3d = obj.collisionModel.testSegment(wall.x-obj.x,ny0,0,wall.x-obj.x,ny1,0)
					if(!col) return null
					
					y = obj.y
					z = obj.z
					z2 = obj.top

					// Loop through holes and see if bottom point is inside one
					any = false
					var wl:int = wall.holes.length
					for(var h:int=0;!any && h<wl;h++) {
					
						 	if(wall.holes[h].open) {
						 		var hole:fPlaneBounds = wall.holes[h].bounds
						 		if(hole.width>=(2*obj.radius) && hole.height>=obj.height) {
						 			if(hole.z<=z && hole.top>=z && hole.y0<=y && hole.y1>=y && hole.z<=z2 && hole.top>=z2) any = true
						 		} 
						 	}
			 		  	
					}
					
					// There was a fCollision 
					if(!any) {
						
						if((obj.y+obj.radius)>wall.y1) {
							if(obj.x<wall.x) return new Collision(wall.x-radius,obj.y+2,-1)
							else return new Collision(wall.x+radius,obj.y+2,-1)
						} else if((obj.y-obj.radius)<wall.y0) {
							if(obj.x<wall.x) return new Collision(wall.x-radius,obj.y-2,-1)
							else return new Collision(wall.x+radius,obj.y-2,-1)
						} else {
							if(obj.x<wall.x) return new Collision(wall.x-radius,-1,-1)
							else return new Collision(wall.x+radius,-1,-1)
						}
						
					}
	
					return null

			  } else {
			  	
					var nx0:Number = wall.x0-obj.x
					var nx1:Number = wall.x1-obj.x
					col = obj.collisionModel.testSegment(nx0,wall.y-obj.y,0,nx1,wall.y-obj.y,0)
					if(!col) return null

					x = obj.x
					z = obj.z
					z2 = obj.top

					// Loop through holes and see if bottom point is inside one
					any = false
					wl = wall.holes.length
					for(h=0;!any && h<wl;h++) {
					
						 	if(wall.holes[h].open) {
						 		hole = wall.holes[h].bounds
						 		if(hole.width>=(2*obj.radius) && hole.height>=obj.height) {
						 			 if(hole.z<=z && hole.top>=z && hole.z<=z2 && hole.top>=z2 && hole.x0<=x && hole.x1>=x) any = true
						 		}
						 	}
			 		  	
					}
					
					// There was a fCollision 
					if(!any) {
						
						if((obj.x+obj.radius)>wall.x1) {
							if(obj.y<wall.y) return new Collision(obj.x+2,wall.y-radius,-1)
							else return new Collision(obj.x+2,wall.y+radius,-1)
						} else if((obj.x-obj.radius)<wall.x0) {
							if(obj.y<wall.y) return new Collision(obj.x-2,wall.y-radius,-1)
							else return new Collision(obj.x-2,wall.y+radius,-1)
						} else {
							if(obj.y<wall.y) return new Collision(-1,wall.y-radius,-1)
							else return new Collision(-1,wall.y+radius,-1)
						}
						
					}

					return null

			  }

			}


			/* 
			* Test primary fCollision from an object into another object
			* @return A collision object if any collision was found, null otherwise
			*/
			private static function testObjectPrimaryCollision(obj:fObject,other:fObject,dx:Number,dy:Number,dz:Number):Collision {
				
				// Simple case. This works now, but it wouldn't with sphere collision models, for example
				if(other.top<=obj.z || other.z>=obj.top) return null

				// The generic implementation of other test works with any collisionModel
				// But as cilinders allow a more efficient detection, I've programmed specific
				// algorythms for these cases
				if(obj.collisionModel is fCilinderCollisionModel) {
				
					if(other.collisionModel is fCilinderCollisionModel) {
						
						// Both elements use cilinder model
						var distance:Number = mathUtils.distance(obj.x,obj.y,other.x,other.y)
						var impulse:Number = (other.radius+obj.radius)
						if(distance<impulse) {
						
						  impulse*=1.01
						  var angle:Number = mathUtils.getAngle(other.x,other.y,obj.x,obj.y,distance)*Math.PI/180
							return new Collision(other.x+impulse*Math.cos(angle),other.y+impulse*Math.sin(angle),-1)
							
						} else return null
				
			  	} else {
			  		
			  	  // Only the moving object uses cilinder model. Note that collisionModels use local coordinates. Therefore
			  	  // any point that is to be tested needs to be translated to the model's coordinate origin.
						angle = mathUtils.getAngle(other.x,other.y,obj.x,obj.y)*Math.PI/180
						var cos:Number = -obj.radius*Math.cos(angle)
						var sin:Number = -obj.radius*Math.sin(angle)
						var nx:Number = obj.x+cos
						var ny:Number = obj.y+sin
						
						if(other.collisionModel.testPoint(nx-other.x,ny-other.y,0)) {
							
							var oppositex:Number = obj.x-cos-other.x
							var oppositey:Number = obj.y-sin-other.y
							var nx2:Number = nx-other.x
							var ny2:Number = ny-other.y
							
							// Find out collision point.
							var points:Array = other.collisionModel.getTopPolygon()
							var intersect:Point = null
							var pl:int = points.length
							for(var i:int=0;intersect==null && i<pl;i++) {
								
								if(i==0) intersect = mathUtils.segmentsIntersect(nx2,ny2,oppositex,oppositey,points[0].x,points[0].y,points[points.length-1].x,points[points.length-1].y)
								else intersect = mathUtils.segmentsIntersect(nx2,ny2,oppositex,oppositey,points[i].x,points[i].y,points[i-1].x,points[i-1].y)
								
							}
							

							// This shouldn't happen
							if(intersect==null) return null
							
							// Bounce
							nx = obj.x-(nx2-intersect.x)*1.01
							ny = obj.y-(ny2-intersect.y)*1.01
							
							return new Collision(nx,ny,-1)
							
						} else return null
			  		
			  		
			  	}
			  	
			  } else {
			  	
			  	// Use generic collision test. Pending implementation
			  	return null
			  	
			  }
			  				
			}


			/* 
			* Test secondary fCollision from an object into a floor
			* @return A collision object if any collision was found, null otherwise
			*/
			private static function testFloorSecondaryCollision(obj:fObject,floor:fFloor,dx:Number,dy:Number,dz:Number):Collision {
				return null
			}


			/* 
			* Test secondary fCollision from an object into a wall
			* @return A collision object if any collision was found, null otherwise
			*/
			private static function testWallSecondaryCollision(obj:fObject,wall:fWall,dx:Number,dy:Number,dz:Number):Collision {
				
				var x:Number, y:Number, z:Number
				var any:Boolean, ret:Collision

				var radius:Number = obj.radius
				var oheight:Number = obj.height

				if(wall.vertical) {
					
					var ny0:Number = wall.y0-obj.y
					var ny1:Number = wall.y1-obj.y
					var col:fPoint3d = obj.collisionModel.testSegment(wall.x-obj.x,ny0,0,wall.x-obj.x,ny1,0)
					if(!col) return null
					
					y = obj.y
					x = obj.x

					// Loop through holes find which one are we inside of
					any = false
					var wl:int = wall.holes.length
					for(var h:int=0;!any && h<wl;h++) {
					
						 	if(wall.holes[h].open) {
							 	var hole:fPlaneBounds = wall.holes[h].bounds
							 	if(hole.width>=(2*obj.radius) && hole.height>=obj.height && hole.z<=obj.z && hole.top>=obj.top && hole.y0<=y && hole.y1>=y) {
							 		any = true
							 	} 
							}
			 		  	
					}
					
					// We are inside one
					if(any) {
						
						ret = new Collision(-1,-1,-1)
						if(dy<0 && ((y-radius)<hole.y0)) ret.y = hole.y0+radius
						if(dy>0 && ((y+radius)>hole.y1)) ret.y = hole.y1-radius
						if(dz<0 && obj.z<=hole.z) ret.z = hole.z
						if(dz>0 && obj.top>=hole.top) ret.z = hole.top-oheight
						return ret
						
					} else {
						if(obj.y<wall.y0) {
							if((obj.x+obj.radius)>wall.x) return new Collision(obj.x+2,wall.y0-radius,-1)
							else if((obj.x-obj.radius)<wall.x) return new Collision(obj.x-2,wall.y0-radius,-1)
							else return new Collision(-1,wall.y0-radius,-1)
						} else if(obj.y1>wall.y1) {
							if((obj.x+obj.radius)>wall.x) return new Collision(obj.x+2,wall.y1+radius,-1)
							else if((obj.x-obj.radius)<wall.x) return new Collision(obj.x-2,wall.y1+radius,-1)
							else return new Collision(-1,wall.y1+radius,-1)
						} else return null
					}

			  } else {
			  	
					// Are we inside the wall ? Then we must be in a hole
					var nx0:Number = wall.x0-obj.x
					var nx1:Number = wall.x1-obj.x
					col = obj.collisionModel.testSegment(nx0,wall.y-obj.y,0,nx1,wall.y-obj.y,0)
					if(!col) return null
					
					y = obj.y
					x = obj.x
					z = (obj.z+obj.top)/2

					// Loop through holes and find which one are we inside of
					any = false
					wl = wall.holes.length
					for(h=0;!any && h<wl;h++) {
					
						 	if(wall.holes[h].open) {
							 	hole = wall.holes[h].bounds
							 	if(hole.width>=(2*obj.radius) && hole.height>=obj.height && hole.z<=z && hole.top>=z && hole.x0<=x && hole.x1>=x) {
							 		any = true
							 	}
							}
			 		  	
					}
					
					// We are inside one
					if(any) {
						
						ret = new Collision(-1,-1,-1)
						if(dx<0 && ((x-radius)<hole.x0)) ret.x = hole.x0+radius
						if(dx>0 && ((x+radius)>hole.x1)) ret.x = hole.x1-radius
						if(dz<0 && obj.z<=hole.z) ret.z = hole.z
						if(dz>0 && obj.top>=hole.top) ret.z = hole.top-oheight
						return ret
						
					} else {
						if(obj.x<wall.x0) {
							if((obj.y+obj.radius)>wall.y) return new Collision(wall.x0-radius,obj.y+2,-1)
							else if((obj.y-obj.radius)<wall.y) return new Collision(wall.x0-radius,obj.y-2,-1)
							else return new Collision(wall.x0-radius,-1,-1)
						} else if(obj.x1>wall.x1) {
							if((obj.y+obj.radius)>wall.y) return new Collision(wall.x1+radius,obj.y+2,-1)
							else if((obj.y-obj.radius)<wall.y) return new Collision(wall.x1+radius,obj.y-2,-1)
							else return new Collision(wall.x1+radius,-1,-1)
						} else return null
					}

			  }
				
			}


			/* 
			* Test secondary fCollision from an object into another object
			* @return A collision object if any collision was found, null otherwise
			*/
			private static function testObjectSecondaryCollision(obj:fObject,other:fObject,dx:Number,dy:Number,dz:Number):Collision {
				
				if(obj.z>other.top || obj.top<other.z) return null
				
				// The generic implementation of other test works with any collisionModel
				// But as cilinders allow a more efficient detection, I've programmed specific
				// algorythms for these cases
				if(obj.collisionModel is fCilinderCollisionModel) {
				
					if(other.collisionModel is fCilinderCollisionModel) {
					
						// Both elements use cilinder model
						if(mathUtils.distance(obj.x,obj.y,other.x,other.y)>=(other.radius+obj.radius)) return null
						
			  	} else {
			  		
			  	  // Only the moving object uses cilinder model. Note that collisionModels use local coordinates. Therefore
			  	  // any point that is to be tested needs to be translated to the model's coordinate origin.
						var angle:Number = mathUtils.getAngle(other.x,other.y,obj.x,obj.y)*Math.PI/180
						var cos:Number = -obj.radius*Math.cos(angle)
						var sin:Number = -obj.radius*Math.sin(angle)
						var nx:Number = obj.x+cos
						var ny:Number = obj.y+sin
						
						if(!other.collisionModel.testPoint(nx-other.x,ny-other.y,0)) return null
			  		
			  	}
			  	
			  } else {
			  	
			  	// Use generic collision test. Pending implementation
			  	
			  	return null
			  	
			  }

				if(obj.z<other.top && obj.top>other.z && (obj.z-dz)>other.top) return new Collision(-1,-1,other.top)
				if(obj.top>other.z && obj.z<other.z && (obj.top-dz)<other.z) return new Collision(-1,-1,other.z)

				return null

				
			}

		}

}
