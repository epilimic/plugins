#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin:myinfo = {
	name = "Car Alarm Announce!",
	author = "epilimic",
	description = "Announces what numbskull shot the flippin car!",
	version = "1",
	url = "nope.avi"
}

//new bool:bActivated = false;
new Handle:hFirstRoundCars;


public OnPluginStart() { 
    HookEvent("round_start", RoundStart); 
} 

public OnEntityCreated(entity, const String:classname[]) {
    if (StrEqual(classname, "prop_car_alarm")) {
		SDKHook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
		SDKHook(entity, SDKHook_StartTouch, StartTouch);
	}
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3]) {
	//PrintToChatAll("%d shot the car alarm!", attacker);
}

public Action:StartTouch(entity, other) {
	//PrintToChatAll("%d touched the alarm car and set it off!", other);
}

public Action:RoundStart( Handle:event, const String:name[], bool:dontBroadcast ) {
    CreateTimer(0.1, RoundStartDelay);
}

public Action:RoundStartDelay( Handle:timer ) {
    new iEntity = -1;
    decl String:sTargetName[128];
    while ( (iEntity = FindEntityByClassname(iEntity, "logic_relay")) != -1 ) {
        GetEntityName(iEntity, sTargetName, sizeof(sTargetName));
       
        if ( StrContains(sTargetName, "relay_caralarm_on") == -1 ) {
            continue;
        }
        
        HookSingleEntityOutput(iEntity, "OnTrigger", CarAlarmLogicRelayTriggered);
	LogMessage("single entity output hooked");
    }
}

public CarAlarmLogicRelayTriggered( const String:output[], caller, activator, Float:delay ) {
    decl String:sTargetName[128];
    GetEntityName(caller, sTargetName, sizeof(sTargetName));
    
    if (IsValidEntity(activator)) {
        decl String:sClassName[128];
        GetEntityClassname(activator, sClassName, sizeof(sClassName));
        // If a car is turned off because of a tank punch or because it was
        // triggered the activator is the car itself. When the cars get
        // randomised the activator is the player who entered the trigger area.
        if ( StrEqual(sClassName, "prop_car_alarm") ) {
			return;
        }
    }
        
    PushArrayString(hFirstRoundCars, sTargetName);
}

bool:ExtractCarName( const String:sName[], String:sBuffer[], iSize ) {
    return (SplitString(sName, "-", sBuffer, iSize) != -1);
}

TriggerCarRelay( const String:sName[], bool:bOn ) {
    decl String:sCarName[128];
    new iEntity;
    
    if ( !ExtractCarName(sName, sCarName, sizeof(sCarName)) ) {
        return;
    }
    
    StrCat(sCarName, sizeof(sCarName), "-relay_caralarm_");
    
    if ( bOn ) {
        StrCat(sCarName, sizeof(sCarName), "on");
    }
    else {
        StrCat(sCarName, sizeof(sCarName), "off");
    }
    
    iEntity = FindEntityByName(sCarName, "logic_relay");
    
    if ( iEntity != -1 ) {
        AcceptEntityInput(iEntity, "Trigger");
    }
}

FindEntityByName( const String:sName[], const String:sClassName[] ) {
    new iEntity = -1;
    decl String:sEntName[128];
    
    while ( (iEntity = FindEntityByClassname(iEntity, sClassName)) != -1 ) {
        if ( !IsValidEntity(iEntity) ) {
            continue;
        }
        
        GetEntityName(iEntity, sEntName, sizeof(sEntName));
        
        if ( StrEqual(sEntName, sName) ) {
            return iEntity;
        }
    }
    
    return -1;
}

GetEntityName( iEntity, String:sTargetName[], iSize ) {
    GetEntPropString(iEntity, Prop_Data, "m_iName", sTargetName, iSize);
}