# Artificial Life Simulator in Monkey C

This is an implementation of a simple "artificial life" simulation based on a project I worked on in college. The basic idea is a to use a priority queue as a data structure to run through discrete events representing movements made by an artificial lifeform called a Frob. 

Frobs can move left, right, up, or down on a two dimensional grid. They can eat grass and reproduce. Frobs have "genes" that give them a preference for moving in a given direction based on what is there. When trying to move into a rock they lose mass, which serves as their "health". They also lose mass if they move into a square occupied by another frob or if they reproduce. Each birthed frob has a small chance for each genetic preference to mutate, giving them potentially different behavior than their parent. When a frob moves to a square occupied by a grass, they will eat the grass and gain its mass (note that the grass can also reproduce/grow). Whenever a frob moves, they lose mass to simulate energy expenditure. When a frob's mass goes to zero they die.

Part of the fun of writing this was dealing with the major limitations of the platform. Garmin watch apps are not intended to have long run times or perform complex calculations. Even initializing the grid and initial state results in hitting the bytecode watchdog limit. To work around this, initialization has to be performed in chunks, so as to momentarily return control flow back to the OS. Further, the original implementation had the construct of "days" where multiple events would be simulated before drawing updated state. Due to the watchdog limitation, only one event is simulated and drawn at a time before releasing control flow. 

Further, in order to drive the simulation, this implementation relies on the builtin Timer API to call a callback to simulate the next event; using a loop or recursion to iterate proved untenable, again, due to the need to limit the amount of bytecode evaluated in each iteration. This limitation also restricts the complexity of drawing the visualization of state. I originally had some logic that changed the size of each colored square representing a grass or a Frob to scale based on their mass, but this led to hard to predict behavior as the number of grasses or Frobs changes dynamically during a run of the simulation. To guarantee staying below the limit required making the world grid too small fo rmy tastes.

Some nice to have improvements would be to replace the primitive graphics with bitmaps (which have some hardware acceleration behind the scenes on some devices). However finding a good art style is, to me, much harder than writing the code itself! A better UI for entering the seed would be welcome. Another future enhancement would be to expose the various simulation parameters in the menu. A major challenge to supporting all these enhancements is the varying screen resolution, screen form factor (square/circle), button layouts, SOC performance, and watchdog limits among Garmin devices. It's kind of a nightmare to have to manually validate all these devices.

Enjoy!

---

### Note:

Grass is green.

Frobs are blue.

Each tick represents a single event.

### Screenshots:

![image](https://github.com/user-attachments/assets/70d944b0-d2a6-4714-b7d8-845f3775cc42)
![image](https://github.com/user-attachments/assets/860b69da-7f70-43c9-9f2a-bc5fd8029389)
