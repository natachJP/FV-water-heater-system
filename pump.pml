mtype = { ON, OFF }

#define MIN_TEMPERATURE 25
#define MAX_TEMPERATURE 40

#define MIN_WATER 0
#define MAX_WATER 20

mtype water_heater_system           = OFF
mtype pump_system_status            = OFF
mtype heater_system_status          = OFF

int water_level                     = 0
int water_temperature               = MIN_TEMPERATURE

/** 
 * Atomic property 
 **/
#define o1   (water_heater_system == OFF)
#define o2   (water_heater_system == ON)

//--
// Water level
#define p1   (water_level >= 0)
#define p2   (water_level >= MIN_WATER)
#define p2_1 (water_level == MIN_WATER)
#define p3   (water_level <= MAX_WATER)
#define p3_1 (water_level == MAX_WATER)
#define p4   (pump_system_status == ON)
#define p5   (pump_system_status == OFF)

//--
// Water temperture
#define q1   (water_temperature >= MIN_TEMPERATURE)
#define q1_1 (water_temperature == MIN_TEMPERATURE)
#define q2   (water_temperature <= MAX_TEMPERATURE)
#define q2_1 (water_temperature == MAX_TEMPERATURE)
#define q3   (heater_system_status == OFF)
#define q4   (heater_system_status == ON)

/** 
 * LTL
 **/
//--
// water
ltl { []p1 }
ltl { [](p2 && p3) }
ltl { p4-><>p5 }

//--
// temperature
ltl { []<>q1 }
ltl { []<>q2 }

//--
// Extra
ltl { (q4 && p2_1) -> q3 }
ltl { o1 -> <>o2 }
ltl { <>[]o2 }

/**
 * Abstraction
 **/
active proctype pump() {
    if
    :: (ON == water_heater_system) ->
        do 
        :: (ON == pump_system_status) ->
            if
            :: (water_level >= MAX_WATER) -> pump_system_status = OFF
            :: (water_level <  MAX_WATER) -> water_level++
            fi;
        :: (OFF == pump_system_status) ->
            if
            :: (water_level <= MIN_WATER) -> pump_system_status = ON
            :: (water_level >  MIN_WATER) -> water_level--
            fi;
        od;
    fi;
}

active proctype heater() {
    if
    :: (ON == water_heater_system) ->
        do 
        :: (ON == heater_system_status) ->
            if
            :: (water_temperature >= MAX_TEMPERATURE) -> heater_system_status = OFF
            :: (water_temperature <  MAX_TEMPERATURE) -> water_temperature++
            fi;
        :: (OFF == heater_system_status) ->
            if
            :: (water_temperature <= MIN_TEMPERATURE) -> heater_system_status = ON
            :: (water_temperature > MIN_TEMPERATURE) -> water_temperature--
            fi;
        od;
    fi;
}

init {
    if 
    :: (OFF == water_heater_system) -> water_heater_system = ON
    fi;
}
