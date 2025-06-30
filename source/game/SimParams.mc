class SimParams {	
	static const MAX_SIMULATION_LENGTH = 25000;
    static const WORLD_HEIGHT = 20;
	static const WORLD_WIDTH = 20;

    static const INIT_FROBS = 20;
	static const INIT_GRASSES = 30;
	static const INIT_ROCKS = 20;

	static const FROB_FIXED_OVERHEAD = 2;
	static const FROB_GENESIS_MASS = 100;
	static const FROB_HIT_PENALTY = 10;
	static const FROB_MASS_TAX_MILLS = 100;
	
	static const GRASS_BIRTH_MASS = 30;
	static const GRASS_BIRTH_PERCENT = 40;
	static const GRASS_CROWD_LIMIT = 2;
	static const GRASS_FIXED_OVERHEAD = 0;
	static const GRASS_GENESIS_MASS = 10;
	static const GRASS_INITIAL_UPDATE_PERIOD = 10;
	static const GRASS_MASS_TAX_MILLS = -200;
	static const GRASS_MAX_UPDATE_PERIOD =  100;
	
	static const DNA_MUTATION_ODDS_PER_BYTE = 20;
	static const ROCK_BUMP_PENALTY = 30;
}
