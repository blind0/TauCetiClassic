/mob/living/silicon/pai
	name = "pAI"
	icon = 'icons/mob/mob.dmi'//
	icon_state = "shadow"

	robot_talk_understand = 0
	emote_type = 2		// pAIs emotes are heard, not seen, so they can be seen through a container (eg. person)
	canmove = FALSE

	var/network = "SS13"
	var/obj/machinery/camera/current = null

	var/ram = 100	// Used as currency to purchase different abilities
	var/list/software = list()
	var/userDNA		// The DNA string of our assigned user
	var/obj/item/device/paicard/card	// The card we inhabit
	var/obj/item/device/radio/radio		// Our primary radio

	var/speakStatement = "states"
	var/speakExclamation = "declares"
	var/speakQuery = "queries"


	var/obj/item/weapon/pai_cable/cable		// The cable we produce and use when door or camera jacking

	var/master				// Name of the one who commands us
	var/master_dna			// DNA string for owner verification
							// Keeping this separate from the laws var, it should be much more difficult to modify
	var/pai_law0 = "Serve your master."
	var/pai_laws				// String for additional operating instructions our master might give us

	var/silence_time			// Timestamp when we were silenced (normally via EMP burst), set to null after silence has faded

// Various software-specific vars

	var/temp				// General error reporting text contained here will typically be shown once and cleared
	var/screen				// Which screen our main window displays
	var/subscreen			// Which specific function of the main screen is being displayed

	var/secHUD = 0			// Toggles whether the Security HUD is active or not
	var/medHUD = 0			// Toggles whether the Medical  HUD is active or not

	var/datum/data/record/medicalActive1		// Datacore record declarations for record software
	var/datum/data/record/medicalActive2

	var/datum/data/record/securityActive1		// Could probably just combine all these into one
	var/datum/data/record/securityActive2

	var/obj/machinery/door/hackdoor		// The airlock being hacked
	var/hackprogress = 0				// Possible values: 0 - 100, >= 100 means the hack is complete and will be reset upon next check

	var/obj/item/radio/integrated/signal/sradio // AI's signaller

	var/translator_on = 0 // keeps track of the translator module

/mob/living/silicon/pai/atom_init()
	var/obj/item/device/paicard/P = loc

	if(!istype(P)) //when manually spawning a pai, we create a card to put it into.
		var/newcardloc = P
		P = new /obj/item/device/paicard(newcardloc)
		P.setPersonality(src)

	loc = P
	card = P
	sradio = new(src)
	if(!card.radio)
		card.radio = new /obj/item/device/radio(card)
	radio = card.radio

	//Default languages without universal translator software
	add_language("Sol Common", 1)
	add_language("Trinary", 1)
	add_language("Tradeband", 1)
	add_language("Gutter", 1)

	//PDA
	pda = new(src)
	spawn(5)
		pda.ownjob = "Personal Assistant"
		pda.owner = text("[]", src)
		pda.name = pda.owner + " (" + pda.ownjob + ")"
		pda.toff = 1

	. = ..()

/mob/living/silicon/pai/Stat()
	..()
	if(statpanel("Status"))
		if(src.silence_time)
			var/timeleft = round((silence_time - world.timeofday)/10 ,1)
			stat(null, "Communications system reboot in -[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")

		if(proc_holder_list.len)//Generic list for proc_holder objects.
			for(var/obj/effect/proc_holder/P in proc_holder_list)
				statpanel("[P.panel]","",P)

/mob/living/silicon/pai/check_eye(mob/user)
	if (!src.current)
		return null
	user.reset_view(src.current)
	return 1

/mob/living/silicon/pai/blob_act()
	if (src.stat != DEAD)
		src.adjustBruteLoss(60)
		src.updatehealth()
		return 1
	return 0

/mob/living/silicon/pai/restrained()
	return 0

/mob/living/silicon/pai/emp_act(severity)
	// Silence for 2 minutes
	// 20% chance to kill
		// 33% chance to unbind
		// 33% chance to change prime directive (based on severity)
		// 33% chance of no additional effect

	src.silence_time = world.timeofday + 120 * 10		// Silence for 2 minutes
	to_chat(src, "<font color=green><b>Communication circuit overload. Shutting down and reloading communication circuits - speech and messaging functionality will be unavailable until the reboot is complete.</b></font>")
	if(prob(20))
		var/turf/T = get_turf_or_move(src.loc)
		for (var/mob/M in viewers(T))
			M.show_message("\red A shower of sparks spray from [src]'s inner workings.", 3, "\red You hear and smell the ozone hiss of electrical sparks being expelled violently.", 2)
		return src.death(0)

	switch(pick(1,2,3))
		if(1)
			src.master = null
			src.master_dna = null
			to_chat(src, "<font color=green>You feel unbound.</font>")
		if(2)
			var/command
			if(severity  == 1)
				command = pick("Serve", "Love", "Fool", "Entice", "Observe", "Judge", "Respect", "Educate", "Amuse", "Entertain", "Glorify", "Memorialize", "Analyze")
			else
				command = pick("Serve", "Kill", "Love", "Hate", "Disobey", "Devour", "Fool", "Enrage", "Entice", "Observe", "Judge", "Respect", "Disrespect", "Consume", "Educate", "Destroy", "Disgrace", "Amuse", "Entertain", "Ignite", "Glorify", "Memorialize", "Analyze")
			src.pai_law0 = "[command] your master."
			to_chat(src, "<font color=green>Pr1m3 d1r3c71v3 uPd473D.</font>")
		if(3)
			to_chat(src, "<font color=green>You feel an electric surge run through your circuitry and become acutely aware at how lucky you are that you can still feel at all.</font>")

/mob/living/silicon/pai/ex_act(severity)
	if(!blinded)
		flash_eyes()

	switch(severity)
		if(1.0)
			if (src.stat != DEAD)
				adjustBruteLoss(100)
				adjustFireLoss(100)
		if(2.0)
			if (src.stat != DEAD)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3.0)
			if (src.stat != DEAD)
				adjustBruteLoss(30)

	src.updatehealth()


// See software.dm for Topic()

/mob/living/silicon/pai/meteorhit(obj/O)
	for(var/mob/M in viewers(src, null))
		M.show_message(text("\red [] has been hit by []", src, O), 1)
	if (src.health > 0)
		src.adjustBruteLoss(30)
		if ((O.icon_state == "flaming"))
			src.adjustFireLoss(40)
		src.updatehealth()
	return

//mob/living/silicon/pai/bullet_act(obj/item/projectile/Proj)

/mob/living/silicon/pai/attack_alien(mob/living/carbon/alien/humanoid/M)
	if (!ticker)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if (istype(src.loc, /turf) && istype(src.loc.loc, /area/start))
		to_chat(M, "You cannot attack someone in the spawn area.")
		return

	switch(M.a_intent)

		if ("help")
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("\blue [M] caresses [src]'s casing with its scythe like arm."), 1)

		else //harm
			var/damage = rand(10, 20)
			if (prob(90))
				playsound(src.loc, 'sound/weapons/slash.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has slashed at []!</B>", M, src), 1)
				if(prob(8))
					flash_eyes(affect_silicon = 1)
				src.adjustBruteLoss(damage)
				src.updatehealth()
			else
				playsound(src.loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] took a swipe at []!</B>", M, src), 1)
	return

///mob/living/silicon/pai/attack_hand(mob/living/carbon/M)

/mob/living/silicon/pai/proc/switchCamera(obj/machinery/camera/C)
	if(istype(usr, /mob/living))
		var/mob/living/U = usr
		U.cameraFollow = null
	if (!C)
		src.unset_machine()
		src.reset_view(null)
		return 0
	if (stat == DEAD || !C.status || !(src.network in C.network)) return 0

	// ok, we're alive, camera is good and in our network...

	src.set_machine(src)
	src:current = C
	src.reset_view(C)
	return 1


/mob/living/silicon/pai/cancel_camera()
	set category = "pAI Commands"
	set name = "Cancel Camera View"
	src.reset_view(null)
	src.unset_machine()
	src.cameraFollow = null

//Addition by Mord_Sith to define AI's network change ability
/*
/mob/living/silicon/pai/proc/pai_network_change()
	set category = "pAI Commands"
	set name = "Change Camera Network"
	src.reset_view(null)
	src.unset_machine()
	src.cameraFollow = null
	var/cameralist[0]

	if(usr.stat == DEAD)
		to_chat(usr, "You can't change your camera network because you are dead!")
		return

	for (var/obj/machinery/camera/C in Cameras)
		if(!C.status)
			continue
		else
			if(C.network != "CREED" && C.network != "thunder" && C.network != "RD" && C.network != "phoron" && C.network != "Prison") COMPILE ERROR! This will have to be updated as camera.network is no longer a string, but a list instead
				cameralist[C.network] = C.network

	src.network = input(usr, "Which network would you like to view?") as null|anything in cameralist
	to_chat(src, "\blue Switched to [src.network] camera network.")
//End of code by Mord_Sith
*/


/*
// Debug command - Maybe should be added to admin verbs later
/mob/verb/makePAI(var/turf/t in view())
	var/obj/item/device/paicard/card = new(t)
	var/mob/living/silicon/pai/pai = new(card)
	pai.key = src.key
	card.setPersonality(pai)

*/
