#pragma semicolon 1
#include <sourcemod>

#define PLUGIN_NAME	   "All Chat (Lite)"
#define PLUGIN_VERSION "1.0"

public Plugin:myinfo =
{
	name = PLUGIN_NAME,
	author = "Root",
	description = "Relays chat messages to all players",
	version = PLUGIN_VERSION,
	url = "http://steamcommunity.com/id/zadroot/"
};

new author, bool:Chat, bool:Target[MAXPLAYERS + 1];
new String:Type[64], String:Name[64], String:Text[512];

public OnPluginStart()
{
	CreateConVar("sm_allchat_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD);

	new UserMsg:SayText2 = GetUserMessageId("SayText2");

	if (SayText2 == INVALID_MESSAGE_ID)
		SetFailState("This game doesn't support SayText2!!");

	HookUserMessage(SayText2, Hook_UserMessage);
	HookEvent("player_say",   Event_Player_Say);

	AddCommandListener(Command_Say, "say");
}

public Action:Hook_UserMessage(UserMsg:msg_id, Handle:bf, const players[], playersNum, bool:reliable, bool:init)
{
	author = BfReadByte(bf);
	Chat   = bool:BfReadByte(bf);
	BfReadString(bf, Type, sizeof(Type), false);
	BfReadString(bf, Name, sizeof(Name), false);
	BfReadString(bf, Text, sizeof(Text), false);

	for (new i = 0; i < playersNum; i++)
	{
		Target[players[i]] = false;
	}
}

public Action:Event_Player_Say(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GetClientOfUserId(GetEventInt(event, "userid")) == author)
	{
		decl players[MaxClients];
		new playersNum = 0;

		for (new client = 1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client) && Target[client])
			{
				players[playersNum++] = client;
			}

			Target[client] = false;
		}

		if (playersNum == 0)
			return;

		new Handle:SayText2 = StartMessage("SayText2", players, playersNum, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);

		if (SayText2 != INVALID_HANDLE)
		{
			BfWriteByte(SayText2,   author);
			BfWriteByte(SayText2,   Chat);
			BfWriteString(SayText2, Type);
			BfWriteString(SayText2, Name);
			BfWriteString(SayText2, Text);
			EndMessage();
		}
	}
}

public Action:Command_Say(client, const String:command[], argc)
{
	for (new target = 1; target <= MaxClients; target++)
		Target[target] = true;

	return Plugin_Continue;
}