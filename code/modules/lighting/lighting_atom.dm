/atom
	var/light_power = 1 // Intensity of the light.
	var/light_range = 0 // Range in tiles of the light.
	var/light_color     // Hexadecimal RGB string representing the colour of the light.

	var/tmp/datum/light_source/light // Our light source. Don't fuck with this directly unless you have a good reason!
	var/tmp/list/light_sources       // Any light sources that are "inside" of us, for example, if src here was a mob that's carrying a flashlight, that flashlight's light source would be part of this list.

// The proc you should always use to set the light of this atom.
/atom/proc/set_light(l_range, l_power, l_color)
	if(l_power != null) light_power = l_power
	if(l_range != null) light_range = l_range
	if(l_color != null) light_color = l_color

	update_light()

// Will update the light (duh).
// Creates or destroys it if needed, makes it update values, makes sure it's got the correct source turf...
/atom/proc/update_light()
	if(!light_power || !light_range) // We won't emit light anyways, destroy the light source.
		if(light)
			light.destroy()
			light = null
	else
		if(!istype(loc, /atom/movable)) // We choose what atom should be the top atom of the light here.
			. = src
		else
			. = loc

		if(light) // Update the light or create it if it does not exist.
			light.update(.)
		else
			light = new/datum/light_source(src, .)

// Should always be used to change the opacity of an atom.
// It notifies (potentially) affected light sources so they can update (if needed).
/atom/proc/set_opacity(new_opacity)
	var/old_opacity = opacity
	opacity = new_opacity
	var/turf/T = loc
	if(old_opacity != new_opacity && istype(T))
		T.reconsider_lights()

// This code makes the light be queued for update when it is moved.
// Entered() should handle it, however Exited() can do it if it is being moved to nullspace (as there would be no Entered() call in that situation).
/atom/Entered(atom/movable/Obj, atom/OldLoc) //Implemented here because forceMove() doesn't call Move()
	. = ..()

	if(Obj && OldLoc != src)
		for(var/A in Obj.light_sources) // Cycle through the light sources on this atom and tell them to update.
			if(!A)
				continue

			var/datum/light_source/L = A
			L.source_atom.update_light()

/atom/Exited(var/atom/movable/Obj, var/atom/newloc)
	. = ..()

	if(!newloc && Obj && newloc != src) // Incase the atom is being moved to nullspace, we handle queuing for a lighting update here.
		for(var/A in Obj.light_sources) // Cycle through the light sources on this atom and tell them to update.
			if(!A)
				continue

			var/datum/light_source/L = A
			L.source_atom.update_light()

/obj/item/equipped()
	. = ..()
	update_light()

/obj/item/pickup()
	. = ..()
	update_light()

/obj/item/dropped()
	. = ..()
	update_light()

//Version of view() which ignores darkness, because BYOND doesn't have it.
/proc/dview(range = world.view, center, invis_flags = 0)
	if(!center)
		return

	dview_mob.loc = center

	dview_mob.see_invisible = invis_flags

	. = view(range, dview_mob)
	dview_mob.loc = null

var/mob/dview/dview_mob = new

/mob/dview
	invisibility = 101
	density = 0

	anchored = 1
	simulated = 0

	see_in_dark = 1e6

/mob/dview/atom_init() // Properly prevents this mob from gaining huds or joining any global lists
	if(initialized)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	initialized = TRUE
	return INITIALIZE_HINT_NORMAL
