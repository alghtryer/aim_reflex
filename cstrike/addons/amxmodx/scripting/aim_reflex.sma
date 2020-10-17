/*
*	___________
*
*	Fast Aim / Reflex Training
*		
*	Author: ALGHTRYER 
*	e: alghtryer@gmail.com w: alghtryer.github.io 	
*	___________
*
*	Plugin for Fast Aim / Reflex Training map: Respawn, Unlimited Ammo, 
*	Give Weapon and all bot configurations.
*	
*	Cvar:
*	bot_armor 0/1 - On/Off Armor for bot.
*
*	Credits: 
*	ConnorMcLeod	: Unlimited Ammo
*/

#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <hamsandwich>
#include <fakemeta> 
#include <cstrike>

enum 
{ 
    CurWeapon_IsActive = 1, // byte 
    CurWeapon_WeaponID, // byte 
    CurWeapon_ClipAmmo // byte 
} 

const XO_CBASEPLAYERWEAPON = 4 
const m_iClip = 51 
const m_iClientClip = 52 

const m_pActiveItem = 373 

new const g_iMaxClip[CSW_P90+1] = { 
    -1,  13, -1, 10,  1,  7,    1, 30, 30,  1,  30,  
        20, 25, 30, 35, 25,   12, 20, 10, 30, 100,  
        8 , 30, 30, 20,  2,    7, 30, 30, -1,  50 
} 

new cvar_on
new gMessage

public plugin_init() 
{

	register_plugin
	(
		"Fast Aim / Reflex Training",		
		"1.0",	
		"ALGHTRYER"
	);
	
	
	RegisterHam(Ham_Killed, "player", "PlayerKilled", 1); 

	register_message(get_user_msgid("CurWeapon"), "Message_CurWeapon")
	RegisterHam(Ham_Spawn, "player", "CBasePlayer_Spawn_Post", true);

	cvar_on = register_cvar("bot_armor", "0");

	register_clcmd("chooseteam", "handled");
	register_clcmd("jointeam", "handled"); 
		
}
public plugin_cfg( ) 
{
	server_cmd("mp_autoteambalance 0");
	server_cmd("mp_limitteams 0");
	server_cmd("humans_join_team CT");
	server_cmd("bot_join_team T");
	server_cmd("bot_quota 16");
	server_cmd("bot_stop 0");
	server_cmd("mp_freezetime 0");
	server_cmd("bot_knives_only");
	
	server_cmd("sv_restartround 1");
}
public client_putinserver( id )
{
	if (!is_user_bot(id))
	{
		gMessage = 6;
		set_task(1.0, "Install_Message", id,_,_,"b",_);
	}
}
public Install_Message( id )
{
	gMessage--;
	switch(gMessage)
	{
		case 5: 
		{
			client_print(id, print_chat, "Installint Map...")	
		}
		case 4: 
		{
			client_print(id, print_chat, "...Add Bots...")	
		}
		case 3: client_print(id, print_chat, "...Configures Bots...")
			
		case 2: 
		{
			client_print(id, print_chat, "...Almost Ready...")
		}
		case 1: client_print(id, print_chat, "Map is ready for playing.")
		
		case 0: 
		{ 
			server_cmd("sv_restartround 1"); 
			remove_task(id);
			client_print(id, print_chat, "Enjoy!")
		}
	}
}
public handled(id) 
{ 
	if ( cs_get_user_team(id) == CS_TEAM_UNASSIGNED ) 
		return PLUGIN_CONTINUE;
 
	return PLUGIN_HANDLED; 
}
public PlayerKilled(Victim)
{
	if (!is_user_alive(Victim))
		set_task(1.0, "PlayerRespawn", Victim);
}
public PlayerRespawn(id)
{
	if (!is_user_alive(id) && CS_TEAM_T <= cs_get_user_team(id) <= CS_TEAM_CT )
	{
		ExecuteHamB(Ham_CS_RoundRespawn, id);
	}
}
public cz_bot_ham_registerable( id ) 
{ 
	RegisterHamFromEntity(Ham_Killed, id, "PlayerKilled")
	RegisterHamFromEntity(Ham_Spawn, id, "CBasePlayer_Spawn_Post", true)
}

public client_disconnect(id)
{
	remove_task(id);
	return PLUGIN_HANDLED;
}
public CBasePlayer_Spawn_Post( id )
{
	if( is_user_alive(id) )
	{
		if(get_pcvar_num(cvar_on)) 
			cs_set_user_armor ( id, 100, CS_ARMOR_VESTHELM );

		if (!is_user_bot(id))
		{
			give_item(id, "weapon_deagle");
			give_item(id, "weapon_usp"); 
			give_item(id, "weapon_glock18");
			give_item(id, "weapon_ak47");
			give_item(id, "weapon_m4a1");
			give_item(id, "weapon_awp" );
		} 
	}
}
public Message_CurWeapon(iMsgId, iMsgDest, id) 
{ 
    if( get_msg_arg_int(CurWeapon_IsActive) ) 
    { 
        new iMaxClip = g_iMaxClip[  get_msg_arg_int( CurWeapon_WeaponID )  ] 
        if( iMaxClip > 2 && get_msg_arg_int(CurWeapon_ClipAmmo) < iMaxClip ) 
        { 
            new iWeapon = get_pdata_cbase(id, m_pActiveItem) 
            if( iWeapon > 0 ) 
            { 
                set_pdata_int(iWeapon, m_iClip, iMaxClip, XO_CBASEPLAYERWEAPON) 
                set_pdata_int(iWeapon, m_iClientClip, iMaxClip, XO_CBASEPLAYERWEAPON) 

                set_msg_arg_int(CurWeapon_ClipAmmo, ARG_BYTE, iMaxClip) 
            } 
        } 
    } 
} 