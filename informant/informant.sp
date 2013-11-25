#include <sourcemod>

new Handle:db = INVALID_HANDLE;

//This started as a plugin by darthninja, from darthninja.com. Modded for my needs.
public Plugin:myinfo = 
{
	name = "shh, it's a secret!",
	author = "epilimic",
	description = "produce magic",
	version = "1.3.3.7",
	url = "nope.avi"
}

public OnPluginStart()
{
	new Handle:serverKeyValFile = CreateKeyValues("informant", "", "");
	if (!FileToKeyValues(serverKeyValFile, "addons/sourcemod/configs/informant.cfg"))
	{
		LogMessage("[ERROR ERROR OH NO WORLD IS GOING TO END!!!] Could not load db file: \"%s\", logging to /sourcemod/logs/informant.log instead.", "addons/sourcemod/configs/informant.cfg");
	}
	else if (FileToKeyValues(serverKeyValFile, "addons/sourcemod/configs/informant.cfg"))
	{
		LogMessage("Informant.cfg file found.");
		PrintToServer("Informant.cfg file loaded.");
	}
	decl String:error[256];
	db = SQL_ConnectCustom(serverKeyValFile, error, 255, true);
	if (!db)
	{
		LogMessage("[ERROR ERROR OH NO WORLD IS GOING TO END!!!] Could not establish connection to server defined in \"%s\", logging to /sourcemod/logs/informant.log instead.", "addons/sourcemod/configs/informant.cfg");
	}
		else
	{
		LogMessage("Informant is good to go!");
		PrintToServer("Informant is good to go!");
	}
}

public OnClientAuthorized(client, const String:steamID[])
{
	if (IsFakeClient(client))
		return;
	
	new String:ip[64];
	new String:ServerName[256];
	decl String:ServerIp[16];
	decl String:name[256];
	decl String:theTime[30];
	FormatTime(theTime, sizeof(theTime), "%r %D", GetTime());
	GetConVarString(FindConVar("hostname"), ServerName, sizeof(ServerName));
	ReplaceString(ServerName, sizeof(ServerName), "'", "`");
	GetClientIP(client, ip, sizeof(ip));
	GetClientName(client, name, sizeof(name));
	new Handle:cvar_ip = FindConVar("ip");
	GetConVarString(cvar_ip, ServerIp, sizeof(ServerIp));
	CloseHandle(cvar_ip);

	if (db == INVALID_HANDLE)
	{
		//Log to file instead
		LogToFile("addons/sourcemod/logs/informant.log", "\nPlayer: %s\nSteamID: %s\nIP: %s\nTime: %s\n", name, steamID, ip, theTime);
		return;
	}
	
	SQL_EscapeString(db, name, name, sizeof(name));
	
	decl String:query[1024];
	
	setMysqlNames();
	Format(query, sizeof(query), "INSERT INTO `informant` (`SteamID`, `PlayerName`, `IPAddress`, `ConnectTime`, `ServerIP`, `ServerName`, `UnixTime`) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%i');", steamID, name, ip, theTime, ServerIp, ServerName, GetTime());
	SQL_TQuery(db, SQLErrorCheckCallback, query);
	//LogToFile("addons/sourcemod/logs/informant.log", "\nPlayer: %s\nSteamID: %s\nIP: %s\nTime: %s\n", name, steamID, ip, theTime);
	
}


public setMysqlNames() 
{
    new String:query[1024];
    Format(query, sizeof(query), "SET NAMES utf8;");
    SQL_TQuery(db, SQLErrorCheckCallback, query);
}

public SQLErrorCheckCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (!StrEqual("", error))
		LogError("SQL Error: %s", error);
}