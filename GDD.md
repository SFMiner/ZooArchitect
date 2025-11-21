# Game Design Document: Zoo Architect - Spatial Survival

**Genre:** Educational Puzzle / Simulation

**Target Audience:** Grades 3–6 (Ages 8–12)

**Platform:** Web / Tablet

**Core Concept:** _Tetris_ meets _Geometry_. Players must design animal enclosures based on specific Area and Perimeter constraints, but with a twist: **every cage you build remains on the map.** As the zoo fills up, players are forced to construct complex, irregular shapes to fit new animals into the remaining gaps.

## 1. The Hook: "The Ever-Crowding Map"

In traditional math games, the board resets after every question. In **Zoo Architect**, the board persists.

If a player places a massive, inefficient square enclosure for the Lions in the center of the map during Turn 1, they may find themselves unable to fit the Elephants in Turn 5. This forces players to plan ahead and visualize how complex shapes (L-shapes, U-shapes) can fit together to maximize space efficiency.

## 2. Gameplay Loop

### Phase 1: The Contract (The Prompt)

The Zoo Director appears with a request card.

- **Visual:** "The **Arctic Wolves** are arriving! They need plenty of space to run, but we are on a budget for fencing."
	
- **Math Constraint:** * **Area:** Must be exactly **24 square units**.
	
	- **Perimeter:** Must be **22 units or less**.
		
- **The Twist:** Sometimes the prompt requires _odd_ shapes. "The **Meerkats** like tight corners. Build a habitat with an Area of 12 and at least 6 corners."
	

### Phase 2: Construction (The Mechanic)

The player views the top-down grid (e.g., 30x30 tiles).

- **Existing State:** The Lions, Zebras, and Food Court built in previous turns are visible as solid obstacles.
	
- **The Tool:** The player uses a "Fence Tool" to paint tiles on the grid.
	
- **Real-time Feedback:** As the player drags the mouse/finger, a holographic display shows the current Area and Perimeter of the shape they are drawing.
	
	- _Example:_ "Current: Area 18, Perimeter 18."
		
- **Validation:** The player clicks "Build."
	
	- **Success:** The fence solidifies, the animals populate the cage, and the player earns "Zoo Coins."
		
	- **Fail:** If the math is wrong, the fence collapses (visual feedback), and the Director gives a hint.
		

### Phase 3: Deconstruction (The Late Game)

As the game progresses to Levels 5+, the grid becomes crowded. Large rectangular spaces are gone.

- **The Challenge:** The player needs an Area of 20 for the Penguins.
	
- **The Solution:** The only available space is an awkward gap between the Tigers and the Exit. The player must **construct** an irregular shape (rectilinear polygon) that snakes around the obstacles.
	
- **Educational Moment:** This forces the student to mentally **deconstruct** the available space into smaller rectangles ("I have a 2x4 space here and a 3x4 space there... that equals 20 total!") to see if the animal will fit.
	

## 3. Key Features & Mechanics

### The "Drafting" Mode

Since mistakes are costly in a persistent world, players can toggle "Draft Mode." They can draw a shape, see its stats, and then "Erase" or "Commit."

- _Adventure Element:_ This is framed as "Blueprints." You don't pour concrete until the math is verified.
    

### Obstacles & Terrain

The map isn't just empty space at the start.

- **River:** Cuts through the map. Cages cannot be built over water.
	
- **Ancient Trees:** Cannot be removed. Players must build _around_ them.
	
- **Effect:** This naturally teaches the calculation of area for shapes with "holes" or missing corners.
	

### The "Renovation" Power-Up

Players earn currency for perfect math. They can spend this currency to:

- **Move:** Shift an existing cage 1 unit in any direction.
	
- **Demolish:** Remove a cage to rebuild it more efficiently (but you must re-solve the math problem for that animal immediately).
	

## 4. Educational Objectives (Common Core Alignment)

- **3.MD.C.5 / 3.MD.C.6:** Recognize area as an attribute of plane figures and measure by counting unit squares.
	
- **3.MD.C.7.D:** Recognize area as additive. Find areas of rectilinear figures by decomposing them into non-overlapping rectangles.
	
- **3.MD.D.8:** Solve real-world problems involving perimeters of polygons, including finding the perimeter given the side lengths.
	

## 5. Visual Style & Tone

- **Style:** "Pixel Art Tycoon." Vibrant colors, cute animated animals that wander inside the bounds of the shapes the player draws.
	
- **Feedback:** * **Positive:** When a cage is built, confetti pops, and visitors flock to that specific area of the grid.
	
	- **Negative:** If the Area is too small, the animal looks sad/cramped. If the Perimeter is too low/high, the fence flashes red.
		

## 6. Level Progression

- **Level 1:** The Empty Lot. Simple rectangles. High tolerance for waste.
	
- **Level 3:** The River. The map is bisected by water. Shapes must be built on one side or the other.
	
- **Level 7:** The Crowded Saturday. The map is 80% full. The player must fit 3 more animals into the "nooks and crannies" left between existing cages. This is the ultimate test of **composite shape construction**.

## 7. Later Features: Profits and Accolades

- Well planned zoos (good animal cages, and enough space between them for patrons to wander freely among them, will result in occasional zoo awards form various zoological and conservation societies, and draw larger crowds., Larger crowds will bring in money, and allowe consession stands concession standas are the lowest priority)