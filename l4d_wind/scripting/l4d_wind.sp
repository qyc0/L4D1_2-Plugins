/* Plugin Template generated by Pawn Studio */
#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
static float g_pos[3];

public Plugin:myinfo = 
{
	name = "add a survivor bot",
	author = "Harry Potter",
	description = "create a survivor bot into game",
	version = "1.1",
	url = ""
}

public OnPluginStart()
{
		RegAdminCmd("sm_wind",sm_addabot, ADMFLAG_BAN, "add a survivor bot");
		RegAdminCmd("sm_addbot",sm_addabot, ADMFLAG_BAN, "add a survivor bot");
		RegAdminCmd("sm_createbot",sm_addabot, ADMFLAG_BAN, "add a survivor bot");
		RegAdminCmd("sm_more",sm_addabot, ADMFLAG_BAN, "add a survivor bot");
		RegConsoleCmd("sm_jiaru",sm_join, "spectator join a bot");
}

public Action:sm_addabot(client, args)
{
	int bot = CreateFakeClient("I am not real.");
	if(bot != 0)
	{
		ChangeClientTeam(bot, 2);
		if(DispatchKeyValue(bot, "classname", "SurvivorBot") == false)
		{
			PrintToChatAll("\x01[TS] Failed to add a bot");
			return Plugin_Handled;
		}
		
		if(DispatchSpawn(bot) == false)
		{
			PrintToChatAll("\x01[TS] Failed to add a bot");
			return Plugin_Handled;
		}
		SetEntityRenderColor(bot, 128, 0, 0, 255);
 		
		bool canTeleport = SetTeleportEndPoint(client);
		if(canTeleport)
		{
			PerformTeleport(client,bot,g_pos);
		}
		
		CreateTimer(0.1, Timer_KickFakeBot, bot, TIMER_REPEAT);
		PrintToChatAll("\x01[TS] Succeed to add a bot, Spectator type \x04!jiaru\x01 to join");
	}
	return Plugin_Handled;
}

public Action:sm_join(int client, int args)
{
	if(GetClientTeam(client) == 1)
		FakeClientCommand(client, "jointeam 2");
	else
		PrintToChat(client,"\x01[TS] You are not Spectator...");
 	return Plugin_Handled;
}


static bool:SetTeleportEndPoint(int client)
{
	float vAngles[3],vOrigin[3];
	
	GetClientEyePosition(client,vOrigin);
	GetClientEyeAngles(client, vAngles);
	
	//get endpoint for teleport
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	
	if(TR_DidHit(trace))
	{
		decl Float:vBuffer[3], Float:vStart[3];

		TR_GetEndPosition(vStart, trace);
		GetVectorDistance(vOrigin, vStart, false);
		new Float:Distance = -35.0;
		GetAngleVectors(vAngles, vBuffer, NULL_VECTOR, NULL_VECTOR);
		g_pos[0] = vStart[0] + (vBuffer[0]*Distance);
		g_pos[1] = vStart[1] + (vBuffer[1]*Distance);
		g_pos[2] = vStart[2] + (vBuffer[2]*Distance);
	}
	else
	{
		PrintToChat(client, "[TS] %s", "Could not teleport player after create a bot");
		CloseHandle(trace);
		return false;
	}
	CloseHandle(trace);
	return true;
}

PerformTeleport(int client, int target, float pos[3])
{
	pos[2]+=40.0;
	TeleportEntity(target, pos, NULL_VECTOR, NULL_VECTOR);
	
	LogAction(client,target, "\"%L\" teleported \"%L\" after respawning him" , client, target);
}


public Action:Timer_KickFakeBot(Handle timer, int fakeclient)
{
	if(IsClientConnected(fakeclient))
	{
		KickClient(fakeclient, "Kicking FakeClient");	
		return Plugin_Stop;
	}	
	return Plugin_Continue;
}

public bool:TraceEntityFilterPlayer(entity, contentsMask)
{
	return entity > MaxClients || !entity;
} 
