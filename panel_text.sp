#pragma semicolon 1

#include <sourcemod>
#include <readyup>
#define PLUGIN_VERSION "1 point 0"

public Plugin:myinfo =
{
	name = "Add Text To Readyup Panel",
	author = "epilimic",
	description = "Displays custom text in the readyup panel",
	version = PLUGIN_VERSION,
	url = "http://buttsecs.org"
};

new String:panelText[65];

public OnPluginStart()
{
	RegServerCmd("sm_addreadystring", AddReadyString_Cmd, "Sets the string to add to the ready-up panel");
	HookEvent("round_start", RoundStart_Event, EventHookMode_PostNoCopy);
}

public Action:AddReadyString_Cmd(args)
{
	GetCmdArg(1, panelText, sizeof(panelText));
}

public RoundStart_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
	CreateTimer(6.0, panelTimer);
}

public Action:panelTimer(Handle:timer)
{
	AddStringToReadyFooter(panelText);
}
