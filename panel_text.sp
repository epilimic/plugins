#pragma semicolon 1

#include <sourcemod>
#include <readyup>
#define PLUGIN_VERSION "1 point 0"
#define MAX_TEXT_LENGTH 65

public Plugin:myinfo =
{
	name = "Add Text To Readyup Panel",
	author = "epilimic",
	description = "Displays custom text in the readyup panel",
	version = PLUGIN_VERSION,
	url = "http://buttsecs.org"
};

new String:panelText[10][MAX_TEXT_LENGTH];
new stringCount = 0;

public OnPluginStart()
{
	RegServerCmd("sm_addreadystring", AddReadyString_Cmd, "Sets the string to add to the ready-up panel");
	RegServerCmd("sm_resetstringcount", ResetStringCount_Cmd, "Resets the string count");
	HookEvent("round_start", RoundStart_Event, EventHookMode_PostNoCopy);
}

public Action:AddReadyString_Cmd(args)
{
	if (stringCount < 10)
	{
		GetCmdArg(1, panelText[stringCount], MAX_TEXT_LENGTH);
		++stringCount;
	}
}

public Action:ResetStringCount_Cmd(args)
{
	stringCount = 0;
}

public RoundStart_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	CreateTimer(6.0, panelTimer);
}

public Action:panelTimer(Handle:timer)
{
	for (new i = 0; i < stringCount; i++)
	{
		AddStringToReadyFooter(panelText[i]);
	}
}
