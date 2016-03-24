#include <sourcemod>
#include <nativevotes>
//get here: https://github.com/powerlord/sourcemod-nativevotes
#include <confogl>
//get here: http://github.com/epilimic/confoglcompmod

#define L4D_TEAM_SPECTATE	1
#define MATCHMODES_PATH		"configs/matchmodes.txt"

new Handle:g_hMatchVote = INVALID_HANDLE;
new Handle:g_hResetMatchVote = INVALID_HANDLE;
new Handle:g_hModesKV = INVALID_HANDLE;
new Handle:g_hCvarPlayerLimit = INVALID_HANDLE;
new Handle:g_hCvarResetTime = INVALID_HANDLE;
new String:g_sCfg[32];

public Plugin:myinfo = 
{
	name = "Match Vote",
	author = "vintik, epilimic",
	description = "!match !rmatch, re-added legacy <!match configname> command",
	version = "1.3.1",
	url = "https://github.com/epilimic"
}

public OnPluginStart()
{
	decl String:sBuffer[128];
	GetGameFolderName(sBuffer, sizeof(sBuffer));
	if (!StrEqual(sBuffer, "left4dead2", false))
	{
		SetFailState("Plugin supports Left 4 dead 2 only!");
	}
	g_hModesKV = CreateKeyValues("MatchModes");
	BuildPath(Path_SM, sBuffer, sizeof(sBuffer), MATCHMODES_PATH);
	if (!FileToKeyValues(g_hModesKV, sBuffer))
	{
		SetFailState("Couldn't load matchmodes.txt!");
	}

	RegConsoleCmd("sm_match", MatchRequest);
	RegConsoleCmd("sm_rmatch", MatchReset);
	g_hCvarPlayerLimit = CreateConVar("sm_match_player_limit", "2", "Minimum # of players in game to start the vote", FCVAR_PLUGIN);
	g_hCvarResetTime = CreateConVar("sm_match_reset_time", "60.0", "Automatically reset match mode if the server is empty during this time. Negative values disable this feature.", FCVAR_PLUGIN);
}

public Action:MatchRequest(client, args)
{
	if (!client) return Plugin_Handled;
	if (args > 0)
	{
		//config specified
		decl String:sCfg[64], String:sBuffer[256];
		GetCmdArg(1, sCfg, sizeof(sCfg));
		BuildPath(Path_SM, sBuffer, sizeof(sBuffer), "../../cfg/cfgogl/%s", sCfg);
		if (DirExists(sBuffer))
		{
			FindConfigName(sCfg, sBuffer, sizeof(sBuffer));
			if (StartMatchVote(client, sBuffer))
			{
				strcopy(g_sCfg, sizeof(g_sCfg), sCfg);
				//caller is voting for
				FakeClientCommand(client, "Vote Yes");
			}
			return Plugin_Handled;
		}
	}
	//show main menu
	MatchModeMenu(client);
	return Plugin_Handled;
}

bool:FindConfigName(const String:cfg[], String:name[], maxlength)
{
	KvRewind(g_hModesKV);
	if (KvGotoFirstSubKey(g_hModesKV))
	{
		do
		{
			if (KvJumpToKey(g_hModesKV, cfg))
			{
				KvGetString(g_hModesKV, "name", name, maxlength);
				return true;
			}
		} while (KvGotoNextKey(g_hModesKV));
	}
	return false;
}

MatchModeMenu(client)
{
	new Handle:hMenu = CreateMenu(MatchModeMenuHandler);
	SetMenuTitle(hMenu, "Select match mode:");
	new String:sBuffer[64];
	KvRewind(g_hModesKV);
	if (KvGotoFirstSubKey(g_hModesKV))
	{
		do
		{
			KvGetSectionName(g_hModesKV, sBuffer, sizeof(sBuffer));
			AddMenuItem(hMenu, sBuffer, sBuffer);
		} while (KvGotoNextKey(g_hModesKV));
	}
	DisplayMenu(hMenu, client, 20);
}

public MatchModeMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		new String:sInfo[64], String:sBuffer[64];
		GetMenuItem(menu, param2, sInfo, sizeof(sInfo));
		KvRewind(g_hModesKV);
		if (KvJumpToKey(g_hModesKV, sInfo) && KvGotoFirstSubKey(g_hModesKV))
		{
			new Handle:hMenu = CreateMenu(ConfigsMenuHandler);
			Format(sBuffer, sizeof(sBuffer), "Select %s config:", sInfo);
			SetMenuTitle(hMenu, sBuffer);
			do
			{
				KvGetSectionName(g_hModesKV, sInfo, sizeof(sInfo));
				KvGetString(g_hModesKV, "name", sBuffer, sizeof(sBuffer));
				AddMenuItem(hMenu, sInfo, sBuffer);
			} while (KvGotoNextKey(g_hModesKV));
			DisplayMenu(hMenu, param1, 20);
		}
		else
		{
			PrintToChat(param1, "No configs for such mode were found.");
			MatchModeMenu(param1);
		}
	}
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public ConfigsMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		new String:sInfo[64], String:sBuffer[64];
		GetMenuItem(menu, param2, sInfo, sizeof(sInfo), _, sBuffer, sizeof(sBuffer));
		if (StartMatchVote(param1, sBuffer))
		{
			strcopy(g_sCfg, sizeof(g_sCfg), sInfo);
			//caller is voting for
			FakeClientCommand(param1, "Vote Yes");
		}
		else
		{
			MatchModeMenu(param1);
		}
	}
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	if (action == MenuAction_Cancel)
	{
		MatchModeMenu(param1);
	}
}

bool:StartMatchVote(client, const String:cfgname[])
{
	if (GetClientTeam(client) == L4D_TEAM_SPECTATE)
	{
		PrintToChat(client, "Match voting isn't allowed for spectators.");
		return false;
	}
	if (!NativeVotes_IsVoteInProgress())//disregard sm_vote_delay
	{
		new iNumPlayers;
		decl iPlayers[MaxClients];
		//list of non-spectators players
		for (new i=1; i<=MaxClients; i++)
		{
			if (!IsClientInGame(i) || IsFakeClient(i) || (GetClientTeam(i) == L4D_TEAM_SPECTATE))
			{
				continue;
			}
			iPlayers[iNumPlayers++] = i;
		}
		if (iNumPlayers < GetConVarInt(g_hCvarPlayerLimit))
		{
			PrintToChat(client, "Match vote cannot be started. Not enough players.");
			return false;
		}
		new String:sBuffer[64];
		g_hMatchVote = NativeVotes_Create(VoteActionHandler,  NativeVotesType_Custom_YesNo, MenuAction_Cancel | MenuAction_VoteEnd | MenuAction_End);
		if (LGO_IsMatchModeLoaded())
		{
			Format(sBuffer, sizeof(sBuffer), "Change config to '%s'?", cfgname);
		}
		else
		{
			Format(sBuffer, sizeof(sBuffer), "Load confogl '%s' config?", cfgname);
		}
		NativeVotes_SetTitle(g_hMatchVote, sBuffer);
		NativeVotes_SetInitiator(g_hMatchVote, client);
		NativeVotes_SetResultCallback(g_hMatchVote, VoteResultHandler);
		NativeVotes_Display(g_hMatchVote, iPlayers, iNumPlayers, 20);
		return true;
	}
	PrintToChat(client, "Match vote cannot be started now.");
	return false;
}

public VoteActionHandler(Handle:vote, MenuAction:action, param1, param2)
{
	switch (action)
	{
		case MenuAction_End:
		{
			g_hMatchVote = INVALID_HANDLE;
			g_hResetMatchVote = INVALID_HANDLE;
			NativeVotes_Close(vote);
		}
		case MenuAction_VoteCancel:
		{
			switch (param1)
			{
				case VoteCancel_Generic:
				{
					NativeVotes_DisplayFail(vote, NativeVotesFail_Generic);
				}
				
				case VoteCancel_NoVotes:
				{
					NativeVotes_DisplayFail(vote, NativeVotesFail_NotEnoughVotes);
				}
			}
		}
	}
}

public VoteResultHandler(Handle:vote, num_votes, num_clients, const client_indexes[], const client_votes[], num_items, const item_indexes[], const item_votes[])
{
	for (new i=0; i<num_items; i++)
	{
		if (item_indexes[i] == NATIVEVOTES_VOTE_YES)
		{
			if (item_votes[i] > (num_clients / 2))
			{
				if (vote == g_hMatchVote)
				{
					NativeVotes_DisplayPass(vote, "confogl is loading...");
					ServerCommand("sm_forcematch %s", g_sCfg);
					return;
				}
				else if (vote == g_hResetMatchVote)
				{
					NativeVotes_DisplayPass(vote, "confogl is unloading...");
					ServerCommand("sm_resetmatch");
					return;
				}
			}
		}
	}
	NativeVotes_DisplayFail(vote, NativeVotesFail_Loses);
}

public Action:MatchReset(client, args)
{
	if (!client) return Plugin_Handled;
	//voting for resetmatch
	StartResetMatchVote(client);
	return Plugin_Handled;
}

StartResetMatchVote(client)
{
	if (GetClientTeam(client) == L4D_TEAM_SPECTATE)
	{
		PrintToChat(client, "Resetmatch voting isn't allowed for spectators.");
		return;
	}
	if (!LGO_IsMatchModeLoaded())
	{
		PrintToChat(client, "Resetmatch vote cannot be started. No match is running.");
		return;
	}
	if (NativeVotes_IsNewVoteAllowed())
	{
		new iNumPlayers;
		decl iPlayers[MaxClients];
		for (new i=1; i<=MaxClients; i++)
		{
			if (!IsClientInGame(i) || IsFakeClient(i) || (GetClientTeam(i) == L4D_TEAM_SPECTATE))
			{
				continue;
			}
			iPlayers[iNumPlayers++] = i;
		}
		if (iNumPlayers < GetConVarInt(g_hCvarPlayerLimit))
		{
			PrintToChat(client, "Resetmatch vote cannot be started. Not enough players.");
			return;
		}
		g_hResetMatchVote = NativeVotes_Create(VoteActionHandler, NativeVotesType_Custom_YesNo, MenuAction_Cancel | MenuAction_VoteEnd | MenuAction_End);
		NativeVotes_SetTitle(g_hResetMatchVote, "Turn off confogl?");
		NativeVotes_SetInitiator(g_hResetMatchVote, client);
		NativeVotes_SetResultCallback(g_hResetMatchVote, VoteResultHandler);
		NativeVotes_Display(g_hResetMatchVote, iPlayers, iNumPlayers, 20);
		FakeClientCommand(client, "Vote Yes");
		return;
	}
	PrintToChat(client, "Resetmatch vote cannot be started now.");
}

public Action:MatchResetTimer(Handle:timer)
{
	for (new i=1; i<=MaxClients; i++)
	{
		if(IsClientConnected(i) && !IsFakeClient(i))
		{
			return Plugin_Handled;
		}
	}
	ServerCommand("sm_resetmatch");
	return Plugin_Handled;
}

public OnClientDisconnect(client)
{
	if(IsFakeClient(client) || !LGO_IsMatchModeLoaded())
		return;
	new Float:fResetTime = GetConVarFloat(g_hCvarResetTime);
	if (fResetTime >= 0.0)
		CreateTimer(fResetTime, MatchResetTimer);
}
